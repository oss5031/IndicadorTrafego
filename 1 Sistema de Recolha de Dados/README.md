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

- De seguida, já na aplicação Node-RED, deve-se dar import (Menu->Import) do flow através do ficheiro *CollectData_MainFlow.json* presente na pasta [NodeRed](https://bitbucket.org/ferrovia40/ironedge/src/master/prototipo/noderedApp/).

- Por fim, basta carregar em **'Deploy'** e no separador 'Main' e ativar (através de um click no quadrado à esquerda do 'timestamp') a função **GlobalVarInit**.

- Criação das tabelas necessárias no SQLite, deve ser feito através do Node-RED, no segundo separador ("SQLite"), ativar o primeiro e o terceiro 'Inject' que realizam a criação dessas mesmas tabelas.
- Ativar o fluxo que irá gerir de forma automática os diretórios onde os dados irão ser guardados semanalmente. Este processo deverá ser feito através do Node-RED, no terceiro separador ("FileSystem Manage") através da ativação do 'Inject'.
- Ativar através do Node-RED, no primeiro separador ("Main"), a recolha automática dos dados através da ativação de todos os 'Inject'.

Nota: Todo este sistema foi implementado e testado numa máquina virtual que utiliza o sistema operativo Ubuntu 20.04 e Node-RED v1.2.2 com a palette *node-red-node-sqlite* v0.4.4.

---

Todo este trabalho insere-se no âmbito do desenvolvimento de uma Tese de Mestrado em Engenharia Informática e de Computadores intitulada de **“Indicador de tráfego: descoberta de padrões na cidade de Lisboa”** - ISEL.

João Vaz - A41920