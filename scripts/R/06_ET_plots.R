# ET_plots.R - a script which generates ET plots against time per site and cleans up the date ranges
# as ET is the main target in this project, this script also ensures ET data time ranges are correct using plotting and editing ranges
# Author: Archie Benn
# Date: 5-6-2026

rm(list = ls())

library(tidyverse)
library(ggrepel)
library(skimr)
library(gridExtra)

# read in
df_06 <- read_csv("data/main/05_filtering/filtered_main.csv")


# function to generate ET vs.time plots across the site list
get_ET_sites <- function(site, data, path_to_dir){
    
    # plot ET vs time per site
    p <- data %>%
        filter(Site_ID == site) %>%
        ggplot(aes(x = Date, y = ET)) +
        geom_line(colour = "seagreen")
    
    png(here(path_to_dir, paste0(site, ".png")), width = 8, height = 4, units = "in", res = 300)
    print(p)
    dev.off()
}

# retrieve updated site IDs after some filtering
site_ids <- unique(df_06$Site_ID)

# apply function to each site                         
# walk(site_ids, \(site) get_ET_sites(site, df_06, "data/main/06_ET_plots/ET_time/"))



# certain time periods from these sites need to be adjusted/removed due to ET/LE measurement errors:
# remove time periods based on plots of ET
df_cleaned <- df_06 %>%
    
    # AU-Cum: remove before November 2012 
    filter(!(Site_ID == "AU-Cum" & Date < as.Date("2012-11-01"))) %>%
    # BE-Bra: remove before January 2005 
    filter(!(Site_ID == "BE-Bra" & Date < as.Date("2005-01-01"))) %>%
    # BR-Sa1: remove 2006-2009
    filter(!(Site_ID == "BR-Sa1" & Date >= as.Date("2006-01-01") & Date < as.Date("2009-01-01"))) %>%
    # BR-Sa3: remove after 2004
    filter(!(Site_ID == "BR-Sa3" & Date >= as.Date("2004-01-01"))) %>%
    # CA-Gro: remove before 2004 and after 2014
    filter(!(Site_ID == "CA-Gro" & Date < as.Date("2004-01-01"))) %>%
    filter(!(Site_ID == "CA-Gro" & Date >= as.Date("2014-01-01"))) %>%
    # CA-NS1: remove after September 2005
    filter(!(Site_ID == "CA-NS1" & Date >= as.Date("2005-09-01"))) %>%
    # CA-NS2: remove November 2004 - May 2005 and after September 2005
    filter(!(Site_ID == "CA-NS2" & Date >= as.Date("2004-11-01") & Date < as.Date("2005-05-01"))) %>%
    filter(!(Site_ID == "CA-NS2" & Date >= as.Date("2005-09-01"))) %>%
    # CA-NS3: remove after September 2005
    filter(!(Site_ID == "CA-NS3" & Date >= as.Date("2005-09-01"))) %>%
    # CA-NS5: remove after September 2005
    filter(!(Site_ID == "CA-NS5" & Date >= as.Date("2005-09-01"))) %>%
    # CA-NS6: remove after September 2005
    filter(!(Site_ID == "CA-NS6" & Date >= as.Date("2005-09-01"))) %>%
    # CA-NS7: remove after September 2005
    filter(!(Site_ID == "CA-NS7" & Date >= as.Date("2005-09-01"))) %>%
    # CA-Qfo: remove before July 2003
    filter(!(Site_ID == "CA-Qfo" & Date < as.Date("2003-07-01"))) %>%
    # CH-Dav: remove 2005-2006
    filter(!(Site_ID == "CH-Dav" & Date >= as.Date("2005-01-01") & Date < as.Date("2006-01-01"))) %>%
    # CH-Lae: remove before July 2004
    filter(!(Site_ID == "CH-Lae" & Date < as.Date("2004-07-01"))) %>%
    # DE-Hai: remove after 2010
    filter(!(Site_ID == "DE-Hai" & Date >= as.Date("2010-01-01"))) %>%
    # DE-Lnf: remove 2007-2010
    filter(!(Site_ID == "DE-Lnf" & Date >= as.Date("2007-01-01") & Date <= as.Date("2010-01-01"))) %>%
    # IT-Col: remove before 2007
    filter(!(Site_ID == "IT-Col" & Date < as.Date("2007-01-01"))) %>%
    # IT-Cpz: remove after 2009
    filter(!(Site_ID == "IT-Cpz" & Date >= as.Date("2009-01-01"))) %>%
    # IT-La2: REMOVE SITE
    filter(!(Site_ID == "IT-La2")) %>%
    # IT-Ren: remove before 2005
    filter(!(Site_ID == "IT-Ren" & Date < as.Date("2005-01-01"))) %>%
    # IT-Ro2: remove 2009-2010
    filter(!(Site_ID == "IT-Ro2" & Date >= as.Date("2009-01-01") & Date < as.Date("2010-01-01"))) %>%
    # PA-SPn: remove before March 2007 and after July 2009
    filter(!(Site_ID == "PA-SPn" & Date < as.Date("2007-03-01"))) %>%
    filter(!(Site_ID == "PA-SPn" & Date >= as.Date("2009-07-01"))) %>%
    # US-Blo: remove after October 2007
    filter(!(Site_ID == "US-Blo" & Date >= as.Date("2007-10-01"))) %>%
    # US-GBT: remove after 2005
    filter(!(Site_ID == "US-GBT" & Date >= as.Date("2005-01-01"))) %>%
    # US-GLE: remove before 2005
    filter(!(Site_ID == "US-GLE" & Date < as.Date("2005-01-01"))) %>%
    # US-Ha1: remove July 2009 - January 2011
    filter(!(Site_ID == "US-Ha1" & Date >= as.Date("2009-07-01") & Date < as.Date("2011-01-01"))) %>%
    # US-Me3: remove after September 2009
    filter(!(Site_ID == "US-Me3" & Date >= as.Date("2009-09-01"))) %>%
    # US-Me6: remove before March 2010
    filter(!(Site_ID == "US-Me6" & Date < as.Date("2010-03-01"))) %>%
    # US-Prr: remove before 2011
    filter(!(Site_ID == "US-Prr" & Date < as.Date("2011-01-01"))) %>%
    # US-Syv: remove June 2007 - June 2012
    filter(!(Site_ID == "US-Syv" & Date >= as.Date("2007-06-01") & Date < as.Date("2012-06-01"))) %>%
    # US-UMd: remove before July 2007
    filter(!(Site_ID == "US-UMd" & Date < as.Date("2007-07-01"))) %>%
    # US-WCr: remove September 2006 - January 2011
    filter(!(Site_ID == "US-WCr" & Date >= as.Date("2006-09-01") & Date < as.Date("2011-01-01"))) %>%
    # ZM-Mon: remove October 2007 and after June 2009
    filter(!(Site_ID == "ZM-Mon" & Date < as.Date("2007-10-01"))) %>%
    filter(!(Site_ID == "ZM-Mon" & Date > as.Date("2009-06-30")))


# generate and check new plots to ensure the ranges are now correct for ET measurements:
# retrieve updated site IDs after some filtering
site_ids <- unique(df_cleaned$Site_ID)

# re-run and save pngs to separate folder
# walk(site_ids, \(site) get_ET_sites(site, df_cleaned, "data/main/06_ET_plots/ET_time_adjusted/"))



# **********************************************************
# failsafe for site age at a given site where age is known
# was having some issues with the site age changing from masked packages downstream, so adding this to fail the script if the age is false
# this is important as my analysis is very focused on age
# BE-Bra is in full pipeline, so used as reference.
# age expected here is 87.088 as have now back-propagated with decimal (and is in 2005, aged 78 in 1996)
expected_age <- 87.088

actual_age <- df_cleaned %>%
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


# happy with those new plots and time ranges, so save out
write_csv(df_cleaned, "data/main/06_ET_plots/adjusted_dates_data.csv")

print("ET_plots.R complete")
