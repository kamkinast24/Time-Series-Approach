#Using Houston dataset from Data Preproccessing julia file

#Gaussian Processes
using GaussianProcesses
using DataFrames

#Kernel is represented as a sum of kernels
kernel = Noise(1.0) + Periodic(0.0,1.0,1.0) + SE(4.0,0.0)

#Maximum Temp
gp_max = GP(x_train_max,y_train_max, MeanZero(),kernel)   #Fit the GP

optimize!(gp_max) #Estimate the parameters through maximum likelihood estimation

μ_max, Σ_max = predict_y(gp_max,x_test_max);

using Plots
pyplot()

plot(x_test_max,μ_max,ribbon=Σ_max)

#Evaluate the model performance
using MLJ

println(rms(μ_max, y_test_max)) #RMSE
println(mae(μ_max, y_test_max)) #MAE
