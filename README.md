# Time Series Approach
2023 Master's Thesis by Kameron Kinast


Dataset Folder: the datasets were extracted from the National Center of Environmental Information (NECI's) Climate Data Online (CDO). Each dataset consists of daily observations of climate variables from January 1st, 1950, to December 31st, 2022. Therefore, the datasets are time series data of climate factors. This folder contains five different airport sites within the United States. 

Time Series Forecasting Folder: four statistical models of time series forecasting with climate datasets in different programming languag

Vector AutoRegressive Folder:
    Datasets:
        Since the Bureau of Labor Statistics only collects the CPI values, the change in index values and the inflation rate are computed and added as two new variables to the economic datasets using Excel. The inflation rate, also known as percent change, is calculated using the following equation:

    Inflation Rate = ((Current CPI - Prior CPI)/(Prior CPI)) * 100

Data Pre-Processing: 
          
          The storm events datasets are extremely large. Using R programming, the datasets were filtered into only three columns: Dates, the number of Fatalities, and the number of Injuries. 
          
          Climate-Economy: The climate dataset is reducing its data resolution to bi-monthly and merging with the economic dataset. CPI and Food-only CPI were created into separate CSV files with the merging of climate datasets. 
          
          Climate-Health: The storm event datasets merged with the climate datasets in daily resolution. However, the storm event dataset only records the occurrence of storms, so it expanded into daily resolution. The missing values were replaced with zeros in storm event datasets. 
    
