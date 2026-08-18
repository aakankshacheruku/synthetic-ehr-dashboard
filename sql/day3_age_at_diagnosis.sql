-- Day 3: JOIN patients + conditions to calculate age at diagnosis for the 38-patient breast cancer cohort

SELECT patients.first, patients.last, patients.birthdate, conditions.start AS diagnosis_date,
       EXTRACT(YEAR FROM AGE(conditions.start, patients.birthdate)) AS age_at_diagnosis
FROM patients
JOIN conditions ON patients.id = conditions.patient
WHERE conditions.code = '254837009'
ORDER BY age_at_diagnosis;

Data limitation: 4 of 38 patients (~10.5%) show implausible ages at diagnosis (1, 3, 9, 13 years old) -- a known artifact of Synthea's synthetic population generation, not a query error. Patients remain in the full cohort; flagged here for downstream analysis.

