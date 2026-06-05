# cleaning.R - script for cleaning data based on findings from data exploration in 06_data_exploration.Rmd
# Author: Archie Benn
# Date: 04-06-2026

library(tidyverse)


# making some changes to the site date ranges based on explorations:

# AU-Cum: remove before November 2012 
# BE-Bra: remove before January 2005 
# BR-Sa1: remove 2006-2009
# BR-Sa3: remove after 2004
# CA-Gro: remove before 2004 and after 2014
# CA-NS1: remove after September 2005
# CA-NS2: remove November 2004 - May 2005 and after September 2005
# CA-NS3: remove after September 2005
# CA-NS5: remove after September 2005
# CA-NS6: remove after September 2005
# CA-NS7: remove after September 2005
# CA-Qfo: remove before July 2003
# CH-Dav: remove 2005-2006
# CH-Lae: remove before July 2004
# DE-Hai: remove after 2010
# DE-Lnf: remove 2007-2010
# IT-Col: remove before 2007
# IT-Cpz: remove after 2009
# IT-La2: REMOVE SITE
# IT-Ren: remove before 2005
# IT-Ro2: remove 2009-2010
# PA-SPn: remove before March 2007 and after July 2009
# US-Blo: remove after October 2007
# US-GBT: remove after 2005
# US-GLE: remove before 2005
# US-Ha1: remove July 2009 - January 2011
# US-Me3: remove after September 2009
# US-Me6: remove before March 2010
# US-Prr: remove before 2011
# US-Syv: remove June 2007 - June 2012
# US-UMd: remove before July 2007
# US-WCr: remove September 2006 - January 2011
# ZM-Mon: remove October 2007 and after June 2009

df <- read_csv("data/main/05_filtering/filtered_main.csv")


# remove time periods
df_filtered2 <- df %>%
    
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
    
    # IT-Ro1: REMOVE SITE (check as error somewhere)
    # filter(!(Site_ID == "IT-Ro1")) %>%
    
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


# save out
write_csv(df_filtered2, "data/main/07_cleaning/adjusted_dates_data.csv")
    
print("cleaning.R complete")

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


    
    
    
    
    
    














