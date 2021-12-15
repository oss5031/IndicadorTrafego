#ESTE FICHEIRO REALIZA O PRE-PROCESSAMENTO DE UM FICHEIRO .CSV (PROVENIENTE DE UMA BD
#SQLITE, OU SEJA, UM .db). OS DADOS DESTE CSV TEM DE CORRESPONDER COM A TABELA JAMSDATA
#USE: Alterar o filePath (input) e filepath de output para os writes 

library(data.table) 
library(dplyr)
library(lubridate)
library(jsonlite) #JSONLITE - fromJSON passa para objeto, toJSON passa para string
library(stringr)
library(geojsonR)

filePath = "/Users/oss5031/Documents/NodeRedData/fromRemoteLinux/traffic/2020/46/_jamsData.csv"

#ler do ficheiro para DataTable
data <- fread(filePath)

#Construcao das colunas
newData <- data.table(datetime=ymd_hms(), city=character(), street=character(),
                      level=numeric(), length=numeric(), end_node=character(),
                      speed=numeric(), road_type=numeric(),delay=numeric(), 
                      position=character())

dataDim <- dim(data)[1]
for(i in 1:dataDim) { #percorre todas as entradas do ficheiros (key, date, payload)
  
  currentPayload <- fromJSON(data[i]$payload)
  payloadDim <- currentPayload$totalFeatures
  if(is.null(payloadDim) || is.null(currentPayload) || payloadDim==0){
    next
  } 
  for(j in 1:payloadDim) { #percorre todas as features de cada entrada
    #tratar das properties (currentPayload$features$properties)
    payloadCity <- currentPayload$features[j,]$properties$city
    payloadStreet <- currentPayload$features[j,]$properties$street
    payloadLevel <- currentPayload$features[j,]$properties$level
    payloadLength <- currentPayload$features[j,]$properties$length
    payloadEndnode <- currentPayload$features[j,]$properties$end_node
    #Caso n exista end_node, para facilitar leitura no Kepler
    if(identical(payloadEndnode, character(0)) || identical(payloadEndnode, NA_character_)){
      payloadEndnode <- payloadStreet
    }
    payloadSpeed <- currentPayload$features[j,]$properties$speed * 3.6 #m/s para km/h
    payloadRoadType <- currentPayload$features[j,]$properties$road_type
    payloadDelay <- currentPayload$features[j,]$properties$delay
    #limpar partes desnecessarias do payload
    pos <- NULL
    pos$features <- currentPayload$features[j,]
    pos$features$properties <- NULL
    pos <- str_replace(toString(toJSON(pos)),"\\{","{\"type\":\"FeatureCollection\",")
    newData <- rbind(newData, data.table(
      datetime=as_datetime(data[i]$requestDate),
      city=payloadCity,
      street=payloadStreet,
      level=payloadLevel,
      length=payloadLength,
      end_node=payloadEndnode,
      speed=payloadSpeed,
      road_type=payloadRoadType,
      delay=payloadDelay,
      position=pos)
    )
    
  }
  
}

write.csv2(newData, "/Users/oss5031/Downloads/_jamsDataProcessed.csv",
           row.names = FALSE, quote = FALSE)

write_json(newData, "/Users/oss5031/Downloads/_jamsDataProcessed.json",pretty = TRUE)




