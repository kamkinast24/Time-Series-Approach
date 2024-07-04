using StateSpaceModels

#Exponential Smoothing using Houston's Maximum Temperature

#Create ES model based on y trainset
model_ets= StateSpaceModels.ExponentialSmoothing(Vector{Float64}(y_train); trend = false, seasonal = 16) #This model only accepts vector of float64
#Fit the model
StateSpaceModels.fit!(model_ets)

#Forecasting the exponential smoothing
forec_ets= StateSpaceModels.forecast(model_ets, length(y_test))
  
#Plot the forecast
plot(model_ets, forec_ets)

#Evaluate the model performance
using MLJ
forecast_ets = reduce(vcat,forec_ets_max.expected_value)

println(rms(forecast_ets, y_test_max)) #RMSE
println(mae(forecast_ets, y_test_max)) #MAE
