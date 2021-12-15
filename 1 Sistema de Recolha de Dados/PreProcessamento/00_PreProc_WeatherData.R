#ESTE FICHEIRO REALIZA O PRE-PROCESSAMENTO DE UM FICHEIRO .CSV (PROVENIENTE DE UMA BD
#SQLITE, OU SEJA, UM .db). OS DADOS DESTE CSV TEM DE CORRESPONDER COM A TABELA WEATHERDATA
#USE: Alterar o filePath (input) e filepath de output para os writes 

#ATENÇAO: Devem ser inicializadas as funcoes auxiliares antes de executar o codigo

library(data.table) 
library(dplyr)
library(lubridate)
library(jsonlite) #JSONLITE - fromJSON passa para objeto, toJSON passa para string
library(stringr)
library(geojsonR)

filePath = "/Users/oss5031/Documents/NodeRedData/fromRemoteLinux/weather/2020/46/_weatherData.csv"

#ler do ficheiro para DataTable
data <- fread(filePath)

#Construcao das colunas
newData <- data.table(data=ymd_hm(), minIntensidadeVentoKM=numeric(), 
                      maxIntensidadeVentoKM=numeric(), mediaIntensidadeVentoKM=numeric(),
                      minTemperatura=numeric(), maxTemperatura=numeric(),
                      mediaTemperatura=numeric(), minPrecAcumulada=numeric(),
                      maxPrecAcumulada=numeric(), mediaPrecAcumulada=numeric()
                      #radiacao=numeric(), idDireccVento=numeric(), precAcumulada=numeric(),
                      #intensidadeVento=numeric(), humidade=numeric(),pressao=numeric()
            )

dataDim <- dim(data)[1] - 1
#Cada pedido irá guardar hora mais antiga de modo a garantir maior consistencia nos dados
for(i in 1:dataDim) { #percorre todas as entradas do ficheiros (key, date, payload)
  currentPayload <- fromJSON(data[i]$payload)
  idxMinHour <- match(min(names(currentPayload)), names(currentPayload))
  currentHour <- NULL
  currentStations <- NULL
  currentStations <- currentPayload[idxMinHour][[1]] #acesso ás 3 estacoes metereologicas
  currentHour <- processCurrentHour(currentStations)
  
  newData <- rbind(newData, data.table(
    data=ymd_hm(min(names(currentPayload))),
    minIntensidadeVentoKM=currentHour$minIntensidadeVentoKM,
    maxIntensidadeVentoKM=currentHour$maxIntensidadeVentoKM,
    mediaIntensidadeVentoKM=round(currentHour$mediaIntensidadeVentoKM, digits=2),
    minTemperatura=currentHour$minTemperatura,
    maxTemperatura=currentHour$maxTemperatura,
    mediaTemperatura=round(currentHour$mediaTemperatura, digits=2),
    minPrecAcumulada=currentHour$minPrecAcumulada,
    maxPrecAcumulada=currentHour$maxPrecAcumulada,
    mediaPrecAcumulada=round(currentHour$mediaPrecAcumulada, digits=2)
    )
  )
}
#Ultimo pedido guarda toda a informacao (as 24 horas)
currentPayload <- fromJSON(data[dataDim+1]$payload)
idxMinHour <- match(min(names(currentPayload)), names(currentPayload))
numHours <- length(names(currentPayload))
idxSorted <- order(names(currentPayload)) #garantir a ordem temporal
#percorrer todas as horas deste pedido
for(j in 1:numHours){
    currentHour <- NULL
    currentStations <- NULL
    currentStations <- currentPayload[idxSorted[j]][[1]] #acesso ás 3 estacoes metereologicas
    currentHour <- processCurrentHour(currentStations)
    
    newData <- rbind(newData, data.table(
      data=ymd_hm(names(currentPayload[idxSorted[j]])),
      minIntensidadeVentoKM=currentHour$minIntensidadeVentoKM,
      maxIntensidadeVentoKM=currentHour$maxIntensidadeVentoKM,
      mediaIntensidadeVentoKM=round(currentHour$mediaIntensidadeVentoKM, digits=2),
      minTemperatura=currentHour$minTemperatura,
      maxTemperatura=currentHour$maxTemperatura,
      mediaTemperatura=round(currentHour$mediaTemperatura, digits=2),
      minPrecAcumulada=currentHour$minPrecAcumulada,
      maxPrecAcumulada=currentHour$maxPrecAcumulada,
      mediaPrecAcumulada=round(currentHour$mediaPrecAcumulada, digits=2)
      )
    )
  
}


write.csv2(newData, "/Users/oss5031/Downloads/_weatherDataProcessed.csv",row.names = FALSE)

write_json(newData, "/Users/oss5031/Downloads/_weatherDataProcessed.json",pretty = TRUE)



############ CARACTERISTICAS ############
#idDireccVento
#(0: sem rumo, 1 ou 9: "N", 2: "NE", 3: "E", 4: "SE", 5: "S", 6: "SW", 7: "W", 8: "NW")


############  Funcoes Auxiliares ############ 

processCurrentHour <- function(currHour)
{
  
  res <- data.table(minIntensidadeVentoKM=numeric(), maxIntensidadeVentoKM=numeric(), 
                    mediaIntensidadeVentoKM=numeric(),minTemperatura=numeric(),
                    maxTemperatura=numeric(),mediaTemperatura=numeric(),
                    minPrecAcumulada=numeric(),maxPrecAcumulada=numeric(),
                    mediaPrecAcumulada=numeric()
                    )
  length <- length(currHour) #numero de estacoes metereologicas
  intensidadeVentoKM <- processIntensidadeVentoKM(currHour, length)
  temperatura <- processTemperatura(currHour, length)
  precAcumulada <- processPrecAcumulada(currHour, length)
  
  res <- rbind(res, data.table(
    minIntensidadeVentoKM=intensidadeVentoKM$minIntensidadeVentoKM,
    maxIntensidadeVentoKM=intensidadeVentoKM$maxIntensidadeVentoKM,
    mediaIntensidadeVentoKM=intensidadeVentoKM$mediaIntensidadeVentoKM,
    minTemperatura=temperatura$minTemperatura,
    maxTemperatura=temperatura$maxTemperatura,
    mediaTemperatura=temperatura$mediaTemperatura,
    minPrecAcumulada=precAcumulada$minPrecAcumulada,
    maxPrecAcumulada=precAcumulada$maxPrecAcumulada,
    mediaPrecAcumulada=precAcumulada$mediaPrecAcumulada
    )
  )
  
  return (res)
}

processIntensidadeVentoKM <- function(currHour, length){
  values <- NULL
  for(i in 1:length) {
    if(!is.null(currHour[[i]])){
      if(currHour[[i]]$intensidadeVentoKM != -99){
        values <- c(values, currHour[[i]]$intensidadeVentoKM)
      }
    }
  }
  toRet <- NULL
  toRet$minIntensidadeVentoKM <- min(values)
  toRet$maxIntensidadeVentoKM <- max(values)
  toRet$mediaIntensidadeVentoKM <- mean(values)
  return (toRet)
}

processTemperatura <- function(currHour, length){
  values <- NULL
  for(i in 1:length) {
    if(!is.null(currHour[[i]])){
      if(currHour[[i]]$temperatura != -99){
        values <- c(values, currHour[[i]]$temperatura)
      }
    }
  }
  toRet <- NULL
  toRet$minTemperatura <- min(values)
  toRet$maxTemperatura <- max(values)
  toRet$mediaTemperatura <- mean(values)
  return (toRet)
}

processPrecAcumulada <- function(currHour, length){
  values <- NULL
  for(i in 1:length) {
    if(!is.null(currHour[[i]])){
      if(currHour[[i]]$precAcumulada != -99){
        values <- c(values, currHour[[i]]$precAcumulada)
      }
    }  
  }
  toRet <- NULL
  toRet$minPrecAcumulada <- min(values)
  toRet$maxPrecAcumulada <- max(values)
  toRet$mediaPrecAcumulada <- mean(values)
  return (toRet)
}

