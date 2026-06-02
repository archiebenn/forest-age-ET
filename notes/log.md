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
- ``` {
  "bands": [
    {
      "band": "FparExtra_QC", 
      "description": "Extra detail Quality for LAI and FPAR", 
      "units": "class-flag", 
      "valid_range": "0 to 254", 
      "fill_value": "255"
    }, 
    {
      "band": "FparLai_QC", 
      "description": "Quality for LAI and FPAR", 
      "units": "class-flag", 
      "valid_range": "0 to 254", 
      "fill_value": "255"
    }, 
    {
      "band": "FparStdDev_500m", 
      "description": "Standard deviation of FPAR", 
      "units": "percent", 
      "valid_range": "0 to 100", 
      "fill_value": "255", 
      "scale_factor": "0.01", 
      "add_offset": "0"
    }, 
    {
      "band": "Fpar_500m", 
      "description": "Fraction of photosynthetically active radiation", 
      "units": "percent", 
      "valid_range": "0 to 100", 
      "fill_value": "255", 
      "scale_factor": "0.01", 
      "add_offset": "0"
    }, 
    {
      "band": "LaiStdDev_500m", 
      "description": "Standard deviation for LAI", 
      "units": "m^2/m^2", 
      "valid_range": "0 to 100", 
      "fill_value": "255", 
      "scale_factor": "0.1", 
      "add_offset": "0"
    }, 
    {
      "band": "Lai_500m", 
      "description": "Leaf area index", 
      "units": "m^2/m^2", 
      "valid_range": "0 to 100", 
      "fill_value": "255", 
      "scale_factor": "0.1", 
      "add_offset": "0"
    }
  ]
}```
- and all that info too   
