# Forest Age in ML ET models: MSc Research Project  
Does forest age as a predictor in ML ET models affect spatial generalisation and accuracy?

# Steps for re-running the full analysis in this project
## Requirements  
- Micromamba installation
- To install, run:

```bash
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
```
  
## 1. Download FLUXNET data
- Download to `~/Downloads`  
- Full FLUXNET2015 data can be downloaded from https://fluxnet.org/data/download-historical-data/ and selecting FLUXNET2015: CC-BY-4.0  

## 2. Environment setup
Setup the `micromamba` and python environments to ensure reproducibility:  
  
```
# clone repo
git clone git@github.com:archiebenn/forest-age-ET.git

# navigate to project directory
cd forest-age-ET

# create and activate micromamba/conda environment
micromamba create -n forest-age-env -f environment.yml
micromamba activate forest-age-env

# ensures any additional pip packages are installed
pip install -r requirements.txt
```

## 3. Re-Running the analysis in full  
To re-run the analysis in full, use the provided Makefile as follows:  

```
make all
```

This will set up all folders, move FLUXNET data and unpack to keep only daily data, set up all data, run all necessary scripts, and save results for all scripts in `data/main/`

