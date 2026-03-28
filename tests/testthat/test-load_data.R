library(testthat)
library(tidyverse)
source("../../R/load_data.R")

test_that("load data reads urls correctly", {
    url <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-08-26/billboard.csv"
    df <- load_data(url)
    
    expect_output(nrow(df)>0)
    expect_true(is.data.frame(df))
})

test_that('data cannot load from a nonexistent url', {
    invalid_url <- "https://this.urldoesnotexist.com/trying/to/copy/format.csv"
    
    expect_error(load_data(invalid_url))
})

#test_that('loads data in csv format that is not a url', {
#    test_tibble <- 
#})
