#!/bin/bash

# move to project root
cd ../../../

mkdir -p data/zipped
mkdir -p data/unzipped
mkdir -p data/all_DD
mkdir -p data/fluxnet/02_full_sites_DD

# copy zips from downloads 
cd data/zipped
cp ~/Downloads/*.zip ./

# unzip files and store
cd ../unzipped
for f in ../zipped/*.zip; do
    unzip -o "$f" -d ./
done

# extract only daily data
find . -type f -name "*FULLSET_DD*.csv" -exec cp {} ../all_DD \;

# read site list generated in sites.R and extract only the data from this list ie. only selected sites
while read site; do
    cp ../all_DD/*${site}* ../fluxnet/02_full_sites_DD 2>/dev/null
done < ../fluxnet/01_site_selection/site_list.txt


# delete other folders
