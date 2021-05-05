 ---

title: "Exemplos de busca de tend�ncias do Google Trend"

categories: []

date: '2021-05-05T00:00:00Z'

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
- Google Trends

authors:
- HenriqueMartins
- GersonJunior


---
## Google Trend - Buscas

Nesse post, Henrique Martins e Gerson J�nior ir�o fazer uma r�pida an�lise de tend�ncias na pesquisa do Google. Primeira an�lise � fazer um comparativo das tend�ncias de pesquisa de "Covid 19" versus "Vacina".
Primeiramente vamos carregar os pacotes necess�rios para o code.

    library(gtrendsR)
    library(ggplot2)
    library(scales)

Buscar as tendencias das palavras "Covid 19" e "Vacina"
    
    Vacina<-gtrends(keyword = "Vacina",geo = "BR",time = "today 12-m",gprop = c("web"),
                 category = 0,hl = "en-US",low_search_volume = FALSE,
                 cookie_url = "http://trends.google.com/Cookies/NID",
                 tz = 0,onlyInterest = FALSE)
    covid<-gtrends(keyword = "covid 19",geo = "BR",time = "today 12-m",gprop = c("web"),
                   category = 0,hl = "en-US",low_search_volume = FALSE,
                   cookie_url = "http://trends.google.com/Cookies/NID",
                   tz = 0,onlyInterest = FALSE)

Fazendo um tratamento nos dados.

    x     <-Vacina$interest_over_time$date 
    Vacina   <-Vacina$interest_over_time$hits
    covid <-covid$interest_over_time$hits
    
    e plotar o gr�fico de uma tend�ncia contra a outra.
    plot(covid~as.Date(x),type = "b",lty = 1,main = "",xlab = "",ylab = "",yaxt="none",
         col="darkgreen", cex=1.5,pch=16)
    par(new=TRUE)
    plot(Vacina~as.Date(x), type = "b",lty = 1,main = "",xlab = "",ylab = "",yaxt="none",
         col="red",cex=1.5,pch=16)
    legend("topright", legend=c("Vacina", "Covid 19"),col=c("red", "darkgreen"), lty=1:1, cex=1.0)
    mtext(side=1, line=2, "Meses", col="black", font=2, cex=1.5)
    mtext(side=2, line=2, "Hits", col="black", font=2, cex=1.5)
    mtext(side=3, line=2, "Pesquisa das palavra 'Vacina' e 'Covid-19' nos �ltimos 12 meses", col="black",font=2,cex=2.25)
    axis(2, seq(0,100),las=2, font=2, col="black")
    
{{< figure src="Plot1.png" width="80%" >}}

Podemos reparar numa queda da tend�ncia da busca da Covid, � plaus�vel que o come�o da pandemia al�m de assustar a popula��o, fez com que ela procurasse conte�do sobre sintomas, poss�veis tratamentos, e com o tempo reduzisse essa busca. E por outro lado, com o come�o da campanha de vacina��o, parte da popula��o buscou a palavra "vacina��o" para acompanhamento da campanha e do calend�rio da vacina��o.

Uma outra an�lise que n�s fizemos era sobre a palavra "futebol", n�s esperamos que o final do ano tenha picos de busca da palavra,pois � quando o Campeonato Brasileiro, Copa do Brasil e Libertadores se encontra nas rodadas finais e decisivas.

    Futebol <-gtrends(keyword = "Futebol",geo = "BR",time = "2015-03-01 2021-05-05",gprop = c("web", "news", "images", "froogle", "youtube"),
                      category = 0,hl = "en-US",low_search_volume = FALSE,
                      cookie_url = "http://trends.google.com/Cookies/NID",
                      tz = 0,onlyInterest = FALSE)
    
    date    <-Futebol$interest_over_time$date   
    Futebol   <-Futebol$interest_over_time$hits
    
    Futebol = data.frame(date,Futebol)
    Futebol$date = as.Date(Futebol$date)
    g1=ggplot(data = Futebol, aes(x = date, y = Futebol)) + geom_line() +   scale_x_date(breaks = seq(as.Date("2000-01-01"), as.Date("2021-01-01"), by="6 month"),labels=date_format("%m-%Y")) +theme(plot.title = element_text(color="darkblue", size=40, face="bold"),  panel.background = element_rect(fill = "grey95", colour = "grey95"),axis.title=element_text(size=14,face="bold"),title=element_text(size=14,face="bold", color="darkblue"),axis.text.y = element_text(face = "bold", color = "darkblue", size = 15),axis.text.x = element_text(face = "bold", color = "darkblue", size = 10, angle = 20))
    g1 = g1 + ggtitle("Pesquisas da palavra Futebol") +     theme(plot.title = element_text(size = 15, face = "bold"))
    g1

{{< figure src="Plot3.png" width="80%" >}}

Al�m da hip�tese ser confirmada, outro ponto importante � ver a queda brusca da busca por futebol no come�o da pandemia em 2020, al�m do foco da popula��o ter mudado, n�o havia jogos.

Se futebol ocorreu essa tend�ncia de aumentar as buscas no final do ano. N�s ficamos curiosos para saber sobre a tend�ncia de busca do maior clube da Am�rica. Por coincid�ncia, tamb�m clube do cora��o do autor que est� escrevendo esse post. Nesse caso, eu (Gerson) espero que o Flamengo tenha um �pice no final de 2019, ano que o clube venceu a copa libertadores e o brasileiro, vivenciando a �poca mais gloriosa da sua hist�ria.
    
    Flamengo <-gtrends(keyword = "Flamengo",geo = "BR",time = "2015-03-01 2021-05-05",gprop = c("web", "news", "images", "froogle", "youtube"),
                 category = 0,hl = "en-US",low_search_volume = FALSE,
                 cookie_url = "http://trends.google.com/Cookies/NID",
                 tz = 0,onlyInterest = FALSE)
    
    date    <-Flamengo$interest_over_time$date   
    Flamengo   <-Flamengo$interest_over_time$hits
    
    Flamengo = data.frame(date,Flamengo)
    Flamengo$date = as.Date(Flamengo$date)
    g2=ggplot(data = Flamengo, aes(x = date, y = Flamengo)) + geom_line() +   scale_x_date(breaks = seq(as.Date("2000-01-01"), as.Date("2021-01-01"), by="6 month"),labels=date_format("%m-%Y")) +theme(plot.title = element_text(color="darkblue", size=40, face="bold"),  panel.background = element_rect(fill = "grey95", colour = "grey95"),axis.title=element_text(size=14,face="bold"),title=element_text(size=14,face="bold", color="darkblue"),axis.text.y = element_text(face = "bold", color = "darkblue", size = 15),axis.text.x = element_text(face = "bold", color = "darkblue", size = 10, angle = 20))
    g2 = g2 + ggtitle("Pesquisas da palavra Flamengo") +     theme(plot.title = element_text(size = 15, face = "bold"))
    g2

{{< figure library="true" src="Plot3.png" width="80%" >}}

A hip�tese foi confirmada, al�m de uma queda na busca no come�o da pandemia, fen�meno com mesma explica��o que a palavra futebol.
A modalidade de negocia��o day-trade vem crescendo nas m�dias sociais, essa � uma modalidade de muito risco, vale a leitura do paper de Fernando Chague e Bruno Giovannetti (� poss�vel viver de day-trade?). Minha hip�tese que vem crescendo o n�mero de pesquisas sobre a palavra day-trade no google. 

    Day_trade <-gtrends(keyword = "Day Trade",geo = "BR",time = "2015-03-01 2021-05-05",gprop = c("web", "news", "images", "froogle", "youtube"),
                      category = 0,hl = "en-US",low_search_volume = FALSE,
                      cookie_url = "http://trends.google.com/Cookies/NID",
                      tz = 0,onlyInterest = FALSE)
    
    date    <-Day_trade$interest_over_time$date   
    Day_trade   <-Day_trade$interest_over_time$hits
    
    Day_trade = data.frame(date,Day_trade)
    Day_trade$date = as.Date(Day_trade$date)
    g3=ggplot(data = Day_trade, aes(x = date, y = Day_trade)) + geom_line() +   scale_x_date(breaks = seq(as.Date("2000-01-01"), as.Date("2021-01-01"), by="6 month"),labels=date_format("%m-%Y")) +theme(plot.title = element_text(color="darkblue", size=40, face="bold"),  panel.background = element_rect(fill = "grey95", colour = "grey95"),axis.title=element_text(size=14,face="bold"),title=element_text(size=14,face="bold", color="darkblue"),axis.text.y = element_text(face = "bold", color = "darkblue", size = 15),axis.text.x = element_text(face = "bold", color = "darkblue", size = 10, angle = 20))
    g3 = g3 + ggtitle("Pesquisas da palavra Day_trade") +     theme(plot.title = element_text(size = 15, face = "bold"))
    g3

{{< figure src="Plot4.png" width="80%" >}}

Hip�tese confirmada. Novamente ressaltando a leitura do paper anterior.

� ineg�vel que a mudan�a do BBB, mesclando celebridades com an�nimos e a entrada de Tiago Leifertc como apresentador deu um novo g�s ao programa. Mas ser� que as ultimas duas edi��es tiveram mais buscas pela palavra BBB?  Vamos aos dados.

    BBB <-gtrends(keyword = "BBB",geo = "BR",time = "2010-01-01 2021-04-01",gprop = c("web", "news", "images", "froogle", "youtube"),
                        category = 0,hl = "en-US",low_search_volume = FALSE,
                        cookie_url = "http://trends.google.com/Cookies/NID",
                        tz = 0,onlyInterest = FALSE)
    
    date    <-BBB$interest_over_time$date   
    BBB   <-BBB$interest_over_time$hits
    
    BBB = data.frame(date,BBB)
    BBB$date = as.Date(BBB$date)
    g4=ggplot(data = BBB, aes(x = date, y = BBB)) + geom_line() +   scale_x_date(breaks = seq(as.Date("2000-01-01"), as.Date("2021-01-01"), by="6 month"),labels=date_format("%m-%Y")) +theme(plot.title = element_text(color="darkblue", size=40, face="bold"),  panel.background = element_rect(fill = "grey95", colour = "grey95"),axis.title=element_text(size=14,face="bold"),title=element_text(size=14,face="bold", color="darkblue"),axis.text.y = element_text(face = "bold", color = "darkblue", size = 15),axis.text.x = element_text(face = "bold", color = "darkblue", size = 10, angle = 20))
    g4 = g4 + ggtitle("Pesquisas da palavra BBB") +     theme(plot.title = element_text(size = 15, face = "bold"))
    g4

{{< figure src="Plot5.png" width="80%" >}}

Podemos observer os picos no come�o do ano, logicamente, pois � nessa �poca que ocorre o programa e principalmente o aumento na busca das duas �ltimas edi��es. Pelo visto, a Globo acertou em cheio.
 
Ainda sobre o BBB, temos talvez o maior fen�meno entre os participantes, uma vit�ria na final com mais de 90%, vamos ver como foi a busca pela participante Juliete??

    Juliette <-gtrends(keyword = "Juliette Freire",geo = "BR",time = "2021-02-01 2021-05-01",gprop = c("web", "news", "images", "froogle", "youtube"),
                  category = 0,hl = "en-US",low_search_volume = FALSE,
                  cookie_url = "http://trends.google.com/Cookies/NID",
                  tz = 0,onlyInterest = FALSE)
    
    date    <-Juliette$interest_over_time$date   
    Juliette   <-Juliette$interest_over_time$hits
    
    Juliette = data.frame(date,Juliette)
    Juliette$date = as.Date(Juliette$date)
    g5=ggplot(data = Juliette, aes(x = date, y = Juliette)) + geom_line() +   scale_x_date(breaks = seq(as.Date("2000-01-01"), as.Date("2021-01-01"), by="2 month"),labels=date_format("%m-%Y")) +theme(plot.title = element_text(color="darkblue", size=40, face="bold"),  panel.background = element_rect(fill = "grey95", colour = "grey95"),axis.title=element_text(size=14,face="bold"),title=element_text(size=14,face="bold", color="darkblue"),axis.text.y = element_text(face = "bold", color = "darkblue", size = 15),axis.text.x = element_text(face = "bold", color = "darkblue", size = 10, angle = 20))
    g5 = g5 + ggtitle("Pesquisas da palavra Juliette") +     theme(plot.title = element_text(size = 15, face = "bold"))
    g5

{{< figure src="Plot6.png" width="80%" >}}


Enfim, voc� pode brincar, buscar outras palavras, fica ai nosso post. Querendo deixar que quem escreve o post (Gerson J�nior) � f� do Gil. Qualquer d�vida ou sugest�o pode enviar email. 

