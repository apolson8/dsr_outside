# Assessment of the demesal shelf rockfish stock complex in the southeast outside subdistrict of the Gulf of Alaska

Please direct any questions to: Andrew Olson (andrew.olson@alaska.gov)

Source: 

*A.	Olson, A., Williams, B., and Jaenicke, M. (in press). Chapter 14: Assessment of the demersal shelf rockfish stock complex in the southeast outside subdistrict of the Gulf of Alaska. Stock Assessment and Fishery Evaluation Report for the Groundfish Resources of the Gulf of Alaska. North Pacific Fishery Management Council, Anchorage, AK.*

## Commercial Fishery Development and History
The DSR fishery has been active since the late 1979 and catch data prior to 1992 is problematic due to changes in the DSR species assemblage as well as the lack of a directed fishery harvest card prior to 1990 for CSEO, SSEO, and NSEO, and in 1992 for EYKT. The directed DSR catch in SEO was above 350 t in the mid-1990s. Since 1998, landings have been below 250 t, and since 2005, directed landings have typically been less than 100 t. During the reported years total harvest peaked at 604 t in 1994, and directed harvest peaked at 381 t in 1994. Although directed landings were higher in the 1990s, since 2000, 58.7% of the DSR total reported catch is from incidental catch of DSR in the halibut fishery. It should be emphasized, however, that prior to 2005, unreported mortality from incidental catch of DSR associated with the halibut and other non-directed fisheries is unknown and may have been as great as a few hundred tons annually. This is due to full retention requirements that were passed by the NPFMC in 1998 did not go into effect until 2005 where fishermen are required to retain and report all DSR caught.  Directed commercial fishery landings have often been constrained by other fishery management actions. In 1992, the directed DSR fishery was allotted a separate halibut prohibited species cap (PSC) and is therefore no longer affected when the PSC is met for other longline fisheries in the GOA. In 1993, the directed fishery was closed early due to an unanticipated increase in DSR incidental catch during the halibut fishery. However, now the incidental catch must be projected because the directed fishery occurs before the Pacific halibut fishery, which starts in mid-March. 

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

### Survey
* ROV survey

### Survey Density Estimate using Distance Sampling Methodology
The `Distance` package is used to estimate population densities and abundances using line and point transect sampling methodology. For Southeast Alaska yelloweye rockfish (YE) we conduct line transects using an remotely operated vehicle (ROV) to conduct line transects in YE rocky habitat and conduct video review to determine species ID and lengths.

Distance sampling has 3 key assumptions that include:

**1. Objects on the line or point are detected with certainty;**
  
  i) We detect fish on both sides of the transect line using the ROV stereo left and right cameras and the belly camera is used to detect any fish that may have been overlooked that we cold not initially detect with the stereo cameras.  

**2. Objects do not move;**

  i) As the ROV is moving we will often see fish in a resting state or moving as the ROV approaches and are assumming the ROV has no behavioral affect on fish, therefore it is important to ensure fish are detected on their first appearance.  

**3. Measurements are exact.**

  i) During video review you collect measurements from the transect line that are converted within the Eventmeasure software from a radial measurement (distance measurement from ROV point of view) to a perpendicular measurement (distance measurement from ROV side view).
  
### Survey Data
Survey data consists of multiple tables that will need to be summarized and joined.  You will be working with 3 main tables in order to produce a valid density estimate which consist of:

**1. ROV Navigation Table**
    
  i) This table consists of the dive number, time (UTC seconds), vessel and ROV position in UTM projection (meters), ROV heading, etc.  We are mainly concerned with the dive number, time, and ROV position as this will tells us when and where the ROV is while we are conducting video review.  
    
**2. Specimen Table**

  i) This is created during the video review process in the EventMeasure software and consists of video file name, Time (use UTC seconds), length (mm) measurement (YE only), precision and direction of length measurement, x, y, z distance from the transect line (MID_X represents the perpendicular distance from the transect line at which a fish was detected), species ID (DSR, lingcod, and black rockfish), specimen number, stage (adult, subadult or juvenile used for YE only), and activity.

**3. Video Quality Control**

  i) Reviews quality of video for good and bad segments for each line transect that is then used in determining good length transects from the ROV nav data and consists of video filename, video frame, time (UTC seconds), dive number, video quality (good or bad), video quality code, description of good and bad assignments (i.e. good going forward, ROV loitering in same area, going over a large drop-off, etc.), and a start and end assignment for each transect. 
  
```{r, echo=FALSE}
library(DiagrammeR)
mermaid("
graph TD
    A[ROV Survey] --> B[Navigation Data]
    A[ROV Survey] --> C[Video Review]
    C[Video Review] --> D[EventMeasure]
    D[EventMeasure Software] --> E[Species ID]
    D[EventMeasure Software] --> F[Species Length]
    D[EventMeasure Software] --> G[Quality Control]
    B[Navigation Data] --> H[Transect Length Estimation]
    G[Quality Control] --> H[Transect Length Estimation]
    E[Species ID] --> I[Specimen Data]
    F[Species Length] --> I[Specimen Data]
    H[Transect Length Estimation] --> J[Survey Data]
    I[Specimen Data] --> J[Survey Data] 
    

")
```



