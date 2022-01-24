---

title: "Introdução ao ggplot2"

categories: []

date: '2021-08-22' 
 
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
- Open Data
- R
- ggplot2
- begginer
- gráficos

# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
- FelipeQueiroz
- DavidMedeiros


---


<script type="text/javascript" src="//cdn.plu.mx/widget-popup.js"></script>

<a href="https://plu.mx/plum/a/?doi=10.17632%2F4jmxk67rrn.1" data-popup="right" data-size="large" class="plumx-plum-print-popup" data-site="plum" data-hide-when-empty="true">Introdução ao ggplot2 published at the "Open Code Community"</a>



<div align="justify">

Nesse post iremos ensinar algumas funções do pacote ggplot2 para a elaboração de gráficos. Esse post tem a intenção de ser introdutório, para aqueles que estão começando no R ou nos gráficos no R. 

Iremos utilizar a base de dados gapminder, disponível no pacote de mesmo nome, para realizar nossas análises.
</div>

<div align="justify">

Um material de consulta muito útil é a [Cheat Sheet](https://d33wubrfki0l68.cloudfront.net/21d683072b0c21cbd9b41fc0e37a587ad26b9525/cbf41/wp-content/uploads/2018/08/data-visualization-2.1.png) disponibilizada pelo próprio RStudio.

Dividimos o post em tipos de dados e dentro dessa divisão falamos sobre seus gráficos mais usados.
Toda seção começa com gráficos mais básicos e avança para estéticas mais elaboradas.

Caso tenha dificuldade em entender alguma manipulação de dados você pode consultar nosso [post anterior](https://opencodecom.net/post/2021-07-26-introducao-ao-dplyr/) sobre o pacote dplyr.

# Uma pequena introdução à Grammar of Graphics

Os gráficos em ggplot2 são construídos em camadas.

Para fazer um gráfico em ggplot2, precisamos informar ao R 3 elementos essenciais do gráfico a ser construído: os dados a serem usados, o mapeamento das variáveis (para x e y, e outros parâmetros como cor, tamanho etc.) e a geometria do gráfico (linha, pontos, barra, histograma etc.).

Podemos ter como exemplo um simples esquema:

    ggplot(<dados-utilizados>, 
            aes(x = <variável-mapeada-para-x>, 
            y = <variável-mapeada-para-y>, 
            color = <variável-mapeada-para-cor>)) + 
        geom_<tipo-de-gráfico>()

No esquema acima, temos todos os elementos para criar um gráfico que, embora não seja estéticamente agradável, é funcional. Todos os elementos gráficos ggplot2 devem possuir dados, mapeamento de variáveis e geometria.

Além disso, há algumas camadas opcionais para os gráficos. Podemos citar a camada *facets*, que subdivide os dados - e os gráficos - com base em cada valor de algum parâmetro, gerando gráficos múltiplos; estatísticas (usa-se o elemento: stat_<estatística-desejada>), que adiciona elementos como média, mediana e linhas de regressão; coordenadas, que nos permite manipular os eixos do gráfico (como colocá-los em escala logarítmica etc.); temas, por meio dos quais mudamos de forma rápida a aparência do gráfico.

Dito isso, diversas das camadas opcionais serão utilizadas nos exemplos elaborados dos gráficos. Elas podem ser exploradas mais profundamente nesse [ótimo guia](http://www.sthda.com/english/wiki/be-awesome-in-ggplot2-a-practical-guide-to-be-highly-effective-r-software-and-data-visualization) de ggplot2 da STHDA. Não fizemos uma abordagem tão profunda nesse post devido ao seu caráter introdutório.

# Mãos na massa

Agora podemos importar as bibliotecas necessárias.
</div>

    library(dplyr) # Utilizado para fazer a manipulação dos dados.
    library(ggplot2) # Utilizado para construir os gráficos.
    library(gapminder) # Utilizado como fonte de dados socioeconômicos.
<div align="justify">

Primeiro vemos como é o dataframe que iremos trabalhar utlizando a função View().
</div>


    View(gapminder)

<div align="center">

{{< figure library="true" src="1.png" width="100%" >}}
</div>

# Gráficos de uma variável

## Histograma

<div align="justify">

Agora que sabemos com que dados estamos lidando, podemos começar a nossa análise.
Para esse gráfico univariado usaremos o dado de população no ano de 1952.
</div>

    # Primeiro vamos manipular no nosso dataframe para termos os dados que queremos
    
    gapminder_1952 <- gapminder %>%
                        filter(year == 1952)

    # Agora podemos criar um histograma para a Expectativa de Vida (lifeExp)
    
    ggplot(gapminder_1952, aes(x = lifeExp)) + 
        geom_histogram(bins = 20) # Bins indica o número de intervalos a serem utilizados no eixo x

    # Vale ressaltar que poderiamos fazer um histograma também com outros dados, tais como população, etc.

<div align="center">

{{< figure library="true" src="2.png" width="100%" >}}
</div>

<div align="justify">

Esse gráfico é o tipo mais básico do histograma, onde passamos a nossa fonte de dados(gapminder_1952) e qual dado dessa fonte usaremos.

Um gráfico mais elaborado, bem como seus novos parâmetros pode ser obtido assim:
</div>

    ggplot(gapminder, aes(x = lifeExp)) + 
      geom_histogram(bins = 20) + # Bins indica o número de intervalos a serem utilizados no eixo x
      labs(x = 'Expectativa de Vida', # Muda o título do eixo x
           y = 'Frequência', # Muda o título do eixo y
           title = 'Expectativa de Vida', # Muda o título do gráfico
           caption = "Fonte: Gapminder.") + # Muda a legenda
      theme_light() + # Indica o tema a ser usado no gráfico
      facet_wrap(~ year) # Indica que o gráfico será dividido ano a ano

<div align="center">

{{< figure library="true" src="3.png" width="100%" >}}
</div>

<div align="justify">

Além disso, podemos fazer um histograma para continente para cada ano, podendo ver melhor a evolução da expectativa de vida de cada um. Faremos isso utilizando o facet_grid(), em que podemos separar colunas e linhas por variáveis distintas. Nesse caso as linhas serão os anos e as colunas serão os continentes.

Algo a ser ressaltado é que não usaremos todos os anos disponíveis na base de dados (12 anos), mas apenas 6. Isso ajudará na visualização dos gráficos (selecionaremos os anos de 2007, 1997, 1987, 1977, 1967 e 1957).
</div>

    ggplot(subset(gapminder, year %in% c(2007, 1997, 1987, 1977, 1967, 1957)), aes(x = lifeExp)) + 
        geom_histogram(bins = 20) + 
        labs(x = 'Expectativa de Vida', # Muda o título do eixo x
            y = 'Frequência', # Muda o título do eixo y
            title = 'Expectativa de Vida', # Muda o título do gráfico
            caption = "Fonte: Gapminder.") + # Muda a legenda
        theme_light() + # Indica o tema a ser usado no gráfico
        facet_grid(year ~ continent)

<div align="center">

{{< figure library="true" src="4.png" width="100%" >}}
</div>

<div align="justify">

## Gráfico de barras

O Gráfico de barras é similar à um histograma em seu formato, porém, esse gráfico é usado para identificar quantas observações pertencem à determinada classe, ao invés de um determinado intervalo de valores, como no histograma.

Nesse caso, iremos ver quantos países de cada continente possuímos no nosso dataframe, no ano de 1952. Esse tipo de gráfico de barras, em que o próprio ggplot conta os valores pertencentes à cada classe é o geom_bar().
</div>

    ggplot(gapminder_1952, aes(x = continent)) +
        geom_bar()

<div align="center">

{{< figure library="true" src="5.png" width="100%" >}}
</div>
<div align="justify">

E agora uma versão mais polida:
</div>

    ggplot(gapminder_1952, aes(x = continent)) +
        labs(x = 'Continente', # Muda o título do eixo x
             y = 'Número de países') + # Muda o título do eixo y
             title = 'Países por continente', # Muda o título do gráfico
        theme_light() + # Muda o tema do gráfico
        geom_bar()

<div align="center">

{{< figure library="true" src="6.png" width="100%" >}}
</div>

<div align="justify">

# Gráficos de duas variáveis

## Gráfico de Dispersão/Pontos

Gráficos de dispersão são muito usados para indicar a relação entre duas variáveis. No ggplot, usamos o geom_point() para fazer um gráfico de dispersão.

Como exemplo, faremos um gráfico de dispersão que plotará a expectativa de vida de cada país e seu PIB per capita. Por fins de simplificação, primeiramente faremos isso somente para o ano de 2007.
</div>

    gapminder_2007 = gapminder %>% filter(year == 2007) # Filtramos o ano que desejamos

    ggplot(gapminder_2007, aes(x = gdpPercap, y = lifeExp, 
                               color = continent, # Indica que a cor dos pontos será dada em função do continente a que pertence
                               size = pop)) + # Indica que o tamanho dos pontos será dado em função da população do país
            geom_point() + # Especifica o tipo de gráfico
            scale_x_log10() + # Indica que a escala do eixo x é em logarítmo
            scale_y_log10() # Indica que a escala do eixo y é em logarítmo

<div align="center">

{{< figure library="true" src="7.png" width="100%" >}}
</div>
<div align="justify">

Agora, em um gráfico mais elaborado, colocaremos uma divisão por anos e alguns elementos estéticos.
</div>

    ggplot(gapminder, aes(x = gdpPercap, y = lifeExp, 
                          color = continent, # Indica que a cor dos pontos será dada em função do continente a que pertence
                          size = pop)) + # Indica que o tamanho dos pontos será dado em função da população do país
            geom_point() + # Especifica o tipo de gráfico
            labs(x = 'PIB per capita', # Muda o título do eixo x
                y = 'Expectativa de Vida', # Muda o título do eixo y
                title = 'PIB p.c. x Expectativa de Vida', # Muda o título do gráfico
                caption = "Fonte: Gapminder.", # Muda a legenda
                color = 'Continente', # Muda o título da legenda de cores
                size = 'População')+ # Muda o título da legenda de tamanho
            scale_x_log10() + # Indica que a escala do eixo x é em logarítmo
            scale_y_log10() + # Indica que a escala do eixo y é em logarítmo
            facet_wrap(~ year) # Separa o gráfico em anos

<div align="center">

{{< figure library="true" src="8.png" width="100%" >}}
</div>
<div align="justify">

## Gráfico de Colunas

O gráfico de colunas é utilizado para indicar valores para uma determinada classe/variável. 

Nesse caso, usaremos o geom_col() para visualizarmos qual é o PIB per capita mediano por continente, para o ano de 1952.
</div>

    # Primeiro utilizamos o filter e o summarize para obter os dados que queremos

    by_continent_1952 <- gapminder %>% 
        filter(year == 1952) %>% 
            group_by(continent) %>% 
                summarize(medianGdpPercap = median(gdpPercap))

    # Plotamos o gráfico

    ggplot(by_continent_1952, aes(x = continent, y = medianGdpPercap)) + 
        geom_col()

<div align="center">

{{< figure library="true" src="9.png" width="100%" >}}
</div>
<div align="justify">

Para o gráfico mais elaborado, iremos fazer um gráfico similar ao acima, porem para todos os anos disponíveis. Além disso, colocaremos alguns elementos estéticos.
</div>

    # Primeiro utilizamos o filter e o summarize para obter os dados que queremos

    by_year_continent <- gapminder %>% 
        group_by(year, continent) %>% 
            summarize(medianGdpPercap = median(gdpPercap), .groups = 'keep')

    # Plotamos o gráfico

    ggplot(by_year_continent, aes(x = continent, y = medianGdpPercap)) + 
        geom_col() +         
        labs(x = 'Continente', # Muda o título do eixo x
            y = 'PIB p.c. mediano', # Muda o título do eixo y
            title = 'PIB p.c. mediano por continente e por ano', # Muda o título do gráfico
            caption = "Fonte: Gapminder.") + # Muda a legenda
        facet_wrap(~ year) # Separa o gráfico em anos

<div align="center">

{{< figure library="true" src="10.png" width="100%" >}}
</div>

<div align="justify">

## Boxplot (Gráfico de Caixa)

O Boxplot é muito utilizado em análises estatísticas devido à algumas propriedades interessantes. A imagem abaixo, retirada do [OperData](https://operdata.com.br/blog/como-interpretar-um-boxplot/), é muito útil para visualizarmos melhor as funcionalidades do boxplot.

</div>

<div align="center">

{{< figure library="true" src="boxplot.jfif" width="100%" >}}
</div>

<div align="justify">

Utilizaremos o geom_boxplot() para representar os valores de PIB per capita por continente, para o ano de 1952.

    ggplot(gapminder_1952, aes(x = continent, y = gdpPercap)) +
        geom_boxplot() +
        scale_y_log10()

</div>

<div align="center">

{{< figure library="true" src="11.png" width="100%" >}}
</div>

<div align="justify">

Para o gráfico mais elaborado, iremos adicionar os outros anos, facetando-os, e adicionar elementos estéticos.

    ggplot(gapminder, aes(x = continent, y = gdpPercap)) +
        geom_boxplot() +
        scale_y_log10() + # Indica que a escala do eixo x é em logarítmo
        labs(x = 'Continente', # Muda o título do eixo x
            y = 'PIB p.c.', # Muda o título do eixo y
            title = 'PIB p.c. por continentes e anos', # Muda o título do gráfico
            caption = "Fonte: Gapminder.") + # Muda a legenda
        facet_wrap(~year) # Separa o gráfico em anos

</div>

<div align="center">

{{< figure library="true" src="12.png" width="100%" >}}
</div>

<div align="justify">

## Gráfico de Linhas

O gráfico de linhas é um dos gráficos mais utilizados. As análises com 2 variáveis contínuas são muito utilizadas especialmente ao representar séries temporais. 

Para o nosso gráfico de exemplo, iremos utilizar o geom_line() para plotar a série temporal de PIB per capita mediano ao longo dos anos.

    ggplot(by_year_continent, aes(x = year, y = medianGdpPercap, color = continent)) + 
        geom_line()

</div>

<div align="center">

{{< figure library="true" src="13.png" width="100%" >}}
</div>

<div align="justify">

Para o nosso gráfico mais elaborado, iremos adicionar os elementos estéticos ao gráfico.

    ggplot(by_year_continent, aes(x = year, y = medianGdpPercap, color = continent)) + 
        geom_line() + 
        labs(x = 'Ano', # Muda o título do eixo x
            y = 'PIB p.c. mediano', # Muda o título do eixo y
            title = 'PIB p.c. mediano por continente', # Muda o título do gráfico
            color = 'Continente', # Muda o título da legenda de cores
            caption = "Fonte: Gapminder.") # Muda a legenda

</div>

<div align="center">

{{< figure library="true" src="14.png" width="100%" >}}
</div>

<div align="justify">

# Adendo: como salvar seus gráficos ggplot2

Para finalizar o nosso post, iremos ensinar como salvar os seus gráficos feitos com o ggplot2 de uma forma simples e rápida. 

Acreditamos que esse é um jeito melhor de salvar as suas imagens do que salvar a partir do visualizador do RStudio, como grande parte dos iniciantes em R fazem.

A função **ggsave()** do próprio ggplot2 é a melhor ferramenta para isso. Abaixo se encontra um exemplo de sua utilização.

</div>

    # Um exemplo de gráfico utilizado nesse post

    graph = ggplot(gapminder, aes(x = gdpPercap, y = lifeExp, color = continent, size = pop)) + 
            geom_point() + # Especifica o tipo de gráfico
            labs(x = 'PIB per capita', # Muda o título do eixo x
                y = 'Expectativa de Vida', # Muda o título do eixo y
                title = 'PIB p.c. x Expectativa de Vida', # Muda o título do gráfico
                caption = "Fonte: Gapminder.", # Muda a legenda
                color = 'Continente', # Muda o título da legenda de cores
                size = 'População')+ # Muda o título da legenda de tamanho
            scale_x_log10() + # Indica que a escala do eixo x é em logarítmo
            scale_y_log10() + # Indica que a escala do eixo y é em logarítmo
            facet_wrap(~ year) # Separa o gráfico em anos

    # A função para salvá-lo

    ggsave(graph, # O objeto ggplot a ser salvo
           filename = 'C:/seu-endereço-do-arquivo-aqui/nome-do-arquivo.png', # O endereço do arquivo e seu nome
           dpi = 400, # A densidade de pixels da imagem (quanto maior, maior a qualidade das linhas e pontos)
           type = 'cairo', # O tipo de salvamento a ser realizado (indicamos o 'cairo' para maior qualidade)
           width = 6, # A largura do gráfico
           height = 4, # A altura do gráfico
           units = 'in') # A unidade de medida das dimensões do gráfico
           
           
           



{{% callout note %}}

**Please, cite this work:**

Queiroz, Felipe; Medeiros, David (2021), "Introdução ao ggplot2 published at the "Open Code Community"", Mendeley Data, V1, doi: 10.17632/4jmxk67rrn.1

{{% /callout %}}
           

