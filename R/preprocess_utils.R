#' Clean and Join Billboard Data
#'
#' Reads, joins, and cleans the billboard and topics datasets.
#' @param billboard_path Path to the raw billboard CSV file.
#' @param topics_path Path to the raw topics CSV file.
#' @return A cleaned and joined data.frame ready for further processing.
#' @examples
#' clean_joined <- clean_and_join_billboard("billboard.csv", "topics.csv")
clean_and_join_billboard <- function(billboard_path, topics_path) {
  if (!file.exists(billboard_path)) stop("billboard_path does not exist")
  if (!file.exists(topics_path)) stop("topics_path does not exist")
  
  billboard <- readr::read_csv(billboard_path, show_col_types = FALSE)
  topics <- readr::read_csv(topics_path, show_col_types = FALSE)
  
  joined <- dplyr::left_join(billboard, topics, by = c("lyrical_topic" = "lyrical_topics"))
  cleaned <- joined %>%
    dplyr::select(-c(song, artist, date)) %>%
    dplyr::select(-non_consecutive) %>%
    dplyr::select(-c(rating_1, rating_2, rating_3)) %>%
    dplyr::select(-c(
      lyrics, u_s_artwork, sound_effects, song_structure, featured_artists, songwriters, songwriters_w_o_interpolation_sample_credits, producers, double_a_side, talent_contestant
    )) %>%
    dplyr::select(-c(label, parent_label, artist_place_of_origin)) %>%
    dplyr::select(-c(cdr_style, discogs_style, keys, discogs_genre)) %>%
    dplyr::select(-c(
      featured_in_a_then_contemporary_play, featured_in_a_then_contemporary_film, featured_in_a_then_contemporary_t_v_show
    )) %>%
    dplyr::mutate(dplyr::across(where(is.character), as.factor)) %>%
    tidyr::drop_na()
  if (nrow(cleaned) == 0) stop("No data remaining after cleaning and joining.")
  return(cleaned)
}

#' Log Transform Columns
#'
#' Applies log1p transformation to specified columns in a data.frame.
#' @param df A data.frame.
#' @param columns Character vector of column names to transform.
#' @return A data.frame with log1p transformed columns.
#' @examples
#' log_df <- log_transform_columns(df, c("weeks_at_number_one"))
log_transform_columns <- function(df, columns) {
  if (!is.data.frame(df)) stop("df must be a data.frame")
  for (col in columns) {
    if (!col %in% names(df)) stop(paste("Column", col, "not found in df"))
    df[[paste0("log_", col)]] <- log1p(df[[col]])
  }
  return(df)
}

#' One-hot Encode Genre Column
#'
#' Expands a semicolon-separated genre column into one-hot encoded columns.
#' @param df A data.frame with a 'cdr_genre' column.
#' @return A data.frame with one-hot encoded genre columns.
#' @examples
#' wide <- one_hot_encode_genre(df)
one_hot_encode_genre <- function(df) {
  if (!"cdr_genre" %in% names(df)) stop("cdr_genre column not found")
  genres <- tidyr::separate_rows(df, cdr_genre, sep = ";")
  genres <- dplyr::mutate(genres, cdr_genre = stringr::str_trim(cdr_genre))
  genres <- dplyr::mutate(genres, value = 1)
  wide <- tidyr::pivot_wider(
    genres,
    names_from = cdr_genre,
    values_from = value,
    values_fill = 0
  )
  return(wide)
}

#' Simplify Key Column
#'
#' Simplifies the 'simplified_key' column to Major/Minor/Multiple Keys.
#' @param df A data.frame with a 'simplified_key' column.
#' @return A data.frame with a simplified 'simplified_key' factor column.
#' @examples
#' df2 <- simplify_key_column(df)
simplify_key_column <- function(df) {
  if (!"simplified_key" %in% names(df)) stop("simplified_key column not found")
  df$simplified_key <- dplyr::case_when(
    df$simplified_key == "Multiple Keys" ~ "Multiple Keys",
    stringr::str_ends(df$simplified_key, "m") ~ "Minor",
    TRUE ~ "Major"
  ) %>% as.factor()
  return(df)
}
