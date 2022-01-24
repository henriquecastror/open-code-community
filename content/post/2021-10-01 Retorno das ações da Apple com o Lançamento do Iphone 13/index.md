---

title: "Retorno das ações da Apple com o Lançamento do Iphone 13"

categories: []

# MUDE APENAS ANO DIA E MES PARA O DIA QUE VOCE NOS ENVIOU
date: '2021-10-01T00:00:00Z' 

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
- Retorno
- ggplot
- mercado financeiro 
- S&P500
- R
# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
- MatheusZiermann
- BrunoDamasceno


---

No último dia 14/09 a Apple apresentou os novos Iphone 13 ao mundo. 
Foram estimados os retornos esperados das ações da Apple desde o lançamento do Iphone 12 (20/10/2020) até o novo lançamento, através da aplicação de uma regressão simples no R. 
Como resultado, tínhamos que o Retorno Estimado para o dia, caso não houvesse o evento, seria de -0,86%. Entretanto o Retorno Efetivo das ações foi de -0,96%.

Pacotes
A seguir, os pacotes que foram utilizados para o trabalho:

    	library(quantmod)
    	library(ggplot2)
    	library(ggthemes)
    	library(moderndive)
    	library(dplyr)  

Variação 
Para o trabalho, considerou-se as Variações do Ativo da Apple e do índice S&P500 para o período entre 13 de Setembro de 2020 e 15 de Setembro de 2021. 
O objetivo é entender a relação das duas variáveis e como o lançamento do Iphone 13 afetou o retorno do ativo estudado.
    
    	#Cotação Apple
    	Apple = getSymbols.yahoo("AAPL", from = '2020-9-13',to = '2021-9-15', auto.assign = F)[,6]
    
    	#Cotação S&P
    	SP500 = getSymbols.yahoo("^GSPC", from = '2020-9-13',to = '2021-9-15', auto.assign = F)[,6]

Gráfico Apple
Primeiramente, estuda-se o gráfico do valor das ações da Apple. Nesse caso, percebe-se um crescimento considerável durante todo o período. 
Destaca-se que no mês de abril de 2021 o Ativo teve uma queda muito grande do seu valor, que foi revertida com uma forte alta a partir de junho de 2021

    	plot(Apple)

{{< figure src="Apple.png" width="80%" >}} 

Gráfico S&P500
Agora, analisa-se o gráfico do índice S&P500. Contata-se que o índice teve uma trajetória consideravelmente mais estável que a variável anterior. As semelhanças com o gráfico anterior são a tendência de alta que foi mantida e uma pequena queda no final do tempo analisado.
É importante comentar que os ativos da Apple têm um grande peso no calculo do S&P500 (fonte: https://www.suno.com.br/noticias/sp-500-cai-cpi-eua-iphone-apple-aapl34/)

    	plot(SP500)

{{< figure src="S&P500.png" width="80%" >}} 

Retorno
Objetivando o desenvolvimento das demais análises, calculou-se os retornos das variáveis estudadas.
    
    	#Calculando Retorno Apple
    	Ret_Apple = dailyReturn(Apple) * 100
    
    	#Calculando Retorno S&P500
    	Ret_SP500 = dailyReturn(SP500) * 100

Base de dados
Ainda, foram necessários ajustes na base de dados para o desenvolvimento do estudo. 
Em um primeiro momento, transformou-se as bases de dados em data frame para ter uma melhor organização ao editá-las. 
Depois, foi necessário criar uma coluna de datas para fazer a junção dos dados frames utilizados. 
Por fim, na nova base criada após a junção das outras duas, as colunas e as linhas foram renomeadas.
    
    	#Transformar em data.frame
    	Ret_SP500=data.frame(Ret_SP500)
    	Ret_Apple = data.frame(Ret_Apple)
    
    	#Criar coluna de datas
    	Ret_SP500$Dias = as.Date(rownames(Ret_SP500))
    	Ret_Apple$Dias = as.Date(rownames(Ret_Apple))
    
    	#Juntar tabelas
    	Principal = left_join(Ret_Apple, Ret_SP500, by = "Dias")
    
    	#Renomear coluna
    	names(Principal)[1]<-paste("Apple")
    	names(Principal)[3]<-paste("SP500")
    
    	#Renomear linhas
    	rownames(Principal) = Principal$Dias

Estimativa
Foi calculada uma regressão simples para estimar os retornos dos ativos da Apple a partir do S&P500. Utilizou-se o pacote Moderndive.
    
    	#Reg
    	Reg = lm(Apple~SP500, data = Principal)
    	Reg_Points = get_regression_points(Reg)
    
    	#Utilizar a coluna ID como coluna de Datas
    	Reg_Points$ID = Principal$Dias

Gráficos Comparativos
Utilizando ggplot2, foram feitos os gráficos comparativos.

    	ggplot(data=Reg_Points)+geom_line(mapping = aes(group = 1, x=ID, y = Apple_hat, color = "Retorno_Estimado"))+
     	geom_point(mapping = aes(group = 1, x=ID, y = Apple, color ="Retorno_Efetivo"))+
      	theme_bw() +
      	labs(x = "Data", y = "Retorno",  title = 'Retorno Apple')+
      	theme(axis.text.x = element_text(angle = 90), plot.title = element_text(hjust = 0.5))+
      	scale_colour_manual("Legenda",breaks = c("Retorno_Estimado", "Retorno_Efetivo"), values = c('black', 'red'))
    
{{< figure src="Ret_Est.Ret_Efe.png" width="80%" >}}
    
    	  ggplot(data=Reg_Points)+geom_line(mapping = aes(group = 1, x=ID, y =Apple, color = "Apple"))+
      	geom_point(mapping = aes(group = 1, x=ID, y = SP500, color ="S&P500"))+
      	theme_bw() +
      	labs(x = "Data", y = "Retorno",  title = 'Retorno Apple X S&P500')+
      	theme(axis.text.x = element_text(angle = 90), plot.title = element_text(hjust = 0.5))+
      	scale_colour_manual("Legenda",breaks = c("Apple", "S&P500"), values = c('black', 'blue'))


{{< figure src="AppleXS&P500.png" width="80%" >}}

Retorno com evento
Também, foi calculado o retorno das ações da Apple na data específica do evento estudado.

    	#Definindo Janela do Evento
    	event.window = Principal[nrow(Principal), c("Apple","SP500")]
    	event.window
    	event.window$SP500
    
    	#Calculo do Retorno Previsto 
    	event.window$Pred.Ret = summary(Reg)$coefficients[1] + 
    	summary(Reg)$coefficients[2] * event.window$SP500
    
    	#Calculando o Retorno Anormal
    	event.window$Ab.Ret = event.window$Apple - event.window$Pred.Ret
    	event.window$tStat = event.window$Ab.Ret / summary(Reg)$sigma
    	event.window$pval = 2 * (1-pt (abs(event.window$tStat), df=nrow(Principal) - 2))
    	options(digits = 3)
    	event.window

Resultados:
Podemos concluir, a partir da análise do gráfico, que o ativo e o índice estudados apresentam tendências de longo prazo próximas, mas quando analisamos o curto prazo, constatou-se trajetórias distintas. 
No caso do dia do lançamento do Iphone 13, estimou-se que, sem o evento, o retorno esperado do dia seria de -0,86%, mas considerando o evento o retorno efetivo das ações foi de -0,96%.
Entretanto, esse é um fenômeno que vem ocorrendo nos lançamentos dos últimos anos. É verificado um momento de alta antes dos períodos de lançamento e um queda nas datas próximas ao evento, seguindo novamente com a elevação do preço das ações.
	
	
	
	

{{% callout note %}}

**Please, cite this work:**

Ziermann , Matheus; Damasceno, Bruno  (2022), "Retorno das a��es da Apple com o Lan�amento do Iphone 13 published at "Open Code community"", Mendeley Data, V1, doi: 10.17632/ycrmpsbrtm.1	

{{% /callout %}}

