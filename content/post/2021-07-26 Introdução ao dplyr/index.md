---

title: "Introdução ao dplyr"

categories: []

# MUDE APENAS ANO DIA E MES PARA O DIA QUE VOCE NOS ENVIOU
date: '2021-07-26T00:00:00Z' 

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
- Open Data
- R
- dplyr
- begginer

# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
- FelipeQueiroz
- DavidMedeiros


---
<script type="text/javascript" src="//cdn.plu.mx/widget-popup.js"></script>

<a href="https://plu.mx/plum/a/?doi=10.17632%2Fwpgpcfxxbs.1" data-popup="right" data-size="large" class="plumx-plum-print-popup" data-site="plum" data-hide-when-empty="true">Introdução ao dplyr published at the &amp;quot;Open Code Community&amp;quot;</a>



<div align="justify">

Nesse post iremos ensinar algumas funções do pacote dplyr, usado para manipulação de dados.
  
O objetivo é que esse post sirva como introdução e material de consulta para os iniciantes em R. 

Utilizaremos o pacote gapminder como fonte dos dados que manipularemos. Esse é um pacote que contém dados socioeconômicos para diversos países em diversos anos, o que nos possibilita realizar as principais tarefas de manipulação de dados com o R: filter e mutate.

</div>
Importando as bibliotecas necessárias.

    library(gapminder)
    library(dplyr)

Visualizaremos como é o dataframe que estamos tratando.

    head(gapminder)

<div align="center">
{{< figure library="true" src="1.png" width="100%" >}}
</div>

<div align="justify">
Temos, agora, um DataFrame com os nomes dos países, seu continente, o ano da observação dos dados, a sua expectativa de vida, sua população e seu PIB per capita.

## Filter

Podemos, agora, fazer uso da função **filter**, para que selecionemos apenas algumas linhas de interesse do DataFrame. 
Usaremos também a função **%>%** (pipe) do dplyr.

</div>

    # Nesse caso estamos filtrando o DataFrame para termos apenas as observações de 
    # dados em que o ano seja 2007.
    # Note que usamos o comando %>%, que é uma maneira de aninhar as funções de uma 
    # forma a simplificar a visualização do nosso código.
    # Esse comando faz parte do pacote dplyr.

    gapminder2007 = gapminder %>% filter(year == 2007)

    head(gapminder2007)

<div align="justify">
Essa função recebe como parâmetro uma condição em uma coluna. No exemplo, passamos a coluna year e a condição do valor dessa coluna ser igual à 2007. 

Ao fazer isso, o **filter** seleciona as linhas do DataFrame que atendem à uma determinada condição estabelecida pelo usuário.

<div align="center">
{{< figure library="true" src="2.png" width="100%" >}}
</div>
<div align="justify">

Agora, podemos analisar o comando **mutate**.

## Mutate
 
Por vezes, não temos os dados da forma que os necessitamos. Para solucionar esse problema, podemos usar o **mutate**. Com o **mutate** podemos modificar uma coluna ou adicionar uma nova a partir das já existentes.

Digamos que você queira saber o valor dos PIBs para os países do dataframe. Contudo, só temos as informações de PIB per capita e população. Felizmente, podemos obter o PIB ao multiplicar essas 2 colunas. 

</div>

    gapminderGDP2007 = gapminder2007 %>% mutate(GDP = pop*gdpPercap)

    head(gapminderGDP2007)

<div align="center">
{{< figure library="true" src="3.png" width="100%" >}}
</div>

## Transmute
<div align="justify">

O **transmute** é muito similar ao **mutate** visto anteriormente, porém, ele tem uma propriedade peculiar que é apenas retornar a coluna que foi criada/modificada. As outras colunas não estão presentes no retorno.

Utilizando o mesmo exemplo que acima:

</div>

    gapminderGDP2007tsmt = gapminder2007 %>% transmute(GDP = pop*gdpPercap)

    head(gapminderGDP2007tsmt)

<div align="center">
{{< figure library="true" src="4.png" width="100%" >}}
</div>

## Select
<div align="justify">

Agora podemos analisar o uso da função **select**. A função, como o nome já indica, seleciona **colunas** do DataFrame a partir dos parâmetros passados, como por exemplo o nome das colunas. Há algumas subfunções muito úteis presentes na [documentação da função](https://dplyr.tidyverse.org/reference/select.html), que permitem fazer seleções mais elaboradas que apenas com base no nome.

Nesse caso, por questões de simplicidade, iremos ilustrar o **select** selecionando colunas com base no seu nome.

</div>


    gapminderGDP2007_Select = gapminderGDP2007 %>% select(continent, lifeExp, GDP)
    
    head(gapminderGDP2007_Select)

<div align="center">
{{< figure library="true" src="5.png" width="100%" >}}
</div>

<div align="justify">

## Group_by e Summarize

A função **group_by** é incrívelmente útil para juntar (ou agrupar) um DataFrame com base um determinadas caracteristicas. Tipicamente ele é muito usado em conjunto com a função **summarize**, pelo seu grande poder combinado de descrição. 

No exemplo que usaremos, o **group_by** será usado para agrupar o DataFrame com base nos diferentes continentes, ou seja, haverá um grupo contendo as linhas referentes à Europa, outro para as da África, e assim em diante.

O **summarize** entra em cena já que desejamos descobrir para cada grupo (nesse caso, os continentes) qual é a mediana de seus valores de PIB (GDP) e de Expectativa de Vida (lifeExp). 

Essa ferramenta pode ser muito útil em diversas análises.

</div>

    gapminderGDP2007_SelectGroupBy = gapminderGDP2007_Select %>% 
    group_by(continent) %>% summarize(medianGDP = median(GDP), medianLifeExp = median(lifeExp))

    head(gapminderGDP2007_SelectGroupBy)

<div align="center">
{{< figure library="true" src="6.png" width="100%" >}}
</div>

## Arrange

<div align="justify">

O **arrange** é uma função que ordena as linhas do dataframe de maneira crescente por meio dos valores de determinada coluna.

No exemplo abaixo, contudo, queremos ordenar as linhas de maneira decrescente, logo, precisamos passar como parâmetro a função desc().

</div>

    # Teremos, agora, as linhas organizadas em valores decrescentes de mediana dos valores de PIB (medianGDP).

    head(gapminderGDP2007_SelectGroupBy %>% arrange(desc(medianGDP)))

<div align="justify">
Ao executarmos o código acima, vemos que a Oceania possuio o mais alto valor mediano do PIB de todos os continentes para o ano de 2007, enquanto a África possui os menores.
</div>

<div align="center">
{{< figure library="true" src="7.png" width="100%" >}}
</div>

<div align="center"><div align="justify">
Esperamos que vocês tenham aproveitado essa breve introdução ao **dplyr**. Há muito mais informações amplamente disponiveis na Internet para que você aprofunde seus conhecimentos. Contudo, caso queira saber mais de algum tópico específico, mande um e-mail para algum dos autores para que possamos fazer um novo post abordando melhor esse assunto!





{{% callout note %}}

**Please, cite this work:**

Queiroz, Felipe; Medeiros, David (2021), "Introduçãao dplyr published at the "Open Code Community"", Mendeley Data, V1, doi: 10.17632/wpgpcfxxbs.1

{{% /callout %}}
           
</div>
