 ---

title: "Exemplos de busca de tend�ncias do Google Trend"

categories: []

date: '2021-05-05T00:00:00Z'

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
- Google Trends

authors:
- HenriqueMartins
- GersonJunior


---
##  An�lise de risco e retorno de a��es usando o R

Nesse post iremos analisar a rela��o de risco e retorno de a��es usando o R. A teoria de finan�as prediz que quanto maior o risco de uma empresa, maior ser� seu retorno. Mas ser� que essa rela��o � verificada nos dados? Nesse post iremos aprender:
1) Baixar dados das empresas do pacote quantmod (pacote j� utilizado anteriomente)
2) Mudan�a de xts para dataframe
3) Realizar uma fun��o para completar NA's ('forward filling')
4) Plotar diferentes gr�ficos: Candle, Retorno hist�rico e Risco-Retorno.


Carregaremos as bibliotecas

    library(quantmod)
    library(PerformanceAnalytics)
    library(data.table)
    library(RColorBrewer)
    library(ggplot2)
    library(reshape2)

Quais os pap�is queremos analisar?

    tickers = c('EQTL3.SA', 'PETR4.SA', 'VALE3.SA', 'WEGE3.SA', 'EMBR3.SA',
                'CSNA3.SA', 'USIM5.SA','TOTS3.SA','ABEV3.SA','LREN3.SA', 
                'CIEL3.SA', 'RADL3.SA', 'RENT3.SA', 'MDIA3.SA', 
                'EZTC3.SA', 'FLRY3.SA', 'OIBR3.SA', 'CVCB3.SA')
    
    apple_stock = getSymbols.yahoo("AAPL", from = '2020-1-1', auto.assign = F)
    
    apple_stock = getSymbols.yahoo("AAPL", from = '2014-1-1', auto.assign = F)[,6]

Retornos mensais e anuais

    monthlyReturn(apple_stock)
    yearlyReturn(apple_stock)

Gr�fico de candle
    
    apple_stock = getSymbols.yahoo("AAPL", from = '2020-1-1', auto.assign = F)
    chartSeries(apple_stock)

{{< figure src="1.png" width="80%" >}}

Criando loop para retornar dados de v�rias a��es num s� data frame

    precos_carteira = NULL
    
    for(ticker in tickers){
      precos_carteira = cbind(precos_carteira, 
                              getSymbols.yahoo(ticker, from = '2014-1-1', auto.assign = F)[,6])
    }

    precos_carteira = data.frame(precos_carteira)

Modificando nome das colunas para ficar mais trabalh�vel
    colnames(precos_carteira) = c('EQTL3', 'PETR4', 'VALE3', 'WEGE3', 'EMBR3',
                                  'CSNA3', 'USIM5','TOTS3','ABEV3','LREN3', 
                                  'CIEL3', 'RADL3', 'RENT3', 'MDIA3', 
                                  'EZTC3', 'FLRY3', 'OIBR3', 'CVCB3'
    )

 Criando coluna com informa��o da  data

    precos_carteira$data = row.names(precos_carteira)
  
Fun��o para fazer o 'forward filling' e dessa forma evitar os NAs nos dias em que n�o houve negocia��o

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

Verificando se ainda temos NAs

    colSums(is.na(precos_carteira))
    colSums(is.na(nova_carteira))

Normalizar os pre�os dos pap�is

    normalizado = data.frame(lapply(nova_carteira, function(x) x/x[1]))
    normalizado$data = precos_carteira$data
    normalizado$data = as.Date(normalizado$data, format = "%Y-%m-%d")

Data prep para plotar v�rias a��es normalizadas num gr�fico s�                                

    d = melt(normalizado, id.vars = 'data')

    ggplot(d, aes(data, value, col=variable, group = variable)) +
      geom_line()

{{< figure src="2.png" width="80%" >}}

Plot de Retorno vs. Risco
Calculando retorno di�rio dos pap�is                                

    retornos_carteira = na.omit(ROC(nova_carteira))

Retorno consolidado da carteira (essa fun��o considera como default pesos iguais para cada papel)                            
    rendimento_carteira = Return.portfolio(retornos_carteira)

M�dia dos retornos di�rios                                

    meant = apply(retornos_carteira, 2, function(x) mean(x))

# Volatilidade ou desvio-padr�o dos retornos di�rios             

    sdev = apply(retornos_carteira, 2, function(x) sd(x))

Data frame contendo m�dia dos retornos di�rios e volatilidade para todos os pap�is da nossa carteira             
    tovar = data.frame(t(rbind(meant, sdev)))

    
    ggplot(tovar, aes(x=sdev, y=meant)) +
      geom_text(aes(label = rownames(tovar), colour = sdev, size = meant),check_overlap = F)+
      xlab('Volatilidade ou Desvio-Padr�o') + ylab('M�dia dos Retornos')

{{< figure src="3.png" width="80%" >}}
