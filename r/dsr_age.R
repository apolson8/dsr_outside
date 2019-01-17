#DSR age compositions by management area#
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
ye_age <- read_excel("data/fishery/dsr port sampling.xlsx")

ye_age$G_MANAGEMENT_AREA_CODE <- factor(ye_length$G_MANAGEMENT_AREA_CODE, levels = c("EYKT", "NSEO", "CSEO", "SSEO"))

ye_age_summary <- ye_age %>% filter(AGE != "NA", 
                                  AGE_READABILITY %in% c("Very Sure", "Comfortably Sure", "Fairly Sure"),
                                  YEAR >= 1992) %>% 
  group_by(YEAR, G_MANAGEMENT_AREA_CODE) %>% count(AGE)


ye_age_summary_eykt <- ye_age_summary %>% filter(G_MANAGEMENT_AREA_CODE == "EYKT")

tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/ye fishery age comps_eykt.tiff",
     width = 6, height = 5, units = "in", res = 600, compression = "lzw")

ggplot(ye_age_summary_eykt, aes(YEAR, AGE, size = n)) + geom_point(shape = 21, stroke = 0.5) + 
  ylab("Observed Age") + xlab("Year") +
  theme(legend.position = "none") + 
  scale_size(range = c(0, 8)) +
  scale_x_continuous(breaks = pretty(ye_length_summary$YEAR, n = 5)) + 
  scale_y_continuous(breaks = seq(10, 90, 10), limits = c(10, 90))

dev.off()

ye_age_summary_cseo <- ye_age_summary %>% filter(G_MANAGEMENT_AREA_CODE == "CSEO")

tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/ye fishery age comps_cseo.tiff",
     width = 6, height = 5, units = "in", res = 600, compression = "lzw")

ggplot(ye_age_summary_cseo, aes(YEAR, AGE, size = n)) + geom_point(shape = 21, stroke = 0.5) + 
  ylab("Observed Age") + xlab("Year") +
  theme(legend.position = "none") + 
  scale_size(range = c(0, 8)) +
  scale_x_continuous(breaks = pretty(ye_length_summary$YEAR, n = 5)) + 
  scale_y_continuous(breaks = seq(10, 90, 10), limits = c(10, 90))

dev.off()

ye_age_summary_nseo <- ye_age_summary %>% filter(G_MANAGEMENT_AREA_CODE == "NSEO")

tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/ye fishery age comps_nseo.tiff",
     width = 6, height = 5, units = "in", res = 600, compression = "lzw")

ggplot(ye_age_summary_nseo, aes(YEAR, AGE, size = n)) + geom_point(shape = 21, stroke = 0.5) + 
  ylab("Observed Age") + xlab("Year") +
  theme(legend.position = "none") + 
  scale_size(range = c(0, 8)) +
  scale_x_continuous(breaks = pretty(ye_length_summary$YEAR, n = 5)) + 
  scale_y_continuous(breaks = seq(10, 90, 10), limits = c(10, 90))

dev.off()

ye_age_summary_sseo <- ye_age_summary %>% filter(G_MANAGEMENT_AREA_CODE == "SSEO")

tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/ye fishery age comps_sseo.tiff",
     width = 6, height = 5, units = "in", res = 600, compression = "lzw")

ggplot(ye_age_summary_sseo, aes(YEAR, AGE, size = n)) + geom_point(shape = 21, stroke = 0.5) + 
  ylab("Observed Age") + xlab("Year") +
  theme(legend.position = "none") + 
  scale_size(range = c(0, 8)) +
  scale_x_continuous(breaks = pretty(ye_length_summary$YEAR, n = 5)) + 
  scale_y_continuous(breaks = seq(10, 90, 10), limits = c(10, 90))

dev.off()