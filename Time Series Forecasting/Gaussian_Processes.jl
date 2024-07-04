#Using Houston dataset from Data Preproccessing julia file

#Gaussian Processes
using GaussianProcesses
using DataFrames

#Kernel is represented as a sum of kernels
kernel = Noise(1.0) + Periodic(0.0,1.0,1.0) + SE(4.0,0.0)

#Maximum Temp
gp = GP(x_train,y_train, MeanZero(),kernel)   #Fit the GP

optimize!(gp) #Estimate the parameters through maximum likelihood estimation

μ, Σ = predict_y(gp,x_test);

using Plots
pyplot()

plot(x_test,μ,ribbon=Σ)

#Evaluate the model performance
using MLJ

println(rms(μ, y_test)) #RMSE
println(mae(μ, y_test)) #MAE
