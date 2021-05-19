---
title: "Análise de risco e retorno de ações usando o R"

categories: []

date: '2021-05-17T00:00:00Z' 

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
- Risco
- Retorno

authors:
- VictorGomes


---
##  Análise de risco e retorno de ações usando o R

Nesse post iremos analisar a relação de risco e retorno de ações usando o R. A teoria de finanças prediz que quanto maior o risco de uma empresa, maior será seu retorno. Mas será que essa relação é verificada nos dados? 
Nesse post iremos aprender:
1) Baixar dados das empresas do pacote quantmod (pacote já utilizado anteriomente).
2) Mudança de xts para dataframe.
3) Realizar uma função para completar NA's ('forward filling').
4) Plotar diferentes gráficos: Candle, Retorno histórico e Risco-Retorno.


Carregaremos as bibliotecas.

    library(quantmod)
    library(PerformanceAnalytics)
    library(data.table)
    library(RColorBrewer)
    library(ggplot2)
    library(reshape2)

Quais os papéis queremos analisar?

    tickers = c('EQTL3.SA', 'PETR4.SA', 'VALE3.SA', 'WEGE3.SA', 'EMBR3.SA',
                'CSNA3.SA', 'USIM5.SA','TOTS3.SA','ABEV3.SA','LREN3.SA', 
                'CIEL3.SA', 'RADL3.SA', 'RENT3.SA', 'MDIA3.SA', 
                'EZTC3.SA', 'FLRY3.SA', 'OIBR3.SA', 'CVCB3.SA')
    
    apple_stock = getSymbols.yahoo("AAPL", from = '2020-1-1', auto.assign = F)
    
    apple_stock = getSymbols.yahoo("AAPL", from = '2014-1-1', auto.assign = F)[,6]

Retornos mensais e anuais.

    monthlyReturn(apple_stock)
    yearlyReturn(apple_stock)

Gráfico de candle.
    
    apple_stock = getSymbols.yahoo("AAPL", from = '2020-1-1', auto.assign = F)
    chartSeries(apple_stock)

{{< figure src="1.png" width="80%" >}}

Criando loop para retornar dados de várias ações num só dataframe.

    precos_carteira = NULL
    
    for(ticker in tickers){
      precos_carteira = cbind(precos_carteira, 
                              getSymbols.yahoo(ticker, from = '2014-1-1', auto.assign = F)[,6])
    }

    precos_carteira = data.frame(precos_carteira)

Modificando nome das colunas para ficar mais trabalhável.
    
    colnames(precos_carteira) = c('EQTL3', 'PETR4', 'VALE3', 'WEGE3', 'EMBR3',
                                  'CSNA3', 'USIM5','TOTS3','ABEV3','LREN3', 
                                  'CIEL3', 'RADL3', 'RENT3', 'MDIA3', 
                                  'EZTC3', 'FLRY3', 'OIBR3', 'CVCB3'
    )

 Criando coluna com informação da  data.

    precos_carteira$data = row.names(precos_carteira)
  
Função para fazer o 'forward filling' e dessa forma evitar os NAs nos dias em que não houve negociação.

    replaceNaWithLatest = function( dfIn, nameColsNa = names(dfIn) ){ 
      dtTest <- data.table(dfIn) 
      invisible(lapply(nameColsNa, 
                       function(nameColNa){ 
                         setnames(dtTest, nameColNa, "colNa") 
                         dtTest[, segment := cumsum(!is.na(colNa))] 
                         dtTest[, colNa := colNa[1], by = "segment"] 
                         dtTest[, segment := NULL] 
                         setnames(dtTest, "colNa", nameColNa) 
                       })) 
      return(dtTest)
    }
    
    nova_carteira = replaceNaWithLatest(data.frame(precos_carteira[,-19]))
    
    
    nova_carteira = data.frame(nova_carteira, row.names = precos_carteira$data)

Verificando se ainda temos NA's.

    colSums(is.na(precos_carteira))
    colSums(is.na(nova_carteira))

Normalizar os preços dos papéis

    normalizado = data.frame(lapply(nova_carteira, function(x) x/x[1]))
    normalizado$data = precos_carteira$data
    normalizado$data = as.Date(normalizado$data, format = "%Y-%m-%d")

Data prep para plotar várias ações normalizadas em apenas um gráfico.                              

    d = melt(normalizado, id.vars = 'data')

    ggplot(d, aes(data, value, col=variable, group = variable)) +
      geom_line()

{{< figure src="2.png" width="80%" >}}

##Plot de Retorno vs. Risco
Calculando retorno diário dos papéis  .                              

    retornos_carteira = na.omit(ROC(nova_carteira))

Retorno consolidado da carteira (essa função considera como default pesos iguais para cada papel)    .                        
    
    rendimento_carteira = Return.portfolio(retornos_carteira)

Média dos retornos diários.                               

    meant = apply(retornos_carteira, 2, function(x) mean(x))

Volatilidade ou desvio-padrão dos retornos diários.             

    sdev = apply(retornos_carteira, 2, function(x) sd(x))

Data frame contendo média dos retornos diários e volatilidade para todos os papéis da nossa carteira    .         
   
    tovar = data.frame(t(rbind(meant, sdev)))

    
    ggplot(tovar, aes(x=sdev, y=meant)) +
      geom_text(aes(label = rownames(tovar), colour = sdev, size = meant),check_overlap = F)+
      xlab('Volatilidade ou Desvio-Padrão') + ylab('Média dos Retornos')

{{< figure src="3.png" width="80%" >}}

Exemplo de análise: podemos observar que RADL3 apresentou um retorno médio maior com uma vol menor que CSNA3. Logicamente, apresentando uma melhor relação risco-retorno que CSNA3. 
