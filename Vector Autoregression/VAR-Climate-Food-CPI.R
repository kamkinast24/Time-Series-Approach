# Import the data and look at the first six rows
merged_Food_df <- read.csv(file = 'Merged_Food.csv')
head(merged_Food_df)

#Convert dates into date format
merged_Food_df$DATES <- as.Date(merged_Food_df$DATES, format = '%Y-%m-%d')

#Ensure all values are time series
merged_Food_df$PRCP <- ts(merged_Food_df$PRCP)
merged_Food_df$TMAX <- ts(merged_Food_df$TMAX)
merged_Food_df$SNOW <- ts(merged_Food_df$SNOW)
merged_Food_df$TMIN <- ts(merged_Food_df$TMIN)
merged_Food_df$Inflation_Rate <- ts(merged_Food_df$Inflation_Rate)


#Check if there is any duplicate
sum(duplicated(merged_Food_df))

#New dataframe
Food_df = merged_Food_df[,c("PRCP","SNOW","TMAX","TMIN","Inflation_Rate")]

library('vars')
library(astsa)

#select best lag length
VARselect(Food_df, lag.max = 15, type ='const')

#estimation
var_model_df <- VAR(Food_df, p = 6, 
                     type = 'const')
#Granger Casuality 
causality(var_model_df, cause=c("PRCP","SNOW","TMAX","TMIN"))

#plot(var.model_df)
summary(var_model_df)

#Orthogonal Impulse Function
irf_var <- irf(var_model_df,n.ahead = 12, ortho = TRUE)
plot(irf_var)


#Forecast Error Variance Decomposition
fevd <- fevd(var_model_df,n.ahead = 12)
plot(fevd)
