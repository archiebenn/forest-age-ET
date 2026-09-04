#!/bin/bash
# sort_csv.sh - after downloading all fullsets of FLUXNET2015 data into ~/Downloads, run this to extract the daily csvs based off the side id text list
# only run with make sort from project root

set -euo pipefail

mkdir -p data/zipped
mkdir -p data/unzipped
mkdir -p data/all_DD
mkdir -p data/main/02_full_sites_DD

# copy zips from downloads 
cd data/zipped
cp ~/Downloads/*.zip ./

# unzip only the daily (DD) files and store
cd ../unzipped
for f in ../zipped/*.zip; do
unzip -j "$f" "*FULLSET_DD*.csv" -d ../all_DD
done

# read site list generated in sites.R and extract only the data from this list ie. only selected sites
while read site; do
cp ../all_DD/*${site}* ../main/02_full_sites_DD 2>/dev/null
done < ../main/01_site_selection/original_site_list.txt


# delete other folders
cd ../
rm -rf all_DD
rm -rf zipped
rm -rf unzipped