# site_maps.R - display flux tower sites on map
# Author: Archie Benn
# Date: 30-05-2026

rm(list = ls())

library(tidyverse)
library(sf)
library(rnaturalearth)
library(countrycode)
library(ggrepel)
library(tikzDevice)

# attach LATEST main fluxnet df after site selections etc. (9-7-2026)
sites <- read_csv("data/main/08_sorting/sites.csv")

# get world data
world <- ne_countries(returnclass = "sf")

# convert site long/lat for robinson projection
sites_coords_robin <- sites %>%
    st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326) %>%
    st_transform(crs = "+proj=robin")

# plot
tikz("diss/figures/world_sites.tex", width = 6, height = 2.75, standAlone = F)

world %>%
    st_transform(crs = "+proj=robin") %>%
    ggplot() +
    geom_sf(fill = "grey90", colour = "grey75", linewidth = 0.2) + 
    geom_sf(data = sites_coords_robin, aes(colour = Site_age)) +
    scale_colour_gradient(
        low = "lightgreen", high = "darkgreen",
        name = "Stand Age (Years)",
        breaks = c(0, 100, 200, 300),
        labels = c("0", "100", "200", "300")
    ) +
    theme_void() +
    theme(legend.text = element_text(size = 8),
          legend.title = element_text(size = 8),
          legend.margin = margin(r = 10)) 

dev.off()

print("site_maps.R complete")

