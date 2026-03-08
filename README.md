# Predicting Billboard #1 Hits

## Contributors/Authors

- May Eindra Tet Toe
- Anastasia Tountas
- Tran Anh Thu Phung
- Harry Nguyen

## Summary

This project asks the predictive question: **Can we predict how many weeks a song stays at #1 on the Billboard Hot 100 chart based on its song-level features, such as musical attributes and lyrical topics?**

We use a publicly available Billboard Hot 100 dataset combined with Spotify audio features to build a regression model that predicts the number of weeks a song remains at the top of the charts. Our goal is to identify which measurable characteristics are most associated with longer runs at #1 and to assess how accurately we can predict a #1 song's longevity using those features. The results help quantify what types of songs tend to have longer chart dominance and provide insight into how well these features explain weeks-at-#1.

## How to Run the Analysis

1. Clone this repository:

   ```bash
   git clone git@github.com:UBC-DSCI-310-2025W2/dsci-310-group-17.git
   cd dsci-310-group-17
   ```

2. Build the Docker image:

   ```bash
   docker build -t billboard-analysis .
   ```

3. Run the container:

   ```bash
   docker run -p 8787:8787 \
       -e PASSWORD=billboard \
       -v "$(pwd)":/home/rstudio/project \
       billboard-analysis
   ```

4. Open <http://localhost:8787> in your browser.

5. Log in with:
   - **Username:** `rstudio`
   - **Password:** `billboard`

6. In the RStudio file pane, open `billboard_number_one_prediction.Rmd` and knit the document (**Knit → Knit to HTML**) or run all chunks.

## Dependencies

This project uses R 4.5.2 and manages package dependencies with `renv`. All package versions are pinned in `renv.lock`. Running the analysis inside the provided Docker container ensures all dependencies are automatically installed at the correct versions.

Key dependencies include:

| Package     | Version |
|-------------|---------|
| R           | 4.5.2   |
| tidyverse   | 2.0.0   |
| ggplot2     | 4.0.1   |
| dplyr       | 1.1.4   |
| readr       | 2.1.6   |
| knitr       | 1.50    |
| caret       | 7.0-1   |
| broom       | 1.0.10  |
| MASS        | 7.3-65  |
| Matrix      | 1.7-4   |
| Rcpp        | 1.1.0   |

For the complete list of all pinned dependencies, see `renv.lock`.

## Licenses

The software code in this project is licensed under the MIT License.  
The written analysis and reports are licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License (CC BY-NC-ND 4.0). 

See `LICENSE.md` for details.
