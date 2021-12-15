# Sistema de recolha, armazenamento e pré-tratamento de dados

## Requisitos
Será necessário ter instalado as seguintes aplicações:

- Aplicação Node-RED [https://nodered.org/] com a palette (plugin do Node-RED) *node-red-node-sqlite* [https://flows.nodered.org/node/node-red-node-sqlite].
- Base de Dados SQLite [https://www.sqlite.org/index.html].
- R Studio [https://www.rstudio.com/].

## Fontes de dados
Estão a ser recolhidos dados de duas fontes: **a)** EMEL, que reporta dados relacionados com o tráfego automóvel na cidade de Lisboa [https://emel.city-platform.com/opendata/] e **b)** IPMA, que reporta dados meteorológicos de todo o país [http://api.ipma.pt/#services].

## Servidor e Base de Dados
A aplicação Node-RED é utilizada como servidor que irá estar em constante funcionamento a obter os dados das respectivas fontes e a armazená-los nas suas respectivas base de dados SQLite conforme o tipo de dados, tráfego ou meteorológia, estando estes a ser recolhidos de 5 em 5 minutos e de 1 em 1 hora, respectivamente.

No caso do primeiro acesso, será necessário a configuração do sistema através da realização das seguintes tarefas:

- Correr o ficheiro deploy.sh que irá criar o diretório onde os ficheiros com as bases de dados irão permanecer.

- De seguida, já na aplicação Node-RED, deve-se dar import (Menu->Import) do flow através do ficheiro *CollectData_MainFlow.json* presente na pasta [NodeRed](https://github.com/oss5031/IndicadorTrafego/tree/main/1%20Sistema%20de%20Recolha%20de%20Dados/NodeRed) e carregar em **'Deploy'** no canto superior direito.

- Criação das tabelas necessárias no SQLite, deve ser feito através do Node-RED, no segundo separador ("SQLite"), ativar o primeiro e o terceiro 'Inject' (clique no quadrado à esquerda do 'timestamp') que realizam a criação dessas mesmas tabelas. (*)

- Ativar o fluxo que irá gerir de forma automática os diretórios onde os dados irão ser guardados semanalmente. Este processo deverá ser feito através do Node-RED, no terceiro separador ("FileSystem Manage") através da ativação do 'Inject' (clique no quadrado à esquerda do 'timestamp').

- Ativar através do Node-RED, no primeiro separador ("Main"), a recolha automática dos dados através da ativação de todos os 'Inject' (clique no quadrado à esquerda do 'timestamp').

(*)
Tabelas criadas: *a)* JamsData - congestionamentos de trânsito, *b)* IrregularitiesData -  congestionamentos de trânsito identificados como irregulares, *c)* ClosuresData - bloqueios, condicionamentos e restrições de vias previamente programadas na cidade, *d)* WeatherData - dados meteorológicos observados nas últimas 24 horas e *e)* PrevWeatherData - previsão de dados meteorológicos até um máximo de 5 dias.

Nota: Todo este sistema foi implementado e testado numa máquina virtual que utiliza o sistema operativo Ubuntu 20.04 e Node-RED v1.2.2 com a palette *node-red-node-sqlite* v0.4.4.

## Pré-Processamento
Estando os dados guardados em bases de dados SQLite (ficheiros .db) e sendo todas as tabelas constituidas pelas colunas key, requestDate e payload, é necessário extrair os dados para o formato .csv para posteriormente serem processados e analisados.

Para realizar a extração dos dados de uma tabela para um ficheiro .csv deverá utilizar-se este comando através da linha de comandos:
````
sqlite3 -header -separator ";" {dbInputFilePath} "Select * from jamsData;" > {csvOutputFilePath}
````

Após obtenção dos ficheiros .csv correspondentes às tabelas JamsData e WeatherData, sendo estas as únicas utilizadas até ao momento, é necessário realizar um conjunto de pré-processamentos sobre os mesmos com o objetivo de obter um conjunto de dados que agrega a informação dessas duas tabelas.

Estes pré-processamentos encontram-se na pasta [PreProcessamento](https://github.com/oss5031/IndicadorTrafego/tree/main/1%20Sistema%20de%20Recolha%20de%20Dados/PreProcessamento) e devem ser executados no R Studio pela seguinte ordem:

- [00_PreProc_JamsData](https://github.com/oss5031/IndicadorTrafego/tree/main/1%20Sistema%20de%20Recolha%20de%20Dados/PreProcessamento/00_PreProc_JamsData.R) - Processa o campo payload do ficheiro csv correspondente à tabela JamsData.

- [00_PreProc_WeatherData](https://github.com/oss5031/IndicadorTrafego/tree/main/1%20Sistema%20de%20Recolha%20de%20Dados/PreProcessamento/00_PreProc_WeatherData.R) - Processa o campo payload do ficheiro csv correspondente à tabela WeatherData.

- [01_Agregar_JamsData](https://github.com/oss5031/IndicadorTrafego/tree/main/1%20Sistema%20de%20Recolha%20de%20Dados/PreProcessamento/01_Agregar_JamsData.R) - Realiza a agregação de linhas idênticas num intervalo especifico de tempo em JamsData. 

- [02_CriarDatasetConjunto](https://github.com/oss5031/IndicadorTrafego/tree/main/1%20Sistema%20de%20Recolha%20de%20Dados/PreProcessamento/02_CriarDatasetConjunto.R) - Realiza a agregação dos dois conjuntos de dados provenientes das tabelas JamsData e WeatherData.


---

Todo este trabalho insere-se no âmbito do desenvolvimento de uma Tese de Mestrado em Engenharia Informática e de Computadores intitulada de **“Indicador de tráfego: descoberta de padrões na cidade de Lisboa”** - ISEL.

João Vaz - A41920