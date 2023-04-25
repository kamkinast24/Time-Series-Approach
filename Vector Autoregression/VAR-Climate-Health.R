#Storm Events
merged_SE_df <- read.csv(file = 'Merged_SE.csv')

#Convert dates into date format
merged_SE_df$DATE <- as.Date(merged_SE_df$DATE, format = '%Y-%m-%d')

#Set all data into time series
merged_SE_df$PRCP <- ts(merged_SE_df$PRCP)
merged_SE_df$TMAX <- ts(merged_SE_df$TMAX)
merged_SE_df$SNOW <- ts(merged_SE_df$SNOW)
merged_SE_df$TMIN <- ts(merged_SE_df$TMIN)
merged_SE_df$deaths <- ts(merged_SE_df$deaths)
merged_SE_df$injuries <- ts(merged_SE_df$injuries)

#Split the injuries and death 
merged_SE_Inj_df <- merged_SE_df[,-6]
merged_SE_Death_df <- merged_SE_df[,-7]

#Check if there is any duplicate
sum(duplicated(merged_SE_Inj_df))
sum(duplicated(merged_SE_Death_df))

#new dataframe 
SE_Inj_df = merged_SE_Inj_df[,c("PRCP","SNOW","TMAX","TMIN", "injuries")]
SE_Death_df = merged_SE_Death_df[,c("PRCP","SNOW","TMAX","TMIN", "deaths")]


library('vars')
library(astsa)

#select best lag length
VARselect(SE_Inj_df_df, lag.max = 15, type ='const')

#estimation
var_model_df <- VAR(SE_Inj_df, p = 13, 
                     type = 'const')
#Granger Casuality 
causality(var_model_df, cause=c("PRCP","SNOW","TMAX","TMIN"))

#plot(var.model_df)
summary(var_model_df)

#Orthogonal Impulse Function
irf_var <- irf(var_model_df,n.ahead = 30, ortho = TRUE)
plot(irf_var)


#Forecast Error Variance Decomposition
fevd <- fevd(var_model_df,n.ahead = 30)
plot(fevd)
