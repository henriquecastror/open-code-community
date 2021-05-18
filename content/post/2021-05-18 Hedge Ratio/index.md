---
title: "Hedge Ratio"

categories: []

date: '2021-05-18T00:00:00Z' 

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
- Tratamento de Dados
- Modelo Binomial
- Passeio Aleatório

authors:
- ArnaldoNascimento

bibliography: references.bib  

---



---




## Load some packages

library(tidyverse)
library(quantmod)
library(zoo)
library(ggplot2)
library(Quandl)
library(lubridate)
library(ggthemes)
library(reshape)
library(riskR)
library(stargazer)
library(tinytex)
```
\newpage

# Introduction
This is a series of short articles to discuss the tools to manage risk in the commodity markets using \emph{R}. My goal is to show how can we optimize the hedging strategy using commodities contracts - futures and options. 


## Forward-Spot relationship 
- The relationship between the forward  and the spot price, assuming no-arbitrage, can be describe as follows (@Geman2005):
\begin{align} f ^T (t) = S(t)e^{(r-y)(T-t)} \end{align} 
where $r$ is the continuously compound interest rate at instant t and maturity $T$, and $y$ is the convenience yield.

- We call backwardation when $(r-y) < 0$, the forward curve is a decreasing function of maturity.
![Backwardation`](back.png){width=50%}

- The contango sitaution is when $(r-y) > 0$, the forward curve is an increasing function of maturity.  
![Contango`](contango.png){width=50%}

```{r }
### Extract the Soybean prices from Quandl
soy = Quandl("TFGRAIN/SOYBEANS")
soy_f = soy  %>%
  mutate(soy, Futures = soy$`Cash Price`-soy$Basis)
dd= soy_f[,c(1:2, 6)]

```

## Spread Futures vs Spot price
![Basis`](basis.png){width=50%}

- Let's assume the \texttt{Basis} as only the spread  between \texttt{Spot} and \texttt{Future} price.

- Supposing you want to hedge a Cash Price position (Spot) with a Future contract (F) in the Chicago Mercantile Exchange (CME). 


```{r }
### Build ggplot 
dd1= melt(dd,id=c("Date"))

dd1 %>%
  ggplot(aes(x=Date, y=value,color=variable))+geom_line()+
  theme_wsj()+
   xlab(" ")+ylab(" ")+
   scale_colour_manual("", 
                      breaks = c("Cash Price", "Futures"),
                      values = c("Cash Price"="darkblue", "Futures"="red"))+
  theme(legend.text = element_text(size = 8, colour = "grey10"))

```

## Hedge Ratio
- The hedge ratio is a measure that compares a financial asset to a hedging instrument. The measurement indicates the risk of a shift in the hedging instrument. 
\begin{align} H^* = \rho \frac{\sigma_S}{\sigma_F} \end{align} 

\begin{align} H_{mv}= \frac{Cov(\Delta S_t, \Delta f_t)}{Var(\Delta f_t)} \end{align} (@Lien2016)

- In the commodity markets is common to use Futures contracts to hedge the Spot price. If a producers/exporters want to hedge their production, for example, then they would sell Futures contracts; if a buyers/importers want to hedge their position in the futures markets, then they would buy futures contracts. In this sense, the hedge ratio indicates the level of risk a producer/exporter are exposed. 


# Time series - zoo
data.z = zoo(dd[,-1], as.Date(dd[,1], format="%Y/%m/%d"))
S = data.z[,"Cash Price",drop=FALSE]
F = data.z[,"Futures",drop=FALSE]
# Estimating the returns
lS= diff(log(S))
lF=diff(log(F))
# Hedge Ratio
H = cov(lS,lF)/cov(lF)
stargazer(H, type = "text", title="Hedge Ratio", rownames = FALSE,
          colnames = FALSE)
```

- Now suppose a company/importer knows that it will buy 1,000,000 of      soybeans in one month. The soybean futures contract unit is 5,000/bushels. So, the number a futures contract (long position) the company will buy is...
```{r }
N = H*(1000000/5000) #buy 190 futures contracts
stargazer(N, type = "text", title="N of Contracts", rownames = FALSE,
          colnames = FALSE)
```

## Risk Metrics
### Estimating optimal hedging ratios based on risk measures (see @Chan2019)

- The risk manager's role is to mitigate the volatility by hedging the underlying asset or avoiding the deviation from the expected value.   
- There are a few risk metrics to measure the uncertainty in the futures contracts. @Chan2019 created a package that computes 26 financial risk measures. Thus, we applied the function to our example (soybean hedging).


### We use the Soybean Future contract (F) for hedging the Spot price (S)
rh = riskR::risk.hedge(lS,lF,alpha=c(0.05, 0.01), beta = 1, p=2)
stargazer(rh,type="text",font.size = 'tiny',
          no.space = TRUE, column.sep.width = '4pt', title="Risk Metrics")


```
^[Risk measures (Standard Deviation (StD), Value at Risk (VaR), Expected Loss (EL), Expected Loss Deviation (ELD), Expected Shortfall (ES), Shortfall Deviation Risk (SDR), Expectile
Value at Risk (EVaR), Deviation Expectile Value at Risk (DEVaR), Entropic (ENT), Deviation Entropic (DENT), Maximum Loss (ML)) ]


# References 

