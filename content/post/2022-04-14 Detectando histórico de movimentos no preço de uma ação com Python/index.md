---

title: "Detectando histórico de movimentos no preço de uma ação com Python"

categories: []

date: '2021-04-14T00:00:00Z' 

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
- Python
- Stock cotations

# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
- ViniciusBergonziLazzari


---

# Introdução

Grandes variações no preço de uma ação podem indicar o início de um movimento maior com relação a sua cotação. O propósito desse exercício é desenvolver uma maneira rápida de verificar qualquer tipo de variação desejada no preço de negociação uma empresa em um único dia nos dados históricos de mercado.

# Desenvolvimento

## Bibliotecas

Começando pelas bibliotecas, usamos `sys` para executar o programa por parâmetros (uma vez que a ideia é agilizar o processo), `requests` para obter os dados da API da [AlphaVantage](https://www.alphavantage.co/), `pandas` para manipular os dados e `matplotlib` para plotar o resultado final.

    import sys
    import requests
    import pandas as pd
    import matplotlib.pyplot as plt
    import matplotlib.dates as mdates
    import matplotlib.lines as mlines

## Recebendo argumentos

Definimos a função `main` da sequinte maneira:

    def main():

    if __name__ == "__main__":
        main()

Logo após, define-se a função `get_arguments()` cujo único propósito é receber os argumentos recebidos por parâmetro e devolver para a aplicação.

    def get_arguments():
        # Recebe os argumentos do vetor de argumentos passado
        symbol = sys.argv[1]
        operator = sys.argv[2]
        reference = float(sys.argv[3])

        # Retorna os parâmetros
        return symbol, operator, reference

- **Symbol** é o ticker utilizado para pesquisa (FB, AMD, AMZN...)
- **Operator** é a referência de pesquisa (+, - ou =)
- **Reference**: é o número de ancoragem para a pesquisa (10, -5, 0...)

Dessa forma, o programa poderia ser executado da sequinte maneira:

    main.py FB + 10

Essa chamada retornaria todas as vezes que a ação do **Facebook** teve uma variação **maior** que **10%** no dia.

    main.py AMZN - -20

Essa chamada retornaria todas as vezes que a ação da **Amazon** teve uma variação **menor** que **20%** no dia.

Feita a função, podemos apenas retornar seu resultado na `main()`

    def main():
        # Recebe os argumentos passados
        symbol, operator, reference = get_arguments()

## Recebendo os dados

Para esse exemplo, utilizamos a API gratuita da [AlphaVantage](https://www.alphavantage.co/). Para utilizá-la basta entrar no site e requisitar uma chave que será usada como validação para suas consultas, de graça (na versão standart).

Para receber os dados, definimos a função `get_cotations_data()` que tem como objetivo fazer a chamada para a API e retornar um dataframe com os dados tratados para a aplicação.

Primeiramente, precisamos montar o link de acesso com o seguinte código

    # Monta a URL da requisição
    url = 'https://www.alphavantage.co/query?function=' + function + '&symbol=' + \
        symbol + '&outputsize=' + output_size + '&apikey=' + api_key

Note que essa requisição necessita de algumas variaveis ainda não definidas como `function`, `output_size` e `api_key` (`symbol` será passada por parâmetro para a função). Para resolver esse problema, definimos globais fixas no início do programa.

Inclusive, `api_key` deve receber a chave que foi previamente gerada para que as pesquisas sejam realizadas.

    # Variáveis padrão para realizar a consulta a API
    api_key = '############'
    function = 'TIME_SERIES_DAILY'
    output_size = 'full'

Feito isso, a requisição deve ser realizada e montada em um `dataframe`.

    # Realiza a requisição
    r = requests.get(url)
    data = r.json()

    # Cria o dataframe já invertendo índices e colunas
    df = pd.DataFrame.from_dict(data['Time Series (Daily)']).transpose()

Como os dados estão ordenados de maneira que a data é descrescente, para montar o gráfico podemos inverter essa ordem.

    # Inverte a ordem do dataframe (data mais antiga primero)
    df = df.iloc[::-1]

Por último, é necessário transformar os indices da tabela de `string` para `datetime`.

    # Converte o índice do dataframe de string para o objeto de data do Pandas
    df = df.set_index(pd.to_datetime(df.index, format='%Y-%m-%d'))

Dessa forma, o resultado final é o seguinte:

    def get_cotations_data(symbol):
        # Monta a URL da requisição
        url = 'https://www.alphavantage.co/query?function=' + function + '&symbol=' + \
            symbol + '&outputsize=' + output_size + '&apikey=' + api_key

        # Realiza a requisição
        r = requests.get(url)
        data = r.json()

        # Cria o dataframe já invertendo índices e colunas
        df = pd.DataFrame.from_dict(data['Time Series (Daily)']).transpose()

        # Inverte a ordem do dataframe (data mais antiga primero)
        df = df.iloc[::-1]

        # Converte o índice do dataframe de string para o objeto de data do Pandas
        df = df.set_index(pd.to_datetime(df.index, format='%Y-%m-%d'))

        return df

## Iterando pelo histórico

Uma vez que os dados estão tratados, basta iterar pela ocorrências para calcular as variações de cotação.

Primeiramente, define-se a variavel `previous_value` para guardar o fechamento do dia anterior (atribuindo o fechamento do primeiro dia do histórico a ela).

    # Recebe o valor de fechamento da menor data
    previous_value = float(df.tail(1)['4. close'])

Após isso, precisamos definir 3 vetores auxiliares

    # Cria os vetores auxiliares
    closes = []
    days = []
    markers = []

**Closes** contém todos os valores de fechamento da cotação do ativo, **Days** contém todos os dias de negociação e **Markers** contém apenas os dias que atendem as critério de variação passado por parâmetro.

A seguir segue o algoritmo para iterar por todos os dias de negociação e preencher todos os vetores necessários.

    # Itera por todos os dias disponíveis, pulando o menor deles
    for index, row in df.iloc[1:].iterrows():
        # Recebe o valor de fechamento do dia atual
        close_value = float(row['4. close'])

        # Recebe a variação atual, baseado no fechamento anterior e atual
        variation = get_intraday_variation(previous_value, close_value)

        # Trata todos os tipos de operando passados
        if test_variation(operator, reference, variation):
            # Caso a variação tenha passado no teste, salva ela no vetor auxiliar
            markers.append(index)

        # Salva o fechamento e dia atuais para plotas no gráfico
        closes.append(close_value)
        days.append(index)

        # Prepara o valor anterior como o valor atual para a próxima iteração
        previous_value = close_value

Primeiramente obtem-se o valor de fechamento do dia atual na variavel `close_value`.

Após isso, a variável `variation` recebe o resultado da função `get_intraday_variation()`, que definiremos a seguir.

Obtida a variação, é necessário testar se esse dado atende ao critério utilizado, a função `test_variation()` é responsável por isso. Caso o teste retorne positivo, o dia da variação é adicionado ao vetor de marcadores.

Por último, adicionamos o dia e o valor de fechamento aos seus vetores, necessários para montar o gráfico do ativo, e atualizamos o `previous_value` para a próxima ocorrência.

## Calculando a variação

A variação do ativo no dia pode ser calculada pelo valor de fechamento atual e do dia anterior com a seguinte fórmula:

    def get_intraday_variation(previous_value, close_value):
        # Variação = (valor atual / valor anterior - 1) * 100
        variation = (close_value / previous_value - 1) * 100

        return variation

## Testando a veriação

Para testar se a oscilação atende ao critério passado, basta testar o valor obtido pelo operador escolhido.

    def test_variation(operator, reference, variation):
        # Identifica qual o operador passado e realiza o determinado teste
        if operator == "=":
            # Testa se são iguais
            return reference == variation
        elif operator == "+":
            # Testa se a variação é maior que a referência
            return reference < variation
        elif operator == "-":
            # Testa se a variação é menor que a referência
            return reference > variation
        else:
            # Trata erro caso o operador não seja reconhecido
            return False

## Obtendo índices de marcação

Para conseguir marcar as datas de marcação no gráfico, precisamos encontrar a quais índicer no vetor de datas cada marcação corresponde, o que pode ser feito com o seguinte comando.

    # Converte os dias salvos para marcação em índices do vetor de dias
    markers = [days.index(day) for day in markers]

## Montando o título do gráfico

Para montar o título do gráfico, selecionamos o menor e maior ano do histórico, em conjunto com o ticker passado como parâmetro.

    def build_title(symbol, df):
        # Busca o menor e maior ano de dados obtidos
        min_date = df.index[0].year
        max_date = df.index[-1].year

        # Monta a string de título
        title = symbol + " " + "stock performance" + " " + "(" + str(min_date) + " - " + str(max_date) + ")"

        return title

## Montando a legenda do gráfico

Da mesma forma para a legenda apenas traduzimos os argumentos passados para uma linguagem mais formal, o mesmo exercício realizado na apresentação dos argumentos mais acima.

    def build_legend(operator, reference):
        # Cria um dicionário para traduzir o operador passado
        operator_dict = {
            "=": "=",
            "+": ">",
            "-": "<",
        }

        # Monta a string de legenda
        legend = "Variation" + " " + operator_dict[operator] + " " + str(reference)

        return legend

## Plotando o resultado final

Esse último passo se trata apenas de uma questão estética, qualquer mudança nos argumentos apresentado pode ser feita consultando a documentação da biblioteca [Matplotlib](https://matplotlib.org/stable/users/index).

    def plot_graph(title, legend, days, closes, markers):
        # Plota o gráfica relacionando datas e fechamentos, inserindo os marcadores
        plt.plot(days, closes, markevery=markers, marker="o",
            markerfacecolor='red', markersize=8)
            
        # Define tamanhos de títulos e rotações de labels
        plt.title(title, size=18, pad=24)
        plt.xticks(rotation=90)

        # Remove a margem dos lados e adiciona o grid horizontal
        plt.grid(axis='y')
        plt.margins(x=0)

        # Adiciona label de performance ao gráfico
        plt.ylabel("Performance", labelpad=15)

        # Converte datas para anos
        plt.gca().xaxis.set_major_locator(mdates.YearLocator())
        plt.gca().xaxis.set_major_formatter(mdates.DateFormatter('%Y'))

        # Cria a legenda do gráfico
        red_square = mlines.Line2D([], [], color='red', marker='o', linestyle='None',
            markersize=10, label=legend)         
        plt.legend(handles=[red_square])

        # Mostra o resultado na tela
        plt.show()

# Exemplos

A seguir seguem alguns exemplos do argumento passado e o gráfico gerado pelo algoritmo.

## FB

    main.py FB - -10

<figure src="FB.png" width="100%">

## AMD

    main.py AMD  + 15

<figure src="AMD.png" width="100%">

# Resultado final

O resultado final desse projeto pode ser encontrado no meu [github pessoal](https://github.com/viniciuslazzari/StockTracker).