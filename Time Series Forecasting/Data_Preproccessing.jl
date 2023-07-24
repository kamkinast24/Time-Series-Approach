using CSV; using DataFrames;

#Extract the dataset of Houston, HOS 
df = DataFrame(CSV.File("Houston HOU.csv"))

#find the median of each climate variable and ensure it is in format of INT64
#ADF Test and PACF/ACF requires Vector of INT64
med_TMAX = floor(Int, median(skipmissing(df.TMAX))) #Maximum Temp
med_TMIN = floor(Int, median(skipmissing(df.TMIN))) #Minimum Temp
med_PRCP = floor(Int, median(skipmissing(df.PRCP))) #Precip.
med_SNOW = floor(Int, median(skipmissing(df.SNOW))) #Snowfall

#replace missing value to median value
df.TMAX = coalesce.(df.TMAX, med_TMAX)
df.TMIN = coalesce.(df.TMIN, med_TMIN)
df.PRCP = coalesce.(df.PRCP, med_PRCP)
df.SNOW = coalesce.(df.SNOW, med_SNOW)

#filter to precipation, snow, max and min temp only
main_df =  select(df,[:DATE,:PRCP, :SNOW, :TMAX, :TMIN])

#Mini-batch: last twenty years
main_df = last(main_df, 7305)

#Adding number of days
main_df[!, :DAY] =  1.0:nrow(main_df)

#Checking if the time series is stationairty, using ADF Test
using HypothesisTests

#Stationarity Test ~ ADF
println(ADFTest(batch_df.TMAX, Symbol("constant"),5))

#Creating training and test set for AR Model
using MLDataUtils
(x_train_max, y_train_max), (x_test_max, y_test_max) = splitobs((main_df.DAY, main_df.TMAX); at = 0.8) #80-20
