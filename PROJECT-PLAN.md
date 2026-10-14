# Team 11: Class Survey Checklist

> 🤖 **AI-assisted program manager. This file contains no analysis code.** It only tracks what's done and what's
> left. Claim a task by putting your name next to it, and tick it off when it's done.

**Due date:** `__________` (fill in from Canvas)

---

## The one question

> **Is coursework preparation associated with how comfortable students feel in programming, math, and statistics?**

**What we've found so far:** basically no association. Every check we've run points the same way:

| Check | Who | Result |
|---|---|---|
| Spearman correlation, coursework level / # electives vs. each comfort score (n=51) | quick check | ρ between −0.16 and +0.05, every permutation p > 0.25 |
| Logistic regression, courses + interests → "comfortable (≥4)" | Sid | 5-fold CV balanced accuracy 0.40–0.59, which is chance (0.50) |
| Clustering (PCA / t-SNE / k-means vs. permuted null) | Clark | not run yet; expected result is no groups beyond noise |

**What the answer means.** A null result is still a finding:
1. **Coursework barely varies.** The core sequence (PSTAT 120/122/126/131, CS 9) is close to universal, and 49 of 51 took 6+ upper-div courses. There isn't much spread left to explain differences in comfort.
2. **Comfort is still a meaningful measure.** Self-rated comfort lines up with self-rated proficiency (e.g. almost every "adv" stats rater gives comfort 4–5). So the null result isn't just a noisy outcome variable. Coursework simply doesn't explain it.
3. **So comfort probably comes from things the survey didn't measure** (projects, internships, personality). Stated as a limitation and a "what we'd ask next time", not as a claim.

**The report's questions (these map one-to-one to the Findings subsections):**
1. How much does coursework actually vary across the class?
2. Is the amount of coursework associated with self-rated comfort?
3. Can coursework and interests together predict comfort, or sort students into distinct groups?

---

## Tasks (one owner each, everyone gets real commits)

Suggested owners are based on who's already done related work. Swap freely.

**A. Coursework variation figure (Findings 1)** — suggested: Hannah
- [ ] R script `scripts/fig-coursework.R`: bar chart of % of class who took each course, core courses highlighted
- [ ] Small table: `upper_div_courses` counts (3-5: 2, 6-8: 19, 9+: 30)
- [ ] 3–4 sentences: "the core is universal, so only electives can distinguish students"

**B. Coursework vs. comfort figure + table (Findings 2, the main result)** — suggested: Ryan
- [ ] R script `scripts/fig-comfort.R`: comfort (2–5) by number of electives, one panel each for prog/math/stat (jittered dots or boxplots)
- [ ] Table: Spearman ρ and p for the 6 pairs (use `cor.test(..., method = "spearman")`)
- [ ] One supporting line: proficiency vs. comfort crosstab, showing the comfort measure is coherent
- [ ] 3–5 sentences, "is associated with" language only

**C. Prediction model (Findings 3a)** — Sid
- [ ] Fix the hard-coded `/Users/sidre/...` paths in `scratchwork-sid.ipynb`
- [ ] Pick **one** of the two feature sets and report it: table of CV balanced accuracy per outcome next to the 0.50 chance line
- [ ] Note the class imbalance (stat.comf is 40 vs 9, so plain accuracy is misleading; that's why balanced accuracy)
- [ ] 2–3 sentences

**D. Clustering (Findings 3b)** — Clark
- [ ] `pip install scikit-learn`, run `scratchwork-clark-clustering.ipynb` top to bottom, commit with outputs
- [ ] Take **one** figure (silhouette real vs. permuted null, Section 6) and adapt the "how to report" paragraph from Section 8
- [ ] If something *does* beat the null, flag it to the group before writing it up

**E. Report assembly (`results/report.qmd`)** — suggested: Joyce + Sid
- [ ] Move Sid's draft text out of `results/report_files/report.ipynb` into `results/report.qmd`. `report_files/` is render output, and **only the rendered `report.qmd` → `report.html` counts as the submission**
- [ ] Delete template text, add all 5 names, keep the 4 headers
- [ ] Replace the Questions section with the 3 questions above
- [ ] Paste in each owner's chunk/figure as it lands
- [ ] Executive summary last (draft below)

**Finish (everyone)**
- [ ] Everyone reads the whole report once
- [ ] Render, then push `report.qmd` and `report.html` to `main`
- [ ] Everyone confirms it shows on GitHub and that their own commits are in the history
- [ ] Add `.DS_Store` to `.gitignore`

---

## Draft executive summary (edit once results are final)

> We asked whether students' coursework preparation is associated with their self-rated comfort in programming,
> math, and statistics. Among the 51 respondents to the background survey, coursework was highly uniform: nearly
> everyone had completed the same core sequence. Neither the number of upper-division courses nor the number of
> electives was associated with comfort in any of the three areas. A logistic regression using courses and interests
> predicted comfort no better than chance, and clustering found no distinct subgroups of students beyond what
> appears in randomly shuffled data. Self-rated comfort did agree with self-rated proficiency, which suggests that
> students' confidence reflects experience the survey did not capture rather than coursework.

---

## Things to keep in mind

- Say "is associated with", never "causes" or "affects". The data are self-reported and collected at a single point in time.
- Always state the n: 55 took the survey, 51 answered the background section, 49 answered both sections.
- Skip near-universal courses (PSTAT 120/122/126/131, CS 9) as predictors. Almost everyone took them, so they can't tell students apart.
- Don't split the `areas` column on commas. Two of its labels contain commas ("Predictive modeling, generally").
- `prog.comf` has only one person at 2, and there are no math/stats beginners. Collapse 2–3 into one "low" group.
- Keep it short: about 3 figures, 2 tables, and a few sentences each.
