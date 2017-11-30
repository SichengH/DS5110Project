library(shinydashboard)
library(dplyr)
library(dbplyr)
library(geojsonio)
library(leaflet)
library(purrr)
library(readr)
library(shiny)
library(highcharter)
library(DT)
library(htmltools)
library(nycflights13)

# Use purrr's split() and map() function to create the list
# needed to display the name of the airline but pass its
# Carrier code as the value

#houses <- read_csv("data/Combined_data.csv")

airline_list <- airlines %>%
  collect()  %>%
  split(.$name) %>%
    map(~.$carrier)

#combined <- read_csv("data/Combined_data.csv")
#states <- geojson_read("data/us-states.geojson", what="sp")
states <- geojson_read("data/sumedh-boston.geojson", what="sp")



r_colors <- rgb(t(col2rgb(colors()) / 255))
names(r_colors) <- colors()


ui <- dashboardPage(
  dashboardHeader(title = "Boston Property Assessment Visualization",
                  titleWidth = 500),
  dashboardSidebar(width = 300,
    selectInput(
      inputId = "airline",
      label = "Airline:", 
      choices = airline_list, 
      selectize = FALSE),
    sidebarMenu(
      selectInput(
        "month",
        "Month:", 
        list(
          "All Year" = 99,
          "January" = 1,
          "February" = 2,
          "March" = 3,
          "April" = 4,
          "May" = 5,
          "June" = 6,
          "July" = 7,
          "August" = 8,
          "September" = 9,
          "October" = 10,
          "November" = 11,
          "December" = 12
        ) , 
        selected =  "All Year", 
        selectize = FALSE),
      actionLink("remove", "Remove detail tabs")
    )
  ),
  dashboardBody(
      


      leafletOutput("mymap", height = 600 ))
)




server <- function(input, output, session) { 
  
  tab_list <- NULL
  
  
  # Preparing the data by pre-joining flights to other
  # tables and doing some name clean-up
  db_flights <- flights %>%
    left_join(airlines, by = "carrier") %>%
    rename(airline = name) %>%
    left_join(airports, by = c("origin" = "faa")) %>%
    rename(origin_name = name) %>%
    select(-lat, -lon, -alt, -tz, -dst) %>%
    left_join(airports, by = c("dest" = "faa")) %>%
    rename(dest_name = name) 
  
  output$monthly <- renderText({
    if(input$month == "99")"Click on a month in the plot to see the daily counts"
  })
  
  output$total_flights <- renderValueBox({
    # The following code runs inside the database
    result <- db_flights %>%
      filter(carrier == input$airline)
    
    if(input$month != 99) result <- filter(result, month == input$month)
    
    result <- result %>%
      tally() %>%
      pull() %>% 
      as.integer()
    
    valueBox(value = prettyNum(result, big.mark = ","),
             subtitle = "Number of Flights")
  })
  
  
  output$per_day <- renderValueBox({
    
    # The following code runs inside the database
    result <- db_flights %>%
      filter(carrier == input$airline)
    
    if(input$month != 99) result <- filter(result, month == input$month)
    result <- result %>%
      group_by(day, month) %>%
      tally() %>%
      summarise(avg = mean(n)) %>%
      pull()
    
    valueBox(prettyNum(result, big.mark = ","),
             subtitle = "Average Flights",
             color = "blue")
  })
  
  
  
  output$percent_delayed <- renderValueBox({
    
    # The following code runs inside the database
    result <- db_flights %>%
      filter(carrier == input$airline)
    
    if(input$month != 99) result <- filter(result, month == input$month)
    result <- result %>%
      filter(!is.na(dep_delay)) %>%
      mutate(delayed = ifelse(dep_delay >= 15, 1, 0)) %>%
      summarise(delays = sum(delayed),
                total = n()) %>%
      mutate(percent = delays / total) %>%
      pull()
    
    valueBox(paste0(round(result * 100), "%"),
             subtitle = "Flights delayed",
             color = "teal")
  })
  
  # Events in Highcharts can be tracked using a JavaScript. For data 
  # points in a plot, the event.point.category returns the value that is 
  # used for an additional filter, in this case the month that was 
  # clicked on.  A paired observeEvent() command is activated when
  # this java script is executed
    js_click_line <- JS(paste0("function(event) {Shiny.onInputChange(",
                               "'line_clicked', [event.point.category])",
                               ";}"))
  
  output$group_totals <- renderHighchart({
    
    if(input$month != 99) {
      result <- db_flights %>%
        filter(month == input$month,
               carrier == input$airline) %>%
        group_by(day) %>%
        tally() %>%
        collect()
      group_name <- "Daily"
    } else {
      result <- db_flights %>%
        filter(carrier == input$airline) %>%
        group_by(month) %>%
        tally() %>%
        collect()    
      group_name <- "Monthly"
    } 
    
    highchart() %>%
      hc_add_series(
        data = result$n, 
        type = "line",
        name = paste(group_name, " total flights"),
        events = list(click = js_click_line)) 
    
    
  })
  
  # Tracks the JavaScript event created by `js_click_line`
  observeEvent(input$line_clicked != "",
               if(input$month == 99)
                   updateSelectInput(session, "month",
                                     selected = input$line_clicked),
               ignoreInit = TRUE)
  
    js_bar_clicked <- JS(paste0("function(event) {Shiny.onInputChange(",
                                "'bar_clicked', [event.point.category]",
                                ");}"))
  
  output$top_airports <- renderHighchart({
    # The following code runs inside the database
    result <- db_flights %>%
      filter(carrier == input$airline) 
    
    if(input$month != 99) result <- filter(result, month == input$month) 
    
    result <- result %>%
      group_by(dest_name) %>%
      tally() %>%
      arrange(desc(n)) %>%
      collect() %>%
      head(10)
    
    highchart() %>%
      hc_add_series(
        data = result$n, 
        type = "bar",
        name = paste("No. of Flights"),
        events = list(click = js_bar_clicked)) %>%
      hc_xAxis(
        categories = result$dest_name,
        tickmarkPlacement="on")
    
    
  })
  
  observeEvent(input$bar_clicked,
               {
                 airport <- input$bar_clicked[1]
                 tab_title <- paste(input$airline, 
                                    "-", airport , 
                                    if(input$month != 99) {
                                        paste("-" ,
                                              month.name[as.integer(
                                                  input$month)])
                                    })
                 
                 if(tab_title %in% tab_list == FALSE){
                   details <- db_flights %>%
                     filter(dest_name == airport,
                            carrier == input$airline)
                   
                   if(input$month != 99) {
                       details <- filter(details, month == input$month)
                   }
                   
                   details <- details %>%
                     head(100) %>% 
                     select(month,
                            day,
                            flight,
                            tailnum,
                            dep_time,
                            arr_time,
                            dest_name,
                            distance) %>%
                     collect() %>%
                     mutate(month = month.name[as.integer(month)])
                   
                   
                   appendTab(inputId = "tabs",
                             tabPanel(
                               tab_title,
                               DT::renderDataTable(details)
                             ))
                   
                   tab_list <<- c(tab_list, tab_title)
                   
                 }
                 
                 updateTabsetPanel(session, "tabs", selected = tab_title)
                 
               })
  
  observeEvent(input$remove,{
    # Use purrr's walk command to cycle through each
    # panel tabs and remove them
    tab_list %>%
      walk(~removeTab("tabs", .x))
    tab_list <<- NULL
  })


    bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
    pal <- colorBin("YlOrRd", domain = states$density, bins = bins)

    labels <- sprintf(
        "<strong>%s</strong><br/>%g random int / mi<sup>2</sup>",
        states$group, states$density
    ) %>% lapply(htmltools::HTML)

  # maps tab
  # Reference: https://rstudio.github.io/leaflet/choropleths.html
  output$mymap <- renderLeaflet({
      leaflet(states) %>%
      setView(-71.0589, 42.3, 11) %>%
      addProviderTiles("MapBox", options = providerTileOptions(
          id = "mapbox.light",
          accessToken = Sys.getenv('MAPBOX_ACCESS_TOKEN'))) %>%
      addPolygons(
          fillColor = ~pal(density),
          weight = 2,
          opacity = 1,
          color = "white",
          dashArray = "3",
          fillOpacity = 0.7,
          highlight = highlightOptions(
              weight = 5,
              color = "#666",
              dashArray = "",
              fillOpacity = 0.7,
              bringToFront = TRUE),
          label = labels,
          labelOptions = labelOptions(
              style = list("font-weight" = "normal", padding = "3px 8px"),
              textsize = "15px",
              direction = "auto")) %>%
          addLegend(pal = pal, values = ~density, opacity = 0.7,
                    title = NULL,
                    position = "bottomright")
  })
  
}



shinyApp(ui, server)
