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

## 12-7-26  

- trying to do some more GAM exploration  
- also remade gam formation script to also output raw predictions per row so i can do a time-series prediction and fit observed vs. fitted on the same graph  

## 13-7-26

- setup loop to do observd vs. fitted on same graphs from GAMs  
- started and finished `14_engineering.py` to engineer features for ML stuff  
- started random forest and have done a few tests on single held out sites but need to work on this more  

## 14-7-26  

- got optuna running on the RF models and did some one site held out testing  
- need to loop over all sites as with the GAM and save these resuklts to visualise in R tomorrow too like with GAM  
- then need to start looking at why these results may be as they are - what is causing under/over estimations? what could the models be missing? etc.  

## 15-7-26

- formed the full RF held out site train/test loop for the 4 models and across all sites which takes about 2hrs to run  
- so not i have the full RF and GAM datasets and predictions compared to observed  
- also got SHAP analysis running so I can have a look through that soon too

## 16-7-26  

- generated loops to get the RF and GAM plots formed and saved to folders in `17_plots_generate.R`  
- made `18_single_sites.Rmd` in which I have started to explore the results of the RF and GAM preds/stats  
- had meeting with martin and need to think of proper questions now, not just more analysis  
- having said that, I do want to try to form XGBoost models in the same was as the RF ones  
- also want to try setting age to be incrementing every day of the year rather than a static value every day of the same year  
- so tomorrow will give that a go and then also have to do a full re-run i'd imagine bc of that  
- also more exploration of SHAP/RF/GAM stuff etc in the `.Rmd` file  

## 17-7-26

- ran `18_single_sites.Rmd` on loop for al sites to generate a load of plots of SHAP alongside obs and fitted  
- basically took all day but have those plots now  

## 20-7-26  

- spoke to JOnah at party on weekend and he told me about time series decomposition for time series data  
- actually really nice idea to split up prediction/observed data into into seasonal, trend, and variance/noise components  
- generated a function which i can then apply to all site/arch/mods  
- however, should really look into nicer ways of converging all of this info rather than having loads of separate plots  
- so tomorrow look into doing this and maybe also applying to the plots from the other day too  

## 21-7-26

- didn't do the converging that time series decomposition info, but would be useful  
- spent a long time swapping from Rstudio/VS Code to Positron so a bit of a waste of the morning  
- started on forming my main questions for the project. I think I will cover it broadly as follows:  
- MAIN Q: what characterises a successful ET RF (or other ML model) training dataset, with a focus on applying forest age. Essentially "If I want to build a ML RF model which generalises well to unseen data, what do I need to consider and can forest age help?"  

1. General composition effects of training set variables on 1-5 held out single sites (short section comparing subsequent addition of variables and this effect on RF predictions - including adding age as a final feature)  
2. Predicting ET on a test set of ~10 random held out sites from random combinations of training sites (comparing `all' and`no\age` models)  
3. Predicting recent years based on historical training within long term sites (compare `all' and`no\_age' models)  

- This should allow a focused but broad application of investigating forest age for ET RF models  
- In terms of part 2: need to make a pipeline which can randomise 10 sites as tests and save their characteristics, then also randomise a further 25-30 for training and save their characteristics, before forming a RF model and testing, and then saving out those metrics, all to be repeated many times over. Also should stratify random draws somewhat (climate zone, cover type etc.)  
- tomorrow i need to finish this plan mostly and also do the age as more continuous. ie age = age_years + (day in current_year)/len(day(current_year))

## 22-7-26

- spent most of the day fixing issues with site age so now i know i can trust it (with fail safes at ends of scripts to check if a single row is identical along pipeline)  
- setup age to act more as a continuous variable wthin sites, so age is now (age in years) + (fraction of day within year)  
- re-ran the whole pipeline start to finish with `make all`, and glad that that works well/perfectly  
- also removed `no_lai` and `no_ge_no_lai` as i am only planning on assessing impacts of age  
- need to now actually get the plan finished and sent to martin over the weekend at some point

## 23-7-26  

- re-ran the entire pipeline with `no_lai` and `no_ge_no_lai` models removed (much faster) while on the train to London

## 24-7-26

- working on my dissertation plan for Martin and 'finalising' the exact questions/areas I want to look at  
- i want to also be able to characterise the sites/datasets used at model formation, and have been looking at some ways to do this based on my sites dataset  
- looking at Gower's Distance calculations which can use continuous and categorical information about sites to characterise them  (https://towardsdatascience.com/gowers-distance-for-mixed-categorical-and-numerical-data-799fedd1080c/)  

# August

## 5-8-26

- setup and finished `analysis_1.2.py` script so i can now run that on the full set of held out data  
- need to now figure out what i will do with these results/how to cluster the training sites and metrics properly downstream in R (cluster analysis all in R)  
- also need to do the other 2 scripts soon ish  

# 9-8-26

- setup and finished `analysis_1.1.py` and ran this with the iteratively added features to test r-squared and rmse for the medoid sites  
- decided to remove the categorical variables from models as these are largely site dpeendent and also complicates model  
- so now just need to do temporal analysis and then get on with analysing it all  


# 10-8-26

- found a bug which caused the koeppen lookup index thing to be mis-categorising lots of the sites (to do with index values being returned instead of characters..., and meant sites in Germany and France were coming up as 'Tropical' etc.), so fixed that and then re-ran all scripts from there downstream  
- finished `analysis_2.py`, and now just need to run it to get results before doing analysis exploration in 3 `.Rmd` files and tarting my actual final plots/stats  



