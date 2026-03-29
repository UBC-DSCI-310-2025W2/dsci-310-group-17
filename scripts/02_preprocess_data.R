library(docopt)
library(tidyverse)
library(caret)
library(readr)
library(tidymodels)
source(here::here("R/preprocess_utils.R"))

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


# Log transform using utility function
billboard_log_transformed <- log_transform_columns(
  billboard_clean,
  c("weeks_at_number_one", "acousticness")
)


# One-hot encoding using utility function
billboard_genres_wide <- one_hot_encode_genre(billboard_log_transformed)


# Simplify key using utility function
billboard_simplify_key <- simplify_key_column(billboard_genres_wide)

billboard_model_final <- billboard_simplify_key |> 
  select(-weeks_at_number_one, -acousticness)

# Feature selection 
## Manual drop redundant columns
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

billboard_manual_dropped <- billboard_model_final |>
  select(-all_of(columns_to_drop))

## Drop columns with nearly 0 variance 
nzv_cols <- nearZeroVar(billboard_manual_dropped, 
                        freqCut = 95/5,  
                        uniqueCut = 5,
                        names = TRUE)

billboard_model_selected <- billboard_manual_dropped |>
  select(-all_of(nzv_cols))

# Train/test split
billboard_split <- initial_split(billboard_model_selected, prop = 0.7)
train_data <- training(billboard_split)
test_data <- testing(billboard_split)

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