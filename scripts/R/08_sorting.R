# sorting.R - for setting up different dfs for data exploration e.g yearly data
# Author: Archie Benn
# Date: 5-6-2026

rm(list = ls())

library(tidyverse)

df_08_climate <- read_csv("data/main/07_climates/climates_data.csv")


# function to get sum of precipitation for last 14 day
get_14D_P <- function(df, date){
    
    # go back 2 weeks
    back_date = date - 14
    P_14D = 0
    
    # while back date is 14, 13, 12...1 days ago
    while (back_date <= date){
        
        # get P for that date
        P_day <- df %>%
            filter(Date == back_date) %>%
            # pull to select the double, not tibble (not select)
            pull(P)                          
        
        # add to '14D' sum in loop
        P_14D <- P_14D + P_day
        back_date <- back_date + 1
    }
        
    # return out sum for last 14 days
    return (P_14D)
}


# adding some extra columns
df_08_extra <- df_08_climate %>%
    
    # allocate sites into age ranges
    mutate(Age_range = cut(Site_age, 
                           breaks = c(0, 10, 20, 50, 100, 150, 320),
                           labels = c("0-10", "11-20", "21-50", "51-100", "101-150", "151-320"))) %>%
    
    # sum of precipitation over previous 14 days
    group_by(Site_ID) %>%
    mutate(P_sum_14D = get_14D_P(., Date)) %>%
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



# yearly average dataframe 
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


# site data
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



