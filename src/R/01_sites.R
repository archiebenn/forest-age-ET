# sites.R - for initial site selection using Besnard 2018 paper on forest age
# Author: Archie Benn
# Date: 29-05-2026

rm(list = ls())
library(tidyverse)

# metadata on FLUXNET2015 sites
df <- read_csv("data/fluxnet/01_site_selection/daily_metadata.csv")

# sites with ages in Besnard 2018
besnard_sites <- c(
    "AU-Cum", "AU-How", "AU-Rob", "AU-Tum", "AU-Wom",
    "BE-Bra", "BE-Vie",
    "BR-Sa1", "BR-Sa3",
    "CA-Ca1", "CA-Ca2", "CA-Ca3", "CA-Gro", "CA-Man",
    "CA-NS1", "CA-NS2", "CA-NS3", "CA-NS5", "CA-NS6", "CA-NS7",
    "CA-Oas", "CA-Obs", "CA-Ojp", "CA-Qcu", "CA-Qfo",
    "CA-SJ1", "CA-SJ2", "CA-SJ3", "CA-TP1", "CA-TP3", "CA-TP4",
    "CA-TPD", "CA-WP1",
    "CH-Dav", "CH-Lae",
    "CN-Cha", "CN-Din", "CN-Qia",
    "CZ-BK1",
    "DE-Bay", "DE-Hai", "DE-Har", "DE-Lkb", "DE-Lnf",
    "DE-Meh", "DE-Obe", "DE-Tha", "DE-Wet",
    "DK-Sor",
    "ES-ES1", "ES-LMa",
    "FI-Hyy", "FI-Sod",
    "FR-Fon", "FR-Hes", "FR-LBr", "FR-Pue",
    "GF-Guy",
    "IL-Yat",
    "IT-Col", "IT-Cp2", "IT-Cpz", "IT-La2", "IT-LMa",
    "IT-Noe", "IT-Non", "IT-PT1", "IT-Ren", "IT-Ro1", "IT-Ro2",
    "IT-SR2", "IT-SRo",
    "JP-Tak", "JP-Tef", "JP-Tom",
    "MY-PSO",
    "NL-Loo",
    "PA-SPn",
    "PT-Esp", "PT-Mi1",
    "RU-Fyo",
    "SE-Fla", "SE-Nor", "SE-Sk1", "SE-Sk2",
    "UK-Gri", "UK-Ham",
    "US-Bar", "US-Blo", "US-Bn1", "US-Bn2", "US-Bn3",
    "US-Dk3", "US-GBT", "US-GLE", "US-Ha1", "US-Ho1", "US-Ho2",
    "US-Los", "US-LPH", "US-Me2", "US-Me3", "US-Me5", "US-Me6",
    "US-MMS", "US-MOz", "US-NC1", "US-NC2", "US-NR1", "US-Oho",
    "US-PFa", "US-Prr", "US-SO2", "US-SO3",
    "US-SP1", "US-SP2", "US-SP3", "US-SRM", "US-Syv",
    "US-UMB", "US-UMd", "US-WBW", "US-WCr", "US-Wrc",
    "VU-Coc",
    "ZM-Mon"
)

# get IGBP of each site 
igbp <- df %>%
    filter(VARIABLE == "IGBP") %>%
    select(SITE_ID, IGBP = DATAVALUE)

# forest IGBP codes (defined at https://fluxnet.org/data/badm-data-templates/igbp-classification/)
forest_IGBP <- c(
    "DBF",
    "DNF",
    "EBF",
    "ENF",
    "MF",
    "OSH"
)

# ages defined in supplementary materials for these forest sites
SITE_AGE <- c(300, 198, 83, 32,
                            78, 94,
                            300, 2,
                            78, 161, 154, 73, 39, 23,14,6,
                            80, 112, 102,
                            9, 37, 70, 98,
                            222, 184,
                            300, 96, 19,
                            31,
                            254, 2, 117, 76, 118,
                            85,
                            46, 83,
                            161, 34, 64,
                            300,
                            180, 63, 56, 89, 13, 188,
                            10, 19, 64, 54,
                            106,
                            106,
                            7,
                            236,
                            13, 176, 184, 96,
                            94, 20, 24, 22,
                            95, 110, 50, 150, 98,
                            300, 93, 90, 96,
                            88)

# site locations
lat <- df %>%
    filter(VARIABLE == "LOCATION_LAT", SITE_ID %in% besnard_sites) %>%
    select(SITE_ID, LATITUDE = DATAVALUE)

long <- df %>%
    filter(VARIABLE == "LOCATION_LONG", SITE_ID %in% besnard_sites) %>%
    select(SITE_ID, LONGITUDE = DATAVALUE)

merged <- merge(igbp, lat, by="SITE_ID")
merged <- merge(merged, long, by="SITE_ID")

# final sites
final_sites <- merged %>% 
    filter(IGBP %in% forest_IGBP,
           SITE_ID %in% besnard_sites) %>%
    add_column(SITE_AGE) 

write_csv(final_sites, "data/fluxnet/01_site_selection/site_ages.csv")

print("sites.R complete")


