---
title: "Como extrair um dia da semana, último dia do mês de um vetor de datas"

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



---
A motivação desse post se deu por causa de dois pedidos: o primeiro pedido foi postado na [comunidade do R programadores no facebook](https://www.facebook.com/groups/1410023525939155), o autor gostaria de obter a ultima sexta feira do mês dado um vetor de datas. O outro pedido foi de um colega de doutorado,  ele gostaria de obter o retorno semanal de uma *Commodity*, começando a base de dados na terça-feira (retorno semanal de terça a terça). Entendendo que essa dúvida era uma recorrente. Fiz esse post. Nele você aprenderá:
1) Baixar dados a partir da função getSymbols (função já recorrente no blog).
2) Tratar as datas.
3) Fazer uma nova coluna de verdadeiro ou falso através de uma logica por uma data usando tidyverse.

## Filtrar toda terça da semana e obter o retorno semanal.
Carregando os pacotes.   
   
    library(PerformanceAnalytics)
    library(data.table)
    library(tidyverse)

#Filtrar todas as terças-feiras do mês e obter o retorno semanal
Baixando os dados, no caso iremos usar 8 ETFS: U.S. investment-grade bonds (BND), International, investment-grade bonds (IAGG), High-yield bonds (GHYG), U.S. equities (VTI),Developed equities (VXUS),Emerging market equities (VWO),Commodities (GSG),REITs (USRT).

    asset_names <- c("BND", "IAGG", "GHYG", "VTI", "VXUS", "VWO", "GSG", "USRT")
    from.date <- as.Date("01/01/17", format="%m/%d/%y")
    options("getSymbols.warning4.0"=FALSE)
    getSymbols(asset_names, from = from.date)
Juntando todos os xts em um dataframe. 

    prices.data <- data.frame(BND[,6], IAGG[,6], GHYG[,6], VTI[,6], VXUS[,6], VWO[,6], GSG[,6], USRT[,6])
O nome da linha é a data, a função abaixo faz com que a data se torno uma coluna.

    prices.data$date <- rownames(prices.data)
Extraindo o dia da semana das datas e criando uma coluna.
  
    prices.data$Week = weekdays(as.Date(prices.data$date))
Filtrando os dias da semana. Observação, meu R está em português, pode ser que o seu esteja em inglês.

    prices.data = prices.data %>% filter(Week == "terça-feira")
Pivot-longer. Eu expliquei como fazer o pivot wider e longer nesse [post](https://opencodecom.net/post/2021-04-22-como-fazer-reshape-no-r/).

    prices.data = prices.data  %>% pivot_longer(!date & !Week , names_to = "Assets", values_to = "Value")
Obtendo uma nova coluna o retorno da semana. 

    prices.data = prices.data %>% group_by(Assets) %>%  mutate(Return_week = ROC(Value))

#Fazer uma coluna com a ultima sexta feira do mês, a ultima semana do mês e o ultimo dia do mês

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

Obter 3 colunas: a resposta TRUE em LastWeekInMonth representa a ultima semana do mês, TRUE em LastFridayInMonth a ultima sexta do mês, e TRUE em LastDayInMonth representa o último dia do mês.

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

Se filtrar TRUE em LastFridayInMonth você obterá o df de todos as sextas-feiras do mês, e assim por diante.

    prices.data = prices.data %>% filter(LastFridayInMonth == "TRUE")


* Vale a pena entrar no grupo do facebook e do telegram do R programadores. Aprendi muito lá.
