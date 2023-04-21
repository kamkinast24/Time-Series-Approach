using StateSpaceModels

#Exponential Smoothing using Houston's Maximum Temperature

#Create ES model based on y trainset
model_ets_max = StateSpaceModels.ExponentialSmoothing(Vector{Float64}(y_train_max); trend = false, seasonal = 16)#AR model only accepts vector of float64
#Fit the model
StateSpaceModels.fit!(model_ets_max)

#Forecasting the exponential smoothing
forec_ets_max= StateSpaceModels.forecast(model_ets_max, length(y_test_max))
  
#Plot the forecast
plot(model_ets_max, forec_ets_max)

using MLJ
forecast_ets_max = reduce(vcat,forec_ets_max.expected_value)

println(rms(forecast_ets_max, y_test_max)) #RMSE
println(mae(forecast_ets_max, y_test_max)) #MAE
