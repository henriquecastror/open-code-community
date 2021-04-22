---

title: "Criando Mapas no R: Mundo e Brasil"

categories: []

date: '2021-04-08T00:00:00Z'

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
- Mapas
- Brazil
- World
- Research
- Master
- Phd

authors:
- GersonJunior
- HenriqueCastroMartins


---

Estamos compartilhando nesse post um código é basicamente criação de 2 tipos de mapas: um para o Brasil e um para o Mundo. Usaremos dados abertos do Banco Mundial. O código é simples e você pode pagar o tempo todo.

## 1° Mapa - Um mapa do crescimento do PIB global (Mapa Mundo)
Primeiro, instale e carregue esses pacotes:

First, install and load these packages. You may need to update your R to version 4.02.

    library(WDI)
    library(highcharter)
    library(dplyr)
    library(maps)


   
Então, você precisa de dados. Portanto, faça o download usando o código a seguir. É uma pena que ainda não tenhamos os dados de 2020! Vamos usar 2019 em vez.

    GDP <- WDI(
    country = "all",
    indicator = "NY.GDP.MKTP.KD.ZG",
    start = 2019,
    end = 2019,
    extra = FALSE,
    cache = NULL)
    
Para simplificar, renomeie a coluna onde está o crescimento do PIB.

    names(GDP)[names(GDP) == "NY.GDP.MKTP.KD.ZG"] <- "GDP_Growth"

Aqui é onde você decide quais países deseja analisar. Vamos manter o simples por enquanto e usar apenas alguns controles.
    Countries  <- c("Brazil","Argentina","Chile","Russian Federation","United States","China","Germany","Australia","South Africa","Canada","India","Egypt, Arab Rep.","United Kingdom")
    
    GDP_Filter <- GDP[GDP$country %in% Countries ,]



Também precisaremos da lista de códigos ISO. Você pode encontrar os códigos ISO [aqui](https://www.iban.com/country-codes)

    Countries_iso3  <- c("BRA","ARG","CHL","RUS", "USA","CHN","DEU","AUS","ZAF","CAN","IND","EGY","GBR")


As linhas abaixo são necessárias para criar o mapa posteriormente. Basicamente, o mapa precisa dos códigos ISO3 para ler os países.

    dat <- iso3166
    dat <- rename(dat, "iso-a3" = a3 )
    dat = dat[dat$`iso-a3` %in% Countries_iso3 ,]
    GDP_Filter_Integer = as.integer(GDP_Filter$GDP_Growth)
    
Observe que a China está duplicada em "dat". Vamos removê-lo.
    
    dat<-dat[!duplicated(dat$sovereignty), ]


Aqui é onde você decide quais países deseja analisar. Vamos manter o simples por enquanto e usar apenas alguns controles.
    
    Countries  <- c("Brazil","Argentina","Chile","Russian Federation","United States","China","Germany","Australia","South Africa","Canada","India","Egypt, Arab Rep.","United Kingdom")
    GDP_Filter <- GDP[GDP$country %in% Countries ,]


Também precisaremos da lista de códigos ISO. Você pode encontrar os códigos ISO [aqui]( https://www.iban.com/country-codes)

    Countries_iso3  <- c("BRA","ARG","CHL","RUS", "USA","CHN","DEU","AUS","ZAF","CAN","IND","EGY","GBR")


As linhas abaixo são necessárias para criar o mapa posteriormente. Basicamente, o mapa precisa dos códigos ISO3 para ler os países.

    dat <- iso3166
    dat <- rename(dat, "iso-a3" = a3 )
    dat = dat[dat$`iso-a3` %in% Countries_iso3 ,]
    GDP_Filter_Integer = as.integer(GDP_Filter$GDP_Growth)

Observe que a China está duplicada em "dat". Vamos removê-lo.

    dat<-dat[!duplicated(dat$sovereignty), ]

Agora, vamos combinar os dados de crescimento do PIB com os códigos ISO3

    dat$GDP <- GDP_Filter$GDP_Growth

Finalmente, a parte divertida. Crie o mapa usando o código a seguir.


    hc<-hcmap(
      map = "custom/world-highres3", 
      data = dat, 
      joinBy = "iso-a3",
      value = "GDP",
      showInLegend = FALSE, 
      nullColor = "#DADADA",
      download_map_data = TRUE) %>%
      hc_mapNavigation(enabled = TRUE) %>%
      hc_legend(align = "center",
                verticalAlign = "top",
                layout = "horizontal",
                x = 100,
                y = 0) %>%
      hc_title(text = "GDP Growth in 2019 for selected Countries")
    
      hc

Isso é o que você precisa encontrar [aqui]( https://henriquemartins.net/html/highchart_map.html)


## 2° Mapa PIB per Capita Brasileiro por estado.
Primeiro, instale e carregue esses pacotes. Pode ser necessário atualizar seu R para a versão 4.02.

    library(udunits2)
    library(units)
    library(geobr)
    library(sf)
    library(ggplot2)
    library(cowplot)
    library(RColorBrewer)
    library(dplyr)

Em seguida, crie manualmente os dados (por exemplo, PIB per capita) para cada estado. Você pode fazer o download usando algum código aberto, mas para simplificar, vamos fazer isso manualmente. Se alguem tiver um code para pegar PIB per Capita para cada estado, por favor, envie email para [mailto:gersondesouzajunior00@gmail.com).
    
    dados <- structure(
    list(X = 1:27, 
       uf = c("Acre", "Alagoas", "Amapá", 
              "Amazónas", "Bahia", "Ceará", "Distrito Federal", "Espírito Santo", 
              "Goiás", "Maranhão", "Mato Grosso do Sul", "Mato Grosso", "Minas Gerais", 
              "Paraíba", "Paraná", "Pará", "Pernambuco", "Piauí", "Rio de Janeiro", 
              "Rio Grande do Norte", "Rio Grande do Sul", "Rondônia", "Roraima", 
              "Santa Catarina", "São Paulo", "Sergipe", "Tocantins"), 
       GDP_Per_Capita = c(17.636, 16.375, 20.247, 24.542, 19.324, 17.178, 85.661, 34.493, 28.272, 13.955, 38.925, 39.931, 29.223,
                          16.107, 38.772, 18.952, 19.623, 15.432, 44.222,19.242 ,40.362 , 25.554, 23.188, 42.149, 48.542, 18.442, 22.933)), class = "data.frame", row.names = c(NA, -27L))

Mais algumas etapas para criar o mapa.
   
    states <- read_country(year = 2019)
    states$name_state <- tolower(states$name_state)
    dados$uf <- tolower(dados$uf)
    
    states <- dplyr::left_join(states, dados, by = c("name_state" = "uf")); states
    
    L = min(states$GDP_Per_Capita)
    S = max(states$GDP_Per_Capita)

Finalmente, crie o mapa.
    
    p = states %>% ggplot() + 
      geom_sf(aes(fill = GDP_Per_Capita ), size = .15) +   scale_fill_gradient(low = "red", high = "blue", name = "GDP Per Capita (R$)", limits = c(L, 50.000))+ 
      xlab("") +  ylab("") +geom_sf_label(aes(label = abbrev_state),label.padding = unit(0.5, "mm"),size = 3) 
    
    
    p = p +   labs(title = "GDP per Capita by State",caption  = "Authors: Gerson J???nior e Henrique Martins.") +
      theme(plot.caption = element_text(hjust = 0, face= "italic"), 
            plot.title.position = "plot", 
            plot.caption.position =  "plot") 
    
    p = p + theme(legend.position = "bottom") + theme(legend.title = element_text(size = 10),legend.text=element_text(size=10))
    plot(p)
    
{{< figure src="G1.png" width="80%" >}}    


## 3° Criando GIFS pelo Mapa do Brasil - Situação COVID (DADOS FICTICIOS)
Você pode criar coisas mais sofisticadas com o mesmo código. Vamos pular a explicação, mas observe que a estrutura é a mesma acima, mas estamos repetindo isso três vezes.


    
    dados1 <- structure(
      list(X = 1:27, 
           uf = c("Acre", "Alagoas", "Amapá", 
              "Amazónas", "Bahia", "Ceará", "Distrito Federal", "Espírito Santo", 
              "Goiás", "Maranhão", "Mato Grosso do Sul", "Mato Grosso", "Minas Gerais", 
              "Paraíba", "Paraná", "Pará", "Pernambuco", "Piauí", "Rio de Janeiro", 
              "Rio Grande do Norte", "Rio Grande do Sul", "Rondônia", "Roraima", 
              "Santa Catarina", "São Paulo", "Sergipe", "Tocantins"), 
           Taxa_de_Ocupação = c(90, 85, 94, 79, 87, 97, 99, 94, 99, 89, 106, 99, 93,
                                83, 96, 87, 97, 96, 85, 96, 97, 96, 64, 99, 92, 85, 90)), class = "data.frame", row.names = c(NA, -27L))
    states <- read_country(year=2019)
    states$name_state <- tolower(states$name_state)
    dados1$uf <- tolower(dados1$uf)
    
    states1 <- dplyr::left_join(states, dados1, by = c("name_state" = "uf")); states
    
    states1$Alerta = ifelse(states1$Taxa_de_Ocupaçãoo < 80, "Médio", "Crítico")
    
    
    p1 = states1 %>% ggplot() + 
      geom_sf(aes(fill = Alerta), size = .15) + scale_fill_manual(values = c("red", "#d8b365"))+geom_sf_label(aes(label = abbrev_state),
                                                                                                                             label.padding = unit(0.5, "mm"),size = 3) + 
      xlab("") +  ylab("") 
                                                                                                                                                                                                                                                                                                                                        size = 3)
    p1 = p1 + labs(title = "Taxa de Ocupação(%) de leitos UTI-Covid para adultos (TIME 1)",
           subtitle = "Dados Fictícios - Intuito Educacional",
           caption  = "Authors: Gerson Júnior e Henrique Martins") +
      theme(plot.caption = element_text(hjust = 0, face= "italic"), #Default is hjust=1
            plot.title.position = "plot", #NEW parameter. Apply for subtitle too.
            plot.caption.position =  "plot") #NEW parameter) 
    
    p1 = p1 + theme(legend.position = "bottom") + theme(legend.title = element_text(size = 10),legend.text=element_text(size=10))
    plot(p1)
    
    
    # PLOT 2
    ##################
    dados2 <- structure(
      list(X = 1:27, 
           uf = c("Acre", "Alagoas", "Amapá", 
              "Amazónas", "Bahia", "Ceará", "Distrito Federal", "Espírito Santo", 
              "Goiás", "Maranhão", "Mato Grosso do Sul", "Mato Grosso", "Minas Gerais", 
              "Paraíba", "Paraná", "Pará", "Pernambuco", "Piauí", "Rio de Janeiro", 
              "Rio Grande do Norte", "Rio Grande do Sul", "Rondônia", "Roraima", 
              "Santa Catarina", "São Paulo", "Sergipe", "Tocantins"), 
           Taxa_de_Ocupação = c(80, 70, 60, 50, 20, 30, 50, 60, 85, 90, 70, 50, 60,
                                100, 40, 32, 48, 55, 60, 70, 75, 84, 50, 44, 44, 42, 32)), class = "data.frame", row.names = c(NA, -27L))
    
    dados2$uf <- tolower(dados2$uf)
    
    states2 <- dplyr::left_join(states, dados2, by = c("name_state" = "uf")); states
    
    states2$Alerta = ifelse(states2$Taxa_de_Ocupação < 80, "Médio", "Crítico")
    
    
    p2= states2   %>%ggplot() + 
      geom_sf(aes(fill = Alerta), size = .15) + scale_fill_manual(values = c("red", "#d8b365")) +geom_sf_label(aes(label = abbrev_state),
                                                                                                                                 label.padding = unit(0.5, "mm"),
                                                                                                                                 size = 3)+ 
      labs(title = "Taxa de Ocupação(%) de leitos UTI-Covid para adultos (TIME 2)",
           subtitle = "Dados Fictícios - Intuito Educacional",
           caption  = "Authors: Gerson Júnior e Henrique Martins") +
      theme(plot.caption = element_text(hjust = 0, face= "italic"), #Default is hjust=1
            plot.title.position = "plot", #NEW parameter. Apply for subtitle too.
            plot.caption.position =  "plot") #NEW parameter
    
    
    p2 = p2 + theme(legend.position = "bottom") + theme(legend.title = element_text(size = 10),legend.text=element_text(size=10))
    plot(p2)
    
    # PLOT 3
    ##################
    dados3 <- structure(
      list(X = 1:27, 
           uf = c("Acre", "Alagoas", "Amapá", 
              "Amazónas", "Bahia", "Ceará", "Distrito Federal", "Espírito Santo", 
              "Goiás", "Maranhão", "Mato Grosso do Sul", "Mato Grosso", "Minas Gerais", 
              "Paraíba", "Paraná", "Pará", "Pernambuco", "Piauí", "Rio de Janeiro", 
              "Rio Grande do Norte", "Rio Grande do Sul", "Rondônia", "Roraima", 
              "Santa Catarina", "São Paulo", "Sergipe", "Tocantins"), 
           Taxa_de_Ocupação = c(50, 70, 90, 50, 20, 90, 50, 40, 85, 80, 90, 75, 60,
                                60, 40, 32, 48, 85, 60, 85, 75, 60, 50, 44, 44, 42, 32)), class = "data.frame", row.names = c(NA, -27L))
    
    dados3$uf <- tolower(dados3$uf)
    
    states3 <- dplyr::left_join(states, dados3, by = c("name_state" = "uf")); states
    
    states3$Alerta = ifelse(states3$Taxa_de_Ocupação < 80, "Médio", "Crítico")
    
    
    p3= states3   %>%ggplot() + 
      geom_sf(aes(fill = Alerta), size = .15) + scale_fill_manual(values = c("red", "#d8b365")) +geom_sf_label(aes(label = abbrev_state),
                                                                                                               label.padding = unit(0.5, "mm"),
                                                                                                               size = 3)+ 
      labs(title = "Taxa de Ocupação(%) de leitos UTI-Covid para adultos (TIME 3)",
           subtitle = "Dados Fictícios - Intuito Educacional",
           caption  = "Authors: Gerson Júnior e Henrique Martins") +
      theme(plot.caption = element_text(hjust = 0, face= "italic"), #Default is hjust=1
            plot.title.position = "plot", #NEW parameter. Apply for subtitle too.
            plot.caption.position =  "plot") #NEW parameter
    
    
    p3 = p3 + theme(legend.position = "bottom") + theme(legend.title = element_text(size = 10),legend.text=element_text(size=10))
    plot(p3)

Now, for fun, let's create a gif.

#GIF
    
    require(gridExtra)
    grid.arrange(p1,p2,p3,nrow = 1)
    
    library(animation)
    animation::saveGIF(
      expr = {
        plot(p1)
        plot(p2)
        plot(p3)
      },
      movie.name = "Gif1.gif"
    )

{{< figure library="true" src="explicit_my3.gif" width="80%"  >}}

Espero que tenha gostado. 