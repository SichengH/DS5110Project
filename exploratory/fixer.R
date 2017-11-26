library(tidyverse)

bad_addr <- read_csv("./data/hbad_addr.csv")
boston <- read_csv("./data/ma/city_of_boston.csv")

bad_addr <- bad_addr %>% ungroup()

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

# lowercase address and fix zipcode
bad_addr <- bad_addr %>%
  mutate(ST_NAME = tolower(ST_NAME),
         ST_NAME_SUF = tolower(ST_NAME_SUF), 
         ZIPCODE = str_extract(ZIPCODE, "\\d+"))

boston2 <- boston
bad_addr2 <- bad_addr

boston2h <- boston2 %>% 
  filter(str_detect(NUMBER, "\\-"))

# 
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



