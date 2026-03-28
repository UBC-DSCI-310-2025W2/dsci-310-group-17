library(testthat)
library(dplyr)
library(here)

source(here::here("R/eda_utils.R"))

# --- Simple input used across tests ---
simple_df <- data.frame(
  x = c(1, 2, 3, 4, 5),
  y = c(10, 20, 30, 40, 50)
)

# Test input

test_that("non-data.frame input throws an error", {
  expect_error(compute_summary_stats(list(x = 1:5), "x"), "`df` must be a data.frame")
})

test_that("numeric vector as df throws an error", {
  expect_error(compute_summary_stats(1:5, "x"), "`df` must be a data.frame")
})

test_that("non-existent column name throws an error", {
  expect_error(
    compute_summary_stats(simple_df, c("x", "z")),
    "Column\\(s\\) not found in `df`"
  )
})

test_that("non-character columns argument throws an error", {
  expect_error(compute_summary_stats(simple_df, 1), "`columns` must be a non-empty character vector")
})

test_that("empty character vector for columns throws an error", {
  expect_error(compute_summary_stats(simple_df, character(0)), "`columns` must be a non-empty character vector")
})

test_that("non-numeric column throws an error", {
  df_with_char <- data.frame(x = 1:3, label = c("a", "b", "c"))
  expect_error(compute_summary_stats(df_with_char, "label"), "Column\\(s\\) must be numeric")
})

# Test output

test_that("output is a data.frame", {
  result <- compute_summary_stats(simple_df, "x")
  expect_true(is.data.frame(result))
})

test_that("output has the expected column names", {
  result <- compute_summary_stats(simple_df, "x")
  expect_equal(names(result), c("Variable", "Mean", "SD", "Min", "Median", "Max"))
})

test_that("one column produces one row in output", {
  result <- compute_summary_stats(simple_df, "x")
  expect_equal(nrow(result), 1)
})

test_that("two columns produce two rows in output", {
  result <- compute_summary_stats(simple_df, c("x", "y"))
  expect_equal(nrow(result), 2)
})

test_that("Variable column contains the correct column names", {
  result <- compute_summary_stats(simple_df, c("x", "y"))
  expect_setequal(result$Variable, c("x", "y"))
})

test_that("computed Mean matches expected value", {
  result <- compute_summary_stats(simple_df, "x")
  expect_equal(result$Mean[result$Variable == "x"], round(mean(simple_df$x), 2))
})

test_that("computed SD matches expected value", {
  result <- compute_summary_stats(simple_df, "x")
  expect_equal(result$SD[result$Variable == "x"], round(sd(simple_df$x), 2))
})

test_that("computed Min and Max match expected values", {
  result <- compute_summary_stats(simple_df, "x")
  expect_equal(result$Min[result$Variable == "x"], round(min(simple_df$x), 2))
  expect_equal(result$Max[result$Variable == "x"], round(max(simple_df$x), 2))
})

test_that("computed Median matches expected value", {
  result <- compute_summary_stats(simple_df, "x")
  expect_equal(result$Median[result$Variable == "x"], round(median(simple_df$x), 2))
})

test_that("values are rounded to 2 decimal places", {
  df_frac <- data.frame(a = c(1.123456, 2.654321, 3.333333))
  result <- compute_summary_stats(df_frac, "a")
  expect_equal(result$Mean, round(mean(df_frac$a), 2))
})

# Edge cases

test_that("single-row data frame returns valid stats where SD is NA", {
  single_row <- data.frame(x = 42)
  result <- compute_summary_stats(single_row, "x")
  expect_equal(result$Mean, 42)
  expect_equal(result$Min, 42)
  expect_equal(result$Max, 42)
  expect_equal(result$Median, 42)
  expect_true(is.na(result$SD))
})

test_that("column with NA values returns non-NA stats (na.rm = TRUE)", {
  df_na <- data.frame(x = c(1, 2, NA, 4, 5))
  result <- compute_summary_stats(df_na, "x")
  expect_equal(result$Mean, round(mean(df_na$x, na.rm = TRUE), 2))
  expect_false(is.na(result$Mean))
})

test_that("column of identical values returns SD of 0", {
  df_const <- data.frame(x = rep(7, 5))
  result <- compute_summary_stats(df_const, "x")
  expect_equal(result$SD, 0)
  expect_equal(result$Min, 7)
  expect_equal(result$Max, 7)
})
