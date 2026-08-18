# Synthetic EHR Dashboard — Breast Cancer Treatment Cost & Pathway Analysis

## The question we're answering:
How does treatment cost and pathway progress for breast cancer patients; from diagnosis through medication, surgery, radiation, or chemotherapy.

_I originally wanted to compare a first diagnosis against a recurrence, but confirmed directly in the data that Synthea's breast cancer module models each patient's diagnosis as a single event. Rather than forcing a comparison the data couldn't support, I noted this a limitation of synthetic data -- something that can model a condition's typical pathway, but not the complex journey of living with the disease twice._


## How I approached learning this:
I didn't want to follow a tutorial and end up with something I couldn't explain. So I treated this project like a Lego set -- read the instruction manual before touching the bricks.

For every skill this project required, I studied the basics in small, focused lessons first, then immediately applied that lesson as homework: _a real piece of this project._
No lesson without a build, no build without a lesson. That meant relearning things I used AI to lean on for. Now, I'm writing my own SQL queries again, understanding why a JOIN works, and etc.

After building projects with the help of AI, I've realized I can't explain some of my projects in too much detail as I only check basic accuracy of my code I've written before sending it in to get fixed and pushed. This time, I can walk through every decision in my project and explain why I made it, not just what it looks like.

## The Tech Stack:
Synthea - Generates realistic synthetic patient data on breast cancer patients (safe, no privacy issues)\
SQL - Queries the raw data to answer specific questions\
Tableau Public - Turns SQL answers into a visual, interactive dashboard\
GitHub - Hosting the project publicly. With code, notes, and progress history\

## End Deliverables
1. Public GitHub repo showcases the process (queries, notes, decisions)
2. Published Dashboard, link-shareable
3. Short written narrative tying it back to why I built this

## The Phases:
1. Phase 1: Completed August 13, 2026 -- Installed Synthea, generated 2319 synthetic patients, and confirmed 38 patients with a breast cancer diagnosis. Check for recurrence (same patient, two diagnosis dates); confirmed none exist in this dataset. 
2. Phase 2: Completed August 14, 2026 -- Set up PostgreSQL, loaded patients and conditions data, and wrote SQL queries (SELECT, FROM, WHERE) to explore the dataset. Identified the breast cancer cohort by SNOMED code (254837009), verified 38 matching patients two independent ways (grep and SQL), confirming Phase 1's recurrence finding diagnosis records never close, supporting the single-event pattern.
3. Phase 3: Completed August 17, 2026 -- Learned SQL JOINs to connect patients and conditions tables. Calculated age at diagnosis for the full cohort; flagged 4 of 38 patients with clinically implausible ages (1, 3, 9, 13) as a known Synthea data-generation limitation, keeping the full cohort intact rather than excluding them.
4. Phase 4: Completed August 17, 2026 -- Used GROUP BY and aggregate functions to analyze cost patterns. Found healthcare cost climbs with age at diagnosis (~$118K avg in the youngest bracket to ~$902K in the oldest). Flagged a gender-proportion skew in the cohort (10.5% male vs. real-world ~1%) as a data limitation. Headline finding: the breast cancer cohort averages $357,695.10 in healthcare expenses vs. $187,777.01 for the general population -- roughly 1.9x higher.
5. Phase 5: Completed August 17, 2026 -- Joined patients, conditions, medications, and procedures to build treatment pathways for the breast cancer cohort. Found 28 of 38 patients (73.7%) have no breast-cancer-related medications, but do have 20-40 monitoring procedures each (physicals, mammography, screening) -- a real surveillance-only pathway, not missing data. Remaining 10 patients split into hormone-only, targeted/hormone combination, and chemo+targeted pathways, based on actual drug regimens (Cyclophosphamide, Epirubicin, Paclitaxel followed by Tamoxifen, trastuzumab, or other targeted agents).
