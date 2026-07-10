# MSc Project notes

# May
## 29-5-26  
- created Makefile structure  
- started Rproj  
- downloaded FLUXNET2015 site metadata as a .csv  
- used Besnard2018 aged sites to write `sites.R` which takes this metadata and filters to keep sites in besnard with location data, ages attached, and forest types  
- saves this as a csv for downstream FLUXNET downloads  

## 30-5-26  
- started `all_site_map.R`  
- used rnaturalearth and other packages to pinpoint the sites with ages on a global map in ggplot  
- saved this map using tikzDevice for use in LaTeX  
- took a while to sort out the micromamba stuff as the packages were acting up but should be fine now  

# June
## 1-6-26
- started `fluxnet.R`  
- downloaded 2x DD fullset FLUXNET datasets as a trial  
- selected variables to keep using papers and the variables website page for FLUXNET  
- ran through both DD datasets, selected variables, and concatenated alongside other site metadata from `01_sites.R`  
- re-named stuff to keep order in scripts etc.  
- should be ready for `05_engineering.R` soon after getting LAI data  

## 2-6-26
- started `lai.R`  
- ```{
      "product": "MCD15A3H", 
      "description": "MODIS/Terra+Aqua Leaf Area Index/FPAR (LAI/FPAR) 4-Day L4 Global 500 m SIN Grid", 
      "frequency": "4-Day", 
      "resolution_meters": 500
    }, ```
- found the above product from MODIS for LAI  
- and all the QC bands too  
- wrote a function/script which uses the fluxnet site info and downloads the MODIS products to a large df  
- then started `filtering.R`  
- this starts by filtering LAI based on the `FparLai_QC` column which is a bit encoded quality metric for LAI values  
- basically if bit 0 = 0, it's good quality. if bit 0 = 1, poor. so used a `bitwAnd()` function to determine this based on the column values  
- then set any poor quality LAI values to NA  
- then used `zoo::na.approx(Lai_500m, na.rm = F))` to linearly interpolate between the NA values for LAI (as only measured every 4 days and also from setting poor quality ones to NA before.  
- this may be justified as LAI is a slow changing variable, so interpolating between the values, while not ideal, is possibly representative of true LAI  
- filtered the LAI products for QC bit 0 = 0, and the fluxnet data for QC <= 1  
- created `sort_csv.sh` which takes the fullset data of FLUXNET2015 (all sites) in zips and extracts only the DD csvs for the rest of the scripts  
- used make sort and make fluxnet on the full dataset (~279k row csv) with ages attached   

## 3-6-26
- adapted `lai.R` to allow re-runs to not have to download each site again if the site csv exists  
- doing first run on all 73 sites to get LAI  
- `filtering.R` essentially now means all data should be good quality and trustworthy  

## 4-6-26
- realised I had missed out NETRAD on `fluxnet.R`  
- spoke to martin as if I include it I drop lots of dates, but NETRAD is a key driver in ET models  
- decided to create 2 datasets - one without (full, continuous dataset), and one with Rn, but will essentially ignore the Rn one unless I have time later on  
- did ET vs time plots and cut out date ranges where ET is not well measured  

## 5-6-26
- re-orered a lot of scripts today  
- e.g took out a lot of pre-processing that was happening in the `data_exploration.Rmd` file and added scripts before this to alow clean import of data into exploration  
- added Koeppen climate zones to the site data  


## 6-6-26
- sorted main data for yearly data and per-site data  
- worked out that Besnard aged sites based on their date at the start of FLUXNET recordings (cross-checked references and dates within the publications to these ages)  
- then added to `05_filtering.R` to adapt the ages of the sites based on their measurement year, such that every extra year adds a year to the age of the site  
- this should be better than static ages, especially for young sites where ET may change significantly year to year and should help ML models learn better  
- however, this is quite uncertain. some of the sites follow this pattern and the literature disturbance dates (ie. age = fluxnet start - disturbance year), but some are off by a few years... what is more important though is that it is true that each consecutive year does +1 to the site age, just the original ages may be off/uncertain.  
- speak to martin about this and see what he says  

## 9-6-26
- A lot more data exploration in the .Rmd  
- tried (and kind of failed) to make a function which summed last 14D of precipitation per row  
- ended up using cumsum(P) which is much bette r   

## 16-6-26
- started GAM.Rmd  
- learning about GAM/smooth function stuff 

## 17-6-26
- More work on data exploration Rmd
- removed first 14 days at each site after calculating cumulative 14D precip (this value is incorrect/inaccurate for first 14 days)  
- removed non-complete site years when forming df_sites as realised I was calculating sum(P) and sum(ET) on all years inc. non-complete ones which is wrong  
- looked into values for moisture indices/aridity indices but not exact with PET/ET etc. - just did P/Tair  
- plotted P against Tair means for sites to try and gauge energy vs water limited sites  
- started more GAM.Rmd but i want to make sure data exploration stuff is complete before I begin this so will work on that more

# July
## 6-7-26  
- last few days have been doing a lot of GAM things  
- like making 5 types of models and doing hold out on single site testing for r2 and rmse  
- looked into concurvity issues with Pa, site age, and site_ID, and making models with combinations of these included  
- and want to look into trying to get some sort of relationship between ET-age explicitly mapped, rather than relying just on exact age data in models, like besnard f(age)

## 8-7-26
- deciding to drop pressure from GAMs - it doesn't seem to add anything useful and just brings up concurvity issues with the site_ID/age  
- martin also agreed with dropping Pa when i spoke to him last on the 6th, so no Pa used going forwards in GAMs (can test in RF etc. though)
- started `11_GAM_exploration.Rmd`

## 9-7-26 
- looked into RMSE nd R-squared values across the 68 sites from the 'No age' (ie. baseline) model across climate zones, cover types, and on maps  
- This is all on GAM exploration map  
- Martin also sent me some papers and links to look at for plots  
- Need to do lots tomorrow in the library for the exploration of these results and maybe some RF/other ML stuff  

## 10-7-26
- did quite a bit today but not a lot of 'forward' progress  
- re-ran all the GAM formations and used the sqrt ET transformation (and back transformation too)  
- also decided to only focus on sites from north america and europe, so took a while attaching continental data to the dfs to the filter on  
- now back at a point where I can do GAM exploration next week and start RF stuff in python  
- looking like age might not be a supporting factor so far from the GAMs, but let's see with RF etc.