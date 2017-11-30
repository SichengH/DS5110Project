## Getting ploygons figured out

library(dplyr)
library(ggplot2)
library(maps)
library(readr)
library(scales)
library(geojsonio)

library(leaflet)

library(rgdal)
library(sp)
library(maps)
library(ggmap)
library(maptools)

# 42.3601° N, 71.0589° W Boston

states <- geojson_read("data/us-boston.geojson", what="sp")

plot(states)

mapImage <- ggmap(get_googlemap(c(lon = -71.0589, lat = 42.3601),
                                scale = 1, zoom = 11), extent = "normal")



states_df <- fortify(states)


mapImage +
    geom_polygon(aes(long, lat, group = group), data = states_df, 
                 colour = "green", alpha = 0.25)


#####################
## Leaflet Didn't work here
####################
library(leaflet)
library(sp)

# data
data <- data.frame(group = c("p_pladser.1", "p_pladser.1", "p_pladser.2","p_pladser.2", "p_pladser.3", "p_pladser.3", "p_pladser.4", "p_pladser.4","p_pladser.6", "p_pladser.6", "p_pladser.6"), lat = c(55.67179, 55.67171, 55.67143, 55.67135, 55.67110, 55.67099, 55.67173, 55.67158, 55.67155, 55.67154, 55.67145), long = c(12.55825, 12.55853, 12.55956, 12.55984, 12.56041, 12.56082, 12.55819, 12.55873, 12.55913, 12.55914, 12.55946))

data <- states_df

# turn into SpatialLines
split_data = lapply(unique(data$group), function(x) {
  df = as.matrix(data[data$group == x, c("long", "lat")])
  lns = Lines(Line(df), ID = x)
  return(lns)
})

data_lines = SpatialLines(split_data)

leaflet(data_lines) %>%
  addTiles() %>%
  addPolylines()






m <- leaflet(states) %>%
  setView(-71.0589, 42.3601, 13) %>%
  addProviderTiles("MapBox", options = providerTileOptions(
    id = "mapbox.light",
    accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN')))


m %>% addPolygons()



##################################################
## Trying census blocks with leaflet
##################################################

library(rgdal)
library(tidyverse)
library(tidycensus)
library(viridis)
library(sf)
library(maps)
library(ggplot2)
options(tigris_use_cache = TRUE)


census_api_key("67129c2afe97f39faba78a95bbde324f6639a265",
               install=TRUE)


suffolk <- get_acs(state = "MA", county = "Suffolk", geography = "tract", 
                  variables = "B19013_001", geometry = TRUE)


suffolk %>%
  ggplot(aes(fill = estimate, color = estimate)) + 
  geom_sf() + 
  coord_sf(crs = 26911) + 
  scale_fill_viridis(option = "magma") + 
  scale_color_viridis(option = "magma")







# dsn is the folder the shape files are in. layer is the name of the file.
boston <- readOGR(dsn="data/boston2010",
                layer="Census2010_Tracts")


plot(boston)

plot(boston, border = "red")

spplot(boston)



leaflet(towns) %>%
    addPolygons()




