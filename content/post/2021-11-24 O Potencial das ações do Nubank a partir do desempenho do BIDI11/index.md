---
 
title: "O Potencial das aÃ§Ãµes do Nubank a partir do desempenho do BIDI11"

categories: []

# MUDE APENAS ANO DIA E MES PARA O DIA QUE VOCE NOS ENVIOU
date: '2021-11-23T00:00:00Z' 

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

A fintech Nubank marcou seu IPO para dezembro de 2021. Esse fato estÃ¡ sendo muito 
discutido pelos profissionais das finanÃ§as, visto que o perÃ­odo de reserva das BDRs
foi aberto no dia 17 de novembro e serÃ¡ encerrado no dia 7 de 
dezembro, surge a pergunta: as aÃ§Ãµes do Nubank seria uma boa oportunidade de 
investimento?
Nesse contexto, fez-se um levantamento do comportamento dos ativos do Banco Inter (BIDI11), um 
concorrente que atua no mesmo mercado e com modelo de negÃ³cio semelhante ao Nubank. Para tanto, utilizou-se a linguagem de programaÃ§Ã£o
Python e o banco de dados do Yahoo Finance.


A seguir, os pacotes que foram utilizados para o trabalho:

	#Abrir pacotes
	from pandas_datareader import data as dd
	import matplotlib as plt
	import numpy as ny
	import pandas as pd
	import math
	import statistics as st

  	#Carregando pacotes para definir estilo dos grÃ¡ficos
	  %matplotlib inline
  	import matplotlib
  	matplotlib.style.use('ggplot')

Coletados dados do BIDI11 do Yahoo Finance.

	bidi11 = dd.DataReader('BIDI11.SA', data_source = 'yahoo', start='04/30/2018', end = '11/23/2021')
	df_int = bidi11["Adj Close"]

Visualizando as informaÃ§Ãµes

	display(bidi11)

PreÃ§os da aÃ§Ã£o BIDI11.SA

 	plt.style.use('bmh')
	bidi11['Adj Close'].plot(figsize=(15, 10), linewidth=2.5)
	plt.pyplot.title("PreÃ§o de fechamento ajustado BIDI11", fontsize=25)
	plt.pyplot.ylabel('', fontsize=15)
	plt.pyplot.xlabel('', fontsize=15)

{{< figure src="cotacao.fechamento.jpeg" width="80%" >}} 

Observando o grÃ¡fico de preÃ§os das aÃ§Ãµes do Banco Inter, constata-se 
que o valor desses ativos aumentou consideravelmente atÃ© 2021. Percebe-se ainda que, 
entre o Ã­nicio de 2021 atÃ© metade do mesmo ano, o preÃ§o das aÃ§Ãµes foi multiplicado
por seis. Entretando, apÃ³s esse perÃ­odo houve uma queda considerÃ¡vel no valor dos ativos
do BIDI11, ocasionada principalmente pela polÃ­tica do Banco Central em elevar a taxa de juros para combater a inflaÃ§Ã£o,
o que impacta negativamente empresas de base tecnolÃ³gicas.

Volatilidade e retorno das aÃ§Ãµes. Calculando o retorno

	vetor = ny.array(df_int)
	retorno = (vetor[1:572]-vetor[0:571])/vetor[0:571]
	print(retorno)


Adicionando o vetor como coluna na base

	retorno = retorno.tolist()
	retorno.insert(0,0)
	bidi11['retorno'] = retorno
	print(bidi11)

GrÃ¡fico retorno

	plt.style.use('bmh')
	bidi11['retorno'].plot(figsize=(15, 10), linewidth=2.5)
	plt.pyplot.title("Retorno BIDI11", fontsize=25)
	plt.pyplot.ylabel(' ', fontsize=15)
	plt.pyplot.xlabel(' ', fontsize=15)

{{< figure src="retorno.jpeg" width="80%" >}} 
	
Volatilidade HistÃ³rica de Parkinson

	    parhv = ny.sqrt(572 / (4 * 22 * ny.log(2)) *
  		pd.DataFrame.rolling(ny.log(bidi11.loc[:, 'High'] / bidi11.loc[:, 'Low']) ** 2, window=22).sum())

GrÃ¡fico volatilidade
	
        plt.style.use('bmh')
        parhv.plot(figsize = (15,10), linewidth = 1.5);
        plt.pyplot.title("Volatilidade HistÃ³rica de Parkinson", fontsize=25)
        plt.pyplot.ylabel(' ', fontsize=15)
        plt.pyplot.xlabel('', fontsize=15)

{{< figure src="volatilidade.jpeg" width="80%" >}} 


Obsevando os dados de volatilidade e de retorno das aÃ§Ãµes em conjunto, pode-se chegar a
conclusÃµes interessantes. Tem-se ue os perÃ­odos de maior volatilidade, tambÃ©m foram os que apresentaram maiores retornos.
AlÃ©m disso, observou-se quem os momentos de maiores retornos positivos, foram seguidos pelos maiores retornos negativos.
Nesse sentido, percebe-se o comportamento especulativo dos investidores ao buscarem retornos de seus investimento no curto prazo. 


GrÃ¡fico de volume de negociaÃ§Ãµes

	plt.style.use('bmh')
	bidi11['Volume'].plot(figsize=(15, 10), linewidth=2.5)
	plt.pyplot.title("Volume de NegociaÃ§Ãµes BIDI11", fontsize=25)
	plt.pyplot.ylabel(' ', fontsize=15)
	plt.pyplot.xlabel(' ', fontsize=15)


{{< figure src="volume.jpeg" width="80%" >}} 

O maior volume de negociaÃ§Ãµes observado ocorreu nem maio de 2020. Ã‰ interessante comentar a reduÃ§Ã£o da volatilidade 
do ativo apÃ³s esse perÃ­do. AlÃ©m disso, destaca-se que a aÃ§Ã£o vem apresentando um crescimento no volume das negociaÃ§Ãµes,
mostrando um aumento do interesse dos investidores no Banco Inter.

CenÃ¡rios

	media = st.mean(retorno)
	desvio = st.mean(retorno)
	otimista = media + 2*desvio/math.sqrt(867)
	pessimista = media - 2*desvio/math.sqrt(867)
	print(otimista, pessimista)


Buscando entender o retorno futuro dessa aÃ§Ã£o, calculou-se os cenÃ¡rios otimista e pessimista
para 95% de confianÃ§a com a estimativa do retorno mÃ©dio. Assim, obteve-se o retorno mÃ©dio esperado
de 0,28% em um cenÃ¡rio otimista e de 0,24% em um cenÃ¡rio pessimista. 

Considerando que o Banco Inter e o Nubank sÃ£o empresas semelhantes, as aÃ§Ãµes do Nubank tem o 
potencial de apresentar retornos consideraveis aos seus investidores. Entretanto, deve-se considerar que no caso do BIDI11
as aÃ§Ãµes eram negociadas exclusivamente no mercado brasileiro, enquanto as aÃ§Ãµes do Nubank serÃ£o negociadas no 
Mercado Americano o que pode alterar o comportamento entre os dois ativos.

*Essa anÃ¡lise nÃ£o Ã© uma recomendaÃ§Ã£o de compra*



{{% callout note %}}

**Please, cite this work:**

Ziermann , Matheus; Damasceno, Bruno  (2022), "O Potencial das ações do Nubank a partir do desempenho do BIDI11 published at the "Open Code Community"", Mendeley Data, V1, doi: 10.17632/3cm6yts2vt.1

{{% /callout %}}




