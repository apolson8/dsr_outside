
#Estimate Line Lengths from Sub/ROV DSR surveys
#Clean up line length data and trim out bad line lengths
library(tidyverse)
library(lubridate)
library(zoo)
library(Distance)


#Import Survey Navigation Data and Video Quality Control Review Data

#Navigation file for ROV tracking during transects - Dives 25 and 26 were removed prior to import.
#Those dives were test dives for black rockfish
cseo_nav <-read_csv("data/survey/2018/CSEO/2018_cseo_nav_data.csv")

ggplot(cseo_nav, aes(ROV_X, ROV_Y)) + geom_point() +
  facet_wrap(~DIVE_NO, scales = "free")

#Video quality control review used for trimming out bad sections of the nav data - Dives 25 and 26 were removed prior to import.
cseo_qc <- read_csv("data/survey/2018/CSEO/2018_cseo_qc.csv")


#Need to get both tables in similar format before joining
#This selects for just the dive numbers in the nav table
cseo_nav %>% mutate(Dive = substr(DIVE_NO, 6, 7)) -> cseo_nav

cseo_nav$Dive <- as.numeric(cseo_nav$Dive)

#Rename column names
plyr::rename(cseo_nav, replace = c("SECONDS" = "Seconds"))-> cseo_nav

#Join Tables
transect <- full_join(cseo_nav, cseo_qc, by = c("Dive", "Seconds"))

#Need to fill in missing values in nav table from the quality control so the good and bad sections have
#time assignments for the entire transect
#fill() function automatically replaces NA values with previous value
#use select() to only keep the necessary columns i.e. Seconds, Dive #, x, y, video quality (good/bad)
transect_qc <- transect %>% fill(Family) %>% filter(!is.na(Family)) %>% 
  select(Seconds, Dive, ROV_X, ROV_Y, Family) 


write.csv(transect_qc, file = "output/2018/CSEO/transect_qc.csv")

View(transect_qc)

transect_qc <- read_csv("output/2018/CSEO/transect_qc.csv")

jpeg(filename = "figures/cseo_rov_transects2018.jpg",
     width = 12, height = 15, units = "in", res = 50)

ggplot(transect_qc, aes(ROV_X, ROV_Y)) + geom_point(aes(colour = factor(Family))) +
  facet_wrap(~Dive, scales = "free") +
  theme(axis.text.x = element_text(angle = 90))

dev.off()

#Check line transects in ArcGIS to ensure transects follow a straight path
#ggplot2() graphs can make transects look zigzaggy when they are actually straight
#due to scaling issues

#Smoothing line transect data

head(transect_qc)
str(transect_qc)
dim(transect_qc)
transect_qc$Dive <- factor(transect_qc$Dive)
levels(transect_qc$Dive)
is.factor(transect_qc$Dive)
is.numeric(transect_qc$Dive)

pdf("output/2018/CSEO/2018_cseo_smoothed_transects.pdf")



#Smoothing Loop that also calculates distance between points
par(mfrow = c(2, 2))
for (i in 1:length (levels (transect_qc$Dive))) {
  sT <- transect_qc [transect_qc$Dive == levels (transect_qc$Dive)[i],]
  
  tX <- smooth.spline(sT$Seconds, sT$ROV_X, spar = 0.7)
  tY <- smooth.spline(sT$Seconds, sT$ROV_Y, spar = 0.7)
  pX <- predict (tX) ##gives the predicted values for lat by seconds for each observation at the level 
  pY <- predict (tY) ##gives the predicted values for long by seconds for each observation at the level 
  
  prSp <- data.frame (pX, Y = pY$y) ## creates the data frame with the pX values of seconds=x and y=lat and the pY values of long=Y
  names (prSp) <- c("Sec", "X", "Y") ##renames seconds=Sec, y=X, and Y=Y
  
  
  #Calculates difference between lat and long points
  #Lat and longs are in the UTM coordinate system (Universal Transverse Mercator coordinate system)
  lon.diff<-diff(prSp$Y) 
  lat.diff<-diff(prSp$X) 
  dist=sqrt(lon.diff^2 + lat.diff^2)
  dist <- c(dist,0)                 #double check this code
  prSp$dist <- dist
  
  plot (sT$ROV_X, sT$ROV_Y, main = levels (transect_qc$Dive)[i],asp = 1, ylab = "Y", xlab = "X") #plots the observed unsmoothed points for lat (x) vs.long (y)
  lines (prSp$X, prSp$Y, lwd = 2, col = 5)  #draws the predicted line for lat vs. long (2=red and 5=blue) 
  
  ## output 
  if (i == 1){
    outPut <- prSp
  } else {
    outPut <- rbind (outPut, prSp) 
  }
}

dev.off()

write.csv(outPut, file = "output/2018/CSEO/cseo_smooth_transect_output.csv") 

transect_pred <- cbind(transect_qc, predX = outPut$X, predY = outPut$Y, Dist = outPut$dist)

transect_pred
view(transect_pred)
view(transect_qc)

##Use this output for ArcGIS to determine length

write.csv(transect_pred, file = "output/2018/CSEO/2018_cseo_smooth_predict.csv")

  #If, for some reason this file does not output correctly to determine
  #transect lengths in ArcGIS:
      ##Import "smooth_transect_output" .csv and "transect_qc" .csv into ArcGIS. 
      ##Export XY points from both files
      ##spatially join the "transect_qc" shapefile to the "smooth_transect_output shapefile.
      ##Open "Points to Line" tool and use joined shapefile for input.
      ##Export the attribute table as a .txt file - which will be your "smoothed_transect_lengths" file 
      ##that will need to be converted to a .csv file for the next step.


#This is the output from the smoothed transect made in ArcGIS
cseo_transects <- read_csv("data/survey/2018/CSEO/CSEO_2018_smoothed_transect_lengths.csv") 

transect_summary <- cseo_transects %>% group_by(Dive) %>% 
  summarise(total_length_m = sum(Shape_Length, na.rm = TRUE))


#Verify dive transect lengths
#How to exclude dives from transect summary (filter(Dive != 8))


#Import ROV specimen data and filter for YE only

cseo_bio <- read_csv("data/survey/2018/CSEO/2018_cseo_species.csv") %>% filter(SPECIES == 145)
view(cseo_bio)

#For the density estimate we only want adults and subadults as these are selected for in the fishery
#filter bio data so raw data is only adults and subadults for YE
ye_adult <- cseo_bio %>% filter(STAGE != "JV")


#Join specimen and transect summary table together
#Columns are renamed to avoid confusion with specimen table
plyr::rename(transect_summary, replace = c("Dive" = "DIVE_NO", "total_length_m" = "transect_length_m")) -> transect_summary


cseo_survey <- full_join(transect_summary, ye_adult, by = "DIVE_NO") %>% 
  mutate(mgt_area = "CSEO", Area = 1056, distance = abs(`MID_X (MM)` * 0.001))


#Prepare data for distance analysis
#If you have transects with zero fish observed you need to replace "NAs" with zero for a given transect
cseo_distance <- cseo_survey %>% select(YEAR, mgt_area, Area, DIVE_NO, transect_length_m, distance) %>%
  mutate(YEAR = replace_na(YEAR, 2018)) 

plyr::rename(cseo_distance, replace = c("mgt_area" = "Region.Label", "DIVE_NO" = "Sample.Label",
                                        "transect_length_m" = "Effort" )) -> cseo_distance

#Data has to be in a data frame in order to work in distance
as.data.frame(cseo_distance) -> cseo_distance


#2018 CSEO Density Analysis#

#View Summary of Data
summary(cseo_distance$distance)

#View Historgram of perpendicular distance from transect line
hist(cseo_distance$distance, xlab = "Distance (m)")

#Distance Model fitting
cseo.model1 <- ds(cseo_distance, key = "hn", adjustment = NULL,
                  convert.units = 0.000001)

summary(cseo.model1$ddf)

plot(cseo.model1, nc = 10)

#Cosine Adjustment
cseo.model2 <- ds(cseo_distance, key = "hn", adjustment = "cos",
                  convert.units = 0.000001)

summary(cseo.model2)

plot(cseo.model2)

#Cosine Adjustment with hazard rate key function
cseo.model3 <- ds(cseo_distance, key = "hr", adjustment = "cos",
                  convert.units = 0.000001)

summary(cseo.model3)

plot(cseo.model3)

#Hazard key function with Hermite polynomial adjustment
cseo.model4 <-ds(cseo_distance, key = "hr", adjustment = "herm",
                 convert.units = 0.000001)

summary(cseo.model4)

plot(cseo.model4)


#Goodness of Fit Test
gof_ds(cseo.model1)

gof_ds(cseo.model2)

gof_ds(cseo.model3)

str(cseo.model1$dht$individuals, max = 1)

cseo.model2$dht$individuals$summary

cseo.model3$sht$individuals$summary


#Abundance Estimate#
cseo.model4$dht$individuals$N

#Density Estimate
cseo.model4$dht$individuals$D
