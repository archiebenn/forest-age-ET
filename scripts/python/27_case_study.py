# case_study.py - running ML models for two case study sites and saving predictions/stats
# Author: Archie Benn
# Date: 15-08-2026

# the site-level (not row-level) age permutation allows the question of: 
# "is the model actually learning something from forest age, or is the age acting as a proxy for other site level features" to be answered
# so in the shuffled models sites randomly swap site age (trajectories as row counts not all equal) with other sites and then train/test etc.

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

# set wd 
os.chdir('/home/ab/Dropbox/university/github/bbinf_project')

# import data
df_14 = pd.read_csv("data/main/14_pre_processing/df_ml_ready.csv")


# *********************************************
# 2. FUNCTION(S)
# *********************************************

# 2.1 RANDOM FOREST SETUP
# this RF function will allow seeds to be looped over for repeated leave one group out 
def random_forest_normal(X, y, all_sites, case_sites, full_data, seed_list):

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
    shap_train_results = []

    for site in case_sites:

        # get ids (all_sites is just df["Site_ID"], so links to main df indices)
        train_idx = all_sites[all_sites != site].index
        test_idx = all_sites[all_sites == site].index

        # train/test split
        X_train, X_test = X.loc[train_idx], X.loc[test_idx]
        y_train, y_test = y.loc[train_idx], y.loc[test_idx]

        # now loop over the seed list to repeat RF stuff (enumerate for messages)
        for i, seed in enumerate(seed_list, start=1):
        
            # now actually setup the random forest
            rf = RandomForestRegressor(
                # use parameters defined above (** expands dict)
                **params,

                # set seed
                random_state=seed,
                # use all except one core
                n_jobs=-2)
            
            # and train the model
            rf.fit(X_train, y_train)

            # shap analysis on a subset of X_test (was massively slowing down script)
            explainer = shap.TreeExplainer(rf)
            # random 250 rows of X_test with seed
            X_shap_subset = X_test.sample(250, random_state=seed)
            # run shap
            shap_values = explainer.shap_values(X_shap_subset)
            fold_shap_df = pd.DataFrame(shap_values, columns=X_shap_subset.columns)            
            # add shap columns
            fold_shap_df["site"] = site
            fold_shap_df["seed"] = seed
            # only add age if mod+age model or will crash!
            if "Site_age" in X_shap_subset.columns:
                fold_shap_df["Site_age_raw"] = X_shap_subset["Site_age"].values
            # append to shap results list
            shap_results.append(fold_shap_df)

            # shap analysis of X_train as well for full age range of sites vs shap dependence on age plot in R later
            X_train_shap_subset = X_train.sample(200, random_state=seed)
            # run shap on training
            train_shap_values = explainer.shap_values(X_train_shap_subset)
            train_shap_df = pd.DataFrame(train_shap_values, columns=X_train_shap_subset.columns)
            train_shap_df["site"] = site 
            train_shap_df["seed"] = seed
            if "Site_age" in X_train_shap_subset.columns:
                train_shap_df["Site_age_raw"] = X_train_shap_subset["Site_age"].values
            # append
            shap_train_results.append(train_shap_df)

            # preds and stats
            preds = rf.predict(X_test)
            rmse = np.sqrt(mean_squared_error(y_test, preds))
            r2 = r2_score(y_test, preds)
            mae = mean_absolute_error(y_test, preds)
            

            # take the full original rows for this fold and append predictions to it
            fold_df = full_data.loc[test_idx].copy()
            fold_df["observed_ET"] = y_test.values
            fold_df["predicted_ET"] = preds
            fold_df["seed"] = seed

            # appending to lists
            preds_results.append(fold_df)
            stats_results.append({"site": site, "seed": seed, "rmse": rmse, "mae": mae, "r2": r2})

            print(f"NORMAL RF test site {site} complete for seed {i}/{len(seed_list)}.")

    # concatenate all the preds individual dfs to one out of the list before returning
    preds_results = pd.concat(preds_results, ignore_index=True)
    shap_results = pd.concat(shap_results, ignore_index=True)
    shap_train_results = pd.concat(shap_train_results, ignore_index=True)

    # return out preds, stats, and shap dfs
    return preds_results, pd.DataFrame(stats_results), shap_results, shap_train_results



# 2.2 RANDOM FOREST SETUP 2: SHUFFLE AGE
# this RF function will allow seeds to be looped over, but also shuffles training site ages before training the models
def random_forest_shuffle_age(X, y, all_sites, case_sites, full_data, seed_list):

    params = {
        "n_estimators": 250, 
        "max_depth": 10, 
        "min_samples_leaf": 10,
        "max_features": 0.6
    }

    # empty lists
    preds_results_shuffled = []
    stats_results_shuffled = []
    shap_results_shuffled = []
    shap_train_results_shuffled =[]

    for site in case_sites:

        # get ids (all_sites is just df["Site_ID"], so links to main df indices)
        train_idx = all_sites[all_sites != site].index
        test_idx = all_sites[all_sites == site].index

        # train/test split
        X_train, X_test = X.loc[train_idx], X.loc[test_idx]
        y_train, y_test = y.loc[train_idx], y.loc[test_idx]

        # this gets the training site IDs for this loop and stores in sites
        site_id_train = all_sites.loc[train_idx]
        sites = site_id_train.unique() 

        # now loop over the seed list to repeat RF stuff
        for i, seed in enumerate(seed_list, start=1):

            # SHUFFLE TRAINING DATASET AGES BASED ON SEED
            # random number generator
            rng = np.random.default_rng(seed)

            # this zips together one training site:a random other training site (should be different but not guaranteed as can be zipped to itself)
            shuffled_site_map = dict(zip(sites, rng.permutation(sites))) 

            # shuffle training site ages
            X_train_shuffled = X_train.copy()

            # this is where the site-wise age shuffle and interpolation happens (within seed loop)
            # for loop does this matched shuffling for the whole dataframe before passing it to the rf for fitting
            for s in sites:

                # real indices of this site s
                s_idx = site_id_train[site_id_train == s].index

                # get matched/donor site
                matched_site = shuffled_site_map[s]

                # get indices of this matched/donor site
                matched_idx = site_id_train[site_id_train == matched_site].index

                # now get the ordered site ages of the original site s and sort (should be already but safe to do again)
                s_age_order = X_train.loc[s_idx, "Site_age"].sort_values().index

                # and get the ordered site age indices of the matched/donor site as well and sort
                matched_ages = X_train.loc[matched_idx, "Site_age"].sort_values().values

                # and now need to interpolate across the lengths of the site age rows for the pairings 
                # ie. number of rows of age of s may not != number of rows of age of the matched shuffled site
                # therefore this interpolates across the length of both to fill in the shorter dated ID's rows to keep full dataset and 'fake' age
                # this interpolation method does reshape how each row is represneted, as 50% of the way through one is replaced to 50% of the way through the other, regardless of length
                # this does also keep all age ranges as in the original dataset
                matched_ages = np.interp(
                np.linspace(0, 1, len(s_age_order)),
                np.linspace(0, 1, len(matched_ages)),
                matched_ages
            )

                # replace original ages with the interpolated matched ages
                X_train_shuffled.loc[s_age_order, "Site_age"] = matched_ages

                # debug check: dump one example site's original vs shuffled ages
                if site == case_sites[0] and seed == seed_list[0]:
                    check_df = pd.DataFrame({
                        "original_age": X_train.loc[s_age_order, "Site_age"].values,
                        "shuffled_age": matched_ages,
                        "origin_site": s,
                        "donor_site": matched_site
                    })
                    # save out to check if shuffle worked or not
                    check_df.to_csv(f"data/main/27_case_study/shuffled_ages/shuffled_check_{s}.csv", index=False)

                            
            # now actually setup the random forest
            rf = RandomForestRegressor(
                # use parameters defined above (** expands dict)
                **params,

                # set seed
                random_state=seed,
                # use all except one core
                n_jobs=-2)
            
            # and train the model on shuffled age training set
            rf.fit(X_train_shuffled, y_train)

            # shap analysis on a subset of X_test (was massively slowing down script)
            explainer = shap.TreeExplainer(rf)
            # random 250 rows of X_test with seed
            X_shap_subset = X_test.sample(250, random_state=seed)
            # run shap
            shap_values = explainer.shap_values(X_shap_subset)
            fold_shap_df = pd.DataFrame(shap_values, columns=X_shap_subset.columns)
            # add shap columns
            fold_shap_df["site"] = site
            fold_shap_df["seed"] = seed
            # check if age is there or will crash (not there in mod only model)
            if "Site_age" in X_shap_subset.columns:
                fold_shap_df["Site_age_raw"] = X_shap_subset["Site_age"].values
            # append to shap results list
            shap_results_shuffled.append(fold_shap_df)

            # shap analysis of X_train as well for full age range of sites vs shap dependence on age plot in R later
            X_train_shap_subset = X_train.sample(200, random_state=seed)
            # run shap on training
            train_shap_values = explainer.shap_values(X_train_shap_subset)
            train_shap_df = pd.DataFrame(train_shap_values, columns=X_train_shap_subset.columns)
            train_shap_df["site"] = site 
            train_shap_df["seed"] = seed
            # only add age if mod+age model or will crash!
            if "Site_age" in X_train_shap_subset.columns:
                train_shap_df["Site_age_raw"] = X_train_shap_subset["Site_age"].values
            # append
            shap_train_results_shuffled.append(train_shap_df)

            # preds and stats
            preds = rf.predict(X_test)
            rmse = np.sqrt(mean_squared_error(y_test, preds))
            r2 = r2_score(y_test, preds)
            mae = mean_absolute_error(y_test, preds)

            # take the full original rows for this fold and append predictions to it
            fold_df = full_data.loc[test_idx].copy()
            fold_df["observed_ET"] = y_test.values
            fold_df["predicted_ET"] = preds
            fold_df["seed"] = seed

            # appending to lists
            preds_results_shuffled.append(fold_df)
            stats_results_shuffled.append({"site": site, "seed": seed, "rmse": rmse, "mae": mae, "r2": r2})

            print(f"SHUFFLED RF test site {site} complete for seed {i}/{len(seed_list)}.")

    # concatenate all the preds individual dfs to one out of the list before returning
    preds_results_shuffled = pd.concat(preds_results_shuffled, ignore_index=True)
    shap_results_shuffled = pd.concat(shap_results_shuffled, ignore_index=True)
    shap_train_results_shuffled = pd.concat(shap_train_results_shuffled, ignore_index=True)

    # return out preds, stats, and shap dfs
    return preds_results_shuffled, pd.DataFrame(stats_results_shuffled), shap_results_shuffled, shap_train_results_shuffled
    



# *********************************************
# 3. SETUP FEATURES ETC.
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
                    #"Climate_zone_Tropical"
                    ]


# features (values) to drop based on model (keys)
model_variants = {
    "mod": ["Site_age"],
    "mod+age": []
}

# set the two case study sites to test on
case_sites = ["US-UMd", "DE-Lnf"]
seeds = [1, 42, 123, 2026, 9]

# set sites as groups to split by  
site_names = df_14["Site_ID"] 

# set target column
y = df_14['ET']



# *********************************************
# 4. MAIN LOOP
# *********************************************
stats_list = []
preds_list = []
shap_test_list = []
shap_train_list = []


# and for age vs. no age models
for model in model_variants:

    print(f"Starting runs for {model}")

    # this accessed the model_variants dict and pulls out the value (feature)
    # ie. for model_variants[mod] (the no age model = key) it will drop 'Site_age' (value) from X
    dropped_feature = model_variants[model]
    excluded = non_features + dropped_feature
    X = df_14.drop(columns=excluded)

    # first RF run: normal training data across the seed list 
    preds_normal, stats_normal, shap_test_normal, shap_train_normal = random_forest_normal(X=X, y=y, 
                                                                       all_sites=site_names, 
                                                                       case_sites=case_sites,
                                                                       full_data=df_14,
                                                                       seed_list=seeds)

    # add columns for if results are from shuffled or not, and model used to generate them
    preds_normal["model"] = model
    preds_normal["shuffled"] = False
    stats_normal["model"] = model
    stats_normal["shuffled"] = False   
    shap_test_normal["model"] = model
    shap_test_normal["shuffled"] = False
    shap_train_normal["model"] = model
    shap_train_normal["shuffled"] = False

    # now append these to main out lists of results
    stats_list.append(stats_normal)
    preds_list.append(preds_normal)
    shap_test_list.append(shap_test_normal)
    shap_train_list.append(shap_train_normal)

    # only run this second shuffling function if age is included in model othersie pointless
    if model == "mod+age":

        # second RF run: shuffled training data ages across seed list
        preds_shuffled, stats_shuffled, shap_test_shuffled, shap_train_shuffled = random_forest_shuffle_age(X=X, y=y,
                                                                                    all_sites=site_names,
                                                                                    case_sites=case_sites,
                                                                                    full_data=df_14,
                                                                                    seed_list=seeds)

        # add columns for if results are from shuffled or not, and model used to generate them
        preds_shuffled["model"] = model
        preds_shuffled["shuffled"] = True
        stats_shuffled["model"] = model
        stats_shuffled["shuffled"] = True   
        shap_test_shuffled["model"] = model
        shap_test_shuffled["shuffled"] = True
        shap_train_shuffled["model"] = model
        shap_train_shuffled["shuffled"] = True

        # append shuffled to main results lists
        stats_list.append(stats_shuffled)
        preds_list.append(preds_shuffled)
        shap_test_list.append(shap_test_shuffled)
        shap_train_list.append(shap_train_shuffled)

    print(f"Run for {model} model complete")


# now all results lists to pandas dfs
stats_df = pd.concat(stats_list, ignore_index=True)
preds_df = pd.concat(preds_list, ignore_index=True)
shap_test_df = pd.concat(shap_test_list, ignore_index=True)
shap_train_df = pd.concat(shap_train_list, ignore_index=True)

# and write all out
stats_df.to_csv("data/main/27_case_study/stats.csv", index=False)
preds_df.to_csv("data/main/27_case_study/preds.csv", index=False)
shap_test_df.to_csv("data/main/27_case_study/test_shap.csv", index=False)
shap_train_df.to_csv("data/main/27_case_study/train_shap.csv", index=False)


print("case_study.py complete")

