# Makefile for MSc Diss
# usage: make [target]
# author:  Archie Benn sj19031@bristol.ac.uk

.PHONY: sites lai fluxnet engineer

sites: ## data prep  part 1 - load site names + filters from besnard
	Rscript src/R/sites.R

lai: sites ## data prep part 2 - fetch MODIS LAI by site coordinates
	Rscript src/R/lai.R

fluxnet: lai  ## data prep part 3 - take suitable sites and get full fluxnet data
	Rscript src/R/fluxnet.R

engineer: fluxnet ## data prep part 4 - select + engineer variables for ML
	Rscript src/R/engineer.R

small_tests: engineer


age_test: engineer


model_comparison: engineer
