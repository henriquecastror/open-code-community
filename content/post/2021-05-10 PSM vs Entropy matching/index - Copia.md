---
authors:
- HenriqueCastroMartins

categories: []

date: "2021-05-08T00:00:00Z"

draft: false

featured: false

gallery_item:

image:
  caption: 
  focal_point: right
  preview_only: false

projects: []

subtitle: Um exercício simples de comparação 

summary: 

tags:
- Master
- PhD
- Causal Inference

title: Propensity-score matching (PSM) vs. Entropy matching

---



    library(dplyr)
    library(haven)
    data <- read_dta("cps1re74.dta")
		
#####

    skewness <-  function(x) {
    m3 <- mean((x - mean(x))^3)
    skewness <- m3/(sd(x)^3)
    skewness
    }
    
  
    table1 <- data %>%                                
    group_by(treat) %>%                     
    summarise_at(vars(age, black, educ),    
                 list(name = mean, var, skewness))   
 

#####
    
    library(Matching)

   
    psmodel <-glm(treat~age+black+educ,
                family = binomial(link = "probit"),
                data=data)

    psmodel
    
    kernel.fit(psmodel, data$treat, data$age, Kernel="Ep")
    
    data$pscore <- psmodel$fitted.values

   
   
    data %>%                                
    group_by(treat) %>%                     
    summarise_at(vars(pscore),    
                 list(name = mean))   

    

    
    data %>% group_by(treat) %>% 
    summarise_at(vars(age,black,educ), 
                 funs(weighted_mean = sum(. * pscore)/sum(pscore) )) 
    
    
    
    
    
    
    
    psm <- pscore(data    = data, 
                      formula = treat~age+black+educ)
    
    stu1.match <- ps.match(object          = stu1.ps,
                       ratio           = 2,
                       caliper         = 0.5,
                       givenTmatchingC = FALSE,
                       matched.by      = "pscore",
                       setseed         = 38902)


    stu1.match <- ps.match(object          = stu1.ps,
                       ratio           = 2,
                       caliper         = 0.5,
                       givenTmatchingC = FALSE,
                       matched.by      = "pscore",
                       setseed         = 38902)

    psmatch2 treat age black educ , kernel
    
{{< figure src="Imagem2.png" width="80%" >}}

Após o pareamento, note que diversas variáveis foram criadas com um "_" no início de seus nomes. 

A que mais nos importa é _weight que é o peso para rebalanceamento de cada observação. 

Veja que o peso de cada observação varia entre [0,1]. Basicamente, quanto maior o peso, maior a similaridade entre a observação do grupo de tratamento e a de controle. 

Pesos baixos indicam que a observação de controle é diferente da observação do grupo de tratamento.

Perceba também que as observações do grupo de tratamento tem peso 1, enquanto as demais (i.e., as de controle) tem pesos menores que 1.

    bys treat: sum _weight , d
    
{{< figure src="Imagem3.png" width="80%" >}}

Podemos agora calcular a média, variância e skewness das amostras pareadas.

    qui estpost tabstat age black educ [aweight = _weight], by(treat) c(s) s(me v sk n) nototal
    esttab . 	,varwidth(20) cells("mean(fmt(3)) variance(fmt(3)) skewness(fmt(3)) count(fmt(0))") noobs  nonumber compress 

{{< figure src="Imagem4.png" width="80%" >}}

Perceba que, de acordo com esse pareamento, os três momentos não parecem semelhantes. 

Não sabemos se as diferenças são estatisticamente significativas, mas visualmente, temos a impressão que sim na maioria dos casos.

Podemos fazer um teste da diferença entre as médias dos dois grupos via OLS da seguinte forma:

    reg age   treat [aweight = _weight]
    reg black treat [aweight = _weight]
    reg educ  treat [aweight = _weight]
    
{{< figure src="Imagem5.png" width="80%" >}}

Perceba que todos os coeficientes da variável independente "treat" são estatisticamente diferentes de zero, ou seja, as diferenças entre as médias dos grupos são significativas.

Isso seria um indicativo que esse pareamento não cumpriu plenamente seu propósito de deixar as sub-amostras comparáveis.

É claro que fizemos o pareamento mais simples e eventualmente poderíamos melhorá-lo. No entanto, nesse momento, temos a sugestão de que as sub-amostras não foram bem pareadas.


# Entropy

Vamos agora rodar o pareamento via entropia. Vamos também usar a versão de pareamento mais simples. Vamos apenas solicitar que os três momentos sejam usados como critério para pareamento. 
				
    ebalance treat age black educ, targets(3)
    
{{< figure src="Imagem6.png" width="80%" >}}

O próprio output da linha anterior mostra os momentos da distribuição dos dois grupos, mas se você quiser, pode rodar novamente as seguintes linhas:

    qui estpost tabstat age black educ [aweight = _webal], by(treat) c(s) s(me v sk n) nototal
    esttab . 	,varwidth(20) cells("mean(fmt(3)) variance(fmt(3)) skewness(fmt(3)) count(fmt(0))") noobs  nonumber compress 

{{< figure src="Imagem7.png" width="80%" >}}

Vamos fazer o mesmo teste de averiguação de diferença de médias usando OLS.

    reg age   treat [aweight = _webal]
    reg black treat [aweight = _webal]
    reg educ  treat [aweight = _webal]	

{{< figure src="Imagem8.png" width="80%" >}}

Note agora que os três coeficientes das variáveis independentes não são significativos. 

Isso indica que as médias dos covariates entre os grupos não são estatisticamente diferentes entre si.


# Conclusão

Ao que parece, o entropy matching é um método que leva a resultados mais apurados de pareamento.

É claro, esse foi um exercício simples. Mas para fins desse post, essa é a conclusão que conseguimos ter.

Thanks for passing by. 






