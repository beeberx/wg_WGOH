library(ggplot2)
library(sf)
library(rnaturalearth)

# World coastlines/polygons
land <- ne_countries(scale = "medium", returnclass = "sf")

# Lambert Conformal Conic projection
# centred over the North Atlantic
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

p <- ggplot() +
  geom_sf(data = land,
          fill = "#EFF5F7",
          colour = "#EFF5F7",
          linewidth = 0.2) +
  coord_sf(
    crs = lcc_crs,
    xlim = c(-105, 70),
    ylim = c(20, 70),
    default_crs = st_crs(4326),
    expand = FALSE
  ) +
  theme_void() +
  theme(
    panel.background = element_rect(
      fill = "#CBE1E9",
      colour = NA
    )
  )
  #theme_minimal() +
  #theme(
  #  panel.grid.major = element_line(
  #    colour = "grey80",
  #    linewidth = 0.3
  #  ),
  #  axis.title = element_blank()
  #)

ggsave(
  "north_atlantic_basemap.svg",
  width = 8,
  height = 6
)
