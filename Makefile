# DSCI 310 Group Project Milestone 2 Makefile

.PHONY: all clean

#Run all command for makefile
all: data/raw/billboard.csv \
	data/raw/topics.csv \
	data/processed/billboard_model_eda \
	data/processed/billboard_model_selected \
	data/processed/billboard_model_testing \
	data/processsed/billboard_model_training \
	results/tables/summary_stats.csv \
	results/figures/target_distribution.png \
	results/figures/average_week.csv \



#Cleaning the Makefile
clean: 

#Initializing and installing envrionment through Docker ? - waiting on group response/feedback


#Generating data for report 
data/raw/billboard.csv \
data/raw/topics.csv: scripts/01_downloading_data.R
	Rscript scripts/01_downloading_data.R

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
results/figures/average_week.csv: data/processed/billboard_model_eda.csv scripts/03_eda.R
	Rscript scripts/03_eda.csv

#Generating Final model and explaining analysis results



#Building the quarto file for the report
