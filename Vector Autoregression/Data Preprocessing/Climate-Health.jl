#Storm Events Database
using CSV; using DataFrames

#Reduced Storm CSV from Storm_Events_Data.R
SE_df = DataFrame(CSV.File("Reduced_Storm_CSV.csv"))

#climate dataset
climate_df = DataFrame(CSV.File("HOU-Hobby Airport.csv"))

#filter to precipation, average wind, snow, max and min temp only
climate_df =  select(climate_df,[:DATE,:PRCP, :SNOW, :TMAX, :TMIN])

using Statistics

#combine storm events and climate dataset
merged_SE_df = outerjoin(climate_df, SE_df, on = :DATE)

#sort out the dates
merged_SE_df = sort!(merged_SE_df, (:DATE))

#replace the misisng values to zero
merged_SE_df.deaths = replace!(merged_SE_df.deaths, missing => 0)
merged_SE_df.injuries = replace!(merged_SE_df.injuries, missing => 0)

#replace missing to median of TMAX, MIN, PRCP, 
merged_SE_df.TMAX = replace!(merged_SE_df.TMAX, missing => floor(median(skipmissing(merged_SE_df.TMAX))))
merged_SE_df.TMIN = replace!(merged_SE_df.TMIN, missing => floor(median(skipmissing(merged_SE_df.TMIN))))
merged_SE_df.PRCP = replace!(merged_SE_df.PRCP, missing => floor(median(skipmissing(merged_SE_df.PRCP))))
merged_SE_df.SNOW = replace!(merged_SE_df.SNOW, missing => floor(median(skipmissing(merged_SE_df.SNOW))))

#save as csv file
CSV.write("Merged_SE.csv", merged_SE_df) 
