---

title: "Exploring Brazilian data in a map"

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
- Open Science
- Brazil
- Finance
- Research
- Master
- Phd

authors:
- GersonJunior
- HenriqueCastroMartins


---

ç á é í ó ú ã à â ê ô û ã õ ü 

This is another work by [Gerson](https://scholar.google.com/citations?user=bbgB49g0N2cC&hl=pt-BR). He made all the codes this time, and I just wrote these few words here. Again, this is part of our project to foster Open Science in our research community and make coding more accessible. 

First, install and load these packages. You may need to update your R to version 4.02.

    library(udunits2)
    library(units)
    library(geobr)
    library(sf)
    library(ggplot2)
    library(cowplot)
    library(RColorBrewer)
    library(dplyr)

Then, manually create the data (e.g., GDP per capita) for each state. You could download using some open code, but for simplicity, we'll make it by hand. 
	
    dados <- structure(
    list(X = 1:27, 
       uf = c("Acre", "Alagoas", "Amapá", 
              "Amazônas", "Bahia", "Ceará", "Distrito Federal", "Espírito Santo", 
              "Goiás", "Maranhão", "Mato Grosso do Sul", "Mato Grosso", "Minas Gerais", 
              "Paraíba", "Paraná", "Pará", "Pernambuco", "Piauí", "Rio de Janeiro", 
              "Rio Grande do Norte", "Rio Grande do Sul", "Rondônia", "Roraima", 
              "Santa Catarina", "São Paulo", "Sergipe", "Tocantins"), 
       GDP_Per_Capita = c(17.636, 16.375, 20.247, 24.542, 19.324, 17.178, 85.661, 34.493, 28.272, 13.955, 38.925, 39.931, 29.223,
                          16.107, 38.772, 18.952, 19.623, 15.432, 44.222,19.242 ,40.362 , 25.554, 23.188, 42.149, 48.542, 18.442, 22.933)), class = "data.frame", row.names = c(NA, -27L))

      
A few more steps to create the map.

    states <- read_country(year = 2019)
    states$name_state <- tolower(states$name_state)
    dados$uf <- tolower(dados$uf)
    
    states <- dplyr::left_join(states, dados, by = c("name_state" = "uf")); states
    
    L = min(states$GDP_Per_Capita)
    S = max(states$GDP_Per_Capita)

  
  
Finally, create the map.  

    p = states %>% ggplot() + 
      geom_sf(aes(fill = GDP_Per_Capita ), size = .15) +   scale_fill_gradient(low = "red", high = "blue", name = "GDP Per Capita (R$)", limits = c(L, 50.000))+ 
      xlab("") +  ylab("") +geom_sf_label(aes(label = abbrev_state),label.padding = unit(0.5, "mm"),size = 3) 
    
    
    p = p +   labs(title = "GDP per Capita by State",caption  = "Authors: Gerson Júnior e Henrique Martins.") +
      theme(plot.caption = element_text(hjust = 0, face= "italic"), 
            plot.title.position = "plot", 
            plot.caption.position =  "plot") 
    
    p = p + theme(legend.position = "bottom") + theme(legend.title = element_text(size = 10),legend.text=element_text(size=10))
    plot(p)

    
This is what you get. Nice way to see the GDP of each of Brazilian's states, right?
    
{{< figure src="G1.png" width="80%" >}}    






## COVID situation in Brazil

You can create fancier stuff with the same code. We'll skip the explanation, but notice the structure is the same as above, but we are repeating it three times.


      dados1 <- structure(
      list(X = 1:27, 
           uf = c("Acre", "Alagoas", "Amapá", 
                  "Amazônas", "Bahia", "Ceará", "Distrito Federal", "Espírito Santo", 
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
    
    states1$Alerta = ifelse(states1$Taxa_de_Ocupação < 80, "Médio", "Crítico")
    
    
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
                  "Amazônas", "Bahia", "Ceará", "Distrito Federal", "Espírito Santo", 
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
                  "Amazônas", "Bahia", "Ceará", "Distrito Federal", "Espírito Santo", 
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

Here is the gif:


{{< figure library="true" src="explicit_my3.gif" width="80%"  >}}


We hope you like it!
