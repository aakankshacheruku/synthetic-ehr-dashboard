# Synthetic EHR Dashboard — Breast Cancer Treatment Cost & Pathway Analysis
### **Live Dashboard** [View on Tableau Public](https://public.tableau.com/views/ehr_dashboard/TCPADashboard?:language=en-US&:display_count=n&:origin=viz_share_link)

## The question we're answering:
How does treatment cost and pathway progress for breast cancer patients; from diagnosis through medication, surgery, radiation, or chemotherapy.

_I originally wanted to compare a first diagnosis against a recurrence, but confirmed directly in the data that Synthea's breast cancer module models each patient's diagnosis as a single event. Rather than forcing a comparison the data couldn't support, I noted this a limitation of synthetic data -- something that can model a condition's typical pathway, but not the complex journey of living with the disease twice._


## How I approached learning this:
I didn't want to follow a tutorial and end up with something I couldn't explain. So I treated this project like a Lego set -- read the instruction manual before touching the bricks.

For every skill this project required, I studied the basics in small, focused lessons first, then immediately applied that lesson as homework: _a real piece of this project._
No lesson without a build, no build without a lesson. That meant relearning things I used AI to lean on for. Now, I'm writing my own SQL queries again, understanding why a JOIN works, and etc.

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
6. Phase 6: Completed August 17, 2026 -- Built cost-by-pathway analysis using CASE WHEN to automate the pathway labels from Phase 5. First attempt used total patient healthcare cost and looked backwards (hormone-only pathway most expensive); rebuilt using cost scoped specifically to the breast cancer diagnosis (medications + procedures tied via REASONCODE) for a cleaner comparison. Finding held up: hormone/targeted therapy without chemo costs more on average ($57,236) than full chemo regimens ($43,311) or surveillance-only monitoring ($40,187) -- explained by the high per-dose cost of modern targeted biologic drugs compared to standard chemo.
7. Phase 7: Completed August 18, 2026 -- Installed Tableau Public and built four dashboard sheets from exported SQL query results: cohort vs. general population cost, cost by age bracket, cost by treatment pathway, and cohort demographics. Settled on a clinical navy/brown/red/butter-yellow color palette, with red reserved specifically for flagging the project's most counterintuitive finding (hormone/targeted therapy costing more than full chemo regimens). Each sheet built around the same structure: question, hypothesis, layout, execution.
8. Phase 8: Completed August 19, 2026 -- Assembled the four Tableau sheets into a single dashboard, added a title and narrative text framing the research question and headline findings, removed redundant legends, and published to Tableau Public. Live dashboard: https://public.tableau.com/views/ehr_dashboard/TCPADashboard


## Closing Narrative

This project set out to answer a real question in oncology cost-of-care: does a breast cancer diagnosis meaningfully change a patient's healthcare cost, and does the intensity of treatment predict how much that cost will be? These are the kinds of questions health systems, insurers, and analysts ask constantly when planning resources, negotiating with payers, or identifying which patient populations carry disproportionate financial burden. Understanding not just that cost differs, but why it differs and where the assumptions break down, is directly applicable to the kind of work a health-tech data analyst is asked to do: turn raw clinical and financial records into findings someone can act on, and be able to defend those findings when a stakeholder asks how the number was actually calculated.

Using synthetic patient data generated by Synthea, structured through PostgreSQL, and analyzed step by step in SQL, the project confirmed the first question directly: this cohort's average healthcare cost runs nearly double that of the general population. The second question produced a less expected answer. Rather than chemotherapy driving the highest cost, patients on targeted hormone therapy without chemotherapy showed the highest average cost per diagnosis, a result traced back to the high per-dose price of modern targeted biologic drugs rather than to treatment intensity itself.

Several points in this project required stepping back and rethinking the approach entirely, rather than pushing forward with the first result. A planned recurrence comparison had to be dropped once the data showed each diagnosis was modeled as a single event, not a repeating one. A cost-by-pathway comparison initially pointed to one conclusion, then reversed once the cost measure was scoped specifically to the diagnosis instead of a patient's total healthcare history. A gender split that looked broken at first glance turned out to be a real, if unusual, pattern once each patient's record was checked individually. In each case, the fix wasn't a workaround. It came from going back into the raw data, verifying what was actually there two independent ways, and letting that evidence decide the next step rather than forcing the data to match an initial assumption. That habit, checking before concluding, is the throughline of the entire project, and the skill meant to carry forward past it.
