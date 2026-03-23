# notes from meeting with martin 23rd march  
- went over general ideas and what i was leaning towards  
- general idea is looking at water flux over long term data - say last 15-20 years  
- is climate change affecting predictability of water flux/evapo-transpiration using ML methods?  
- could test with ML predictability + building models with/without certain variables like LAi
- would need to filter for sites with 10-20+ years of data  
- could integrate FLUXCOM data/predictions with FLUXNET data but need to be aware of differences in resolutions  
- could also somehow use ECOSTRESS data but need to be aware of temporal limitations of ISS as not daily passes  
- focus on FLUXNET specifics, don't go down too many rabbit holes as a lot of literature  
- ie. how is water flux changing across FLUXNET?  
- look into water flux ML specifically (martin said he didn't know much surrounding this)  

## predictive models  
- for long term trends  
- general idea ->  given 15 years of data, split 10 for training and most recent 5 for testing  
- can including/excluding certain variables affect predictability?  
- ie train 2 models: one inc. LAi, one without  
- do these two models predict most recent 5 years differently?  
- if one with variable e.g LAi is different + more accurate, indicates variable is important with regards to climate change   
- 


## Evapo-transpiration (ET)  
- ET is largely sum of transpiration + Evaporation_canopy + Evaporation_soil  
- when recording data sometimes a gap is used 2 days after rainfall  
- this minimises E_c and E_soil to just leave an estimate of transpiration  

## Gross primary productivity (GPP)  
- essentially a sum of photosynthesis  

### H1: leaf area index (LAi)
- from satellite data  
- variable in water/carbon flux ie. affects evapotranspiration (ET)  
- link between co2 conc., LAi, ET?  
- known as "greening" in the literature ie. higher LAi = more greening  


### H2: stress  
- does this affect water flux?  
- didn't really go into much detail  


### H3: Windyness
- also threw in this idea  
- again didn't go into much detail ubt went over how it has been changing over time  

### interesting side note  
- on ET  
- idea 1 = more co2 -> more photosynthesis (A) + less stomatal conductance = LESS ET  
- idea 2 = more co2 -> more photosynthesis = more LAi = MORE ET  
- could somehow try to bring in to testing?  

## to-do going forward for next meeting/Lit Review  
- look over reviews on ET and LAi/greening  
- look specifically into papers on FLUXNET and greeing/water flux  
- look into water flux ML models  
- literature review themes - even just some headings but try to flesh out a structure  
- ie. lit review subheadings + wordcounts to try and not go down too many rabbit holes  














