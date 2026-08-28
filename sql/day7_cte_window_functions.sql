-- Day 7: CTEs and window functions
-- goal was to clean up the Day 6 nested subqueries and look at cost over time.
-- ended up finding an error in my Day 6 explanation.

-- same cost-by-pathway query from Day 6, rewritten with CTEs.
-- identical output, but you can read it top to bottom now instead of
-- unpacking three layers of nesting.
WITH pathways AS (
    SELECT
        p.patient,
        CASE
            WHEN COUNT(m.description) = 0 THEN 'Surveillance only'
            WHEN COUNT(m.description) <= 3 THEN 'Hormone/targeted, no chemo'
            ELSE 'Chemo + targeted/hormone'
        END AS pathway
    FROM (SELECT DISTINCT patient FROM conditions WHERE code = '254837009') p
    LEFT JOIN medications m ON p.patient = m.patient AND m.reasoncode = '254837009'
    GROUP BY p.patient
),
diagnosis_costs AS (
    SELECT patient, SUM(cost) AS diagnosis_cost
    FROM (
        SELECT patient, totalcost AS cost
        FROM medications
        WHERE reasoncode = '254837009'
        UNION ALL
        SELECT patient, base_cost AS cost
        FROM procedures
        WHERE reasoncode = '254837009'
    ) combined
    GROUP BY patient
)
SELECT
    pathways.pathway,
    COUNT(*) AS patient_count,
    ROUND(AVG(diagnosis_costs.diagnosis_cost), 2) AS avg_diagnosis_cost
FROM pathways
JOIN diagnosis_costs ON pathways.patient = diagnosis_costs.patient
GROUP BY pathways.pathway
ORDER BY avg_diagnosis_cost;
-- verified: same numbers as Day 6. $40,187.32 / $43,310.55 / $57,235.52

-- window function: running total of cost per patient, in date order.
-- SUM() OVER (PARTITION BY ... ORDER BY ...) accumulates without collapsing
-- rows, so every treatment event keeps its own row and carries the running
-- total up to that point. GROUP BY couldn't do this.
WITH cohort_events AS (
    SELECT patient, start, totalcost AS cost
    FROM medications
    WHERE reasoncode = '254837009'
    UNION ALL
    SELECT patient, start, base_cost AS cost
    FROM procedures
    WHERE reasoncode = '254837009'
)
SELECT
    patient,
    start,
    cost,
    SUM(cost) OVER (PARTITION BY patient ORDER BY start) AS running_cost
FROM cohort_events
ORDER BY patient, start;
-- looked at one chemo patient (398966d0) against one hormone patient
-- (cb6993fe). the chemo patient's Cyclophosphamide infusions were $231.35
-- each, but there were two $8,710.82 procedure charges in the same window.
-- the hormone patient had a single $25,237.67 charge then ~6 weeks of
-- repeating $427/$1,274 charges. drugs were nowhere near the main cost
-- for either one. that contradicted my Day 6 explanation, so I checked it.

-- splitting cost by source to test it properly
WITH pathways AS (
    SELECT
        p.patient,
        CASE
            WHEN COUNT(m.description) = 0 THEN 'Surveillance only'
            WHEN COUNT(m.description) <= 3 THEN 'Hormone/targeted, no chemo'
            ELSE 'Chemo + targeted/hormone'
        END AS pathway
    FROM (SELECT DISTINCT patient FROM conditions WHERE code = '254837009') p
    LEFT JOIN medications m ON p.patient = m.patient AND m.reasoncode = '254837009'
    GROUP BY p.patient
),
cost_by_source AS (
    SELECT patient, 'medication' AS source, SUM(totalcost) AS cost
    FROM medications WHERE reasoncode = '254837009' GROUP BY patient
    UNION ALL
    SELECT patient, 'procedure' AS source, SUM(base_cost) AS cost
    FROM procedures WHERE reasoncode = '254837009' GROUP BY patient
)
SELECT
    pathways.pathway,
    cost_by_source.source,
    ROUND(AVG(cost_by_source.cost), 2) AS avg_cost
FROM pathways
JOIN cost_by_source ON pathways.patient = cost_by_source.patient
GROUP BY pathways.pathway, cost_by_source.source
ORDER BY pathways.pathway, cost_by_source.source;
-- chemo:   meds $1,238.27  procedures $42,072.29  (meds = 2.9%)
-- hormone: meds   $762.30  procedures $56,473.23  (meds = 1.3%)
-- so medications are 1-3% of cost across every pathway, AND the hormone
-- group spends LESS on drugs than the chemo group while costing ~$14K more
-- overall. my Day 6 explanation (expensive targeted biologics) was wrong.

-- which procedures actually drive it
WITH pathways AS (
    SELECT
        p.patient,
        CASE
            WHEN COUNT(m.description) = 0 THEN 'Surveillance only'
            WHEN COUNT(m.description) <= 3 THEN 'Hormone/targeted, no chemo'
            ELSE 'Chemo + targeted/hormone'
        END AS pathway
    FROM (SELECT DISTINCT patient FROM conditions WHERE code = '254837009') p
    LEFT JOIN medications m ON p.patient = m.patient AND m.reasoncode = '254837009'
    GROUP BY p.patient
)
SELECT
    pathways.pathway,
    pr.description,
    COUNT(*) AS event_count,
    ROUND(SUM(pr.base_cost), 2) AS total_cost
FROM pathways
JOIN procedures pr ON pathways.patient = pr.patient AND pr.reasoncode = '254837009'
WHERE pathways.pathway <> 'Surveillance only'
GROUP BY pathways.pathway, pr.description
ORDER BY pathways.pathway, total_cost DESC;
-- radiation. the hormone group has 102 external beam radiation events
-- ($88,841.64) plus 68 radiation therapy care events ($29,335.20).
-- the chemo group has zero radiation events. not fewer, none.
-- also 4 lumpectomies in the hormone group vs 2 in the chemo group.
--
-- corrected finding: the two groups aren't "more vs less intensive
-- treatment." they're different strategies. one is built around systemic
-- chemo, the other around surgery + a radiation course with hormone
-- therapy as maintenance. the radiation course costs more than the chemo
-- it replaces. the medication regimen I used to LABEL the pathways was
-- never what was DRIVING the cost.
--
-- caveat: n=5 per group. the radiation vs no-radiation contrast is the
-- solid part. the lumpectomy frequency difference (4 vs 2) is doing real
-- work in that gap too and is much shakier at this sample size.
