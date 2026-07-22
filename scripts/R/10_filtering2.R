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



# **********************************************************
# failsafe for site age at a given site where age is known
# was having some issues with the site age changing from masked packages downstream, so adding this to fail the script if the age is false
# this is important as my analysis is very focused on age
# BE-Bra is in full pipeline, so used as reference.
# age expected here is 87.088 as have now back-propagated with decimal (and is in 2005, aged 78 in 1996)
expected_age <- 87.088

actual_age <- df_filtered2 %>%
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

##################
# save out new data
write_csv(df_filtered2, "data/main/10_filtering2/df_10.csv")
write_csv(df_sites2, "data/main/10_filtering2/df_sites2.csv")
write_csv(df_yearly2, "data/main/10_filtering2/df_yearly2.csv")

print("filtering2.R complete")
