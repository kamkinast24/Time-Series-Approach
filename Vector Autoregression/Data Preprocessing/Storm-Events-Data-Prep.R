#Data Wrangling with Storm Event Database
library(dplyr)
library(lubridate)

#Storm Events
SE_df <- read.csv(file = 'storm_events.csv')
#Convert into datetime
SE_df <- SE_df %>%
  mutate(DATE = lubridate::mdy(BEGIN_DATE))

#Filter to three columns only
SE_df<- SE_df %>% select(c('DATE',  'DEATHS_DIRECT', 'INJURIES_DIRECT'))

#sum all duplciate rows
SE_df <- SE_df %>% 
group_by(DATE) %>%
summarise(deaths = sum(DEATHS_DIRECT),
          injuries = sum(INJURIES_DIRECT))

#export as csv file
library(readr)
write_csv(SE_df, "Reduced_Storm_CSV.csv")
