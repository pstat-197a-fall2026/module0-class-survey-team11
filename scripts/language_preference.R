# fig-courses-language.R
# Question: are the courses a student has taken associated with the programming
# language they prefer (Python, R, or no preference)?
#   - Table:  per course, % of each language group who took it, Fisher exact p-value
#   - Figure: dot plot of those percentages

library(tidyverse)

MIN_GROUP <- 5

lang_levels  <- c("Python", "R", "No preference")
group_levels <- c("Took the course", "Did not take it")

data_dir <- c("data", "../data")[dir.exists(c("data", "../data"))][1]
if (is.na(data_dir)) {
  stop("Could not find the data/ folder. Run from the repo root or from scripts/.")
}
out_dir <- file.path(dirname(data_dir), "figures")
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

background <- read_csv(file.path(data_dir, "background-clean.csv"), show_col_types = FALSE)
interest   <- read_csv(file.path(data_dir, "interest-clean.csv"),   show_col_types = FALSE)

people <- background |>
  select(response_id, courses) |>
  inner_join(select(interest, response_id, language), by = "response_id") |>
  mutate(language = factor(language, levels = lang_levels))

stopifnot(!any(is.na(people$language)))

n_resp <- nrow(people)

overall <- count(people, language) |>
  mutate(pct = 100 * n / sum(n))
print(overall)

course_long <- people |>
  separate_longer_delim(courses, delim = ",") |>
  mutate(course = str_squish(courses)) |>
  filter(course != "") |>
  distinct(response_id, course)

keep <- course_long |>
  count(course, name = "n_took") |>
  filter(n_took >= MIN_GROUP, n_resp - n_took >= MIN_GROUP) |>
  pull(course)

pct_by <- function(flag) {
  as.numeric(prop.table(table(factor(people$language[flag], levels = lang_levels)))) * 100
}

results <- map_dfr(keep, function(crs) {
  took <- people$response_id %in% course_long$response_id[course_long$course == crs]
  tab  <- table(factor(took, levels = c(FALSE, TRUE)), people$language)
  pt <- pct_by(took)
  pn <- pct_by(!took)
  tibble(
    course      = crs,
    n_took      = sum(took),
    n_not       = sum(!took),
    took_python = pt[1], took_r = pt[2], took_nopref = pt[3],
    not_python  = pn[1], not_r  = pn[2], not_nopref  = pn[3],
    p_value     = fisher.test(tab)$p.value
  )
}) |>
  mutate(p_holm = p.adjust(p_value, method = "holm")) |>
  arrange(desc(n_took))

print(results, n = Inf, width = Inf)

write_csv(mutate(results, across(where(is.double), \(x) round(x, 3))),
          file.path(out_dir, "tbl-courses-language.csv"))

# figure
lang_key <- c(python = "Python", r = "R", nopref = "No preference")

plot_df <- results |>
  mutate(course_lab = paste0(course, " (", n_took, " took)")) |>
  select(course_lab, n_took,
         took_python, took_r, took_nopref,
         not_python,  not_r,  not_nopref) |>
  pivot_longer(-c(course_lab, n_took),
               names_to = c("group", "lang"), names_sep = "_", values_to = "pct") |>
  mutate(
    group    = factor(if_else(group == "took", group_levels[1], group_levels[2]),
                      levels = group_levels),
    language = factor(unname(lang_key[lang]), levels = lang_levels),
    course_lab = fct_reorder(course_lab, n_took)
  )

fig_courses_language <- ggplot(plot_df, aes(x = pct, y = course_lab)) +
  geom_vline(data = overall, aes(xintercept = pct),
             linetype = "dashed", color = "grey55") +
  geom_path(aes(group = course_lab), color = "grey75") +
  geom_point(aes(color = group), size = 3, alpha = 0.9) +
  facet_wrap(~ language, nrow = 1,
             labeller = as_labeller(c(Python = "Prefer Python", R = "Prefer R",
                                      `No preference` = "No language preference"))) +
  scale_color_manual(values = c(`Took the course` = "#1f4e79",
                                `Did not take it` = "#c8553d"),
                     name = NULL) +
  scale_x_continuous(limits = c(0, 100), breaks = seq(0, 100, 25),
                     labels = \(x) paste0(x, "%")) +
  labs(
    title = "Language preference of students who took each course vs. those who didn't",
    subtitle = paste0("Dashed line = whole class. Smallest Fisher exact p = ",
                      signif(min(results$p_value), 2), "\n(Holm-adjusted ",
                      signif(min(results$p_holm), 2), ")"),
    x = "Share of the group with this preference",
    y = NULL,
    caption = paste0("Students with both survey sections (n = ", n_resp,
                     ").\nCourses shown: taken by at least ", MIN_GROUP,
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
       width = 11, height = 6, dpi = 300, bg = "white")

