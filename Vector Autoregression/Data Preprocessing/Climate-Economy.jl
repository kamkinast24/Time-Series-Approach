using CSV; using DataFrames; using TimeSeries; using Dates
climate_df = DataFrame(CSV.File("Houston HOU.csv"))

#Only above 1980
climate_df = climate_df[(year.(climate_df.DATE).>= 1980), : ]

#filter to precipation, average wind, snow, max and min temp only
climate_df =  select(climate_df,[:DATE,:PRCP, :SNOW, :TMAX, :TMIN])

using Statistics

#replace 0.0 to median of TMAX, MIN, PRCP, 
climate_df.TMAX = replace!(climate_df.TMAX, missing => floor(median(skipmissing(climate_df.TMAX))))
climate_df.TMIN = replace!(climate_df.TMIN, missing => floor(median(skipmissing(climate_df.TMIN))))
climate_df.PRCP = replace!(climate_df.PRCP, missing => floor(median(skipmissing(climate_df.PRCP))))
climate_df.SNOW = replace!(climate_df.SNOW, missing => floor(median(skipmissing(climate_df.SNOW))))

#Create Time Array
climate_ta = TimeArray(climate_df; timestamp = :DATE)

using TimeSeriesResampler

#Reduce the data size
#average the daily into bimonthly
climate_ta = mean(resample(climate_ta, Dates.Month(2)))

#recreate dataframe
reduced_climate_df = DataFrame(values(climate_ta), :auto)
reduced_climate_df = select(reduced_climate_df,"x1" => "PRCP","x2" => "SNOW",
    "x3" => "TMAX", "x4" => "TMIN")

#add one more month (with same average values) to match to economy dataset
reduced_climate_df[!,:DATES] = timestamp(climate_ta)+ Dates.Month(1) 
reduced_climate_df = reduced_climate_df[!, [:DATES, :PRCP, :SNOW, :TMAX, :TMIN]]


#CPI Economy dataset
Inf_df = DataFrame(CSV.File("HOU-CPI.csv"))
Food_df = DataFrame(CSV.File("HOU- Food_CPI.csv"))

#convert to dates
Inf_df.DATES = Date.(Inf_df.Label, "yyyy u")
Food_df.DATES = Date.(Food_df.Label, "yyyy u")

#Only focus on Inflation Rates
Inf_df = select!(Inf_df, [:DATES, :Inflation_Rate])
Food_df = select!(Food_df, [:DATES, :Inflation_Rate])

#combine  CPI economy and climate dataset
merged_df = innerjoin(reduced_climate_df, Inf_df, on = :DATES)
merged_food_df = innerjoin(reduced_climate_df, Food_df, on = :DATES)
