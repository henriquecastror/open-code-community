---

title: "Volatilidade Histórica Parkinson - python"

categories: []

date: '2021-09-10T00:00:00Z' 

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

# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
- MaikeMOta


---

Um questionamento que muito Jr. assim como eu já deve ter feito ao mensurar a volatilidade histórica: se analisarmos apenas o fechamento dos preços, perdemos dados da movimentação intradiária do papel, ou seja, se o preço de fechamento do ativo em D-1 foi 10 dinheiros, e o fechamento de hoje é 10 dinheiros a variação da vol é mínima dependendo do modelo que estiver utilizando.

A próxima questão é: existe na literatura alguma forma de considerar a volatilidade intradiária? Sim, obviamente existe e há muito tempo.

Michael Parkinson em 1980, tem como objetivo estimar a volatilidade de uma série temporal a partir dos preços de High e Low nos fornecendo a seguinte equação:

{{< figure src="Fig1.png" width="100%" >}} 

Novidade para alguns, assunto batido para outros, mas a intenção é sempre alcançar os desavisados. Caso você ainda utilize a vol histórica fica a dica de implementação.

Processo de codar é simples, segue um exemplo para o índice bovespa:

    ticker = '^BVSP'
    acao = yf.download(ticker, period='3y')
    print(acao.head())

    parhv = np.sqrt(252 / (4 * 22 * np.log(2)) 
                pd.DataFrame.rolling(np.log(acao.loc[:, 'High'] / acao.loc[:, 'Low']) ** 2, window=22).sum())


    plt.figure(figsize=(20,10))
    plt.plot(parhv, label='Parkinson HV')
    plt.legend(loc='upper left')
    plt.title('Parkinson Historical Volatility')

{{< figure src="Fig2.png" width="100%" >}} 

Segue o código completo no github: https://github.com/MaikeRM/volatilidade_parkinson.git

Referências

[1] E. Sinclair, Volatility Trading, John Wiley & Sons, 2008
    
