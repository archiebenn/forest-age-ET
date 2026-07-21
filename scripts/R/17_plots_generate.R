# plots_generate.R - generate observed vs. fitted plots for ET over site dates for all architectures/models
# Author: Archie Benn
# Date: 16-07-2026


rm(list = ls())

library(tidyverse)
library(here)
library(wesanderson)
library(patchwork)
library(sf)
library(rnaturalearth) 
library(countrycode)
library(ggrepel)
library(ltc)

# Load in data
df_sites <- read_csv(here("data/main/10_filtering2/df_sites2.csv"))
results_dir <- "data/main/16_ML_results/"

# make folders for plots 
dirs <- c("data/main/17_plots_generate/1_obs_pred",
          "data/main/17_plots_generate/2_RF_model_plots",
          "data/main/17_plots_generate/2_GAM_model_plots",
          "data/main/17_plots_generate/3_obs_pred_SHAP",
          "data/main/17_plots_generate/3_SHAP_all")
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
# 1. function to generate ET vs.time plots for observed and fitted from different architectures
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
    
    png(here(path_to_dir, paste(site, "_", mod, ".png", sep = "")), width = 8, height = 4, units = "in", res = 300)
    print(p)
    dev.off()
}
# *******************************************************************



# *******************************************************************
# 2. function to generate facetted model plots per site with the RF architecture
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
# 3. function to generate observed vs. fitted + SHAP importance per architecture at sites
# *******************************************************************
# palette
pal3 <- ltc("dora")

preds_with_SHAP <- function(mod, arch, site, data, stats_df, shap_df, path_to_dir){
    
    # get r2 and rmse form stats_df
    stats_sub <- stats_df %>%
        filter(model == mod, Site_ID == site, architecture == arch)
    
    # plot ET vs time per site
    pred_p <- data %>%
        
        filter(model == mod) %>%
        filter(Site_ID == site) %>%
        ggplot(aes(x = Date)) +
        
        # fit observed and predicted to same plot
        geom_line(aes(y = observed_ET, colour = "Observed"), alpha = 0.6) +
        geom_line(aes(y = predicted_ET, colour = "Predicted"), alpha = 0.6) +
        
        ylab("Daily ET (mm)") +
        
        ggtitle("Observed vs. Fitted") +
        
        theme_minimal()+
        
        # legend
        scale_colour_manual(name = NULL, 
                             values = c("Observed" = pal3[2], "Predicted" = pal3[5])) +
        
        # move legend to bottom
        theme(legend.position = "bottom") +
        
        # add stats to plot
        geom_text(data = stats_sub,
                  aes(x = -Inf, y = Inf, 
                      label = paste("R-squared = ", round(r2, 2), 
                                    "\nRMSE = ", round(rmse, 2))),
                  hjust = -0.1, vjust = 1.2,  
                  size = 3) 
    
    
    # create df of SHAP score means across features
    shap_site_summary <- shap_df %>%
        
        # select chosen rows
        filter(Site_ID == site, architecture == arch, model == mod) %>%
        
        # apply summaries across all columns with everything()
        summarise(across(everything(), list(mean = mean, sd = sd))) %>%
        
        # pivot across all (will drop non numeric NAs later), then name feature/value (sd or mean)
        # (?=mean$|sd$) is a lookahead which sees what follows the underscore and then sorts 
        pivot_longer(everything(), names_to = c("feature", ".value"), names_sep = "_(?=mean$|sd$)") %>%
        drop_na()
    
    # and now the shap plot
    shap_p <- shap_site_summary %>%
        
        # re-orders features by most important
        ggplot(aes(x = reorder(feature, mean), y = mean, fill = mean > 0)) +
        
        geom_col(position=position_dodge()) +
        geom_errorbar(aes(ymin=mean-sd, ymax=mean+sd), width=.2) +
        
        # aesthetics
        theme_minimal() +
        xlab("Features in Model") +
        ylab("Mean SHAP value") +
        ggtitle("SHAP feature importance") +
        scale_fill_manual(name = NULL,
                          values = c("TRUE" = pal3[1], "FALSE" = pal3[3]), 
                          labels = c("TRUE" = "+ impact", "FALSE" = "- impact")) +
        
        # move legend to bottom
        theme(legend.position = "bottom") +
        
        # flip coords to fit in feature names easily
        coord_flip()
    
    # forming the arranged plot of the above two with patchwork lib
    final_p <- pred_p + shap_p + plot_layout(widths = c(1.3, 1)) +
        plot_annotation(title = paste(arch, " at ", site, " (model: ", mod, ")", sep = "" ))
    
    # save plot
    png(here(path_to_dir, paste(site, "_", arch, "_", mod, ".png", sep = "")), width = 8, height = 4, units = "in", res = 300)
    print(final_p)
    dev.off()
}
# *******************************************************************




# *******************************************************************
# running loops to generate the plots
# *******************************************************************
# list site names from sites df
sites <- c(unique(df_sites$Site_ID))

# 1. model constant, compare architecture
# all model
for (i in sites){
    preds_by_architecture("all", i, preds_merged, stats_merged, "data/main/17_plots_generate/1_obs_pred")
}
# no age model
for (i in sites){
    preds_by_architecture("no_age", i, preds_merged, stats_merged, "data/main/17_plots_generate/1_obs_pred")
}
# no lai model
for (i in sites){
    preds_by_architecture("no_lai", i, preds_merged, stats_merged, "data/main/17_plots_generate/1_obs_pred")
}
# no age or lai model
for (i in sites){
    preds_by_architecture("no_age_no_lai", i, preds_merged, stats_merged, "data/main/17_plots_generate/1_obs_pred")
}


# 2. architecture constant, compare model
for (i in sites){
    arch_preds_by_model("RF", i, preds_merged, stats_merged, "data/main/17_plots_generate/2_RF_model_plots")
}
for (i in sites){
    arch_preds_by_model("GAM", i, preds_merged, stats_merged, "data/main/17_plots_generate/2_GAM_model_plots")
}



# 3. obs vs preds + SHAP plots
for (i in sites){
    preds_with_SHAP("all", "RF", i, preds_merged, stats_merged, shap_merged, "data/main/17_plots_generate/3_obs_pred_SHAP")
}
for (i in sites){
    preds_with_SHAP("no_age", "RF", i, preds_merged, stats_merged, shap_merged, "data/main/17_plots_generate/3_obs_pred_SHAP")
}
for (i in sites){
    preds_with_SHAP("no_lai", "RF", i, preds_merged, stats_merged, shap_merged, "data/main/17_plots_generate/3_obs_pred_SHAP")
}
for (i in sites){
    preds_with_SHAP("no_age_no_lai", "RF", i, preds_merged, stats_merged, shap_merged, "data/main/17_plots_generate/3_obs_pred_SHAP")
}

# *******************************************************************

print("17_plots_generate.R finished")