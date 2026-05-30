# all_site_map.R - display flux tower sites on map
# Author: Archie Benn

#Sys.setenv(PROJ_LIB = "/home/ab/micromamba/envs/bbinf_project/share/proj")

library(tidyverse)
library(sf)
library(rnaturalearth)
library(countrycode)
library(ggrepel)

# sites
sites = read_csv("data/fluxnet/site_selection/site_ages.csv")

# get world data
world <- ne_countries(returnclass = "sf")

# plot
world %>%
    st_transform(crs = "+proj=robin") %>%
    ggplot() +
    geom_sf() +
    theme_minimal()
 
    