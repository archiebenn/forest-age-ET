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
library(pheatmap)
library(ltc)
library(tikzDevice)
library(ggrepel)

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


# set numpy seed
set.seed(42)

# *********************************************
# 1. DATA SETUP
# *********************************************

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
# 2. GOWER MATRIX
# *********************************************
# select only these cols for matrix calculation
df_features <- df %>%
    dplyr::mutate(across(all_of(categorical_features), as.factor)) %>%
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
# 3. PAM + silhouette (cluster assignment)
# *********************************************

# using silhouette method to determine ideal value of k (clusters) with factoextra package
# peaks at k=14 = too high for 57ish sites
fviz_nbclust(gower, FUN = pam, method = "silhouette", k.max = 20) +
    labs(subtitle = "Silhouette Method for Optimal k")

# now run pam on the dissimilarity matrix. diss = TRUE as passing a dissimilarity matrix (gower)
pam_result_gower <- pam(gower_matrix, k = 6, diss = TRUE)

# view cluster assignments
print(pam_result_gower$clustering)

# get medoid site ID labels
medoid_ids <- pam_result_gower$medoids

# label list, blank if not medoid site id
site_ids <- rownames(gower_matrix)
labels <- ifelse(site_ids %in% rownames(pam_result_gower$medoids), site_ids, "")

# visualise clusters
pal2 = ltc(casa_natal)

# cluster plot
p_cluster_plot <- fviz_cluster(pam_result_gower, 
             data = gower_matrix,
             geom = "point", 
             ellipse.type = "convex") + 
    theme_minimal() +
    xlab("Dimension 1 (46.7\\%)") +
    ylab("Dimension 2 (20.1\\%)") +
    ggtitle(NULL) +
    
    # colour from ltc
    scale_colour_manual(values = pal2) +
    scale_fill_manual(values = pal2) +
    
    labs(color = "Cluster", shape = "Cluster", fill = "Cluster") +
    
    # add medoid ids
    geom_text_repel(aes(label = ifelse(rownames(gower_matrix) %in% medoid_ids, rownames(gower_matrix), "")),
                    min.segment.length = 0,
                    force = 100,
                    box.padding = 1.25)


p_cluster_plot 

tikz("diss/figures/cluster_plot.tex", width = 6, height = 4, standAlone = TRUE)
print(p_cluster_plot)
dev.off()

# silhouette plot
fviz_silhouette(pam_result_gower)

# visualise on world map
world <- ne_countries(scale = "medium", returnclass = "sf")

# create and save out df
# full site df with cluster attached
df_clustered <- df %>%
    mutate(cluster = factor(pam_result_gower$clustering[Site_ID]))
write_csv(df_clustered, "data/main/20_gower/df_clustered.csv")



# *********************************************
# 4. Classifying clusters
# *********************************************
# try yto classify the clusters by looking at mean values for the vars
df_clustered %>%
    dplyr::group_by(cluster) %>%
    dplyr::summarise(
        dplyr::across(all_of(numerical_features), list(mean = mean, sd = sd)),
        dplyr::across(all_of(categorical_features), ~ as.character(names(sort(table(.), decreasing = TRUE))[1]))
    )





# *********************************************
# 5. HEATMAP
# *********************************************
# colour palette
pal=ltc("heatmap2",50,"continuous")

# retrieve medoid site per cluster
medoid_ids <- pam_result_gower$medoids
centroids <- df_features[medoid_ids, ]

centroids_num <- centroids %>%
    select(all_of(numerical_features)) %>%
    
    # scale numerical values (z scores)
    scale()

# categorical features converted to numeric codes
centroids_cat_num <- centroids %>%
    dplyr::select(all_of(categorical_features)) %>%
    dplyr::mutate(across(everything(), ~ as.numeric(as.factor(.))))

# combine into one matrix
centroids_mat <- cbind(centroids_num, centroids_cat_num)

# form heatmap of variables and centroids
p_heat <- pheatmap(
    centroids_mat,
    cluster_rows = FALSE,
    cluster_cols = TRUE,
    main = "Cluster Centroid Heatmap (Medoids)",
    fontsize_row = 10,
    fontsize_col = 10,
    color = pal,
    
    # for tikzdevice
    labels_col = gsub("_", "\\\\_", colnames(centroids_mat)),
    labels_row = gsub("_", "\\\\_", rownames(centroids_mat))
)

p_heat

# get string names back for categoricAL columns
centroids_cat <- centroids %>%
    dplyr::select(all_of(categorical_features)) %>%
    dplyr::mutate(across(all_of(categorical_features), as.character))







# cluster-level mean z-scores for numerical features
cluster_means_num <- df_clustered %>%
    
    # scale features
    mutate(across(all_of(numerical_features), ~ as.numeric(scale(.)))) %>%
    group_by(cluster) %>%
    
    # mean of each feature
    summarise(across(all_of(numerical_features), mean)) %>%
    column_to_rownames("cluster") %>%
    as.matrix()

cluster_means_num

# cluster-level mode for categorical features
cluster_mode_cat <- df_clustered %>%
    group_by(cluster) %>%
    summarise(across(all_of(categorical_features),
                     ~ names(sort(table(.), decreasing = TRUE))[1])) %>%
    column_to_rownames("cluster")


# function to label clusters
labeller <- function(cluster, high_thresh = 1, vhigh_thresh = 1.5, low_thresh = -1, vlow_thresh = -1.5){
    
    vals = cluster_means_num[as.character(cluster), ]
    
    vhigh <- names(vals[!is.na(vals) & vals > vhigh_thresh])
    vlow  <- names(vals[!is.na(vals) & vals < vlow_thresh])
    high  <- names(vals[!is.na(vals) & vals > high_thresh & vals <= vhigh_thresh])
    low   <- names(vals[!is.na(vals) & vals < low_thresh & vals >= vlow_thresh])
    
    vhigh_labels <- paste("Very high:", vhigh)
    vlow_labels  <- paste("Very low:", vlow)
    high_labels  <- paste("High:", high)
    low_labels   <- paste("Low:", low)
    
    cat_labels <- paste(
        names(cluster_mode_cat), " = ", as.character(cluster_mode_cat[as.character(cluster), ])
    )
    
    all_labels <- c(vhigh_labels, high_labels, low_labels, vlow_labels, cat_labels)
    
    paste(all_labels, collapse = ", ")
}

# apply to all clusters
cluster_labels <- sapply(sort(unique(df_clustered$cluster)), labeller)
cluster_labels


# colour palette
pal=ltc("heatmap3", 30, "continuous")

# form heatmap of variables and centroids
p_heat2 <- pheatmap(
        cluster_means_num,
    cluster_rows = FALSE,
    cluster_cols = TRUE,
    fontsize_row = 10,
    fontsize_col = 10,
    display_numbers = TRUE,
    number_color = "black",
    angle_col = 90,

    #color = hcl.colors(50, "BluYl"),

    # for tikzdevice
    labels_col = gsub("_", "\\\\_", colnames(centroids_mat)),
    labels_row = gsub("_", "\\\\_", rownames(centroids_mat))
)

p_heat2


# pheatmap
tikz("diss/figures/pheat2.tex", width = 6, height = 4, standAlone = TRUE)
print(p_heat2)
dev.off()


# and now form cluster labels with description as a df
df_cluster_labels <- data.frame(
    cluster = 1:length(cluster_labels),
    medoid_site = pam_result_gower$medoids,
    label = cluster_labels
)


# *********************************************
# 6. EXTRA
# *********************************************

# counts of sites/cluster for results section
df_clustered %>%
    
    group_by(cluster) %>%
    
    summarise(sites_in_cluster = n())


write_csv(df_cluster_labels, "data/main/20_gower/df_cluster_labels.csv")

print("gower_pam.R complete")























