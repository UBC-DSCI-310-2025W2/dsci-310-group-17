library(testthat)
library(dplyr)
library(tibble)
library(here)

source(here::here("R/extract_top_coefficients.R"))

# Make a fake data model
mock_lm <- lm (
  y ~ loud_factor + tempo_bpm + release_year + artist_popularity + danceability_score,
  data = tibble(
    y = c(1,2,3,4,5),
    loud_factor = c(2.1, -4.3, 2.6, 0.8, -1.5),
    tempo_bpm = c(1,6,3,4,2),
    release_year = c(2003, 2019, 2017, 2024, 2007),
    artist_popularity = c(50, 70, 90, 30, 80),
    danceability_score = c(0.4, 0.6, 0.7, 0.2, 0.9)
  )
)

# Tests
## Checking n
test_that("n as a strings and throws an error", {
  expect_error(extract_top_coefficients(mock_lm, n ="10"))
})

test_that("n as a negative number throws an error", {
  expect_error(extract_top_coefficients(mock_lm, n = -1))
})

test_that("n as a zero throws an error", {
  expect_error(extract_top_coefficients(mock_lm, n = 0))
})

test_that("n as a vector throws an error", {
  expect_error(extract_top_coefficients(mock_lm, n = c(3,5)))
})

test_that("n as NULL throws an error", {
  expect_error(extract_top_coefficients(mock_lm, n = NULL))
})

## Checking fit
test_that("fit without estimate columns", {
  bad_input <- list(a = 1, b = 2)
  expect_error(extract_top_coefficients(bad_input))
})

test_that("non-model object throws an error", {
  expect_error(extract_top_coefficients("not_a_model"))
})

test_that("NULL fit throws an error", {
  expect_error(extract_top_coefficients(NULL))
})

# Checking output type
test_that("function retruns a data frame", {
  result <- extract_top_coefficients(mock_lm, n = 4)
  expect_true(is.data.frame(result))
})

test_that("result have all required columns", {
  result <- extract_top_coefficients(mock_lm, n = 4)
  expect_true(all(c("term", "estimate", "direction") %in% names(result)))
})

test_that("term column in character type", {
  result <- extract_top_coefficients(mock_lm, n = 4)
  expect_type(result$term, "character")
})

test_that("estimate column is double type", {
  result <- extract_top_coefficients(mock_lm, n = 4)
  expect_type(result$estimate, "double")
})

test_that("direction column in character type", {
  result <- extract_top_coefficients(mock_lm, n = 4)
  expect_type(result$direction, "character")
})

test_that("intercept is removed from output", {
  result <- extract_top_coefficients(mock_lm, n = 4)
  expect_false("(Intercept)" %in% result$term)
})

test_that("output has fewer rows than input including intercept", {
  result <- extract_top_coefficients(mock_lm, n = 10)
  input_rows <- nrow(broom::tidy(mock_lm))
  expect_lt(nrow(result), input_rows)
})

test_that("return at most n rows", {
  result <- extract_top_coefficients(mock_lm, n = 4)
  expect_lte(nrow(result), 4)
})

test_that("returns all rows when n exceed number of predictors", {
  result <- extract_top_coefficients(mock_lm, n = 20)
  expect_lte(nrow(result), 5)
})

test_that("rows are sorted by decending absolute estimate", {
  result <- extract_top_coefficients(mock_lm, n = 4)
  expect_true(all(diff(abs(result$estimate)) <= 0))
})

test_that("direction column only contains Positive or Negative", {
  result <- extract_top_coefficients(mock_lm, n = 4)
  expect_true(all(result$direction %in% c ("Positive", "Negative")))
})

test_that("direction matches sign of estimate", {
  result <- extract_top_coefficients(mock_lm, n = 4)
  expect_true(all(
    (result$estimate > 0 & result$direction == "Positive") |
      (result$estimate < 0 & result$direction == "Negative")
  ))
})