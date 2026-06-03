# MSc Project notes

# April
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
