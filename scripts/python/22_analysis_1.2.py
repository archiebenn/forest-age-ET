# analysis_1.2.py - part 1.2 of final analysis for dissertation
# this script builds rf models (with and without age) based on 20 randomly samples training sites and predicts on the 7 medoid (representative) test sites, before saving metrics
# date: 5-8-2026
# author: Archie Benn sj19031@bristol.ac.uk

# does adding age reduce error?
# does age help more for ecologically distant test sites?
# does age help more for certain clusters?

import os
import pandas as pd
import numpy as np
from datetime import datetime
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import r2_score, mean_squared_error

# set wd 
os.chdir('/home/ab/Dropbox/university/github/bbinf_project')

# timestamp for runs/file names e.g 0505_1738 
timestamp = datetime.now().strftime("%d%m_%H%M")

# *********************************************
# 1. DATA SETUP
# *********************************************

df = pd.read_csv("data/main/14_pre_processing/df_ml_ready.csv")
df_sites = pd.read_csv("data/main/21_analysis_1.1/cleaned_sites.csv")
df_gower = pd.read_csv("data/main/20_gower/gower_matrix.csv", index_col=0)
df_cluster_labels = pd.read_csv("data/main/20_gower/df_cluster_labels.csv")

df_cleaned = df[df["Site_ID"].isin(df_sites["Site_ID"])]

# all sites list
all_sites = df_sites["Site_ID"].astype(str).tolist()

# test sites list (medoids)
test_sites = df_cluster_labels.iloc[:, 1].astype(str).tolist()

# training pool
train_pool = [s for s in all_sites if s not in test_sites]



# *********************************************
# 2. FUNCTIONS
# *********************************************

# 2.1 function to randomly select 20 sites from training sites list
def train_selecta(main_df, train_sites, n):

    chosen = np.random.choice(train_sites, size=n, replace=False)
    train_df = main_df[main_df["Site_ID"].isin(chosen)].copy()

    return train_df



# 2.2 random forest training function - trains on training df
def rf_train(train_df, features_age, features_no_age, target):

    #params defined in script 15
    params = {
            "n_estimators": 250, 
            "max_depth": 10, 
            "min_samples_leaf": 10,
            "max_features": 0.6
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



# 2.3 function to form predictions and metrics given the models
# this will run per site in the test site list (ie. per medoid)
def rf_pred(age_model, no_age_model, test_df, features_age, features_no_age, target):

    # predict!
    preds_age = age_model.predict(test_df[features_age])
    preds_no_age = no_age_model.predict(test_df[features_no_age])

    # metrics
    rmse_age = np.sqrt(mean_squared_error(test_df[target], preds_age))
    rmse_no_age = np.sqrt(mean_squared_error(test_df[target], preds_no_age))
    r2_age = r2_score(test_df[target], preds_age)
    r2_no_age = r2_score(test_df[target], preds_no_age)

    # return dict of metrics
    return {
        "rmse_age": rmse_age,
        "rmse_no_age": rmse_no_age,
        "r2_age":r2_age,
        "r2_no_age": r2_no_age,
        "preds_age": preds_age,
        "preds_no_age": preds_no_age
    }



# *********************************************
# 3. SETUP FEATURES
# *********************************************
# features to exluce in all instances
non_features = [
                    'Site_ID',       
                    'Latitude',
                    'Longitude',
                    'Age_range',
                    'ET',
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
# 4. MAIN LOOP
# *********************************************
results = []
predictions_full = []

# loop over 100 random training sets
for run in range(100):

    # set NumPy seed to change every run (otherwise constant training set)
    np.random.seed(run)

    # 1. select training sites
    train_df = train_selecta(main_df=df_cleaned,
                             train_sites=train_pool,
                             n=20)

    # 2. train both age and no_age models
    rf_age, rf_no_age = rf_train(train_df=train_df,
                                 features_age=features_age,
                                 features_no_age=features_no_age,
                                 target="ET")

    # loop over the 7 medoid/cluster test sites
    for site in test_sites:

        # set test df to this site
        test_df = df_cleaned[df_cleaned["Site_ID"] == site]

        # 3. get metrics from predictions
        metrics = rf_pred(age_model=rf_age,
                        no_age_model=rf_no_age,
                        test_df=test_df,
                        features_age=features_age,
                        features_no_age=features_no_age,
                        target="ET")

        # compute mean training set Gower distance to this test site
        mean_gower = df_gower.loc[train_df["Site_ID"].unique(), site].mean()

        # save out metrics to results
        results.append({
            "run": run,
            "test_site": site,
            "test_site_cluster": df_sites.loc[df_sites["Site_ID"] == site, "cluster"].values[0],
            "rmse_age": metrics["rmse_age"],
            "rmse_no_age": metrics["rmse_no_age"],
            "r2_age": metrics["r2_age"],
            "r2_no_age": metrics["r2_no_age"],
            "mean_gower": mean_gower,
            "train_sites": train_df["Site_ID"].unique().tolist()
        })

        # save predictions (large table)
        for i in range(len(test_df)):
            predictions_full.append({
            "run": run,
            "test_site": site,
            "test_site_cluster": df_sites.loc[df_sites["Site_ID"] == site, "cluster"].values[0],
            "timestamp": test_df.iloc[i]["Date"],
            "y_true": test_df.iloc[i]["ET"],
            "pred_age": metrics["preds_age"][i],
            "pred_no_age": metrics["preds_no_age"][i],
            "rmse_age": metrics["rmse_age"],
            "rmse_no_age": metrics["rmse_no_age"],
            "r2_age": metrics["r2_age"],
            "r2_no_age": metrics["r2_no_age"],
            "mean_gower": mean_gower,
            "train_sites": train_df["Site_ID"].unique().tolist()
        })

        print(f"Run {run} for site {site} complete")


# save out results and predictions
results_df = pd.DataFrame(results)
predictions_df = pd.DataFrame(predictions_full)

results_df.to_csv(f"data/main/22_analysis_1.2/metrics_{timestamp}.csv", index=False)
predictions_df.to_csv(f"data/main/22_analysis_1.2/predictions_{timestamp}.csv", index=False)


print("analysis_1.2.py complete")