# Assessment of the demersal shelf rockfish stock complex in the southeast outside subdistrict of the Gulf of Alaska 

Please direct any questions to: Andrew Olson (andrew.olson@alaska.gov) and Kellii Wood (kellii.wood@alaska.gov) <img src="http://acuasi.alaska.edu/sites/default/files/inline-images/fishandgame_small.png" width = "75" height = "75"> 

**Source:** *Olson, A., Williams, B., and Jaenicke, M. (in press). Chapter 14: Assessment of the demersal shelf rockfish stock complex in the southeast outside subdistrict of the Gulf of Alaska. Stock Assessment and Fishery Evaluation Report for the Groundfish Resources of the Gulf of Alaska. North Pacific Fishery Management Council, Anchorage, AK.*

## Commercial Fishery Development and History
The demersal shelf rockfish (DSR) assemblage is composed of 7 species: yelloweye(*Sebastes rubberimus*), quillback (*S. maliger*), copper (*S. caurinus*), rosethorn (*S. helvomaculatus*), China (*S. nebulosus*), canary (*S. pinniger*), and tiger rockfish (*S. nigrocinctus*) with yelloweye being the predominant species harvested.  The commercial fishery has been active since the late 1979 and catch data prior to 1992 is problematic due to changes in the DSR species assemblage as well as the lack of a directed fishery harvest card prior to 1990 for Central Southeast Outside (CSEO), Southern Southeast Outside (SSEO), and Northern Southeast Outside (NSEO), and in 1992 for East Yakutat (EYKT) management areas. The directed DSR catch in SEO was above 350 t in the mid-1990s. Since 1998, landings have been below 250 t, and since 2005, directed landings have typically been less than 100 t. During the reported years total harvest peaked at 604 t in 1994, and directed harvest peaked at 381 t in 1994. Although directed landings were higher in the 1990s, since 2000, 58.7% of the DSR total reported catch is from incidental catch of DSR in the halibut fishery. It should be emphasized, however, that prior to 2005, unreported mortality from incidental catch of DSR associated with the halibut and other non-directed fisheries is unknown and may have been as great as a few hundred tons annually. This is due to full retention requirements that were passed by the NPFMC in 1998 did not go into effect until 2005 where fishermen are required to retain and report all DSR caught.  Directed commercial fishery landings have often been constrained by other fishery management actions. In 1992, the directed DSR fishery was allotted a separate halibut prohibited species cap (PSC) and is therefore no longer affected when the PSC is met for other longline fisheries in the GOA. In 1993, the directed fishery was closed early due to an unanticipated increase in DSR incidental catch during the halibut fishery. However, now the incidental catch must be projected because the directed fishery occurs before the Pacific halibut fishery, which starts in mid-March. 

Directed commercial fisheries are held in the four management areas (EYKT, NSEO, SSEO, and CSEO) if there is sufficient quota available after the DSR mortality in other commercial fisheries (primarily the IFQ halibut fishery) is estimated. The directed fishery in NSEO has been closed since 1995; the total allocation for this management area has not been sufficient to prosecute an orderly fishery. The directed commercial DSR fisheries in the CSEO and SSEO management areas were not opened in 2005 because it was estimated that total mortality in the sport fishery was significant and combined with the directed commercial fishery would likely result in exceeding the TAC. No directed fisheries occurred in 2006 or 2007 in the SEO district as ADFG took action in two areas; one was to enact management measures to keep the catch of DSR in the sport fishery to the levels mandated by the Board of Fisheries (BOF), and the other was to further compare the estimations of incidental catch in the halibut fishery to the actual landings from full retention regulations in the commercial fishery in those years to see how closely our predicted incidental catch matched commercial landings. From 2008–2014, there was sufficient quota to hold directed commercial fisheries in at least two of the four SEO management areas. From 2015–2017, only EYKT, and in 2018 only CSEO were open to directed fishing. 

## Data Sources

### Commercial Fishery
* Directed commercial fishery
* Bycatch from groundfish fisheries
  + Halibut IFQ
  + Sablefish IFQ
  + Lingcod 
  + Pacific cod
  + Black rockfish 
* Bycatch in salmon troll fishery

### Sport Fishery
* Charter logbook (guided)
* State-wide harvest survey (un-guided)

### Subsistence Fishery
* Community harvest interviews and surveys

### Survey
* ROV survey

## Yelloweye Rockfish Survey Density Estimate using Distance Sampling Methodology

The `Distance` package is used to estimate population densities and abundances using line and point transect sampling methodology. For Southeast Alaska yelloweye rockfish (YE) we conduct line transects using an remotely operated vehicle (ROV) to conduct line transects in YE rocky habitat and conduct video review to determine species ID and lengths.

Distance sampling has 3 key assumptions that include:

**1. Objects on the line or point are detected with certainty;**
  
  i) We detect fish on both sides of the transect line using the ROV stereo left and right cameras and the belly camera is used to detect any fish that may have been overlooked that we cold not initially detect with the stereo cameras.  

**2. Objects do not move;**

  i) As the ROV is moving we will often see fish in a resting state or moving as the ROV approaches and are assumming the ROV has no behavioral affect on fish, therefore it is important to ensure fish are detected on their first appearance.  

**3. Measurements are exact.**

  i) During video review you collect measurements from the transect line that are converted within the Eventmeasure software from a radial measurement (distance measurement from ROV point of view) to a perpendicular measurement (distance measurement from ROV side view).
  
### Survey Data
Survey data consists of multiple tables that will need to be tidied, summarized, and joined.  You will be working with 3 main tables in order to produce a valid density estimate which consist of:

**1. ROV Navigation Table**
    
  i) This table consists of the dive number, time (UTC seconds), vessel and ROV position in UTM projection (meters), ROV heading, etc.  We are mainly concerned with the dive number, time, and ROV position as this will tells us when and where the ROV is while we are conducting video review.  
    
**2. Specimen Table**

  i) This is created during the video review process in the EventMeasure software and consists of video file name, Time (use UTC seconds), length (mm) measurement (YE only), precision and direction of length measurement, x, y, z distance from the transect line (MID_X represents the perpendicular distance from the transect line at which a fish was detected), species ID (DSR, lingcod, and black rockfish), specimen number, stage (adult, subadult or juvenile used for YE only), and activity.

**3. Video Quality Control**

  i) Reviews quality of video for good and bad segments for each line transect that is then used in determining good length transects from the ROV nav data and consists of video filename, video frame, time (UTC seconds), dive number, video quality (good or bad), video quality code, description of good and bad assignments (i.e. good going forward, ROV loitering in same area, going over a large drop-off, etc.), and a start and end assignment for each transect. 
  
<img src="https://i.imgur.com/6l7IpTA.png?1">

### Exploratory Analysis
Post-tidying survey data is analyzed using histograms as an exploratory analysis to determine oddities in the data visually.  The general pattern we want to see is a shoulder shape with the highest detection of fish occuring closest to the transect line with detection decreasing as distance from the transect line increases.  If oddities occur such as, spikes, heaped, overdisperesed, or generally poor data this is most likely due to bad lighting during video review, camera issues, ROV data, etc.  Best step to do is double-check your raw data and ensure you have tidied your data correctly for analysis.  If issues still remain we can establish bin sizes within the historgram, cutoff points, and truncate the data so it works nicely.

![](http://distancesampling.org/images/distance-animation.gif)

<img src="https://i.imgur.com/2NtktLg.png"> 

**Source:** http://distancesampling.org


### Model Fit and Selection

A probability detection function is fit to the survey data which describes the relationship between distance and the probablity of detecting a fish.  When selecting a model there are a few items to consider including: 

**1. Model Robustness**--use a model that will fit a wide variety of plausible shapes for *g(x)*;

**2. Shape Criterion**--use a model with a good shoulder;

**3. Pooling Robustness**--use a model for the average detection function, even when many factors affect detectability;

**4. Estimator Efficiency**--use a model that will lead to a precise estimator of density.

<img src="https://i.imgur.com/xCozhZx.png">

**Source:** http://distancesampling.org

**Model Fit:**
Model fitting is composed of 2 key features: key functions which determines the basic model shape and adjustment terms that can make models more robust

| **Key Function**     | **Adjustment Term** |
| -------------------- | ------------------- |
| Uniform              | Cosine              |
| Half Normal          | Hermite Polynomial  |
| Hazard Rate          | Simple Polynomial   |
| Negative Exponential |                     |
  
Note that the more parameters you fit the greater the flexibility is fitting the probability detection function, however, uncertainty increases.  Models with too few parameters tend to produce esimtates with low variance and high bias, where as models with too many parameters tend to produce estimates with low bias and high variance.  The most common key function/adjustment term combinations that are used are half normal/cosine and hazard rate/hermite polynomial.  

*Ex.* `sseo.model1 <- ds(tidy_data, key = "hr", adjustment = "herm", convert.units = 0.000001)`

Converting units here ensures that all our distance measurements are in meters and converts our survey area (km<sup>2</sup>) to meters. 

**Model Selection Criteria:**

When we are choosing the best model there are a number of criteria that we must look and and test which includes:


**1. Good shoulder fit**; 

**2. Akaike's Information Criterion (AIC):** determines which model is best based on the probability detection function likelihood and the number of parameters in the model.  Lower AIC values are best.  In the case where the difference between model AICs is less than 2, we should select the simplest of the models;

**3. Fewest number of parameters**;

**4. Low standard error associated with N**;

**5. Goodness of Fit Test:** test that determines if our sample data represents what we would actually see in nature;  

**6. QQ-Plot:** plot of data should fit a fairly straight line indicating the data has a normal distribution.  Look out for major outliers, gaps, step-wise patterns, and poor fit.  

When you have selected your model you can look at the model `summary()` to obtain a YE density estimate for your surveyed area with associated standard error (se), coefficient of variance (cv), lower and upper confidence levels (lcl & ucl), and degrees of freedom (df). 

## References

1. Miller, D.L., Rexstad, E., Thomas, L., Marshall, L., and Laake, J. (2017). "*Distance Sampling in R*".
    bioRxiv 063891, doi:(https://doi.org/10.1101/063891).



