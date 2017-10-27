################################################################
## Property value over time 2014-2017
################################################################

library(dplyr)
library(ggplot2)
library(maps)
library(readr)
library(scales)


# Read data (Part A)
fpath <- paste0("../homework/hw2/hw2-data/part-a/",
                "property-assessment-fy-audited.csv")
bospropw <- read_csv(fpath)

# Get LU labels (Part A)
LU = c("A","AH","C","CC","CD","CL","CM","CP","E","EA",
       "I","R1","R2","R3","R4","RC","RL")
LU_label = c("Residential 7 or more units",
             "Agricultural/Horticultural",
             "Commerical",
             "Commerical Condominium",
             "Residential condominium unit",
             "Commerical land",
             "Condominium main",
             "Condo parking",
             "Tax-exempt",
             "Tax-exempt (121A)",
             "Industrial",
             "Residential 1-family",
             "Residential 2-family",
             "Residential 3-family",
             "Residential 4 or more family",
             "Mixed use (res. and comm.)",
             "Residential land")
LU_labels <- tibble(LU, LU_label)

# map base layer

# Location vs. gross tax (make a map)
mass <- map_data("state") %>%
    filter(
        region %in% c("massachusetts"))

# Prepare a map of Massachusetts
base <- ggplot() +
    geom_polygon(data = mass, aes(x = long, y = lat, group = group),
                 fill = "white", colour = "black")


#######################################################
## Reconfigure data frame to assess profitability
## 
## Want the average change in profitability across all
## available years. 
## 
#######################################################

# filter out by year keeping only PID and GROSS_TAX
bospropw2014 <- bospropw %>%
    filter(year == 2014) %>%
    select(PID, GROSS_TAX)
bospropw2015 <- bospropw %>%
    filter(year == 2015) %>%
    select(PID, GROSS_TAX)
bospropw2016 <- bospropw %>%
    filter(year == 2016) %>%
    select(PID, GROSS_TAX)
bospropw2017 <- bospropw %>%
    filter(year == 2017) %>%
    select(PID, GROSS_TAX)

# make new base dataframe
bospropc <- bospropw %>%
    select(PID, LATITUDE, LONGITUDE, OWNER, LU) %>%
    group_by(PID, LATITUDE, LONGITUDE)

# add 2014
bospropc <- left_join(x = bospropc,
                      y = bospropw2014,
                      by = "PID") %>%
    ungroup() %>%
    transmute(PID = PID,
              LATITUDE = LATITUDE,
              LONGITUDE = LONGITUDE,
              LU = LU,
              OWNER = OWNER,
              GROSS_TAX2014 = GROSS_TAX)

# add 2017
bospropc <- left_join(x = bospropc,
                      y = bospropw2017,
                      by = "PID") %>%
    ungroup() %>%
    transmute(PID = PID,
              LATITUDE = LATITUDE,
              LONGITUDE = LONGITUDE,
              LU = LU,
              OWNER = OWNER,
              GROSS_TAX2014 = GROSS_TAX2014,
              GROSS_TAX2017 = GROSS_TAX)


# Compute proportion of property assessment increases.
bospropd <- bospropc %>%
    mutate(
        val_change = ifelse(GROSS_TAX2017 == 0 | GROSS_TAX2014 == 0,
                            0, GROSS_TAX2017 - GROSS_TAX2014),
        val_prop = ifelse(GROSS_TAX2017 == 0, 0,
                          val_change / GROSS_TAX2014)
    )

bospropd$val_factors <- NA
x25 <- quantile(bospropd$val_prop, 0.25, na.rm = TRUE)
x50 <- median(bospropd$val_prop, na.rm = TRUE)
x75 <- quantile(bospropd$val_prop, 0.75, na.rm = TRUE)
x100 <- Inf

bospropd$val_factors[(bospropd$val_prop < 0)] <- "negative"
bospropd$val_factors[(bospropd$val_prop == 0)] <- "not taxed"
bospropd$val_factors[(bospropd$val_prop > 0 &
                      bospropd$val_prop <= x25)] <- "0_to_quantile_25"
bospropd$val_factors[(bospropd$val_prop > x25 &
                      bospropd$val_prop <= x50)] <- "quantile_25_50"
bospropd$val_factors[(bospropd$val_prop > x50 &
                      bospropd$val_prop <= x75)] <- "quantile_50_75"
bospropd$val_factors[(bospropd$val_prop > x75 &
                      bospropd$val_prop <= x100)] <- "quantile_75_100"

bospropd$val_factors <- factor(bospropd$val_factors,
                               levels = c("negative", "not taxed",
                                          "0_to_quantile_25",
                                          "quantile_25_50",
                                          "quantile_50_75",
                                          "quantile_75_100"))

# Proportion of change in property assessment by land use
bospropd <- left_join(x = bospropd, y = LU_labels, by = "LU")


# Map profitability throughout Boston. Include land use.
m3 <- base +
    geom_point(data = bospropd,
               aes(x = LONGITUDE, y = LATITUDE,
                   color = val_factors, alpha = 0.01), size = 0.25) +
    coord_fixed(xlim = c(-70.9, -71.25), ylim = c(42.22, 42.4),
                ratio = 1.3)
style <- m3 +
    scale_colour_brewer(palette = "Spectral") +
    guides(
        alpha = "none",
        colour = guide_legend(override.aes = list(size=2))) +
    labs(title = "Change in Property Assessment Value 2014-2017",
        x = "Longitude",
        y = "Latitude",
        color = "Value Change") +
    theme(legend.position="bottom",
          plot.title = element_text(hjust = 0.5))

ggsave("property_delta2014-2017.png", style)



