# filtering.R - script for filtering LAI and fluxnet data using QC metrics
# Author: Archie Benn
# Date: 02-06-2026

rm(list = ls())
library(tidyverse)
library(zoo)


# import full (unscaled) data and LAI data
df <- read_csv("data/fluxnet/03_full_unscaled/full_unscaled.csv")
lai_full <- read_csv("data/fluxnet/04_lai_full_unscaled/lai_full_unscaled.csv")

# 1. filter LAI quality first:
# FparLai_QC is a bit-encoded quality metric, see (https://www.earthdata.nasa.gov/s3fs-public/2025-04/MOD15_User_Guide_V5.pdf?VersionId=eBlss9mLOaTk4czZcz4ZEwioQ4AwJqj3)
# bit 0 of each of these values refers to the MODLAND_QC bits where 0 = good quality, 1 = other (filled/other algorithm etc.)

# show summaries of total and good quality sites
print(lai_full %>%
          group_by(SITE_ID) %>%
          summarise(n_LAI_measurements = n(),                                # number of measurements at each site
                    n_good_quality = sum(bitwAnd(FparLai_QC, 1L) == 0)))     # number of good quality measurements at sites


lai_filtered <- lai_full %>%
    mutate(
        Lai_500m = ifelse(bitwAnd(FparLai_QC, 1L) == 0,         # "if FparLai_QC bit 0 =..."
                          Lai_500m,                             # 0: keep Lai_500m as is (good quality)
                          NA                                    # 1: replace with NA (poor quality)
        )) %>%
    select(SITE_ID, calendar_date, Lai_500m)                    # just keep these cols post-filtering


# now these NA values are filled, linear interpolation will be used to gap fill the LAI (slow changing variable)
# attach LAI to full/main fluxnet data frame by site and date
full_data <- df %>%
    left_join(lai_filtered, by = c("SITE_ID", "TIMESTAMP" = "calendar_date")) %>%
    group_by(SITE_ID) %>%
    arrange(TIMESTAMP, .by_group = TRUE) %>%                                       # before interpolating to ensure right order
    mutate(Lai_500m = zoo::na.approx(Lai_500m, na.rm = F)) %>%                     # approximate LAI values interpolated between misssing values
    ungroup() %>%
    filter(!is.na(Lai_500m))                                                       # removes rows before LAI measurements began

















