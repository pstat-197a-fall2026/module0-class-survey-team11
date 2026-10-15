# fig-coursework.R
# Finding 1: coursework variation across the class
#   - Figure: % of respondents who took each course, core courses highlighted
#   - Table:  upper_div_courses counts

library(tidyverse)

CORE_CUTOFF <- 80
data_dir <- c("data", "../data")[dir.exists(c("data", "../data"))][1]
if (is.na(data_dir)) {
  stop("Could not find the data/ folder. Run from the repo root or from scripts/.")
}
out_dir <- file.path(dirname(data_dir), "figures")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

background <- read_csv(file.path(data_dir, "background-clean.csv"),
                       show_col_types = FALSE)
n_resp <- nrow(background)  # denominator for every percentage below (51)

# ---- one row per respondent-course -----------------------------------------
# `courses` is a comma-separated cell. Splitting on commas is safe for this
# column because no course label contains a comma.
course_long <- background |>
  select(response_id, courses) |>
  separate_longer_delim(courses, delim = ",") |>
  mutate(course = str_squish(courses)) |>
  filter(course != "") |>
  distinct(response_id, course)  # guard against a course listed twice in one cell

core_label  <- paste0("Core (taken by ", CORE_CUTOFF, "%+ of class)")
other_label <- "Other courses"

course_summary <- course_long |>
  count(course, name = "n_took") |>
  mutate(
    pct   = 100 * n_took / n_resp,
    group = factor(if_else(pct >= CORE_CUTOFF, core_label, other_label),
                   levels = c(core_label, other_label))
  ) |>
  arrange(desc(n_took))

print(course_summary, n = Inf)

# ---- figure -----------------------------------------------------------------
fig_coursework <- course_summary |>
  mutate(course = fct_reorder(course, pct)) |>
  ggplot(aes(x = pct, y = course, fill = group)) +
  geom_col(width = 0.75) +
  # Counts next to every bar: percentages out of 51 people move ~2 points per person.
  geom_text(aes(label = paste0(n_took, "/", n_resp)), hjust = -0.15, size = 3.3) +
  scale_fill_manual(values = setNames(c("#1f4e79", "#9aa5b1"),
                                      c(core_label, other_label)),
                    name = NULL) +
  scale_x_continuous(breaks = seq(0, 100, 25),
                     labels = \(x) paste0(x, "%")) +
  coord_cartesian(xlim = c(0, 112)) +
  labs(
    title = "Nearly everyone has taken the same core courses",
    subtitle = paste0("Share of survey respondents who took each course (n = ", n_resp, ")"),
    x = "Respondents who took the course",
    y = NULL,
    caption = "Labels show number of respondents / total. Courses entered as free text appear once each."
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    legend.justification = "left",
    panel.grid.major.y = element_blank(),
    panel.grid.minor = element_blank(),
    plot.title.position = "plot"
  )

print(fig_coursework)

ggsave(file.path(out_dir, "fig-coursework.png"), fig_coursework,
       width = 8, height = 6, dpi = 300, bg = "white")

# ---- table: upper_div_courses ----------------------------------------------
upper_div_tbl <- background |>
  mutate(upper_div_courses = factor(upper_div_courses,
                                    levels = c("3-5", "6-8", "9+"))) |>
  count(upper_div_courses, name = "n", .drop = FALSE) |>
  mutate(pct = round(100 * n / sum(n), 1))

# Fails loudly if a label is spelled differently than expected (it would become NA).
stopifnot(sum(upper_div_tbl$n) == n_resp)

print(upper_div_tbl)
write_csv(upper_div_tbl, file.path(out_dir, "tbl-upper-div.csv"))

# In report.qmd, show it with:
#   knitr::kable(upper_div_tbl,
#                col.names = c("Upper-division courses taken", "Respondents", "%"))