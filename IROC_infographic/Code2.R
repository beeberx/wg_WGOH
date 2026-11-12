# Code developed with CoPilot 
# Written by B. Berx, 10-Nov-2026

#Assumptions
#Your files are:
# app.R
# 
# www/
# │
# ├── Basemap.svg
# ├── icon1.png
# └── icon2.png
# data/
# └── Highlights2025.csv
# 
# Required Packages
# install.packages(c(
#   "shiny",
#   "leaflet",
#   "sf",
#   "dplyr",
#   "htmltools"
# ))
# 
# app.R
library(shiny)

highlights <- read.csv(
  "data/Highlights2025.csv",
  stringsAsFactors = FALSE
)

ui <- fluidPage(

  tags$head(

    tags$style(HTML("

      body{
        margin:0;
      }

      .container-map{
        position:relative;
        width:100%;
        max-width:1400px;
        margin:auto;
      }

      .basemap{
        width:100%;
      }

      .icon{
        position:absolute;
        width:50px;
        height:50px;
        cursor:pointer;
      }

      .tooltip{
        visibility:hidden;

        position:absolute;

        background:white;
        border:1px solid #bbb;

        padding:10px;
        border-radius:5px;

        width:250px;

        z-index:1000;
      }

      .icon:hover + .tooltip{
        visibility:visible;
      }

    "))
  ),

  uiOutput("infographic")

)

server <- function(input, output){

  output$infographic <- renderUI({

    elems <- list(

      tags$img(
        src = "Basemap.svg",
        class = "basemap"
      )

    )

    for(i in seq_len(nrow(highlights))){

      row <- highlights[i,]

      elems <- append(
        elems,
        list(

          tags$img(
            src = row$icon,
            class = "icon",

            style = paste0(
              "left:", row$x, "%;",
              "top:", row$y, "%;"
            )
          ),

          tags$div(
            class = "tooltip",

            style = paste0(
              "left:", row$x + 2, "%;",
              "top:", row$y + 2, "%;"
            ),

            tags$b(row$title),

            tags$br(),

            row$description
          )

        )
      )

    }

    tags$div(
      class = "container-map",
      elems
    )

  })

}

shinyApp(ui, server)