# april diss notes  
## general thoughts 
- 

# some papers for lit review  
## 21 april  
### paper 1: Evaluating Different Machine Learning Methods for Upscaling Evapotranspiration from Flux Towers to the Regional Scale -Journal of Geophysical Research: Atmospheres 
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
- 