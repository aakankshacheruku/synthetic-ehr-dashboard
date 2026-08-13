# Synthetic EHR Dashboard — Breast Cancer Treatment Cost & Pathway Analysis

## The question we're answering:
How does treatment cost and pathway progress for breast cancer patients; from diagnosis through medication, surgery, radiation, or chemotherapy. If the data supports it, how does this path differ between the first diagnosis and a recurrence?

## Why this project:
Watching someone close to me go through breast cancer for a second time, after five years in remission, was shocking to say the least. It left me with so many questions: How is it going to go this time? Will she have to go through the same rounds of tests and medications again before we know whether it's surgery, chemotherapy, or radiation? How long do those tests even take? How do doctors know which medications are working and which aren't? What if things change quickly; what does the timeline from diagnosis to treatment actually look like?.\
I built this end-to-end project to explore a real oncology cost-of-care question, using synthetic data that mirror the kind of information healthcare systems and analysts work with everyday.\
Using Synthea, I generated thousands of realistic (but fully synthetic) patient records to dig into treatment pathways and costs -- not to answer her specific treatment, but the data that led to the diagnosis.

## How I approached learning this:
I didn't want to follow a tutorial and end up with something I couldn't explain. So I treated this project like a Lego set -- read the instruction manual before touching the bricks.\
For every skill this project required, I studied the basics in small, focused lessons first, then immediately applied that lesson as homework: _a real piece of this project._
No lesson without a build, no build without a lesson. That meant relearning things I used AI to lean on for. Now, I'm writing my own SQL queries again, understanding why a JOIN works, and etc.\
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
* August 13th
1. Phase 1 -- Get the data, install Synthea, generate patients, confirm breast cancer + recurrence is present.
