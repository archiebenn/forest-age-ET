# analysis_1.3.py - part 1.3 of final analysis for dissertation
# this script builds rf models (with and without age) trained by cluster (minus medoids) and predicts on the 6 medoid (representative) test sites, before saving metrics
# date: 21-8-2026
# author: Archie Benn sj19031@bristol.ac.uk

# import libraries
import numpy as np
import pandas as pd
import os
import shap
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score, mean_absolute_error


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