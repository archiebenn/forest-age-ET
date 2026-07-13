# pre_processing.py - setting up data for machine learning models (non GAM)
# author: Archie Benn sj19031@bristol.ac.uk
# date: 13-07-2026

# have to exclude variables which will allow the model to memorise across rows  
# so no Site_ID, and no lat/long data (Site_ID was in GAM as a random effect, lat/long was never included in GAM)  
# will also start with site age to see how it goes  
# going to one hot encode the categorical variables - not necessary for RF but if wanting to use XGBoost etc. later it keeps it constant

# import libraries
import numpy as np
import pandas as pd
import os
from sklearn.preprocessing import OneHotEncoder

# set seed for NumPy
np.random.seed(42)
# setup wd 
os.chdir('/home/ab/Dropbox/university/github/bbinf_project')
# import data
df_10 = pd.read_csv("data/main/10_filtering2/df_10.csv")



# one hot encoding categorical vars
encoder = OneHotEncoder(sparse_output=False)

categorical_list = ['Continent', 'Cover_type', 'Climate_zone']
categorical_cols = df_10[categorical_list]

# encode the cols
encoded_data = encoder.fit_transform(categorical_cols)

# set as one hot encoded categorical df
encoded_df = pd.DataFrame(
    encoded_data,
    columns=encoder.get_feature_names_out(categorical_list)
)

# now merge back with the main df 
merged = pd.concat([df_10.drop(columns=categorical_list), encoded_df], axis=1)

# write out
merged.to_csv("data/main/14_pre_processing/df_ml_ready.csv")
print("ML data pre processing complete")