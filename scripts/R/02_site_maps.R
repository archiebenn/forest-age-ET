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
library(ltc)
library(tidyplots)

# attach LATEST main fluxnet df after site selections etc. (22-7-2026)
sites <- read_csv("data/main/20_gower/df_clustered.csv")
medoids <- read_csv("data/main/20_gower/df_cluster_labels.csv")

sites_sf <- sites %>%
    st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)

# get world data
world <- ne_countries(scale = "medium", returnclass = "sf")

# get medoid site ID labels
medoid_labels <- medoids$medoid_site

# colour palette
pal <- rev(colors_continuous_viridis)

medoid_coords <- sites_sf %>%
    filter(Site_ID %in% medoid_labels) %>%
    mutate(lon = st_coordinates(.)[,1],
           lat = st_coordinates(.)[,2])


p <- world %>%
    ggplot(aes(colour = Site_age)) +
    geom_sf(fill = "grey95", colour = "grey75", linewidth = 0.2) + 
    geom_sf(data = sites_sf, aes(colour = Site_age), size = 1) +
    coord_sf(xlim = c(-145, 32.5), ylim = c(20, 72.5), default_crs = sf::st_crs(4326)) +
    scale_colour_gradientn(
        colours = pal,
        name = "Stand Age \n(Years)",
        breaks = c(0, 100, 200, 300),
        labels = c("0", "100", "200", "300")
    ) +

    theme_void() +
    
    # add repelled site labels for medoid sites
    geom_text_repel(data = medoid_coords, aes(x = lon, y = lat, label = Site_ID), 
                    min.segment.length = 0,
                    box.padding = 1.25) +
    
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          legend.margin = margin(r = 10))

p 


p_climates <- world %>%
    ggplot() +
    geom_sf(fill = "grey95", colour = "grey75", linewidth = 0.2) + 
    geom_sf(data = sites_sf, aes(colour = Climate_zone), size = 1) +
    coord_sf(xlim = c(-145, 32.5), ylim = c(6.5, 70), default_crs = sf::st_crs(4326)) +
    scale_colour_brewer(palette = "Set1", name = "Climate Zone") +
    theme_void() +
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          legend.margin = margin(r = 10)) 
p_climates


# plot as TikZ object for integration into LaTeX
options(tikzLatexPackages = c(
    getOption("tikzLatexPackages"),
    "\\usepackage{MinionPro}\n",
    "\\usepackage{MnSymbol}\n"
))
tikz("diss/figures/world_sites.tex", width = 6, height = 3, standAlone = TRUE)
print(p)
dev.off()

print("site_maps.R complete")

p
