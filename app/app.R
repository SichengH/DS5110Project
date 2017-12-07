library(shinydashboard)
library(data.table)
library(dplyr)
library(geojsonio)
library(leaflet)
library(purrr)
library(readr)
library(shiny)
library(highcharter)
library(DT)
library(htmltools)
# read geojson file, used to plot ploygons for zipcodes
#setwd("/Users/haosicheng/Documents/GitHub/DS5110Project/")
#boston <- geojson_read("sumedh-boston.geojson", what="sp")

boston <- geojson_read("zillow-conversion-boston2.geojson", what="sp")


# sample data for markers


load("data.coord.rda")


sample <- data.coord %>% group_by(LAT,LON, YR_BUILT) %>% count()

#sample <- sample.data%>% group_by(Latitude,Longitude) %>% count()
 

ui <- dashboardPage(
  dashboardHeader(title = "Boston Property Assessment Visualization",
                  titleWidth = 500),
  dashboardSidebar(width = 300,
                   sliderInput("input1", "Year Build",min = 1850,max = 2017,value = c(1850,2017)),
                   sliderInput("input2", "Year Remodeled",min = 1950,max = 2017,value = c(1950,2017)),
                   selectInput('input3', 'Bathroom Style', choices = data.coord$BTH_STYLE,multiple = TRUE),
                   selectInput('input4', 'Kitchen Style', choices = data.coord$KIT_STYLE,multiple = TRUE),
                   selectInput('input5', 'Interior Condition', choices = data.coord$INT_CND,multiple = TRUE),
                   selectInput('input6', 'Interior Finish', choices = data.coord$INT_CND,multiple = TRUE),
                   selectInput('input7', 'View', choices = data.coord$VIEW,multiple = TRUE),
                   # textOutput only to debug, remove in final build
                   textOutput("debug")),
  dashboardBody(
    # leafletOutput, shows map
    leafletOutput("boston_map", height = 600))
)

server <- function(input, output, session) { 
  
    bins <- c(0, 700, 750, 800, 850, 900, 950, 1000, Inf)
    pal <- colorBin("Spectral",
                    domain = as.numeric(
                        as.character(boston$mean_interior_score))^(5/2),
                    bins = bins)

  labels <- sprintf(
      paste("<strong>%s</strong> <br>",
            "Interior Mean Score: %g <br>",
            "Interior Max Score: %g <br>",
            "Interior Min Score: %g <br>",
            "Interior SD Score: %g <br>",
            "Neighborhood Property Count: %g"),
    boston$neighborhood,
    round(as.numeric(as.character(boston$mean_interior_score))^(5/2),0),
    round(as.numeric(as.character(boston$max_int_score))^(5/2),0),
    round(as.numeric(as.character(boston$min_int_score))^(5/2),0),
    round(as.numeric(as.character(boston$sd_interior_score))^(5/2),0),
    as.numeric(as.character(boston$region_property_count))
  ) %>% lapply(htmltools::HTML)

    value <- reactiveVal(0)

    observeEvent(input$input1, {
        newValue <- input$input1
        value(newValue)
    })
  
  # maps tab
  # Reference: https://rstudio.github.io/leaflet/choropleths.html
  output$boston_map <- renderLeaflet({
    leaflet(boston) %>%
        setView(-71.0589, 42.3, 11) %>%
        addProviderTiles(providers$CartoDB.Positron) %>%
        addPolygons(
            fillColor = ~pal(as.numeric(
                           as.character(mean_interior_score))^(5/2)),
            weight = 2,
            opacity = 1,
            color = "white",
            dashArray = "3",
            fillOpacity = 0.5,
            group = "polygon",
            highlight = highlightOptions(
                weight = 5,
                color = "#666",
                dashArray = "",
                fillOpacity = 1,
                bringToFront = TRUE),
            label = labels,
            labelOptions = labelOptions(
                style = list("font-weight" = "normal",
                             padding = "3px 8px"),
                textsize = "15px",
                direction = "auto")) %>%

      # NOTE!!
      # legend cant be added to any group, causes error
      # possible workaround here: 
      #    https://github.com/rstudio/leaflet/issues/215
    addLegend(pal = pal, values = ~mean_interior_score, opacity = 0.7,
              title = NULL,
              position = "bottomright") %>%


     # markers group, shows borders for zipcode
     #   but does not shade. Displays marker cluster on map
     # Use as lower layer, for zoom >= 12
    addPolygons(weight = 2,
                stroke = TRUE,
                color = "orange",
                dashArray = "5",
                fillOpacity = 0.0,
                group = "markers") %>%
    addMarkers(data = sample %>% filter(YR_BUILT > value()[1]), 
               clusterOptions = markerClusterOptions(),
               group = "markers", popup = paste0("<h1>hello</h1><br>", value()[1], " ", value()[2], "<br>", sample$YR_BUILT))
  })
  
  # create reactive zoom function
  zoom <- reactive({ input$boston_map_zoom })
  
  # observe zoom level change
  observe({
    req(zoom())
    
    if (zoom() < 12) {
      hide <- "markers"
      show <- "polygon"
    } else {
      hide <- "polygon"
      show <- "markers"
    }
    
    leafletProxy("boston_map") %>%
      hideGroup(hide) %>%
      showGroup(show)
    
    output$debug <- renderText({ zoom() })
  })
}

shinyApp(ui, server)
