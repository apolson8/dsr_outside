
#Reference installed packages
library(tidyverse)
library(Distance) 
library(lubridate) 
library(zoo)

#Import navigation, quality control, and specimen data
nav_sseo <- read_csv("F://SSEO2018/sseo_nav_2018.csv")
qc_sseo <- read_csv("F://SSEO2018/2018_sseo_qc.csv")
species_sseo <- read_csv("F://SSEO2018/2018_SSEO_Species.csv")

#Verify the data imported correctly
View(nav_sseo)
View(qc_sseo)
View(species_sseo)

read.table(nav_sseo)

#_________________________________________________________________
#TRANSECT LINE ESTIMATION

#Need to get both tables in similar format before joining

#This selects for just the dive numbers in the nav table
nav_sseo %>% mutate(Dive = substr(DIVE_NO, 6, 7)) -> nav_sseo

#Converts the Dive column to be numeric
nav_sseo$Dive <- as.numeric(nav_sseo$Dive)


#Rename column names
plyr::rename(nav_sseo, replace = c("SECONDS" = "Seconds"))-> nav_sseo

#Join Tables using a full_join
transect <- full_join(nav_sseo, qc_sseo, by = c("Dive", "Seconds"))

#Need to fill in missing values in nav table from the quality control so the good and bad sections have time assignments 
#for the entire transect

#fill() function automatically replaces NA values with previous value

#use select() to only keep the necessary columns i.e. Seconds, Dive #, x, y, video quality (good/bad)
transect_qc <- transect %>% fill(Family) %>% filter(!is.na(Family)) %>% 
  select(Seconds, Dive, ROV_X, ROV_Y, Family)

#Check data
transect_qc

#Output your cleaned up data table
write.csv(transect_qc, file = "F://SSEO2018/transect_qc.csv")
