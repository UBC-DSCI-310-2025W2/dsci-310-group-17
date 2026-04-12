# DSCI 310 Group Project 17 Milestone 2 Makefile

.PHONY: all clean

#Run all command for makefile
all: notebooks/billboard_number_one_prediction.html 



#Cleaning the Makefile
clean: 
	rm data/raw/*.csv \
	data/processed/*.csv \
	results/figures/*.png \
	results/tables/*.csv \
	notebooks/*.html \
	notebooks/*.pdf 

#Generating data for report 
data/raw/billboard.csv \
data/raw/topics.csv: scripts/01_download_data.R
	Rscript scripts/01_download_data.R

#Preprocessing data 
data/processed/billboard_model_eda.csv \
data/processed/billboard_model_selected.csv \
data/processed/billboard_model_testing.csv \
data/processed/billboard_model_training.csv: \
data/raw/billboard.csv data/raw/topics.csv \
scripts/02_preprocess_data.R
	Rscript scripts/02_preprocess_data.R


#Conducting EDA and generating relevant plots for scripts
results/tables/summary_stats.csv \
results/figures/target_distribution.png \
results/figures/audio_feature_distribution.png \
results/figures/average_week.png: data/processed/billboard_model_eda.csv scripts/03_eda.R
	Rscript scripts/03_eda.R

#Generating Final model and explaining analysis results
results/tables/cv_metrics.csv \
results/tables/test_metrics.csv \
results/tables/top_15_coefficients.csv \
results/figures/actual_vs_predicted.png \
results/figures/top_15_coefficients.png: \
data/processed/billboard_model_training.csv \
data/processed/billboard_model_testing.csv \
scripts/04_model_and_results.R
	Rscript scripts/04_model_and_results.R


#Building the quarto file, PDF, and HTML for the report

#quarto file 
render: 
	quarto render notebooks/billboard_number_one_prediction.qmd

#PDF 
notebooks/billboard_number_one_prediction.pdf: results notebooks/billboard_number_one_prediction.qmd
	quarto render notebooks/billboard_number_one_prediction.qmd --to pdf

#HTML
notebooks/billboard_number_one_prediction.html: results notebooks/billboard_number_one_prediction.qmd
	quarto render notebooks/billboard_number_one_prediction.qmd --to html

