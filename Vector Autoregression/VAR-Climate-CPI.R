# Import the data and look at the first six rows
merged_CPI_df <- read.csv(file = 'Merged_CPI.csv')
head(merged_CPI_df)

#Convert the dates into date format
merged_CPI_df$DATES <- as.Date(merged_CPI_df$DATES, format = '%Y-%m-%d')

#Requries all values to be in time series for VAR model
merged_CPI_df$PRCP <- ts(merged_CPI_df$PRCP)
merged_CPI_df$TMAX <- ts(merged_CPI_df$TMAX)
merged_CPI_df$SNOW <- ts(merged_CPI_df$SNOW)
merged_CPI_df$TMIN <- ts(merged_CPI_df$TMIN)
merged_CPI_df$Inflation_Rate <- ts(merged_CPI_df$Inflation_Rate)

#Check if there is any duplicate
sum(duplicated(merged_CPI_df))

#New DataFrame
CPI_df = merged_CPI_df[,c("PRCP","SNOW","TMAX","TMIN","Inflation_Rate")]


library('vars')
library(astsa)

#select best lag length
#VARselect(CPI_df, lag.max = 15, type ='const')

#estimation
var_model_df <- VAR(CPI_df, p = 6, 
                     type = 'const')
#Granger Casuality 
#causality(var_model_df, cause=c("PRCP","SNOW","TMAX","TMIN"))

#plot(var.model_df)
#summary(var_model_df)

#Orthogonal Impulse Function
irf_var <- irf(var_model_df,n.ahead = 12, ortho = TRUE)
plot(irf_var)


#Forecast Error Variance Decomposition
#fevd <- fevd(var_model_df,n.ahead = 12)
#plot(fevd)
