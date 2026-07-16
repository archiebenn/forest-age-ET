# plots_generate.R - generate observed vs. fitted plots for ET over site dates for all architectures/models
# Author: Archie Benn
# Date: 16-07-2026


rm(list = ls())

library(tidyverse)
library(here)
library(wesanderson)
library(gridExtra)
library(sf)
library(rnaturalearth) 
library(countrycode)
library(ggrepel)

# Load in data
df_sites <- read_csv(here("data/main/10_filtering2/df_sites2.csv"))
results_dir <- "data/main/16_ML_results/"

# make folders for plots 
dirs <- c("data/main/17_plots_generate/all",
          "data/main/17_plots_generate/no_age",
          "data/main/17_plots_generate/no_lai",
          "data/main/17_plots_generate/no_age_no_lai",
          "data/main/17_plots_generate/RF_model_plots",
          "data/main/17_plots_generate/GAM_model_plots")
walk(dirs, ~dir.create(here(.x), recursive = TRUE, showWarnings = FALSE))

# load in data
GAM_preds <- read.csv(here(paste(results_dir, "GAM_preds_results.csv", sep = "")))
GAM_stats <- read.csv(here(paste(results_dir, "GAM_stats_results.csv", sep = "")))

RF_preds <- read.csv(here(paste(results_dir, "RF_preds_results.csv", sep = "")))
RF_stats <- read.csv(here(paste(results_dir, "RF_stats_results.csv", sep = "")))
RF_shap <- read.csv(here(paste(results_dir, "RF_shap_results.csv", sep = "")))

# set dates to Date type from char
GAM_preds$Date <- as.Date(GAM_preds$Date)
RF_preds$Date <- as.Date(RF_preds$Date)

# Form merged dataframes for stats/preds/shap stuff
preds_merged <- bind_rows(GAM_preds, RF_preds)
stats_merged <- bind_rows(GAM_stats, RF_stats)
shap_merged <- bind_rows(RF_shap)

# rename 'site' to Site_ID in both shap and stats merged dfs
stats_merged <- stats_merged %>%
    rename(Site_ID = site)
shap_merged <- shap_merged %>%
    rename(Site_ID = site)


# *******************************************************************
# function to generate ET vs.time plots for observed and fitted from different architectures
# *******************************************************************
# (model constant, compare architectures)
preds_by_architecture <- function(mod, site, data, stats_df, path_to_dir){
    
    # get r2 and rmse form stats_df
    stats_sub <- stats_df %>%
        filter(model == mod, Site_ID == site)
    
    # plot ET vs time per site
    p <- data %>%
        
        filter(model == mod) %>%
        filter(Site_ID == site) %>%
        ggplot(aes(x = Date)) +
        
        # fit observed and predicted to same plot
        geom_line(aes(y = observed_ET, colour = "Observed"), alpha = 0.6) +
        geom_line(aes(y = predicted_ET, colour = "Predicted"), alpha = 0.6) +
        
        ylab("Daily ET (mm)") +
        
        ggtitle(paste(site, " (Model: ", mod, ")", sep = "")) +
        
        # legend
        scale_colour_manual(name = "Legend", 
                            values = c("Observed" = "seagreen", "Predicted" = "tomato")) +
        
        
        facet_wrap(~architecture) +
        
        # add stats to plot
        geom_text(data = stats_sub,
                  aes(x = -Inf, y = Inf, 
                      label = paste("R-squared = ", round(r2, 2), 
                                    "\nRMSE = ", round(rmse, 2))),
                  hjust = -0.1, vjust = 1.2,  
                  size = 3) +
        
        theme_minimal()
    
    png(here(path_to_dir, paste0(site, ".png")), width = 8, height = 4, units = "in", res = 300)
    print(p)
    dev.off()
}
# *******************************************************************



# *******************************************************************
# function to generate facetted model plots per site with the RF architecture
# *******************************************************************
# (# architecture constant, compare models)
arch_preds_by_model <- function(arch, site, data, stats_df, path_to_dir){
    
    # get r2 and rmse form stats_df
    stats_sub <- stats_df %>%
        filter(architecture == arch, Site_ID == site)
    
    # plot ET vs time per site
    p <- data %>%
        
        filter(architecture == arch) %>%
        filter(Site_ID == site) %>%
        ggplot(aes(x = Date)) +
        
        # fit observed and predicted to same plot
        geom_line(aes(y = observed_ET, colour = "Observed"), alpha = 0.6) +
        geom_line(aes(y = predicted_ET, colour = "Predicted"), alpha = 0.6) +
        
        ylab("Daily ET (mm)") +
        
        ggtitle(paste(arch, "models at", site)) +
        
        # legend
        scale_colour_manual(name = "Legend", 
                            values = c("Observed" = "seagreen", "Predicted" = "tomato")) +
        
        
        facet_wrap(~model) +
        
        # add stats to plot
        geom_text(data = stats_sub,
                  aes(x = -Inf, y = Inf, 
                      label = paste("R-squared = ", round(r2, 2), 
                                    "\nRMSE = ", round(rmse, 2))),
                  hjust = -0.1, vjust = 1.2,  
                  size = 3) +
        
        theme_minimal() 
    
    png(here(path_to_dir, paste0(site, ".png")), width = 8, height = 4, units = "in", res = 300)
    print(p)
    dev.off()
}
# *******************************************************************



# *******************************************************************
# running loops to generate the plots
# *******************************************************************
# list site names from sites df
sites <- c(unique(df_sites$Site_ID))

# model constant, compare architecture
# all model
for (i in sites){
    preds_by_architecture("all", i, preds_merged, stats_merged, "data/main/17_plots_generate/all")
}
# no age model
for (i in sites){
    preds_by_architecture("no_age", i, preds_merged, stats_merged, "data/main/17_plots_generate/no_age")
}
# no lai model
for (i in sites){
    preds_by_architecture("no_lai", i, preds_merged, stats_merged, "data/main/17_plots_generate/no_lai")
}
# no age or lai model
for (i in sites){
    preds_by_architecture("no_age_no_lai", i, preds_merged, stats_merged, "data/main/17_plots_generate/no_age_no_lai")
}


# architecture constant, compare model
for (i in sites){
    arch_preds_by_model("RF", i, preds_merged, stats_merged, "data/main/17_plots_generate/RF_model_plots")
}
for (i in sites){
    arch_preds_by_model("GAM", i, preds_merged, stats_merged, "data/main/17_plots_generate/GAM_model_plots")
}
# *******************************************************************

print("17_plots_generate.R finished")