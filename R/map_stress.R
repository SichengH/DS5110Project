##############################################################################
## Stress Test leaflet map, to see how many points it can handle.
## Finding: 500k points plotted in under 15sec, but once the map loads,
##    scrolling and dragging do not drop performance. 
##############################################################################

library(tidyverse)
library(leaflet)
library(shiny)

ui <- fluidPage(
  leafletOutput("clusterMap")
)

server <- function(input, output, session) {
  
  output$clusterMap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = ndata, clusterOptions = markerClusterOptions())
  })
}

# nrow(data) -> 110395
data <- read_csv("./data/fixed_loc.csv")
ndata <- data %>% select(-PID)

# 110k -> 4s
shinyApp(ui, server)

# generate another 100k points randomly
lat <- sample(42240:42390, 100000, replace = TRUE) / 1000
lon <- sample(-71180:-71000, 100000, replace = TRUE) / 1000

# create temp tibble
tdf <- tibble(LAT = lat, LON = lon)

# bind both
ndata <- data %>% bind_rows(tdf)

# 200k -> 7s
shinyApp(ui, server)

# generate another 300k points randomly
lat <- sample(42240:42390, 300000, replace = TRUE) / 1000
lon <- sample(-71180:-71000, 300000, replace = TRUE) / 1000

# create temp tibble
tdf <- tibble(LAT = lat, LON = lon)

# bind both
ndata <- ndata %>% bind_rows(tdf)

# nrow(ndata) = 510395
# 500k -> 14s
shinyApp(ui, server)
