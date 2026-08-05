# analysis_1.2.R - part 1.2 of final analysis for dissertation
# large scale train:test evaluation - random training sites on 7 test sites: how does training set composition impact predictability?
# date: 5-8-2026
# author: Archie Benn sj19031@bristol.ac.uk

# Does adding age reduce error?
# Does age help more for ecologically distant test sites?
# Does age help more for certain clusters?

import os
import pandas as pd
import numpy as np
import shap
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import r2_score, mean_squared_error

# set seed for NumPy
np.random.seed(42)

# set wd 
os.chdir('/home/ab/Dropbox/university/github/bbinf_project')

# *********************************************
# 1. DATA SETUP
# *********************************************

df = pd.read_csv("data/main/14_pre_processing/df_ml_ready.csv")
df_sites = pd.read_csv("data/main/20_gower/df_clustered.csv")
df_gower = pd.read_csv("data/main/20_gower/gower_matrix.csv", index_col=0)
df_cluster_labels = pd.read_csv("data/main/20_gower/df_cluster_labels.csv")

# remove CA-TP1 and CA-TP4 as these are part of the chronosequence of CA-TP3 which is a test site (stops local site leakage)
sites_remove = ["CA-TP1", "CA-TP4"]
df_cleaned = df[~df["Site_ID"].isin(sites_remove)]
df_sites_cleaned = df_sites[~df_sites["Site_ID"].isin(sites_remove)]

# all sites list
all_sites = df_sites_cleaned["Site_ID"].astype(str).tolist()

# test sites list (medoids)
test_sites = df_cluster_labels.iloc[:, 1].astype(str).tolist()

# training pool
train_pool = [s for s in all_sites if s not in test_sites]



# *********************************************
# 2. FUNCTIONS
# *********************************************

# 2.1 function to randomly select 20 sites from training sites list
def train_selecta(main_df, train_sites, n=20):

    chosen = np.random.choice(train_sites, size=n, replace=False)
    train_df = main_df[main_df["Site_ID"].isin(chosen)].copy()

    return train_df

# testing 2.1 
selected = train_selecta(df_cleaned, train_pool)
print(selected.head(10))


# 2.2 random forest training function - trains on training df
def rf_train(train_df):

    models = ("age", "no_age")

    #params defined in script 15
    params = {
            "n_estimators": 250, 
            "max_depth": 10, 
            "min_samples_leaf": 10,
            "max_features": 0.6
        }

    # empty lists
    preds_results = []
    stats_results = []
    shap_results = []

    # now actually setup the random forest
    rf = RandomForestRegressor(
        # use parameters defined above (** expands dict)
        **params,
        random_state=42,
        # use all except one core
        n_jobs=-2)

    

    
