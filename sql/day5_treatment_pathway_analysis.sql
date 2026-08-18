-- Day 5: treatment pathway analysis for the 38-patient breast cancer cohort
-- loaded medications.csv and procedures.csv, both linked to conditions via REASONCODE

CREATE TABLE medications (
    START TIMESTAMPTZ, STOP TIMESTAMPTZ, PATIENT TEXT, PAYER TEXT, ENCOUNTER TEXT,
    CODE TEXT, DESCRIPTION TEXT, BASE_COST NUMERIC, PAYER_COVERAGE NUMERIC,
    DISPENSES INTEGER, TOTALCOST NUMERIC, REASONCODE TEXT, REASONDESCRIPTION TEXT
);

CREATE TABLE procedures (
    START TIMESTAMPTZ, STOP TIMESTAMPTZ, PATIENT TEXT, ENCOUNTER TEXT, SYSTEM TEXT,
    CODE TEXT, DESCRIPTION TEXT, BASE_COST NUMERIC, REASONCODE TEXT, REASONDESCRIPTION TEXT
);
-- loaded via \copy, same pattern as patients/conditions
-- medications: 127,737 rows total (all patients, all conditions)
-- procedures: 386,759 rows total

-- combined medication + procedure timeline for the cohort, tied to breast cancer via reasoncode
SELECT patient, start, 'medication' AS type, description, totalcost AS cost
FROM medications
WHERE reasoncode = '254837009'
UNION ALL
SELECT patient, start, 'procedure' AS type, description, base_cost AS cost
FROM procedures
WHERE reasoncode = '254837009'
ORDER BY patient, start;

-- medication count per patient -- this is where two real bugs showed up
SELECT p.patient, COUNT(m.description) AS medication_count
FROM (SELECT DISTINCT patient FROM conditions WHERE code = '254837009') p
LEFT JOIN medications m ON p.patient = m.patient AND m.reasoncode = '254837009'
GROUP BY p.patient
ORDER BY medication_count;
-- bug 1: used COUNT(*) at first instead of COUNT(m.description) -- COUNT(*)
-- counts the row even when the LEFT JOIN produces no match (all NULLs),
-- so a true zero-medication patient incorrectly showed as 1. switched to
-- COUNT(m.description), which only counts non-NULL values.
-- bug 2: pasted a 3-UUID IN(...) list to spot check a few patients and got
-- 0 rows back -- turned out to be a transcription error in the UUIDs, not
-- a real data issue. safer to check patients one at a time by exact match
-- when spot-checking, instead of retyping long UUIDs into a list.

-- result: 28 of 38 patients (73.7%) have ZERO cancer-related medications
-- checked their procedures separately -- all 28 have 20-40 procedures each
-- (annual physicals, mammography, bone density or pelvic/cytopathology).
-- this is a real surveillance-only pathway, not missing data -- confirmed
-- by checking procedures.csv for the same patients (nested subquery below)

SELECT p.patient, COUNT(pr.description) AS procedure_count
FROM (SELECT DISTINCT patient FROM conditions WHERE code = '254837009') p
LEFT JOIN procedures pr ON p.patient = pr.patient AND pr.reasoncode = '254837009'
WHERE p.patient IN (
    SELECT patient FROM (
        SELECT p2.patient, COUNT(m.description) AS med_count
        FROM (SELECT DISTINCT patient FROM conditions WHERE code = '254837009') p2
        LEFT JOIN medications m ON p2.patient = m.patient AND m.reasoncode = '254837009'
        GROUP BY p2.patient
    ) sub WHERE med_count = 0
)
GROUP BY p.patient
ORDER BY procedure_count;

-- pathway groups, based on medication pattern for the remaining 10 patients:
-- surveillance-only: 28 patients, no meds, procedure-based monitoring
-- hormone therapy only: 1 patient (Tamoxifen alone)
-- targeted/hormone combo, no chemo: 4 patients (Tamoxifen + one targeted agent,
--   e.g. trastuzumab, ribociclib, or palbociclib+fulvestrant, same-day)
-- chemo + targeted/hormone combo: 5 patients (multiple chemo rounds --
--   Cyclophosphamide, Epirubicin, or Paclitaxel -- then a targeted/hormone
--   combo). one of these (45918696) was diagnosed in 2026 and only shows
--   4 chemo rounds with no follow-up yet -- likely still mid-treatment,
--   flagged as incomplete rather than a confirmed chemo-only pathway
