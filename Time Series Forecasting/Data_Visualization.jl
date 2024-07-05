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
