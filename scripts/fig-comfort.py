"""
Task B (Findings 2): Is coursework associated with self-rated comfort?

Outputs (in results/):
  fig-comfort.png              comfort by number of electives, one panel per skill
  table-comfort-spearman.csv   Spearman rho and p for the 6 coursework x comfort pairs
  table-prof-comfort.csv       proficiency x comfort crosstab

Run: .venv/bin/python scripts/fig-comfort.py
"""

import re
from pathlib import Path

import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from scipy.stats import spearmanr

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "results"

SKILLS = {"prog": "Programming", "math": "Mathematics", "stat": "Statistics"}
CORE = {"PSTAT 120", "PSTAT 122", "PSTAT 126"}

bg = pd.read_csv(ROOT / "data" / "background-clean.csv")


def count_electives(courses):
    """Upper-division courses (number >= 100) selected, excluding the core."""
    labels = [c.strip() for c in courses.split(",")]
    return sum(int(re.search(r"\d+", c).group()) >= 100 and c not in CORE for c in labels)


bg["n_electives"] = bg["courses"].map(count_electives)
bg["coursework_level"] = bg["upper_div_courses"].map({"3-5": 1, "6-8": 2, "9+": 3})

# Spearman correlations: 2 coursework measures x 3 comfort scores
rows = []
for pred in ["coursework_level", "n_electives"]:
    for skill, label in SKILLS.items():
        res = spearmanr(bg[pred], bg[f"{skill}.comf"])
        rows.append({"coursework": pred, "comfort": label,
                     "rho": round(res.statistic, 3), "p_value": round(res.pvalue, 3)})
spearman = pd.DataFrame(rows)
spearman.to_csv(OUT / "table-comfort-spearman.csv", index=False)

# Proficiency vs comfort: shows the comfort measure is coherent
tabs = []
for skill, label in SKILLS.items():
    tab = pd.crosstab(bg[f"{skill}.prof"], bg[f"{skill}.comf"].astype(int))
    tab = tab.reindex(columns=[2, 3, 4, 5], fill_value=0)
    tab.insert(0, "skill", label)
    tabs.append(tab)
prof_comf = pd.concat(tabs)
prof_comf.to_csv(OUT / "table-prof-comfort.csv")

# Figure: comfort by number of electives
fig, axes = plt.subplots(1, 3, figsize=(12, 4), sharey=True)
for ax, (skill, label) in zip(axes, SKILLS.items()):
    sns.stripplot(data=bg, x="n_electives", y=f"{skill}.comf", jitter=0.25, ax=ax)
    r = spearman.query("coursework == 'n_electives' and comfort == @label").iloc[0]
    ax.set_title(f"{label} (rho = {r.rho:.2f}, p = {r.p_value:.2f})")
    ax.set_xlabel("Number of electives")
    ax.set_ylabel("Comfort (2-5)")
fig.suptitle(f"Comfort by number of electives (n = {len(bg)})")
fig.tight_layout()
fig.savefig(OUT / "fig-comfort.png", dpi=150)

print(spearman.to_string(index=False), "\n")
print(prof_comf)
