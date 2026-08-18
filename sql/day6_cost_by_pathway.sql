-- Day 6: cost by treatment pathway

-- built a CASE WHEN to turn Day 5's manual pathway groupings into an actual
-- SQL label instead of me eyeballing patient IDs every time
SELECT
    p.patient,
    COUNT(m.description) AS medication_count,
    CASE
        WHEN COUNT(m.description) = 0 THEN 'Surveillance only'
        WHEN COUNT(m.description) <= 3 THEN 'Hormone/targeted, no chemo'
        ELSE 'Chemo + targeted/hormone'
    END AS pathway
FROM (SELECT DISTINCT patient FROM conditions WHERE code = '254837009') p
LEFT JOIN medications m ON p.patient = m.patient AND m.reasoncode = '254837009'
GROUP BY p.patient
ORDER BY medication_count;
-- labels matched what I found by hand yesterday: 28 surveillance, 5 hormone-only, 5 chemo

-- first attempt at cost by pathway -- used patients.healthcare_expenses
SELECT
    pathway,
    COUNT(*) AS patient_count,
    ROUND(AVG(healthcare_expenses), 2) AS avg_expenses,
    MIN(healthcare_expenses) AS min_expenses,
    MAX(healthcare_expenses) AS max_expenses
FROM (
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
) pathways
JOIN patients ON patients.id = pathways.patient
GROUP BY pathway
ORDER BY avg_expenses;
-- result: surveillance $319K, chemo $389K, hormone-only $541K (!)
-- didn't trust this -- healthcare_expenses is a patient's ENTIRE lifetime
-- healthcare cost, not cost tied to breast cancer specifically. someone in
-- the hormone-only group could have a totally unrelated expensive condition
-- dragging their number up. also only 5 patients in two of the groups, so
-- one or two unrelated-cost patients can swing the average a lot.

-- second attempt: scoped cost to JUST the breast cancer diagnosis, using
-- medications.totalcost + procedures.base_cost, both filtered by reasoncode
SELECT
    pathways.pathway,
    COUNT(*) AS patient_count,
    ROUND(AVG(costs.diagnosis_cost), 2) AS avg_diagnosis_cost,
    MIN(costs.diagnosis_cost) AS min_diagnosis_cost,
    MAX(costs.diagnosis_cost) AS max_diagnosis_cost
FROM (
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
) pathways
JOIN (
    SELECT patient, SUM(cost) AS diagnosis_cost
    FROM (
        SELECT patient, totalcost AS cost
        FROM medications
        WHERE reasoncode = '254837009'
        UNION ALL
        SELECT patient, base_cost AS cost
        FROM procedures
        WHERE reasoncode = '254837009'
    ) combined_costs
    GROUP BY patient
) costs ON pathways.patient = costs.patient
GROUP BY pathways.pathway
ORDER BY avg_diagnosis_cost;
-- result: surveillance $40,187, chemo $43,311, hormone-only $57,236
-- ranges got way tighter (surveillance min/max went from $13K-$1.07M down
-- to $1.5K-$105K), which backs up the idea that the first version was
-- mostly picking up unrelated healthcare costs, not real signal

-- note on this query combining medications.totalcost and procedures.base_cost:
-- these aren't quite the same thing. totalcost is post-discount, base_cost
-- is pre-discount/list price. summing them together isn't perfectly
-- apples-to-apples, but it's the best I have without payer-level discount
-- data for procedures. flagging this as a real limitation, not hiding it.

-- real finding, still holds even with the cleaner numbers: hormone/targeted
-- therapy without chemo costs more on average than full chemo regimens.
-- kind of counterintuitive at first, but makes sense once you look at the
-- actual drugs -- trastuzumab, palbociclib, ribociclib are all newer,
-- expensive targeted biologics, priced way higher
