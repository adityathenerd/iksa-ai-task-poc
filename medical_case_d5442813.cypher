// Medical Knowledge Graph - Auto-generated Cypher Queries
// Generated at: 2025-08-07 16:34:25.246376

// Query 1

MERGE (case:Case {
    id: 'd5442813-ab4e-4583-8b08-e3f41f2fce59',
    chief_complaint: 'Vaginal bleeding and intermittent moderate cramps',
    created_at: '2025-08-07T16:34:25.236237',
    clinical_reasoning: 'The patient\'s symptoms of vaginal bleeding and intermittent moderate cramps, along with her history of hypertension, suggest several potential diagnoses, including threatened abortion, ectopic pregnancy, and others. The recommended tests and treatments are aimed at confirming these diagnoses and managing the patient\'s symptoms.'
});

// Query 2
MERGE (:Symptom {name: 'Vaginal bleeding', onset: '2 days ago', severity: 'lower than usual periods', aggravating_factors: 'Physical activity'});

// Query 3
MERGE (:Symptom {name: 'Intermittent moderate cramps', onset: '2 days ago', severity: 'moderate', aggravating_factors: 'Physical activity'});

// Query 4
MERGE (:Symptom {name: 'Nausea', severity: 'worse with pickles and cheese'});

// Query 5
MERGE (:Condition {name: 'Hypertension'});

// Query 6
MERGE (:Condition {name: 'Threatened Abortion'});

// Query 7
MERGE (:Condition {name: 'Ectopic Pregnancy'});

// Query 8
MERGE (:Condition {name: 'Infection'});

// Query 9
MERGE (:Condition {name: 'Cervical Contraction/Incomplete Abortion'});

// Query 10
MERGE (:Condition {name: 'Placenta Previa'});

// Query 11
MERGE (:Condition {name: 'Hyperemesis Gravidarum'});

// Query 12
MERGE (:Condition {name: 'Hydatidiform Mole'});

// Query 13
MERGE (:Test {name: 'Pelvic Exam', urgency: 'immediate'});

// Query 14
MERGE (:Test {name: 'Vital Signs', urgency: 'immediate'});

// Query 15
MERGE (:Test {name: 'Urine Pregnancy Test', urgency: 'immediate'});

// Query 16
MERGE (:Test {name: 'Serial Beta-hCG Blood Tests', urgency: 'immediate'});

// Query 17
MERGE (:Test {name: 'Transvaginal Ultrasound', urgency: 'immediate'});

// Query 18
MERGE (:Test {name: 'Complete Blood Count', urgency: 'further investigation'});

// Query 19
MERGE (:Test {name: 'STI Testing', urgency: 'further investigation'});

// Query 20
MERGE (:Test {name: 'Gonorrhea/Chlamydia Testing', urgency: 'further investigation'});

// Query 21
MERGE (:Treatment {name: 'Hospitalization', urgency: 'dependent on severity'});

// Query 22
MERGE (:Medication {name: 'Beta-blockers', indication: 'hypertension'});

// Query 23
MERGE (:Treatment {name: 'Pain management', indication: 'cramping'});

// Query 24
MERGE (:Medication {name: 'Antiemetics', indication: 'nausea and vomiting'});

// Query 25
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Threatened Abortion'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 26
MATCH (a {name: 'Intermittent moderate cramps'})
    MATCH (b {name: 'Threatened Abortion'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 27
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Ectopic Pregnancy'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 28
MATCH (a {name: 'Intermittent moderate cramps'})
    MATCH (b {name: 'Ectopic Pregnancy'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 29
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Infection'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 30
MATCH (a {name: 'Intermittent moderate cramps'})
    MATCH (b {name: 'Infection'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 31
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Cervical Contraction/Incomplete Abortion'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 32
MATCH (a {name: 'Intermittent moderate cramps'})
    MATCH (b {name: 'Cervical Contraction/Incomplete Abortion'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 33
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Placenta Previa'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 34
MATCH (a {name: 'Intermittent moderate cramps'})
    MATCH (b {name: 'Placenta Previa'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 35
MATCH (a {name: 'Nausea'})
    MATCH (b {name: 'Hyperemesis Gravidarum'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 36
MATCH (a {name: 'Vaginal bleeding'})
    MATCH (b {name: 'Hydatidiform Mole'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 37
MATCH (a {name: 'Intermittent moderate cramps'})
    MATCH (b {name: 'Hydatidiform Mole'})
    MERGE (a)-[:SUGGESTS]->(b);

// Query 38
MATCH (a {name: 'Threatened Abortion'})
    MATCH (b {name: 'Pelvic Exam'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 39
MATCH (a {name: 'Ectopic Pregnancy'})
    MATCH (b {name: 'Pelvic Exam'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 40
MATCH (a {name: 'Infection'})
    MATCH (b {name: 'Pelvic Exam'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 41
MATCH (a {name: 'Cervical Contraction/Incomplete Abortion'})
    MATCH (b {name: 'Pelvic Exam'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 42
MATCH (a {name: 'Placenta Previa'})
    MATCH (b {name: 'Pelvic Exam'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 43
MATCH (a {name: 'Hyperemesis Gravidarum'})
    MATCH (b {name: 'Pelvic Exam'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 44
MATCH (a {name: 'Hydatidiform Mole'})
    MATCH (b {name: 'Pelvic Exam'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 45
MATCH (a {name: 'Threatened Abortion'})
    MATCH (b {name: 'Vital Signs'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 46
MATCH (a {name: 'Ectopic Pregnancy'})
    MATCH (b {name: 'Vital Signs'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 47
MATCH (a {name: 'Infection'})
    MATCH (b {name: 'Vital Signs'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 48
MATCH (a {name: 'Cervical Contraction/Incomplete Abortion'})
    MATCH (b {name: 'Vital Signs'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 49
MATCH (a {name: 'Placenta Previa'})
    MATCH (b {name: 'Vital Signs'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 50
MATCH (a {name: 'Hyperemesis Gravidarum'})
    MATCH (b {name: 'Vital Signs'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 51
MATCH (a {name: 'Hydatidiform Mole'})
    MATCH (b {name: 'Vital Signs'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 52
MATCH (a {name: 'Threatened Abortion'})
    MATCH (b {name: 'Urine Pregnancy Test'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 53
MATCH (a {name: 'Ectopic Pregnancy'})
    MATCH (b {name: 'Urine Pregnancy Test'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 54
MATCH (a {name: 'Infection'})
    MATCH (b {name: 'Urine Pregnancy Test'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 55
MATCH (a {name: 'Cervical Contraction/Incomplete Abortion'})
    MATCH (b {name: 'Urine Pregnancy Test'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 56
MATCH (a {name: 'Placenta Previa'})
    MATCH (b {name: 'Urine Pregnancy Test'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 57
MATCH (a {name: 'Hyperemesis Gravidarum'})
    MATCH (b {name: 'Urine Pregnancy Test'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 58
MATCH (a {name: 'Hydatidiform Mole'})
    MATCH (b {name: 'Urine Pregnancy Test'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 59
MATCH (a {name: 'Threatened Abortion'})
    MATCH (b {name: 'Serial Beta-hCG Blood Tests'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 60
MATCH (a {name: 'Ectopic Pregnancy'})
    MATCH (b {name: 'Serial Beta-hCG Blood Tests'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 61
MATCH (a {name: 'Infection'})
    MATCH (b {name: 'Serial Beta-hCG Blood Tests'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 62
MATCH (a {name: 'Cervical Contraction/Incomplete Abortion'})
    MATCH (b {name: 'Serial Beta-hCG Blood Tests'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 63
MATCH (a {name: 'Placenta Previa'})
    MATCH (b {name: 'Serial Beta-hCG Blood Tests'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 64
MATCH (a {name: 'Hyperemesis Gravidarum'})
    MATCH (b {name: 'Serial Beta-hCG Blood Tests'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 65
MATCH (a {name: 'Hydatidiform Mole'})
    MATCH (b {name: 'Serial Beta-hCG Blood Tests'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 66
MATCH (a {name: 'Threatened Abortion'})
    MATCH (b {name: 'Transvaginal Ultrasound'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 67
MATCH (a {name: 'Ectopic Pregnancy'})
    MATCH (b {name: 'Transvaginal Ultrasound'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 68
MATCH (a {name: 'Infection'})
    MATCH (b {name: 'Transvaginal Ultrasound'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 69
MATCH (a {name: 'Cervical Contraction/Incomplete Abortion'})
    MATCH (b {name: 'Transvaginal Ultrasound'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 70
MATCH (a {name: 'Placenta Previa'})
    MATCH (b {name: 'Transvaginal Ultrasound'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 71
MATCH (a {name: 'Hyperemesis Gravidarum'})
    MATCH (b {name: 'Transvaginal Ultrasound'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 72
MATCH (a {name: 'Hydatidiform Mole'})
    MATCH (b {name: 'Transvaginal Ultrasound'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 73
MATCH (a {name: 'Threatened Abortion'})
    MATCH (b {name: 'Complete Blood Count'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 74
MATCH (a {name: 'Ectopic Pregnancy'})
    MATCH (b {name: 'Complete Blood Count'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 75
MATCH (a {name: 'Infection'})
    MATCH (b {name: 'Complete Blood Count'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 76
MATCH (a {name: 'Cervical Contraction/Incomplete Abortion'})
    MATCH (b {name: 'Complete Blood Count'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 77
MATCH (a {name: 'Placenta Previa'})
    MATCH (b {name: 'Complete Blood Count'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 78
MATCH (a {name: 'Hyperemesis Gravidarum'})
    MATCH (b {name: 'Complete Blood Count'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 79
MATCH (a {name: 'Hydatidiform Mole'})
    MATCH (b {name: 'Complete Blood Count'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 80
MATCH (a {name: 'Threatened Abortion'})
    MATCH (b {name: 'STI Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 81
MATCH (a {name: 'Ectopic Pregnancy'})
    MATCH (b {name: 'STI Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 82
MATCH (a {name: 'Infection'})
    MATCH (b {name: 'STI Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 83
MATCH (a {name: 'Cervical Contraction/Incomplete Abortion'})
    MATCH (b {name: 'STI Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 84
MATCH (a {name: 'Placenta Previa'})
    MATCH (b {name: 'STI Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 85
MATCH (a {name: 'Hyperemesis Gravidarum'})
    MATCH (b {name: 'STI Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 86
MATCH (a {name: 'Hydatidiform Mole'})
    MATCH (b {name: 'STI Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 87
MATCH (a {name: 'Threatened Abortion'})
    MATCH (b {name: 'Gonorrhea/Chlamydia Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 88
MATCH (a {name: 'Ectopic Pregnancy'})
    MATCH (b {name: 'Gonorrhea/Chlamydia Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 89
MATCH (a {name: 'Infection'})
    MATCH (b {name: 'Gonorrhea/Chlamydia Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 90
MATCH (a {name: 'Cervical Contraction/Incomplete Abortion'})
    MATCH (b {name: 'Gonorrhea/Chlamydia Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 91
MATCH (a {name: 'Placenta Previa'})
    MATCH (b {name: 'Gonorrhea/Chlamydia Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 92
MATCH (a {name: 'Hyperemesis Gravidarum'})
    MATCH (b {name: 'Gonorrhea/Chlamydia Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 93
MATCH (a {name: 'Hydatidiform Mole'})
    MATCH (b {name: 'Gonorrhea/Chlamydia Testing'})
    MERGE (a)-[:INDICATES_NEED_FOR]->(b);

// Query 94
MATCH (a {name: 'Threatened Abortion'})
    MATCH (b {name: 'Hospitalization'})
    MERGE (a)-[:MAY_REQUIRE]->(b);

// Query 95
MATCH (a {name: 'Ectopic Pregnancy'})
    MATCH (b {name: 'Hospitalization'})
    MERGE (a)-[:MAY_REQUIRE]->(b);

// Query 96
MATCH (a {name: 'Infection'})
    MATCH (b {name: 'Hospitalization'})
    MERGE (a)-[:MAY_REQUIRE]->(b);

// Query 97
MATCH (a {name: 'Cervical Contraction/Incomplete Abortion'})
    MATCH (b {name: 'Hospitalization'})
    MERGE (a)-[:MAY_REQUIRE]->(b);

// Query 98
MATCH (a {name: 'Placenta Previa'})
    MATCH (b {name: 'Hospitalization'})
    MERGE (a)-[:MAY_REQUIRE]->(b);

// Query 99
MATCH (a {name: 'Hyperemesis Gravidarum'})
    MATCH (b {name: 'Hospitalization'})
    MERGE (a)-[:MAY_REQUIRE]->(b);

// Query 100
MATCH (a {name: 'Hydatidiform Mole'})
    MATCH (b {name: 'Hospitalization'})
    MERGE (a)-[:MAY_REQUIRE]->(b);

// Query 101
MATCH (a {name: 'Hypertension'})
    MATCH (b {name: 'Beta-blockers'})
    MERGE (a)-[:TREATED_BY]->(b);

// Query 102
MATCH (a {name: 'Intermittent moderate cramps'})
    MATCH (b {name: 'Pain management'})
    MERGE (a)-[:TREATED_BY]->(b);

// Query 103
MATCH (a {name: 'Nausea'})
    MATCH (b {name: 'Antiemetics'})
    MERGE (a)-[:TREATED_BY]->(b);

