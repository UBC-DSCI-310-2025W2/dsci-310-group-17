library(docopt)
library(tidyverse)
library(readr)
library(knitr)
source("R/eda_utils.R")

doc <- "
Usage:
  03_eda.R [--in_data=<path>] [--out_prefix_tables=<prefix>] [--out_prefix_figures=<prefix>]
  
Options:
  --in_data=<path> Path to the processed EDA dataset [default: ../data/processed/billboard_model_eda.csv] 
  --out_prefix_tables=<prefix> Prefix for output files [default: ../results/tables/]
  --out_prefix_figures=<prefix> Prefix for output files [default: ../results/figures/]
"

opt <- docopt(doc)
in_data <- opt$in_data
out_prefix_tables <- opt$out_prefix_tables
out_prefix_figures <- opt$out_prefix_figures

dir.create(out_prefix_tables, recursive = TRUE, showWarnings = FALSE)
dir.create(out_prefix_figures, recursive = TRUE, showWarnings = FALSE)

# Read the EDA data
billboard_clean <- read_csv(in_data, show_col_types = FALSE)

# 1. Summary statistics table
message("Computing summary statistics...")
summary_stats <- compute_summary_stats(
  billboard_clean,
  c("weeks_at_number_one", "overall_rating", "bpm",
    "energy", "danceability", "happiness",
    "acousticness", "loudness_d_b", "front_person_age", "length_sec")
)

write_csv(summary_stats, paste0(out_prefix_tables, "summary_stats.csv"))
message("Saved summary statistics to: ", paste0(out_prefix_tables, "summary_stats.csv"))
        
# 2. Distribution of Weeks at Number One   
message("Plotting Weeks at Number One distribution...")
target_distribution <- ggplot(billboard_clean, aes(x = weeks_at_number_one)) +
  geom_histogram(binwidth = 1, fill = "steelblue", colour = "white") +
  labs(
    title = "Distribution of Weeks at Number One",
    x = "Weeks at Number One",
    y = "Count"
  ) +
  theme_minimal()

ggsave(
  paste0(out_prefix_figures, "target_distribution.png"),
  plot = target_distribution,
  width = 7,
  height = 5,
  dpi = 150
)

message("Saved target distribution plot to: ", paste0(out_prefix_figures, "target_distribution.png"))

# 3. Distribution of Spotify audio features
message("Plotting audio feature distributions...")
audio_feature_distribution <- billboard_clean |>
  select(bpm, energy, danceability, happiness, acousticness) |>
  pivot_longer(
    cols = everything(),
    names_to = "feature",
    values_to = "value"
  ) |>
  ggplot(aes(x = value)) +
  geom_histogram(fill = "steelblue", colour = "white", bins = 30) +
  facet_wrap(~feature, scales = "free") +
  labs(
    title = "Distributions of Spotify Audio Features",
    x = "Value",
    y = "Count"
  ) +
  theme_minimal()

ggsave(
  paste0(out_prefix_figures, "audio_feature_distribution.png"),
  plot = audio_feature_distribution,
  width = 9,
  height = 6,
  dpi = 150
)

message("Saved audio feature distribution plot to: ", paste0(out_prefix_figures, "audio_feature_distribution.png"))

# 4. Average weeks at number one by genre
message("Plotting average weeks at number one by gerne...")
average_week <- billboard_clean |>
  group_by(cdr_genre) |>
  summarise(mean_weeks = mean(weeks_at_number_one), .groups = "drop") |>
  ggplot(aes(
    x = reorder(cdr_genre, mean_weeks),
    y = mean_weeks
  )) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  labs(
    title = "Average Weeks at Number One by Genre",
    x = "Genre",
    y = "Average Weeks at Number One"
  ) +
  theme_minimal()

ggsave(
  paste0(out_prefix_figures, "average_week.png"),
  plot = average_week,
  width = 9,
  height = 6,
  dpi = 150
)

message("Save the average weeks at number one by gerne plot to: ", paste0(out_prefix_figures, "average_week.png"))
message("EDA completed!")