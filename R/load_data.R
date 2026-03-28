#' Load billboard data for project use
#' 
#' @description
#' Loads a CSV file for for project use
#' @param path
#' Path to file - accepts URL or CSV file  
#' @return 
#' A tibble containing the loaded data
#' @example 
#' billboard_data<-load_data("https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-08-26/billboard.csv")
#' @export

load_data<-function(path) {
    readr::read_csv(path)
}