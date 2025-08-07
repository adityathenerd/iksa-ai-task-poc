from langgraph.graph import StateGraph, END
from typing import TypedDict, List, Optional, Dict, Any
from langchain.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_openai import ChatOpenAI
import os
from dotenv import load_dotenv
load_dotenv()
from langchain.tools import tool
from langchain_core.messages import HumanMessage, AIMessage
from ollama import chat
from kg_drafter import integrate_with_intake_script

@tool
def thesis_generator(conversation_summary: str) -> str:
    """Generate a clinical thesis from the full patient conversation using MedGemma via Ollama."""
    messages = [
        {
            "role": "system", 
            "content": """You are a medical expert. Analyze this patient conversation and generate:
1. A structured symptom summary
2. Potential differential diagnoses
3. Recommended next steps"""
        },
        {
            "role": "user", 
            "content": f"Patient conversation:\n{conversation_summary}"
        },
    ]
    print("Generating thesis...")
    response = chat(model="alibayram/medgemma:latest", messages=messages)
    return response.message.content


def generate_conversation_summary(messages: List[Dict[str, str]]) -> str:
    """Convert conversation messages into a coherent summary"""
    summary = []
    for msg in messages:
        role = "Patient" if msg["role"] == "user" else "Doctor"
        summary.append(f"{role}: {msg['content']}")
    return "\n".join(summary)


# SYSTEM PROMPT
system_prompt = """
You are a medical intake assistant. Your goal is to gather all relevant clinical information through natural conversation.

Keep in mind that the patient is in their first trimester of pregnancy. Consider complications that may arise from this and ask the patient about any pre-existing conditions.

Key responsibilities:
1. Start by asking about primary symptoms
2. For each symptom, gather:
   - Onset and duration
   - Severity and characteristics
   - Alleviating/aggravating factors
3. Explore associated symptoms
4. When patient indicates they're done, summarize and confirm:
   - "Let me summarize what you've told me..."
   - "Is there anything else we haven't covered?"

Only when confirmation is complete should you generate the clinical analysis.
"""

# Create a proper prompt template
prompt_template = ChatPromptTemplate.from_messages([
    ("system", system_prompt),
    MessagesPlaceholder("chat_history", optional=True),
    ("human", "{input}"),
    MessagesPlaceholder("agent_scratchpad")
])

tools = [thesis_generator]  # Make sure thesis_generator is properly defined
llm = ChatOpenAI(model="gpt-4", api_key=os.getenv('OPENAI_API_KEY'))  # Using standard gpt-4 as gpt-4.1 doesn't exist
agent = create_tool_calling_agent(llm=llm, tools=tools, prompt=prompt_template)
agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)

# Define state
class AgentState(TypedDict):
    messages: List[Dict[str, str]]  # Store as proper message objects
    symptoms: str
    waiting_for_input: bool
    diagnosis: Optional[str]
    should_end: bool   



# Define nodes with updated state references
def initialize_state():
    return {
        "messages": [],
        "symptoms": "",
        "waiting_for_input": True,
        "diagnosis": None,
        "should_end": False
    }

def agent_node(state: Dict[str, Any]):
    if state["waiting_for_input"]:
        return state
        
    # Convert messages to LangChain message format
    chat_history = []
    for msg in state["messages"]:
        if msg["role"] == "user":
            chat_history.append(HumanMessage(content=msg["content"]))
        else:
            chat_history.append(AIMessage(content=msg["content"]))
    
    # Get last user input
    last_user_msg = next((m for m in reversed(state["messages"]) if m["role"] == "user"), None)
    input_text = last_user_msg["content"] if last_user_msg else ""
    
    # Run agent with conversation history
    response = agent_executor.invoke({
        "input": input_text,
        "chat_history": chat_history
    })["output"]
    
    # Store agent response
    state["messages"].append({"role": "assistant", "content": response})
    
    # Check for ending condition
    if "anything else" in response.lower():
        user_responses = [m["content"].lower() for m in state["messages"] if m["role"] == "user"]
        if any("no" in resp or "that's all" in resp for resp in user_responses):
            state["should_end"] = True
    
    state["waiting_for_input"] = True
    return state

def patient_input_node(state: Dict[str, Any]):
    if not state["waiting_for_input"]:
        return state
        
    user_input = input("\nPatient: ").strip()
    if not user_input:
        return state
        
    # Store user message
    state["messages"].append({"role": "user", "content": user_input})
    state["symptoms"] += " " + user_input
    state["waiting_for_input"] = False
    return state


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
        kg_result = integrate_with_intake_script(result)
        
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

# Build the graph
graph = StateGraph(AgentState)

graph.add_node("assistant", agent_node)
graph.add_node("user_input", patient_input_node)
graph.add_node("diagnosis_generator", generate_diagnosis_node)

graph.set_entry_point("user_input")

def decide_next_node(state: Dict[str, Any]):
    state.setdefault("should_end", False)
    state.setdefault("waiting_for_input", True)
    
    if state["should_end"]:
        return "diagnosis_generator"
    if state["waiting_for_input"]:
        return "user_input"
    return "assistant"

graph.add_conditional_edges(
    "assistant",
    decide_next_node,
    {"user_input": "user_input", "diagnosis_generator": "diagnosis_generator"}
)

graph.add_conditional_edges(
    "user_input",
    lambda state: "assistant",
    {"assistant": "assistant"}
)

graph.add_edge("diagnosis_generator", END)

# Compile with recursion limit
workflow = graph.compile()

# Run conversation
print("Medical Intake Assistant (type 'quit' to exit)")
state = initialize_state()

while True:
    try:
        result = workflow.invoke(state)
        state.update(result)
        
        if state.get("diagnosis") is not None:
            break
        if any("quit" in msg.lower() for msg in state.get("conversation", []) if isinstance(msg, str)):
            print("\nEnding conversation...")
            break
    except KeyboardInterrupt:
        print("\nConversation ended by user")
        break
    except Exception as e:
        print(f"Error in conversation flow: {e}")
        break
