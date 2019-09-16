#DSR HARVEST FROM DIRECTED AND INCIDENTAL CATCH#
#DATA IMPORTED FROM ALEX REPORTS WITH DSR SPECIES SELECTED#
#DSR SPECIES: yelloweye, copper, quillback, China, rosethorn, tiger, and canary#

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


#IMPORT DATA#
dsr <- read_excel("data/fishery/dsr fishticket.xlsx")

dsr$G_MANAGEMENT_AREA_CODE <- factor(dsr$G_MANAGEMENT_AREA_CODE, levels = c("EYKT", "NSEO", "CSEO", "SSEO"))

dsr_salmon <-read_excel("data/fishery/dsr_salmon fishticket.xlsx")

#DSR Directed Fishery Harvest (Y CFEC Permit)#
dsr_direct <- dsr %>% filter(YEAR >= 2014, G_CFEC_FISHERY_GROUP_CODE == "Y") %>%
  group_by(YEAR) %>% mutate(tons = ROUND_POUNDS *0.000453592) %>%
  summarise(total_tons = sum(tons))

dsr_direct


#DSR Directed Fishery Harvest by Mgt Area#
harvest_area <- dsr %>% filter(YEAR >=1992, G_CFEC_FISHERY_GROUP_CODE == "Y") %>%
  group_by(YEAR, G_MANAGEMENT_AREA_CODE) %>% 
  mutate(tons = ROUND_POUNDS * 0.000453592) %>% summarise(total_tons = sum(tons))

harvest_area


jpeg(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/dsr directed harvest mgt_area.jpg",
     width = 7, height = 5, units = "in", res = 600)


ggplot(harvest_area, aes(YEAR, total_tons, fill = G_MANAGEMENT_AREA_CODE)) + 
  geom_bar(stat = "identity") + ylab("Directed Commercial Fishery Catch (t)") + 
  scale_fill_manual(values= cbPalette) + scale_color_manual(values = cbPalette) +
  xlab("Year") + ylim(0,610) + scale_x_continuous(breaks = pretty(harvest_area$YEAR, n = 5)) +
  theme(legend.title=element_blank(), legend.position = c(0.75, 0.75))

dev.off()


#DSR Harvest during IPHC surveys (Harvest Code = 43 Test fishery)#
dsr_survey <- dsr %>% filter(YEAR >= 2014, HARVEST_CODE == 43) %>%
  group_by(YEAR) %>% mutate(tons = ROUND_POUNDS *0.000453592) %>%
  summarise(total_tons = sum(tons))

dsr_survey

#DSR Incidental Harvest#
#Need to join harvest from DSR and salmon fishtickets#
#DSR bycatch began being assigned groundfish stat-areas in 2015#
dsr_ind <- dsr %>% 
  filter(YEAR >= 2015, G_CFEC_FISHERY_GROUP_CODE != "Y", HARVEST_CODE != 43) %>%
  group_by(YEAR) %>% mutate(tons = ROUND_POUNDS *0.000453592) %>%
  summarise(total_tons = sum(tons))

dsr_ind

dsr_ind_salmon <-dsr_salmon %>% filter(YEAR >= 2015) %>% group_by(YEAR) %>%
  mutate(tons = ROUND_POUNDS * 0.000453592) %>%
  summarise(total_tons = sum(tons))

dsr_ind_salmon

#Join incidental catch summary tables#
dsr_incidental <- left_join(dsr_ind, dsr_ind_salmon, by = "YEAR") %>% 
  mutate(total_tons = total_tons.x + total_tons.y) %>% group_by(YEAR) %>%
  select(YEAR, total_tons)

dsr_incidental

#Commercial landings by year and DSR species#
#Excludes Testfish harvest (code 43)#
dsr_harvest <- dsr %>% filter(YEAR >= 2015, HARVEST_CODE != 43) %>% 
  group_by(YEAR, G_MANAGEMENT_AREA_CODE, SPECIES_CODE, SPECIES) %>%
  select(YEAR, G_MANAGEMENT_AREA_CODE, SPECIES_CODE, SPECIES, ROUND_POUNDS)

dsr_harvest

dsr_salmon_harvest <- dsr_salmon %>% filter(YEAR >=2015) %>% group_by(YEAR, SPECIES_CODE, SPECIES) %>%
  select(YEAR, SPECIES_CODE, SPECIES, ROUND_POUNDS)

dsr_salmon_harvest            

total_harv <-semi_join(dsr_harvest, dsr_salmon_harvest, by= "YEAR", "SPECiES") %>% 
  group_by(YEAR, SPECIES, SPECIES_CODE) %>% mutate(tons = ROUND_POUNDS * 0.000453592) %>%
  summarise(total_tons = sum(tons))

View(total_harv %>% group_by(YEAR) %>% summarise(sum(total_tons)))


total_harv_table <- total_harv %>% spread(YEAR, total_tons)

knitr::kable(total_harv_table)  

#DSR Incidental Harvest by Mgt. Area#
#Need to use OceanAK report for salmon harvest since ALEX report does not work#
dsr_ind_area <- dsr %>% 
  filter(YEAR >= 1992, G_CFEC_FISHERY_GROUP_CODE != "Y", HARVEST_CODE != 43) %>%
  group_by(YEAR, G_MANAGEMENT_AREA_CODE) %>% mutate(tons = ROUND_POUNDS *0.000453592) %>%
  summarise(total_tons = sum(tons))

dsr_ind_area

dsr_salmon_area <- read_excel("data/fishery/dsr_salmon_grndfish_mgt_area.xlsx")

plyr::rename(dsr_salmon_area, replace = c("Batch Year"= "YEAR", "G Mgt Area District" = "G_MANAGEMENT_AREA_CODE",
                                          "Whole Weight (sum)" = "ROUND_POUNDS")) -> dsr_salmon_area

mgt_areas <- c("EYKT", "NSEO", "CSEO", "SSEO")

salmon_summary <- dsr_salmon_area %>% 
  filter(G_MANAGEMENT_AREA_CODE %in% mgt_areas) %>%
  group_by(YEAR, G_MANAGEMENT_AREA_CODE) %>% 
  mutate(tons = ROUND_POUNDS * 0.000453592) %>% summarise(total_tons = sum(tons))

ind_harv_area <- union(dsr_ind_area, salmon_summary, by = "YEAR", "G_MANAGEMENT_AREA_CODE") %>%
  group_by(YEAR, G_MANAGEMENT_AREA_CODE) %>% summarise(sum(total_tons))

ind_harv_area$G_MANAGEMENT_AREA_CODE <- factor(ind_harv_area$G_MANAGEMENT_AREA_CODE, levels = c("EYKT", "NSEO", "CSEO", "SSEO"))

ind_harv_area

ind_harv_table <- ind_harv_area %>% spread(YEAR, `sum(total_tons)`)

knitr::kable(ind_harv_table)

jpeg(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/dsr incidental harvest mgt_area.jpg",
     width = 7, height = 5, units = "in", res = 600)


ggplot(ind_harv_area, aes(YEAR, `sum(total_tons)`, fill = G_MANAGEMENT_AREA_CODE)) + 
  geom_bar(stat = "identity") + ylab("Incidental Commercial Fishery Catch (t)") + 
  scale_fill_manual(values= cbPalette) + scale_color_manual(values = cbPalette) +
  xlab("Year") + ylim(0,610) + scale_x_continuous(breaks = pretty(ind_harv_area$YEAR, n = 5)) +
  theme(legend.title=element_blank(), legend.position = c(0.75, 0.75))

dev.off()

##DSR HARVEST BY SECTOR##
DSR_HRVST_SECTOR<-read_excel("data/fishery/YE summary tables SEO.xlsx", sheet = 2)

DSR_HRVSTsum<-DSR_HRVST_SECTOR %>% filter(Year < 2018) %>% select(Year, Catch_Type, Catch_mt)


jpeg(filename = "figures/dsr harvest by catch type.jpg",
     width = 7, height = 5, units = "in", res = 600)

ggplot(DSR_HRVSTsum, aes(x=Year,y=Catch_mt, fill=Catch_Type)) + geom_bar(stat="identity") + 
  ylab("Harvest (t)") + ylim(0,610) + scale_x_continuous(breaks = pretty(DSR_HRVSTsum$Year, n = 5)) +
  scale_fill_grey() +
  theme(legend.position=c(0.75,0.78), legend.title = element_blank()) 

dev.off()


View(DSR_HRVSTsum)

##DSR HARVEST (OFL, ABC, TAC, TOTAL)
DSR_ABC<-DSR_HRVST_SECTOR %>% select(Year, Catch_Quota, Quota_mt) %>% filter(Quota_mt != 'NA')

DSR_ABC$Catch_Quota<-factor(DSR_ABC$Catch_Quota,
                            levels=c("OFL", "ABC", "TAC", "Total Catch"))

jpeg(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/dsr catch quota.jpg",
     width = 7, height = 5, units = "in", res = 600)

ggplot(data=DSR_ABC, aes(x=Year, y=Quota_mt, colour=Catch_Quota)) +
  geom_point(size=3) + geom_line(size=1) + ylab("Catch Guidelines & Total Catch (t)") + 
  scale_fill_manual(values= cbPalette) + scale_color_manual(values = cbPalette) +
  scale_x_continuous(breaks = pretty(DSR_ABC$Year , n =5)) +
  theme(legend.position=c(0.75,0.80)) 

dev.off()


##YELLOWEYE BIOMASS ESTIMATE##
#lower 90% Confidence interval#
YE_BIO<-read_excel("data/fishery/YE summary tables SEO.xlsx", sheet = 3)


jpeg(filename = "H:/Groundfish/ROCKFISH/DSR/dsr_safe/figures/ye biomass estimates.jpg",
     width = 8, height = 7, units = "in", res = 600)

ggplot(data=YE_BIO, aes(x=Year)) + geom_line(aes(y=Biomass_mt), size=1.5, colour="black") + 
  geom_line(aes(y=LCI_90), linetype=2, size=1.5, colour="black") +
  geom_point(aes(y=Biomass_mt),size=4, colour="black") + ylab("Yelloweye Rockfish Biomass Estimate (t)") +
  scale_y_continuous(labels = scales::comma) +
  scale_x_continuous(breaks = pretty(YE_BIO$Year , n =5))

dev.off()

