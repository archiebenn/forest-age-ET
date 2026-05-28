# Makefile for MSc Diss
# usage: make [target]
# --arch options: rf, xgboost, lstm, rnn
# author:  Archie Benn sj19031@bristol.ac.uk


.PHONY: help sites lai fluxnet engineer small_scale generalisation model_comparison

.DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

sites: ## data prep  part 1 - load site names + filters from besnard
	Rscript src/R/sites.R

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


