---
title: "Detecting time series outliers"

categories: []

date: '2021-09-15' 

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

# DIGITE NA LISTA ABAIXO OS TRACKS DO SEU CODIGO
tags: 
- Outliers

# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
- RobHyndman

---
## Calculando a vari�ncia e a volatilidade de uma carteira hipot�tica
A fun��o tsoutliers () do pacote forecasting do R � �til para identificar anomalias em uma s�rie temporal. No entanto, n�o est� devidamente documentado em nenhum lugar. Esta postagem visa preencher essa lacuna.
A fun��o come�ou como uma resposta em CrossValidated[https://stats.stackexchange.com/questions/1142/simple-algorithm-for-online-outlier-detection-of-a-generic-time-series/1153#1153] e depois foi adicionada ao pacote forecasting, dado que achei que poderia ser �til para outras pessoas. Desde ent�o, ele foi atualizado e tornou-se mais confi�vel.
O procedimento decomp�e a s�rie temporal em tend�ncia, sazonalidade e componentes remanescentes:

\begin{align} y_t = T_t + S_t + R_t\end{align} 

O componente sazonal � opcional e pode conter v�rios padr�es sazonais correspondentes aos per�odos sazonais dos dados. A ideia � remover qualquer sazonalidade e tend�ncia nos dados e, em seguida, descobrir os outliers nas s�ries restantes, $R_t$.

Para dados observados com mais frequ�ncia do que anualmente, usamos uma abordagem robusta para estimar $T_t$ e $S_t$ aplicando primeiro o m�todo MSTL aos dados. O MSTL estimar� iterativamente o (s) componente (s) sazonal (is).

Em seguida, a for�a da sazonalidade � medida usando:

\begin{align} F_s = 1 - \dfrac{Var(y_t-T-S_t)}{Var(y_t - T_t) }\end{align}
Se $F_s$ > 0,6, uma s�rie ajustada sazonalmente � calculada:

\begin{align} y^t_t = y_t - S_t\end{align}

Um limite de for�a sazonal � usado aqui porque a estimativa de S_t provavelmente ser� super ajustada e muito barulhenta se a sazonalidade subjacente for muito fraca (ou inexistente), potencialmente mascarando quaisquer outliers por t�-los absorvidos no componente sazonal.

Se $Fs$???0,6, ou se os dados s�o observados anualmente ou com menos frequ�ncia, simplesmente definimos y_t^* = y_t.

Em seguida, n�s reestimamos o componente de tend�ncia a partir dos valores de y ??? t. Para s�ries temporais n�o sazonais, como dados anuais, isso � necess�rio, pois n�o temos a estimativa de tend�ncia da decomposi��o STL. Mas mesmo que tenhamos calculado uma decomposi��o STL, podemos n�o t�-la usado se $F_s$???0,6.

O componente de tend�ncia T_t � estimado aplicando o o Friedman's super smoother (via supsmu ()) aos dados y_t^*. Esta fun��o foi testada em muitos dados e tende a funcionar bem em uma ampla gama de problemas.

Procuramos outliers na s�rie restante estimada:

\begin{align} r_t^^ = y_t^* - t^^_T\end{align}

Se Q1 denota o 25� percentil e Q3 denota o 75� percentil dos valores restantes, ent�o o intervalo interquartil � definido como IQR = Q3 ??? Q1. As observa��es s�o rotuladas como outliers se forem menores que Q1-3 � IQR ou maiores que Q3 + 3 � IQR. Esta � a defini��o usada por Tukey (1977, p44)[https://www.amazon.com.br/dp/0134995457?geniuslink=true] em sua proposta original de boxplot para valores "distantes".

Se os valores restantes s�o normalmente distribu�dos, ent�o a probabilidade de uma observa��o ser identificada como um outlier � de aproximadamente 1 em 427000.

Quaisquer outliers identificados desta maneira s�o substitu�dos por valores interpolados linearmente usando as observa��es vizinhas, e o processo � repetido.


Exemplo: dados de ouro
Os dados do pre�o do ouro cont�m os pre�os di�rios do ouro pela manh� em d�lares americanos de 1 � de janeiro de 1985 a 31 de mar�o de 1989. Os dados me foram fornecidos por um cliente que queria que eu fizesse uma previs�o do pre�o do ouro. (Eu disse a ele que seria quase imposs�vel superar uma previs�o ing�nua). Os dados s�o mostrados a seguir.

    library(fpp2)
    autoplot(gold)

{{< figure src="1.png" width="80%" >}}


Existem per�odos de valores ausentes e um outlier �bvio que � cerca de $ 100 maior do que o esperado. Isso foi simplesmente um erro de digita��o, com algu�m digitando 593,70 em vez de 493,70. Vamos ver se a fun��o tsoutliers () pode identific�-lo.

    tsoutliers(gold)
    ## $index
    ## [1] 770
    ## 
    ## $replacements
    ## [1] 495

Com certeza, ele � facilmente encontrado e a substitui��o sugerida (interpolada linearmente) est� perto do valor verdadeiro.

A fun��o tsclean () remove outliers identificados dessa maneira e os substitui (e quaisquer valores ausentes) por substitui��es interpoladas linearmente.
    
    autoplot(tsclean(gold), series="clean", color='red', lwd=0.9) +
    autolayer(gold, series="original", color='gray', lwd=1) +
    geom_point(data = tsoutliers(gold) %>% as.data.frame(), 
    aes(x=index, y=replacements), col='blue') +
    labs(x = "Day", y = "Gold price ($US)")

{{< figure src="2.png" width="80%" >}}



O ponto azul mostra a substitui��o do outlier, as linhas vermelhas mostram a substitui��o dos valores ausentes.
