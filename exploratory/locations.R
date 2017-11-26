# Sorting out locations

library(dplyr)
library(readr)
library(stringr)


houses <- read_csv("../data/Combined_data.csv")


addr <- houses %>%
    group_by(PID, ST_NUM, ST_NAME, ST_NAME_SUF, UNIT_NUM,
             ZIPCODE, Latitude, Longitude) %>%
    count()

bad_addr <- addr %>%
    filter( is.na(Latitude) | is.na(Longitude) )


hbad_addr <- bad_addr %>%
    rowwise() %>%
    mutate(
        ST_NUM = ifelse(ST_NUM < 1 | is.na(ST_NUM), "", ST_NUM),
        ST_NAME = ifelse(is.na(ST_NAME), "", ST_NAME),
        ST_NAME_SUF = ifelse(is.na(ST_NAME_SUF), "", ST_NAME_SUF),
        ZIPCODE = ifelse(is.na(ZIPCODE), "", str_extract(ZIPCODE, "\\d+"))
    )

write_csv(hbad_addr, "./data/hbad_addr.csv")
