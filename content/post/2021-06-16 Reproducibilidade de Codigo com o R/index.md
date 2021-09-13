---
title: "Reproducibilidade de Código com o R"

categories: [R, reproducibilidade]

# MUDE APENAS ANO DIA E MES PARA O DIA QUE VOCE NOS ENVIOU
date: '2021-06-16T00:00:00Z' 

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

# DIGITE NA LISTA ABAIXO OS TRACKS DO SEU CODIGO
tags: 
  - Open Data
  - R
  - reproducibilidade
  
# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
  - MarceloPerlin
  - MarcosHenriqueReichert
  - LucasMussoi


---

<script type="text/javascript" src="//cdn.plu.mx/widget-popup.js"></script>

<a href="https://plu.mx/plum/a/?doi=10.17632%2Fscpb9gnsgm.1" data-popup="right" data-size="large" class="plumx-plum-print-popup" data-site="plum" data-hide-when-empty="true">Reproducibilidade de C�digo com o R published at the &amp;quot;Open Code Community&amp;quot;</a>



Uma pesquisa baseada em dados é reproduzível quando outros cientistas
conseguem replicar os seus resultados. O benefício para a ciência é
óbvio: diferentes pesquisadores podem repetir experimentos
computacionais e testar novas hipóteses com base em resultados já
estabelecidos. Claramente, políticas de reproducibilidade são uma
condição necessária para promovermos a ciência perante uma audiência
cada vez mais crítica do trabalho acadêmico. Como confiar em resultados
os quais não permitem replicação? Seria a palavra do pesquisador
suficiente? Claro que não..

Apesar de parecer uma premissa simples, a prática de reproducibilidade
em pesquisa baseada em dados é complexa. No mundo ideal, o mesmo
*script* de pesquisa – código de computador que produz gráficos e
tabelas – deveria sempre produzir os mesmos resultados. Na prática,
entretanto, todo código de programação possui diversas dependências: o
**sistema operacional** (Windows/Mac/Linux), a **plataforma
estatística** utilizada (R/Python/Stata/..) e **versões das funções
específicas** de cada plataforma. Uma maneira estruturada de entender o
problema é imaginar um *grid* com todas estas possíveis combinações de
plataforma computacional, versões de software e funções para a pesquisa.
Uma pesquisa é reproduzível se, dada a mesma entrada de dados, a saída
do programa (gráfico/tabela) é equivalente em todas combinações do
*grid*.

Como professor e pesquisador, já vivenciei situações onde a
reproducibilidade de código não persiste, com alguns casos mais graves
que outros. Aprendi a lidar com a reproducibilidade na marra, com erros
e acertos. Assim, neste pequeno artigo irei mostrar o que a plataforma R
tem para oferecer em termos de reproducibilidade e compartilhar o que
aprendi no processo.

# Reproducibilidade com o R

## Organização de pastas e arquivos

O primeiro e mais simples movimento para melhorar a reproducibilidade de
código é organizar os seus arquivos. Pode parecer bobagem, mas uma
básica organização facilita muito o processo de execução de códigos
antigos. Quem nunca baixou um código estilo *miojo* da internet?

Por exemplo, imagine você abrir uma pasta com um projeto antigo e se
deparar com o seguinte cenário:

    ## Loading required package: fs

    ## /tmp/Rtmp3rqa7g/Minha-Pesquisa
    ## ├── data
    ## │   ├── dados-atualizados.csv
    ## │   └── dados-finais.csv
    ## ├── script-artigo-final2--REVISADO.R
    ## ├── script-download-dados.R
    ## ├── script-download-dados2.R
    ## ├── tabela-final1.xlsx
    ## └── tabela-final2-antes-de-filtrar.xlsx

Neste caso temos três scripts do R, uma pasta com dados e dois arquivos
.csv. Os nomes dos arquivos também não ajudam. Afinal, qual arquivo
representa os dados utilizados na pesquisa publicada? O que parece óbvio
no momento de edição do projeto, ou uma semana depois, não será tão
óbvio em seis meses. Se não é óbvio para o próprio autor, imagine para
outras pessoas.

Como sugestão, e deixo claro que a forma de organização é
intrinsicamente gosto pessoal, entendo que a melhor estrutura é aquela
mais simples e óbvia. Um exemplo para o projeto anterior seria a
seguinte organização de arquivos e pastas:

    ## /tmp/Rtmp3rqa7g/Minha-Pesquisa-oganizada
    ## ├── 01-import-clean-data.R
    ## ├── 02-make-tables.R
    ## ├── data
    ## │   └── dados-pesquisa-2021-05-01.rds
    ## ├── fcts
    ## │   └── fcts-models.R
    ## ├── figs
    ## │   ├── p1-variable-over-time.png
    ## │   └── p2-distribution-plot.png
    ## └── tabs
    ##     ├── tab01-summary-stats.tex
    ##     └── tab02-ols-model.tex

Daqui a um ano ou mais, caso eu ou outra pessoa retorne a este projeto,
a estrutura de arquivos e pastas permite o fácil e rápido entendimento
do código: dois *script* numerados e sequenciados
(`01-import-clean-data.R` e `02-make-tables.R`), um de dados com data
`dados-pesquisa-2021-05-01.rds` e pastas para as saídas em tabelas
(`tabs/`) e figuras (`figs/`).

Assim, como critérios pessoais, utilizo as seguintes regras:

-   Na pasta raiz do projeto, somente código R pode existir (todo o
    resto, arquivos de figura, tabelas, dados, devem ir em pasta
    própria);
-   Se os scripts possuem ordem de execução, use numeração no nome, de
    forma a ficar claro o sequenciamento (ex. 01-import-data.R,
    02-clean-data.R, 03-make-tables.R);
-   Se dados podem mudar com o tempo, usar uma data na nomeação do
    arquivo (ex: dados-tesouro-direto\_2021-01-05.csv);
-   Figuras e tabelas devem ser nomeadas na ordem em que aparecem no
    artigo ou relatório (ex. p1-grafico-tempo.png, p2-histograma.png,
    tab1-descritiva.tex, etc)

## Pacote `renv`

Pacote `renv` tem uma missão específica: controlar e gerenciar pacotes
de projetos. Sua estrutura e funcionamento é muito semelhante ao
[*Virtual Enviromnent
(venv)*](https://docs.python.org/3/tutorial/venv.html) do Python. A
grosso modo, a partir de um diretório de trabalho, registramos os
pacotes utilizados – incluindo versões – em um arquivo local chamado
`renv.lock`. Após isso, podemos copiar o código para outra máquina e
restaurar todos pacotes e suas versões específicas com um simples
comando. Isto é, reproduzimos o ambiente específico do projeto em termos
de pacotes e versões do R.

O primeiro passo para usar `renv` é definir uma pasta de trabalho onde
código R e arquivos dados irão viver. Ao mudar o diretório para esta
pasta com `setwd` ou usando a ferramenta de projetos do RStudio, a qual
já muda o diretório automaticamente para onde o arquivo de projeto
existe, basta inicializar o `renv` com comando `renv::init()`. O que
este comando irá fazer é ler os scripts do R existentes na raiz e
subdiretórios da pasta atual, localizar no código as chamadas a
`library/require` ou `::`, e registrar **todas** as dependências de
pacotes. Por exemplo, se fizeres uma chamada a `library(dplyr)` em um
código de R na pasta (ou subpasta) de trabalho, o `renv::init()` irá
identificar esta dependência.

Após inicializarmos o `renv` no projeto, basta registrar as dependências
– pacotes e suas versões – com o comando `renv::snapshot()`, e pronto!
Agora, quando copiarmos o código para outro computador, basta usar
`renv::restore()` para instalar e usar todas as dependências do projeto.
Resumindo:

1.  Abra o projeto e use `renv::init()` para inicializar o `renv`;
2.  Use `renv::snapshot()` para registar todos pacotes e versões;
3.  Use `renv::install()` para instalar novos pacotes (função
    `install.packages()` é sobrescrito por `renv` e funciona da mesma
    forma);
4.  Use `renv::update()` para atualizar todos pacotes, incluindo pacotes
    instalados do Github.

Para mais detalhes sobre `renv`, veja o [site
oficial](https://rstudio.github.io/renv/articles/renv.html). Eu uso o
`renv` em todos os meus projetos e só tenho elogios:

-   O *overhead* de tempo para instalação e configuração é mínimo;
-   A pasta de trabalho tem um aumento pequeno de tamanho pois todos
    pacotes são na verdade links simbólicos (e não arquivos locais);
-   Facilita muito o uso de pacotes em computadores diferentes. Ao
    copiar a pasta, basta digitar um comando para sincronizar a máquina
    com todos os pacotes do projeto;

## Pacote `checkpoint`

Pacote `checkpoint` é uma iniciativa da
[Microsoft](https://mran.microsoft.com/documents/rro/reproducibility/)
para aumentar a reproducibilidade de códigos em R. A grande sacada do
pacote é utilizar o tempo, e não projetos, para definir as versões dos
pacotes. Podes, por exemplo, usar todas versões dos pacotes na data
`2020-01-05`. O pacote acessa um repositório atualizado com as linhas de
tempo das versões e instala apenas aquelas disponíveis na data de
referência.

Assim como para o `renv`, o uso do `checkpoint` é bastante simples,
basta carregar o pacote no topo do script e chamar a principal função
com uma data, como em:

    library(checkpoint)

    checkpoint("2020-01-01")  

    # resto do código aqui

O que o `checkpoint` irá fazer é definir um repositório local para os
pacotes, buscar pacotes utilizados no código, e instalar todas versões
disponíveis naquela data em particular, incluindo as versões das
dependências. A partir disso, o resto do código acessará o repositório
local do `checkpoint` para buscar todos os pacotes utilizados nos
scripts.

Pessoalmente, acho a forma de utilizar o `checkpoint` bem interessante
porém um pouco gananciosa no sentido de tentar oferecer uma solução
mágica para o problema de reproducibilidade. Na prática, ao usar o
`checkpoint` em meus projetos, vejo os seguintes problemas:

-   A instalação de todos pacotes na inicialização do `checkpoint` acaba
    exigindo certo tempo de processamento pois **todas** as dependências
    devem que ser reinstaladas;
-   A primeira data do repositório de pacotes é `'2014-09-17'`, o que
    pode não ser suficiente para projetos mais antigos;
-   Dependências externas ao R, como software instalado via apt do
    linux, não são resolvidas. Assim, no futuro, sem a garantia de que
    dependências externas serão sempre disponíveis, a reproducibilidade
    fica comprometida;
-   Adiciona um **custo de armazenamento** significativo. Ao reinstalar
    pacotes, um projeto mínimo pode ter tamanho maior que 100 MB,
    simplesmente pelo uso de um reposítório customizado.

Para mais detalhes, veja a página do projeto no
[Github](https://github.com/RevolutionAnalytics/checkpoint).

## Conteinarização – docker

Hoje em dia é impossível falar de reproducibilidade sem mencionar a
tecnologia *docker*. Primeiramente pensada para a execução de códigos em
produção – sistemas ativos e importantes–, o *docker* permite a criação
de uma imagem de um sistema operacional dentro do seu computador. Na
minha opinião, atualmente o *docker* é o ápice do que se consegue em
termos de reproducibilidade computacional, justificando o seu uso
sistêmico na indústria.

Por exemplo, digamos que voce tenha um código em R desenvolvido no
sistema operacional [Ubuntu 18.04](https://ubuntu.com/), e versões
específicas de software via apt e pacotes do R. Assim, podes criar uma
imagem para recriar este ambiente computacional no seu computador,
instalar todas as dependências, incluindo software por apt-get e pacotes
do R e, por fim, executar o código dentro da imagem e exportar
resultados para arquivos Excel ou .csv. Assim, mesmo que estejas usando
Windows 10, podes rodar o código R no sistema Ubuntu 18.04.

O uso do docker com o R vai muito além deste artigo, exigindo
conhecimento sobre arquiteturas e códigos em linha de comando. Em
resumo, utilizar *docker* resume-se a 1) baixar uma imagem de um sistema
operacional, 2) escrever um `Dockerfile` com todos os passos de
preparação do sistema para execução de *scripts* e 3) executar o código.
Para quem quiser conhecer mais, um tutorial muito bom está disponível
[aqui](https://colinfay.me/docker-r-reproducibility/). Um vídeo
ilustrativo está disponível no
[Youtube](https://www.youtube.com/watch?v=CdG7gUPgdWU).

# Conclusão

Reproducibilidade no R não é uma tarefa fácil, mas os pacotes existentes
hoje ajudam bastante. Particularmente, uso o `renv` em todos os projetos
que faço e estou muito satisfeito. Entendo que o `renv` fornece o
equilíbrio entre reproducibilidade e inconveniência, não atrapalhando o
desenvolvimento do código. Quem quiser saber mais sobre
reproducibilidade no R, o próprio CRAN tem uma [página
especial](https://cran.r-project.org/web/views/ReproducibleResearch.html)
sobre o tópico. Lá encontrarás diversos outros pacotes voltados a
reproducibilidade e não citados aqui.



{{% callout note %}}

**Please, cite this work:**

Perlin, Marcelo; Reichert, Marcos Henrique; Mussoi, Lucas (2021), "Reproducibilidade de C�digo com o R published at the "Open Code Community"", Mendeley Data, V1, doi: 10.17632/scpb9gnsgm.1

{{% /callout %}}


