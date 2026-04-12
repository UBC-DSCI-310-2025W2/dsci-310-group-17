library(docopt)
library(tidyverse)
library(tidymodels)
library(readr)
library(here)

library(dsci310billboardanalysis)

doc <- "
Usage:
  05_model_and_results.R [--in_train=<path>] [--in_test=<path>] [--out_prefix_figures=<prefix>] [--out_prefix_tables=<prefix>]
                        
Options:
  --in_train=<path> Path to the training CSV [default: ../data/processed/billboard_model_training.csv]
  --in_test=<path> Path to the testing CSV [default: ../data/processed/billboard_model_testing.csv]
  --out_prefix_tables=<prefix> Prefix for output files [default: ../results/tables/]
  --out_prefix_figures=<prefix> Prefix for output files [default: ../results/figures/]
"

opt <- docopt(doc)
in_train <- opt$in_train
in_test <- opt$in_test
out_prefix_tables <- opt$out_prefix_tables
out_prefix_figures <- opt$out_prefix_figures

set.seed(123)
dir.create(out_prefix_tables, recursive = TRUE, showWarnings = FALSE)
dir.create(out_prefix_figures, recursive = TRUE, showWarnings = FALSE)

# Reading the training and testing data
train_data <- read_csv(in_train, show_col_types = FALSE)
test_data <- read_csv(in_test, show_col_types = FALSE)

# Recipe & model spec
lm_recipe <- recipe(log_weeks_at_number_one ~ ., data = train_data) |>
  step_dummy(all_nominal_predictors(), one_hot = FALSE) |>
  step_nzv(all_predictors()) |>
  step_normalize(all_numeric_predictors()) |>
  step_lincomb(all_numeric_predictors())

lm_spec <- linear_reg() |>
  set_engine("lm") |>
  set_mode("regression")

lm_workflow <- workflow() |>
  add_recipe(lm_recipe) |>
  add_model(lm_spec)

# Cross validation
message("Running 5-fold repeated cross-validation (3 repeats)...")
set.seed(123)
cv_folds <- vfold_cv(
  train_data,
  v       = 5,
  repeats = 3,
  strata  = log_weeks_at_number_one
)

cv_results <- fit_resamples(
  lm_workflow,
  resamples = cv_folds,
  metrics   = metric_set(rmse, rsq, mae),
  control   = control_resamples(save_pred = TRUE)
)

# Cross-validation summary
cv_metrics <- collect_metrics(cv_results)
write_csv(cv_metrics, paste0(out_prefix_tables, "cv_metrics.csv"))
message("Saved Cross-validation metrics table to: ", paste0(out_prefix_tables, "cv_metrics.csv"))

# Fit the final model on full training set
message("Fitting final model on training data...")
final_fit <- fit(lm_workflow, data = train_data)

# Evaluate the model on test set
message("Evaluating final model on test set...")
test_predictions <- predict(final_fit, new_data = test_data) |>
  bind_cols(test_data |> select(log_weeks_at_number_one)) |>
  rename(
    predicted = .pred,
    actual    = log_weeks_at_number_one
  )

test_metrics <- test_predictions |>
  metrics(truth = actual, estimate = predicted)

write_csv(test_metrics, paste0(out_prefix_tables, "test_metrics.csv"))
message("Saved testing metrics table to: ", paste0(out_prefix_tables, "test_metrics.csv"))

# Result figure 1: Actual vs predicted
message("Plotting results plot comparing actual and predicted target values...")
rsq_label <- paste0(
  "R_squared = ",
  round(
    test_predictions |>
      metrics(truth = actual, estimate = predicted) |>
      filter(.metric == "rsq") |>
      pull(.estimate),
    3
  )
)

p_actual_vs_predicted <- test_predictions |>
  mutate(
    actual_weeks    = expm1(actual),
    predicted_weeks = expm1(predicted)
  ) |>
  ggplot(aes(x = actual_weeks, y = predicted_weeks)) +
  geom_point(alpha = 0.4, colour = "steelblue", size = 2) +
  geom_abline(
    slope     = 1,
    intercept = 0,
    linetype  = "dashed",
    colour    = "firebrick",
    linewidth = 0.8
  ) +
  annotate(
    "text",
    x      = 12,
    y      = 2,
    label  = rsq_label, 
    colour = "firebrick",
    size   = 4
  ) +
  labs(
    title    = "Actual vs Predicted Weeks at #1 (Test Set)",
    x        = "Actual Weeks at #1",
    y        = "Predicted Weeks at #1"
  ) +
  theme_minimal()

ggsave(
  paste0(out_prefix_figures, "actual_vs_predicted.png"),
  plot = p_actual_vs_predicted,
  width = 7,
  height = 5,
  dpi = 150
)
message("Saved results plot comparing actual and predicted target values plot to: ", 
        paste0(out_prefix_figures, "actual_vs_predicted.png"))

# Result figure 2: Top 15 predictors by coefficient magnitude
message("Plotting top 15 coefficients...")

coef_data <- extract_top_coefficients(extract_fit_engine(final_fit), n = 15)

p_coefficients <- ggplot(
  coef_data,
  aes(x = reorder(term, abs(estimate)), y = estimate, fill = direction)
) +
  geom_col(show.legend = TRUE) +
  coord_flip() +
  scale_fill_manual(
    values = c("Positive" = "steelblue", "Negative" = "firebrick"),
    name   = "Effect on\nlog(weeks + 1)"
  ) +
  labs(
    title    = "Top 15 Predictors by Coefficient Magnitude",
    x        = NULL,
    y        = "Standardised Coefficient"
  ) +
  theme_minimal() +
  theme(legend.position = "right")

ggsave(
  paste0(out_prefix_figures, "top_15_coefficients.png"),
  plot = p_coefficients,
  width = 8,
  height = 6,
  dpi = 150
)
message("Saved the coefficients plot to: ",
        paste0(out_prefix_figures, "top_15_coefficients.png"))

write_csv(coef_data, paste0(out_prefix_tables, "top_15_coefficients.csv"))
message("Saved coefficients table to: ",
        paste0(out_prefix_tables, "top_15_coefficients.csv"))

message("Modelling and results completed!")