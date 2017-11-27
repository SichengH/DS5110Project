########################################################################
## Need coordinates for PID which are missing lat/lng.
##
## Address data provided by https://openaddresses.io/
## Parsing address data so it can be joined to BOS data.
#######################################################################

library(tidyverse)

boston <- read_csv("./data/ma/city_of_boston.csv")

# spliting st address and lowercase
boston <- boston %>%
  rowwise() %>%
  mutate(LSUF = length(strsplit(STREET, "\\s+")[[1]]),
         RSUF = LSUF - 1,
         ST_NAME = tolower(
           paste(
             strsplit(STREET, "\\s+")[[1]][1:RSUF]
             , collapse = " ")
           ),
         SUF = tolower(strsplit(STREET, "\\s+")[[1]][LSUF])) %>% 
  select(-LSUF, -RSUF)

boston2 <- boston
bad_addr2 <- bad_addr

boston2h <- boston2 %>% 
  filter(str_detect(NUMBER, "\\-"))

boston2g <- boston2 %>% 
  filter(!str_detect(NUMBER, "\\-"))

# range
boston3 <- boston2h %>% 
  rowwise() %>%
  mutate(
    NGRP = strsplit(NUMBER, "\\-")[1],
    NL = tryCatch({
        list(as.numeric(str_extract(NGRP[[1]], "\\d+")
                        ):as.numeric(str_extract(NGRP[[length(NGRP)]], "\\d+")))
    }, warning = function(w) {
      print(c("warning", NGRP))
      NA
    }, error = function(e){
      print(c("error", NGRP))
      list(as.numeric(NGRP[!is.na(str_extract(NGRP, "\\d+"))]))
    })) %>%
  unnest(NL)

boston4 <- bind_rows(boston3, boston2g) %>%
  mutate( NUMBER = ifelse(is.na(NL), NUMBER, NL) )

boston4_dedupe <- boston4 %>%
  group_by(NUMBER, ST_NAME, SUF, POSTCODE) %>%
  summarize(
    HASH_CONCAT = paste(HASH, collapse =",")
  ) %>%
  ungroup() %>%
  rowwise() %>%
  mutate(
    HASH_BACK = strsplit(HASH_CONCAT, ",")[[1]][1]
  )

#write_csv(boston4, "./data/boston4.csv")
#write_csv(boston4_dedupe, "./data/boston4_dedupe.csv")

#boston4 <- read_csv("./data/boston4.csv")
#boston4_dedupe <- read_csv("./data/boston4_dedupe.csv")

# do not re run!!!!!!
#boston5 <- inner_join(boston4, boston4_dedupe, by = c("HASH" = "HASH_BACK"))
# boston4 <- boston4 %>% filter( HASH %in% boston4_dedupe$HASH_BACK )
#write_csv(boston4, "./data/boston4_hacked.csv")
boston4 <- read_csv("./data/boston4_hacked.csv") %>% 
  select(LON, LAT, NUMBER, POSTCODE, HASH, ST_NAME, SUF)

###################
## bad_addr
###################

bad_addr <- read_csv("./data/hbad_addr.csv")
bad_addr <- bad_addr %>% ungroup()

# lowercase address and fix zipcode
bad_addr <- bad_addr %>%
  mutate(ST_NAME = tolower(ST_NAME),
         ST_NAME_SUF = tolower(ST_NAME_SUF), 
         ZIPCODE = str_extract(ZIPCODE, "\\d+"))

# range 
bad_addr2 <- bad_addr %>% 
  rowwise() %>%
  filter(str_detect(ST_NUM, "\\d+")) %>%
  mutate(
    NUMBER = str_replace(ST_NUM, "\\s+", ""), 
    NGRP = strsplit(NUMBER, "\\-")[1],
    NL = tryCatch({
      list(as.numeric(str_extract(NGRP[[1]], "\\d+")
      ):as.numeric(str_extract(NGRP[[length(NGRP)]], "\\d+")))
    }, warning = function(w) {
      print(c("warning", NGRP))
      NA
    }, error = function(e){
      print(c("error", NGRP))
      list(as.numeric(NGRP[!is.na(str_extract(NGRP, "\\d+"))]))
    })) %>%
  unnest(NL)

bad_addr2 <- bad_addr2 %>%
  mutate(ST_NUM = ifelse(str_detect(ST_NUM, "\\-"), NL, ST_NUM))

bad_addr2_dedupe <- bad_addr2 %>%
  group_by(ST_NUM, ST_NAME, ST_NAME_SUF, ZIPCODE) %>%
  summarize(
    PID_CONCAT = paste(PID, collapse =",")
  ) 

##############################################
# the real shit begins here! turn back now!
# 
# Separate into two buckets based on complete cases.
# Certain addresses do not include a st number but still
# need to be assigned coordinates.
##############################################

# complete cases bucket
bad2_complete <- bad_addr2_dedupe[complete.cases(bad_addr2_dedupe),] %>%
  mutate(
    addr_key = paste(ST_NUM, ST_NAME, ZIPCODE)
  )

boston4_complete <- boston4[complete.cases(boston4), ] %>%
  mutate(
    addr_key = paste(NUMBER,  ST_NAME, POSTCODE)
  )


bmatch <- inner_join(x = bad2_complete, y = boston4_complete,
                     by = "addr_key")

# expand bmatch by PID
pid_expand <- bmatch %>%
  mutate(
    pide = strsplit(PID_CONCAT, ",")[1]
  ) %>%
  unnest(pide)


# just check
length(intersect(pid_expand$pide, bad_addr$PID))/length(unique(bad_addr$PID))


# not complete cases
bad2_not_complete <- bad_addr2_dedupe[!complete.cases(bad_addr2_dedupe),] %>%
  ungroup() 

total_bad2_not_complete <- nrow(bad2_not_complete)

bad2_not_complete_subset <- bad2_not_complete %>% 
    select(ST_NAME, ZIPCODE, PID_CONCAT)

bad2_not_complete_subset <- bad2_not_complete_subset[
  complete.cases(bad2_not_complete_subset),]

# check percentage 
nrow(bad2_not_complete_subset)/ total_bad2_not_complete

# fixing for not complete
bader2 <- bad2_not_complete_subset %>%
  mutate(addr_key = paste(ST_NAME, ZIPCODE))

boston4_for_bader2 <- boston4[complete.cases(boston4), ] %>%
  mutate(
    addr_key = paste(ST_NAME, POSTCODE)
  )

bmatch_bad <- inner_join(x = bader2, y = boston4_for_bader2,
                     by = "addr_key")
# ungrouping
pid_expand_not_complete <- bmatch_bad %>%
  rowwise() %>%
  mutate(
    pide = strsplit(PID_CONCAT, ",")[1]
  ) %>%
  unnest(pide)

length(intersect(pid_expand_not_complete$pide, bad_addr$PID))/
  length(unique(bad_addr$PID))
