library(docopt)
library(tidyverse)
library(caret)
library(readr)
library(tidymodels)
library(dsci310billboardanalysis)

doc <- "
Usage:
  02_preprocess_data.R [--in_billboard=<path>] [--in_topics=<path>] [--out_train=<path>] [--out_test=<path>] [--out_full=<path>] [--out_eda=<path>]
                       
Options:
  --in_billboard=<path> Path to raw billboard CSV [default: ../data/raw/billboard.csv]
  --in_topics=<path> Path to raw topics CSV [default: ../data/raw/topics.csv]
  --out_eda=<path> Path for EDA data CSV [default: ../data/processed/billboard_model_eda.csv]
  --out_train=<path> Path for processed training CSV [default: ../data/processed/billboard_model_training.csv]
  --out_test=<path> Path for processed testing CSV [default: ../data/processed/billboard_model_testing.csv]
  --out_full=<path> Path for full processed CSV [default: ../data/processed/billboard_model_selected.csv]
"

opt <- docopt(doc)

in_billboard <- opt$in_billboard
in_topics <- opt$in_topics
out_train <- opt$out_train
out_test <- opt$out_test
out_full <- opt$out_full
out_eda <- opt$out_eda

dir.create(dirname(out_train), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(out_test), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(out_full), recursive = TRUE, showWarnings = FALSE)
dir.create(dirname(out_eda), recursive = TRUE, showWarnings = FALSE)

set.seed(123)


# Use utility function for cleaning and joining
billboard_clean <- clean_and_join_billboard(in_billboard, in_topics)


# Save the EDA dataset
write_csv(billboard_clean, out_eda)
message("Saved EDA dataset:", out_eda)

# Split first so all preprocessing steps can be learned from training data only.
billboard_split <- initial_split(billboard_clean, prop = 0.7)
billboard_train_raw <- training(billboard_split)
billboard_test_raw <- testing(billboard_split)


# Feature selection is driven by domain knowledge and applied after the split to
# avoid leaking information from the test set into the model-building pipeline.
columns_to_drop <- c(
  # Demographic identity
  "artist_male","artist_white", "artist_black", "songwriter_male", "songwriter_white", "producer_male", "producer_white", 
  # Artist structure
  "artist_structure", "group_named_after_non_lead_singer",
  # Songwriter/producer overlaps
  "artist_is_only_songwriter", "artist_is_only_producer", "songwriter_is_a_producer",
  # Timing
  "instrumental_length_sec",  "intro_length_sec",
  # Lyrical content 
  "lyrical_topic","lyrical_narrative",
  # External content
  "written_for_a_play", "written_for_a_film", "written_for_a_t_v_show", "eurovision_entry", "topped_the_charts_by_multiple_artist", "associated_with_dance")

preprocessed <- preprocess_billboard_split(
  billboard_train_raw,
  billboard_test_raw,
  columns_to_drop
)

train_data <- preprocessed$train
test_data <- preprocessed$test
billboard_model_selected <- preprocessed$full

# Save output:
for (p in c(dirname(out_full), dirname(out_train), dirname(out_test))) {
  dir.create(p, recursive = TRUE, showWarnings = FALSE)
}

write_csv(billboard_model_selected, out_full)
write_csv(train_data, out_train)
write_csv(test_data, out_test)

message("Saved full processed data to:", out_full)
message("Saved training data to:", out_train)
message("Saved testing data to:", out_test)