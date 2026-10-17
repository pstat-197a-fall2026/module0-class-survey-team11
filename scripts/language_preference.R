# fig-courses-language.R
# Question: are the courses a student has taken associated with the programming
# language they prefer (Python, R, or no preference)?
#   - Table:  per course, % of each language group who took it, Fisher exact p-value
#   - Figure: dot plot of those percentages
#
# Run from the repo root or from scripts/. Needs tidyverse (tidyr >= 1.3.0).

library(tidyverse)

# ---- settings ---------------------------------------------------------------
# Only test courses where at least this many students took it AND at least this
# many did not. Courses taken by almost everyone (or almost no one) can't be compared.
MIN_GROUP <- 5

lang_levels <- c("Python", "R", "No preference")

# ---- locate data and output folders ----------------------------------------
data_dir <- c("data", "../data")[dir.exists(c("data", "../data"))][1]
if (is.na(data_dir)) {
  stop("Could not find the data/ folder. Run from the repo root or from scripts/.")
}
out_dir <- file.path(dirname(data_dir), "figures")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

background <- read_csv(file.path(data_dir, "background-clean.csv"), show_col_types = FALSE)
interest   <- read_csv(file.path(data_dir, "interest-clean.csv"),   show_col_types = FALSE)

# ---- join: only students who answered both sections (49) --------------------
people <- background |>
  select(response_id, courses) |>
  inner_join(select(interest, response_id, language), by = "response_id") |>
  mutate(language = factor(language, levels = lang_levels))

stopifnot(!any(is.na(people$language)))  # fails loudly if a language label is spelled differently

n_resp <- nrow(people)
lang_n <- count(people, language)  # group sizes, in the order of lang_levels
print(lang_n)

# ---- one row per student-course ---------------------------------------------
course_long <- people |>
  separate_longer_delim(courses, delim = ",") |>
  mutate(course = str_squish(courses)) |>
  filter(course != "") |>
  distinct(response_id, course)

course_counts <- count(course_long, course, name = "n_took")
keep <- course_counts |>
  filter(n_took >= MIN_GROUP, n_resp - n_took >= MIN_GROUP) |>
  pull(course)

# ---- test each course -------------------------------------------------------
# For each course: % of each language group who took it, plus a Fisher exact test
# of "took the course" (yes/no) against language (3 groups).
results <- map_dfr(keep, function(crs) {
  took <- people$response_id %in% course_long$response_id[course_long$course == crs]
  tab  <- table(factor(took, levels = c(FALSE, TRUE)), people$language)
  pct  <- as.numeric(tapply(took, people$language, mean)) * 100  # order: Python, R, No preference
  tibble(
    course     = crs,
    n_took     = sum(took),
    pct_python = pct[1],
    pct_r      = pct[2],
    pct_nopref = pct[3],
    p_value    = fisher.test(tab)$p.value
  )
}) |>
  mutate(p_holm = p.adjust(p_value, method = "holm")) |>  # we ran several tests, so adjust
  arrange(p_value)

print(results, n = Inf)

write_csv(mutate(results, across(where(is.double), \(x) round(x, 3))),
          file.path(out_dir, "tbl-courses-language.csv"))

# ---- figure -----------------------------------------------------------------
lang_labels <- setNames(paste0(lang_n$language, " (n = ", lang_n$n, ")"),
                        as.character(lang_n$language))

plot_df <- results |>
  select(course, n_took,
         Python = pct_python, R = pct_r, `No preference` = pct_nopref) |>
  pivot_longer(c(Python, R, `No preference`),
               names_to = "language", values_to = "pct") |>
  mutate(language = factor(language, levels = lang_levels),
         course   = fct_reorder(course, n_took))

fig_courses_language <- ggplot(plot_df, aes(x = pct, y = course, color = language)) +
  geom_point(size = 3, alpha = 0.9) +
  scale_color_manual(
    values = c(Python = "#1f4e79", R = "#c8553d", `No preference` = "#7a8793"),
    labels = lang_labels, name = NULL
  ) +
  scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 25),
                     labels = \(x) paste0(x, "%")) +
  labs(
    title = "Course-taking by preferred programming language",
    subtitle = paste0(
      "Share of each language group who took the course. Smallest Fisher exact p = ",
      signif(min(results$p_value), 2), " (Holm-adjusted ",
      signif(min(results$p_holm), 2), ")"
    ),
    x = "Students in the group who took the course",
    y = NULL,
    caption = paste0("Students with both survey sections (n = ", n_resp,
                     "). Courses shown: taken by at least ", MIN_GROUP,
                     " students and not taken by at least ", MIN_GROUP, ".")
  ) +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    legend.justification = "left",
    panel.grid.minor = element_blank(),
    plot.title.position = "plot"
  )

print(fig_courses_language)

ggsave(file.path(out_dir, "fig-courses-language.png"), fig_courses_language,
       width = 8, height = 5.5, dpi = 300, bg = "white")
