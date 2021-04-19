
rm(list = ls())
library(udunits2)
library(units)
library(geobr)
library(sf)
library(ggplot2)
library(cowplot)
library(RColorBrewer)
library(dplyr)

# PLOT 1
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


#JUNTAR O 3 PLOTS EM 1 
require(gridExtra)
grid.arrange(p1,p2,p3,nrow = 1)

# Fazer um gif
library(animation)
animation::saveGIF(
  expr = {
    plot(p1)
    plot(p2)
    plot(p3)
  },
  movie.name = "explicit_my3.gif"
)
