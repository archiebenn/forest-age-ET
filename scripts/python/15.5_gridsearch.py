# gridsearch.py - using a new method to properly identify generalising RF parameters (now late august) which should be more defensible
# Author: Archie Benn
# Date: 17-08-2026

import numpy as np
import pandas as pd
import optuna
from sklearn.model_selection import GroupKFold
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error

# set numpy seed
np.random.seed(42)

# import data
df = pd.read_csv("data/main/14_pre_processing/df_ml_ready.csv")
df_sites = pd.read_csv("data/main/21_analysis_1.1/cleaned_sites.csv")

df_cleaned = df[df["Site_ID"].isin(df_sites["Site_ID"])]

# list of sites
sites = df_cleaned["Site_ID"]


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
                    #"Climate_zone_Tropical"
                    ]


# set features and target
y = df_cleaned['ET']
# drop the non features to get a features df
X = df_cleaned.drop(columns=non_features)

# a new parameter searcher using GroupKFold which should be more tuned for generalisation as tunes on a subset of sites rather than one held out site
def parameter_search(trial):

    # params will still be confined within these limits
    params = {
        "n_estimators": trial.suggest_int("n_estimators", 50, 450, step=100),
        "max_depth": trial.suggest_int("max_depth", 5, 50),
        "min_samples_leaf": trial.suggest_int("min_samples_leaf", 1, 20),
        "max_features": trial.suggest_float("max_features", 0.3, 1.0),
    }

    # arbitrary split of data into 7 groups to hold out and test on
    gkf = GroupKFold(n_splits=7)

    # empty dict to hold RMSEs
    scores = []

    for train_idx, test_idx in gkf.split(X, y, groups=sites):
        X_train, X_test = X.iloc[train_idx], X.iloc[test_idx]
        y_train, y_test = y.iloc[train_idx], y.iloc[test_idx]

        rf = RandomForestRegressor(**params, random_state=42, n_jobs=-2)
        rf.fit(X_train, y_train)
        preds = rf.predict(X_test)

        # RMSE append
        scores.append(np.sqrt(mean_squared_error(y_test, preds)))

    return np.mean(scores)  # single number Optuna optimises


# start the search ro minimise RMSE
study = optuna.create_study(direction="minimize")
study.optimize(parameter_search, n_trials=20)

# and get the best value and params
print(study.best_params)
print(study.best_value)

# save out the best params
df_params = pd.DataFrame([study.best_params])
df_params.to_csv("data/main/15.5_gridsearch/best_params.csv", index=False)

# and the full df (all trials params + scores)
df_trials = study.trials_dataframe()
df_trials.to_csv("data/main/15.5_gridsearch/all_trials.csv", index=False)

print("grisdearch.py complete")