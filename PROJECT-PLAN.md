# Team 11: Class Survey Checklist

> 🤖 **AI-assisted program manager. This file contains no analysis code.** It only tracks what's done and what's
> left. Anyone can claim a task by putting their name next to it, and tick it off when it's done.

**Due date:** `__________` (fill in from Canvas)

---

## What we've done

- Brainstormed and ranked questions (`scripts/questions.txt`)
- Explored the data in Python notebooks: course counts, interest areas, a course × area heatmap
- Ran logistic regression (Sid): coursework predicts comfort at about chance level, which is a usable negative finding
- Wrote coursework vs. self-rating and clustering notebooks (Clark); these haven't been run yet

## What we still need

- The actual report. `results/report.qmd` is still the blank template, and **the rendered report pushed to `main` is the submission**
- Final tables and figures **in R**, because the report is R/Quarto
- Substantive commits from **everyone**, since grades use the commit history

---

## Checklist (roughly in order)

**Decide**
- [ ] Fill in the due date above
- [ ] Pick the final 2–3 questions (suggestions below) and rewrite `questions.txt` without causal words ("affect", "contribute")

**Clean up**
- [ ] Fix the hard-coded file paths in `scratchwork-sid.ipynb`
- [ ] Run Clark's notebooks and take the necessary pieces for final report.
- [ ] Add `.DS_Store` to `.gitignore`

**Analyze** (one R script per person in `scripts/`)
- [ ] Q1: coursework vs. self-rated skill/comfort
- [ ] Q2: preferred programming language
- [ ] Q3: interest areas vs. domains
- [ ] Each question ends up with one final table or figure

**Write** (`results/report.qmd`)
- [ ] Set up the skeleton: title, all 5 names, the 4 section headers, template text deleted
- [ ] Data description
- [ ] Questions of interest
- [ ] Findings for each question
- [ ] Executive summary (write this last)

**Finish**
- [ ] Everyone reads the whole report once
- [ ] Render, then push `report.qmd` and `report.html` to `main`
- [ ] Everyone confirms it shows up on GitHub and has their own commits in the history

---

## Things to keep in mind

- Say "is associated with", never "causes" or "affects". The data are self-reported and collected at a single point in time.
- Always state the n: 55 took the survey, 51 answered the background section, 49 answered both sections.
- Skip near-universal courses (PSTAT 120/122/126/131, CS 9). Almost everyone took them, so they can't tell students apart.
- Don't split the `areas` column on commas. Two of its labels contain commas ("Predictive modeling, generally").

---

## Sample finished report

```
Title: Analysis of Class Surveys
Authors: [all 5 names]

## Executive summary
One paragraph: what we looked at and the 2–3 most interesting results.

## Data description
- Class survey from PSTAT 197A, Fall 2026
- 55 respondents; 51 answered background questions, 49 answered both sections
- Mostly senior statistics majors
- Measures: self-rated proficiency/comfort (prog, math, stat), courses taken,
  research experience, preferred language, interest areas and domains

## Questions of interest
1. Is coursework associated with self-rated skill and comfort?
2. How does preferred programming language relate to coursework and interests?
3. Which areas of data science go together with which domains?

## Findings
### 1. Coursework and skill/comfort
  [table or figure] + 3–5 sentences explaining it
### 2. Language preference
  [table or figure] + 3–5 sentences
### 3. Areas and domains
  [table or figure] + 3–5 sentences
```

Keep it short. A few clear tables or figures, each with a caption, beat many plots.
