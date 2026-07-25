# gower_pam.R - computing gower matrices to characterise sites as an initial test. 
# also carrying out PAM to cluster sites
# author: Archie Benn
# date: 24-07-2026

# the computed matrix will use gower as it is a mix of numerical and categorical values and represents dissimilarity between site characteristics
# this gower matrix then feeds into pam

rm(list = ls())

library(tidyverse)
library(cluster)
library(factoextra)
library(rnaturalearth)
library(sf)

# set numpy seed
set.seed(42)

df <- read_csv("data/main/10_filtering2/df_sites2.csv")

# define site level features
categorical_features <- c("Cover_type", "Climate_zone")

numerical_features <- c("Site_age",
                      "ET_mean",
                      "Lai_mean",
                      "SW_rad_mean",
                      "Tair_mean",
                      "Wspeed_mean",
                      "VPD_mean",
                      "P_sum_14D_mean")


# *********************************************
# GOWER MATRIX
# *********************************************
# select only these cols for matrix calculation
df_features <- df %>%
    mutate(across(all_of(categorical_features), as.factor)) %>%
    column_to_rownames("Site_ID") %>%
    select(all_of(c(categorical_features, numerical_features)))


# compute gower distances
gower <- daisy(df_features, metric = "gower")
gower_matrix <- as.matrix(gower)


# quick test to see top 5 most similar to a specific site:
# head(6) as 1st most similar is itself
gower_matrix["DE-Obe", ] %>%
    sort() %>%
    head(6)

# save out
as_tibble(gower_matrix, rownames = "Site_ID") %>%
    write_csv("data/main/20_gower/gower_matrix.csv")


# *********************************************
# PAM + silhouette
# *********************************************

# using silhouette method to determine ideal value of k (clusters) with factoextra package
# peaks at k=7
fviz_nbclust(gower, FUN = pam, method = "silhouette") +
    labs(subtitle = "Silhouette Method for Optimal k")

# now run pam on the dissimilarity matrix with k=6. diss = TRUE as passing a dissimilarity matrix (gower)
pam_result_gower <- pam(gower_matrix, k = 7, diss = TRUE)

# view cluster assignments
print(pam_result_gower$clustering)

# visualise clusters
fviz_cluster(pam_result_gower, data = gower_matrix, geom = "point", ellipse.type = "convex")
fviz_silhouette(pam_result_gower)

# visualise on world map
world <- ne_countries(scale = "medium", returnclass = "sf")

# access cluster per site ID
df_clustered <- df %>%
    mutate(cluster = factor(pam_result_gower$clustering[Site_ID]))

# plot on map
p_map <- ggplot() +
    geom_sf(data = world, fill = "grey95", colour = "grey80") +
    geom_point(data = df_clustered, aes(Longitude, Latitude, colour = cluster), size = 2.5) +
    coord_sf(xlim = c(-130, 40), ylim = c(25, 70)) + 
    theme_minimal()

p_map








print("gower_pam.R complete")























