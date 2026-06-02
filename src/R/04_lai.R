# LAI.R - script for acquiring and attaching LAI data from MODIS at sites
# Author: Archie Benn
# Date: 02-06-2026
# MODISTools: Koen Hufkens. (2023). bluegreen-labs/MODISTools: MODISTools v1.1.5. Zenodo. https://doi.org/10.5281/zenodo.7551164

if (!require(MODISTools)) install.packages("MODISTools")
library(MODISTools)
library(tidyverse)
library(purrr)
library(progressr)
library(future)
library(furrr)


# use multi-core (n-1 cores) for download below
plan(multisession, workers = parallel::detectCores() - 1)


# function to retrieve LAI data per site and return df for site
get_LAI <- function(site_id, latitude, longitude, start_date, end_date){
    site_lai <- mt_subset(product = "MCD15A3H",
              lat = latitude,
              lon = longitude,
              band = c("Lai_500m", "FparLai_QC", "FparExtra_QC", "LaiStdDev_500m"),
              start = start_date,
              end = end_date,
              km_lr = 0,                                                                 # 0,0 = 1 pixel. 1,1 = 9 pixels
              km_ab = 0,
              site_name = site_id,
              internal = TRUE,
              progress = TRUE)
    return(site_lai)
}


# import full (unscaled) data
df <- read_csv("data/fluxnet/03_full_unscaled/full_unscaled.csv")


# sort full data into sites and dates for LAI acquisition loop 
lai_setup_df <- df %>%
    group_by(SITE_ID) %>%
    summarise(
        LATITUDE = first(LATITUDE),
        LONGITUDE = first(LONGITUDE),
        START_DATE = as.character(min(TIMESTAMP)),      # characters for mt_subset() later
        END_DATE = as.character(max(TIMESTAMP))
    )


# use future_pmap() to apply get_LAI() across each row with multiple cores used
lai_results <- lai_setup_df %>%
    mutate(
        LAI = future_pmap(
            list(SITE_ID, LATITUDE, LONGITUDE, START_DATE, END_DATE),
            get_LAI
        )
    ) 


# un nest the LAI data per site into one big df
all_lai <- lai_results %>%
    select(SITE_ID, LAI) %>%
    tidyr::unnest(LAI) %>%           # un nest
    select(SITE_ID, calendar_date, band, value) %>%
    tidyr::pivot_wider(              # wide instead of long format
        id_cols = c(SITE_ID, calendar_date),
        names_from = band,
        values_from = value
    )








