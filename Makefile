# Makefile for MSc Diss
# usage: make [target]
# --arch options: rf, xgboost, lstm, rnn
# author:  Archie Benn sj19031@bristol.ac.uk


.PHONY: help sites lai fluxnet engineer small_scale generalisation model_comparison diss all

.DEFAULT_GOAL := help

ARCHITECTURE ?= rf

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

all: sites lai fluxnet engineer small_scale generalisation model_comparison diss ## run full pipeline

sites: ## data prep  part 1 - filter sites, make csv, create world map
	Rscript src/R/sites.R
	Rscript src/R/all_site_map.R
	sed -i 's/{world_sites_ras/{..\/figures\/world_sites_ras/g' diss/figures/world_sites.tex

lai: ## data prep part 2 - fetch MODIS LAI by site coordinates
	Rscript src/R/lai.R

fluxnet: ## data prep part 3 - take suitable sites and get full fluxnet data
	Rscript src/R/fluxnet.R

engineer: ## data prep part 4 - select + engineer variables for ML
	Rscript src/R/engineer.R

small_scale: ## analysis 1 - small scale testing
	python src/python/small_scale.py --arch $(ARCHITECTURE)

generalisation: ## analysis 2 - generalisation
	python src/python/generalisation.py --arch $(ARCHITECTURE)

model_comparison: ## analysis 3 - 4 way model accuracy comparison
	python src/python/model_comparison.py --arch $(ARCHITECTURE)

diss: ## compile diss PDF with LaTeX
	cd diss/LaTeX && latexmk -pdf main.tex
