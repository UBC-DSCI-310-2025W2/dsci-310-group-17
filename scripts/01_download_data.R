library(docopt)
library(tidytuesdayR)
library(readr)

doc <- "
Usage:
  01_download_data.R [--out_billboard=<path>] [--out_topics=<path>]
  
Options: 
  --out_billboard=<path> Path/filename for the billboard CSV [default: ../data/raw/billboard.csv]
  --out_topics=<path> Path/filename for the topics CSV [default: ../data/raw/topics.csv]
"

opt <- docopt(doc)

out_billboard <- opt$out_billboard
out_topics <- opt$out_topics

# Create output directories if the don't exist
dir.create(dirname(out_billboard), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(out_topics),    recursive = TRUE, showWarnings = FALSE)

# Load the TidyTuesday data
message("Downloading TidyTuesday data...")
tuesdata <- tidytuesdayR::tt_load(2025, week = 34)
billboard <- tuesdata$billboard
topics <- tuesdata$topics

# Save raw datasets
write_csv(billboard, out_billboard)
write_csv(topics, out_topics)

message("Saved billboard data to: ", out_billboard)
message("Saved topics data to:    ", out_topics)