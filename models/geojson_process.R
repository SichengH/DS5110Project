## Processing model_data.csv for inclusion into GeoJSON file

library(dplyr)
library(readr)


fpath <- "models/model_data.csv"
df <- read_csv(fpath)

current <- "app/data.coord.rda"
load(current)

regions <- read_tsv("data/MA-Regions.csv", col_names = FALSE)

int_score_df <- df %>% select(PID, INT_SCORE) %>% group_by(PID) %>%
    summarize(
        mean_int_score = mean(INT_SCORE, na.rm = TRUE),
        sd_int_score = sd(INT_SCORE, na.rm = TRUE),
        pid_count = n()
    ) %>%
    arrange(desc(sd_int_score))


region_score <- df %>% select(regions, INT_SCORE) %>%
    group_by(regions) %>%
    summarize(
        mean_int_score = mean(INT_SCORE, na.rm = TRUE),
        sd_int_score = sd(INT_SCORE, na.rm = TRUE),
        max_int_score = max(INT_SCORE, na.rm = TRUE),
        min_int_score = min(INT_SCORE, na.rm = TRUE),
        property_count = n()
    )

regionsdf <- left_join(x= regions, y = region_score,
                       by = c("X4" = "regions"))

write_tsv(regionsdf, "data/regionsdf.csv")


