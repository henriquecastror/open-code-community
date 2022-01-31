---

title: "Beta calculado por Rolling Regression e por grupos (mês, ano)."

categories: []

date: '2022-30-01T00:00:00Z' 

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
- CAPM
- Finance

authors:
- GersonJunior


---

Há diversas críticas ao modelo CAPM. Uma crítica se deve ao beta ser estático. Para contornar essa limitação, apresentamos 2 tipos de regressão no post.

1) Beta por rolling regression - Utilizamos uma janela de X dados de observação e façamos uma regressão linear com dados dessa janela obtendo um beta (dados da observação 1 até X), a partir daí andamos 1 passo e regredimos mais uma vez (dados da observação 2 até  X+1) e assim sucessivamente. 
2) Calculamos o beta por mês, semestre ou ano.

Primeiramente iremos carregar as bibliotecas.

    library(quantmod)
    library(dplyr)
    library(plotly)
    library(ggplot2)
    library(broom)

Iremos baixar os dados (biblioteca quantmod) do Ibovespa e do PETR4:

    getSymbols("^BVSP", from = "2014-01-01" )
    getSymbols("PETR4.SA", from = "2014-01-01")

Os dados baixados são em formato XTS e há diversos dados (ohlcv e adjusted - Open, High, Low, Close, Volume e o preço ajustado). Como queremos trabalhar com apenas com o preço ajustado e no formato data.frame, será necessário realizar os passos abaixo.

    BVSP = data.frame(BVSP)
    BVSP = BVSP %>% select(Ibov = BVSP.Adjusted) %>%
    mutate(date = rownames(BVSP)) %>%
      filter(!is.na(Ibov))
    
    PETR4 = data.frame(PETR4.SA)
    PETR4 = PETR4 %>% select(Petr4 = PETR4.SA.Adjusted)%>%
      mutate(date = rownames(PETR4)) %>%
      filter(!is.na(Petr4))

Juntando os dois data.frames em um data.frame único e criando vetores dos retornos

    All_data = inner_join(PETR4,BVSP, by="date")
    All_data = All_data %>% mutate(Return_petr4 = Petr4/lag(Petr4,1)-1, 
                                   Return_ibov = Ibov/lag(Ibov,1)-1)

Fazendo o roling regression nos passos a seguir:

    Coef <- . %>% as.data.frame %>% lm %>% coef
    
    Beta_alpha = All_data  %>% 
      do(cbind(reg_col = select(., Return_petr4, Return_ibov) %>% 
                 rollapplyr(100, Coef, by.column = FALSE, fill = NA),
               date_col = select(., date))) %>%
      ungroup 

O argumento 100 nos diz que queremos que a janela seja 100 observações para cada regressão, e estamos regreindo o retorno da petrobras contra o retorno do Ibovespa.

Observe que o obtemos o valor do intercepto (alpha) e do beta. Mas queremos apenas plotar o beta, por isso estaremos filtrando os dados para beta e plotaremos em um gráfico utilizando o ggplot2. 

    Beta_alpha = Beta_alpha %>% filter(!is.na(`reg_col.(Intercept)`)) %>%
      select(date,beta = reg_col.Return_ibov)
    
    Beta_alpha$date = as.Date(Beta_alpha$date)
    ggplot(Beta_alpha, aes(date)) + 
               geom_line(aes(y = beta, colour = "beta")) + theme_bw() +
      scale_x_date(date_breaks = "1 year", 
                   date_labels = "%Y") + ggtitle("PETR4 - Beta Rolling Window (100 observations)")

{{< figure src="1.png" width="80%" >}}

Abaixo iremos fazer a regressão do beta mês a mês e iremos plotar o gráfico do beta.

    Beta_alpha_month = All_data %>% group_by(Yearmon = as.yearmon(date)) %>%
      do(Month_regression = tidy(lm(Return_petr4 ~ Return_ibov, data = .))) %>%
      unnest(Month_regression)
    
    Beta_alpha_month = Beta_alpha_month %>% filter(term == 'Return_ibov')
    Beta_alpha_month$Yearmon = as.Date(Beta_alpha_month$Yearmon)
    ggplot(Beta_alpha_month, aes(Yearmon)) + 
      geom_line(aes(y = estimate, colour = "beta")) + theme_bw() +
      scale_x_date(breaks = "1 year", 
                   date_labels = "%Y")+
      ggtitle("PETR4 - Beta Rolling Window (100 observations)")
      
{{< figure src="1.png" width="80%" >}}


Esse post pode ser bastante utilizado em TCC'S, abordando diferenças entre os betas estáticos e betas dinâmicos. 



{{% callout note %}}
