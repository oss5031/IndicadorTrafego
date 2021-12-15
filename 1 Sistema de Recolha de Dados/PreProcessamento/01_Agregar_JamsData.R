#USE: Alterar o filePath (input) e filepath de output para os writes 
#É REALIZADA A AGREGACAO DE LINHAS IDENTICAS NUM INTERVALO ESPECIFICO DE TEMPO (JamsData)

library(data.table) 
library(dplyr)
library(lubridate)
library(jsonlite) #JSONLITE - fromJSON passa para objeto, toJSON passa para string
library(stringr)
library(geojsonR)

filePath = "/Users/oss5031/Documents/NodeRedData/fromRemoteLinux/traffic/2020/47/_jamsDataProcessed.csv"

#ler do ficheiro para DataTable
data <- fread(filePath)

#round_date - rounds it to the nearest value
#floor_date - rounds it down to the nearest boundary
#ceiling_date - rounds it up to the nearest boundary 
aggregateInterval <- "30 minutes"

current <- data %>%
  mutate(aggregationDate=floor_date(ymd_hms(data$datetime),aggregateInterval)) 

current <- current %>% 
  select(-datetime) %>%
  select(aggregationDate,everything())

current <- distinct(current)

finalData <- rename(current, datetime = aggregationDate) 

write.csv2(finalData, "/Users/oss5031/Downloads/_jamsDataAggregated.csv",
           row.names = FALSE, quote = FALSE)

write_json(finalData, "/Users/oss5031/Downloads/_jamsDataAggregated.json",pretty = TRUE)



