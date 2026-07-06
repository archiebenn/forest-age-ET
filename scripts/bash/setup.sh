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
mkdir -p 10_GAM_testing

echo "setup.sh complete"

cd ../../