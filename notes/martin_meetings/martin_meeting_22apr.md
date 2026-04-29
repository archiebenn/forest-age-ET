# supervisor meeting 22 april 10am
## lit review and project plan 
- he is going to check word counts as thinks it's wrong  
- but he was happy with my plan overall and glad i did it  

## plan note adaptations 
- big one was to cut out the satellite data aspect overall  
- but can keep it in as adding some of that data into the models
- he said to structure lit review as follows: 
    - 1. why does the water cycle matter?  
    - 2. how is the water cycle changing?  
    - 3. what we don't know/literature gaps  
    - 4. examples of using ML for ET and the case for ML here 

### for part 4. above: 
- he mentioned about issues with satellite ET models not all agreeing
- and also for satellite vs sapflow (said don't worry bout this too much) vs FLUXNET ET not necessarily all agreeing on ET  
- in other words, the field of ET predictaility **lacks theory** 
- also has 'process-based model "TRENDY" disagree' - need to look into this more  

## site selection and partitioning
### 1. Budyko curve/equation  
- PET = potetntial ET, PPT = P = precipitation
- aridity index = PET/PPT and is the **ratio of potential ET to precipitation**  
- x axis = **potential** ET to precipitation (ie. aridity index) and runs dry -> wet if PPT/PET (wet -> dry if PET/PPT - can be either in lierature)  
- y axis = AET/PPT = **actual** ET to precipitation ie. how much precip is returned as ET  
- 2 lines on a Budyko curve: 
    - 1. Water limit (where AET/PPT (y axis) = 1)
    - 2. Energy limit (where AET/PPT = PET/PPT, so 1:1 line)
- so a site's position on a curve tells you its dominant water balance regime - whether it's primarily water or energy-limited  
- ...and is therefore useful for grouping FLUXNET sites on catchment, or ecosystems by their climatic constraints = useful  
- can also be helpful to see if a site shifts on the curve over time from FLUXNET data = example of climate change  
- use to ensure ML models are trained on full breadth of aridity etc. rather than clustering  
- equally can be used to see if energy or water-limited sites behave differently in terms of how predictable their ET is in models  

### 2. Koppen climate classification  
- categorical grouping based on temp and precip thresholds  
- useful for labelling sites but is discrete and sites near boundaries get arbitrarily assigned. doesn't capture continuous nature of climate gradients  

### 3. whittaker biome diagrams  
- plot of mean annual temp (MAT) on x vs. mean annual precip (MAP) on y  
- places sites into biome spaces so is more ecologically interpretable than BUdykp  
- useful for assessing if FLUXNET sites span realistic biome diversity  

### could potentially use all three in methods
"Whittaker and Köppen to characterise and group your sites ecologically and climatically, and Budyko to situate them in water balance space and motivate hypotheses about where ET predictability should vary."

## another thing:
- martin also mentioned could do a 'space for time' look at responses after disturbances  
- would need to know baout event dates and times etc.  













