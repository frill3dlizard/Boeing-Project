# Boeing-Project
## Is Boeing actually more dangerous than other aircraft types? 

In recent times, Boeing has been under a negative light, with its most recent crash only on the 29/12/2024 killing 179 on board, leaving merely 2 surviving crew members ([thegaurdian](https://www.theguardian.com/world/2024/dec/29/south-korea-jeju-air-plane-crash-mourning), 30/12/2024). Combining this with the multiple other reports of mechanical failures and financial turmoil; Boeing seems to be failing on many fronts. Some analysis has been done on the frequency of incidents (an unforeseen event that causes no injury), however this short investigation will focus on accidents that were fatal. For passengers, whether this accident was caused due to human error, a mechanical failure or weather event is of little importance, so these types of failures are not separated.

The data on commercial aircraft fatalities was derived from the U.S. National Transport Safety Board ([NTSB](https://data.ntsb.gov/carol-main-public/query-builder)), filters can be seen in the R script. Combine the American and non-American data sets, to get `combined_df`.

```R
#Filter group: 
#Event type is "Accident" and 
#FAR part is "Non-U.S., commercial" and 
#Aircraft category is "Airplane" and
#Fatal - Onboard is greater than "0"

#Want columns 1, 4, 17-21, 27 from raw data
#NA in place of the desired column index
columns = c(NA, rep("NULL", 2), NA, rep("NULL", 12), 
            NA, NA, NA, NA, NA, rep("NULL", 5), 
            NA, rep("NULL", 19))

non_us_df = read.csv("cases2024-12-12_21-15.csv", colClasses = columns)

#Filter group: 
#Event type is "Accident" and 
#FAR part is "Part 121: Air carrier" and 
#Fatal - Onboard is greater than "0"

us_df =read.csv("cases2024-12-11_01-08.csv", colClasses = columns)

#### Manipulating data frame ####

#Since there are no overlaps between the data frames
#We can just combine the two immediately
combined_df = rbind(us_df, non_us_df) %>% 
  mutate(EventDate = as.Date(EventDate, format ="%Y-%m-%d"))
```
After extracting the aircraft manufactures of interest, I can show the raw number of fatalities from the year 2000.

![rawfatalitiesplot](https://github.com/user-attachments/assets/216e7d71-aca5-4e7c-af0e-71a5fdb9516f)

Since Boeing and Airbus have the largest fleets and certainly the most passengers in each flight, only a reliable comparison can be made relative to their share of the commercial fleet. The below plot resolves said issue.

![fatalitiesplot](https://github.com/user-attachments/assets/29ab9868-2a33-4c8e-b22c-32daef212928)
*<small> Cumulative fatalities since 2000, made relative to the percent share in the US commercial aircraft fleet, and separated by aircraft type. Share of aircraft fleet found at [ForecastInternationl](https://dsm.forecastinternational.com/2019/10/01/an-overview-of-the-u-s-commercial-aircraft-fleet-2/#:~:text=Of%20the%207%2C356%20aircraft%20in,manufactured%20by%2013%20different%20companies).</small>*

The above plot shows that Cessna has both the most frequent number of fatal incidents, but also the highest number of fatalities relative to the number of planes flown. Focusing on Airbus and Boeing (the two main aircraft types in commercial aviation), the Airbus has less accidents each year, however seemingly more severe. Boeing has a far greater number of accidents (36 vs 11), and an overall higher number of fatalities relative to the share of Boeing planes (61.252847
 vs 54.339623).
