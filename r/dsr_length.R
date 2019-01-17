#DSR Length Frequencies historgrams by management area#
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
ye_length <- read_excel("data/fishery/dsr port sampling.xlsx")

ye_length$G_MANAGEMENT_AREA_CODE <- factor(ye_length$G_MANAGEMENT_AREA_CODE, levels = c("EYKT", "NSEO", "CSEO", "SSEO"))


ye_length_summary <- ye_length %>% filter(YEAR >= 1992, LENGTH_MILLIMETERS != "NA") %>% 
  mutate(length_cm = LENGTH_MILLIMETERS / 10) %>% 
  group_by(YEAR, G_MANAGEMENT_AREA_CODE, length_cm) %>% count(length_cm)

summary_cseo <- ye_length_summary %>% filter(G_MANAGEMENT_AREA_CODE == "CSEO")

  
tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/ye fishery length comps_cseo.tiff",
     width = 6, height = 5, units = "in", res = 600, compression = "lzw")


ggplot(summary_cseo, aes(YEAR, length_cm, size = n)) + geom_point(shape = 21, stroke = 0.5) + 
  ylab("Length (cm)") + xlab("Year") + 
  theme(legend.position = "none") + 
  scale_size(range = c(0, 8)) +
  scale_x_continuous(breaks = pretty(ye_length_summary$YEAR, n = 5)) + 
  scale_y_continuous(breaks = seq(0, 100, 10), limits = c(30, 80))


dev.off()

summary_eykt <- ye_length_summary %>% filter(G_MANAGEMENT_AREA_CODE == "EYKT")


tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/ye fishery length comps_eykt.tiff",
     width = 6, height = 5, units = "in", res = 600, compression = "lzw")


ggplot(summary_eykt, aes(YEAR, length_cm, size = n)) + geom_point(shape = 21, stroke = 0.5) + 
  ylab("Length (cm)") + xlab("Year") + 
  theme(legend.position = "none") + 
  scale_size(range = c(0, 8)) +
  scale_x_continuous(breaks = pretty(ye_length_summary$YEAR, n = 5)) + 
  scale_y_continuous(breaks = seq(0, 100, 10), limits = c(30, 80))


dev.off()

summary_nseo <- ye_length_summary %>% filter(G_MANAGEMENT_AREA_CODE == "NSEO")


tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/ye fishery length comps_nseo.tiff",
     width = 6, height = 5, units = "in", res = 600, compression = "lzw")


ggplot(summary_nseo, aes(YEAR, length_cm, size = n)) + geom_point(shape = 21, stroke = 0.5) + 
  ylab("Length (cm)") + xlab("Year") + 
  theme(legend.position = "none") + 
  scale_size(range = c(0, 8)) +
  scale_x_continuous(breaks = pretty(ye_length_summary$YEAR, n = 5)) + 
  scale_y_continuous(breaks = seq(0, 100, 10), limits = c(30, 80))


dev.off()

summary_sseo <- ye_length_summary %>% filter(G_MANAGEMENT_AREA_CODE == "SSEO")


tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/ye fishery length comps_sseo.tiff",
     width = 6, height = 5, units = "in", res = 600, compression = "lzw")


ggplot(summary_sseo, aes(YEAR, length_cm, size = n)) + geom_point(shape = 21, stroke = 0.5) + 
  ylab("Length (cm)") + xlab("Year") + 
  theme(legend.position = "none") + 
  scale_size(range = c(0, 8)) +
  scale_x_continuous(breaks = pretty(ye_length_summary$YEAR, n = 5)) + 
  scale_y_continuous(breaks = seq(0, 100, 10), limits = c(30, 80))


dev.off()


#YE ROV lengths vs fishery lengths#
#Survey Data filtered for YE species code = 145 and excludes RMS greater than 10
#and a horizontal angle greater than 30

survey <- read_excel("data/survey/ye_lengths_ROV_survey.xlsx", sheet = 2)

fishery <-read_excel("data/fishery/dsr port sampling.xlsx")


ye_survey <- survey %>% mutate(length_cm = length_mm / 10)  %>%
  select(year, mgt_area, length_cm) 

ye_survey$data_type <-"survey"

ye_survey$mgt_area<- factor(ye_survey$mgt_area, levels = c("EYKT", "NSEO", "CSEO", "SSEO"))

ye_survey %>% group_by(mgt_area)%>% 
  summarise(n(), min(length_cm), max(length_cm), 
            avg_length = mean(length_cm), sd = sd(length_cm))

#survey historgram by mgt area
ggplot(ye_survey, aes(length_cm, fill = mgt_area, colour = mgt_area)) +
  geom_histogram(binwidth = 1, position = "identity", alpha = 0.4, lwd = 0.8)


#survey density by mgt area
tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/survey length dist.tiff",
     width = 6, height = 5, units = "in", res = 600, compression = "lzw")


p1<- ggplot(ye_survey, aes(length_cm, fill = mgt_area, colour = mgt_area)) + 
  geom_density(alpha = 0.4, lwd = 0.8, adjust = 1.0) + xlim(30, 90) + ylim(0, 0.07) +
  ggtitle("Yelloweye ROV Survey") +
  scale_fill_manual(values= cbPalette) + scale_color_manual(values = cbPalette) +
  xlab("Length (cm)") + ylab("Density") + 
  annotate("text", x = 30, y = 0.06, label = "a)", fontface = "bold", size = 5) +
  theme(legend.title=element_blank(), legend.position = c(0.75, 0.75))

dev.off()

ye_fishery <- fishery %>% filter(YEAR >= 2012, !is.na(LENGTH_MILLIMETERS), !is.na(WEIGHT_KILOGRAMS)) %>% 
  mutate(length_cm = LENGTH_MILLIMETERS / 10) %>%
  select(YEAR, G_MANAGEMENT_AREA_CODE, length_cm, WEIGHT_KILOGRAMS) %>%
  rename(year = YEAR, mgt_area = G_MANAGEMENT_AREA_CODE, weight_kg = WEIGHT_KILOGRAMS)

ye_fishery$data_type <-"fishery"

ye_fishery$mgt_area<- factor(ye_fishery$mgt_area, levels = c("EYKT", "NSEO", "CSEO", "SSEO"))

ye_fishery %>% group_by(mgt_area)%>% 
  summarise(n(), min(length_cm), max(length_cm), 
            avg_length = mean(length_cm), sd = sd(length_cm))

#fishery density by mgt area
tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/fishery length dist.tiff",
     width = 6, height = 5, units = "in", res = 600, compression = "lzw")

p2 <- ggplot(ye_fishery, aes(length_cm, fill = mgt_area, colour = mgt_area)) + 
  geom_density(alpha = 0.4, lwd = 0.8, adjust = 1.0) + xlim(30, 90) + ylim(0, 0.07) +
  ggtitle("Yelloweye Fishery (Directed & Halibut IFQ)") +
scale_fill_manual(values= cbPalette) + scale_color_manual(values = cbPalette) +
  xlab("Length (cm)") + ylab("Density") +
  annotate("text", x = 30, y = 0.06, label = "b)", fontface = "bold", size = 5) +
  theme(legend.title=element_blank(), legend.position = c(0.75, 0.75))

dev.off()

#Combine Survey and Fishery data
length_comps <-bind_rows(ye_survey, ye_fishery)


#Normalized distribution for histogram
ggplot(length_comps, aes(length_cm, fill = data_type, colour = data_type)) + 
  geom_histogram(aes(y = ..density..), binwidth = 2, position = "identity", alpha = 0.4, lwd = 0.8) +
  scale_fill_manual(values= cbPalette) + scale_color_manual(values = cbPalette)

#Normalized distribution using density plot
tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/fishery_survey length dist.tiff",
     width = 6, height = 5, units = "in", res = 600, compression = "lzw")

p3 <- ggplot(length_comps, aes(length_cm, fill = data_type, colour = data_type)) + 
  geom_density(alpha = 0.4, lwd = 0.8, adjust = 1.0) + xlim(30, 90) + ylim(0, 0.07) +
  scale_fill_manual(values= cbPalette) + scale_color_manual(values = cbPalette) +
  xlab("Length (cm)") + ylab("Density") +
  annotate("text", x = 30, y = 0.06, label = "c)", fontface = "bold", size = 5) +
theme(legend.title=element_blank(), legend.position = c(0.75, 0.75))

dev.off()

#YE fishery L-W relationship

#L vs W RELATIONSHIP#
#exploratory plots
#scatter plot
ggplot(ye_fishery, aes(length_cm, weight_kg)) + geom_point() +
  stat_smooth(method = "loess", lwd = 2, se = FALSE) 

#boxplot
ggplot(ye_fishery, aes(length_cm, weight_kg, group = length_cm)) + geom_boxplot()


#LW Model log transformed
lw_ye <- lm(log(weight_kg) ~ log(length_cm), data = ye_fishery)

summary(lw_ye)


tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/ye_lw.tiff",
     width = 6, height = 5, units = "in", res = 600, compression = "lzw")

p4 <- ggplot(ye_fishery, aes(x = log(length_cm), y = log(weight_kg))) + 
  geom_point(size = 2) + ylab("log Weight (kg)") + xlab("log Length (cm)") +
  stat_smooth(method = lm, lwd = 2) +
  annotate("text", x = 3.4, y = 2, label = "d)", fontface = "bold", size = 5) +
  annotate("text", x = 4.0, y = -0.5, 
           label = "italic(log(W) == log(-10.81) + 2.98*log(L))", parse = T, size = 5) +
  annotate("text", x = 4.0, y = -0.75, label = "italic(R^2 == 0.9286)", parse = T, size = 5)


dev.off()


#Put parameter estimates into equation and back transform to estimate fish weight during survey
a <- exp(-10.812017)
b <- c(2.984601)

ye_survey_weight <- ye_survey %>% mutate(weight_kg = a * length_cm ^ b)

ye_survey_weight

#Survey weight density by mgt area
jpeg(filename = "figures/ye_survey weights.jpg",
     width = 6, height = 5, units = "in", res = 600)

p6 <- ggplot(ye_survey_weight, aes(weight_kg, fill = mgt_area, colour = mgt_area)) + 
  geom_density(alpha = 0.4, lwd = 0.8, adjust = 1) + 
  scale_fill_manual(values= cbPalette) + scale_color_manual(values = cbPalette) +
  xlab("Weight (kg)") + ylab("Density") + ggtitle("Yelloweye ROV Survey") +
  xlim(0, 15) + ylim(0, 0.4) +
  annotate("text", x = 0, y = 0.38, label = "e)", fontface = "bold", size = 5) +
  theme(legend.title=element_blank(), legend.position = c(0.75, 0.75))

dev.off()

#Fishery weight density by mgt area
jpeg(filename = "figures/ye_fishery weights.jpg",
     width = 6, height = 5, units = "in", res = 600)

p7 <- ggplot(ye_fishery, aes(weight_kg, fill = mgt_area, colour = mgt_area)) + 
  geom_density(alpha = 0.4, lwd = 0.8, adjust = 1) + xlim(0, 15) + ylim(0, 0.4) +
  scale_fill_manual(values= cbPalette) + scale_color_manual(values = cbPalette) +
  xlab("Weight (kg)") + ylab("Density") + ggtitle("Yelloweye Fishery (Directed & Halibut IFQ)") +
  annotate("text", x = 0, y = 0.38, label = "f)", fontface = "bold", size = 5) + 
  theme(legend.title=element_blank(), legend.position = c(0.75, 0.75))

dev.off()

#Combine survey and fishery weights
weight_comps <- bind_rows(ye_survey_weight, ye_fishery)

jpeg(filename = "figures/fishery_survey_weights.jpg",
     width = 6, height = 5, units = "in", res = 600)

p5 <- ggplot(weight_comps, aes(weight_kg, fill = data_type, colour = data_type)) + 
  geom_density(alpha = 0.4, lwd = 0.8, adjust = 1) +
  scale_fill_manual(values= cbPalette) + scale_color_manual(values = cbPalette) +
  xlab("Weight (kg)") + ylab("Density") + xlim(0, 15) + ylim(0, 0.4) +
  annotate("text", x = 0, y = 0.38, label = "g)", fontface = "bold", size = 5) +
  theme(legend.title=element_blank(), legend.position = c(0.75, 0.75))

dev.off()

#Multiplot of YE fishery vs survey lengths
tiff(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/ye_lw comparisons.tiff",
     width = 13, height = 15, units = "in", res = 600, compression = "lzw")

grid.arrange(p1, p6, p2, p7, p3, p5, p4, ncol = 2)

dev.off()

