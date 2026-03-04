# Predicting Billboard #1 Hits

**Authors/Contributors:** May Eindra Tet Toe, Anastasia Tountas, Tran Anh Thu Phung, Harry Nguyen

## Summary

This project uses the *Billboard Hot 100 #1 hits* dataset to build a regression model that predicts **how many weeks a song stays at #1** based on song-level features (e.g., musical attributes and lyrical topics). At a high level, our goal is to identify which measurable characteristics are most associated with longer runs at the top of the charts and assess how accurately we can predict a #1 song’s longevity using those features. The results can help quantify what types of songs tend to have longer chart dominance and provide insight into how well these features explain weeks-at-#1.

## How to run the analysis

### Option A (recommended): Docker

*Docker instructions will be added once the Docker environment is built for this project.*

### Option B: Run locally (R)

1. Clone this repository.
2. Open the RMarkdown file in RStudio.
3. Install required R packages (see **Dependencies** below).
4. Knit the RMarkdown file or run the code chunks interactively.

> Note: The analysis downloads the raw data from the web and writes it into the `data/` directory.

## Dependencies

This project is written in **R** and is intended to be run via an RMarkdown workflow.

Key R packages used include (not exhaustive):

- `tidyverse`
- `tidymodels`
- `readr`
- `dplyr`
- `ggplot2`

A fully pinned and reproducible computational environment will be provided via **Docker** in a later step.

## Repository structure (Milestone 1)

- `data/`: data downloaded via code and saved locally for the analysis
- `*.Rmd`: the monolithic RMarkdown report containing the full analysis
- `Dockerfile`: (to be added) container specification for a reproducible environment
- `.github/workflows/publish_docker_image.yml`: (to be added/updated) GitHub Actions workflow to build and publish the Docker image

## Licenses

- **Code license:** MIT License  
- **Report license:** Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)

See `LICENSE.md` for details.
