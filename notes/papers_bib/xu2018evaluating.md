
# paper 1: Evaluating Different Machine Learning Methods for Upscaling Evapotranspiration from Flux Towers to the Regional Scale -Journal of Geophysical Research: Atmospheres 
## introduction
- upscale ET from 36 flux tower sites (65 site years) to regional scale 
- ML methods: artificial neural network, cubist, deep belief network, RF, and support vector machine  
- essentially took these methods and trained on those 65 years... 
- then applied to estimate on each grid cell within a watershed between 2012-2016  
- deep belief was worst, others had similar performance, and RF had lowest relative uncertainty (from three-cornered hat method)  
- ML performed better on densely vegetated conditions than barren/sparse land 
- "Satellite sensors detecting two-dimensional information of land surface become an effective way to upscale ET from flux towers to large areas." - 4 methods:   
- - 1) predictive equations which link ET observations (flux towers) to vegetation indices (e.g LAi), land surface temp. observations, and meteorological parameters (e.g net radiation, precip, air temp.)  
- - 2) "geostatistical methods" based on kriging theoretical framework  
- - 3) using semi-theoretical or running theoretical methods  
- - 4) using ML methods  
- "All of these studies (lists ML methods for ET flux predictions) trained the machine learning models with flux observations and other groundmeasured variables related to ET or sensible and latent heat fluxes. The trained models were then applied to produce ET over continental or global scales with remote sensing and meteorological inputs."  

## methods overview  
- went over the 5 ML methods  
- study area and data sets 
- looks at specific river basin in China  
- goes over how upstream/midstream/downstream areas in basin are characterised by weather and vegetation like '...mountaineous areas with relatively high precip and mainly covered by grassland...'  
- hydrometeorology observation network was set up within the basin in 2008-2011  
- ET observations from eddy covariance (EC) towers (flux towers) was used to test the ML models performance   

### specific methods  
- ET trained and predicted using equation in lit review notes  
- performance for models was evaluated **across all land types** using global k-fold cross validation testing  
- 5 sensitivity tests (LOOK INTO) were conducted to explore ET prediction performances by using different explanatory variables - variables were successively added and R-squared and RMSE compared across the 5 different models = **improved with added features**  
- performance was evaluated using **EC observed (true - x) against ET predicted (y)** and R-squared calculated  
- these performances are calculated using the 3 cornered hat method where different tools predicting the same value can have their relative uncertainties calculated   

## results  
- performance of the 5 models was tested against observed EC data 2012-2016 using R-squared plot  
- all 5 rough;y followed 1:1 line, with R-2 values of 0.87-0.89  
- RMSE was also calculated alongside MAPE (?)  
- so performance evaluated using R-2, RMSE, and MAPE  
- as all relatively similar, relative uncertainty was important with 3 cornered hat method  
- RF model slightly outperformed the other ML methods based on R2, MAPE, RMSE and relative uncertainties   
- therefore RF model was taken forward to predict 2012-2016 over river basin  

## limitations 


## key takeaways  
- comparison of **relative** (not absolute)  uncertainties of ML model ET predictions calculated using 3 cornered hat method  
- equation for ML models  
- sensitivity tests to compare models with successively added predictor variables  
- RMSE, MAPE, and R2 for comparing to EC observed ET data for accuracy  
- Used 3 stage validation: 
- - Site scale — test all five models against eddy covariance tower data (direct but point measurements)  
- - Regional scale validation — test against large aperture scintillometer (LAS) data, which measures ET over a footprint of several km², bridging the gap between a tower point and a regional map  
- - TCH uncertainty — since no single "truth" exists at full regional scale, TCH is used to rank the models by their relative uncertainty across space  
- ET relative uncertainty was tested across seasons and ground cover types e.g grassland/barren land  
- 5 models performances were largely identical in upscaling ET predictions  





















