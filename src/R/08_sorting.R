# sorting.R - for setting up different dfs for data exploration e.g yearly data
# Author: Archie Benn
# Date: 5-6-2026

library(tidyverse)

df_08 <- read_csv(here("data/main/07_climates/climates_data.csv"))

# 1. make a yearly average dataframe 
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
              SW_rad_mean = mean(SW_rad),
              Tair_mean = mean(Tair),
              Wspeed_mean = mean(Wspeed),
              VPD_mean = mean(VPD),
              P_year = sum(P),                       # yearly sum of precip
              Pa_mean = mean(Pa))
