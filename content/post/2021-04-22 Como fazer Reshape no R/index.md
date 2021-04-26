---

title: "Como fazer Reshape no R - um exemplo com os dados da DR"

categories: []

date: '2021-04-22T00:00:00Z'

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
- Reshape 
- Pivot Wider
- Pivot Longer
- Research

authors:
- GersonJunior


---

## Comandos Gerais

Neste post iremos ensinar como fazer um reshape long to wide, reshape wide to long. Utilizaremos o pacote tidyr. Baixaremos os dados do GetDFPData2 do [Marcelo Perlin](https://www.msperlin.com/blog/) para termos os dados da DR. No caso iremos usar apenas a empresa Petrobrás como dado. 

Baixando os Dados 

        library(GetDFPData2)
    library(tidyr)
    df =  get_dfp_data(
      companies_cvm_codes = NULL,
      first_year = 2020,
      last_year = lubridate::year(Sys.Date()),
      type_docs = c("BPA", "BPP", "DRE"),
      type_format = c("con", "ind"),
      clean_data = TRUE,
      use_memoise = FALSE,
      cache_folder = "gdfpd2_cache",
      do_shiny_progress = FALSE
    )

Selecionando a demonstração do Resultado

    df_DR = df$`DF Consolidado - Demonstração do Resultado`

Filtrando a empresa, no caso a Petrobrás e selecionando as colunas que nos interessam

    df_DR_petrobras = df_DR %>% filter(DENOM_CIA == "PETROLEO BRASILEIRO S.A. PETROBRAS")  %>%  select(DT_FIM_EXERC,DENOM_CIA,CD_CONTA,VL_CONTA)
    
    
Reshape long to wide

    df_pivot_wide =  df_DR_petrobras %>%  pivot_wider(names_from = CD_CONTA, values_from = VL_CONTA)
      
{{< figure src="1.png" width="70%" >}}

    
E depois retornando - reshape wide to long 

    df_pivt_long = df_pivot_wide  %>% pivot_longer(!DT_FIM_EXERC & !DENOM_CIA , names_to = "DS_CONTA", values_to = "VL_CONTA")


{{< figure src="2.png" width="100%" >}}

