library(testthat)
library(readr)
library(tidyverse)
source("../../R/load_data.R")

#Loads a valid URL
test_that("load data reads urls correctly", {
    url <- "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-08-26/billboard.csv"
    df <- load_data(url)
    
    expect_true(nrow(df)>0)
    expect_true(is.data.frame(df))
})

#Fails to load an invalid URL
test_that('data cannot load from a nonexistent url', {
    invalid_url <- "https://this.urldoesnotexist.com/trying/to/copy/format.csv"
    
    expect_error(load_data(invalid_url))
})

# Loads data in a csv format
test_that('loads data in csv format that is not a url', {
    df_test <- data.frame(col_1 = c('tempo', 'bpm', 'rythum'), col_2 = 1:3)
    
    temp_file <- tempfile(fileext = '.csv')
    write_csv(df_test, temp_file)
    
    result <- load_data(temp_file)
    
    expect_equal(result,df_test)
})

#Fails to load nonexistent data file
test_that('retunrs an error if the file does not exist', {
    fake_file <- tempfile(fileext = ".csv")
    expect_error(load_data(fake_file), "File does not exist")
})

#Fails to load files with different types (not csv)
test_that('returns an error if there is an invalid file type', {
    temp_file_inv <-tempfile(fileext = ".txt")
    writeLines(c("this", "is", "not a csv"), temp_file_inv)
    
    expect_error(load_data(temp_file_inv))
})
