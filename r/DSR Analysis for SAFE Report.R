#Yelloweye Info for SAFE REPORT#

#IMPORT EXCEL FILES FOR USE#
library(readxl)
library(tidyverse)
library(ggthemes)
library(gridExtra)
library(extrafont)


##THEMES FOR GRAPHS##
loadfonts(device="win")
windowsFonts(Times=windowsFont("TT Times New Roman"))
theme_set(theme_bw(base_size=14,base_family='Times New Roman')
          +theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()))


#PORT SAMPLING DATA#

#AVG WEIGHTS BY YEAR AND MANAGMENT AREA#
YE_Weight<-read_excel(
  "M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2016 for 2017 SAFE/Data/2013-2016 Port Sampling YE avg weights.xlsx")

YE_Weight

tbl_df(YE_Weight)

YE_Weight_SUM<-YE_Weight %>% group_by(YEAR, G_MANAGEMENT_AREA_CODE)%>% 
  summarise(n=n(), avg=mean(WEIGHT_KILOGRAMS), sd(WEIGHT_KILOGRAMS))

YE_Weight_SUM

ggplot(data=YE_Weight_SUM, aes(YEAR, avg))+geom_point(aes(colour=G_MANAGEMENT_AREA_CODE)) 


##YE ROCKFISH DENSITY ESTIMATES PER KM2##
#TAKEN FROM SAFE REPORT TABLE 3#

YE_DensitySUM<-read_excel("M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2016 for 2017 SAFE/Data/YE summary tables SEO.xlsx",
                          sheet=1)

YE_DensitySUM$Area<-factor(YE_DensitySUM$Area, levels=c("EYKT", "NSEO", "CSEO", "SSEO"))

YE_DensitySUM

#DEFINE CONFIDENCE INTERVALS#
limits<-aes(ymax=Upper_CI, ymin=Lower_CI)


jpeg(filename = "M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/Presentation/Figures/YE_Density.jpg",
     width = 6, height = 5.2, units = "in", res = 600)

ggplot(data=YE_DensitySUM, aes(y=YE_Density, x=Year)) +  geom_errorbar(limits) +
  geom_point(size=4, colour="black") + facet_wrap(~ Area) + 
  scale_x_continuous(breaks=seq(1990, 2017, 5)) +
  labs(y= expression(paste("Density of yelloweye rockfish per  ", km^2))) + ylim(0, 5800) 


dev.off()
  

##DSR HARVEST BY SECTOR##
DSR_HRVST_SECTOR<-read_excel("M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/YE summary tables SEO.xlsx",
                             sheet=2)

DSR_HRVSTsum<-DSR_HRVST_SECTOR %>% select(Year, Catch_Type, Catch_mt)

jpeg(filename = "M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/Presentation/Figures/DSR_Catch_Sector.jpg",
     width = 6, height = 5.2, units = "in", res = 600)


ggplot(DSR_HRVSTsum, aes(x=Year,y=Catch_mt, fill=Catch_Type)) + geom_bar(stat="identity") + 
  ylab("Catch (t)") + ylim(0,610) + scale_x_continuous(breaks = pretty(DSR_HRVSTsum$Year, n = 5)) +
  theme(legend.position=c(0.75,0.78))

dev.off()


View(DSR_HRVSTsum)

##DSR HARVEST (OFL, ABC, TAC, TOTAL)
DSR_ABC<-DSR_HRVST_SECTOR %>% select(Year, Catch_Quota, Quota_mt) %>% filter(Quota_mt != 'NA')

DSR_ABC$Catch_Quota<-factor(DSR_ABC$Catch_Quota,
                              levels=c("OFL", "ABC", "TAC", "Total Catch"))

jpeg(filename = "M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/Presentation/Figures/DSR Catch Guidelines.jpg",
     width = 6, height = 5.2, units = "in", res = 600)

ggplot(data=DSR_ABC, aes(x=Year, y=Quota_mt, colour=Catch_Quota)) +
  geom_point(size=3) + geom_line(size=1) + ylab("Catch Guidelines & Total Catch (t)") + 
  scale_x_continuous(breaks = pretty(DSR_ABC$Year , n =5)) +
  theme(legend.position=c(0.75,0.80))
    
dev.off()



##DSR HARVEST BY MANAGEMENT AREA##
#pull updated data from OceanAK YE report#
DSR_MGNT<-read_excel("M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2016 for 2017 SAFE/Data/YE summary tables SEO.xlsx",
                               sheet=3)
DSR_MGNT


DSR_DIRECTED<-DSR_MGNT %>% select(Batch_Year, Permit_Fishery, Mgt_Area_District, Metric_Tons) %>%
  filter(Permit_Fishery %in% c("DSR Directed fishery")) %>% group_by(Batch_Year, Mgt_Area_District) %>%
  summarise(Total=sum(Metric_Tons))

DSR_DIRECTED

DSR_DIRECTED$Mgt_Area_District<-factor(DSR_DIRECTED$Mgt_Area_District, levels=c("EYKT", "NSEO",
                                                                                "CSEO", "SSEO"))

plot3<-ggplot(data=DSR_DIRECTED, aes(x=Batch_Year, y=Total, fill=Mgt_Area_District)) + 
  geom_bar(stat="identity") + ylab("Directed Commercial Fishery Catch (mt)") + 
  xlab("Year") + ylim(0,610) + theme(legend.title=element_blank())

plot3


##DSR INDIRECT HARVEST BY MANAGEMENT AREA#
#pre-filtered data in excel to exclude directed and halibut test fishery bycatch#
DSR_MGNT2<-read_excel("M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2016 for 2017 SAFE/Data/YE summary tables SEO.xlsx",
                                   sheet=4)
DSR_IND<-DSR_MGNT2 %>% group_by(Batch_Year, Mgt_Area_District) %>% 
  summarise(Total=sum(Metric_Tons))

DSR_IND$Mgt_Area_District<-factor(DSR_IND$Mgt_Area_District, levels=c("EYKT", "NSEO",
                                                                      "CSEO", "SSEO"))

plot4<-ggplot(data=DSR_IND, aes(y=Total, x=Batch_Year, fill=Mgt_Area_District)) +
  geom_bar(stat="identity") + ylab("Total Incidental Cartch (mt)") + xlab("Year") +
  ylim(0,610) + theme(legend.title=element_blank())

plot4

##YELLOWEYE BIOMASS ESTIMATE##
#lower 90% Confidence interval#
YE_BIO<-read_excel("M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/YE summary tables SEO.xlsx",
                              sheet=5)

jpeg(filename = "M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/Presentation/Figures/YE_Biomass.jpg",
     width = 6, height = 5.2, units = "in", res = 600)


ggplot(data=YE_BIO, aes(x=Year)) + geom_line(aes(y=Biomass_mt), size=1, colour="black") + 
  geom_line(aes(y=LCI_90), linetype=4, size=1, colour="black") +
  geom_point(aes(y=Biomass_mt),size=3, colour="black") + ylab("Yelloweye Rockfish Biomass Estimate (t)") +
  scale_x_continuous(breaks = pretty(YE_BIO$Year , n =5))

dev.off()

##DSR Species Commercial Harvest by Year and Species##
#Test Fishery Harvest removed in OceanAK#
dat1<-read_excel("M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/DSR Biomass Calculations from ROV/data/DSR Commercial Catch by Year and Species.xlsx", sheet = 1)

dat1_sum<-dat1 %>% group_by(Year, Species) %>% summarise(Total_mt = sum(Weight_lbs * 0.000453592))

#Adding in DSR bycatch in salmon troll fishery#
dat2<-read_excel("M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/DSR Biomass Calculations from ROV/data/2015-2017 Groundfish bycatch on Salmon Troll fishery.xlsx", sheet = 1)

dat2_sum<-dat2 %>% group_by(Year, Species) %>% summarise(Total_mt = sum(Weight_lbs * 0.000453592))

DSR_Harvest<-left_join(dat1_sum, dat2_sum, by = c("Year", "Species")) %>% group_by(Year, Species) %>%
  replace_na(list(Total_mt.y = 0)) %>% transmute(Total_mt = Total_mt.x + Total_mt.y)
  

DSR_Harvest$Total_mt<-round(DSR_Harvest$Total_mt, 4)

View(DSR_Harvest)

write.csv(DSR_Harvest, "M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/DSR Biomass Calculations from ROV/data/DSR_Harvest_summary.csv")

#Directed DSR Fishery Bycatch Species#
#Excludes PU harvest#
dat3<-read_excel("M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/DSR Biomass Calculations from ROV/data/2010-2017 Directed DSR Bycatch Species.xlsx", sheet = 1)
  
dat3  
  
dat4<-dat3 %>% group_by(Year, Species) %>% summarise(Total_mt = sum(Weight_lbs * 0.000453592))  
  
dat4$Total_mt<-round(dat4$Total_mt, 2)

dat4

#DSR Summary Table for Directed, Incidental, and Research Harvest#
dat5<-read_excel("M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/DSR Biomass Calculations from ROV/data/1992-2017 DSR harvest (directed, incidental, and research).xlsx", sheet = 1)

dat5

dat5$Mgt_Area<-factor(dat5$Mgt_Area, levels=c("EYKT", "NSEO","CSEO", "SSEO"))

dat5$Mgmt_Program_Name<-as.character(as.logical(dat5$Mgmt_Program_Name))


Research<-dat5 %>% group_by(Year) %>% filter(Mgmt_Program_Name == "Test Fishery") %>%
  summarise(Weight_mt = sum(Weight_lbs * 0.000453592))

Research

target<-c("Y06A", "Y61A")

Direct<-dat5 %>% group_by(Year, Mgt_Area) %>% filter(CFEC_Fishery_Code %in% target) %>%
  summarise(Weight_mt = sum(Weight_lbs * 0.000453592))

Direct$Weight_mt<-round(Direct$Weight_mt, 2)

Direct

jpeg(filename = "M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/Presentation/Figures/DSR Direct Harvest.jpg",
     width = 6, height = 5.2, units = "in", res = 600)

ggplot(data=Direct, aes(x=Year, y=Weight_mt, fill=Mgt_Area)) + 
  geom_bar(stat="identity") + ylab("Directed Commercial Fishery Catch (t)") + 
  xlab("Year") + ylim(0,610) + scale_x_continuous(breaks = pretty(Direct$Year , n =5)) +
  (theme(legend.title=element_blank(), legend.position=c(0.75,0.75)))


dev.off()


dat6<-read_excel("M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/DSR Biomass Calculations from ROV/data/1992-2017 DSR Incidental harvest.xlsx", sheet = 1)

dat6$Mgt_Area<-factor(dat6$Mgt_Area, levels=c("EYKT", "NSEO","CSEO", "SSEO"))


Incidental<-dat6 %>% group_by(Year, Mgt_Area) %>% 
    summarise(Weight_mt = sum(Weight_lbs * 0.000453592))

#Add-in Salmon incidental catch#
dat2_sum<-dat2 %>% group_by(Year, Mgt_Area) %>% summarise(Total_mt = sum(Weight_lbs * 0.000453592))

Incidental_sum<-left_join(Incidental, dat2_sum, by = c("Year", "Mgt_Area")) %>% group_by(Year, Mgt_Area) %>%
  replace_na(list(Total_mt = 0)) %>% transmute(Total_mt = Weight_mt + Total_mt)


Incidental_sum$Total_mt<-round(Incidental_sum$Total_mt, 4)

Incidental_sum$Mgt_Area<-factor(Incidental_sum$Mgt_Area, levels = c("EYKT", "NSEO", "CSEO", "SSEO"))

jpeg(filename = "M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/Presentation/Figures/DSR Incidental Harvest.jpg",
     width = 6, height = 5.2, units = "in", res = 600)

ggplot(data=Incidental_sum, aes(x=Year, y=Total_mt, fill=Mgt_Area)) + 
  geom_bar(stat="identity") + ylab("Incidental Commercial Fishery Catch (t)") + 
  xlab("Year") + ylim(0,610) + scale_x_continuous(breaks = pretty(Incidental_sum$Year , n =5)) +
  (theme(legend.title=element_blank(), legend.position=c(0.75,0.75)))


dev.off()

dat10<-read_excel("M:/SAFE REPORTS FOR DSR STOCK ASSESSMENT/2017 for 2018 SAFE/DSR Biomass Calculations from ROV/data/2010-2017 DSR Harvest ALEX output.xlsx", sheet = 1)

dat11<-dat10 %>% group_by(YEAR, SPECIES) %>% filter(HARVEST_CODE != 43) %>% 
  summarise(Weight_mt = sum(ROUND_POUNDS * 0.000453592))

dat11$Weight_mt<-round(dat11$Weight_mt, 4)

View(dat11)
