#Using Houston's dataset in Data_PreProccessing Julia code

#Maximum Temperature Variable only

#ADF Test and PACF/ACF requires Vector of INT64
#PACF
pacf_plot = plot(Forecast.pacf(main_df.TMAX,lag = 25))

#ACF
acf_plot = plot(Forecast.acf(main_df.TMAX, lag = 25))

plot(acf_plot)
plot(pacf_plot)

#AR Model
using Forecast

#optimization function to find best order of p
aic_ar_pred = []
bic_ar_pred =[]
for i in 1:110
    AR_model = ar(Vector{Float64}(y_train), i)
    d = AR_model.ic::Dict #extract the information criterion 
    aic_ar = get(d,"AIC",4) #extract AIC info from AR model, if no answer, default is 4
    bic_ar = get(d,"BIC",4)
    push!(aic_ar_pred, aic_ar)
    push!(bic_ar_pred, bic_ar)
end

println(findmin(aic_ar_pred)) #select the minimum value of output vector 
println(findmin(bic_ar_pred))

#Create AR model based on best AIC
ar_temp_max = ar(Vector{Float64}(y_train),88)

#Forecast the temperatures
fc_temp_max = Forecast.forecast(ar_temp_max,length(y_test));

plot(fc_temp)

#Performance Evluation
using MLJ

println(rms(fc_temp_max.mean[!,2], y_test)) #RMSE
println(mae(fc_temp_max.mean[!,2], y_test)) #MAE
