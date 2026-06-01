# fluxnet.R - sorting FLUXNET full DD (daily) datasets before feature engineering
# Author: Archie Benn

library(tidyverse)
library(stringr)

DD_dir <- "data/fluxnet/02_full_sites_DD"

# list full set of DD FLUXNET csv files
file_names_DD <- list.files(DD_dir, full.names = T)

# variables to keep for models (from https://fluxnet.org/data/aboutdata/data-variables/)
# F = gap-Filled
vars_keep <- c("TIMESTAMP",            # date 
               "LE_F_MDS",             # latent heat (W m-2)
               "LE_F_MDS_QC",          # latent heat quality
               "SW_IN_F",              # Short-wave radiation, incoming (W m-2)
               "SW_IN_F_QC",           # Short-wave radiation, incoming quality
               "TA_F",                 # daily mean temp (deg C)
               "TA_F_QC",              # daily mean temp quality
               "WS_F",                 # Wind speed (m s-1)
               "WS_F_QC",              # Wind speed quality
               "VPD_F",                # Vapour Pressure Deficit - VPD - (hPa)
               "VPD_F_QC",             # VPD quality
               "P_F",                  # Precipitation (mm)
               "P_F_QC",               # Precipitation quality
               "PA_F",                 # Atmospheric pressure (kPa)
               "PA_F_QC"               # Atmospheric pressure quality
               )

# create single DF from FULLSET data and keeping only selected variables for each site
# also attach site name to link to other .csv with ages later
fluxnet_selected <- file_names_DD %>%                                                             
    map(\(x) read_csv(x, 
                      col_select = all_of(vars_keep),
                      na = "-9999") %>%                                                   # apply col select and remove N/A values for each file name in list
            mutate(SITE_ID = str_extract(basename(x), "FLX_([^_]+)", group = 1))) %>%   # save the site name from standard FLUXNET naming of data
    list_rbind()


# read in sites from sites.R
sites_metadata = read_csv("data/fluxnet/01_site_selection/site_ages.csv")

# attach the two data frames based on site name to form final dataset (non-scaled/filtered) for engineer.R
df_fluxnet_ages <- fluxnet_selected %>%
    left_join(sites_metadata, by="SITE_ID",
              relationship = "many-to-one")

# save out as a .csv
write_csv(df_fluxnet_ages, "data/fluxnet/03_full_unscaled/full_unscaled.csv")


print("fluxnet.R complete")










