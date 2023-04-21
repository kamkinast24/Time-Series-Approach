#Julia Programming
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

#Adding number of days
main_df[!, :DAY] =  1.0:nrow(main_df)

#Maximum Temperature Variable only
#PACF
pacf_plot_tmax = plot(Forecast.pacf(main_df.TMAX,lag = 25))

#ACF
acf_plot_tmax = plot(Forecast.acf(main_df.TMAX, lag = 25))

plot(acf_plot_tmax)
plot(pacf_plot_tmax)

#Creating training and test set for AR Model
using MLDataUtils
(x_train_max, y_train_max), (x_test_max, y_test_max) = splitobs((main_df.DAY, main_df.TMAX); at = 0.8) #80-20


#AR Model
using Forecast

#optimization function to find best order of p
aic_ar_pred_max = []
bic_ar_pred_max =[]
for i in 1:110
    AR_model_max = ar(Vector{Float64}(y_train_max), i)
    d = AR_model_max.ic::Dict #extract the information criterion 
    aic_ar_max = get(d,"AIC",4) #extract AIC info from AR model, if no answer, default is 4
    bic_ar_max = get(d,"BIC",4)
    push!(aic_ar_pred_max, aic_ar_max)
    push!(bic_ar_pred_max, bic_ar_max)
end

println(findmin(aic_ar_pred_max)) #select the minimum value of output vector 
println(findmin(bic_ar_pred_max))

#Create AR model based on best AIC
ar_temp_max = ar(Vector{Float64}(y_train_max),88)

#Forecast the temperatures
fc_temp_max = Forecast.forecast(ar_temp_max,length(y_test_max));

plot(fc_temp_max)

#Performance Evluation
using MLJ

println(rms(fc_temp_max.mean[!,2], y_test_max)) #RMSE
println(mae(fc_temp_max.mean[!,2], y_test_max)) #MAE