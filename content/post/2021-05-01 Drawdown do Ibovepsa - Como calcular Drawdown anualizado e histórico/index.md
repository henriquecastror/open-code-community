---

title: "Drawdown do Ibovepsa - Como calcular Drawdown anualizado e histórico"

categories: []

date: '2021-05-01T00:00:00Z' 

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
- Drawdown
- Asset Allocation

authors:
- GersonJunior


---

## Fatores de Risco


Drawdown é uma medida que mensura a queda máxima em relação a um topo anterior. Portanto iremos calcular no post 2 drawdowns: o drawdown em cada momento (t) e o drawdown anualizado, nas seguintes formulas:

Drawdown  anualizado = (mínimo do ano / máximo do ano) -1

Drawdown no momento (t) = (índice no momento (t) / máximo histórico até o momento (t))-1

Iremos analisar o Ibovespa usando o package quantmod para obtenção de dados, iremos utilizar os dados de 2020 até a ultima observação como forma de exercício. O drawdown dos fundos é uma importante medida a ser analisada. Muitos fundos são extramemnte alavancados. Alavancagem é um recurso legítimo, mas drawdown excessivos mostra a falta de gestão de risco. O exercício é apenas para IBOV, mas recomendo a análise para os fundos que você tem interesse de virar cotista.

        
    library(quantmod)
    library(PerformanceAnalytics)
    library(lubridate)
Precisaremos de dados então vamos pegar os dados do Ibovespa (^BVSP) a partir de 2020.

    from.date <- as.Date("01/01/2020", format="%m/%d/%y")
    getSymbols("^BVSP", from = from.date)

Transformando o XTS em Data.frame.

    BVSP = data.frame(BVSP)
Esse passo é para filtrar os NA's.

    BVSP = BVSP %>% mutate(Return_day = ROC(BVSP.Close))  %>%  filter(BVSP.Close!="NA")
Transformando o nomes das linhas em colunas, dado que os nomes das linhas são as datas.

    BVSP <- cbind(Date = rownames(BVSP), BVSP)

Criando uma coluna com o ano. 

    BVSP$year = year(BVSP$Date)

Calculando o Drawdown anualizado.

    BVSP %>%
      group_by(year) %>%
      summarize("Drawdown ibov anual" = min(BVSP.Close)/max(BVSP.Close)-1)
    
       year `Drawdown ibov anual`
      <int>                 <dbl>
    1  2020                -0.468
    2  2021                -0.12

Podemos ver que o drawdown anualizado de 2020 foi de -0.46. Um alto drawdown, decorrente da crise do COVID-19. 
Agora vamos calcular o Drawdown histórico.

    draw_downs_Bovespa <- c()
    maxs_Bovespa <- c()
    max_p_Bovespa <- 0
    for(i in 1:nrow(BVSP)){
      max_p_Bovespa <- max(BVSP$BVSP.Close[i], max_p_Bovespa)
      draw_downs_Bovespa[i] <- BVSP$BVSP.Close[i]/max_p_Bovespa-1
      maxs_Bovespa[i] <- max_p_Bovespa
    }
    
    
    draw_downs_Bovespa = data.frame(cbind(BVSP$Date,draw_downs_Bovespa))
    draw_downs_Bovespa = draw_downs_Bovespa %>% rename(date = V1, draw_down = draw_downs_Bovespa) 
    draw_downs_Bovespa$date = as.Date(draw_downs_Bovespa$date , format =  "%Y-%m-%d")
    draw_downs_Bovespa$draw_down = as.numeric(draw_downs_Bovespa$draw_down)
    
Plotando o gráfico.

    g1 = ggplot(data = draw_downs_Bovespa, aes(x = date, y = draw_down)) + geom_area(fill="red4") +   scale_x_date(breaks = seq(as.Date("2020-01-01"), as.Date("2021-05-01"), by="3 month"),labels=date_format("%m-%Y")) +theme(plot.title = element_text(color="darkblue", size=40, face="bold"),  panel.background = element_rect(fill = "grey95", colour = "grey95"),axis.title=element_text(size=14,face="bold"),title=element_text(size=14,face="bold", color="darkblue"),axis.text.y = element_text(face = "bold", color = "darkblue", size = 15),axis.text.x = element_text(face = "bold", color = "darkblue", size = 15))
    g1 = g1 + ggtitle("Drawdown Ibovepsa") +     theme(plot.title = element_text(size = 15, face = "bold"))
    g1
    
{{< figure src="1.png" width="80%" >}}

