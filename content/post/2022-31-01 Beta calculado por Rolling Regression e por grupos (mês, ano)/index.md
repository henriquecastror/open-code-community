---

title: "Beta calculado por Rolling Regression e por grupos (m�s, ano)."

categories: []

date: '2022-31-01T00:00:00Z' 

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
- Finance3

authors:
- GersonJunior


---

H� diversas cr�ticas ao modelo CAPM. Uma cr�tica se deve ao beta ser est�tico. Para contornar essa limita��o, apresentamos 2 tipos de regress�o no post.

1) Beta por rolling regression - Utilizamos uma janela de X dados de observa��o e fa�amos uma regress�o linear com dados dessa janela obtendo um beta (dados da observa��o 1 at� X), a partir da� andamos 1 passo e regredimos mais uma vez (dados da observa��o 2 at�  X+1) e assim sucessivamente. 
2) Calculamos o beta por m�s, semestre ou ano.

Primeiramente iremos carregar as bibliotecas.

    library(quantmod)
    library(dplyr)
    library(plotly)
    library(ggplot2)
    library(broom)

Iremos baixar os dados (biblioteca quantmod) do Ibovespa e do PETR4:

    getSymbols("^BVSP", from = "2014-01-01" )
    getSymbols("PETR4.SA", from = "2014-01-01")

Os dados baixados s�o em formato XTS e h� diversos dados (ohlcv e adjusted - Open, High, Low, Close, Volume e o pre�o ajustado). Como queremos trabalhar com apenas com o pre�o ajustado e no formato data.frame, ser� necess�rio realizar os passos abaixo.

    BVSP = data.frame(BVSP)
    BVSP = BVSP %>% select(Ibov = BVSP.Adjusted) %>%
    mutate(date = rownames(BVSP)) %>%
      filter(!is.na(Ibov))
    
    PETR4 = data.frame(PETR4.SA)
    PETR4 = PETR4 %>% select(Petr4 = PETR4.SA.Adjusted)%>%
      mutate(date = rownames(PETR4)) %>%
      filter(!is.na(Petr4))

Juntando os dois data.frames em um data.frame �nico e criando vetores dos retornos

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

O argumento 100 nos diz que queremos que a janela seja 100 observa��es para cada regress�o, e estamos regreindo o retorno da petrobras contra o retorno do Ibovespa.

Observe que o obtemos o valor do intercepto (alpha) e do beta. Mas queremos apenas plotar o beta, por isso estaremos filtrando os dados para beta e plotaremos em um gr�fico utilizando o ggplot2. 

    Beta_alpha = Beta_alpha %>% filter(!is.na(`reg_col.(Intercept)`)) %>%
      select(date,beta = reg_col.Return_ibov)
    
    Beta_alpha$date = as.Date(Beta_alpha$date)
    ggplot(Beta_alpha, aes(date)) + 
               geom_line(aes(y = beta, colour = "beta")) + theme_bw() +
      scale_x_date(date_breaks = "1 year", 
                   date_labels = "%Y") + ggtitle("PETR4 - Beta Rolling Window (100 observations)")

{{< figure src="1.png" width="80%" >}}

Abaixo iremos fazer a regress�o do beta m�s a m�s e iremos plotar o gr�fico do beta.

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


Esse post pode ser bastante utilizado em TCC'S, abordando diferen�as entre os betas est�ticos e betas din�micos. 



{{% callout note %}}