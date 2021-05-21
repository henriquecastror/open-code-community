---

title: "Recession shading em gráficos no R"

categories: []

date: '2021-05-21T00:00:00Z' 

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
- ggplot2
- fred
- recession

authors:
- FelipeQueiroz
- DavidMedeiros


---
<div align="justify">

Nesse post iremos ensinar a construir um gráfico de linha com indicações para períodos de recessão em séries temporais (gráficos com recession shading). 

Iremos nos basear no gráfico abaixo, retirado do [FRED](https://fred.stlouisfed.org/), para desenvolver a nossa versão.

</div>
<div align="center">
{{< figure library="true" src="1.png" width="100%" >}}
</div>
<div align="justify">

Começaremos **importando os dados da série temporal** do 'Personal Consumer Expenditures'. Após isso, **importamos um dataframe a partir de um .csv** contendo as datas de início e fim de cada recessão nos EUA. Realizamos, então, uma **manipulação dos dados desse dataframe**, de modo a restarmos somente com recessões que se encontrarem no período em que desejamos plotar. No final, elaboraremos um **gráfico de linha** que mostrará a série temporal e indicará os períodos recessivos.

</div>
Importando as bibliotecas necessárias.

    library(tidyquant) # Utilizado para importar os dados da série temporal.
    library(dplyr) # Utilizado para fazer a manipullação dos dados.
    library(ggplot2) # Utilizado para construir os gráficos.

Importando os dados da série temporal.


    # Utilizaremos a série temporal do Personal Consumer Expenditures, 
    # disponível no FRED. 
    # Observação: como os dados são obtidos do FRED, temos que usar o código da 
    # série utilizado por ele. Nesse caso, o código é "PCE".
    # Usaremos a função tq_get() da biblioteca tidyquant para importar os dados
    # da série temporal escolhida.

    inicio = '2000-01-01'
    fim = '2021-04-01'

    df = 'PCE' %>%
      tq_get(get  = "economic.data",
            from = inicio,
            to   = fim)

Agora, iremos fazer a manipulação dos dados de recessões.

Primeiro, importamos os dados.


    # Infelizmente o FRED não disponibiliza de forma tão concisa os dados 
    # necessários. Embora eles estejam disponíveis neste link
    # (fredhelp.stlouisfed.org/fred/data/understanding-the-data/recession-bars),
    # não há nenhum arquivo do FRED, ao menos que tenha chegado ao conhecimento 
    # dos autores, que esteja disponível com esses dados.

    # Por esse motivo, um dos autores fez a transposição desses dados para um 
    # arquivo .csv e o disponibilizou na internet, facilitando o processo para
    # outros que queiram replicar o código.

    # Para efetivamente importar os dados, utilizamos a função read.csv().

    recessoes_nber = read.csv('https://fqueiroz.netlify.app/uploads/recessoes_nber.csv', 
                             sep = ',')

    # Realizamos, também, uma pequena mudança de nome das colunas, apenas para 
    # simplificar o processo.

    names(recessoes_nber) = c('start', 'end') 

Para podermos trabalhar com esse dataframe, precisamos transformar os seus valores em datas.

    # Usaremos a função as.Date()

    recessoes_nber$start = as.Date(recessoes_nber$start)
    recessoes_nber$end = as.Date(recessoes_nber$end)

Agora, podemos selecionar apenas as recessões que estão no período de interesse.

    # Selecionamos, a partir da função subset(), apenas as recessões que tem 
    # seu fim nos períodos de interesse ou que ainda estão ocorrendo (ou não 
    # possuem data definida de término).

    recessoes_nber = subset(recessoes_nber, 
                            (end >= min(df$date) | is.na(end)))

    # Utilizamos a função is.na() para determinar se há alguma recessão ainda 
    # ocorrendo, já que nesse caso, não há nenhum valor de data na célula que 
    # indicaria a data do fim da recessão.

Realizaremos a manipulação dos dados de datas de início e de fim das recessões.

    # Primeiro, substituímos os valores em que não há data (recessão ainda está 
    # ocorrendo) pelo valor máximo da data na série temporal de interesse. Se 
    # não houver nenhuma recessão em andamento, nada será feito.

    recessoes_nber[is.na(recessoes_nber)] = max(df$date)

    # Após isso, substituímos os valores de data de início da recessão que estão
    # localizados fora do período de interesse, pelo valor mínimo de data da 
    # série temporal. Isso será importante caso o usuário selecione o início da 
    # série temporal dentro de um período de recessão. Se esse nao for o caso, 
    # nada ocorrerá.

    recessoes_nber$start[recessoes_nber$start < min(df$date)] = min(df$date)

Agora, temos os dados de recessão manipulados e os dados da série temporal. Já podemos elaborar o gráfico com esses dados.

Construiremos o gráfico utilizando o pacote ggplot2.

    # Para indicar os períodos recessivos, vamos utilizar o geom_rect, que 
    # colocará retângulos no gráfico entre as datas de início e fim das 
    # recessões. Colocamos a cor e transparência desejadas como parâmetro.

    df %>%
      ggplot() +
      geom_rect(data = recessoes_nber, 
                aes(xmin = start, xmax = end, ymin = -Inf, ymax = +Inf), 
                fill='#FEF3DE', alpha=0.8, col="#FEF3DE") +
      geom_line(aes(x=date, y=price), size = 1, color = "dodgerblue3") +
      labs(x = 'Data',
          y = 'Bilhões de US$',
          title = 'Personal Consumption Expenditures',
          caption = "Dados: U.S. Bureau of Economic Analysis. Elaboração própria.") +
      theme_light() +
      scale_x_date(breaks = scales::pretty_breaks(n = 8), expand = c(0,0)) +
      scale_y_continuous(breaks = scales::pretty_breaks(n = 8))    

Isso nos dá como output a imagem abaixo, que é exatamente o que nós desejavamos.

<div align="center">
{{< figure library="true" src="2.png" width="100%" >}}
</div>
