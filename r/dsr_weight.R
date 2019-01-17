#DSR weights by management area#
library(dplyr)
library(ggplot2)
library(readxl)
library(tidyr)
library(ggthemes)
library(gridExtra)
library(extrafont)

##THEMES FOR GRAPHS##
loadfonts(device="win")
windowsFonts(Times=windowsFont("TT Times New Roman"))
theme_set(theme_bw(base_size=14,base_family='Times New Roman')
          +theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()))

#COLOR BLIND PALETTE#
cbPalette <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")

#Import DSR Port Sampling data#
#Samples are Yelloweye rockfish only#
ye_weight <- read_excel("data/fishery/dsr port sampling.xlsx")

ye_weight$G_MANAGEMENT_AREA_CODE <- factor(ye_weight$G_MANAGEMENT_AREA_CODE, levels = c("EYKT", "NSEO", "CSEO", "SSEO"))

ye_weight_summary <- ye_weight %>% filter(YEAR >= 2015, WEIGHT_KILOGRAMS != "NA") %>% 
  group_by(YEAR, G_MANAGEMENT_AREA_CODE) %>%
  summarise(n = n(), avg_kg = mean(WEIGHT_KILOGRAMS), sd_kg = sd(WEIGHT_KILOGRAMS), se = sd_kg / sqrt(n)) 

ye_weight_summary

ye_weight_summary2 <- ye_weight_summary %>% filter(YEAR >= 2016) %>% 
  select(YEAR, G_MANAGEMENT_AREA_CODE, avg_kg) %>%
  spread(YEAR, avg_kg)

knitr::kable(ye_weight_summary2)

ye_weight_sseo <-ye_weight %>% filter (YEAR >= 2013 & YEAR != 2018, WEIGHT_KILOGRAMS != "NA", G_MANAGEMENT_AREA_CODE == "SSEO") %>%
  summarise(n = n(), avg_kg = mean(WEIGHT_KILOGRAMS), sd_kg = sd(WEIGHT_KILOGRAMS), se = sd_kg / sqrt(n)) 
  
ye_weight_sseo

  
  

