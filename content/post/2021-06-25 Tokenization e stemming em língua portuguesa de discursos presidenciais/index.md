---
title: "Tokenization e stemming em língua portuguesa de discursos presidenciais."

categories: [NLP, text mining]

# MUDE APENAS ANO DIA E MES PARA O DIA QUE VOCE NOS ENVIOU
date: '2021-06-25T00:00:00Z' 

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
  - NLP
  - Text Mining
  
# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
  - LucasMussoi
  - MarceloPerlin
  - MarcosHenriqueReichert


---


<script type="text/javascript" src="//cdn.plu.mx/widget-popup.js"></script>


<a href="https://plu.mx/plum/a/?doi=10.17632%2Fk5myphbwwj.1" data-popup="right" data-size="large" class="plumx-plum-print-popup" data-site="plum" data-hide-when-empty="true">Tokenization e stemming em l�ngua portuguesa de discursos presidenciais published at the &amp;quot;Open Code Community&amp;quot;</a>

As premissas que constituem a vasta gama de modelos de *Machine
Learning* e de *Deep Learning* foram trazidas para o ramo da linguística
com o intuito de interpretar escritas e falas humanas, **Processamento
de Linguagem Natural** sendo *NLP* seu acrônimo em inglês. Por mais que
tenhamos pouco conhecimento sobre as minúcias de uma linguagem, há
padrões que são identificáveis nas palavras - afixo, raiz, radical,
etc. Esses elementos constituem a morfologia, suas características estão
profundamente atreladas aos passos necessários para o pré-processamento
de uma base de dados textual: tokenização, remoção de *stop words* e
*inclusive stemming*. A acurácia dos modelos está diretamente ligada a
qualidade desses passos iniciais portanto, é de sumo interesse que
tenhamos um vislumbre dessa etapa. Vamos ver um pouco desses processos e
algumas de suas funcionalidades, as quais podem ser diretamente
utilizadas em pesquisas ou apenas com intuito ilustrativo.

# Pré-processamanto textual.

## Dados não processados

Como base textual, optamos pelo uso de discursos presidenciais pelo
simples fato de conterem diversos prefixos de tratamento, linguagem
culta (assim esperamos), parágrafos bem estruturados, não conterem
(assim esperamos, novamente) erros de digitação e por serem de livre e
fácil acesso
(<https://www.gov.br/planalto/pt-br/acompanhe-o-planalto/discursos/2021>).

    library(tibble) # Biblioteca necessária para o trabalho com dados

    jb_speech <- read.delim("dp_jb.txt", #localização de arquivo com os discursos
                            header = FALSE, #gera coluna de dados com nome genérico
                            col.names = "txt") #converte nome genérico para txt
    df_speech <- tibble(jb_speech) #transforma na estrutura de dados tibble

## Tokenização

Utilizamos a função *unnest\_tokens()* da biblioteca *tidytext* para
realizar a tokenização dos discursos presidenciais selecionados.

    library(tidytext) #biblioteca para textmining
    library(dplyr) #biblioteca que permite manipulação de dataframes

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

    tokens <- df_speech %>% #piping: acessa os discursos
      unnest_tokens(palavras, txt) #tokenização propriamente dita dos discursos, chama a coluna dos tokens de palavras. txt é a variável com os discursos.

    tokens

    ## # A tibble: 7,144 x 1
    ##    palavras
    ##    <chr>   
    ##  1 discurso
    ##  2 15062021
    ##  3 bom     
    ##  4 dia     
    ##  5 nós     
    ##  6 sabemos 
    ##  7 que     
    ##  8 uma     
    ##  9 boa     
    ## 10 imagem  
    ## # … with 7,134 more rows

*unnest\_tokens()* converte automaticamente as letras maiúsculas em
minúsculas de maneira a facilitar a comparação com outras databases.
Pode-se então usar *to\_lower = FALSE* nos argumentos da função. Manter
as palavras com letras maiúsculas serve como proxy para identificação de
nomes pessoais, empresas, entidades governamentais e acrônimos.

Pode-se utilizar o argumento *token = “sentences”* para diferenciar
palavras com letras maiúsculas que iniciam frases.

    sentences <- df_speech %>%
      unnest_tokens(sentences, txt, token = "sentences")

    head(sentences)

    ## # A tibble: 6 x 1
    ##   sentences                                                                     
    ##   <chr>                                                                         
    ## 1 discurso - 15062021                                                           
    ## 2 bom dia, nós sabemos que uma boa imagem vale muito mais que um milhão de pala…
    ## 3 eu quero começar saudando o nosso ministério das relações exteriores, tendo e…
    ## 4 parabéns a todos os servidores do nosso itamaraty na pessoa do nosso ministro…
    ## 5 eu me lembro, senhores embaixadores.                                          
    ## 6 em 1963, eu tinha 8 anos de idade, estava em jundiaí indo para campinas, e eu…

    # Usando token = "tweets, é possível fazer a tokenização por palavras e preservando os USERNAMES, HASHTAGS e URL's de twitters. 

## *Stop words*

*Stop words* por definição carregam muito poucas informações. Nas
línguas românticas, inclusive, são as palavras mais comuns - um
threshold é estabalecido dentro de um database de textos para que a
palavra seja considerada uma *stop word* - ou palavras funcionais tal
como *a*, *o*, *em*, *no* e suas variações. Línguas com casos como
Russo, Latim, Islandês a abordagem é feita de maneira diferente.

Vamos observar a composição primária desse discuros presidencial
analisando a incidência das palavras. O intuito é reduzir a carga de
informações a serem processadas, ajudando a manter um tempo
computacional aceitável e despendê-lo em funções mais cruciais.

    tokens_rank <- tokens %>% #acessa os tokens
      count(palavras, sort = TRUE) #assimila a cada token sua incidência

    head(tokens_rank)

    ## # A tibble: 6 x 2
    ##   palavras     n
    ##   <chr>    <int>
    ## 1 que        229
    ## 2 de         228
    ## 3 o          224
    ## 4 a          212
    ## 5 e          193
    ## 6 para       111

É necessário fazer o download das *stop words* em português brasileiro.
Há diversas fontes, a grande maioria com as mesmas palavras. Realizamos,
portanto, e a eliminação dessas palavras baseadas na tokenização
previamente realizada.

    library(stringr) # Usamos a biblioteca stringr para retirar qualquer espaço em branco do databse de stopwords. 

    ## 
    ## Attaching package: 'stringr'

    ## The following object is masked _by_ '.GlobalEnv':
    ## 
    ##     sentences

    stopwords <- read.delim(
        file = "http://www.labape.com.br/rprimi/ds/stopwords.txt", 
        header = FALSE,
        col.names = "palavras")

    # Com o argumento pattern = " " dizemos que vamos substituir um espaço em branco pelo argumento repl="" (nenhum espaço)
    stopwords <- str_replace_all(string=stopwords$palavras, pattern=" ", repl="")

    head(stopwords)

    ## [1] "de"  "a"   "o"   "que" "e"   "do"

    #Filtramos as palvras que não estão na lista de stopwords com o prefixo ! - negação - e as contamos
    clean_speech <- tokens %>%
      filter(!palavras %in% stopwords)

    freq_word_speech <- clean_speech %>%
      count(palavras, sort = TRUE)

    # Exibimos um wordcloud das 50 palavras mais frequentes
    library(wordcloud)

    ## Loading required package: RColorBrewer

    wordcloud(words = freq_word_speech$palavras,
              freq = freq_word_speech$n,
              min.freq = 1,
              max.words = 50,
              random.order = FALSE,
              colors=brewer.pal(8, "Dark2"))

![](Discursos_JB_NLP_preprocessamento_files/figure-markdown_strict/unnamed-chunk-5-1.png)

O contexto é extremamente importante em *text mining* então devemos
garantir que as stop words estão dentro do universo o qual desejamos
estudar. Através das palavras observadas podemos assumir que há vícios
de linguagem por parte do presidente. Como as palavras *“aí”*, *“coisa”*
que não carregam significados reais nenhum no entanto, aparecem com
frequência. Para, especificamente, a incidência das palavras nos
discursos presidenciais de Jair Bolsonaro podemos incluir essas palavras
na nossa lista de *stopwords* (se esse for nosso desejo e não implicar
em nehum problema para o estudo realizado).

## Stemming

Stemming é uma das maneiras de reduzir a dispersão dos dados - o que
pode ser interessante para treinarmos alguns modelo - reduzindo uma
palavra à sua raiz. No entanto, somos penalizados por estarmos jogando
informações fora.

Para isso, precisamos realizar o download do pacote *rslp* -
desenvolvido por Viviane Moreira Orengo e Christian Huyck do Instituto
de Informática da Universidade Federal do Rio Grande do Sul (*A Stemming
Algorithmm for the Portuguese Language*).

    devtools::install_github("dfalbel/rslp")

    ## Skipping install of 'rslp' from a github remote, the SHA1 (b8cd6715) has not changed since last install.
    ##   Use `force = TRUE` to force installation

    library(rslp)

    speech_stemm <- tibble(palavras = rslp(clean_speech$palavras))

    freq_word_stemm <- speech_stemm %>%
      count(palavras, sort = TRUE)

    wordcloud(words = freq_word_stemm$palavras,
              freq = freq_word_stemm$n,
              min.freq = 1,
              max.words = 50,
              random.order = FALSE,
              colors=brewer.pal(8, "Dark2"))

![](Discursos_JB_NLP_preprocessamento_files/figure-markdown_strict/unnamed-chunk-6-1.png)

Podemos ver que após o stemming, do mesmo database, temos diferença nas
incidências de palavras. Palavras distintas podem ter a mesma raíz e
isso se reflete visualmente através dos *wordclouds* os quais são
expressivamente distintos.

# Conclusão

*Text mining* gradativamente se consolidou como uma importante
ferramenta para as mais diversas áreas do conhecimento. Há uma vasta
literatura que aborda não somente o uso, mas os algoritmos por trás das
funções aqui utlizadas. A importância de estudos que interpretem as
características linguísticas regionais se sobressai, ainda mais, em um
país de tamanha dimensão como o Brasil.






{{% callout note %}}

**Please, cite this work:**

Almeida, Lucas Mussoi; Perlin, Marcelo; Reichert, Marcos Henrique (2021), "Tokenization e stemming em língua portuguesa de discursos presidenciais published at the "Open Code Community"", Mendeley Data, V1, doi: 10.17632/k5myphbwwj.1

{{% /callout %}}
           
           
