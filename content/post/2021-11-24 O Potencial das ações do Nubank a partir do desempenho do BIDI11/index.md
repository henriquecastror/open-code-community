---

title: "O Potencial das ações do Nubank a partir do desempenho do BIDI11"

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

A fintech Nubank marcou seu IPO para dezembro de 2021. Esse fato está sendo muito 
discutido pelos profissionais das finanças, visto que o período de reserva das BDRs
foi aberto no dia 17 de novembro e será encerrado no dia 7 de 
dezembro, surge a pergunta: as ações do Nubank seria uma boa oportunidade de 
investimento?
Nesse contexto, fez-se um levantamento do comportamento dos ativos do Banco Inter (BIDI11), um 
concorrente que atua no mesmo mercado e com modelo de negócio semelhante ao Nubank. Para tanto, utilizou-se a linguagem de programação
Python e o banco de dados do Yahoo Finance.


A seguir, os pacotes que foram utilizados para o trabalho:

	#Abrir pacotes
	from pandas_datareader import data as dd
	import matplotlib as plt
	import numpy as ny
	import pandas as pd
	import math
	import statistics as st

  	#Carregando pacotes para definir estilo dos gráficos
	  %matplotlib inline
  	import matplotlib
  	matplotlib.style.use('ggplot')

Coletados dados do BIDI11 do Yahoo Finance.

	bidi11 = dd.DataReader('BIDI11.SA', data_source = 'yahoo', start='04/30/2018', end = '11/23/2021')
	df_int = bidi11["Adj Close"]

Visualizando as informações

	display(bidi11)

Preços da ação BIDI11.SA

 	plt.style.use('bmh')
	bidi11['Adj Close'].plot(figsize=(15, 10), linewidth=2.5)
	plt.pyplot.title("Preço de fechamento ajustado BIDI11", fontsize=25)
	plt.pyplot.ylabel('', fontsize=15)
	plt.pyplot.xlabel('', fontsize=15)

{{< figure src="cotacao.fechamento.jpeg" width="80%" >}} 

Observando o gráfico de preços das ações do Banco Inter, constata-se 
que o valor desses ativos aumentou consideravelmente até 2021. Percebe-se ainda que, 
entre o ínicio de 2021 até metade do mesmo ano, o preço das ações foi multiplicado
por seis. Entretando, após esse período houve uma queda considerável no valor dos ativos
do BIDI11, ocasionada principalmente pela política do Banco Central em elevar a taxa de juros para combater a inflação,
o que impacta negativamente empresas de base tecnológicas.

Volatilidade e retorno das ações. Calculando o retorno

	vetor = ny.array(df_int)
	retorno = (vetor[1:572]-vetor[0:571])/vetor[0:571]
	print(retorno)


Adicionando o vetor como coluna na base

	retorno = retorno.tolist()
	retorno.insert(0,0)
	bidi11['retorno'] = retorno
	print(bidi11)

Gráfico retorno

	plt.style.use('bmh')
	bidi11['retorno'].plot(figsize=(15, 10), linewidth=2.5)
	plt.pyplot.title("Retorno BIDI11", fontsize=25)
	plt.pyplot.ylabel(' ', fontsize=15)
	plt.pyplot.xlabel(' ', fontsize=15)

{{< figure src="retorno.jpeg" width="80%" >}} 
	
Volatilidade Histórica de Parkinson

	    parhv = ny.sqrt(572 / (4 * 22 * ny.log(2)) *
  		pd.DataFrame.rolling(ny.log(bidi11.loc[:, 'High'] / bidi11.loc[:, 'Low']) ** 2, window=22).sum())

Gráfico volatilidade
	
        plt.style.use('bmh')
        parhv.plot(figsize = (15,10), linewidth = 1.5);
        plt.pyplot.title("Volatilidade Histórica de Parkinson", fontsize=25)
        plt.pyplot.ylabel(' ', fontsize=15)
        plt.pyplot.xlabel('', fontsize=15)

{{< figure src="volatilidade.jpeg" width="80%" >}} 


Obsevando os dados de volatilidade e de retorno das ações em conjunto, pode-se chegar a
conclusões interessantes. Tem-se ue os períodos de maior volatilidade, também foram os que apresentaram maiores retornos.
Além disso, observou-se quem os momentos de maiores retornos positivos, foram seguidos pelos maiores retornos negativos.
Nesse sentido, percebe-se o comportamento especulativo dos investidores ao buscarem retornos de seus investimento no curto prazo. 


Gráfico de volume de negociações

	plt.style.use('bmh')
	bidi11['Volume'].plot(figsize=(15, 10), linewidth=2.5)
	plt.pyplot.title("Volume de Negociações BIDI11", fontsize=25)
	plt.pyplot.ylabel(' ', fontsize=15)
	plt.pyplot.xlabel(' ', fontsize=15)


{{< figure src="volume.jpeg" width="80%" >}} 

O maior volume de negociações observado ocorreu nem maio de 2020. É interessante comentar a redução da volatilidade 
do ativo após esse perído. Além disso, destaca-se que a ação vem apresentando um crescimento no volume das negociações,
mostrando um aumento do interesse dos investidores no Banco Inter.

Cenários

	media = st.mean(retorno)
	desvio = st.mean(retorno)
	otimista = media + 2*desvio/math.sqrt(867)
	pessimista = media - 2*desvio/math.sqrt(867)
	print(otimista, pessimista)


Buscando entender o retorno futuro dessa ação, calculou-se os cenários otimista e pessimista
para 95% de confiança com a estimativa do retorno médio. Assim, obteve-se o retorno médio esperado
de 0,28% em um cenário otimista e de 0,24% em um cenário pessimista. 

Considerando que o Banco Inter e o Nubank são empresas semelhantes, as ações do Nubank tem o 
potencial de apresentar retornos consideraveis aos seus investidores. Entretanto, deve-se considerar que no caso do BIDI11
as ações eram negociadas exclusivamente no mercado brasileiro, enquanto as ações do Nubank serão negociadas no 
Mercado Americano o que pode alterar o comportamento entre os dois ativos.

*Essa análise não é uma recomendação de compra*



{{% callout note %}}

**Please, cite this work:**

Ziermann , Matheus; Damasceno, Bruno  (2022), "O Potencial das a��es do Nubank a partir do desempenho do BIDI11 published at the "Open Code Community"", Mendeley Data, V1, doi: 10.17632/3cm6yts2vt.1

{{% /callout %}}




