# ML.py - running ML models for all 57 sites held out in a loop, and saving predictions/stats
# Author: Archie Benn
# Date: 15-07-2026

# import libraries
import numpy as np
import pandas as pd
import os
from sklearn.model_selection import LeaveOneGroupOut
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score


# set seed for NumPy
np.random.seed(42)

# set wd 
os.chdir('/home/ab/Dropbox/university/github/bbinf_project')

# import data
df_14 = pd.read_csv("data/main/14_pre_processing/df_ml_ready.csv")


# RANDOM FOREST SETUP
def random_forest(X, y, sites, cv):

    params = {
        "n_estimators": 250, 
        "max_depth": 10, 
        "min_samples_leaf": 10,
        "max_features": 0.6
    }

    # empty lists
    preds_results = []
    stats_results = []

    # run the leaveOneOut generator (cv) until the test index name == test site
    for train_idx, test_idx in cv.split(X, y, groups=sites):

        # set train/test split for features (X df) using indices from the leaveOneOute generator
        # train_idx is the row indices of the training rows (ie. non test site rows, opposite for test_idx)
        X_train, X_test = X.iloc[train_idx], X.iloc[test_idx]

        # and same for train/test values of target/ET
        y_train, y_test = y.iloc[train_idx], y.iloc[test_idx]
        
        # now actually setup the random forest
        rf = RandomForestRegressor(
            # use parameters defined above (** expands dict)
            **params,
            random_state=42,
            # use all except one core
            n_jobs=-2)
        
        # and train the model
        rf.fit(X_train, y_train)

        # preds and stats
        preds = rf.predict(X_test)
        rmse = np.sqrt(mean_squared_error(y_test, preds))
        r2 = r2_score(y_test, preds)

        # get test site id for this loop
        test_site = sites.iloc[test_idx[0]]

        # setup this fold's/test site's results per row preds dataframe
        fold_df = pd.DataFrame({
            "site": test_site,
            "observed_ET": y_test.values,
            "predicted_ET": preds
        
        })

        # appending to lists
        preds_results.append(fold_df)
        stats_results.append({"site": test_site, "rmse": rmse, "r2": r2})

        print(f"RF test site {test_site} complete.")

    # concatenate all the preds individual dfs to one out of the list before returning
    preds_results = pd.concat(preds_results, ignore_index=True)

    # return out stats and preds dfs
    return preds_results, pd.DataFrame(stats_results)
    


# OTHER MODEL SETUPS GO HERE




# RUNNING MODELS
# set cross validation method to leave one group out
validation = LeaveOneGroupOut()
# set sites as groups to split by  
site_names = df_14["Site_ID"] 

# set features and target
y = df_14['ET']

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
                     'Unnamed: 0',      # not sure where this came from
                     ]


# features (values) to drop based on model (keys)
model_variants = {
    "all": [],
    "no_age": ["Site_age"],
    "no_lai": ["Lai_500m"],
    "no_age_no_lai": ["Site_age", "Lai_500m"]
}

# preds and stats lists for all architectures
preds = []
stats = []

# outer loop determines which variant of ML model (full, no age, etc.)
for model, dropped_feature in model_variants.items():

    excluded = non_features + dropped_feature

    # setup variant of features df  by dropping excluded cols per model (split is made within each ML function)
    X_variant = df_14.drop(columns=excluded)

    # now inner conditional selects the architecture to train/test
    if True:
        
        # for naming final .csv 
        architecture = "RF"

        # run random forest
        rf_preds_df, rf_stats_df = random_forest(X_variant, y, site_names, validation)

        # add model used to dfs as a column
        rf_preds_df["model"] = model
        rf_stats_df["model"] = model

        # append to outer lists
        preds.append(rf_preds_df)
        stats.append(rf_stats_df)

        print(f"Model {architecture}:{model} complete")


# combine all preds and stats to long format
preds_df = pd.concat(preds, ignore_index=True)
stats_df = pd.concat(stats, ignore_index=True)

# save out results
preds_df.to_csv(f"data/main/x_ML_results/{architecture}_preds_results.csv", index=False)
stats_df.to_csv(f"data/main/x_ML_results/{architecture}_stats_results.csv", index=False)