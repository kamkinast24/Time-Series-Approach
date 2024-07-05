# Data Visualziation of all four time series forecasting methods

using Plots; using CSV; using DataFrames; using Statistics;

#Extract the dataset of MLP RESULTS
mlp = DataFrame(CSV.File("y_pred.csv"))
MLP_data = mlp.values

ARIMA_dataset = fc_temp.mean[:,2]
ETS_data = forec_ets.expected_value
ETS_data = reduce(vcat, ETS_data)
#GP_dataset = μ

using Dates
dr = Dates.Date(2019,1,1):Day(1):Date(2022,12,31)
num_day = collect(dr)

# convert to Celsius 
ARIMA_dataset_C = (ARIMA_dataset.-32.0).* (5/9)
MLP_data_C = (MLP_data.-32.0).* (5/9)
ETS_data_C = (ETS_data.-32.0).* (5/9)
#GP_dataset_C = (GP_dataset.-32.0).* (5/9)
y_test_C = (y_test.-32.0).* (5/9)

using LaTeXStrings

plot(num_day, y_test_C, label = "Observations", color = "midnightblue", lw =2, framestyle = :box)
plot!(num_day, MLP_data_C, label = "MLP", color = "steelblue", lw = 2)
plot!(num_day,ETS_data_C, label = "ETS" , color = "skyblue2", lw = 2)
plot!(num_day,ARIMA_dataset_C, label = "ARIMA", color = "darkgoldenrod1", lw = 2, legend = :bottomleft)
#plot!(num_day, GP_dataset_C, label = "GP", color = "darkorange", lw =2)
ylabel!("Minimum Temperature [°C]")
#ylabel!("Maximum Temperature [°C]")
xlabel!("Dates")
#ylims!(-30, 40) #maximum
ylims!(-40, 30) #minimum
#yticks!([-20, -10, 0,10,20,30,40]) #maximum
yticks!([ -30, -20,-10, 0, 10, 20, 30]) #minimum

png("Chicago_Minimum_Temp.png")


using Plots; using CSV; using DataFrames; using Statistics; using GLM

#Extract the dataset of MLP RESULTS
mlp_forecast = DataFrame(CSV.File("y_forecast.csv"))
MLP_forecast_data = last(mlp_forecast.values, 2922)

#Collect the dates
dr = Dates.Date(2003,1,1):Day(1):Date(2030,12,31)
num_day_combined = collect(dr)
dr_obs = Dates.Date(2003,1,1):Day(1):Date(2022,12,31)
num_day_obs = collect(dr_obs)
dr_forecast = Dates.Date(2023,1,1):Day(1):Date(2030,12,31)
num_day_for = collect(dr_forecast)

#Convert to Celisus
MLP_forecast_data_C = (MLP_forecast_data.-32.0).* (5/9)
#observations = (main_df.TMAX.-32.0).* (5/9) #maximum
observations = (main_df.TMIN.-32.0).* (5/9) #minimum

#Combine observations and MLP
combination = reduce(vcat,(observations, MLP_forecast_data_C))

#trend 
#Adding number of days
df_proejction = DataFrame(DAY = 1.0:length(combination), VALUES = combination)
model = lm(@formula(VALUES ~ DAY), df_proejction)
trend = 0.000213184.*df_proejction.DAY.+ 4.81406

plot(num_day_combined,combination, label = false, framestyle = :box)
plot!(num_day_obs,observations, label = "Observations", lw = 3)
plot!(num_day_for, MLP_forecast_data_C, label = "MLP Forecast Values", lw = 3)
plot!(num_day_combined, trend, label = "Trendline", color = "grey0", lw = 3, legend =:bottomright)
#annotate!(num_day_combined[1195], -25,text("y = 0.0002x + 4.81", 7)) #maximum
annotate!(num_day_combined[1195], -35,text("y = 0.0002x + 4.81", 7)) #minimum
ylabel!("Minimum Temperature [°C]")
#ylabel!("Maximum Temperature [°C]")
xlabel!("Dates")
#ylims!(-30, 40) #maximum
ylims!(-40, 30) #minimum
#yticks!([-20, -10, 0,10,20,30,40]) #maximum
yticks!([ -30, -20,-10, 0, 10, 20, 30]) #minimum


png("Chicago_Minimum_Forecast.png")
