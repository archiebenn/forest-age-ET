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
    mutate(P_sum_14D = cumsum(P) - lag(cumsum(P), 14, default = 0))

    # NEED TO FIRGURE OUT DROPPING FIRST 14 DAYS OF EACH SITE (as P_sum_14D won't be true)

    ungroup() %>%
        
    # rearrange
    relocate(Site_ID, 
             Date, 
             Latitude, 
             Longitude, 
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
              Latitude = first(Latitude),
              Longitude = first(Longitude),
              Cover_type = first(Cover_type),
              Climate_zone = first(Climate_zone),
              Site_age = first(Site_age),
              Age_range = first(Age_range),
              ET_year = sum(ET),                     # yearly sum of ET
              Lai_mean = mean(Lai_500m),
              Lai_sd = sd(Lai_500m),
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
              Pa_sd = sd(Pa))

# write out yearly df
write_csv(df_yearly, "data/main/08_sorting/yearly.csv")


# 3. site dataframe
df_sites <- df_08_extra %>%
    group_by(Site_ID) %>%
    summarise(Site_ID = first(Site_ID),
              Days_of_data = n_distinct(Date),
              Latitude = first(Latitude),
              Longitude = first(Longitude),
              Cover_type = first(Cover_type),
              Climate_zone = first(Climate_zone),
              Site_age = mean(Site_age),
              Age_range = first(Age_range),
              ET_mean = mean(ET),                    
              ET_sd = sd(ET),
              Lai_mean = mean(Lai_500m),
              Lai_sd = sd(Lai_500m),
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
              Pa_sd = sd(Pa))

# write out site df
write_csv(df_sites, "data/main/08_sorting/sites.csv")



