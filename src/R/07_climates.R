# cleaning.R - script for adding site climate zones
# also adds koeppen climate zones 
# Author: Archie Benn
# Date: 04-06-2026

rm(list = ls())

if (!require(kgc)) install.packages("kgc")
library(tidyverse)


# read in data
df_07 <- read_csv("data/main/06_ET_plots/adjusted_dates_data.csv")

# look up vector to simplify zones a sites
koeppen_lookup <- c(
    
    # tropical - constant warm temps
    Af = "Tropical", Am = "Tropical", Aw = "Tropical", As = "Tropical",
    
    # dry - low precip rates
    BSh = "Dry", BSk = "Dry", BWh = "Dry", BWk = "Dry",
    
    # temperate - mild annual temps
    Cfa = "Temperate", Cfb = "Temperate", Cfc = "Temperate",
    Csa = "Temperate", Csb = "Temperate", Csc = "Temperate",
    Cwa = "Temperate", Cwb = "Temperate", Cwc = "Temperate",
    
    # continental - hot summers and cold winters
    Dfa = "Continental", Dfb = "Continental", Dfc = "Continental", Dfd = "Continental",
    Dsa = "Continental", Dsb = "Continental", Dsc = "Continental", Dsd = "Continental",
    Dwa = "Continental", Dwb = "Continental", Dwc = "Continental", Dwd = "Continental",
    
    # polar - constanty cold temps
    ET = "Polar", EF = "Polar"
)


# df for determining Koeggen climate zones based off coordinates of sites
site_climates <- df_07 %>%
    distinct(Site_ID, Longitude, Latitude) %>%
    mutate(
        rndCoord.lon = RoundCoordinates(Longitude, latlong = "lon"),
        rndCoord.lat = RoundCoordinates(Latitude, latlong = "lat"),
        Climate_zone = LookupCZ(data.frame(Site = Site_ID, Longitude, Latitude, rndCoord.lon, rndCoord.lat))
    ) %>%
    # simplify with lookup vector
    mutate(Climate_zone = koeppen_lookup[Climate_zone])   


# recombining 
df_climates <- df_07 %>%
    left_join(select(site_climates, Site_ID, Climate_zone), by = "Site_ID")


  
# 3. make a yearyl average dataframe 
df_years <- df_cleaned %>%
    group_by(Site_ID, year(Date)) %>%
    summarise(Site_ID = first(Site_ID),
              Latitude = first(Latitude),
              Longitude = first(Longitude),
              Cover_type = first(Cover_type),
              Climate_zone = first(Climate_zone),
              Site_age = first(Site_age),
              ET_year = sum(ET), 
              Lai_mean = mean(Lai_500m),
              SW_rad_mean = mean(SW_rad),
              Tair_mean = mean(Tair),
              Wspeed_mean = mean(Wspeed),
              VPD_mean = mean(VPD),
              P_year = sum(P),
              Pa_mean = mean(Pa))
    
    
    
    
    
    
    
    
    
    
    


    
    
    
    
    
    














