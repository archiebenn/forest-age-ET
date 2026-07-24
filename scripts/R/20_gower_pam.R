# gower_pam.R - computing gower matrices to characterise sites as an initial test. 
# also carrying out PAM to cluster sites
# author: Archie Benn
# date: 24-07-2026

# the computed matrix will use gower as it is a mix of numerical and categorical values and represents dissimilarity between site characteristics
# this gower matrix then feeds into pam

rm(list = ls())

library(tidyverse)
library(cluster)

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











print("gower_pam.R complete")



























