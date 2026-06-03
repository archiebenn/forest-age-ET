# filtering.R - script for filtering LAI and fluxnet data using QC metrics
# Author: Archie Benn
# Date: 02-06-2026

rm(list = ls())
library(tidyverse)
library(zoo)


# import full (unscaled) data and LAI data
df <- read_csv("data/fluxnet/03_full_unscaled/full_unscaled.csv")
lai_full <- read_csv("data/fluxnet/04_lai/lai_full_unscaled.csv")

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
full_lai_data <- df %>%
    left_join(lai_filtered, by = c("SITE_ID", "TIMESTAMP" = "calendar_date")) %>%
    group_by(SITE_ID) %>%
    arrange(TIMESTAMP, .by_group = TRUE) %>%                                       # before interpolating to ensure right order
    mutate(Lai_500m = zoo::na.approx(Lai_500m, na.rm = F)) %>%                     # approximate LAI values interpolated between misssing values
    ungroup() %>%
    filter(!is.na(Lai_500m))                                                       # removes rows before LAI measurements began


# write out csv
write_csv(full_data, "data/fluxnet/05_filtering/full_lai_filtered.csv")


# 2. filtering/checking for FLUXNET gap filled
# _QC columns = 0 means measured, while = 1 is good gap filled, and 2-3 is poor quality

# check distributions with a summary()
flux_QC <- full_data %>%
    group_by(SITE_ID) %>%
    summarise(
        # total
        n_measurements = n(),
        
        # LE
        LE_best = sum(LE_QC == 0),
        LE_good = sum((LE_QC > 0) & (LE_QC <= 1)),
        LE_poor = sum(LE_QC > 1),
        
        # SW radiation
        SW_rad_best = sum(SW_rad_QC == 0),
        SW_rad_good = sum((SW_rad_QC > 0) & (SW_rad_QC <= 1)),
        SW_rad_poor = sum(SW_rad_QC > 1),
        
        # Air temp.
        Tair_best = sum(Tair_QC == 0),
        Tair_good = sum((Tair_QC > 0) & (Tair_QC <= 1)),
        Tair_poor = sum(Tair_QC > 1),
        
        # Wind speed
        Wspeed_best = sum(Wspeed_QC == 0),
        Wspeed_good = sum((Wspeed_QC > 0) & (Wspeed_QC <= 1)),
        Wspeed_poor = sum(Wspeed_QC > 1),
        
        # VPD
        VPD_best = sum(VPD_QC == 0),
        VPD_good = sum((VPD_QC > 0) & (VPD_QC <= 1)),
        VPD_poor = sum(VPD_QC > 1),
        
        # Precip
        P_best = sum(P_QC == 0),
        P_good = sum((P_QC > 0) & (P_QC <= 1)),
        P_poor = sum(P_QC > 1),
        
        # Pressure
        Pa_best = sum(Pa_QC == 0),
        Pa_good = sum((Pa_QC > 0) & (Pa_QC <= 1)),
        Pa_poor = sum(Pa_QC > 1)
    )

# save qualities
write_csv(flux_QC, "data/fluxnet/05_filtering/flux_QC.csv")

# will filter out any qc scores > 1 and then save as the full dataset
cols_filter <- c("LE_QC", "SW_rad_QC", "Tair_QC", "Wspeed_QC", "VPD_QC", "P_QC", "Pa_QC")

# checks against all columns in row simultaneously and drops full row if any QC > 1 ie. poor gap filling
full_filtered_data <- full_data %>%
    filter(if_all(all_of(cols_filter), \(x) x <= 1))


    












