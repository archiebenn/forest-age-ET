# Makefile for MSc Diss
# usage: make [target]
# --arch options: rf, xgboost, lstm, rnn
# author:  Archie Benn sj19031@bristol.ac.uk


.PHONY: help all sites fluxnet lai filter ET_plots clean  engineer small_scale generalisation model_comparison diss

.DEFAULT_GOAL := help

ARCHITECTURE ?= rf

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

all: sites fluxnet lai filter ET_plots clean

sites: ## data prep  part 1 - filter sites, make csv, create world map
	Rscript src/R/01_sites.R
	Rscript src/R/02_site_maps.R
	sed -i 's/{world_sites_ras/{..\/figures\/world_sites_ras/g' diss/figures/world_sites.tex

fluxnet: ## data prep part 2 - take suitable sites and get full fluxnet data
	Rscript src/R/03_fluxnet.R

lai: ## data prep part 3 - fetch MODIS LAI by site coordinates
	Rscript src/R/04_lai.R

filter: ## data prep part 4 - filter LAI and fluxnet based on quality metric
	Rscript src/R/05_filtering.R

ET_plots: ## data prep part 5 - checking ET against time plots per site and adjusting time ranges  
	Rscript src/R/06_ET_plots.R

clean: ## data prep part 6 - cleaning data based on data exploration finding
	Rscript src/R/07_cleaning.R

engineer: ## data prep part 7 - select + engineer variables for ML
	Rscript src/R/07_engineer.R

small_scale: ## analysis 1 - small scale testing
	python src/python/small_scale.py --arch $(ARCHITECTURE)

generalisation: ## analysis 2 - generalisation
	python src/python/generalisation.py --arch $(ARCHITECTURE)

model_comparison: ## analysis 3 - 4 way model accuracy comparison
	python src/python/model_comparison.py --arch $(ARCHITECTURE)

diss: ## compile diss PDF with LaTeX
	cd diss/LaTeX && latexmk -pdf main.tex && xdg-open main.pdf
