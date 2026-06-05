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

# main download = 73 sites. want to make sure if re-running it doesn't try to download again if they exist/saves if crashes mid-download
# make cached directory
cached_dir <- "data/main/04_lai/cached_sites"
dir.create(cached_dir, recursive = TRUE, showWarnings = FALSE)


# function to retrieve LAI data per site and return df for site
get_LAI <- function(site_id, latitude, longitude, start_date, end_date){
    
    # re-define within function env
    cached_dir <- "data/main/04_lai/cached_sites"
    
    # define file csv (in cached dir) for this site
    site_csv <- file.path(cached_dir, paste0(site_id, ".csv"))
    
    # check if site csv already exists in cached dir and return before continuing
    if (file.exists(site_csv)){
        return(read_csv(site_csv, show_col_types = FALSE))
    }
    
    # if not present in cached dir:
    site_lai <- mt_subset(product = "MCD15A3H",
              lat = latitude,
              lon = longitude,
              band = c("Lai_500m", "FparLai_QC"),  # retrieve these bands (for QC etc.)
              start = start_date,
              end = end_date,
              km_lr = 0,                           # 0,0 = 1 pixel. 1,1 = 9 pixels
              km_ab = 0,
              site_name = site_id,
              internal = TRUE,
              progress = TRUE)
    
    # write site csv to cached dir immediately after downloading and return
    write_csv(site_lai, site_csv)
    return(site_lai)
}


# import full (unscaled) fluxnet data
df <- read_csv("data/main/03_full_unscaled/full_unscaled.csv")


# sort full data into sites and dates for LAI acquisition loop 
lai_setup_df <- df %>%
    group_by(SITE_ID) %>%
    summarise(
        LATITUDE = first(LATITUDE),
        LONGITUDE = first(LONGITUDE),
        START_DATE = as.character(min(TIMESTAMP)),      # characters for mt_subset() later
        END_DATE = as.character(max(TIMESTAMP))
    )


# warning: will be SLOW 
# use future_pmap() to apply get_LAI() across each row in lai_setup_df with multiple cores used
future_pmap(
    list(lai_setup_df$SITE_ID, lai_setup_df$LATITUDE, lai_setup_df$LONGITUDE,
         lai_setup_df$START_DATE, lai_setup_df$END_DATE),                          # pass these args
    get_LAI
)


# form full LAI df from the individual cached site csvs (and un nest and into wide format)
lai_full <- list.files(cached_dir, pattern = "*.csv", full.names = T) %>%
    map(read_csv) %>%                                                       # read the csvs in
    bind_rows() %>%                                                         # bind all csvs to single df
    select(site, calendar_date, band, value) %>% 
    rename(SITE_ID = site) %>%
    tidyr::pivot_wider(                                                     # wide instead of long format
        id_cols = c(SITE_ID, calendar_date),                                # these form a unique row in the output (site and date)
        names_from = band,
        values_from = value
    ) %>% 
    mutate(
        calendar_date = as.Date(calendar_date),                             # back to Date class for merging with main df
        Lai_500m = Lai_500m * 0.1                                           # scale factor for LAI band from MODIS (see https://lpdaac.usgs.gov/documents/926/MOD15_User_Guide_V61.pdf)
    )
    

# write out for filtering.R
write_csv(lai_full, "data/main/04_lai/lai_all.csv")

print("lai.R complete")








