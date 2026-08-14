# Synthetic EHR Dashboard — Breast Cancer Treatment Cost & Pathway Analysis

## The question we're answering:
How does treatment cost and pathway progress for breast cancer patients; from diagnosis through medication, surgery, radiation, or chemotherapy.

_I originally wanted to compare a first diagnosis against a recurrence, but confirmed directly in the data that Synthea's breast cancer module models each patient's diagnosis as a single event. Rather than forcing a comparison the data couldn't support, I noted this a limitation of synthetic data -- something that can model a condition's typical pathway, but not the complex journey of living with the disease twice._

## Why this project:
Watching someone close to me go through breast cancer for a second time, after five years in remission, was shocking to say the least. It left me with so many questions: How is it going to go this time? Will she have to go through the same rounds of tests and medications again before we know whether it's surgery, chemotherapy, or radiation? How long do those tests even take? How do doctors know which medications are working and which aren't? What if things change quickly; what does the timeline from diagnosis to treatment actually look like?

I built this end-to-end project to explore a real oncology cost-of-care question, using synthetic data that mirror the kind of information healthcare systems and analysts work with everyday.

Using Synthea, I generated thousands of realistic (but fully synthetic) patient records to dig into treatment pathways and costs -- not to answer her specific treatment, but the data that led to the diagnosis.

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
