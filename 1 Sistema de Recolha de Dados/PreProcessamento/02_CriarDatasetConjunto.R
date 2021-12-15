#ESTE FICHEIRO REALIZA A AGREGACAO DOS DATASETS JAMS E WEATHER

library(data.table) 
library(dplyr)
library(lubridate)
library(jsonlite) #JSONLITE - fromJSON passa para objeto, toJSON passa para string
library(stringr)
library(geojsonR)

jamsFilePath = "/Users/oss5031/Documents/NodeRedData/fromRemoteLinux/traffic/2020/47/_jamsDataAggregated.csv"
weatherFilePath = "/Users/oss5031/Documents/NodeRedData/fromRemoteLinux/weather/2020/47/_weatherDataProcessed.csv"

jamsData <- fread(jamsFilePath)
weatherData <- fread(weatherFilePath)

finalData <- NULL
dataDim <- dim(jamsData)[1]
for(i in 1:dataDim) {
  #baixa sempre para hora mais proxima de modo a ficar hora 'certa' para existir no
  #dataset da weather (onde só existem entradas com hora 'certa')
  currentDate <- floor_date(ymd_hms(jamsData[i]$datetime), "1 hour")
  currentWeather <- weatherData %>% filter(ymd_hms(data) == currentDate )
  newRow <- cbind(jamsData[i], currentWeather %>% select(-1))
  finalData <- rbind(finalData,newRow) 
}


write.csv2(finalData, "/Users/oss5031/Downloads/_jamsDataset.csv",
           row.names = FALSE, quote = FALSE)

write_json(finalData, "/Users/oss5031/Downloads/_jamsDataset.json",pretty = TRUE)

#round_date - rounds it to the nearest value
#floor_date - rounds it down to the nearest boundary
#ceiling_date - rounds it up to the nearest boundary 



