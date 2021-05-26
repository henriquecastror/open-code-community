---
title: "Table Heatmap no R - Temperatura do IPCA"

categories: []

date: '2021-05-26T00:00:00Z' 

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
- Open Code

authors:
- GersonJunior
- FelipeQueiroz


---
##Temperatura do IPCA.

Esse post foi motivado por um tweet da economista chefe do Banco Inter, [Rafaela  Vitoria]( https://twitter.com/rvitoria/status/1392130287824510983). A Rafaela postou table heatmap do IPCA.  Observar-se a aceleração do IPCA nos últimos meses. Como é interessante para reports esse table, fizemos o código para captar os dados do IPCA pelo package [BETS]( https://cran.r-project.org/web/packages/BETS/BETS.pdf), tratar os dados e construir o table heatmap.
Carregar os pacotes

    library(BETS)
    library(gt)
    library(scales)
    library(tidyverse)
    library(lubridate)

Esse passo é importante para identificarmos qual code do IPCA, caso o leitor esteja curioso com outros tipos de series que o BETS fornece.

    # Identificar qual é o código que queremos
    list = BETSsearch()
    # Pegar o IPCA
    IPCA = BETSget(10764, from = "2010-01-01", data.frame = TRUE, frequency = NULL)

Uma informação interessante, colocamos o parâmetro data.frame = TRUE para tratamos o dado do dpylr.
Tratando os dados.
    
    IPCA = IPCA %>% 
      mutate(date, year(date))
    
    IPCA = IPCA %>% 
      mutate(date, format(date, '%b'))
    
    IPCA = IPCA[-1]
    
    names(IPCA) = c('value','Ano','m')
    
        IPCA$m = str_to_title(IPCA$m)

Pivotando o data.frame. Lembrando que o Gerson fez  um post disso no [Open Code]( https://opencodecom.net/post/2021-04-22-como-fazer-reshape-no-r/).

    IPCA = IPCA %>%
      pivot_wider(names_from = m, values_from = value)

Contruindo o table heatmap.
   
    IPCA %>%
      gt(rowname_col = "Ano") %>%
      tab_header(
        title = "IPCA Mensal",
        subtitle = "2010 - Presente"
      ) %>%
      tab_source_note(
        source_note = md("<div align = 'right'>Fonte: BETS, FGV.</div>")
      ) %>%
      tab_source_note(
        source_note = md("<div align = 'right'>Elaboração: Gerson Junior e Felipe Queiroz.</div>")
      ) %>%
      fmt(
        columns = 2:13,
        fns = function(x) paste0(x, "%")
        ) %>%
      fmt_missing(
        columns = 2:13, 
        missing_text = "" 
      ) %>%
      tab_options(
        data_row.padding = 15
      ) %>%  
      data_color(columns = 2:13,
                 colors = col_numeric(palette = c('green', 'grey90', 'red'),
                                      domain = c(1.5, -1),
                                      na.color = 'white'))
<div align="center">
{{< figure library="true" src="1.png" width="100%" >}}
</div>
