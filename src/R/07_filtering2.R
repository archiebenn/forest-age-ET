# filtering2.R - script for filtering based on findings from data exploration in 06_data_exploration.Rmd
# Author: Archie Benn
# Date: 04-06-2026

rm(list = ls())
library(tidyverse)


# making some changes to the site date ranges based on explorations:

# AU-Cum: remove before November 2012 
# BE-Bra: remove before January 2005 (snip)
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
# IT-Ro1: REMOVE SITE (check as error somewhere)
# IT-Ro2: remove 2009-2010
# PA-SPn: remove before March 2007 and after July 2009
# US-Blo: remove after October 2007
# US-GBT: remove after 2005
# US-GLE: remove before 2005
# US-Ha1: remove July 2009 - January 2011
# US-Me3: remove after September 2009
# US-Me6: remove before March 2010
# US-Prr: remove before 2011
# US:Syv: remove June 2007 - June 2012
# US-UMd: remove before July 2007
# US-WCr: remove September 2006 - January 2011
# ZM-Mon: remove October 2007 and after June 2009














