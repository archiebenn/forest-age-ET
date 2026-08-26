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

# serif plots
options(tikzLatexPackages = c(
    getOption("tikzLatexPackages"),
    "\\usepackage{tgheros}",
    "\\renewcommand{\\familydefault}{\\sfdefault}",
    "\\usepackage{sansmath}",
    "\\sansmath"
))

# minion pro plots
#options(tikzLatexPackages = c(
#    getOption("tikzLatexPackages"),
#    "\\usepackage{MinionPro}\n",
#    "\\usepackage{MnSymbol}\n"
#))

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
           lat = st_coordinates(.)[,2]) %>%
    
    # add cluster number to name for clarity on world map
    mutate(name_cluster = paste(Site_ID, " (", cluster, ")", sep = ""))


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

# palette for map
pal2 = ltc(casa_natal)

# clusters on map
p_clusters <- world %>%
    
    ggplot() +
    # set map colours
    geom_sf(fill = "grey95", colour = "grey75", linewidth = 0.2) + 
    
    # add points
    geom_point(data = sites, aes(Longitude, Latitude, colour = factor(cluster)), size = 2, alpha = 0.8) +
    
    # set scale limits
    coord_sf(xlim = c(-145, 32.5), ylim = c(6.5, 75), default_crs = sf::st_crs(4326)) +
    
    scale_x_continuous(labels = function(x) paste0(x, "$^\\circ$")) +
    scale_y_continuous(labels = function(x) paste0(x, "$^\\circ$")) +
    
    # hide degrees symbol for latex
    theme_minimal() +
    # add repelled site labels for medoid sites
    geom_text_repel(data = medoid_coords, aes(x = lon, y = lat, label = name_cluster), 
                    min.segment.length = 0,
                    box.padding = 1.2) +
    
    scale_colour_manual(values = pal2) +
    
    
    # legend name
    labs(colour = "Cluster") +
    
    theme(legend.text = element_text(size = 10),
          legend.title = element_text(size = 10),
          legend.margin = margin(r = 10)) 

p_clusters


# plot as TikZ object for integration into LaTeX
#tikz("diss/figures/world_sites.tex", width = 6, height = 3, standAlone = TRUE)
#print(p)
#dev.off()

tikz("diss/figures/world_sites_clusters.tex", width = 6, height = 3, standAlone = TRUE)
print(p_clusters)
dev.off()

print("site_maps.R complete")



