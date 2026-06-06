# sorting.R - for setting up different dfs for data exploration e.g yearly data
# Author: Archie Benn
# Date: 5-6-2026

rm(list = ls())

library(tidyverse)

df_08 <- read_csv("data/main/07_climates/climates_data.csv")

# yearly average dataframe 
df_yearly <- df_08 %>%
    group_by(Site_ID, year(Date)) %>%
    summarise(Site_ID = first(Site_ID),
              Latitude = first(Latitude),
              Longitude = first(Longitude),
              Cover_type = first(Cover_type),
              Climate_zone = first(Climate_zone),
              Site_age = first(Site_age),
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


# site data
df_sites <- df_08 %>%
    group_by(Site_ID) %>%
    summarise(Site_ID = first(Site_ID),
              Days_of_data = n_distinct(Date),
              Latitude = first(Latitude),
              Longitude = first(Longitude),
              Cover_type = first(Cover_type),
              Climate_zone = first(Climate_zone),
              Site_age = mean(Site_age),
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



