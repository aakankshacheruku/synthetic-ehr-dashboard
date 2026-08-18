-- Day 4: GROUP BY and aggregate functions on the breast cancer cohort

-- baseline stats for the cohort
SELECT
    COUNT(*) AS cohort_size,
    ROUND(AVG(patients.healthcare_expenses), 2) AS avg_expenses,
    MIN(patients.healthcare_expenses) AS min_expenses,
    MAX(patients.healthcare_expenses) AS max_expenses,
    ROUND(SUM(patients.healthcare_expenses), 2) AS total_expenses
FROM patients
JOIN conditions ON patients.id = conditions.patient
WHERE conditions.code = '254837009';
-- 38 patients, avg $357,695.10, range $13,827.39 - $1,165,190.65

-- top 5 highest-cost patients -- checking if the max is one outlier or a real cluster
SELECT patients.first, patients.last, patients.healthcare_expenses
FROM patients
JOIN conditions ON patients.id = conditions.patient
WHERE conditions.code = '254837009'
ORDER BY patients.healthcare_expenses DESC
LIMIT 5;
-- it's a real cluster: 5 patients between ~$900K-$1.17M, not a single fluke

-- age bracket vs avg cost
-- first attempt: age / 10 * 10 -- this didn't work because EXTRACT/AGE returns
-- NUMERIC, not INT, so 47/10 = 4.7 and *10 just gives back 47. no truncation.
-- fixed with FLOOR() before multiplying back up, then cast to INT
SELECT
    (FLOOR(EXTRACT(YEAR FROM AGE(conditions.start, patients.birthdate)) / 10) * 10)::INT AS age_bracket,
    COUNT(*) AS patient_count,
    ROUND(AVG(patients.healthcare_expenses), 2) AS avg_expenses
FROM patients
JOIN conditions ON patients.id = conditions.patient
WHERE conditions.code = '254837009'
GROUP BY age_bracket
ORDER BY age_bracket;
-- cost climbs with age bracket, ~$118K (0s) up to ~$902K (80s)

-- gender check within the cohort
SELECT gender, COUNT(*) AS patient_count
FROM patients
WHERE id IN (SELECT patient FROM conditions WHERE code = '254837009')
GROUP BY gender;
-- 34 F / 4 M -- 10.5% male vs real-world ~1% male incidence
-- checked ages of the 4 male patients (60-68) -- epidemiologically plausible
-- individually, so this looks like a demographic skew in Synthea's module,
-- not made-up individual cases. keeping them in the cohort, noting the skew.

-- headline comparison: cohort vs general population
SELECT
    'Breast Cancer Cohort' AS group_label,
    COUNT(*) AS patient_count,
    ROUND(AVG(healthcare_expenses), 2) AS avg_expenses
FROM patients
WHERE id IN (SELECT patient FROM conditions WHERE code = '254837009')

UNION ALL

SELECT
    'General Population' AS group_label,
    COUNT(*) AS patient_count,
    ROUND(AVG(healthcare_expenses), 2) AS avg_expenses
FROM patients;
-- breast cancer cohort: $357,695.10 avg vs general population: $187,777.01 avg
-- ~1.9x higher cost -- headline finding for the project
