library(docopt)
library(tidyverse)
library(caret)
library(readr)
library(tidymodels)

doc <- "
Usage:
  02_preprocess_data.R [--in_billboard=<path>] [--in_topics=<path>] 
                       [--out_train=<path>] [--out_test=<path>] [--out_full=<path>] [--out_eda=<path>]
                       
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

# Read data 
billboard <- read_csv(in_billboard, show_col_types = FALSE)
topics <- read_csv(in_topics, show_col_types = FALSE)

# Join the two datasets
billboard_joined <- billboard |>
  left_join(topics, by = c("lyrical_topic" = "lyrical_topics"))

# Data wrangling
billboard_clean <- billboard_joined |>
  # Remove identifier columns
  select(-c(song, artist, date)) |>
  # Remove data-leakage column
  select(-non_consecutive) |>
  # Remove individual judge scores to avoid multicollinearity
  select(-c(rating_1, rating_2, rating_3)) |>
  # Remove free-text columns
  select(-c(
    lyrics,
    u_s_artwork,
    sound_effects,
    song_structure,
    featured_artists,
    songwriters,
    songwriters_w_o_interpolation_sample_credits,
    producers,
    double_a_side,
    talent_contestant
  )) |>
  # Remove high-cardinality columns
  select(-c(label, parent_label, artist_place_of_origin)) |>
  # Remove redundant columns and discogs_genre
  select(-c(cdr_style, discogs_style, keys, discogs_genre)) |>
  # Remove ambiguous columns
  select(-c(
    featured_in_a_then_contemporary_play,
    featured_in_a_then_contemporary_film,
    featured_in_a_then_contemporary_t_v_show
  )) |>
  # Convert remaining character columns to factors
  mutate(across(where(is.character), as.factor)) |>
  drop_na()

# Save the EDA dataset
write_csv(billboard_clean, out_eda)
message("Saved EDA dataset:", out_eda)

# Log transform
billboard_log_transformed <- billboard_clean |> 
  mutate(
    log_weeks_at_number_one = log1p(weeks_at_number_one),
    log_acousticness = log1p(acousticness)
  )

# One-hot encoding 
billboard_genres <- billboard_log_transformed |> 
  separate_rows(cdr_genre, sep = ";") |> 
  mutate (cdr_genre = str_trim(cdr_genre))

billboard_genres_wide <- billboard_genres |> 
  mutate(value = 1) |> 
  pivot_wider(
    names_from = cdr_genre, 
    values_from = value,
    values_fill = 0
  )

# Simplify key
billboard_simplify_key <- billboard_genres_wide |> 
  mutate(
    simplified_key = case_when(
      simplified_key == "Multiple Keys"          ~ "Multiple Keys",
      str_ends(simplified_key, "m")              ~ "Minor",  
      TRUE                                        ~ "Major"  
    ) |> as.factor()
  )

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