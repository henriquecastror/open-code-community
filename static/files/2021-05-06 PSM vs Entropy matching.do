* Esse � um post r�pido para comparar os resultados de duas t�cnicas de matching diferentes: Propensity-score matching (PSM) e Entropy matching.

* Uma explica��o mais apurada das t�cnicas est� fora do escopo daqui, ent�o se voc� est� interessado(a) nos detalhes, recomendo a literatura a seguir.

* Mas de uma forma simples, voc� pode pensar da seguinte forma:

* Propensity-score matching faz o pareamento entre unidades do grupo de controle e tratamento com base na propens�o de se receber o tratamento dado um conjunto de covariates. 
* Propensity-score � simplesmente um n�mero que indica a probabilidade de se receber o tratamento. 
* Assim o pareamento com base em propensity-score � simplesmente o pareamento usando essa probabilidade como crit�rio fundamental.

* Entropy matching, por sua vez, faz o pareamento com base em um ou mais momentos da distribui��o dos covariates. 
* Basicamente, voc� usa como crit�rio de pareamento: a m�dia (1� momento), vari�ncia (2� momento), skewness (3� momento)... 
* O resultado � uma sub-amostra rebalanceada tal que os momentos dos covariates dos grupos de controle e tratamento s�o semelhantes.

* De novo, essa � uma explica��o curta, apenas para entendermos o b�sico das diferen�as entre os dois m�todos.

* Vamos agora � estima��o. Dessa vez, vou utilizar o Stata. Esse c�digo � amplamente baseado em PAPER EBALANCE.

* Instale os pacotes "psmatch2" e "ebalance" e carregue a seguinte base:

ssc install ebalance, all replace
use cps1re74.dta, clear
		
* Vamos come�ar analisando os covariates "age", "black" e "educ" no grupo de controle e no de tratamento. A vari�vel de tratamento � "treat". 
* Ao todo, temos 185 obs. de tratamento e 15,992 observa��es de controle.

qui estpost tabstat age black educ , by(treat) c(s) s(me v sk n) nototal
esttab . 	,varwidth(20) cells("mean(fmt(3)) variance(fmt(3)) skewness(fmt(3)) count(fmt(0))") noobs nonumber compress 

* Claramente, os dois grupos s�o diferentes entre si. O grupo de tratamento � 1) mais jovem, 2) majoritariamente black, e 3) menos escolarizados que o grupo de controle.
* Note tamb�m que a vari�ncia e skewness das duas sub-amostras s�o consideravelmente diferentes.
* Se us�ssemos essas duas sub-amostras em alguma an�lise econom�trica sem um pr�-processamento para torn�-las compar�veis, ter�amos provavelmente coeficientes viesados por selection bias.		
* Assim, � importante executarmos algum m�todo de pareamento para que eventuais an�lises futuras n�o sofram desse vi�s.

	
* Vamos come�ar pelo PSM usando o pacote psmatch2. Vamos usar o pareamento mais simples, isto �, sem usar nenhuma fun��o adicional.
* H� v�rias fun��es e crit�rios distintos que voc� pode utilizar (e.g., definindo commom support, diferentes estimadores, etc.) que podem melhorar seu pareamento.
* Mas, para fins desse exerc�cio, vamos tomar o caminho mais simples e executar pareamento via Kernel, usando tipo default que � Epanechnikov kernel.
* Fa�a o pareamento da seguinte forma:
		
psmatch2 treat age black educ , kernel

* Ap�s o pareamento, note que diversas vari�veis foram criadas com um "_" no in�cio de seus nomes. 
* A que mais nos importa � _weight que � o peso para rebalanceamento de cada observa��o. 
* Veja que o peso de cada observa��o varia entre [0,1]. Basicamente, quanto maior o peso, maior a similaridade entre a observa��o do grupo de tratamento e a de controle. 
* Pesos baixos indicam que a observa��o de controle � diferente da observa��o do grupo de tratamento.
* Perceba tamb�m que as observa��es do grupo de tratamento tem peso 1, enquanto as demais (i.e., as de controle) tem pesos menores que 1.

bys treat: sum _weight , d

* Podemos agora calcular a m�dia, vari�ncia e skewness das amostras pareadas.

qui estpost tabstat age black educ [aweight = _weight], by(treat) c(s) s(me v sk n) nototal
esttab . 	,varwidth(20) cells("mean(fmt(3)) variance(fmt(3)) skewness(fmt(3)) count(fmt(0))") noobs  nonumber compress 

* Perceba que, de acordo com esse pareamento, os tr�s momentos n�o parecem semelhantes. 
* N�o sabemos se as diferen�as s�o estatisticamente significativas, mas visualmente, temos a impress�o que sim.
* Podemos fazer um teste da diferen�a entre as m�dias dos dois grupos via OLS da seguinte forma:

reg age   treat [aweight = _weight]
reg black treat [aweight = _weight]
reg educ  treat [aweight = _weight]

* Perceba que todos os coeficientes das vari�veis independentes s�o estatisticamente diferentes de zero, ou seja, as diferen�as entre as m�dias s�o significativas.
* Isso seria um indicativo que esse pareamento n�o cumpriu plenamente seu prop�sito de deixar as sub-amostras compar�veis.
* � claro que fizemos o pareamento mais simples e eventualmente poder�amos melhor�-lo. No entanto, nesse momento, temos a sugest�o de que as sub-amostras n�o foram bem pareadas.



********************************************************************************
* Vamos agora rodar o pareamento via entropia. Vamos tamb�m usar a vers�o de pareamento mais simples. Vamos apenas solicitar que os tr�s momentos sejam usados como crit�rio. 
				
ebalance treat age black educ, targets(3)

* O pr�prio output da linha anterior mostra os momentos da distribui��o dos dois grupos, mas se voc� quiser, pode rodar novamente as seguintes linhas:
qui estpost tabstat age black educ [aweight = _webal], by(treat) c(s) s(me v sk n) nototal
esttab . 	,varwidth(20) cells("mean(fmt(3)) variance(fmt(3)) skewness(fmt(3)) count(fmt(0))") noobs  nonumber compress 


* Vamos fazer o mesmo teste de averigua��o de diferen�a de m�dias usando OLS.

reg age   treat [aweight = _webal]
reg black treat [aweight = _webal]
reg educ  treat [aweight = _webal]	

* Note agora que os tr�s coeficientes das vari�veis independentes n�o s�o significativos. 
* Isso indica que as m�dias dos covariates entre os grupos n�o s�o estatisticamente diferentes entre si.


********************************************************************************
* Conclus�o

* Ao que parece, o entropy matching � um m�todo que leva a resultados mais apurados de pareamento.
* � claro, esse foi um exerc�cio simples. Mas para fins desse post, essa � a conclus�o que conseguimos ter.

* Thanks for passing by.




