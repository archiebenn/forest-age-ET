# all_site_map.R - display flux tower sites on map
# Author: Archie Benn

library(tidyverse)
library(sf)
library(rnaturalearth)
library(countrycode)
library(ggrepel)

# sites
sites = read_csv("data/fluxnet/site_selection/site_ages.csv")

# get world data
world <- ne_countries(returnclass = "sf")

# convert site long/lat for robinson projection
sites_coords_robin <- sites %>%
    st_as_sf(coords = c("LONGITUDE", "LATITUDE"), crs = 4326) %>%
    st_transform(crs = "+proj=robin")

# plot
world %>%
    st_transform(crs = "+proj=robin") %>%
    ggplot() +
    geom_sf(fill = "grey90", colour = "grey75", linewidth = 0.2) + 
    geom_sf(data = sites_coords_robin, aes(colour = SITE_AGE)) +
    scale_colour_gradient(low = "lightgreen", high = "darkgreen", name = "Stand age (years)") +
    theme_light()
   
    