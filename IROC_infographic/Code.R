library(shiny)
library(leaflet)
library(dplyr)

icons <- awesomeIcons(
  icon = "fire",
  library = "fa",
  markerColor = "red"
)

ui <- fluidPage(

  selectInput(
    "year",
    "Year",
    choices = c(2025, 2026)
  ),

  leafletOutput("map", height = "800px")
)

server <- function(input, output) {

  output$map <- renderLeaflet({

    leaflet() %>%
      addTiles() %>%
      setView(-4, 57, zoom = 5)

  })

  observe({

    dat <- climate_data %>%
      filter(year == input$year)

    leafletProxy("map") %>%
      clearMarkers() %>%
      addMarkers(
        lng = dat$lon,
        lat = dat$lat,
        popup = dat$popup
      )

  })

}

shinyApp(ui, server)