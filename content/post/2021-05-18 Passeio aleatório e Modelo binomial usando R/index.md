---
title: "Passeio aleat�rio e Modelo binomial usando R"

categories: []

date: '2021-05-17T00:00:00Z' 

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
- Tratamento de Dados
- Modelo Binomial
- Passeio Aleat�rio

authors:
- ArnaldoNascimento


---



---
## Passeio aleat�rio e Modelo binomial usando R

A motiva��o desse post � mostrar como construir dois modelos b�sicos mas muito instrutivos em simula��es estoc�sticas. S�o eles, o Passeio Aleat�rio, modelo que serve como base para diversos processos estoc�sticos e o Modelo Binomial, que � uma discretiza��o do movimento geom�trico browniano com �tima performance computacional.

Carregando os par�metros: fator de subida (xp), fator de descida (xm), valor inicial (S0), probabilidade de subida (pp), probabilidade de descida (pm), n�mero de passos (n) e n�mero de caminhos a serem plotados em cada simula��o (path).

    xp <- 1.1; xm <- 0.9         
    S0 <- 0.5                   
    pp <- 0.6; pm <- 1-pp        
    n <- 100                    
    path <- 10

Construindo o vetor de probabilidades aleat�rias (a) e inicializando o vetor de ganho/perda (e) em cada passo e o vetor do valor acumulado em cada passo (S).

    a <- runif(n, min = 0, max = 1)                    
    e <- matrix(nrow = 1, ncol = n-1, NA)               
    S <- matrix(nrow = 1, ncol = n, NA); S[1] <- S0    

Construindo o vetor de ganho/perda.

    for (i in 1:(n-1)) {
      if (a[i]>pp) e[i] <- xm else e[i] <- xp           
    }

Construindo o vetor do valor acumulado a cada passo. Aqui basta escolher qual modelo quer simular, passeio aleat�rio (processo aditivo) ou o modelo binomial (processo multiplicativo)

    for (i in 2:n) {
        #S[i] <- S[i-1]+e[i-1]                         
        S[i] <- S[i-1]*e[i-1]                          
    }

Plotando o primeiro caminho.

    plot(c(1:n), S, type = "l", xlab = "n", ylab = "S", xlim = c(0,n), ylim = c(min(S),max(S)))
    


Construindo e plotando os demais caminhos. Aqui tamb�m pode-se escolher entre os dois modelos.

    for (j in 1:path) {                                 # building different paths
      a <- runif(n, min = 0, max = 1)
      S[1] <- S0
     
      for (i in 1:(n-1)) {
        if (a[i]>pp) e[i] <- xm else e[i] <- xp
      }
      for (i in 2:n) {
        #S[i] <- S[i-1]+e[i-1]                          # S for Random Walk
        S[i] <- S[i-1]*e[i-1]                            # S for Binomial Model
      }
      lines(c(1:n), S, type = "l", col = j)            
    }
    
    
{{< figure src="RandomWalk.png" width="80%" >}}       