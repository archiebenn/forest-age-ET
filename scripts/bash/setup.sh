#!/bin/bash

# setup.sh - makes folders for results to be read into/out of
# only run from root!

set -eo pipefail

cd data/main || \
{ echo "data/main directory not found, please ensure you are running this script from project root"; exit 1; }

mkdir -p 01_site_selection  
mkdir -p 02_full_sites_DD   
mkdir -p 03_full_unscaled  
mkdir -p 04_lai            
mkdir -p 05_filtering  
mkdir -p 06_ET_plots
mkdir -p 07_climates
mkdir -p 08_sorting  
mkdir -p 09_GAM      
mkdir -p 10_filtering2
mkdir -p 11_GAM
mkdir -p 12_GAM_testing
mkdir -p 13_GAM_exploration
mkdir -p 14_pre_processing
mkdir -p 15_random_forest_test
mkdir -p 15.5_gridsearch
mkdir -p 16_ML_results
mkdir -p 17_plots_generate
mkdir -p 18_single_site_exploration
mkdir -p 19_decomposition
mkdir -p 20_gower
mkdir -p 21_analysis_1.1
mkdir -p 21_analysis_1.2
mkdir -p 27_case_study




echo "setup.sh complete"

cd ../../