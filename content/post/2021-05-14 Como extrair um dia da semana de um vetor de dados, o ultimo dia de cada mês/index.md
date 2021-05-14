title: "Como extrair um dia da semana de um vetor de dados, o ultimo dia de cada m�s."

categories: []

date: '2021-05-14T00:00:00Z'

draft: no

featured: no

gallery_item: null

image:
  caption: 
  focal_point: Top
  preview_only: no

projects: []

subtitle: null

summary: null

tags: 
- Open Data
- Open Code
- Tratamento de Dados

authors:
- GersonJunior




---
Esse post foi motivado com duas d�vidas que ocorreram a mim no dia de ontem. A primeira d�vida foi postada na [comunidade do R programadores no facebook](https://www.facebook.com/groups/1410023525939155)* foi como  obtinha a ultima sexta feira do m�s dado um vetor de dates. A outra d�vida foi de um colega de doutorado como ele obtinha o retorno semanal de uma Commodity, come�ando na ter�a-feira. Entendendo que essa d�vida era uma d�vida recorrente. Fiz esse post. Nele voc� aprender�:
1) Baixar dados a partir da fun��o getSymbols (fun��o j� recorrente no blog)
2) Tratar as datas 
3) Fazer uma nova coluna de verdadeiro ou falso atrav�s de uma logica por uma data usando tidyverse.

## Trabalhando com dados
Carregando os pacotes   
   
    library(PerformanceAnalytics)
    library(data.table)
    library(tidyverse)

#Filtrar todas as ter�as-feiras do m�s e obter o retorno semanal
Baixando os dados, no caso iremos usar 8 ETFS: U.S. investment-grade bonds (BND), International, investment-grade bonds (IAGG), High-yield bonds (GHYG), U.S. equities (VTI),Developed equities (VXUS),Emerging market equities (VWO),Commodities (GSG),REITs (USRT).

    asset_names <- c("BND", "IAGG", "GHYG", "VTI", "VXUS", "VWO", "GSG", "USRT")
    from.date <- as.Date("01/01/17", format="%m/%d/%y")
    options("getSymbols.warning4.0"=FALSE)
    getSymbols(asset_names, from = from.date)
Juntando todos os xts em um dataframe. 

    prices.data <- data.frame(BND[,6], IAGG[,6], GHYG[,6], VTI[,6], VXUS[,6], VWO[,6], GSG[,6], USRT[,6])
O nome da linha � a data, a fun��o abaixo faz com que a data se torno uma coluna

    prices.data$date <- rownames(prices.data)
Extraindo o dia da semana das datas e criando uma coluna.
  
    prices.data$Week = weekdays(as.Date(prices.data$date))
Filtrando os dias da semana. Observa��o, meu R est� em portugu�s, pode ser que o seu esteja em ingl�s.

    prices.data = prices.data %>% filter(Week == "ter�a-feira")
Pivot-longer. Eu tamb�m fiz um post explicando como fazer o pivot wider nesse [post](https://opencodecom.net/post/2021-04-22-como-fazer-reshape-no-r/)

    prices.data = prices.data  %>% pivot_longer(!date & !Week , names_to = "Assets", values_to = "Value")
Obtendo uma nova coluna o retorno da semana. 

    prices.data = prices.data %>% group_by(Assets) %>%  mutate(Return_week = ROC(Value))



#Fazer uma coluna com a ultima sexta feira do m�s, a ultima semana do m�s e o ultimo dia do m�s
Limpando a base

    rm(list = ls())

    asset_names <- c("BND", "IAGG", "GHYG", "VTI", "VXUS", "VWO", "GSG", "USRT")
    from.date <- as.Date("01/01/17", format="%m/%d/%y")
    options("getSymbols.warning4.0"=FALSE)
    getSymbols(asset_names, from = from.date)
    prices.data <- data.frame(BND[,6], IAGG[,6], GHYG[,6], VTI[,6], VXUS[,6], VWO[,6], GSG[,6], USRT[,6])
    prices.data$date <- rownames(prices.data)
    prices.data$Week = weekdays(as.Date(prices.data$date))
    prices.data = prices.data  %>% pivot_longer(!date & !Week , names_to = "Assets", values_to = "Value")

Realizando 3 colunas: a resposta TRUE em LastWeekInMonth representa a ultima semana do m�s, TRUE em LastFridayInMonth a ultima sexta do m�s, e TRUE em LastDayInMonth representa o �ltimo dia do m�s.

    prices.data = prices.data %>% 
      mutate(year = year(date),month= month(date)) %>%
      group_by(year, month) %>% 
      mutate(LastDayInMonth = max(date)==date)%>% 
      arrange(date) %>%
      ungroup() %>% 
      group_by(year, month, Week,Assets) %>%
      mutate(LastWeekInMonth = row_number() ==  n(), 
             LastFridayInMonth = Week =="sexta-feira" & LastWeekInMonth == 1) %>% 
      ungroup()

Se filtrar TRUE em LastFridayInMonth voc� obter� o df de todos as sextas-feiras do m�s, e assim por diante.

    prices.data = prices.data %>% filter(LastFridayInMonth == "TRUE")
