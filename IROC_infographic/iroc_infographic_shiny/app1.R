library(shiny)
library(dplyr)
library(sf)
library(ggplot2)
library(ggiraph)
library(png)
library(rsvg) # <-- Reads your SVG basemap

# 1. Define the same projection & bounding box used to create basemap.svg
lcc_crs <- paste(
  "+proj=lcc",
  "+lat_1=40",
  "+lat_2=70",
  "+lat_0=50",
  "+lon_0=-30",
  "+datum=WGS84",
  "+units=m",
  "+no_defs"
)

# Build boundary points along all 4 edges in 1-degree steps and project to lcc_crs
edge_pts <- rbind(
  data.frame(lon = seq(-105, 70, by = 1), lat = 20),  # Bottom edge
  data.frame(lon = seq(-105, 70, by = 1), lat = 70),  # Top edge
  data.frame(lon = -105, lat = seq(20, 70, by = 1)),  # Left edge
  data.frame(lon = 70,   lat = seq(20, 70, by = 1))   # Right edge
)

map_bbox <- st_as_sf(edge_pts, coords = c("lon", "lat"), crs = 4326) %>%
  st_transform(crs = lcc_crs) %>%
  st_bbox()

# 2. Load your SVG basemap once at startup (at crisp 2400px width)
svg_file <- "north_atlantic_basemap.svg"
basemap_raster <- rsvg::rsvg(svg_file, width = 2400)

csv_file <- "HighlightText_2026.csv"

# 3. Define the User Interface
ui <- fluidPage(
  titlePanel("Interactive Highlights Map"),
  girafeOutput("highlight_map", width = "100%", height = "650px")
)

# 4. Define Server Logic
server <- function(input, output, session) {
  
  map_data <- reactive({
    sf_obj <- read.csv(csv_file, stringsAsFactors = FALSE) %>%
      mutate(
        icon_file = gsub('^"+|"+$', '', trimws(icon_file))
      ) %>%
      st_as_sf(wkt = "wkt", crs = 4326) %>%
      st_transform(crs = lcc_crs)
    
    coords <- st_coordinates(sf_obj)
    
    sf_obj %>%
      mutate(
        X = coords[, "X"],
        Y = coords[, "Y"]
      )
  })
  
  output$highlight_map <- renderGirafe({
    df <- map_data()
    
    # Calculate icon half-width in meters (~3.5% of map width)
    icon_radius <- (map_bbox["xmax"] - map_bbox["xmin"]) * 0.035
    
    # Start ggplot with your SVG basemap stretched across the exact map_bbox
    p <- ggplot() +
      annotation_raster(
        raster = basemap_raster,
        xmin = map_bbox["xmin"],
        xmax = map_bbox["xmax"],
        ymin = map_bbox["ymin"],
        ymax = map_bbox["ymax"]
      )
    
    # Add PNG icons on top of the SVG basemap
    for (i in seq_len(nrow(df))) {
      img_path <- df$icon_file[i]
      if (file.exists(img_path)) {
        img <- png::readPNG(img_path)
        p <- p + annotation_raster(
          raster = img,
          xmin = df$X[i] - icon_radius,
          xmax = df$X[i] + icon_radius,
          ymin = df$Y[i] - icon_radius,
          ymax = df$Y[i] + icon_radius
        )
      } else {
        warning(paste("Icon file not found:", img_path))
      }
    }
    
    # Add invisible interactive hitbox over each icon for hover & click
    p <- p +
      geom_point_interactive(
        data = df,
        aes(
          x = X,
          y = Y,
          tooltip = title,
          data_id = title
        ),
        size = 12,
        alpha = 0.01
      ) +
      coord_sf(
        crs = lcc_crs,
        xlim = c(map_bbox["xmin"], map_bbox["xmax"]),
        ylim = c(map_bbox["ymin"], map_bbox["ymax"]),
        expand = FALSE
      ) +
      theme_void()
    
    girafe(
      ggobj = p,
      options = list(
        opts_selection(type = "single", only_shiny = FALSE),
        opts_hover(css = "cursor:pointer;")
      )
    )
  })
  
  observeEvent(input$highlight_map_selected, {
    req(input$highlight_map_selected)
    
    clicked_row <- map_data() %>%
      filter(title == input$highlight_map_selected)
    
    req(nrow(clicked_row) > 0)
    
    showModal(modalDialog(
      title = clicked_row$title,
      HTML(clicked_row$highlight_text),
      easyClose = TRUE,
      footer = modalButton("Close")
    ))
  })
}

shinyApp(ui = ui, server = server)
