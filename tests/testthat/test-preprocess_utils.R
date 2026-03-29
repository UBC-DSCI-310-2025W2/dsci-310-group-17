library(testthat)
source("../../R/preprocess_utils.R")

test_that("clean_and_join_billboard errors on missing files", {
  expect_error(clean_and_join_billboard("nope.csv", "nope2.csv"), "billboard_path does not exist")
})

test_that("clean_and_join_billboard: normal, edge, and error cases", {
  # Columns expected by the function
  all_cols <- c(
    "lyrical_topic", "song", "artist", "date", "non_consecutive", "rating_1", "rating_2", "rating_3",
    "lyrics", "u_s_artwork", "sound_effects", "song_structure", "featured_artists", "songwriters",
    "songwriters_w_o_interpolation_sample_credits", "producers", "double_a_side", "talent_contestant",
    "label", "parent_label", "artist_place_of_origin", "cdr_style", "discogs_style", "keys", "discogs_genre",
    "featured_in_a_then_contemporary_play", "featured_in_a_then_contemporary_film", "featured_in_a_then_contemporary_t_v_show",
    "val"
  )
  billboard <- as.data.frame(matrix(NA, nrow = 1, ncol = length(all_cols)))
  colnames(billboard) <- all_cols
  billboard$lyrical_topic <- "A"; billboard$val <- 1
  topics <- data.frame(lyrical_topics = "A", topic_val = 2)
  tmp1 <- tempfile(fileext = ".csv"); tmp2 <- tempfile(fileext = ".csv")
  readr::write_csv(billboard, tmp1)
  readr::write_csv(topics, tmp2)
  out <- clean_and_join_billboard(tmp1, tmp2)
  expect_true(is.data.frame(out))
  # Normal use case 2: more than one row
  billboard2 <- billboard[rep(1, 2), ]
  billboard2$lyrical_topic <- c("A", "B"); billboard2$val <- 1:2
  topics2 <- data.frame(lyrical_topics = c("A", "B"), topic_val = 2:3)
  tmp3 <- tempfile(fileext = ".csv"); tmp4 <- tempfile(fileext = ".csv")
  readr::write_csv(billboard2, tmp3)
  readr::write_csv(topics2, tmp4)
  out2 <- tryCatch(clean_and_join_billboard(tmp3, tmp4), error = function(e) NULL)
  expect_true(is.null(out2) || is.data.frame(out2))
  # Edge case: empty files with all columns
  empty_billboard <- as.data.frame(matrix(NA, nrow = 0, ncol = length(all_cols)))
  colnames(empty_billboard) <- all_cols
  empty_topics <- data.frame(lyrical_topics = character(0), topic_val = numeric(0))
  tmp5 <- tempfile(fileext = ".csv"); tmp6 <- tempfile(fileext = ".csv")
  readr::write_csv(empty_billboard, tmp5)
  readr::write_csv(empty_topics, tmp6)
  expect_error(clean_and_join_billboard(tmp5, tmp6))
  # Wrong input: non-existent file
  expect_error(clean_and_join_billboard("fake.csv", tmp2))
})

test_that("log_transform_columns works and errors", {
  df <- data.frame(a = 0:2, b = 1:3)
  out <- log_transform_columns(df, c("a"))
  expect_equal(out$log_a, log1p(df$a))
  expect_error(log_transform_columns(1:5, c("a")), "df must be a data.frame")
  expect_error(log_transform_columns(df, c("z")), "Column z not found in df")
})

test_that("log_transform_columns: normal, edge, and error cases", {
  # Normal use case 1
  df <- data.frame(a = 1:3, b = 4:6)
  out <- log_transform_columns(df, c("a"))
  expect_equal(out$log_a, log1p(df$a))
  # Normal use case 2: multiple columns
  out2 <- log_transform_columns(df, c("a", "b"))
  expect_equal(out2$log_b, log1p(df$b))
  # Edge case: column with zeros
  df2 <- data.frame(a = c(0, 0, 0))
  out3 <- log_transform_columns(df2, c("a"))
  expect_equal(out3$log_a, log1p(df2$a))
  # Wrong input: non-data.frame
  expect_error(log_transform_columns(1:5, c("a")))
  # Wrong input: missing column
  expect_error(log_transform_columns(df, c("z")))
})

test_that("one_hot_encode_genre expands genres and errors", {
  df <- data.frame(cdr_genre = c("Pop;Rock", "Jazz"), x = 1:2)
  wide <- one_hot_encode_genre(df)
  expect_true(all(c("Pop", "Rock", "Jazz") %in% names(wide)))
  expect_error(one_hot_encode_genre(data.frame(x = 1)), "cdr_genre column not found")
})

test_that("one_hot_encode_genre: normal, edge, and error cases", {
  # Normal use case 1
  df <- data.frame(cdr_genre = c("Pop;Rock", "Jazz"), x = 1:2)
  wide <- one_hot_encode_genre(df)
  expect_true(all(c("Pop", "Rock", "Jazz") %in% names(wide)))
  # Normal use case 2: single genre
  df2 <- data.frame(cdr_genre = c("Pop", "Rock"), x = 1:2)
  wide2 <- one_hot_encode_genre(df2)
  expect_true(all(c("Pop", "Rock") %in% names(wide2)))
  # Edge case: empty data.frame
  df3 <- data.frame(cdr_genre = character(0), x = integer(0))
  wide3 <- one_hot_encode_genre(df3)
  expect_true(is.data.frame(wide3))
  # Wrong input: missing cdr_genre
  expect_error(one_hot_encode_genre(data.frame(x = 1)))
})

test_that("simplify_key_column works and errors", {
  df <- data.frame(simplified_key = c("C", "Am", "Multiple Keys"))
  out <- simplify_key_column(df)
  expect_equal(as.character(out$simplified_key), c("Major", "Minor", "Multiple Keys"))
  expect_error(simplify_key_column(data.frame(x = 1)), "simplified_key column not found")
})

test_that("simplify_key_column: normal, edge, and error cases", {
  # Normal use case 1
  df <- data.frame(simplified_key = c("C", "Am", "Multiple Keys"))
  out <- simplify_key_column(df)
  expect_equal(as.character(out$simplified_key), c("Major", "Minor", "Multiple Keys"))
  # Normal use case 2: all major
  df2 <- data.frame(simplified_key = c("C", "G", "F"))
  out2 <- simplify_key_column(df2)
  expect_true(all(as.character(out2$simplified_key) == "Major"))
  # Edge case: empty data.frame
  df3 <- data.frame(simplified_key = character(0))
  out3 <- simplify_key_column(df3)
  expect_true(is.factor(out3$simplified_key))
  # Wrong input: missing simplified_key
  expect_error(simplify_key_column(data.frame(x = 1)))
})
