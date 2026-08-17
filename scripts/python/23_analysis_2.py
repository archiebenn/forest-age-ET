# analysis_2.py - part 2 of final analysis for dissertation
# this script is the temporal preiction aspect of the dissertation - it builds RF models on historical FLUXNET data per site and predicts the most recent data
# date: 10-8-2026
# author: Archie Benn sj19031@bristol.ac.uk


import os
import pandas as pd
import numpy as np
from datetime import datetime
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import r2_score, mean_squared_error, mean_absolute_error

# set wd 
os.chdir('/home/ab/Dropbox/university/github/bbinf_project')

# timestamp for runs/file names e.g 0505_1738 
timestamp = datetime.now().strftime("%d%m_%H%M")

# *********************************************
# 1. DATA SETUP
# *********************************************

df = pd.read_csv("data/main/14_pre_processing/df_ml_ready.csv")
df_sites = pd.read_csv("data/main/21_analysis_1.1/cleaned_sites.csv")


# *********************************************
# 2. TRAIN/TEST SPLIT FILTERING
# *********************************************
# 80/20 train:test, so needs at least 5 years of coverage = 1825 days of coverage
# also, as some sites have gaps this should be continuous so need to filter on dates, not just number of days of data

sites_long = df_sites.loc[(df_sites["Days_of_data"] >= 1825)]
df_cleaned = df[df["Site_ID"].isin(sites_long["Site_ID"])]



# *********************************************
# 3. FUNCTIONS
# *********************************************

# 3.1 function to split up train/test 80:20
def train_test_8020(site_df):

    # row id where 80% of rows in df lies
    split_id = int(len(site_df) * 0.8)

    # earliest 80% and latest 20% 
    train_80 = site_df.iloc[:split_id]
    test_20 = site_df.iloc[split_id:]

    return train_80, test_20


# 3.2 function to fit RF models with training data
def rf_train_temporal(train_df, features_age, features_no_age, target = "ET"):

    #params defined from script 15.5
    params = {
            "n_estimators": 350, 
            "max_depth": 17, 
            "min_samples_leaf": 19,
            "max_features": 0.35
        }

    # 1. AGE MODEL (full features)
    rf_age = RandomForestRegressor(
        # use parameters defined above (** expands dict)
        **params,
        random_state=42,
        # use all except one core
        n_jobs=-2)
    # fit
    rf_age.fit(train_df[features_age], train_df[target])

    # 2. NO AGE MODEL
    rf_no_age = RandomForestRegressor(
        # use parameters defined above (** expands dict)
        **params,
        random_state=42,
        # use all except one core
        n_jobs=-2)
    # fit
    rf_no_age.fit(train_df[features_no_age], train_df[target])

    # return the fitted models
    return rf_age, rf_no_age


# 3.3 function to predict and return metrics and raw preds 
def rf_pred(age_model, no_age_model, test_df, features_age, features_no_age, target = "ET"):

    # predict!
    preds_age = age_model.predict(test_df[features_age])
    preds_no_age = no_age_model.predict(test_df[features_no_age])


    # metrics
    rmse_age = np.sqrt(mean_squared_error(test_df[target], preds_age))
    rmse_no_age = np.sqrt(mean_squared_error(test_df[target], preds_no_age))
    r2_age = r2_score(test_df[target], preds_age)
    r2_no_age = r2_score(test_df[target], preds_no_age)
    mae_age = mean_absolute_error(test_df[target], preds_age)
    mae_no_age = mean_absolute_error(test_df[target], preds_no_age)

    # return dict of metrics
    return {
        "rmse_age": rmse_age,
        "rmse_no_age": rmse_no_age,
        "mae_age": mae_age,
        "mae_no_age": mae_no_age,
        "r2_age":r2_age,
        "r2_no_age": r2_no_age,
        "preds_age": preds_age,
        "preds_no_age": preds_no_age
    }




# *********************************************
# 4. SETUP FEATURES
# *********************************************
# features to exluce in all instances
# features in main df to exlude in all instances
non_features = [
                    'Site_ID',       
                    'Latitude',
                    'Longitude',
                    'Age_range',
                    'ET',
                    "ET_90D_peak",
                    "year(Date)",
                    'LE',
                    'P',              # have cumulative sum already
                    'Pa',             # dropped
                    'Date',
                    'Unnamed: 0',     # not sure where this came from

                    # the following categorical columns will all be dropped as a test 9-8-26 (from 1.1 analysis)
                    "Continent_Europe",
                    "Continent_North America",
                    "Cover_type_DBF",
                    "Cover_type_EBF",
                    "Cover_type_ENF",
                    "Cover_type_MF",
                    "Cover_type_OSH",
                    "Climate_zone_Continental",
                    "Climate_zone_Polar",
                    "Climate_zone_Temperate",
                    "Climate_zone_Tropical"
                    ]


# age column to drop for the no age model
age_column = 'Site_age'

features_age = [c for c in df_cleaned.columns if c not in non_features]
features_no_age = [c for c in df_cleaned.columns
                    if c not in non_features and c != age_column]



# *********************************************
# 5. MAIN LOOP
# *********************************************
results = []
predictions_full = []

# loop over each site in the cleaned df
for site in sites_long["Site_ID"]:

    # 1. set site as main df and sort by date (should already be in order but just to be safe)
    df_site = df_cleaned[df_cleaned["Site_ID"] == site].sort_values("Date").reset_index(drop=True)

    # 2. setup train/test split
    train_df, test_df = train_test_8020(site_df=df_site)

    # 3. fit age and no age models
    rf_age, rf_no_age = rf_train_temporal(train_df=train_df,
                                          features_age=features_age,
                                          features_no_age=features_no_age)

    # 4. compute preds and metrics
    metrics = rf_pred(age_model=rf_age,
                      no_age_model=rf_no_age,
                      test_df=test_df,
                      features_age=features_age,
                      features_no_age=features_no_age)

    # 5. save out metrics to results
    results.append({
        "test_site": site,
        "test_site_cluster": df_sites.loc[df_sites["Site_ID"] == site, "cluster"].values[0],
        "rmse_age": metrics["rmse_age"],
        "rmse_no_age": metrics["rmse_no_age"],
        "mae_age": metrics["mae_age"],
        "mae_no_age": metrics["mae_no_age"],
        "r2_age": metrics["r2_age"],
        "r2_no_age": metrics["r2_no_age"],
    })

    # save predictions (large table)
    for i in range(len(test_df)):
        predictions_full.append({
        "test_site": site,
        "test_site_cluster": df_sites.loc[df_sites["Site_ID"] == site, "cluster"].values[0],
        "timestamp": test_df.iloc[i]["Date"],
        "y_true": test_df.iloc[i]["ET"],
        "pred_age": metrics["preds_age"][i],
        "pred_no_age": metrics["preds_no_age"][i],
        "rmse_age": metrics["rmse_age"],
        "rmse_no_age": metrics["rmse_no_age"],
        "mae_age": metrics["mae_age"],
        "mae_no_age": metrics["mae_no_age"],
        "r2_age": metrics["r2_age"],
        "r2_no_age": metrics["r2_no_age"],
    })

    print(f"Temporal predictions and metrics for {site} complete")
    

# save out results and predictions
results_df = pd.DataFrame(results)
predictions_df = pd.DataFrame(predictions_full)

results_df.to_csv(f"data/main/23_analysis_2/metrics_{timestamp}.csv", index=False)
predictions_df.to_csv(f"data/main/23_analysis_2/predictions_{timestamp}.csv", index=False)

print("analysis_2.py complete")