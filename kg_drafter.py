import json
import re
from typing import Dict, List, Any, Optional
from dataclasses import dataclass
from enum import Enum
import uuid
from datetime import datetime
import logging
from langchain_openai import ChatOpenAI
import os
from dotenv import load_dotenv
load_dotenv()
from langchain.prompts import ChatPromptTemplate
from langchain_core.output_parsers import JsonOutputParser
from pydantic import BaseModel, Field
from neo4j import GraphDatabase
import time

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Pydantic models for structured output
class ClinicalEntity(BaseModel):
    name: str = Field(description="Name of the clinical entity")
    type: str = Field(description="Type of entity: symptom, condition, test, treatment, medication, risk_factor")
    properties: Dict[str, Any] = Field(default_factory=dict, description="Additional properties like severity, duration, location, etc.")
    icd_code: Optional[str] = Field(default=None, description="ICD-10 code if applicable")
    confidence: Optional[str] = Field(default=None, description="Confidence level: high, moderate, low")

class ClinicalRelationship(BaseModel):
    from_entity: str = Field(description="Source entity name")
    to_entity: str = Field(description="Target entity name")
    relationship_type: str = Field(description="Type: suggests, indicates_need_for, treated_by, diagnosed_with, etc.")
    properties: Dict[str, Any] = Field(default_factory=dict, description="Relationship properties")
    confidence: Optional[str] = Field(default=None, description="Confidence in this relationship")

class PatientCase(BaseModel):
    patient_demographics: Dict[str, Any] = Field(default_factory=dict, description="Age, gender, relevant history")
    chief_complaint: str = Field(description="Primary reason for visit")
    entities: List[ClinicalEntity] = Field(description="All clinical entities found in the report")
    relationships: List[ClinicalRelationship] = Field(description="Relationships between entities")
    clinical_reasoning: str = Field(description="Summary of clinical reasoning from the report")
    recommendations: List[str] = Field(description="Next steps and recommendations")

class Neo4jConnection:
    """Handles Neo4j database connection and query execution"""
    
    def __init__(self, database: str = "neo4j"):
        self.uri = "bolt://localhost:7687"
        self.username = "neo4j"
        self.password = "password"
        self.database = database
        self.driver = GraphDatabase.driver(self.uri, auth=(self.username, self.password))
        
    def connect(self):
        """Establish connection to Neo4j database"""
        try:
            self.driver = GraphDatabase.driver(
                self.uri, 
                auth=(self.username, self.password)
            )
            # Test connection
            with self.driver.session(database=self.database) as session:
                session.run("RETURN 1")
            logger.info(f"Successfully connected to Neo4j at {self.uri}")
            return True
        except Exception as e:
            logger.error(f"Failed to connect to Neo4j: {e}")
            return False
    
    def close(self):
        """Close Neo4j connection"""
        if self.driver:
            self.driver.close()
            logger.info("Neo4j connection closed")
    
    def execute_query(self, query: str, parameters: Dict[str, Any] = None) -> List[Dict[str, Any]]:
        """Execute a single Cypher query"""
        if not self.driver:
            raise Exception("No active database connection. Call connect() first.")
        
        try:
            with self.driver.session(database=self.database) as session:
                result = session.run(query, parameters or {})
                records = [record.data() for record in result]
                return records
        except Exception as e:
            logger.error(f"Query execution failed: {e}")
            logger.error(f"Query: {query}")
            raise
    
    def execute_queries_batch(self, queries: List[str], batch_size: int = 10) -> Dict[str, Any]:
        """Execute multiple queries in batches"""
        if not self.driver:
            raise Exception("No active database connection. Call connect() first.")
        
        results = {
            'success_count': 0,
            'error_count': 0,
            'errors': [],
            'execution_time': 0
        }
        
        start_time = time.time()
        
        try:
            with self.driver.session(database=self.database) as session:
                for i in range(0, len(queries), batch_size):
                    batch = queries[i:i + batch_size]
                    logger.info(f"Executing batch {i//batch_size + 1}: queries {i+1} to {min(i+batch_size, len(queries))}")
                    
                    for j, query in enumerate(batch):
                        try:
                            session.run(query)
                            results['success_count'] += 1
                            logger.debug(f"Query {i+j+1} executed successfully")
                        except Exception as e:
                            results['error_count'] += 1
                            error_info = {
                                'query_index': i + j + 1,
                                'query': query[:100] + "..." if len(query) > 100 else query,
                                'error': str(e)
                            }
                            results['errors'].append(error_info)
                            logger.error(f"Query {i+j+1} failed: {e}")
                    
                    # Small delay between batches to avoid overwhelming the database
                    if i + batch_size < len(queries):
                        time.sleep(0.1)
        
        except Exception as e:
            logger.error(f"Batch execution failed: {e}")
            raise
        
        results['execution_time'] = time.time() - start_time
        return results
    
    def clear_database(self, confirm: bool = False):
        """Clear all nodes and relationships (USE WITH CAUTION!)"""
        if not confirm:
            raise Exception("Database clearing requires explicit confirmation. Set confirm=True")
        
        logger.warning("Clearing entire database...")
        self.execute_query("MATCH (n) DETACH DELETE n")
        logger.info("Database cleared successfully")
    
    def get_database_stats(self) -> Dict[str, Any]:
        """Get database statistics"""
        stats_query = """
        MATCH (n) 
        WITH labels(n) AS nodeLabels, count(*) AS nodeCount
        UNWIND nodeLabels AS label
        RETURN label, sum(nodeCount) AS count
        ORDER BY count DESC
        """
        
        rel_stats_query = """
        MATCH ()-[r]->()
        RETURN type(r) AS relationship_type, count(r) AS count
        ORDER BY count DESC
        """
        
        node_stats = self.execute_query(stats_query)
        rel_stats = self.execute_query(rel_stats_query)
        
        total_nodes_query = "MATCH (n) RETURN count(n) AS total_nodes"
        total_rels_query = "MATCH ()-[r]->() RETURN count(r) AS total_relationships"
        
        total_nodes = self.execute_query(total_nodes_query)[0]['total_nodes']
        total_rels = self.execute_query(total_rels_query)[0]['total_relationships']
        
        return {
            'total_nodes': total_nodes,
            'total_relationships': total_rels,
            'node_types': node_stats,
            'relationship_types': rel_stats
        }

class Neo4jQueryBuilder:
    """Builds Neo4j Cypher queries from JSON knowledge graph"""
    
    def __init__(self):
        self.node_queries = []
        self.relationship_queries = []
    
    def build_cypher_from_json(self, kg_json: Dict[str, Any]) -> List[str]:
        """Convert JSON KG to Cypher queries"""
        queries = []
        
        # Build node creation queries
        for entity in kg_json.get('entities', []):
            query = self._build_node_query(entity)
            queries.append(query)
        
        # Build relationship creation queries
        for rel in kg_json.get('relationships', []):
            query = self._build_relationship_query(rel)
            queries.append(query)
        
        return queries
    
    def _build_node_query(self, entity: Dict[str, Any]) -> str:
        """Build MERGE query for a node"""
        node_type = entity['type'].replace(' ', '').title()
        name = entity['name'].replace("'", "\\'")
        
        # Build properties string
        props = {"name": name}
        props.update(entity.get('properties', {}))
        
        # Convert properties to Cypher format
        prop_strings = []
        for key, value in props.items():
            if isinstance(value, str):
                prop_strings.append(f"{key}: '{value.replace('\"', '\\\"')}'")
            elif isinstance(value, (int, float)):
                prop_strings.append(f"{key}: {value}")
            elif isinstance(value, bool):
                prop_strings.append(f"{key}: {str(value).lower()}")
            elif value is not None:
                prop_strings.append(f"{key}: '{str(value).replace('\"', '\\\"')}'")
        
        props_str = ", ".join(prop_strings)
        
        return f"MERGE (:{node_type} {{{props_str}}});"
    
    def _build_relationship_query(self, relationship: Dict[str, Any]) -> str:
        """Build relationship creation query without Cartesian product"""
        from_name = relationship['from_entity'].replace("'", "\\'")
        to_name = relationship['to_entity'].replace("'", "\\'")
        rel_type = relationship['relationship_type'].upper()
        
        # Build relationship properties
        rel_props = relationship.get('properties', {})
        if relationship.get('confidence'):
            rel_props['confidence'] = relationship['confidence']
        
        prop_strings = []
        for key, value in rel_props.items():
            if isinstance(value, str):
                prop_strings.append(f"{key}: '{value.replace('\"', '\\\"')}'")
            elif isinstance(value, (int, float)):
                prop_strings.append(f"{key}: {value}")
            elif isinstance(value, bool):
                prop_strings.append(f"{key}: {str(value).lower()}")
            elif value is not None:
                prop_strings.append(f"{key}: '{str(value).replace('\"', '\\\"')}'")
        
        props_str = f" {{{', '.join(prop_strings)}}}" if prop_strings else ""
        
        return f"""MATCH (a {{name: '{from_name}'}})
    MATCH (b {{name: '{to_name}'}})
    MERGE (a)-[:{rel_type}{props_str}]->(b);"""


class MedicalKGBuilder:
    def __init__(self, model: str = "gpt-4"):
        self.llm = ChatOpenAI(model=model, api_key=os.getenv('OPENAI_API_KEY'), temperature=0.1)
        self.json_parser = JsonOutputParser(pydantic_object=PatientCase)
        self.query_builder = Neo4jQueryBuilder()
        
        # LLM prompt for clinical report analysis
        self.analysis_prompt = ChatPromptTemplate.from_messages([
            ("system", """You are a medical AI expert specializing in clinical data extraction and knowledge graph construction.

Your task is to analyze medical reports and extract structured clinical information including:

1. **Clinical Entities**: Extract and classify all medical entities:
   - Symptoms (with severity, location, duration, onset)
   - Conditions/Diagnoses (with ICD-10 codes if known, confidence levels)
   - Diagnostic Tests (with urgency, type, timing)
   - Treatments/Medications (with dosage, frequency, route if mentioned)
   - Risk Factors (modifiable/non-modifiable)
   - Clinical Findings (lab values, imaging results)

2. **Relationships**: Identify clinical relationships:
   - symptoms → suggests → conditions
   - symptoms → indicates_need_for → diagnostic_tests
   - conditions → treated_by → treatments/medications
   - risk_factors → increases_risk_of → conditions
   - diagnostic_tests → produces → findings
   - findings → confirms/supports → conditions

3. **Clinical Context**: Extract patient demographics, timeline, severity indicators, and clinical reasoning.

**Important Guidelines:**
- Use standard medical terminology
- Include confidence levels (high/moderate/low) for diagnoses
- Preserve clinical nuances (differential diagnoses, rule-outs)
- Extract temporal relationships (onset, progression)
- Include quantitative data when available (lab values, measurements)
- Identify contraindications and drug interactions if mentioned
## IMPORTANT
- make sure you consider all the nodes mentioned and create relationships in between the nodes as relevant. don't miss any node

{format_instructions}"""),
            ("human", "Please analyze this medical report and extract structured clinical information:\n\n{medical_report}")
        ])
    
    def analyze_medical_report(self, report: str) -> Dict[str, Any]:
        """Use LLM to convert medical report to structured JSON"""
        logger.info("Analyzing medical report with LLM...")
        
        try:
            # Format the prompt
            formatted_prompt = self.analysis_prompt.format_messages(
                medical_report=report,
                format_instructions=self.json_parser.get_format_instructions()
            )
            
            # Get LLM response
            response = self.llm.invoke(formatted_prompt)
            
            # Parse JSON response
            parsed_data = self.json_parser.parse(response.content)
            
            logger.info(f"Successfully extracted {len(parsed_data.get('entities', []))} entities and {len(parsed_data.get('relationships', []))} relationships")
            
            return parsed_data
            
        except Exception as e:
            logger.error(f"Error analyzing medical report: {e}")
            raise
    
    def enhance_with_medical_knowledge(self, clinical_data: Dict[str, Any]) -> Dict[str, Any]:
        """Enhance extracted data with additional medical knowledge"""
        logger.info("Enhancing with medical knowledge...")
        
        enhancement_prompt = ChatPromptTemplate.from_messages([
            ("system", """You are a medical knowledge expert. Given extracted clinical entities and relationships, enhance them with:

1. **Missing ICD-10 codes** for conditions
2. **Additional clinical relationships** based on medical knowledge
3. **Standard medical classifications** and properties
4. **Contraindications and interactions**
5. **Typical diagnostic workups** for identified conditions
6. **Evidence-based treatment protocols**

Only add relationships that are clinically established. Mark generated relationships with "knowledge_based": true.

Return the enhanced data in the same JSON format."""),
            ("human", "Enhance this clinical data:\n\n{clinical_data}")
        ])
        
        try:
            formatted_prompt = enhancement_prompt.format_messages(
                clinical_data=json.dumps(clinical_data, indent=2)
            )
            
            response = self.llm.invoke(formatted_prompt)
            enhanced_data = self.json_parser.parse(response.content)
            
            logger.info("Successfully enhanced clinical data with medical knowledge")
            return enhanced_data
            
        except Exception as e:
            logger.warning(f"Error enhancing data: {e}. Using original data.")
            return clinical_data
    
    def build_knowledge_graph(self, report: str, enhance: bool = False) -> Dict[str, Any]:
        """Complete pipeline: report → JSON → enhanced KG"""
        
        # Step 1: Extract structured data from report
        clinical_data = self.analyze_medical_report(report)
        
        # Step 2: Enhance with medical knowledge (optional)
        if enhance:
            clinical_data = self.enhance_with_medical_knowledge(clinical_data)
        
        # Step 3: Add metadata
        clinical_data['metadata'] = {
            'created_at': datetime.now().isoformat(),
            'case_id': str(uuid.uuid4()),
            'entity_count': len(clinical_data.get('entities', [])),
            'relationship_count': len(clinical_data.get('relationships', [])),
            'enhanced': enhance
        }
        
        return clinical_data
    
    def generate_cypher_queries(self, kg_json: Dict[str, Any]) -> List[str]:
        """Generate Neo4j Cypher queries from JSON KG"""
        logger.info("Generating Cypher queries...")
        
        queries = self.query_builder.build_cypher_from_json(kg_json)
        
        # Add case creation query
        case_id = kg_json.get('metadata', {}).get('case_id', str(uuid.uuid4()))
        case_query = f"""
MERGE (case:Case {{
    id: '{case_id}',
    chief_complaint: '{kg_json.get('chief_complaint', '').replace("'", "\\'")}',
    created_at: '{kg_json.get('metadata', {}).get('created_at', '')}',
    clinical_reasoning: '{kg_json.get('clinical_reasoning', '').replace("'", "\\'")}'
}});"""
        
        queries.insert(0, case_query)
        
        logger.info(f"Generated {len(queries)} Cypher queries")
        return queries
    
    def save_to_files(self, kg_json: Dict[str, Any], base_filename: str = "medical_kg"):
        """Save KG JSON and Cypher queries to files"""
        
        # Save JSON
        json_filename = f"{base_filename}.json"
        with open(json_filename, 'w', encoding='utf-8') as f:
            json.dump(kg_json, f, indent=2, ensure_ascii=False)
        
        # Save Cypher queries
        cypher_filename = f"{base_filename}.cypher"
        queries = self.generate_cypher_queries(kg_json)
        
        with open(cypher_filename, 'w', encoding='utf-8') as f:
            f.write("// Medical Knowledge Graph - Auto-generated Cypher Queries\n")
            f.write(f"// Generated at: {datetime.now()}\n\n")
            
            for i, query in enumerate(queries, 1):
                f.write(f"// Query {i}\n{query}\n\n")
        
        logger.info(f"Saved KG to {json_filename} and queries to {cypher_filename}")
        
        return json_filename, cypher_filename

# Example usage function
def process_medical_report(report: str, enhance: bool = False) -> tuple[Dict[str, Any], List[str]]:
    """
    Main function to process a medical report into KG
    
    Args:
        report: Medical report text
        enhance: Whether to enhance with medical knowledge
    
    Returns:
        Tuple of (kg_json, cypher_queries)
    """
    
    # Initialize builder
    kg_builder = MedicalKGBuilder()
    
    # Build knowledge graph
    kg_json = kg_builder.build_knowledge_graph(report, enhance=enhance)
    
    # Generate Cypher queries
    cypher_queries = kg_builder.generate_cypher_queries(kg_json)
    
    # Save files
    kg_builder.save_to_files(kg_json, f"medical_case_{kg_json['metadata']['case_id'][:8]}")
    
    return kg_json, cypher_queries

# Integration with your existing medical intake script
def integrate_with_intake_script(diagnosis_result: str) -> Dict[str, Any]:
    """
    Function to integrate with your existing medical intake script
    Call this function with the diagnosis result from your thesis_generator
    """
    
    logger.info("Processing diagnosis result through KG builder...")
    
    try:
        kg_json, cypher_queries = process_medical_report(diagnosis_result)
        
        print(f"\n🔬 Knowledge Graph Generated:")
        print(f"  • Entities: {kg_json['metadata']['entity_count']}")
        print(f"  • Relationships: {kg_json['metadata']['relationship_count']}")
        print(f"  • Cypher Queries: {len(cypher_queries)}")
        
        return {
            'knowledge_graph': kg_json,
            'cypher_queries': cypher_queries,
            'status': 'success'
        }
        
    except Exception as e:
        logger.error(f"Error processing diagnosis: {e}")
        return {
            'error': str(e),
            'status': 'failed'
        }

"""
To integrate with your existing script, modify the generate_diagnosis_node function:

def generate_diagnosis_node(state: Dict[str, Any]):
    if not state.get("messages"):
        state["diagnosis"] = "No conversation to analyze"
        return state
    
    try:
        conversation_summary = generate_conversation_summary(state["messages"])
        print("\nGenerating diagnosis based on full conversation...")
        
        # Get clinical analysis
        result = thesis_generator.invoke({"conversation_summary": conversation_summary})
        print(f"\n🧾 Clinical Analysis:\n{result}")
        
        # NEW: Build knowledge graph from the result
        kg_result = integrate_with_intake_script(result, "your-openai-api-key")
        
        if kg_result['status'] == 'success':
            print(f"\n🔬 Knowledge Graph Built Successfully!")
            print(f"Files saved: medical_case_*.json and medical_case_*.cypher")
            
            # Optionally store KG in state
            state["knowledge_graph"] = kg_result['knowledge_graph']
        else:
            print(f"\n❌ KG Generation Failed: {kg_result.get('error')}")
        
        state["diagnosis"] = result
        
    except Exception as e:
        print(f"Error generating diagnosis: {e}")
        state["diagnosis"] = "Could not generate clinical analysis"
    
    return state
"""