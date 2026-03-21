# Predicting Billboard #1 Hits

## Contributors/Authors

- May Eindra Tet Toe
- Anastasia Tountas
- Tran Anh Thu Phung
- Harry Nguyen

## Summary

This project asks the predictive question: Can we predict how many weeks a song stays at #1 on the Billboard Hot 100 chart based on its song-level features, such as musical attributes and lyrical topics?

We use a publicly available Billboard Hot 100 dataset (TidyTuesday, 1958–2025) combined with song-level audio and metadata features to build a regression model that predicts the number of weeks a song remains at the top of the charts (using a log1p transformation to address the strong right-skew in weeks-at-#1). Our linear regression model demonstrates weak predictive performance on unseen data (test RMSE ≈ 0.50 on the log scale; test R² ≈ 0.05), suggesting that the included musical and lyrical-topic features explain only a small portion of the variation in #1 longevity. At a high level, this implies that many drivers of long #1 runs likely depend on factors not captured in the dataset—such as marketing and promotion, artist popularity, streaming/radio dynamics, release timing, and competition in a given week. Despite limited predictive accuracy, the model highlights a few consistent associations with longer #1 runs, including lower energy, higher loudness, and higher overall rating.

## How to Run the Analysis

1. Clone this repository:

   ```bash
   git clone git@github.com:UBC-DSCI-310-2025W2/dsci-310-group-17.git
   cd dsci-310-group-17
   ```

2. Start the container:

   ```bash
   docker compose up
   ```

3. Open <http://localhost:8787> in your browser (no password required).

4. In the RStudio file pane, open `billboard_number_one_prediction.Rmd` and knit the document (**Knit → Knit to HTML**) or run all chunks.

5. When done, stop the container with:

   ```bash
   docker compose down
   ```

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
