# filtering2.R - further filtering based on georgraphic exploration in 09_data_exploration.Rmd
# Author: Archie Benn
# Date: 10-07-2026

rm(list = ls())

library(tidyverse)

# from data exploration, it's clear that Europe and N. America have by far the most amount of data
# far fewer sites in asia, s.america, and oceania, and these also have greatly different mean ET values per site
# so will be leaving these out (provide further justification for report)

df_08 <- read_csv("data/main/08_sorting/df_main.csv")


df_filtered2 <- df_08 %>%
    
    # only Europe/N American sites
    filter(Continent %in% c("Europe", "North America")) %>%
    
    # need to drop GF-Guy independently, as it is incorrectly labelled as Europe but is in French Guiana
    filter(Site_ID != "GF-Guy")


##################
# re-doing filtering for year/site data
df_sites <- read_csv("data/main/08_sorting/sites.csv")

df_sites2 <- df_sites %>%
    filter(Site_ID %in% df_filtered2$Site_ID)

df_yearly <- read_csv("data/main/08_sorting/yearly.csv")

df_yearly2 <- df_yearly %>%
    filter(Site_ID %in% df_filtered2$Site_ID)



##################
# save out new data
write_csv(df_filtered2, "data/main/10_filtering2/df_10.csv")
write_csv(df_sites2, "data/main/10_filtering2/df_sites2.csv")
write_csv(df_yearly2, "data/main/10_filtering2/df_yearly2.csv")

