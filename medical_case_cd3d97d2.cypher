// Medical Knowledge Graph - Auto-generated Cypher Queries
// Generated at: 2025-08-07 14:58:34.050635

// Query 1

MERGE (case:Case {
    id: 'cd3d97d2-cfd9-4fac-b340-6a984b356999',
    chief_complaint: 'Vaginal bleeding and cramps',
    created_at: '2025-08-07T14:58:34.040702',
    clinical_reasoning: 'The patient\'s symptoms of vaginal bleeding and cramps, along with her being in the first trimester of pregnancy, suggest possible complications such as early pregnancy loss, ectopic pregnancy, or threatened abortion. Other conditions such as placental abruption, infection, hormonal imbalance, or medication side effects are also considered but are less likely. Further evaluation through ultrasound, speculum exam, and laboratory tests is recommended to reach a definitive diagnosis.'
});

// Query 2
MERGE (:Symptom {name: 'Vaginal bleeding', severity: 'Moderate', duration: 'A couple of days', location: 'Vaginal', characteristics: 'Slightly brownish, does not worsen or improve'});

// Query 3
MERGE (:Symptom {name: 'Cramps', severity: 'Moderate', duration: 'Intermittent', location: 'Abdominal'});

// Query 4
MERGE (:Symptom {name: 'Nausea'});

// Query 5
MERGE (:Condition {name: 'Early Pregnancy Loss/Miscarriage'});

// Query 6
MERGE (:Condition {name: 'Ectopic Pregnancy'});

// Query 7
MERGE (:Condition {name: 'Threatened Abortion/Imminent Miscarriage'});

// Query 8
MERGE (:Condition {name: 'Placental Abruption'});

// Query 9
MERGE (:Condition {name: 'Infection'});

// Query 10
MERGE (:Condition {name: 'Hormonal Imbalance'});

// Query 11
MERGE (:Condition {name: 'Medication Side Effect'});

// Query 12
MERGE (:Test {name: 'Ultrasound', urgency: 'High', type: 'Transvaginal'});

// Query 13
MERGE (:Test {name: 'Speculum Exam', urgency: 'High'});

// Query 14
MERGE (:Test {name: 'Complete Blood Count (CBC)', urgency: 'High'});

// Query 15
MERGE (:Test {name: 'Serum Beta-hCG (Human Chorionic Gonadotropin)', urgency: 'High'});

// Query 16
MERGE (:Treatment {name: 'Expectant Management'});

// Query 17
MERGE (:Treatment {name: 'Medical Management'});

// Query 18
MERGE (:Treatment {name: 'Surgical Intervention'});

// Query 19
MERGE (:Medication {name: 'Bonsartan H'});

// Query 20
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Early Pregnancy Loss/Miscarriage'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 21
MATCH (a {name: 'Cramps'})
    MATCH (b {name: 'Early Pregnancy Loss/Miscarriage'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 22
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Ectopic Pregnancy'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 23
MATCH (a {name: 'Cramps'})
    MATCH (b {name: 'Ectopic Pregnancy'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 24
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Threatened Abortion/Imminent Miscarriage'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 25
MATCH (a {name: 'Cramps'})
    MATCH (b {name: 'Threatened Abortion/Imminent Miscarriage'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 26
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Placental Abruption'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 27
MATCH (a {name: 'Cramps'})
    MATCH (b {name: 'Placental Abruption'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 28
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Infection'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 29
MATCH (a {name: 'Cramps'})
    MATCH (b {name: 'Infection'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 30
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Hormonal Imbalance'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 31
MATCH (a {name: 'Cramps'})
    MATCH (b {name: 'Hormonal Imbalance'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 32
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Medication Side Effect'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 33
MATCH (a {name: 'Cramps'})
    MATCH (b {name: 'Medication Side Effect'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 34
MATCH (a {name: 'Early Pregnancy Loss/Miscarriage'})
    MATCH (b {name: 'Ultrasound'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 35
MATCH (a {name: 'Ectopic Pregnancy'})
    MATCH (b {name: 'Ultrasound'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 36
MATCH (a {name: 'Threatened Abortion/Imminent Miscarriage'})
    MATCH (b {name: 'Ultrasound'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 37
MATCH (a {name: 'Placental Abruption'})
    MATCH (b {name: 'Ultrasound'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 38
MATCH (a {name: 'Infection'})
    MATCH (b {name: 'Speculum Exam'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 39
MATCH (a {name: 'Early Pregnancy Loss/Miscarriage'})
    MATCH (b {name: 'Complete Blood Count (CBC)'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 40
MATCH (a {name: 'Ectopic Pregnancy'})
    MATCH (b {name: 'Serum Beta-hCG (Human Chorionic Gonadotropin)'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 41
MATCH (a {name: 'Early Pregnancy Loss/Miscarriage'})
    MATCH (b {name: 'Expectant Management'})
    MERGE (a)-[:TREATED_BY]->(b);

// Query 42
MATCH (a {name: 'Ectopic Pregnancy'})
    MATCH (b {name: 'Medical Management'})
    MERGE (a)-[:TREATED_BY]->(b);

// Query 43
MATCH (a {name: 'Placental Abruption'})
    MATCH (b {name: 'Surgical Intervention'})
    MERGE (a)-[:TREATED_BY]->(b);

