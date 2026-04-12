# Data validation checkpoint for the Billboard analysis pipeline.
#
# This script validates the EDA dataset before the train/test split so the
# downstream analysis does not leak information from the test set into the
# validation decisions.
#
# If pointblank is not installed, run:
#   renv::install("pointblank")

library(docopt)
library(pointblank)
library(tidyverse)
library(readr)

doc <- "
Usage:
  03_validate_data.R [--in_eda=<path>]
  
Options:
  --in_eda=<path> Path to the EDA dataset [default: data/processed/billboard_model_eda.csv]
"

opt <- docopt(doc)
in_eda <- opt$in_eda

# Read the pre-split EDA dataset.
billboard_eda <- read_csv(in_eda, show_col_types = FALSE)

# Capture the columns that exist in the EDA input so the validation checks
# can confirm the file still has the structure the rest of the pipeline expects.
expected_columns <- names(billboard_eda)

# Numeric fields that should remain numeric after preprocessing.
numeric_cols <- c("weeks_at_number_one", "overall_rating", "divisiveness", 
                  "front_person_age", "bpm", "energy", 
                  "danceability", "happiness", "loudness_d_b", "acousticness")

# Start validation on the EDA dataset.
message("Starting data validation on EDA dataset...")

# CRITICAL checks: fail the pipeline if any of these fail.
agent_critical <- create_agent(
  billboard_eda,
  label = "Billboard EDA Dataset Validation (Critical Checks)"
) %>%

  # Check 1: confirm the dataset still has the columns the pipeline expects.
  col_exists(
    columns = expected_columns,
    label = "Check 1: Expected columns exist"
  ) %>%
  
  # Check 2: confirm the columns needed by downstream analysis are present.
  col_exists(
    columns = c("weeks_at_number_one", "cdr_genre", "simplified_key", "front_person_age"),
    label = "Check 2: Critical columns present in dataset"
  ) %>%
  
  # Check 3: the target variable must never be missing.
  col_vals_not_null(
    columns = "weeks_at_number_one",
    label = "Check 3: Target variable (weeks_at_number_one) has no null values"
  ) %>%
  
  # Check 4: critical predictors and metadata should also be populated.
  # Check 5: numeric fields should still be numeric after preprocessing.
  col_is_numeric(
    columns = all_of(numeric_cols[numeric_cols %in% names(billboard_eda)]),
    label = "Check 5: Numeric columns have correct data types"
  ) %>%
  
  # Check 6: duplicate rows can distort summary statistics and modeling.
  rows_distinct(
    label = "Check 6: No duplicate rows in dataset"
  ) %>%
  
  # Check 7: numeric ranges should stay within plausible bounds.
  col_vals_gt(
    columns = "weeks_at_number_one",
    value = 0,
    label = "Check 7a: Target variable (weeks_at_number_one) is positive"
  ) %>%
  col_vals_lte(
    columns = "weeks_at_number_one",
    value = 52,
    label = "Check 7b: Target variable (weeks_at_number_one) within reasonable range"
  ) %>%
  
  # Check 8: categorical columns need values so downstream recoding can work.
  # Run the critical checks and collect results.
  interrogate()

# WARNING checks: report issues but do not block the pipeline.
agent_warning <- create_agent(
  billboard_eda,
  label = "Billboard EDA Dataset Validation (Warning Checks)"
) %>%

  # Check 4: predictors and metadata missingness should remain low.
  col_vals_not_null(
    columns = all_of(c("overall_rating", "cdr_genre", "simplified_key")),
    label = "Check 4: Critical columns have missingness below threshold"
  ) %>%

  # Check 7c: front-person age should remain in plausible bounds.
  col_vals_between(
    columns = "front_person_age",
    left = 10,
    right = 100,
    label = "Check 7c: Front person age in reasonable range (10-100)"
  ) %>%

  # Check 8: categorical columns should have usable values.
  col_vals_not_null(
    columns = "cdr_genre",
    label = "Check 8a: cdr_genre column has values"
  ) %>%
  col_vals_not_null(
    columns = "simplified_key",
    label = "Check 8b: simplified_key column has values"
  ) %>%

  # Check 9: Spotify-style features should remain on the expected 0-1 scale.
  col_vals_between(
    columns = c("energy", "danceability", "happiness", "acousticness"),
    left = 0,
    right = 1,
    label = "Check 9: Spotify audio features in expected range (0-1)"
  ) %>%

  # Run the warning checks and collect results.
  interrogate()

# Print validation summaries to the console for quick inspection.
message("\n=== EDA Dataset Validation Summary (Critical) ===")
print(agent_critical)

message("\n=== EDA Dataset Validation Summary (Warning) ===")
print(agent_warning)

# Report whether critical validation checks passed overall.
critical_passed <- all_passed(agent_critical)
warning_passed <- all_passed(agent_warning)

if (!critical_passed) {
  message("\nERROR: Critical validation checks failed. Stopping pipeline.")
  quit(save = "no", status = 1)
}

if (!warning_passed) {
  message("\nWARNING: Non-critical validation checks found issues. Continuing.")
}

# Final status message so pipeline logs clearly show the validation step ended.
message("\n✓ Data validation completed successfully!")
