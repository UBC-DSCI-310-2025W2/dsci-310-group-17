#' Compute Summary Statistics for Selected Columns
#'
#' @description
#' Takes a data frame and a character vector of numeric column names, and
#' returns a long-format summary table with Mean, SD, Min, Median, and Max
#' rounded to two decimal places for each variable.
#'
#' @param df A data.frame containing the columns to summarise.
#' @param columns A character vector of column names in `df` to summarise.
#'   All specified columns must be numeric.
#'
#' @return A tibble with columns:
#' - `Variable`: name of the original column
#' - `Mean`: mean of the column, rounded to 2 decimal places
#' - `SD`: standard deviation, rounded to 2 decimal places
#' - `Min`: minimum value, rounded to 2 decimal places
#' - `Median`: median value, rounded to 2 decimal places
#' - `Max`: maximum value, rounded to 2 decimal places
#'
#' @examples
#' df <- data.frame(a = 1:5, b = c(2.1, 3.2, 4.3, 5.4, 6.5))
#' compute_summary_stats(df, c("a", "b"))
#'
#' @export
compute_summary_stats <- function(df, columns) {
  if (!is.data.frame(df)) {
    stop("`df` must be a data.frame.")
  }
  if (!is.character(columns) || length(columns) == 0) {
    stop("`columns` must be a non-empty character vector of column names.")
  }
  missing_cols <- setdiff(columns, names(df))
  if (length(missing_cols) > 0) {
    stop(paste("Column(s) not found in `df`:", paste(missing_cols, collapse = ", ")))
  }
  non_numeric <- columns[!sapply(df[columns], is.numeric)]
  if (length(non_numeric) > 0) {
    stop(paste("Column(s) must be numeric:", paste(non_numeric, collapse = ", ")))
  }

  df[columns] |>
    tidyr::pivot_longer(cols = dplyr::everything(), names_to = "Variable") |>
    dplyr::group_by(Variable) |>
    dplyr::summarise(
      Mean   = round(mean(value, na.rm = TRUE), 2),
      SD     = round(sd(value, na.rm = TRUE), 2),
      Min    = round(min(value, na.rm = TRUE), 2),
      Median = round(median(value, na.rm = TRUE), 2),
      Max    = round(max(value, na.rm = TRUE), 2),
      .groups = "drop"
    )
}
