# GAM_testing.R - forms many models using bam() to evaluate per site RMSE and R^2 across different predictor combinations
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

df_08 <- read_csv("data/main/08_sorting/df_main.csv")

# set site ID as a factor
df_08$Site_ID <- as.factor(df_08$Site_ID)

# to evaluate each model (determined in last script) held out site testing will be carried out  
# will hold out a site one-by-one and predict all rows' ET at that site, then repeat for other sites  
# using bam() as it's faster and will be forming many models for every site 

# set site list to loop over for held out site testing
sites <- c(unique(df_08$Site_ID))

# initialise empty list to store r^2 and rmse data in
results_list = list()

for (i in sites){
    
    # setup train/test split for held out sites
    train <- df_08 %>%
        filter(Site_ID != i)
    
    test <- df_08 %>%
        filter(Site_ID == i)
    
    # use training data to form bams for 5 instances: full predictors age k20, full predictors age k5, without age, without Pa, and without age or Pa
    bam_full <- bam(ET ~ 
                        s(Site_ID, bs = "re") +               # site as random effect
                        s(Site_age, bs = "cr", k = 20) +
                        s(Lai_500m, bs = "cr", k = 20) +
                        s(P_sum_14D, bs = "cr", k = 20) +
                        s(SW_rad, bs = "cr", k = 20) +
                        s(Tair, bs = "cr", k = 20) +     
                        s(Wspeed, bs = "cr", k = 20) +
                        s(VPD, bs = "cr", k = 20) 
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
        fitted <- predict(models[[model]], 
                          newdata = test,
                          exclude = "s(Site_ID)")
        
        # add to growing list
        results_list[[paste(i, "_", model)]] <- data.frame(
            
            bam_model = model,
            site = i,
            
            # rmse and r^2 per site by comparison to observed ET (test$ET)
            rmse = sqrt(mean((test$ET - fitted)^2)),
            r2   = cor(test$ET, fitted)^2)
    }
    print(paste("completed ", i))
}


# then convert results list to a df and save as a .csv
validations_df <- do.call(rbind, results_list)

# write out
write_csv(validations_df, "data/main/10_GAM_testing/results.csv")

print("GAM_testing.R complete")