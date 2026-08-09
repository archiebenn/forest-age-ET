# Makefile for MSc Dissertation.
# usage: make [target]
# author:  Archie Benn sj19031@bristol.ac.uk
# May - September 2026

.PHONY: help all setup sites map fluxnet lai filter ET_plots climates sorting filter2 gams engineer single_held_out generate_plots gower analysis_1.1 analysis_1.2 diss

.DEFAULT_GOAL := help

ARCHITECTURE ?= rf

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

all: setup sites fluxnet lai filter ET_plots climates sorting filter2 engineer gower analysis_1.1 analysis_1.2 map diss

setup: ## setup the folder structure for data to be read into/out of
	./scripts/bash/setup.sh

sites: ## data prep  part 1 - filter sites, make csv, create world map
	Rscript scripts/R/01_sites.R

map: ## make a world map, compile standalone tikz to PDF
	Rscript scripts/R/02_site_maps.R
	cd diss/figures && pdflatex -interaction=nonstopmode world_sites.tex

fluxnet: ## data prep part 2 - take suitable sites and get full fluxnet data
	Rscript scripts/R/03_fluxnet.R

lai: ## data prep part 3 - fetch MODIS LAI by site coordinates
	Rscript scripts/R/04_lai.R

filter: ## data prep part 4 - filter LAI and fluxnet based on quality metric
	Rscript scripts/R/05_filtering.R

ET_plots: ## data prep part 5 - checking ET against time plots per site and adjusting time ranges  
	Rscript scripts/R/06_ET_plots.R

climates: ## data prep part 6 - adds koeppen climate zone data to each site
	Rscript scripts/R/07_climates.R

sorting: ## data prep part 7 - sorts full dataset into main, by-year, and by-site DFs (and adds some columns)
	Rscript scripts/R/08_sorting.R

filter2: ## data prep part 8 - filter sites based on georgraphic data 
	Rscript scripts/R/10_filtering2.R

gams: ## Forms GAMs (bams) to assess R-squared and RMSE per site for all predictions
	Rscript scripts/R/12_GAM_formation.R

engineer: ## data prep part 9 - select + engineer variables for ML
	python scripts/python/14_ml_engineering.py

single_held_out: ## python script which runs multiple ML architectures and generates preds and stats per site
	python scripts/python/16_ML_single_held_out.py 

generate_plots: ## R script which generates predicted vs. observed plots fo different architectures and models  
	Rscript scripts/R/17_plots_generate.R

gower: ## dissimilarity calculation for site features (to characterise these sites)
	Rscript scripts/R/20_gower_pam.R

analysis_1.1: ## tests the effect of iterative addition of features to RF models with r-squared and rmse of predictions against the 7 medoid test sites
	python scripts/python/22_analysis_1.1.py

analysis_1.2: ## large scale train/test loops. trains on 20 random sites and predicts on 7 medoid/cluster sites, then saves metrics and repeats
	python scripts/python/22_analysis_1.2.py

diss: map ## compile diss PDF with LaTeX
	cd diss/main && latexmk -pdf dissertation.tex && xdg-open dissertation.pdf
