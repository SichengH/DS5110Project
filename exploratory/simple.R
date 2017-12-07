library(leaflet)
library(geojsonio)


bins <- c(0, 10, 20, 50, 100, 200, 500, 1000, Inf)
pal <- colorBin("YlOrRd", domain = boston$mean_interior_score,
                bins = bins)


leaflet(boston) %>%
    setView(-71.0589, 42.3, 11) %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addPolygons(
        fillColor = ~pal(as.numeric(as.character(max_interior_score))^2)
    )


      ,
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
            direction = "auto"))




%>%
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

