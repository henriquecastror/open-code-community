---

title: "Rolling Correlation entre BTC - S&P500 e BTC-Nasdaq"

categories: []

date: '2022-03-06T00:00:00Z' 

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
- Crypto
- Correlation
- Ggplot

authors:
- GersonJunior

---

Há uma discussão do aumento da correlação do BTC contra S&P500 e Nasdaq. O próposito desse exercício é verificar se esse aumento é verídico e montar um script para acompanhamento da correlação.

Primeiramente iremos carregar os pacotes, nesse script, nós usaremos o dplyr, importante para tratamento de dados; Quantmod para baixar a base de dados do Yahoo Finance; Ggplot2 para fazer gráficos. Inclusive para o ggplot2, eu recomendo o [post](https://opencodecom.net/post/2021-08-22-introducao-ao-ggplot2/) de introdução ao ggplot2. 
Primeiro passo é carregar as bibliotecas.
 
    library(dplyr)
    library(quantmod)
    library(ggplot2)

Depois de carregado as bibliotecas, iremos usar a função getSymbols para baixar os dados. Para saber o code para baixar os dados, é só olhar no próprio site do Yahoo Finance, como no exemplo do BTC, ao entrar no [site](https://finance.yahoo.com/quote/BTC-USD?p=BTC-USD&.tsrc=fin-srch), verificamos que o code do BTC é BTC-USD, ou seja, Bitcoin denotado em Dólar.

    getSymbols("BTC-USD")
    getSymbols("^GSPC")
    getSymbols("^IXIC")

Quando baixamos do getSymbols ele retorna em xts (objeto em time series). Eu, particularmente, gosto de trabalhar com data.frame, pois o package dplyr é muito intuitivo e fácil de manipulação.
Então, o passo abaixo é criar um data.frame

    BTC = data.frame(`BTC-USD`)
    SP500 = data.frame(GSPC)
    Nasdaq = data.frame(IXIC)

Abaixo iremos criar um vetor (coluna), chamada data para os nomes das linhas, se reparamos, os nomes das linhas é a data de cada preço, e iremos criar um vetor chamado return para cada retorno, utilizando sempre a coluna do adjusted, e por fim, iremos selecionar os vetores de interesse: data, retorno.
  
    BTC = BTC %>% mutate(data = rownames(BTC),
                     return_btc = BTC.USD.Adjusted/lag(BTC.USD.Adjusted,1)-1) %>%
    select(data,return_btc)

    SP500 = SP500 %>% mutate(data = rownames(SP500),
                         return_sp = GSPC.Adjusted/lag(GSPC.Adjusted,1)-1) %>%
      select(data,return_sp)

    Nasdaq = Nasdaq %>% mutate(data = rownames(Nasdaq),
                           return_nasdaq = IXIC.Adjusted/lag(IXIC.Adjusted,1)-1) %>%
    select(data,return_nasdaq )

Temos 3 data.frames para os dados de BTC, S&P500  e Nasdaq. Agora irei juntar esses data.frames em um data.frame único (chamado Data). Note que estamos usando inner_join, para entender a diferença, segue o pai de quem progama,stackoverflow explicando a [diferença](https://stackoverflow.com/questions/5706437/whats-the-difference-between-inner-join-left-join-right-join-and-full-join#:~:text=INNER%20JOIN%3A%20returns%20rows%20when,matches%20in%20the%20left%20table.). É importante usar inner_join e não left_join, pois BTC tem dados para todos os dias, e os outros 2 apenas dias úteis, se fizermos left_join, terá varios NA's no vetor do retorno da Nasdaq e S&P500.

    Data = inner_join(BTC,SP500, by = "data")
    Data = inner_join(Data,Nasdaq, by = "data")

Agora é um passo para mostrar que o vetor data, é uma data. Se não fizer isso, o ggptlot não reconhece e dá erro.

    Data$data = as.Date(Data$data)

Agora iremos criar os vetores de correlação (Rolling Correlation) entre os retornos de BTC e S&P500 e a correlação entre BTC e Nasdaq. Note que no parâmetro width, eu coloquei 30, o que representa que janela conterá 30 obs.

    Data = Data %>%
    mutate(cor_btc_sp = rollapplyr(
    data = cbind(return_btc, return_sp),
    width = 30,
    FUN = function(w) cor(w[, 1], w[, 2]),
    by.column = FALSE,
    fill = NA)) %>%
    mutate(cor_btc_nasdaq = rollapplyr(
    data = cbind(return_btc, return_nasdaq),
    width = 30,
    FUN = function(w) cor(w[, 1], w[, 2]),
    by.column = FALSE,
    fill = NA))
  
Com os vetores no data.frame, é só realizarmos os plots. Note que no segundo geom_line eu coloquei a função mean para traçar uma reta da média da correlação naquele vetor, o intuito é para identificar se a atual correlação está acima ou abaixo da média  

    ggplot(Data, aes(data)) +  geom_line(aes(y = cor_btc_sp, colour = "Correlation")) +
    geom_line(aes(y = mean(cor_btc_sp, na.rm= T), colour = "Mean Correlation")) +  theme_bw() + 
    ggtitle("Rolling Correlation BTC vs S&P500 - 30 observations")

{{< figure src="1.png" width="80%" >}}

    ggplot(Data, aes(data)) +  geom_line(aes(y = cor_btc_nasdaq, colour = "Correlation")) +
    geom_line(aes(y = mean(cor_btc_nasdaq, na.rm= T), colour = "Mean Correlation")) +  theme_bw() + 
    ggtitle("Rolling Correlation BTC vs Nasdaq - 30 observations")

{{< figure src="2.png" width="80%" >}}

Podemos observar um aumento da correlação de BTC e os índices, as discussões do motivo do aumento, não se encontra no escopo do post. O autor tem suas teses, mas não é objetivo do post.







