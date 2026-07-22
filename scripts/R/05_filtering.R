# filtering.R - script for filtering LAI and fluxnet data using QC metrics and back-propagating ages
# Author: Archie Benn
# Date: 03-06-2026

rm(list = ls())

if (!require(bigleaf)) install.packages("bigleaf")
library(bigleaf)
library(tidyverse)
library(zoo)
library(conflicted)

# use dplyr even if masked by plyr (was causing a few issues)
conflicted::conflict_prefer_all("dplyr", quiet = TRUE)

# import full (unscaled) data and LAI data
df_05 <- read_csv("data/main/03_full_unscaled/full_unscaled.csv")
lai_full <- read_csv("data/main/04_lai/lai_all.csv")


# 1. filter LAI quality first:
# FparLai_QC is a bit-encoded quality metric, see (https://www.earthdata.nasa.gov/s3fs-public/2025-04/MOD15_User_Guide_V5.pdf?VersionId=eBlss9mLOaTk4czZcz4ZEwioQ4AwJqj3)
# bit 0 of each of these values refers to the MODLAND_QC bits where 0 = good quality, 1 = other (filled/other algorithm etc.)

# show summaries of total and good quality sites
print(lai_full %>%
          group_by(SITE_ID) %>%
          
          # number of measurements at each site
          dplyr::summarise(n_LAI_measurements = n(),  
                    
                    # number of good quality measurements at sites
                    n_good_quality = sum(bitwAnd(FparLai_QC, 1L) == 0)))     



# this will replace any poor quality LAI measurements with N/A based off the QC
lai_filtered <- lai_full %>%
    mutate(
        Lai_500m = ifelse(bitwAnd(FparLai_QC, 1L) == 0,         # "if FparLai_QC bit 0 =..."
                          Lai_500m,                             # 0: keep Lai_500m as is (good quality)
                          NA                                    # 1: replace with NA (poor quality)
        )) %>%
    
    # just keep these cols post-filtering
    select(SITE_ID, calendar_date, Lai_500m)                


# now these NA values are filled, linear interpolation will be used to gap fill the LAI (slow changing variable)
# attach LAI to full/main fluxnet data frame by site and date
full_data <- df_05 %>%
    left_join(lai_filtered, by = c("SITE_ID", "TIMESTAMP" = "calendar_date")) %>%
    group_by(SITE_ID) %>%
    
    # before interpolating to ensure right order
    dplyr::arrange(TIMESTAMP, .by_group = TRUE) %>%           
    
    # approximate LAI values interpolated between misssing values
    mutate(Lai_500m = zoo::na.approx(Lai_500m, na.rm = F)) %>%     
    
    # removes rows before LAI measurements began
    ungroup() %>%
    filter(!is.na(Lai_500m))                                                      



# 2. filtering/checking for FLUXNET gap filled
# _QC columns = 0 means measured, while = 1 is good gap filled, and 2-3 is poor quality

# check distributions with a summary()
flux_QC <- full_data %>%
    group_by(SITE_ID) %>%
    dplyr::summarise(
        # total
        n_measurements = n(),
        
        # LE
        LE_best = sum(LE_QC == 0),
        LE_good = sum((LE_QC > 0) & (LE_QC <= 1)),
        LE_poor = sum(LE_QC > 1),
        
        # Net Rad. - only column to also have N/A values
        Rn_best = sum(Rn_QC == 0, na.rm = TRUE),
        Rn_good = sum((Rn_QC > 0) & (Rn_QC <= 1), na.rm = TRUE),
        Rn_poor = sum(Rn_QC > 1, na.rm = TRUE),
        
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
write_csv(flux_QC, "data/main/05_filtering/flux_QC.csv")


#3. Now I have the age ranges for the fluxnet data I can back-propagate the ages of the sites so they aren't static
# essentially, besnard2018 ages sites regardless of ranges, so FLUXNET data range does not change the site age
# e.g a '2 year old' site with a range from 2004-2010 is still seen as ~2 in 2010, when it should be ~8 (disturbance year = start - besnard age)
# so will attempt to re-age the sites based on fluxnet yearly data. note this is an estimate and does introduce uncertainties
# on top of this, i will try to treat age as continuous, so age will become year + (day as a fraction of year)

full_data_aged <- full_data %>%
    
    # group by site to get min year per site
    group_by(SITE_ID) %>%    
    
    # offset the age by the difference between observation date and start of observation date
    dplyr::mutate(SITE_AGE = SITE_AGE + year(TIMESTAMP) - min(year(TIMESTAMP)))  




# will filter out any qc scores > 1 and then save as the full dataset - leave out Rn_QC as it has NA values which messes up next steps
cols_filter <- c("LE_QC", "SW_rad_QC", "Tair_QC", "Wspeed_QC", "VPD_QC", "P_QC", "Pa_QC")


# set up final/full dataset
filtered_data <- full_data_aged %>%
    
    # checks against all columns in row simultaneously and drops full row if any QC > 1 ie. poor gap filling
    filter(if_all(all_of(cols_filter), \(x) x <= 1)) %>%  
    
    # and drop QC cols after filtering
    select(-all_of(cols_filter)) %>%      
    
    # add ET column (kg m-2 s-1 units in function so need to multiply by sec/day to get mm/day) - from bigleaf (https://search.r-project.org/CRAN/refmans/bigleaf/html/LE.to.ET.html)
    mutate(ET = (LE.to.ET(LE, Tair)) * 86400) %>%             
    
    # renaming for consistency
    dplyr::rename(                                                    
        Site_age = SITE_AGE,
        Latitude = LATITUDE,
        Longitude = LONGITUDE,
        Date = TIMESTAMP,
        Site_ID = SITE_ID) %>%   
    
    # rearranging columns
    relocate(Site_ID,                                          
             Date, 
             Latitude, 
             Longitude, 
             Cover_type, 
             Site_age,
             ET,
             LE, 
             Lai_500m,
             )


# df without Rn - MAIN dataset going forward
filtered <- filtered_data %>%
    
    # drop all Rn cols
    select(-Rn, -Rn_QC)                  


# **********************************************************
# failsafe for site age at a given site where age is known
# was having some issues with the site age changing from masked packages downstream, so adding this to fail the script if the age is false
# this is important as my analysis is very focused on age
# BE-Bra is in full pipeline, so used as reference.
# age expected here is 78 as not back-propagated yet
expected_age <- 78

actual_age <- filtered %>%
    filter(Site_ID == "BE-Bra", 
           Date == "2005-01-01") %>%
    pull(Site_age)

# stop execution and paste issue
if (!isTRUE(all.equal(actual_age, expected_age))) {
    stop(paste("BE-Bra site age has drifted from expected value!",
               "\nExpected age:", expected_age,
               "\nActual age:", actual_age))
}
# **********************************************************


# save out both
write_csv(filtered, "data/main/05_filtering/filtered_main.csv")

print("filtering.R complete")






