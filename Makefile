# Makefile for MSc Dissertation.
# usage: make [target]
# author:  Archie Benn sj19031@bristol.ac.uk
# May - September 2026

.PHONY: help all setup sites map fluxnet lai filter ET_plots climates sorting filter2 gams engineer grid_search single_held_out generate_plots gower analysis_1.1 analysis_1.2 analysis_2 case_study tex_plots diss

.DEFAULT_GOAL := help

ARCHITECTURE ?= rf

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

all: setup sites fluxnet lai filter ET_plots climates sorting filter2 engineer gower analysis_1.1 analysis_1.2 analysis_2 case_study map tex_plots diss

setup: ## setup the folder structure for data to be read into/out of
	./scripts/bash/setup.sh

sites: ## data prep  part 1 - filter sites, make csv, create world map
	Rscript scripts/R/01_sites.R

map: ## make a world map, compile standalone tikz to PDF
	Rscript scripts/R/02_site_maps.R

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

grid_search: ## added later, but this uses GroupKFold searching to find the best model parameters for the subsequent RF models
	python scripts/python/15.5_gridsearch.py

single_held_out: ## python script which runs multiple ML architectures and generates preds and stats per site
	python scripts/python/16_ML_single_held_out.py 

generate_plots: ## R script which generates predicted vs. observed plots fo different architectures and models  
	Rscript scripts/R/17_plots_generate.R

gower: ## dissimilarity calculation for site features (to characterise these sites)
	Rscript scripts/R/20_gower_pam.R

analysis_1.1: ## tests the effect of iterative addition of features to RF models with r-squared and rmse of predictions against the 7 medoid test sites
	python scripts/python/21_analysis_1.1.py

analysis_1.2: ## large scale train/test loops. trains on 20 random sites and predicts on 7 medoid/cluster sites, then saves metrics and repeats
	python scripts/python/22_analysis_1.2.py

analysis_2: ## temporal analysis - trains RF models on earliest 80% of FLUXNET data and then tests against the most recent 20%, site by site
	python scripts/python/23_analysis_2.py 

case_study: ## looking into US-Umd and DE-Lnf in depth with SHAP values and straining site age perturbations
	python scripts/python/27_case_study.py

tex_plots: ## run latex on the individual plots from tikzDevice for integration as pdfs into main .tex 
	cd diss/figures && pdflatex -interaction=nonstopmode world_sites.tex
	cd diss/figures && pdflatex -interaction=nonstopmode 1.1_p1.tex
	cd diss/figures && pdflatex -interaction=nonstopmode 1.2_p3.tex
	cd diss/figures && pdflatex -interaction=nonstopmode 1.2_gower_r2.tex
	cd diss/figures && pdflatex -interaction=nonstopmode pheat2.tex
	cd diss/figures && pdflatex -interaction=nonstopmode case_study_bars.tex
	cd diss/figures && pdflatex -interaction=nonstopmode cluster_plot.tex
	cd diss/figures && pdflatex -interaction=nonstopmode world_sites_clusters.tex
	cd diss/figures && pdflatex -interaction=nonstopmode umd_main.tex
	cd diss/figures && pdflatex -interaction=nonstopmode umd_main2.tex
	cd diss/figures && pdflatex -interaction=nonstopmode lnf_main.tex
	cd diss/figures && pdflatex -interaction=nonstopmode lnf_main2.tex
	cd diss/figures && pdflatex -interaction=nonstopmode umd_shap_diff.tex
	cd diss/figures && pdflatex -interaction=nonstopmode lnf_shap_diff.tex
	cd diss/figures && pdflatex -interaction=nonstopmode lnf_scatter.tex
	cd diss/figures && pdflatex -interaction=nonstopmode umd_scatter.tex
	cd diss/figures && pdflatex -interaction=nonstopmode age_et_gam.tex
	cd diss/figures && pdflatex -interaction=nonstopmode age_et_gam_ns.tex
	cd diss/figures && pdflatex -interaction=nonstopmode shap_dependence.tex





diss: tex_plots ## compile diss PDF with LaTeX
	cd diss/main && latexmk -pdf dissertation.tex && xdg-open dissertation.pdf
