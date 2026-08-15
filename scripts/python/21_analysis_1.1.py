# analysis_1.1.py - part 1.1 of final analysis for dissertation
# addition of variables and impact on predictability in RF ET models
# date: 9-8-26
# author: Archie Benn sj19031@bristol.ac.uk

# does adding site information to RF models improve predictions?  
# e.g temperature only vs. temperature + cumulative precip etc.

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

# set NumPy seed 
np.random.seed(42)

# *********************************************
# 1. DATA SETUP
# *********************************************

df = pd.read_csv("data/main/14_pre_processing/df_ml_ready.csv")
df_sites = pd.read_csv("data/main/20_gower/df_clustered.csv")
df_gower = pd.read_csv("data/main/20_gower/gower_matrix.csv", index_col=0)
df_cluster_labels = pd.read_csv("data/main/20_gower/df_cluster_labels.csv")


# remove chronosequence sites of which other sites in chronosequence are also represented in test medoids (stops local site leakage)
# CH-Dav also goes as the only polar site as v limited climate zone coverage
sites_remove = ["CA-TP1", "CA-TP4", "US-Me2", "US-Me5", "US-Me6", "CH-Dav"]
df_cleaned = df[~df["Site_ID"].isin(sites_remove)]
df_sites_cleaned = df_sites[~df_sites["Site_ID"].isin(sites_remove)]

# save out this cleaned site df too for map
df_sites_cleaned.to_csv("data/main/21_analysis_1.1/cleaned_sites.csv", index=False)

# all sites list
all_sites = df_sites_cleaned["Site_ID"].astype(str).tolist()

# test sites list (medoids)
test_sites = df_cluster_labels.iloc[:, 1].astype(str).tolist()

# training pool
train_sites = [s for s in all_sites if s not in test_sites]

# *********************************************
# 2. FUNCTIONS
# *********************************************

# 2.1 function to take list of features and add 1 in a loop over length of list
def feature_adder(features):

    # empty list
    feature_sets = []

    # iterate over loop with index
    for index, feature in enumerate(features):

        # pull out feature, then feature + next feature etc., and continue
        features_this_loop = features[:index + 1]

        feature_sets.append(features_this_loop)

    return feature_sets

        


# 2.2 pass feature(s) list to RF model and train/test iteratively per feature subset
def rf_it_train(feature_sets, train_df, test_df, target):

    #params defined in script 15
    params = {
            "n_estimators": 250, 
            "max_depth": 10, 
            "min_samples_leaf": 10,
            "max_features": 0.6
        }

    # setup RF
    rf = RandomForestRegressor(
        # use parameters defined above (** expands dict)
        **params,
        random_state=42,
        # use all except one core
        n_jobs=-2) 
    
    results = []

    # now fit the model over the feature sets and predict against test
    for index, feature_set in enumerate(feature_sets, start=1):

        total_models = len(feature_sets)

        X = train_df[feature_set]
        y = train_df[target]

        rf.fit(X,y)

        # predict!
        preds = rf.predict(test_df[feature_set])

        # metrics
        rmse = np.sqrt(mean_squared_error(test_df[target], preds))
        r2 = r2_score(test_df[target], preds)

        results.append({"features": feature_set, "rmse": rmse, "r2": r2})

        print(f"RF model {index}/{total_models} complete")



    # return dict of metrics
    return results



# *********************************************
# 3. SETUP FEATURES
# *********************************************

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

features_all = [c for c in df_cleaned.columns if c not in non_features]

# re-order as the order of added features in this case is important
feature_order = [
    "Tair", "SW_rad", "VPD", "Wspeed", "P_sum_14D",
    "Lai_500m", "Site_age"
]

# safety check: catches typos/missing cols
# set() unorders all so just catches if elements match
# ^ operand will show which don't match if assert fails
assert set(feature_order) == set(features_all), set(feature_order) ^ set(features_all)

features_all = feature_order


# *********************************************
# 4. MAIN LOOP
# *********************************************

# this will be a list of dicts
results_main = []

# loop over all test sites
for site in test_sites:

    print(f"Starting site {site}")

    # set train/test dfs
    test_df = df_cleaned[df_cleaned["Site_ID"] == site]
    train_df = df_cleaned[df_cleaned["Site_ID"] != site]

    # get list of iterative feature sets
    feature_sets = feature_adder(features = features_all)

    # fit and predict ET using RF using each set
    metrics = rf_it_train(feature_sets=feature_sets,
                          train_df=train_df,
                          test_df=test_df,
                          target="ET")

    test_site_cluster = df_sites_cleaned.loc[df_sites_cleaned["Site_ID"] == site, "cluster"].values[0]

    results_main.append({"test_site": site, "test_site_cluster": test_site_cluster, "metrics": metrics})

    print(f"Site {site} complete!")


# clean up results_main from being a list of dicts
rows = []

# for each item in results_main list (test site and metrics)
for entry in results_main:

    # for every metrics entry (from rf_it_train dict return)
    for m in entry["metrics"]:

        rows.append({
            "test_site": entry["test_site"],
            "test_site_cluster": entry["test_site_cluster"],
            "n_features": len(m["features"]),
            "features": ",".join(m["features"]),
            "rmse": m["rmse"],
            "r2": m["r2"],
        })

results_main_df = pd.DataFrame(rows)
results_main_df.to_csv(f"data/main/21_analysis_1.1/results_{timestamp}.csv", index=False)

print("analysis_1.1.py complete")








