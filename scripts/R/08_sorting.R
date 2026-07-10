# sorting.R - for setting up different dfs for data exploration e.g yearly data
# Author: Archie Benn
# Date: 5-6-2026

rm(list = ls())

library(tidyverse)

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
        
    # rearrange
    relocate(Site_ID, 
             Date, 
             Latitude, 
             Longitude, 
             Continent,
             Cover_type, 
             Climate_zone,
             Site_age,
             Age_range,
             ET,
             LE, 
             Lai_500m,
             P_sum_14D
    )

# save out
write_csv(df_08_extra, "data/main/08_sorting/df_main.csv")



# 2. yearly average dataframe 
df_yearly <- df_08_extra %>%
    
    group_by(Site_ID, year(Date)) %>%
    summarise(Site_ID = first(Site_ID),
              n_days_coverage = n(),                 # to check if years are complete (n = 365 or 366)
              Latitude = first(Latitude),
              Longitude = first(Longitude),
              Continent = first(Continent),
              Cover_type = first(Cover_type),
              Climate_zone = first(Climate_zone),
              Site_age = first(Site_age),
              Age_range = first(Age_range),
              ET_year = sum(ET),                     # yearly sum of ET
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
              P_year = sum(P),                       # yearly sum of precip
              Pa_mean = mean(Pa),
              Pa_sd = sd(Pa)) %>%
    
    # need to ensure years are complete (ie drop non-complete years) as sum() is being used below for P and ET:
    # for complete years, n_days_coverage can be 365 or 366 (leap years)
    filter(n_days_coverage %in% c(365, 366)) 

# write out yearly df
write_csv(df_yearly, "data/main/08_sorting/yearly.csv")


# 3. site dataframe
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
    mutate(moisture_index_est = P_mean/(Tair_mean + 273.15) * 1000)            # as kelvin to stop near-0 divisions

# write out site df
write_csv(df_sites, "data/main/08_sorting/sites.csv")

print("sorting.R complete")

