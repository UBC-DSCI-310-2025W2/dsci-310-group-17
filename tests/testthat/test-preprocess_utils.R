library(testthat)
source("../../R/preprocess_utils.R")

test_that("clean_and_join_billboard errors on missing files", {
  expect_error(clean_and_join_billboard("nope.csv", "nope2.csv"), "billboard_path does not exist")
})

test_that("log_transform_columns works and errors", {
  df <- data.frame(a = 0:2, b = 1:3)
  out <- log_transform_columns(df, c("a"))
  expect_equal(out$log_a, log1p(df$a))
  expect_error(log_transform_columns(1:5, c("a")), "df must be a data.frame")
  expect_error(log_transform_columns(df, c("z")), "Column z not found in df")
})

test_that("one_hot_encode_genre expands genres and errors", {
  df <- data.frame(cdr_genre = c("Pop;Rock", "Jazz"), x = 1:2)
  wide <- one_hot_encode_genre(df)
  expect_true(all(c("Pop", "Rock", "Jazz") %in% names(wide)))
  expect_error(one_hot_encode_genre(data.frame(x = 1)), "cdr_genre column not found")
})

test_that("simplify_key_column works and errors", {
  df <- data.frame(simplified_key = c("C", "Am", "Multiple Keys"))
  out <- simplify_key_column(df)
  expect_equal(as.character(out$simplified_key), c("Major", "Minor", "Multiple Keys"))
  expect_error(simplify_key_column(data.frame(x = 1)), "simplified_key column not found")
})
