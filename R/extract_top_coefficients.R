#' Extract and format top predictors by coefficient magnitude
#' 
#' @description 
#' Takes a fitted tidymodels workflow or model engine, extracts the 
#' regression coefficients, removes the intercept, and returns the 
#' top 'n' predictors sorted by absolute coefficient value. Adds a 
#' human-readable 'direction' column and title-cases the term names.
#' 
#' @param fit A fitted model engine (output of `extract_fit_engine()`)
#'  or any object supported by `broom::tidy()` that returns a data 
#'  frame with `term` and `estimate` columns.
#' @param n Integer. Number of top predictors to return, current default
#' is 15.
#' 
#' @return A tibble with columns:
#' - `term`: Formatted predictor name (underscores replaced, title-cased)
#' - `estimate`: Standardized coefficient value
#' - `direction`: "Positive" if estimate > 0, else "Negative"
#' 
#' @example 
#' # After fitting the model:
#' coef <- extract_top_coefficients(extract_fit_engine(final_fit)) # For default n
#' coef <- extract_top_coefficients(extract_fit_engine(final_fit), n = 10) # For n = 10
#' 
#' @export

extract_top_coefficients <- function(fit, n = 15) {
  if (!is.numeric(n) || length(n) != 1 || n < 1) {
    stop("`n` must be a single positive integer.")
  }
  
  tidy_df <- broom::tidy(fit)
  
  if(!all(c("term", "estimate") %in% names(tidy_df))) {
    stop("The object passed to `fit` must produce a tidy dataframe with `term` and `estimate` columns.")
  }
  
  tidy_df |> 
    dplyr::filter(term != "(Intercept)") |>
    dplyr::arrange(dplyr::desc(abs(estimate))) |>
    dplyr::slice_head(n = n) |>
    dplyr::mutate(
      direction = dplyr::if_else(estimate > 0, "Positive", "Negative"),
      term      = stringr::str_replace_all(term, "_", " ") |> stringr::str_to_title()
    )
}