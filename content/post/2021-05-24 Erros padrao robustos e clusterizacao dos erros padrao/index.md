---

title: "Erros padrãƒo robustos e clusterizaã‡ãƒo dos erros padrãƒ"

categories: []

# MUDE APENAS ANO DIA E MES PARA O DIA QUE VOCE NOS ENVIOU
date: '2021-05-24T00:00:00Z' 

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

# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
- LucasSchwarz


---

Nesse breve post apresento uma rÃ¡pida discussÃ£o sobre erros robustos e clusterizaÃ§Ã£o dos erros padrÃ£o, alÃ©m de apresentar como Ã© possÃ­vel implementar essas soluÃ§Ãµes em regressÃµes no R.   O uso dessas diferentes estratÃ©gias para computar os erros padrÃ£o Ã© uma importante decisÃ£o de desenho de pesquisa frequentemente discutida por avaliadores em journals ou em congressos e, ao menos pela minha breve experiÃªncia, Ã© um tratamento usualmente necessÃ¡rio, ao menos na pesquisa em contabilidade e finanÃ§as. Mas, antes de partirmos direto para a implementaÃ§Ã£o dessas soluÃ§Ãµes, devemos antes saber: quando isso serÃ¡ necessÃ¡rio? De forma geral, vocÃª deverÃ¡ pensar nisso â€“ ou jÃ¡ deve estar pensando nisso â€“ quando o termo de erro no seu modelo linear nÃ£o tem um comportamento homocedÃ¡stico (o Ben Lambert faz uma boa revisÃ£o sobre homoscedasticidade e heterocedasticidade aqui: https://bit.ly/3u4K3L3). 

Embora nÃ£o provoque viÃ©s nos coeficientes em si, a heterocedasticidade pode arruinar os resultados de uma pesquisa a partir do momento que induz viÃ©s nos erros padrÃ£o dos coeficientes, podendo resultar em inferÃªncias inadequadas. Os erros de uma regressÃ£o representam o quÃ£o longe estÃ¡ da reta de regressÃ£o. Idealmente, os dados devem ser homocedÃ¡sticos, isso Ã©, esse erro deve seguir uma variÃ¢ncia constante e, visualmente, deverÃ­amos observar erros com um comportamento uniforme prÃ³ximo a reta da regressÃ£o estimada, sem grande dispersÃ£o. 

A heterocedasticidade surge pela natureza dos dados. Hipoteticamente, imagine um modelo de regressÃ£o onde a renda Ã© explicada pela idade. O racional por trÃ¡s desse modelo Ã© ingenuamente simples:  quanto mais velho vocÃª Ã©, maior a sua renda. De forma geral podemos deduzir que a maior parte dos adolescentes e jovens adultos recebem algo nÃ£o muito acima do salÃ¡rio mÃ­nimo. Digamos, entÃ£o, que atÃ© os 25 anos nÃ£o existe muita variabilidade nos dados. Depois dos 30 anos, entretanto, as diferenÃ§as costumam a aparecer com mais frequÃªncia: alguns podem ter alcanÃ§ado o cargo de sÃªnior e aumentado o salÃ¡rio em dez vezes enquanto outros podem ter, no mÃ¡ximo, dobrado o salÃ¡rio. A intuiÃ§Ã£o aqui Ã© de que a variabilidade do salÃ¡rio tenderÃ¡ a aumentar conforme a idade e isso, muito provavelmente, incorreria em problemas de heterocedasticidade: isso Ã©, os erros nÃ£o seriam homocedÃ¡sticos â€“ o erro em torno da reta de regressÃ£o aumentaria conforme a idade, dado a maior variabilidade. Para identificar formalmente a existÃªncia de problemas de heterocedasticidade existem inÃºmeros testes, que nÃ£o vou discutir aqui. Entretanto, entre esses testes, o teste de Breusch Pagan jÃ¡ Ã© um bom comeÃ§o.

IntuiÃ§Ã£o Ã  parte, apresentamos a seguir quais sÃ£o as possÃ­veis formas de implementar tratamentos para esse tipo de problema. Discutirei em duas partes: i) erros padrÃ£o robustos, tratamento â€œclÃ¡ssicoâ€ para a heterocedasticidade e; ii) clusterizaÃ§Ã£o dos erros padrÃ£o, caso especial de erros padrÃ£o robustos utilizados para casos mais particulares. 

Primeiro devemos carregar uma base de dados. Nesse exemplo, utilizarei uma base de dados disponibilizada no prÃ³prio R com mais de duas variÃ¡veis. Para treinar, vocÃª pode usar uma base de dados prÃ³pria ou alguma outra que seja de fÃ¡cil acesso. NÃ£o iremos partir para a interpretaÃ§Ã£o das relaÃ§Ãµes estimadas. Usaremos os seguintes pacotes a seguir: fixest e sandwich. Lembrando que Ã© possÃ­vel aplicar as correÃ§Ãµes tratadas a seguir usando o plm + a funÃ§Ã£o coeftest, mas o caminho Ã© diferente e isso acabaria ficando melhor explicado em outro post.


		#Carregando alguns pacotes e o primeiro conjunto de dados que iremos utilizar para o exemplo 
		library(fixest)
		library(sandwich)
		data(iris)
		datairis <- iris

Em seguida, estimaremos um modelo de regressÃ£o OLS (Ordinary Least Squares) com efeitos fixos por meio da funÃ§Ã£o feols, parte do pacote fixest. No exemplo, iremos regredir dois modelos simples: i) Petal.Lenght contra Petal.Width e; ii) o mesmo modelo anterior, mas com mais uma variÃ¡vel, Sepal.Width. 

		#Estimando modelos  de regressÃ£o
		modelo1 <- feols(Petal.Length  ~ Petal.Width, data = datairis)
		modelo2 <- feols(Petal.Length  ~ Petal.Width + Sepal.Width, data = datairis)


Erros padrÃ£o robustos. Para verificar as estimaÃ§Ãµes dos modelos anteriores com os erros padrÃ£o sem levar em consideraÃ§Ã£o ajustes para problemas de heterocedasticidade, basta especificar â€œstandardâ€ no comando exibido a seguir. A funÃ§Ã£o etable do fixest permite visualizar os resultados de duas ou mais diferentes estimaÃ§Ãµes simultaneamente. Em â€œS.E. typeâ€ Ã© possÃ­vel verificar o tratamento dado ao erro padrÃ£o e, como esperado, verificamos erros calculados da forma padrÃ£o, sem tratamento para possÃ­veis problemas de heterocedasticidade ou emprego de clusterizaÃ§Ã£o.


	etable(modelo1, modelo2, se = "standard")

{{< figure src="Fig1.png" width="80%" >}}  


Como o nosso interesse Ã© tratar possÃ­veis problemas de heterocedasticidade, nÃ³s substituiremos o â€œstandardâ€ apresentado anteriormente por â€œheteroâ€. Dessa forma, computaremos erros padrÃ£o robustos a heterocedasticidade, mais especificamente na forma mais â€œtradicionalâ€ de se tratar problemas de heterocedasticidade (emprego de HC1), que pode ser vista em detalhes aqui: https://data.library.virginia.edu/understanding-robust-standard-errors/. 

Entretanto, como veremos mais na frente, existem outras formas de computar erros padrÃ£o robustos a heterocedasticidade (HC2, HC3, entre outras, que se diferenciam pela forma de se calcular). Como Ã© possÃ­vel observar na imagem a seguir, em â€œS.E. Typeâ€ Ã© apontado que os erros-padrÃ£o dos modelos estimados sÃ£o robustos a heterocedasticidade. Como devem perceber, a grande diferenÃ§a entre os modelos estimados na imagem anterior e os modelos estimados na imagem a seguir nÃ£o estÃ¡ nos coeficientes, que permanecem idÃªnticos. A Ãºnica (e importante) mudanÃ§a esteve nos valores dos erros-padrÃ£o, agora menos enviesados, sob a premissa de que os dados nÃ£o sÃ£o homocedÃ¡sticos. 

	etable(modelo1, modelo2, se = "hetero")

{{< figure src="Fig2.png" width="80%" >}}  


Ã‰ importante destacar que a correÃ§Ã£o â€œheteroâ€ Ã© baseada no HC1 Robust Standard Error, que nÃ£o Ã© idÃªntica a correÃ§Ã£o de White mais conhecida, que Ã© baseada na HC3, padrÃ£o do pacote sandwich. Ã‰ possÃ­vel empregar as diferentes variaÃ§Ãµes de tratamentos dos erros padrÃ£o, como a correÃ§Ã£o clÃ¡ssica de White (H0), a correÃ§Ã£o de Mackinnon e White (HC2) ou a correÃ§Ã£o de Cribari-Neto (HC4). Como podem perceber, hÃ¡ situaÃ§Ãµes em que diferentes correÃ§Ãµes nÃ£o implicam em diferenÃ§as perceptÃ­veis nos erros padrÃ£o observados. Por essa razÃ£o, nÃ£o vou reportar as imagens dos testes a seguir por brevidade. 


		#CorreÃ§Ã£o clÃ¡ssica de White
		etable(modelo1, modelo2, .vcov = sandwich::vcovHC, .vcov.args = list(type = "HC0"))
		#CorreÃ§Ã£o de Mackinnon e White
		etable(modelo1, modelo2, .vcov = sandwich::vcovHC, .vcov.args = list(type = "HC2"))
		#CorreÃ§Ã£o de Cribari-Neto
		etable(modelo1, modelo2, .vcov = sandwich::vcovHC, .vcov.args = list(type = "HC4"))

Com pequenas modificaÃ§Ãµes Ã© possÃ­vel estimar alguns tratamentos mais complexos, como a correÃ§Ã£o de Newey-West que, teoricamente, procura resolver problemas de heterocedasticidade e correlaÃ§Ã£o serial.

		#CorreÃ§Ã£o de Newey-West
		etable(modelo1, modelo2, .vcov = sandwich::NeweyWest, .vcov.args = list(type = "NeweyWest"))


{{< figure src="Fig3.png" width="80%" >}}  


ClusterizaÃ§Ã£o dos erros padrÃ£o, caso especial de erros padrÃ£o robustos que leva em conta a heterocedasticidade entre clusters das observaÃ§Ãµes. Em algumas situaÃ§Ãµes mais particulares, clusterizar os erros-padrÃ£o pode ser necessÃ¡rio. Em algumas situaÃ§Ãµes ainda mais particulares, pode ser interessante clusterizar os erros padrÃ£o em mais de uma maneira (two-way, three-way, e por aÃ­ vai...). Em um trabalho recente, onde os dados eram infestados por problemas de correlaÃ§Ã£o serial, me foi indicado clusterizar os dados em two-way. Como eu poderia clusterizar em one-way? E como clusterizar em two-way? Pelo fixest nÃ£o Ã© complicado. Ã‰ necessÃ¡rio apenas especificar se os erros-padrÃ£o serÃ£o clusterizados por meio de um cluster Ãºnico (â€œclusterâ€) ou por mais de um cluster (â€œtwowayâ€), especificando o nÃ­vel da clusterizaÃ§Ã£o.  

Para o exemplo a seguir, vamos precisar carregar a seguinte base de dados.

		#Carregando dados
		data(airquality)
		dataair <- airquality

Em seguida, estimamos os modelos de regressÃ£o.

		#Estimando modelos de regressÃ£o
		modelo3 <- feols(Ozone  ~ Solar.R, data = dataair)
		modelo4 <- feols(Ozone  ~ Solar.R + Wind, data = dataair)

Para clusterizar os erros-padrÃ£o em one-way, devemos especificar o cluster. No exemplo a seguir o cluster serÃ¡ feito com base no mÃªs. 

		# Clusterizando em one-way (one-way clustering)
		etable(modelo3, modelo4, se = "cluster", cluster =c("Month"))

{{< figure src="Fig4.png" width="80%" >}}  

Para clusterizar os erros-padrÃ£o em dois nÃ­veis, devemos especificar que desejamos estimar os erros-padrÃ£o em twoway e, em seguida, especificar os dois nÃ­veis de clusters a serem empregados. No exemplo a seguir empregamos MÃªs e Dia.

		#Clusterizando em two-way (two-way clustering) 
		etable(modelo3, modelo4, se = "twoway", cluster =c("Month", "Day"))

{{< figure src="Fig5.png" width="80%" >}}  


