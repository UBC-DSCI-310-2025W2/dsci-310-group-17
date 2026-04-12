# DSCI 310 Group Project 17 Milestone 2 Makefile

.PHONY: all clean validate

#Run all command for makefile
all: notebooks/billboard_number_one_prediction.html


#Cleaning the Makefile
clean:
	rm -f data/raw/*.csv \
	data/processed/*.csv \
	results/figures/*.png \
	results/tables/*.csv \
	notebooks/*.html \
	notebooks/*.pdf

#Generating data for report
data/raw/billboard.csv \
data/raw/topics.csv: scripts/01_download_data.R
	Rscript scripts/01_download_data.R \
		--out_billboard=data/raw/billboard.csv \
		--out_topics=data/raw/topics.csv

#Preprocessing data
data/processed/billboard_model_eda.csv \
data/processed/billboard_model_selected.csv \
data/processed/billboard_model_testing.csv \
data/processed/billboard_model_training.csv: \
data/raw/billboard.csv data/raw/topics.csv \
scripts/02_preprocess_data.R
	Rscript scripts/02_preprocess_data.R \
		--in_billboard=data/raw/billboard.csv \
		--in_topics=data/raw/topics.csv \
		--out_eda=data/processed/billboard_model_eda.csv \
		--out_train=data/processed/billboard_model_training.csv \
		--out_test=data/processed/billboard_model_testing.csv \
		--out_full=data/processed/billboard_model_selected.csv


results:
	mkdir -p results/figures results/tables

# Data validation checks
validate: data/processed/billboard_model_eda.csv scripts/03_validate_data.R
	Rscript scripts/03_validate_data.R \
		--in_eda=data/processed/billboard_model_eda.csv

#Conducting EDA and generating relevant plots for scripts
results/tables/summary_stats.csv \
results/figures/target_distribution.png \
results/figures/audio_feature_distribution.png \
results/figures/average_week.png: results data/processed/billboard_model_eda.csv validate scripts/04_eda.R
	Rscript scripts/04_eda.R \
		--in_data=data/processed/billboard_model_eda.csv \
		--out_prefix_tables=results/tables/ \
		--out_prefix_figures=results/figures/

#Generating Final model and explaining analysis results
results/tables/cv_metrics.csv \
results/tables/test_metrics.csv \
results/tables/top_15_coefficients.csv \
results/figures/actual_vs_predicted.png \
results/figures/top_15_coefficients.png: \
results \
data/processed/billboard_model_training.csv \
data/processed/billboard_model_testing.csv \
scripts/05_model_and_results.R
	Rscript scripts/05_model_and_results.R \
		--in_train=data/processed/billboard_model_training.csv \
		--in_test=data/processed/billboard_model_testing.csv \
		--out_prefix_tables=results/tables/ \
		--out_prefix_figures=results/figures/


#Building the quarto file, PDF, and HTML for the report

#quarto file
render:
	quarto render notebooks/billboard_number_one_prediction.qmd

#PDF
notebooks/billboard_number_one_prediction.pdf: \
results/tables/summary_stats.csv \
results/tables/cv_metrics.csv \
results/tables/test_metrics.csv \
results/tables/top_15_coefficients.csv \
results/figures/target_distribution.png \
results/figures/audio_feature_distribution.png \
results/figures/average_week.png \
results/figures/actual_vs_predicted.png \
results/figures/top_15_coefficients.png \
notebooks/billboard_number_one_prediction.qmd
	quarto render notebooks/billboard_number_one_prediction.qmd --to pdf

#HTML
notebooks/billboard_number_one_prediction.html: \
results/tables/summary_stats.csv \
results/tables/cv_metrics.csv \
results/tables/test_metrics.csv \
results/tables/top_15_coefficients.csv \
results/figures/target_distribution.png \
results/figures/audio_feature_distribution.png \
results/figures/average_week.png \
results/figures/actual_vs_predicted.png \
results/figures/top_15_coefficients.png \
notebooks/billboard_number_one_prediction.qmd
	quarto render notebooks/billboard_number_one_prediction.qmd --to html
