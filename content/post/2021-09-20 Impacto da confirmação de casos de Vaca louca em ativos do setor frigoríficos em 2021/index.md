---

title: "Impacto da confirmação de casos de Vaca louca em ativos do setor frigoríficos em 2021"

categories: []

# MUDE APENAS ANO DIA E MES PARA O DIA QUE VOCE NOS ENVIOU
date: '2021-09-20T00:00:00Z' 

draft: no

featured: no

gallery_item: null

image:
  caption: 
  focal_point: 
  preview_only: 

projects: []

subtitle: null

summary: null

# DIGITE NA LISTA ABAIXO OS TRACKS DO SEU CODIGO
tags: 
- Open Data
- R
- Retorno
- Finanças
- Agrobusiness

# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
- MatheusZiermann
- BrunoDamasceno


---

No dia 1 de setembro de 2021 o Ministério da Agricultura divulgou a suspeita de dois casos de Encefalopatia Espongiforme, 
enfermidade conhecida como doença da vaca louca, fato confirmado no dia 4 de Setembro de 2021. 
Este post tem o objetivo de compreender os efeitos dessa confirmação em ativos de quatro empresas diferentes: 
1)JBS (JBSS3); 2)Marfrig (MLFG3); 3)BRF (BRFS3); 4)Minerva Foods (BEEF3). 
Como resultado, o efeito da doença foi menor do que o esperado para o período analisado, 
com esses ativos terminando o período acima do rendimento da IBOVESPA. 
Destaca-se que a janela do evento foi do dia 30 de agosto ao dia 8 de setembro.

## Pacotes

A seguir são apresentados os pacotes utilizados para a qpesquisa 
		
    	library(quantmod)
    	library(PerformanceAnalytics)
    	library(data.table)
    	library(ggplot2)
    	library(dplyr)
    	library(gridExtra)
    	library(knitr) 

## Retorno do Ibovespa

Primeiramente, analisa-se o retorno do IBOVESPA. Destaca-se que o índice teve um 
comportamento com variações pouco significativas durante o período, com exceção do dia 8 de setembro, 
o que ocorreu, provavelmente, devido à instabilidade política brasileira.  
	
    		BenchMarks = '^BVSP'
    	Ibov= NULL
    	for (benckmark in BenchMarks) {
      	Ibov = cbind(Ibov,
                   getSymbols.yahoo(BenchMarks, from = '2021-8-30', to = '2021-9-9', auto.assign = F)[,6])
    	}
    
    	colnames(Ibov) = c('Ibov')
    	Ret_Ibov = dailyReturn(Ibov) * 100
    	plot(Ret_Ibov)

{{< figure src="RetIbov.png" width="80%" >}} 

## Retorno dos Ativos 

Agora, calcula-se o retorno das ações das empresas: 1) JBS (JBSS3); 2) Marfrig (MLFG3); 3)BRF (BRFS3); 4) Minerva Foods (BEEF3), durante a janela do evento.

    	MRFG3 = getSymbols.yahoo("MRFG3.SA", from = '2021-8-30', to = '2021-9-9', auto.assign = F)[,6]
    	BEEF3 = getSymbols.yahoo("BEEF3.SA", from = '2021-8-30', to = '2021-9-9', auto.assign = F)[,6]
    	JBSS3 = getSymbols.yahoo("JBSS3.SA", from = '2021-8-30', to = '2021-9-9', auto.assign = F)[,6]
    	BRFS3 = getSymbols.yahoo("BRFS3.SA", from = '2021-8-30', to = '2021-9-9', auto.assign = F)[,6]
    
    	Ret_MRFG3 = dailyReturn(MRFG3) * 100
    	
    	Ret_BEEF3 = dailyReturn(BEEF3) * 100
    	
    	Ret_JBSS3 = dailyReturn(JBSS3) * 100
    	
    	Ret_BRFS3 = dailyReturn(BRFS3) * 100


## Comparação IBOVESPA e Ativos

Agora, para fazer a comparação entre as ações das empresas e o IBOVESPA, deve-se organizar as bases de dados em Data Frames. Além disso, cria-se uma variável com datas específicas. Ainda, disponibiliza-se as tabelas de retornos dos ativos.

    	Dias_semana = format(as.Date(c('2021-08-30', '2021-08-31', '2021-09-01',
                                   '2021-09-02', '2021-09-03', '2021-09-06', '2021-09-08'), format="%Y-%m-%d"))
    
    	Ret_BEEF3 = as.data.frame(Ret_BEEF3)
    	Ret_BRFS3 = as.data.frame(Ret_BRFS3)
    	Ret_Ibov = as.data.frame(Ret_Ibov)
    	Ret_JBSS3 = as.data.frame(Ret_JBSS3)
    	Ret_MRFG3 = as.data.frame(Ret_MRFG3)
    
    	Ret_BEEF3$Data = Dias_semana
    	Ret_BRFS3$Data = Dias_semana
    	Ret_Carteira$Data = Dias_semana
    	Ret_Comparado$Data = Dias_semana
    	Ret_Ibov$Data = Dias_semana
    	Ret_JBSS3$Data = Dias_semana
    	Ret_MRFG3$Data = Dias_semana

## Gráfico

Por fim, utiliza-se o pacote GGplot2 para o desenvolvimento de gráficos comparativos.


    	Graf_BEEF3=ggplot() + 
     	 	geom_line(data = Ret_BEEF3,aes(group = 1, Data, daily.returns, colour = "Ret_BEEF3"), size = 0.5)+
      		geom_line(data = Ret_Ibov, aes(Data, daily.returns, group = 1, colour = "Ret_Ibov"), size = 0.5)+
      		theme_bw() +
      		labs(x = "Data", y = "Retorno",  title = 'Retorno BEEF3')+
      		theme(axis.text.x = element_text(angle = 90), plot.title = element_text(hjust = 0.5))+
      		scale_colour_manual("",breaks = c("Ret_BEEF3", "Ret_Ibov"),values = c("red", "blue"))
    
    	Graf_BRFS3 = ggplot() + 
     		geom_line(data = Ret_BRFS3, aes(group = 1, Data, daily.returns, colour = "Ret_BRFS3"), size = 0.5)+
     		geom_line(data = Ret_Ibov, aes(Data, daily.returns, group = 1, colour = "Ret_Ibov"), size = 0.5)+
      		theme_bw()+
      		labs(x = "Data", y = "Retorno",  title = 'Retorno BRFS3')+
      		theme(axis.text.x = element_text(angle = 90), plot.title = element_text(hjust = 0.5))+
      		scale_colour_manual("",breaks = c("Ret_BRFS3", "Ret_Ibov"),values = c("red", "blue"))
    
    	Graf_JBSS3 = ggplot() + 
      		geom_line(data = Ret_JBSS3, aes(group = 1, Data, daily.returns, colour = "Ret_JBSS3"), size = 0.5)+
      		geom_line(data = Ret_Ibov, aes(Data, daily.returns, group = 1, colour = "Ret_Ibov"), size = 0.5)+
      		labs(x = "Data", y = "Retorno",  title = 'Retorno JBSS3')+
      		theme_bw()+
      		scale_colour_manual("", breaks = c("Ret_JBSS3", "Ret_Ibov"),values = c("red", "blue"))+
      		theme(axis.text.x = element_text(angle = 90), plot.title = element_text(hjust = 0.5))
    
    	Graf_MRFG3 = ggplot() + 
      		geom_line(data = Ret_MRFG3, aes(group = 1, Data, daily.returns, colour = "Ret_MRFG3"), size = 0.5)+
      		geom_line(data = Ret_Ibov, aes(Data, daily.returns, group = 1, colour = "Ret_Ibov"), size = 0.5)+
      		labs(x = "Data", y = "Retorno",  title = 'Retorno MRFG3')+
      		theme_bw()+
      		scale_colour_manual("",breaks = c("Ret_MRFG3", "Ret_Ibov"),values = c("red", "blue"))+
      		theme(axis.text.x = element_text(angle = 90), plot.title = element_text(hjust = 0.5))
    
    	grid.arrange(Graf_MRFG3, Graf_BEEF3, Graf_BRFS3, Graf_JBSS3, ncol=2, nrow=2)

{{< figure src="RetAtivosIbov.png" width="80%" >}} 



