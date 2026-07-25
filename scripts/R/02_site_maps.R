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

# attach LATEST main fluxnet df after site selections etc. (22-7-2026)
sites <- read_csv("data/main/10_filtering2/df_sites2.csv")

sites_sf <- sites %>%
    st_as_sf(coords = c("Longitude", "Latitude"), crs = 4326)

# get world data
world <- ne_countries(scale = "medium", returnclass = "sf")

# colour palette
pal=ltc("heatmap0",10,"continuous")


p <- world %>%
    ggplot() +
    geom_sf(fill = "grey95", colour = "grey75", linewidth = 0.2) + 
    geom_sf(data = sites_sf, aes(colour = Site_age), size = 1) +
    coord_sf(xlim = c(-145, 32.5), ylim = c(6.5, 70), default_crs = sf::st_crs(4326)) +
    scale_colour_gradientn(
        colours = pal,
        name = "Stand Age \n(Years)",
        breaks = c(0, 100, 200, 300),
        labels = c("0", "100", "200", "300")
    ) +
    
    theme_void() +
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          legend.margin = margin(r = 10)) 

p


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


