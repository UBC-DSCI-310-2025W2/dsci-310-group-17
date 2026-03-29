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

### Prerequisites

- [Docker Desktop](https://docs.docker.com/get-docker/) installed and running

### Steps

1. Clone this repository:

   ```bash
   git clone git@github.com:UBC-DSCI-310-2025W2/dsci-310-group-17.git
   cd dsci-310-group-17
   ```

2. Start the container using the pinned image tag:

   ```bash
   IMAGE_TAG=sha-307ddb7 docker compose up
   ```

   This:
   - Uses image `ruk2712/dsci-310-group-17:sha-307ddb7` (pinned to this project's latest release)
   - Maps port **8787** on your machine to RStudio Server inside the container
   - Mounts the current directory into `/home/rstudio/project` inside the container

   > **Alternative tags:** All available image tags (including newer releases) are listed on [Docker Hub](https://hub.docker.com/r/ruk2712/dsci-310-group-17/tags). To use a different version, replace `sha-13c80a2` with any tag from that page, e.g.:
   > ```bash
   > IMAGE_TAG=sha-6d85eab docker compose up
   > ```
   > You can also omit `IMAGE_TAG` entirely to use `latest`, though this may not be reproducible.

3. Open <http://localhost:8787> in your browser (no password required) to access RStudio Server.

4. In the RStudio **Terminal** tab, run the full analysis pipeline using the Makefile:

   ```bash
   cd projects
   make all
   ```

   This runs the following steps in order:
   | Step | Script | Output |
   |------|--------|--------|
   | Download data | `scripts/01_download_data.R` | `data/raw/` |
   | Preprocess data | `scripts/02_preprocess_data.R` | `data/processed/` |
   | EDA | `scripts/03_eda.R` | `results/figures/`, `results/tables/` |
   | Model & results | `scripts/04_model_and_results.R` | `results/figures/`, `results/tables/` |
   | Render report (HTML) | `notebooks/billboard_number_one_prediction.qmd` | `notebooks/billboard_number_one_prediction.html` |

   To also render the **PDF** version of the report:

   ```bash
   make notebooks/billboard_number_one_prediction.pdf
   ```

   > **Note:** The report is a Quarto document (`.qmd`). Do not use the RStudio Knit button — use the Makefile commands above instead.

5. To remove all generated files and start fresh:

   ```bash
   make clean
   ```

6. When done, stop the container. In the terminal where `docker compose up` is running, press **Ctrl+C** to stop it, then run:

   ```bash
   docker compose down
   ```

## Adding a New Dependency

This project uses `renv` to manage R package dependencies and Docker to ensure a reproducible environment. Follow these steps when adding a new R package:

1. Create a new branch:

   ```bash
   git checkout -b add-<package-name>-dependency
   ```

2. Start the container and open RStudio at <http://localhost:8787>:

   ```bash
   docker compose up
   ```

3. Install the package inside the container's RStudio **Console**:

   ```r
   install.packages("<package-name>")
   ```

4. Snapshot the new package into `renv.lock`:

   ```r
   renv::snapshot()
   ```

5. Add the package to the `Dockerfile` if it requires any system-level libraries (add an `apt-get install` line under the existing `RUN apt-get` block).

6. Commit both `renv.lock` and (if changed) `Dockerfile`, then push the branch. The GitHub Actions workflow will automatically build and push a new Docker image tagged with the commit SHA.

7. Pin to the new SHA tag by setting `IMAGE_TAG` when starting the container. The exact tag (formatted as `sha-<7-char-sha>`) is shown in the GitHub Actions run logs and on [Docker Hub](https://hub.docker.com/r/ruk2712/dsci-310-group-17/tags):

   ```bash
   IMAGE_TAG=sha-<your-new-sha> docker compose up
   ```

8. Open a pull request to merge the changes into `main`.

## Running the Tests

Tests are written with [`testthat`](https://testthat.r-lib.org/) and cover the four core utility functions in `R/`:

| Test file | Functions tested |
|-----------|-----------------|
| `tests/testthat/test-eda_utils.R` | `compute_summary_stats` |
| `tests/testthat/test-extract_top_coefficients.R` | `extract_top_coefficients()` |
| `tests/testthat/test-load_data.R` | `load_data()` |
| `tests/testthat/test-preprocess_utils.R` | `clean_and_join_billboard()` |

To run all tests, open the RStudio **Terminal** inside the running container and execute:

```bash
Rscript -e "testthat::test_dir('tests/testthat')"
```

Or run a single test file:

```bash
Rscript -e "testthat::test_file('tests/testthat/test-load_data.R')"
```

## Dependencies

This project uses R 4.5.2 and manages package dependencies with `renv`. All package versions are pinned in `renv.lock`. Running the analysis inside the provided Docker container ensures all dependencies are automatically installed at the correct versions.

Key dependencies include:

| Package     | Version      |
|-------------|--------------|
| R           | 4.5.2        |
| tidyverse   | 2.0.0        |
| ggplot2     | 4.0.2        |
| dplyr       | 1.2.0        |
| readr       | 2.2.0        |
| knitr       | 1.51         |
| caret       | 7.0-1        |
| broom       | 1.0.12       |
| tidymodels  | 1.4.1        |
| tibble      | 3.3.1        |
| docopt      | 0.7.2        |
| testthat    | 3.3.2        |
| here        | 1.0.2        |

For the complete list of all pinned dependencies, see `renv.lock`.

## Licenses

The software code in this project is licensed under the MIT License.  
The written analysis and reports are licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License (CC BY-NC-ND 4.0).

See `LICENSE.md` for details.
