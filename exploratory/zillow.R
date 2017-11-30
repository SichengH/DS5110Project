library(readr)
library(dplyr)
library(leaflet)


census <- read_csv("data/coordinates.csv") %>% select(-X1)


# leaflet tutorial

m <- leaflet(census) %>%
  setView(-71.0589, 42.3601, 13) %>%
  addProviderTiles("MapBox", options = providerTileOptions(
    id = "mapbox.light",
    accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')))


m %>% addPolygons()
