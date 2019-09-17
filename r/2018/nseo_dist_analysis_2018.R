
#Estimate Line Lengths from Sub/ROV DSR surveys
#Clean up line length data and trim out bad line lengths

##REFERENCE INSTALLED PACKAGES
library(tidyverse)
library(lubridate)
library(zoo)
library(Distance)


##IMPORT NAVIGATION, QUALITY CONTROL, AND SPECIMEN DATA#########################
nseo_nav <-read_csv("data/survey/2018/NSEO/2018_NSEO_Nav_Data.csv")
nseo_qc <-read_csv("data/survey/2018/NSEO/QC_NSEO_2018.csv")
nseo_species <-read_csv("data/survey/2018/NSEO/NSEO_2018_species.csv")

#Plot ROV transects#

ggplot(nseo_nav, aes(ROV_X, ROV_Y)) + geom_point() +
  facet_wrap(~DIVE_NO, scales = "free")

##TRANSECT LINE ESTIMATION######################################################
#Need to get both tables in similar format before joining. This selects for just the dive numbers in the nav table, not text (Column DIVE_NO)
nseo_nav %>% mutate(Dive = substr(DIVE_NO, 6, 7)) -> nseo_nav

#Converts dive column from text to numeric format
nseo_nav$Dive <- as.numeric(nseo_nav$Dive)

#Rename column names (Typically from SECONDS to Seconds, but this was already "Seconds")
plyr::rename(nseo_nav, replace = c("Seconds" = "Seconds"))-> nseo_nav

#Join Tables using a "full join"
transect <- full_join(nseo_nav, nseo_qc, by = c("Dive", "Seconds"))

#Need to fill in missing values in nav table from the quality control so the good and bad sections have
#time assignments for the entire transect.

#fill() function automatically replaces NA values with previous value

#Use select() to only keep the necessary columns i.e. Seconds, Dive #, x, y, video quality (good/bad)
transect_qc <- transect %>% fill(Family) %>% filter(!is.na(Family)) %>% 
  select(Seconds, Dive, ROV_X, ROV_Y, Family) 

#Check Data
view(transect_qc)

#Four rows were empty, remove rows by using this code:
new_transect_qc <- (na.omit(transect_qc))

#Check that rows were omitted
view(new_transect_qc)

#Output cleaned data table (make sure to use updated transect_qc table)
write.csv(new_transect_qc, file = "output/2018/NSEO/new_transect_qc.csv")

#Use ggplot to look at data to identify good/bad areas:
new_transect_qc <- read_csv("output/2018/NSEO/new_transect_qc.csv")

jpeg(filename = "figures/survey/2018/NSEO/nseo_rov_transects2018.jpg",
     width = 12, height = 15, units = "in", res = 50)

ggplot(new_transect_qc, aes(ROV_X, ROV_Y)) + geom_point(aes(colour = factor(Family))) +
  facet_wrap(~Dive, scales = "free") +
  theme(axis.text.x = element_text(angle = 90))

dev.off()

#Check line transects in ArcGIS to ensure transects follow a straight path
#ggplot2() graphs can make transects look zigzaggy when they are actually straight due to scaling issues

##SMOOTHING LINE TRANSECT DATA##################################################

#Convert "Dive" column from numeric value to a factor:
new_transect_qc$Dive <-factor(new_transect_qc$Dive)
head(new_transect_qc)
str(new_transect_qc)
dim(new_transect_qc)
new_transect_qc$Dive <- factor(new_transect_qc$Dive)
levels(new_transect_qc$Dive)
is.factor(new_transect_qc$Dive)
is.numeric(new_transect_qc$Dive)

#Verify that "Dive" column was converted correctly:
glimpse(new_transect_qc)

#Save output as a pdf so it can be reviewed easily:
pdf("output/2018/NSEO/2018_nseo_smoothed_transects.pdf")

#Set up graph window as a 2X2 frame
par(mfrow = c(2,2))

#SMOOTHING FUNCTION#############################################################
#Smoothing loop that also calculates distance between points 
for (i in 1:length (levels (new_transect_qc$Dive))) {
  sT <- new_transect_qc [new_transect_qc$Dive == levels (new_transect_qc$Dive)[i],]
  
  tX <- smooth.spline(sT$Seconds, sT$ROV_X, spar = 0.7)
  tY <- smooth.spline(sT$Seconds, sT$ROV_Y, spar = 0.7)
  pX <- predict (tX) #gives the predicted values for lat by seconds for each observation at the level 
  pY <- predict (tY) #gives the predicted values for long by seconds for each observation at the level 
  
  prSp <- data.frame (pX, Y = pY$y) # creates the data frame with the pX values of seconds=x and y=lat and the pY values of long=Y
  names (prSp) <- c("Sec", "X", "Y") #renames seconds=Sec, y=X, and Y=Y
  
  
  #Calculates difference between lat and long points
  #Lat and longs are in the UTM coordinate system (Universal Transverse Mercator coordinate system)
  lon.diff<-diff(prSp$Y) 
  lat.diff<-diff(prSp$X) 
  dist=sqrt(lon.diff^2 + lat.diff^2)
  dist <- c(dist,0)                 #double check this code
  prSp$dist <- dist
  
  plot (sT$ROV_X, sT$ROV_Y, main = levels (new_transect_qc$Dive)[i],asp = 1, ylab = "Y", xlab = "X") #plots the observed unsmoothed points for lat (x) vs.long (y)
  lines (prSp$X, prSp$Y, lwd = 2, col = 5)  #draws the predicted line for lat vs. long (2=red and 5=blue) 
  
  #Output
  if (i == 1){
    outPut <- prSp
  } else {
    outPut <- rbind (outPut, prSp) 
  }
}

dev.off()

write.csv(outPut, file = "output/2018/NSEO/nseo_smooth_transect_output.csv") 

#Combines your original dataset with the predicted output from smoothing function

transect_pred <- cbind(new_transect_qc, predX = outPut$X, predY = outPut$Y, Dist = outPut$dist)

#Check and export data to be used in ArcGIS
View(transect_pred)

#Use this output for ArcGIS to determine length

write.csv(transect_pred, file = "output/2018/NSEO/2018_nseo_smooth_predict.csv") #This file will be used in ArcGIS

##CHECK TRANSECT LENGTHS IN ARCGIS##############################################

#Import smoothed data into ArcGIS (if needed)
#Convert the 2018_nseo_smoothed_predict.csv into a feature class in ArcGIS
#Create feature class from XY table, using Pred_X and Pred_Y and project the feature class
#as WGS84 UTM 8N (7N for EYKT). 


#If, for some reason this file does not output correctly to determine
#transect lengths in ArcGIS:
      ##Import "smooth_transect_output" .csv and "transect_qc" .csv into ArcGIS. 
      ##Export XY points from both files
      ##spatially join the "transect_qc" shapefile to the "smooth_transect_output shapefile.
      ##Open "Points to Line" tool and use joined shapefile for input.
      ##Export the attribute table as a .txt file - which will be your "smoothed_transect_lengths" file 
      ##that will need to be converted to a .csv file for the next step.


#This is the output from the smoothed transect made in ArcGIS (or rename Dist as Shape_Length)
nseo_transects <- read_csv("output/2018/NSEO/2018_nseo_smotth_predict_lengths.csv") #This was created in ArcGIS

transect_summary <- nseo_transects %>% group_by(Dive) %>% 
  summarise(transect_length_m = sum(Shape_Leng, na.rm = TRUE))

#Verify dive transect lengths
View(transect_summary)

##DISTANCE ANALYSIS#############################################################

#Import ROV specimen data and filter for YE only

nseo_species <- read_csv("data/survey/2018/NSEO/NSEO_2018_species.csv") %>% filter(Species == 145)
view(nseo_species)

#For the density estimate we only want adults and subadults as these are selected for in the fishery
#filter bio data so raw data is only adults and subadults for YE
ye_adult <- nseo_species %>% filter(Stage != "JV")
view(ye_adult)

#Join specimen and transect summary table together
#Columns are renamed to avoid confusion with specimen table
plyr::rename(transect_summary, replace = c("DIVE_NO" = "Dive")) -> transect_summary
view(transect_summary)

#Make sure to change the Area for each surveyed area (NSEO = 442, SSEO = 1052, CSEO = 1661, EYKT = 739)
nseo_survey <- full_join(transect_summary, ye_adult, by = "Dive") %>% 
  mutate(mgt_area = "NSEO", Area = 442, distance = abs(`Mid X (mm)` * 0.001))

view(nseo_survey)

##PREPARE DATA FOR DISTANCE ANALYSIS############################################

#If you have transects with zero fish observed you need to replace "NAs" with zero for a given transect
nseo_distance <- nseo_survey %>% select(Year, mgt_area, Area, Dive, transect_length_m, distance) %>%
  mutate(YEAR = replace_na(Year, 2018)) 

plyr::rename(nseo_distance, replace = c("mgt_area" = "Region.Label", "Dive" = "Sample.Label",
                                        "transect_length_m" = "Effort" )) -> nseo_distance

#Data has to be in a data frame in order to work in distance
as.data.frame(nseo_distance) -> nseo_distance


##2018 NSEO DENSITY ANALYSIS####################################################

#View Summary of Data
summary(nseo_distance$distance)

#View Historgram of perpendicular distance from transect line 
hist(nseo_distance$distance, xlab = "Distance (m)")

###*Model 1 - Distance Model Fitting*###########################################
nseo.model1 <- ds(nseo_distance, key = "hn", adjustment = NULL,
                  convert.units = 0.000001)

summary(nseo.model1$ddf)

plot(nseo.model1, nc = 10)



###*Model 2 - Cosine Adjustment*################################################
nseo.model2 <- ds(nseo_distance, key = "hn", adjustment = "cos",
                  convert.units = 0.000001)

summary(nseo.model2)

plot(nseo.model2)

###*Model 3 - Cosine Adjustment with hazard rate key function*##################
nseo.model3 <- ds(nseo_distance, key = "hr", adjustment = "cos",
                  convert.units = 0.000001)

summary(nseo.model3)

plot(nseo.model3)

###*Model 4 - Hazard key function with Hermite polynomial adjustment*###########
nseo.model4 <-ds(nseo_distance, key = "hr", adjustment = "herm",
                 convert.units = 0.000001)

summary(nseo.model4)

plot(nseo.model4)


###Goodness of Fit Test#########################################################
gof_ds(nseo.model1)

gof_ds(nseo.model2)

gof_ds(nseo.model3)

gof_ds(nseo.model4)

str(nseo.model1$dht$individuals, max = 1)

nseo.model1$dht$individuals$summary

nseo.model2$dht$individuals$summary

nseo.model3$sht$individuals$summary

nseo.model4$sht$individuals$summary

###Abundance Estimate###########################################################
nseo.model4$dht$individuals$N

###Density Estimate#############################################################
nseo.model4$dht$individuals$D
