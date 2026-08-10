# analysis_2.py - part 2 of final analysis for dissertation
# this script is the temporal preiction aspect of the dissertation - it builds RF models on historical FLUXNET data per site and predicts the most recent data
# date: 10-8-2026
# author: Archie Benn sj19031@bristol.ac.uk


import os
import pandas as pd
import numpy as np
from datetime import datetime
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import r2_score, mean_squared_error

# set wd 
os.chdir('/home/ab/Dropbox/university/github/bbinf_project')

# timestamp for runs/file names e.g 0505_1738 
timestamp = datetime.now().strftime("%d%m_%H%M")