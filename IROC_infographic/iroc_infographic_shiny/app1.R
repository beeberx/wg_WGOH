library(shiny)
library(dplyr)
library(sf)
library(ggplot2)
library(ggiraph)
library(png)
library(rsvg)

# 1. Define the projection & bounding box matching north_atlantic_basemap.svg
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

edge_pts <- rbind(
  data.frame(lon = seq(-105, 70, by = 1), lat = 20),
  data.frame(lon = seq(-105, 70, by = 1), lat = 70),
  data.frame(lon = -105, lat = seq(20, 70, by = 1)),
  data.frame(lon = 70,   lat = seq(20, 70, by = 1))
)

map_bbox <- st_as_sf(edge_pts, coords = c("lon", "lat"), crs = 4326) %>%
  st_transform(crs = lcc_crs) %>%
  st_bbox()

# 2. Load SVG basemap
svg_file <- "north_atlantic_basemap.svg"
if (!file.exists(svg_file)) {
  stop(paste("Cannot find SVG basemap at:", file.path(getwd(), svg_file)))
}
basemap_raster <- rsvg::rsvg(svg_file, width = 2400)

csv_file <- "HighlightText_2026.csv"

# 3. Define User Interface
ui <- fluidPage(
  titlePanel("Interactive Highlights Map"),
  girafeOutput("highlight_map", width = "100%", height = "650px")
)

# 4. Define Server Logic
server <- function(input, output, session) {
  
  map_data <- reactive({
    if (!file.exists(csv_file)) {
      stop(paste("Cannot find CSV file at:", file.path(getwd(), csv_file)))
    }
    
    df <- read.csv(csv_file, stringsAsFactors = FALSE) %>%
      mutate(
        icon_file = gsub('^"+|"+$', '', trimws(icon_file)),
        color = if ("color" %in% names(.)) ifelse(is.na(color) | color == "", "#E74C3C", trimws(color)) else "#E74C3C",
        # Parse icon_size and default to 1.0 if missing or blank
        icon_size = if ("icon_size" %in% names(.)) ifelse(is.na(as.numeric(icon_size)), 1.0, as.numeric(icon_size)) else 1.0
      ) %>%
      st_as_sf(wkt = "wkt", crs = 4326) %>%
      st_transform(crs = lcc_crs)
    
    df
  })

  output$highlight_map <- renderGirafe({
    df <- map_data()
    geom_types <- as.character(st_geometry_type(df))
    
    # Split data by geometry family
    polys_df  <- df[geom_types %in% c("POLYGON", "MULTIPOLYGON"), ]
    lines_df  <- df[geom_types %in% c("LINESTRING", "MULTILINESTRING"), ]
    points_df <- df[geom_types %in% c("POINT", "MULTIPOINT"), ]
    
    # Start plot with the SVG basemap
    p <- ggplot() +
      annotation_raster(
        raster = basemap_raster,
        xmin = map_bbox["xmin"],
        xmax = map_bbox["xmax"],
        ymin = map_bbox["ymin"],
        ymax = map_bbox["ymax"]
      )
    
    # Layer 1: Polygons (drawn first so they sit underneath lines and icons)
    if (nrow(polys_df) > 0) {
      p <- p + geom_sf_interactive(
        data = polys_df,
        aes(
          fill = I(color),
          color = I(color),
          tooltip = title,
          data_id = title
        ),
        alpha = 0.35,
        linewidth = 0.8
      )
    }
    
    # Layer 2: Linestrings
    if (nrow(lines_df) > 0) {
      p <- p + geom_sf_interactive(
        data = lines_df,
        aes(
          color = I(color),
          tooltip = title,
          data_id = title
        ),
        linewidth = 1.5
      )
    }
    
    # Layer 3: Points and Multipoints (with dynamic PNG icon sizes + click hitboxes)
    if (nrow(points_df) > 0) {
      pts_expanded <- suppressWarnings(st_cast(points_df, "POINT"))
      coords <- st_coordinates(pts_expanded)
      pts_expanded$X <- coords[, "X"]
      pts_expanded$Y <- coords[, "Y"]
      
      # Base icon half-width in meters (~3.5% of map width for icon_size = 1.0)
      base_radius <- (map_bbox["xmax"] - map_bbox["xmin"]) * 0.035
      
      for (i in seq_len(nrow(pts_expanded))) {
        img_path <- pts_expanded$icon_file[i]
        if (!is.na(img_path) && img_path != "" && file.exists(img_path)) {
          img <- png::readPNG(img_path)
          
          # Multiply base radius by the row's icon_size multiplier
          r <- base_radius * pts_expanded$icon_size[i]
          
          p <- p + annotation_raster(
            raster = img,
            xmin = pts_expanded$X[i] - r,
            xmax = pts_expanded$X[i] + r,
            ymin = pts_expanded$Y[i] - r,
            ymax = pts_expanded$Y[i] + r
          )
        }
      }
      
      # Scale the clickable hitbox to match each icon's size
      p <- p + geom_point_interactive(
        data = pts_expanded,
        aes(
          x = X,
          y = Y,
          size = 12 * icon_size,
          tooltip = title,
          data_id = title
        ),
        alpha = 0.01
      ) +
        scale_size_identity() # Uses the exact calculated point size without adding a legend
    }
    
    # Apply projection bounds
    p <- p +
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
        opts_hover(css = "cursor:pointer;opacity:0.85;")
      )
    )
  })
  
  # Show popup modal when any polygon, line, or icon is clicked
  observeEvent(input$highlight_map_selected, {
    req(input$highlight_map_selected)
    
    clicked_row <- map_data() %>%
      filter(title == input$highlight_map_selected) %>%
      slice(1)
    
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
