rm(list=ls())

library(tidyverse)
library(ggplot2)
library(ggsci)
library(cowplot)
library(Cairo)
#### Import data ####
#Filter group: 
#Event type is "Accident" and 
#FAR part is "Non-U.S., commercial" and 
#Aircraft category is "Airplane" and
#Fatal - Onboard is greater than "0"

#Want columns 1, 4, 17-21, 27
#NA in place of the desired column index
columns = c(NA, rep("NULL", 2), NA, rep("NULL", 12), 
            NA, NA, NA, NA, NA, rep("NULL", 5), 
            NA, rep("NULL", 19))

non_us_df = read.csv("cases2024-12-12_21-15.csv", colClasses = columns)

#Filter group: 
#Event type is "Accident" and 
#FAR part is "Part 121: Air carrier" and 
#Fatal - Onboard is greater than "0"

air_carrier_df =read.csv("cases2024-12-11_01-08.csv", colClasses = columns)


#### Manipulating data frame ####

#Since there are no overlaps between the data frames
#We can just combine the two immediately
combined_df = rbind(air_carrier_df, non_us_df)
combined_df = combined_df %>% 
  mutate(EventDate = as.Date(EventDate, format ="%Y-%m-%d"))


#Can check that all NtsbNo are unique
combined_df$NtsbNo %>% unique() %>% length()
#Gives 357 which is the same number of rows in the combined data frame
yearly_df = combined_df %>% 
  mutate(type = case_when(grepl("Boeing", Make, ignore.case = T) ~ "Boeing",
                          grepl("Douglas", Make, ignore.case = T) ~ "McDonnell D.",
                          grepl("Airbus", Make, ignore.case = T) ~ "Airbus",
                          grepl("Cessna", Make, ignore.case = T) ~ "Cessna",
                          TRUE ~ "All other makers")) %>% 
  group_by(date = lubridate::floor_date(EventDate, "year"), type) %>% 
  summarise(yFatal = sum(FatalInjuryCount),
            ySerious = sum(SeriousInjuryCount),
            yMinor = sum(MinorInjuryCount),
            yOnboard = sum(OnboardInjuryCount),
            yOnground = sum(OnGroundInjuryCount))


yearly_proportion = yearly_df %>% filter(type !="All other makers") %>% group_by(type) %>% 
  mutate(yFatal_prop = case_when(type == "Boeing" ~ yFatal/43.9,
                                 type == "McDonnell D." ~ yFatal/4.5,
                                 type == "Airbus" ~ yFatal/21.2,
                                 type == "Cessna" ~yFatal/3.4))
#Source for numbers
#https://dsm.forecastinternational.com/2019/10/01/an-overview-of-the-u-s-commercial-aircraft-fleet-2/#:~:text=Of%20the%207%2C356%20aircraft%20in,manufactured%20by%2013%20different%20companies.
#### Plotting ####
#Plot raw fatalities from 2001-01-01
raw_plotting_df = yearly_df %>% filter(type != "All other makers",
                                       date > "2000-01-01") %>% 
  group_by(type) %>% mutate(cum_yFatal = cumsum(yFatal))

rawplot <- ggplot(data = raw_plotting_df)+
  geom_point(aes(x=date, y=cum_yFatal, color= type))+
  geom_line(aes(x=date, y=cum_yFatal, color= type))+
  theme_bw()+
  scale_x_date(name="")+
  scale_y_continuous(name = "Yearly Fatalities Cumulated")+
  scale_color_lancet(name = "Aircraft Type")
rawplot
Cairo(210, 120, file="rawfatalitiesplot.png", type="png", bg="white", res = 400, units = "mm")
rawplot
dev.off()
#Only plot from 2000
#Cumulate the fatalities over the time period
truncated = yearly_proportion %>% filter(date > "2000-01-01") %>% 
  group_by(type) %>% mutate(cum_yFatal_prop = cumsum(yFatal_prop))

plot1 <- ggplot(data= truncated)+
  geom_point(aes(x=date, y=(cum_yFatal_prop), color= type))+
  theme_bw()+
  scale_x_date(name ="")+
  scale_y_continuous(name = "Number of Fatilities by Share of Flight")+
  scale_color_lancet(name = "Aircraft Type")
plot1

#Save plot
Cairo(210, 120, file="fatalitiesplot.png", type="png", bg="white", res = 400, units = "mm")
plot1
dev.off()


summary(lm(data=truncated, cum_yFatal_prop ~ date+type))
