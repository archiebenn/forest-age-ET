# analysis_2.py - part 2 of final analysis for dissertation
# this script is the temporal preiction aspect of the dissertation - it builds RF models on historical FLUXNET data per site and predicts the most recent data
# date: 10-8-2026
# author: Archie Benn sj19031@bristol.ac.uk


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

# all sites list
all_sites = df_sites["Site_ID"].astype(str).tolist()



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

    train_80 = site_df.iloc[:split_id]
    test_20 = site_df.iloc[split_id:]

    return train_80, test_20


# 3.2 function to fit and predict RF models
