---

title: "O Potencial das a��es do Nubank a partir do desempenho do BIDI11"

categories: []

# MUDE APENAS ANO DIA E MES PARA O DIA QUE VOCE NOS ENVIOU
date: '2021-11-24T00:00:00Z' 

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



A fintech Nubank marcou seu IPO para dezembro de 2021. Esse fato est� sendo muito 
discutido pelos profissionais das finan�as, visto que o per�odo de reserva das BDRs
foi aberto no dia 17 de novembro e ser� enserrado no dia 7 de 
dezembro, surge a pergunta: as a��es do Nubank seria uma boa oportunidade de 
investimento?
Nesse contexto, fez-se um levantamento do comportamento dos ativos do Banco Inter (BIDI11), um 
concorrente que atua no mesmo mercado e com modelo de neg�cio semelhante ao Nubank. Para tanto, utilizou-se a linguagem de programa��o
Python e o banco de dados do Yahoo Finance.

Pacotes
A seguir, os pacotes que foram utilizados para o trabalho:

	#Abrir pacotes
	from pandas_datareader import data as dd
	import matplotlib as plt
	import numpy as ny
	import pandas as pd
	import math
	import statistics as st

	#Carregando pacotes para definir estilo dos gr�ficos
	%matplotlib inline
	import matplotlib
	matplotlib.style.use('ggplot')

Coletados dados do BIDI11 do Yahoo Finance

	bidi11 = dd.DataReader('BIDI11.SA', data_source = 'yahoo', start='04/30/2018', end = '11/23/2021')
	df_int = bidi11["Adj Close"]

Visualizando as informa��es

	display(bidi11)

Pre�os da a��o BIDI11.SA

 	plt.style.use('bmh')
	bidi11['Adj Close'].plot(figsize=(15, 10), linewidth=2.5)
	plt.pyplot.title("Pre�o de fechamento ajustado BIDI11", fontsize=25)
	plt.pyplot.ylabel('', fontsize=15)
	plt.pyplot.xlabel('', fontsize=15)

{{< figure src="cotacao.fechamento.png" width="80%" >}} 

Observando o gr�fico de pre�os das a��es do Banco Inter, constata-se 
que o valor desses ativos aumentou consideravelmente at� 2021. Percebe-se ainda que, 
entre o �nicio de 2021 at� metade do mesmo ano, o pre�o das a��es foi multiplicado
por seis. Entretando, ap�s esse per�odo houve uma queda consider�vel no valor dos ativos
do BIDI11, ocasionada principalmente pela pol�tica do Banco Central em elevar a taxa de juros para combater a infla��o,
o que impacta negativamente empresas de base tecnol�gicas.

Volatilidade e retorno das a��es
Calcular retorno

	vetor = ny.array(df_int)
	retorno = (vetor[1:572]-vetor[0:571])/vetor[0:571]
	print(retorno)


Adicionando o vetor como coluna na base

	retorno = retorno.tolist()
	retorno.insert(0,0)
	bidi11['retorno'] = retorno
	print(bidi11)

Gr�fico retorno

	plt.style.use('bmh')
	bidi11['retorno'].plot(figsize=(15, 10), linewidth=2.5)
	plt.pyplot.title("Retorno BIDI11", fontsize=25)
	plt.pyplot.ylabel(' ', fontsize=15)
	plt.pyplot.xlabel(' ', fontsize=15)

{{< figure src="retorno.png" width="80%" >}} 
	
Volatilidade Hist�rica de Parkinson

	parhv = ny.sqrt(572 / (4 * 22 * ny.log(2)) *
  		pd.DataFrame.rolling(ny.log(bidi11.loc[:, 'High'] / bidi11.loc[:, 'Low']) ** 2, window=22).sum())

Gr�fico volatilidade
	plt.style.use('bmh')
	parhv.plot(figsize = (15,10), linewidth = 1.5);
	plt.pyplot.title("Volatilidade Hist�rica de Parkinson", fontsize=25)
	plt.pyplot.ylabel(' ', fontsize=15)
	plt.pyplot.xlabel('', fontsize=15)

{{< figure src="volatilidade.png" width="80%" >}} 


Obsevando os dados de volatilidade e de retorno das a��es em conjunto, pode-se chegar a
conclus�es interessantes. Tem-se ue os per�odos de maior volatilidade, tamb�m foram os que apresentaram maiores retornos.
Al�m disso, observou-se quem os momentos de maiores retornos positivos, foram seguidos pelos maiores retornos negativos.
Nesse sentido, percebe-se o comportamento especulativo dos investidores ao buscarem retornos de seus investimento no curto prazo. 


Gr�fico de volume de negocia��es

	plt.style.use('bmh')
	bidi11['Volume'].plot(figsize=(15, 10), linewidth=2.5)
	plt.pyplot.title("Volume de Negocia��es BIDI11", fontsize=25)
	plt.pyplot.ylabel(' ', fontsize=15)
	plt.pyplot.xlabel(' ', fontsize=15)


{{< figure src="volume.png" width="80%" >}} 

O maior volume de negocia��es observado ocorreu nem maio de 2020. � interessante comentar a redu��o da volatilidade 
do ativo ap�s esse per�do. Al�m disso, destaca-se que a a��o vem apresentando um crescimento no volume das negocia��es,
mostrando um aumento do interesse dos investidores no Banco Inter

Cen�rios

	media = st.mean(retorno)
	desvio = st.mean(retorno)
	otimista = media + 2*desvio/math.sqrt(867)
	pessimista = media - 2*desvio/math.sqrt(867)
	print(otimista, pessimista)


Buscando entender o retorno futuro dessa a��o, calculou-se os cen�rios otimista e pessimista
para 95% de confian�a com a estimativa do retorno m�dio. Assim, obteve-se o retorno m�dio esperado
de 0,28% em um cen�rio otimista e de 0,24% em um cen�rio pessimista. 

Considerando que o Banco Inter e o Nubank s�o empresas semelhantes, as a��es do Nubank tem o 
potencial de apresentar retornos consideraveis aos seus investidores. Entretanto, deve-se considerar que no caso do BIDI11
as a��es eram negociadas exclusivamente no mercado brasileiro, enquanto as a��es do Nubank ser�o negociadas no 
Mercado Americano o que pode alterar o comportamento entre os dois ativos.

*Essa an�lise n�o � uma recomenda��o de compra*