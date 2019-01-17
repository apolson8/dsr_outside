#Distance Analysis for YE#
library(dplyr)
library(ggplot2)
library(Distance)
library(readxl)
library(tidyr)

#Import Data and filter for out other species and transect types
#except for YE and "Line Transect"
survey_lengths <- read_excel("data/survey/ye_lengths_ROV_survey.xlsx", sheet = 2)

survey_lengths %>% filter(species_code == 145) -> survey_lengths

transects <- read_excel("data/survey/ye_transects_ROV_survey.xlsx")

transects %>% group_by(Year, `Management Area`, `Dive Number`)%>%
  filter(`Species Code` == 145, `Transect Type` != "Experimental")-> transects

#Rename column names
plyr::rename(transects, replace = c("Year" = "year", "Management Area" = "mgt_area",
                                    "Transect Number" = "transect_no", "Obs Number" = "specimen_no",
                                    "Line Length Meters" = "line_length_m", "Distance Feet" = "dist_ft",
                                    "Depth Meters" = "depth_m", "Dive Number" = "dive_no")) -> transects
#Join tables
 survey<- left_join(survey_lengths, transects, by = c("year", "mgt_area", "dive_no", "transect_no", "specimen_no"))
 
 #Add Survey Area estimates by mgt area
 #Mutated dist_ft to meters but has to be labeled "distance"
survey %>% mutate(Area = ifelse(mgt_area == "EYKT", 739,
                              ifelse(mgt_area == "NSEO", 442,
                              ifelse(mgt_area == "CSEO", 1661,
                              ifelse(mgt_area == "SSEO", 1056, "NA"))))) %>%
  mutate(distance = abs(dist_ft * 0.3048))-> survey


#Output new table to .csv and re-import back in for analysis
write.csv(survey, file = "output/rov_survey.csv")

rov_survey <-read.csv("output/rov_survey.csv", header = TRUE)

rov_survey %>% filter(stage != "juvenile") %>% 
  select(year, mgt_area, Area, dive_no, transect_no, specimen_no, line_length_m,
                                                    distance) -> rov_survey

plyr::rename(rov_survey, replace = c("mgt_area" = "Region.Label", "dive_no" = "Sample.Label",
                                     "line_length_m" = "Effort" )) -> rov_survey

                      

#2016 CSEO Density Analysis#
survey_CSEO2016 <- rov_survey %>% filter(year == 2016, Region.Label == "CSEO")

#View Summary of Data
summary(survey_CSEO2016$distance)

#View Historgram of perpendicular distance from transect line
hist(survey_CSEO2016$distance, xlab = "Distance (m)")

#Distance Model fitting
cseo.model1 <- ds(survey_CSEO2016, key = "hn", adjustment = NULL,
                  convert.units = 0.000001)

summary(cseo.model1$ddf)

plot(cseo.model1, nc = 10)

#Cosine Adjustment
cseo.model2 <- ds(survey_CSEO2016, key = "hn", adjustment = "cos",
                  convert.units = 0.000001)

summary(cseo.model2)

plot(cseo.model2)

#Hazard key function with Hermite polynomial adjustment
cseo.model3 <-ds(survey_CSEO2016, key = "hr", adjustment = "herm",
                 convert.units = 0.000001)

summary(cseo.model3)

plot(cseo.model3)


#Goodness of Fist Test
gof_ds(cseo.model1)

gof_ds(cseo.model2)

gof_ds(cseo.model3)

str(cseo.model1$dht$individuals, max = 1)

cseo.model2$dht$individuals$summary

cseo.model3$sht$individuals$summary


#Abundance Estimate#
cseo.model2$dht$individuals$N

#Density Estimate
cseo.model2$dht$individuals$D



#2018 SSEO Density Estimate#

#Filter out SSEO data for 2018 from YE survey length table
sseo_2018 <- survey_lengths %>% filter(mgt_area == "SSEO", year == 2018)

#Import estimate transect length for bad and good sections for survey
#Remove out bad sections and summarize good length estimates for a dive
sseo_transects <- read_csv("data/survey/sseo/2018_sseo_smoothed_transect_lengths.csv")

transect_summary <- sseo_transects %>% group_by(Dive) %>% 
  summarise(total_length_m = sum(Shape_Length, na.rm = TRUE))

#Note Dive 8 was a bad dive so exclude and Dive 21 saw no YE

transect_summary

