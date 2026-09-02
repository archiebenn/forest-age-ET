# sorting.R - for setting up different dfs for data exploration e.g yearly data
# Author: Archie Benn
# Date: 5-6-2026

rm(list = ls())

library(tidyverse)
library(conflicted)

conflicted::conflict_prefer_all("dplyr", quiet = TRUE)

df_08_climate <- read_csv("data/main/07_climates/climates_data.csv")


# 1. adding some extra columns to main df
df_08_extra <- df_08_climate %>%
    
    # allocate sites into age ranges
    mutate(Age_range = cut(Site_age, 
                           breaks = c(0, 10, 20, 50, 100, 150, 320),
                           labels = c("0-10", "11-20", "21-50", "51-100", "101-150", "151-320"))) %>%
    
    # sum of precipitation over previous 14 days
    group_by(Site_ID) %>%
    # calculate last 14D sum of precip using the difference of the current cumsum of P and a 14 days lagged cumsum of P
    mutate(P_sum_14D = cumsum(P) - lag(cumsum(P), 14, default = 0)) %>%

    # NEED TO FIRGURE OUT DROPPING FIRST 14 DAYS OF EACH SITE (as P_sum_14D won't be true)
    # drop first 14 entries at each site to satisfy P_sum_14D:
    slice(-(1:14)) %>%

    ungroup() %>%
    group_by(Site_ID, year(Date)) %>%
    
    # only do this for full years of data to avoid taking winter averages if no peak dates exist in the year
    #filter(n() >= 365) %>%
    
    # get maximum value of 90 day cumulative sum of ET (so 90 day period back from this = max ET period)
    # divide by cumulative sum period to get daily peak average in 'high ET season'
    mutate(ET_90D_peak = max(cumsum(ET) - lag(cumsum(ET), 90, default = 0))/90) %>%
    
    # calculate DOY in radians to then get sin(DOY) and cos(DOY) for input features
    # scaled to the unit interval (year = 365, lap year of 366 not included as minimal difference in terms of what RF sees)
    mutate(DOY_radians = (2 * pi * yday(Date))/365,
           sin_DOY = sin(DOY_radians),
           cos_DOY = cos(DOY_radians)) %>%
    
    ungroup() %>%
   
    # rearrange
    relocate(Site_ID, 
             Date, 
             sin_DOY,
             cos_DOY,
             Latitude, 
             Longitude, 
             Continent,
             Cover_type, 
             Climate_zone,
             Site_age,
             Age_range,
             ET,
             ET_90D_peak,
             LE, 
             Lai_500m,
             P_sum_14D
    )



# 2. yearly average dataframe 
df_yearly <- df_08_extra %>%
    
    group_by(Site_ID, year(Date)) %>%
    
    summarise(Site_ID = first(Site_ID),
              
              # to check if years are complete (n = 365 or 366)
              n_days_coverage = n(), 
              Latitude = first(Latitude),
              Longitude = first(Longitude),
              Continent = first(Continent),
              Cover_type = first(Cover_type),
              Climate_zone = first(Climate_zone),
              Site_age = first(Site_age),
              Age_range = first(Age_range),
              
              # yearly sum of ET
              ET_year = sum(ET), 
              
              # sum of 90D peak ET
              ET_90D_peak_sum = max(cumsum(ET) - lag(cumsum(ET), 90, default = 0)),
              
              # get maximum value of 90 day cumulative sum of ET (so 90 day period back from this = max ET period)
              # divide by cumulative sum period to get daily peak average in 'high ET season'
              ET_90D_peak = max(cumsum(ET) - lag(cumsum(ET), 90, default = 0))/90,
              #ET_90D_peak_start = 
              
              Lai_mean = mean(Lai_500m),
              Lai_sd = sd(Lai_500m),
              P_sum_14D_mean = mean(P_sum_14D),
              P_sum_14D_sd = sd(P_sum_14D),
              SW_rad_mean = mean(SW_rad),
              SW_rad_sd = sd(SW_rad),
              Tair_mean = mean(Tair),
              Tair_sd = sd(Tair),
              Wspeed_mean = mean(Wspeed),
              Wspeed_sd = sd(Wspeed),
              VPD_mean = mean(VPD),
              VPD_sd = sd(VPD),
              
              # yearly sum of precip
              P_year = sum(P),                  
              Pa_mean = mean(Pa),
              Pa_sd = sd(Pa)) %>% 
    
    # need to ensure years are complete (ie drop non-complete years) as sum() is being used below for P and ET:
    # for complete years, n_days_coverage can be 365 or 366 (leap years)
    filter(n_days_coverage %in% c(365, 366)) 


# 3. need to do this separately
df_90D_summary <- df_yearly %>%
    
    group_by(Site_ID) %>%
    
    # now can get site summary for avergae daily ET during peak 90 days
    summarise(ET_90D_peak_mean = mean(ET_90D_peak),
              ET_90D_peak_sd = sd(ET_90D_peak))
    


# 4. site dataframe
df_sites <- df_08_extra %>%
    group_by(Site_ID) %>%
    summarise(Site_ID = first(Site_ID),
              Days_of_data = n_distinct(Date),
              Latitude = first(Latitude),
              Longitude = first(Longitude),
              Continent = first(Continent),
              Cover_type = first(Cover_type),
              Climate_zone = first(Climate_zone),
              Site_age = mean(Site_age),
              Age_range = first(Age_range),
              ET_mean = mean(ET),                    
              ET_sd = sd(ET),
              Lai_mean = mean(Lai_500m),
              Lai_sd = sd(Lai_500m),
              P_sum_14D_mean = mean(P_sum_14D),
              P_sum_14D_sd = sd(P_sum_14D),
              SW_rad_mean = mean(SW_rad),
              SW_rad_sd = sd(SW_rad),
              Tair_mean = mean(Tair),
              Tair_sd = sd(Tair),
              Wspeed_mean = mean(Wspeed),
              Wspeed_sd = sd(Wspeed),
              VPD_mean = mean(VPD),
              VPD_sd = sd(VPD),
              P_mean = mean(P),  
              P_sd = sd(P),
              Pa_mean = mean(Pa),
              Pa_sd = sd(Pa)) %>%

    # as kelvin to stop near-0 divisions
    mutate(moisture_index_est = P_mean/(Tair_mean + 273.15) * 1000)   


# 5. and now join to add peak 90 day daily ET average at sites
df_sites <- df_sites %>%
    
    left_join(df_90D_summary, by = "Site_ID") %>%
    
    relocate(
        Site_ID,
        Days_of_data,
        Latitude,
        Longitude,
        Continent,
        Cover_type,
        Climate_zone,
        Site_age,
        Age_range,
        ET_mean,
        ET_sd,
        ET_90D_peak_mean,
        ET_90D_peak_sd,
    )


# **********************************************************
# failsafe for site age at a given site where age is known
# was having some issues with the site age changing from masked packages downstream, so adding this to fail the script if the age is false
# this is important as my analysis is very focused on age
# BE-Bra is in full pipeline, so used as reference.
# age expected here is 87.088 as have now back-propagated with decimal (and is in 2005, aged 78 in 1996)
expected_age <- 87.088

actual_age <- df_08_extra %>%
    filter(Site_ID == "BE-Bra", 
           Date == "2005-02-01") %>%
    pull(Site_age)

# stop execution and paste issue
if (!isTRUE(all.equal(actual_age, expected_age))) {
    stop(paste("BE-Bra site age has drifted from expected value!",
               "\nExpected age:", expected_age,
               "\nActual age:", actual_age))
}
# **********************************************************

# save out
write_csv(df_08_extra, "data/main/08_sorting/df_main.csv")
write_csv(df_yearly, "data/main/08_sorting/yearly.csv")
write_csv(df_sites, "data/main/08_sorting/sites.csv")

print("sorting.R complete")

