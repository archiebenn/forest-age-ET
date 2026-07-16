# GAM_testing.R - forms many models using bam() to evaluate per site RMSE and R^2 across different predictor combinations
# Author: Archie Benn
# Date: 06-07-2026

# predictors to include was initially based on concurvity values in 09_GAM.Rmd, but extended to evaluate across different predictors
# such as comparing between met only, and met + structure data (ie, met + LAI)

rm(list = ls())

library(mgcViz)
library(tidyverse)
library(caret)
library(zoo)
library(mgcv)
library(wesanderson)
library(ggeffects)

set.seed(42)

df_10 <- read_csv("data/main/10_filtering2/df_10.csv")

# set site ID, cover type, and climate zone as factors
df_10 <- df_10 %>%
    mutate(across(c(Site_ID, Cover_type, Climate_zone, Continent), as.factor))

# to evaluate each model (determined in last script) held out site testing will be carried out  
# will hold out a site one-by-one and predict all rows' ET at that site, then repeat for other sites  
# using bam() as it's faster and will be forming many models for every site 

# set site list to loop over for held out site testing
sites <- c(unique(df_10$Site_ID))

# initialise empty lists to store raw predicted values, r^2 and rmse data in
stats_list = list()
predicted_list <- list()

for (i in sites){
    
    # setup train/test split for held out sites
    train <- df_10 %>%
        filter(Site_ID != i)
    
    test <- df_10 %>%
        filter(Site_ID == i)
    
    # use training data to form bams for 5 instances: full predictors age k20, full predictors age k5, without age, without Pa, and without age or Pa
    bam_full <- bam((ET)^(1/2) ~ 
                        
                        # random effects 
                        s(Site_ID, bs = "re") +               # site as random effect
                        
                        # fixed parametric factors
                        Cover_type +                # 13-7-26 
                        Climate_zone +              # 13-7-26 
                        Continent +                 # 16-7-26
                        
                        # fixed effects
                        s(Tair, bs = "cr", k = 20) + 
                        s(P_sum_14D, bs = "cr", k = 20) +
                        s(SW_rad, bs = "cr", k = 20) +
                        s(Wspeed, bs = "cr", k = 20) +
                        s(VPD, bs = "cr", k = 20) +
                        s(Lai_500m, bs = "cr", k = 20) +
                        #Age_range
                        s(Site_age, bs = "cr", k = 20)
                        #s(Pa, bs = "cr", k = 20)    
                    
                    # form only from training sites
                    , data = train)
    
    bam_nage <- update(bam_full, . ~ . -s(Site_age, bs = "cr", k = 20))
    bam_nlai <- update(bam_full, . ~ . -s(Lai_500m, bs = "cr", k = 20))
    bam_nage_nlai <- update(bam_nage, . ~ . -s(Lai_500m, bs = "cr", k = 20))
    
    models <- list(
        all = bam_full,
        no_age = bam_nage,
        no_lai = bam_nlai,
        no_age_no_lai = bam_nage_nlai
    )
    
    # loop over each of the 3 model names
    for (model in names(models)) {
        
        # predict ET from the BAM and save each in df
        # models[[model]] accesses the actual model object itself, just 'model' would be trying to access the string
        fitted <- as.numeric((predict(models[[model]], 
                          newdata = test,
                          exclude = "s(Site_ID)"))^2)
        
        
        # per row predicted values attached to test df per site - with architecture and model columns
        predicted_list[[paste(i, "_", model)]] <- test %>%
            mutate(model = model,
                   architecture = "GAM",
                   predicted_ET = fitted,
                   observed_ET = ET)
            
        
        # and adding to growing stats list - with architecture and model columns
        stats_list[[paste(i, "_", model)]] <- data.frame(
            model = model,
            architecture = "GAM",
            site = i,
            # rmse and r^2 per site by comparison to observed ET (test$ET)
            rmse = sqrt(mean((test$ET - fitted)^2)),
            r2 = 1 - sum((test$ET - fitted)^2) / sum((test$ET - mean(test$ET))^2)
        )
    
    }
    print(paste("completed ", i))
}


# then convert both lists to dfs and save as .csvs
preds_df <- bind_rows(predicted_list)
stats_df <- bind_rows(stats_list)

# write out
write_csv(preds_df, "data/main/12_GAM_testing/GAM_preds_results.csv")
write_csv(stats_df, "data/main/12_GAM_testing/GAM_stats_results.csv")

# also write out to other folder as this houses the other ML architecture results for same thing
write_csv(preds_df, "data/main/x_ML_results/GAM_preds_results.csv")
write_csv(stats_df, "data/main/x_ML_results/GAM_stats_results.csv")

print("GAM_testing.R complete")