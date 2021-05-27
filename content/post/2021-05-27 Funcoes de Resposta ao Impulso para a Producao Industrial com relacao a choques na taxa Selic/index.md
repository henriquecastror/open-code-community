---

title: "FunÃ§Ãµes de Resposta ao Impulso para a ProduÃ§Ã£o Industrial com relaÃ§Ã£o a choques na taxa Selic"

categories: []

# MUDE APENAS ANO DIA E MES PARA O DIA QUE VOCE NOS ENVIOU
date: '2021-05-25T00:00:00Z' 

draft: no

featured: no

gallery_item: null

image:
  caption: 
  focal_point: 
  preview_only: 

projects: []

subtitle: null

summary: null

bibliography: bibliografia1.bib

# DIGITE NA LISTA ABAIXO OS TRACKS DO SEU CODIGO
tags: 
- Open Data
- Macroeconomia
- Brasil
- PolÃ­tica monetÃ¡ria
- ProduÃ§Ã£o industrial
- Taxa Selic
- VAR
- VEC
- FunÃ§Ã£o de Resposta ao Impulso

# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
- MohammedKaebi


---

# MotivaÃ§Ã£o

A taxa Selic se encontra em nÃ­veis extremamente baixos, caracterizando um nÃ­vel de estÃ­mulo monetÃ¡rio que tem colocado em risco o cumprimento das metas de inflaÃ§Ã£o no horizonte relevante para a polÃ­tica monetÃ¡ria do Banco Central do Brasil (BCB). Sendo assim, como indicado nas Ãºltimas atas do COPOM (veja @ataBCB2021Marco e @ataBCB2021Maio), haverÃ¡ um processo de normalizaÃ§Ã£o da taxa de juros nos prÃ³ximos meses, o que poderÃ¡ gerar impactos em termos de reaÃ§Ã£o da indÃºstria. Com isso, iremos estimar FunÃ§Ãµes de Resposta ao Impulso derivadas de Modelos de CorreÃ§Ã£o de Erros Vetorial (VEC) para analisar qual seria a reaÃ§Ã£o da produÃ§Ã£o industrial a um choque ortogonal na taxa Selic.

SerÃ£o analisados os seguintes segmentos da produÃ§Ã£o industrial:

- IndÃºstria geral
- IndÃºstrias extrativas
- IndÃºstrias de transformaÃ§Ã£o
- ProduÃ§Ã£o de bens de capital
- ProduÃ§Ã£o de bens intermediÃ¡rios
- ProduÃ§Ã£o de bens durÃ¡veis
- ProduÃ§Ã£o de bens nÃ£o durÃ¡veis

As bibliotecas necessÃ¡rias sÃ£o:

    library(tidyverse)
    library(lubridate)
    library(seasonal) # dessazonalizaÃ§Ã£o
    library(readxl) # leitura de excel
    library(sidrar) # dados do IBGE
    library(ipeadatar) # dados do ipeadata
    library(rbcb) # dados do BCB. Este pacote nÃ£o estÃ¡ disponÃ­vel no CRAN, para instalar use devtools::install_github('wilsonfreitas/rbcb')
    library(fredr) # dados do FRED
    library(urca) # testes de raiz unitÃ¡ria e cointegraÃ§Ã£o
    library(vars) # modelagem de VAR
    library(gridExtra) # juntar grÃ¡ficos em um grid
    
    
    
Tema padrÃ£o para os grÃ¡ficos:

    theme_set(theme_classic())
    theme_update(panel.grid.major.y = element_line(linetype = "dotted", color = "gray70"),
                 axis.title = element_text(size = 9, color = "black"),
                 axis.text = element_text(size = 8, color = "black"),
                 plot.title = element_text(size = 12, color = 'black'),
                 plot.caption = element_text(size = 13, color = 'black'),
                 plot.subtitle = element_text(size = 13, color = 'black'))

# Dados

## VariÃ¡veis utilizadas

Com base na literatura de maior referÃªncia para este tipo de estudo (veja @bernanke1992, @evans1996, e @bernanke1998) e uma referÃªncia que faz um estudo similar para outros paÃ­ses (veja @dedola2005), serÃ£o utilizadas as seguintes variÃ¡veis para compÃ´r o vetor de variÃ¡veis endÃ³genas:

- Taxa de juros de curto prazo (mÃ©dia mensal da Selic diÃ¡ria)
- ProduÃ§Ã£o industrial (PIM-PF)
- InflaÃ§Ã£o mensal (variaÃ§Ã£o mensal do IPCA)
- Taxa de cÃ¢mbio (mÃ©dia mensal da taxa de cÃ¢mbio R\$/U\$D, em *ln*)
- Agregado monetÃ¡rio (Meios de pagamento - M1, em *ln*)
- ConcessÃµes de crÃ©dito (em *ln*)

AlÃ©m disso, tambÃ©m serÃ£o consideradas as seguintes variÃ¡veis exÃ³genas:

- Taxa de juros dos EUA (*fedfunds*)
- Ãndice de preÃ§os global de commodities (em *ln*)
- Medida de risco paÃ­s para o Brasil (EMBI+, em *ln*)
- Indicadora de recessÃ£o para o Brasil

Os dados utilizados terÃ£o peridiocidade mensal, com inÃ­cio em 2002-01-01 e fim em 2021-03-01.

## Baixando os dados

Com exceÃ§Ã£o da variÃ¡vel indicadora de recessÃ£o para o Brasil, todas as outras podem ser obtidas diretamente no R.

Taxa Selic (fonte: BCB):

    code <- c(selic_daily = 1178)
    juros_db <- rbcb::get_series(code, "2002-01-01") # baixa os dados do SGS do BCB

    ## Calculando a mÃ©dia mensal
    juros <- juros_db %>%
     mutate(month = month(date), year = year(date)) %>%
     group_by(month, year) %>%
     summarise(selic = mean(selic_daily)) %>%
     mutate(day = 1, date = as.Date(paste(year, month, day, sep = "-"))) %>%
     ungroup() %>%
     dplyr::select(date, selic) %>%
     arrange(date)
     
ProduÃ§Ã£o industrial (fonte: IBGE): 

    ## Bens de capital, Bens intermediÃ¡rios, bens de consumo durÃ¡veis, bens de consumo semidurÃ¡veis e nÃ£o durÃ¡veis
    pim_1 <-
      '/t/3651/n1/all/v/3134/p/all/c543/129278,129283,129301,129305/d/v3134%201' %>%
      get_sidra(api = .) %>%
      dplyr::mutate(date = parse_date(`MÃªs (CÃ³digo)`, format = '%Y%m')) %>%
      dplyr::select(date, "Grandes categorias econÃ´micas", Valor) %>%
      pivot_wider(names_from = "Grandes categorias econÃ´micas", values_from = Valor)

    ## IndÃºstria geral, extrativa e transformaÃ§Ã£o
      pim_2 <-
      '/t/3653/n1/all/v/3134/p/all/c544/129314,129315,129316/d/v3134%201' %>%
      get_sidra(api = .) %>%
      mutate(date = parse_date(`MÃªs (CÃ³digo)`, format = '%Y%m')) %>%
      dplyr::select(date, "SeÃ§Ãµes e atividades industriais (CNAE 2.0)", Valor) %>%
      pivot_wider(names_from = "SeÃ§Ãµes e atividades industriais (CNAE 2.0)", values_from = Valor)

    ## Juntando em uma tabela
    PIM <- left_join(pim_2, pim_1, by = "date") %>% 
    rename("IndÃºstria geral" = "1 IndÃºstria geral",
         "IndÃºstrias extrativas" = "2 IndÃºstrias extrativas",
         "IndÃºstrias de transformaÃ§Ã£o" = "3 IndÃºstrias de transformaÃ§Ã£o",
         "Bens de capital" = "1 Bens de capital",
         "Bens intermediÃ¡rios" = "2 Bens intermediÃ¡rios",
         "Bens de consumo durÃ¡veis" = "31 Bens de consumo durÃ¡veis",
         "Bens de consumo nÃ£o durÃ¡veis" = "32 Bens de consumo semidurÃ¡veis e nÃ£o durÃ¡veis")

InflaÃ§Ã£o (fonte: IBGE):

    IPCA_SA <- get_sidra(api = "/t/118/n1/all/v/all/p/all/d/v306%202") %>% 
      mutate(date = parse_date(`MÃªs (CÃ³digo)`, format = '%Y%m')) %>% 
      dplyr::select(date, IPCA_M = Valor) %>%  
      filter(date >= as.Date("2002-01-01"))
    
Taxa de cÃ¢mbio (fonte: BCB):

    code <- c(cambio = 3698)
    usd <- rbcb::get_series(code, "2002-01-01") # baixa os dados do SGS do BCB
    
Agregado monetÃ¡rio (fonte: BCB):

    code <- c(money_supply = 27841)
    money <- rbcb::get_series(code, "2002-01-01") # baixa os dados do SGS do BCB

ConcessÃµes de crÃ©dito (aplicamos tambÃ©m o mÃ©todo X13-ARIMA-SEATS para dessazonalizar; fonte: BCB):

    code <- c(credito = 21277)
    credito <- rbcb::get_series(code, "2002-01-01") # baixa os dados do SGS do BCB
    credito <- credito %>% 
     mutate(credito_sa = final(seas(ts(credito, start = c(2002, 1), frequency = 12)))) %>% # dessazonalizaÃ§Ã£o
     dplyr::select(date, credito_sa)

    credito$credito_sa <- as.numeric(credito$credito_sa)


FEDFUNDS (fonte: FRED):
Para baixar os dados do FRED, Ã© necessÃ¡rio especificar a chave do API. Veja como obter [aqui](https://research.stlouisfed.org/docs/api/api_key.html).

    fredr_set_key("1234567890abcdefg") # Insira aqui a sua chave do API do FRED
    
    fedfunds <- fredr(
      series_id = "FEDFUNDS",
      observation_start = as.Date("2002-01-01"),
      observation_end = as.Date("2021-03-01")
      ) %>%
      dplyr::select(date, value) %>% 
      rename(fedfunds = value)
      
Ãndice de preÃ§os global de commodities (fonte: FMI, via FRED):

    commodities <- fredr(
     series_id = "PALLFNFINDEXM",
      observation_start = as.Date("2002-01-01"),
      observation_end = as.Date("2021-03-01")
      ) %>%
      dplyr::select(date, value)%>% 
      rename(commodities = value)

Risco Brasil (fonte: JP Morgan, via ipeadata):

    EMBI_db <- ipeadata("JPM366_EMBI366", quiet = FALSE) %>% 
     dplyr::select(date, value)
    EMBI <- EMBI_db %>%
      mutate(month = month(date), year = year(date)) %>%
      group_by(month, year) %>%
      summarise(EMBI = mean(value)) %>%
      mutate(day = 1, date = as.Date(paste(year, month, day, sep = "-"))) %>%
      ungroup() %>%
      dplyr::select(date, EMBI) %>%
      arrange(date) %>% 
      filter(date >= as.Date("2002-01-01"), date <= as.Date("2021-03-01"))
      
Indicadora de recessÃ£o para o Brasil (fonte: CODACE/FGV). Baise o excel {{% staticref "rececoes_codace.xlsx" "newtab" %}} aqui{{% /staticref %}}:

    dummy_recession <- read_excel("rececoes_codace.xlsx")
    dummy_recession$date <- as.Date(dummy_recession$date)
    dummy_recession <- dummy_recession %>% 
      filter(date >= as.Date("2002-01-01"))
      
Juntando os dados em uma tabela para as endÃ³genas e uma para as exÃ³genas:

    db_industry <- left_join(PIM, juros, by = 'date') %>%
      left_join(IPCA_SA, by = 'date') %>%
      left_join(usd, by = 'date') %>%
      left_join(credito, by = 'date') %>%
      left_join(money, by = 'date') %>% 
     mutate(
      log_money_supply = log(money_supply),
      log_credito_sa = log(credito_sa),
      log_cambio = log(cambio)
      ) %>% # transforma a inflaÃ§Ã£o, crÃ©dito e M1 para ln
     dplyr::select(-cambio, -credito_sa, -money_supply)
      
    exogen <-  as.matrix(cbind(dummy_recession[, 2],
                           fedfunds[, 2],
                           log(commodities[, 2]),
                           log(EMBI[, 2])))
                           
# Modelos

A mensuraÃ§Ã£o dos efeitos da polÃ­tica monetÃ¡ria segue nos moldes de @dedola2005, sendo realizada em duas etapas. Primeiro Ã© estimado um modelo mais geral, utilizando apenas a ProduÃ§Ã£o Industrial Geral como variÃ¡vel de produÃ§Ã£o e as outras variÃ¡veis endÃ³genas e exÃ³genas. Na segunda etapa, incluÃ­mos a ProduÃ§Ã£o Industrial Geral e mais uma variÃ¡vel de produÃ§Ã£o industrial em nÃ­vel mais especÃ­fico. EntÃ£o, serÃ£o estimados no total sete modelos, sendo um deles contendo apenas a atividade em nÃ­vel geral e o restante tambÃ©m contendo a atividade industrial em nÃ­vel mais desagregado.

Nesse tipo de modelo a ordenaÃ§Ã£o das variÃ¡veis endÃ³genas no vetor importa, devendo ser feita com base no seu grau de exogeneidade. A ordenaÃ§Ã£o adotada foi: nÃ­vel de atividade, inflaÃ§Ã£o mensal, taxa de juros de curto prazo, agregado monetÃ¡rio, concessÃµes de crÃ©dito e taxa de cÃ¢mbio. Para a etapa seguinte, a variÃ¡vel de atividade mais especÃ­fica foi ordenada apÃ³s o produto em nÃ­vel mais geral.

## Testes de raiz unitÃ¡ria

Para que um modelo do tipo VAR($p$) seja adequado, Ã© necessÃ¡rio que este seja estacionÃ¡rio, implicando na necessidade de ausÃªncia de caracterÃ­sticas que tornam o sistema de equaÃ§Ãµes nÃ£o-estacionÃ¡rio. Uma caracterÃ­stica usual em sÃ©ries econÃ´micas que podem resultar na nÃ£o-estacionariedade do sistema Ã© a presenÃ§a de tendÃªncia estocÃ¡stica. Uma soluÃ§Ã£o para isso seria levar em consideraÃ§Ã£o as variÃ¡veis em sua primeira diferenÃ§a, o que, na maioria dos casos, torna a sÃ©rie estacionÃ¡ria. PorÃ©m, ao aplicar essa transformaÃ§Ã£o e construir um VAR em diferenÃ§as, informaÃ§Ãµes importantes acerca de uma possÃ­vel relaÃ§Ã£o de longo prazo entre as sÃ©ries acaba sendo descartada. Nesse sentido, um modelo do tipo VEC corrige este problema quando as sÃ©ries em questÃ£o sÃ£o nÃ£o-estacionÃ¡rias e cointegradas, ou seja, apresentam uma tendÃªncia estocÃ¡stica em comum. Assim, um VEC faz com que seja possÃ­vel analisar a dinÃ¢mica de curto e longo prazo entre as variÃ¡veis, em que, no curto prazo, os desvios da relaÃ§Ã£o de longo prazo sÃ£o corrigidos, e, no longo prazo, Ã© considerada a relaÃ§Ã£o de cointegraÃ§Ã£o entre elas.

EntÃ£o, primeiro vamos verificar se as sÃ©ries em questÃ£o apresentam tendÃªncia estocÃ¡stica a partir de testes de raiz unitÃ¡ria de @ADF1981, em que a hipÃ³tese nula do teste Ã© que a sÃ©rie Ã© nÃ£o estacionÃ¡ria. Para isso, utilizamos a funÃ§Ã£o `ur.df` do pacote `urca`:

    summary(ur.df(db_industry$IPCA_M, type = 'drift', selectlags = "AIC", lags = 12))
    summary(ur.df(db_industry$selic, type = 'trend', selectlags = "AIC", lags = 12))
    summary(ur.df(db_industry$log_money_supply, type = 'trend', selectlags = "AIC", lags = 12))
    summary(ur.df(db_industry$log_credito_sa, type = 'trend', selectlags = "AIC", lags = 12))
    summary(ur.df(db_industry$log_cambio, type = 'trend', selectlags = "AIC", lags = 12))

    summary(ur.df(db_industry$`IndÃºstria geral`, type = 'drift', selectlags = "AIC", lags = 6))
    summary(ur.df(db_industry$`IndÃºstrias extrativas`, type = 'drift', selectlags = "AIC", lags = 6))
    summary(ur.df(db_industry$`IndÃºstrias de transformaÃ§Ã£o`, type = 'drift', selectlags = "AIC", lags = 6))
    summary(ur.df(db_industry$`Bens de capital`, type = 'drift', selectlags = "AIC", lags = 6))
    summary(ur.df(db_industry$`Bens intermediÃ¡rios`, type = 'drift', selectlags = "AIC", lags = 6))
    summary(ur.df(db_industry$`Bens de consumo durÃ¡veis`, type = 'drift', selectlags = "AIC", lags = 6))
    summary(ur.df(db_industry$`Bens de consumo nÃ£o durÃ¡veis`, type = 'drift', selectlags = "AIC", lags = 6))
   
Os testes nÃ£o nos fornecem evidÃªncias para rejeitar a hipÃ³tese de presenÃ§a de tendÃªncia estocÃ¡stica em diversas das variÃ¡veis a 5% de significÃ¢ncia (i.e. 95% de confianÃ§a), fazendo com que um VAR($p$) em nÃ­veis nÃ£o seja adequado. EntÃ£o, iremos verificar se hÃ¡ a existÃªncia de cointegraÃ§Ã£o entre as variÃ¡veis, para que, entÃ£o, possamos representar um VAR($p$) em nÃ­vel por um VEC($p-1$), a partir do Teorema da RepresentaÃ§Ã£o de @granger1987.

## Definindo e estimando os modelos

O nÃºmero de defasagens utilizado em um modelo do tipo VEC vem do nÃºmero de defasagens utilizada no VAR em nÃ­vel, mesmo que este nÃ£o seja adequado com a presenÃ§a de variÃ¡veis nÃ£o estacionÃ¡rias. EntÃ£o, primeiro iremos encontrar a ordem $p$ do VAR, para entÃ£o testar a presenÃ§a de cointegraÃ§Ã£o e, caso esta seja evidenciada, estimaremos um VEC com ordem $p-1$.

Para escolher a ordem $p$ do VAR, utilizaremos a funÃ§Ã£o `VARselect`, que computa os critÃ©rios de informaÃ§Ã£o do modelo para diferentes defasagens. EntÃ£o, estimaremos o modelo com a funÃ§Ã£o `VAR` e verificaremos se hÃ¡ ausÃªncia de correlaÃ§Ã£o serial nos resÃ­duos com a funÃ§Ã£o `serial.test` (o lag escolhido para esse teste deve ser suficientemente grande para que a estatÃ­stica do teste seja vÃ¡lida, para mais detalhes veja @lutkepohl2006). Depois, serÃ¡ conduzido o teste de coitegraÃ§Ã£o de @johansen1991 com a funÃ§Ã£o `ca.jo` e, caso seja verificada, estimaremos um VEC com ordem $p-1$ e o transformaremos em um VAR com uso da funÃ§Ã£o `vec2var`, alÃ©m de verificar a ausÃªncia de correlaÃ§Ã£o serial nos resÃ­duos. Por fim, estimaremos a FunÃ§Ã£o de Resposta ao Impulso com relaÃ§Ã£o a um choque na taxa Selic, utilizando a funÃ§Ã£o `irf`, em que tambÃ©m adicionamos um intervalo de confianÃ§a de 95% obtido via bootstrap com 250 iteraÃ§Ãµes.

Dado que iremos estimar sete modelos diferentes que possuem um passa-a-passo idÃªntico, demonstraremos o cÃ³digo para dois modelos, o geral e um especÃ­fico, para que nÃ£o fique muito repetitivo. Para estimar o restante, bastaria replicar o mesmo processo, apenas alterando a numeraÃ§Ã£o dos objetos.

### Modelo 1: IndÃºstria Geral

    # Renomeando a principal variÃ¡vel por simplicidade e mantendo apenas as variÃ¡veis relevantes para este modelo
    db_industry_mod1 <- db_industry %>%
      rename(Y_industry = `IndÃºstria geral`) %>%
      dplyr::select(Y_industry,
                    IPCA_M,
                    selic,
                    log_money_supply,
                    log_credito_sa,
                    log_cambio)

    # Transformando em objeto Time Series
    db_industry_mod1 <-
     ts(db_industry_mod1,
     start = c(2002, 1),
     frequency = 12)
     
    # Verificando a ordem do VAR com base nos CritÃ©rios de InformaÃ§Ã£o 
     VARselect(
     db_industry_mod1,
     lag.max = 12,
     type = 'both',
     exogen = exogen,
     season = 12 # dummies mensais
     )
     
     # Estimando o VAR
     model1_var <- VAR(db_industry_mod1,
                      p = 2, # defasagem escolhida
                      type = 'both',
                      season = 12,
                      exogen = exogen)
                      
    # Teste de correlaÃ§Ã£o serial
    serial.test(model1_var, lags.pt = 30)
    
    # Verificando a presenÃ§a de cointegraÃ§Ã£o
    jotest <- ca.jo(
      db_industry_mod1,
      type = "trace",
      K = 2, # defasagem escolhida para o VAR
      ecdet = "trend", # 
      spec = "longrun",
      dumvar = exogen,
      season = 12
    ) 

    summary(jotest) # indica 4 relaÃ§Ãµes de cointegraÃ§Ã£o

    # Transformando o VEC em VAR
    model1 <- vec2var(jotest, r = 4) # r indica o nÃºmero de relaÃ§Ãµes de cointegraÃ§Ã£o

    # Teste de correlaÃ§Ã£o serial
    serial.test(model1, lags.pt = 30)

    # Estimando a e plotando FunÃ§Ã£o de Resposta ao Impulso

    Y_IRF_mod1 <-
     irf(
       model1,
       impulse = "selic",
       response = "Y_industry",
       n.ahead = 36,
       boot = TRUE,
       ci = 0.95,
       runs = 250,
       seed = 1414
    ) 

    g1 <- tibble(
     IRF = Y_IRF_mod1$irf$selic,
     Lower = Y_IRF_mod1$Lower$selic,
     Upper = Y_IRF_mod1$Upper$selic
    ) %>%
    ggplot(aes(x = seq(0, 36, 1))) +
    geom_line(aes(y = IRF), size = 1.3, color = "#1874CD") +
    geom_line(aes(y = Lower), color = 'red', linetype = "dashed") +
    geom_line(aes(y = Upper), color = 'red', linetype = "dashed") +
    geom_ribbon(aes(ymin = Lower, ymax = Upper),
              alpha = 0.2,
              fill = "#1874CD") +
    geom_hline(aes(yintercept = 0), color = "black") +
    labs(title = 'ProduÃ§Ã£o Industrial Geral',
       x = 'Meses apÃ³s o choque',
       y = '')

### Modelo 2: IndÃºstria Geral + IndÃºstrias Extrativas

    # Renomeando a principal variÃ¡vel por simplicidade e mantendo apenas as variÃ¡veis relevantes para este modelo
    db_industry_mod2 <- db_industry %>%
     rename(Y_industry = `IndÃºstria geral`,
         Y_industry_extrat = `IndÃºstrias extrativas`) %>%
     dplyr::select(Y_industry,
                Y_industry_extrat,
                IPCA_M,
                selic,
                log_money_supply,
                log_credito_sa,
                log_cambio)

    # Transformando em objeto Time Series
    db_industry_mod2 <-
      ts(db_industry_mod2,
       start = c(2002, 1),
       frequency = 12)
  
    # Verificando a ordem do VAR com base nos CritÃ©rios de InformaÃ§Ã£o 
    VARselect(
      db_industry_mod2,
      lag.max = 12,
      type = 'both',
      exogen = exogen,
      season = 12 # dummies mensais
    )

    # Estimando o VAR
    model2_var <- VAR(db_industry_mod2,
                  p = 2, # defasagem escolhida
                  type = 'both',
                  season = 12,
                  exogen = exogen)

    # Teste de correlaÃ§Ã£o serial
    serial.test(model2_var, lags.pt = 30)

    # Verificando a presenÃ§a de cointegraÃ§Ã£o
    jotest2 <- ca.jo(
      db_industry_mod2,
      type = "trace",
      K = 2, # defasagem escolhida para o VAR
      ecdet = "trend", # 
      spec = "longrun",
      dumvar = exogen,
      season = 12
    )

    summary(jotest2) # indica 5 relaÃ§Ãµes de cointegraÃ§Ã£o

    # Transformando o VEC em VAR
    model2 <- vec2var(jotest2, r = 5) # r indica o nÃºmero de relaÃ§Ãµes de cointegraÃ§Ã£o

    # Teste de correlaÃ§Ã£o serial
    serial.test(model2, lags.pt = 30)

    # Estimando e plotando a FunÃ§Ã£o de Resposta ao Impulso

    Y_IRF_mod2 <-
      irf(
        model2,
        impulse = "selic",
        response = "Y_industry_extrat",
        n.ahead = 36,
        boot = TRUE,
        ci = 0.95,
        runs = 250,
        seed = 1414
      ) 

    g2 <- tibble(
      IRF = Y_IRF_mod2$irf$selic,
      Lower = Y_IRF_mod2$Lower$selic,
      Upper = Y_IRF_mod2$Upper$selic
    ) %>%
      ggplot(aes(x = seq(0, 36, 1))) +
      geom_line(aes(y = IRF), size = 1.3, color = "#1874CD") +
      geom_line(aes(y = Lower), color = 'red', linetype = "dashed") +
      geom_line(aes(y = Upper), color = 'red', linetype = "dashed") +
      geom_ribbon(aes(ymin = Lower, ymax = Upper),
              alpha = 0.2,
              fill = "#1874CD") +
      geom_hline(aes(yintercept = 0), color = "black") +
      labs(title = 'IndÃºstrias Extrativas',
       x = 'Meses apÃ³s o choque',
       y = '')

### Resultados

Fazendo o mesmo procedimento para o restante dos subsetores industriais, alterando apenas a numeraÃ§Ã£o dos objetos em que armazenamos os resultados (e.g. no modelo geral era 1, no modelo que inclui indÃºstrias extrativas Ã© 2, e assim por diante), podemos juntar os grÃ¡ficos em uma imagem.

    layout_matrix <- matrix(c(1, 1, 1, 1,
                              2, 2, 3, 3,
                              4, 4, 5, 5,
                              6, 6, 7, 7), nrow = 4, byrow = TRUE)

    grid <- grid.arrange(g1, g2, g3, g4, g5, g6, g7, layout_matrix = layout_matrix)
    ggsave("Fig.png", grid, width = 7.7, height = 9.9, units = "in", dpi = 500)


  {{< figure src="Fig.png" width="80%" >}}    

# DiscussÃ£o sobre os resultados

A ProduÃ§Ã£o Industrial Geral apresenta uma reaÃ§Ã£o levemente positiva nos primeiros meses apÃ³s o choque, mas Ã© rapidamente revertida e se torna declinante, chegando a um ponto de mÃ­nimo cerca de 12 meses apÃ³s o aumento na taxa de juros. No entanto, o efeito Ã© gradualmente dissipado e a produÃ§Ã£o industrial retorna para o nÃ­vel anterior ao choque.

Ao analisar os subsetores industriais, pode-se observar uma disparidade em termos da direÃ§Ã£o da resposta e, principalmente, em termos de sua magnitude. O tempo entre o choque e o mÃªs em que a resposta atinge um ponto de mÃ­nimo Ã© similar entre os setores, indicando semelhanÃ§as originadas de uma rigidez contratual e produtiva.

O subsetor de IndÃºstrias Extrativas Ã© o Ãºnico que apresenta uma resposta fortemente positiva e sustentada ao longo do tempo, em que a reaÃ§Ã£o atinge um mÃ¡ximo cerca de dez meses apÃ³s o choque e se mantÃ©m aproximadamente nesse nÃ­vel atÃ© o final do perÃ­odo considerado. Por outro lado, o subsetor de IndÃºstrias de TransformaÃ§Ã£o apresenta uma leve resposta positiva nos primeiros meses, mas essa resposta Ã© revertida e chega a um ponto de mÃ­nimo cerca de 12 meses apÃ³s o choque na taxa de juros, com o impacto negativo sendo gradualmente exaurido ao longo dos prÃ³ximos meses, mas permanecendo permanentemente menor do que o nÃ­vel anterior Ã  inovaÃ§Ã£o de polÃ­tica monetÃ¡ria.

A resposta mais negativa pode ser observada no subsetor de Bens de Capital, sugerindo que o aumento no custo de capital da economia derivado do choque positivo na taxa de juros de curto prazo afeta permanentemente a produÃ§Ã£o de ativos de longo prazo, sendo o reflexo da reduÃ§Ã£o nesse tipo de investimento por conta do maior custo de oportunidade. A ProduÃ§Ã£o de Bens IntermediÃ¡rios apresenta uma reaÃ§Ã£o positiva nos primeiros meses apÃ³s o choque na taxa de juros, porÃ©m, essa situaÃ§Ã£o Ã© revertida e o subsetor passa a exibir uma resposta permanentemente negativa.

A produÃ§Ã£o de Bens de Consumo DurÃ¡veis Ã©, assim como a produÃ§Ã£o de Bens de Capital, fortemente impactada pela inovaÃ§Ã£o na taxa de juros, refletindo a sua grande dependÃªncia nas condiÃ§Ãµes de financiamento da economia, por se tratar de bens com maior valor unitÃ¡rio. Assim, da mesma forma que empresas reduzem sua demanda por Bens de Capital por conta de uma deterioraÃ§Ã£o das circunstÃ¢ncias de financiamento, as famÃ­lias reduzem a sua demanda geral por Bens de Consumo DurÃ¡veis. Por outro lado, a produÃ§Ã£o geral de Bens de Consumo NÃ£o DurÃ¡veis Ã© praticamente nÃ£o afetada pelo choque na taxa de juros, mostrando uma relativa insensibilidade Ã  polÃ­tica monetÃ¡ria, uma vez que  considera bens mais relacionados ao consumo de subsistÃªncia dos agentes da economia.

# References


Banco Central do Brasil. 2021a. "Ata Da Reunião 237 Do Comitê de Política Monetária." Ata de reunião. Banco Central do Brasil. https://www.bcb.gov.br/publicacoes/atascopom/17032021.

---. 2021b. "Ata Da Reunião 238 Do Comitê de Política Monetária." Ata de reunião. Banco Central do Brasil. https://www.bcb.gov.br/publicacoes/atascopom/05052021.

Bernanke, Ben S., and Alan S. Blinder. 1992. "The Federal Funds Rate and the Channels of Monetary Transmission." The American Economic Review 82 (4): 901-21. http://www.jstor.org/stable/2117350.

Bernanke, Ben S., and Ilian Mihov. 1998. "Measuring Monetary Policy." The Quarterly Journal of Economics 113 (3): 869-902. http://www.jstor.org/stable/2586876.

Christiano, Lawrence J., Martin Eichenbaum, and Charles Evans. 1996. "The Effects of Monetary Policy Shocks: Evidence from the Flow of Funds." The Review of Economics and Statistics 78 (1): 16-34. http://www.jstor.org/stable/2109845.

Dedola, Luca, and Francesco Lippi. 2005. "The Monetary Transmission Mechanism: Evidence from the Industries of Five OECD Countries." European Economic Review 49 (6): 1543-69. https://doi.org/https://doi.org/10.1016/j.euroecorev.2003.11.006.

Dedola, Luca, and Francesco Lippi. 2005. "The Monetary Transmission Mechanism: Evidence from the Industries of Five OECD Countries." European Economic Review 49 (6): 1543-69. https://doi.org/https://doi.org/10.1016/j.euroecorev.2003.11.006.

Dickey, David A., and Wayne A. Fuller. 1981. "Likelihood Ratio Statistics for Autoregressive Time Series with a Unit Root." Econometrica 49 (4): 1057-72. http://www.jstor.org/stable/1912517.

Engle, Robert F., and C. W. J. Granger. 1987. "Co-Integration and Error Correction: Representation, Estimation, and Testing." Econometrica 55 (2): 251-76. http://www.jstor.org/stable/1913236.

Johansen, Soren. 1991. "Estimation and Hypothesis Testing of Cointegration Vectors in Gaussian Vector Autoregressive Models." Econometrica 59 (6): 1551-80. https://ideas.repec.org/a/ecm/emetrp/v59y1991i6p1551-80.html.

Lütkepohl, Helmut. 2006. New Introduction to Multiple Time Series Analysis. Springer Publishing Company, Incorporated.
