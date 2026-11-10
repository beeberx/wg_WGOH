# install.packages(c("sf", "ggplot2", "rnaturalearth"))

library(sf)
library(ggplot2)
library(rnaturalearth)

# Land polygons
land <- ne_countries(
  scale = "medium",
  returnclass = "sf"
)

# Define map extent
xmin <- -12
xmax <- 4
ymin <- 48
ymax <- 62

# Create map
p <- ggplot() +
  
  # Sea background
  annotate(
    "rect",
    xmin = xmin,
    xmax = xmax,
    ymin = ymin,
    ymax = ymax,
    fill = "#CBE1E9"
  ) +
  
  # Land polygons
  geom_sf(
    data = land,
    fill = "#EFF5F7",
    colour = "#EFF5F7",
    linewidth = 0.2
  ) +
  
  coord_sf(
    xlim = c(xmin, xmax),
    ylim = c(ymin, ymax),
    expand = FALSE
  ) +
  
  theme_void()

# Save SVG
ggsave(
  "Basemap.svg",
  p,
  width = 10,
  height = 8,
  device = "svg"
)