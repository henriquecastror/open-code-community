---

title: "Regressão logística multinomial usando Python para prever raridade de pokemons"


categories: []

date: '2022-07-05T00:00:00Z' 

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
- Machine Learning
- Logistic Regression

# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
- ViniciusBergonziLazzari

---


# Introdução

Usando regressão logística de múltiplas variáveis para prever a raridade de pokemons baseando-se puramente em seus status. O modelo pode ser utilizado para diversos usos de múltiplas variáveis com resultados boleanos.

# Desenvolvimento

## Bibliotecas

Começando pelas bibliotecas, usamos `numpy` para manipulação de vetores, `pandas` para manipulação e limpeza dos dados, `matplotlib` para obter alguns dados do treinamento do modelo e `sklearn` para fazer uso de algumas ferramentas que facilitam o aprendizado do algoritmo.

    import numpy as np
    import pandas as pd
    import matplotlib.pyplot as plt
    from sklearn.model_selection import train_test_split
    from sklearn.metrics import accuracy_score

## Recebendo e filtrando os dados

Definimos a função `main` da sequinte maneira:

    def main():

    if __name__ == "__main__":
        main()

Primeiramente transformamos o CSV dos dados para um dataframe utilizando uma função pronta da biblioteca `pandas` com o seguinte comando

    data = pd.read_csv('./data.csv')

A seguir definimos a função para filtrar apenas os dados que serão utilizados no treinamento do algoritmo com a seguinte função

    # Função para filtrar os dados de treinamento
    def filterData(data):
        # Dicionário para traduzir falso = 0 e verdadeiro = 1
        legendary_dict = {False: 0, True: 1}

        # Selecionando apenas as colunas desejadas
        data = data[['Type 1', 'HP', 'Attack', 'Defense', 'Sp. Atk', 'Sp. Def', 'Speed', 'Legendary']]
        
        # Alterando o tipo de dado da coluna indicando a raridade de string para number
        data['Legendary'] = [legendary_dict[item] for item in data['Legendary']]

        # Realizando o processo de one-hot encoding do tipo primário do pokemon
        # https://www.geeksforgeeks.org/python-pandas-get_dummies-method/
        data = pd.get_dummies(data, columns=['Type 1'], prefix=['type1'])

        return data

Dessa maneira, tratamos o dataset de treino para conter apenas os atributos desejados, reduzindo a sujeira e interferência de características secundárias.

## Normalizando dados

O próximo passo é normalizar todos nossos dados, um processo que retira o peso de outliers no treinamento do modelo e torna o processo de aprendizagem mais eficiente. Para mais informações, [esse artigo](https://medium.com/@urvashilluniya/why-data-normalization-is-necessary-for-machine-learning-models-681b65a05029) pode exemplificar melhor o uso da ferramenta.

    # Função para normalizar os dados de treinamento
    def normalizeData(data):
        # Para cada atributo (coluna) do dataframe
        for feature in data.columns:
            # Obtem o maior e menor valor da coluna correspondente
            maxValue = data[feature].max()
            minValue = data[feature].min()

            # Realiza a normalização do dado atual, para que o mesmo sempre
            # corresponda a um valor entre 0 e 1
            data[feature] = (data[feature] - minValue) / (maxValue - minValue)

        return data

## Separando datasets de treino e teste

Primeiramente, definimos que o dataset de treino tera 30% do tamanho do dataset original. Para isso utilizaremos a constante 

    TEST_SIZE = 0.3

Após isso, separamos as entradas na variável X

    x = data.loc[:, data.columns != 'Legendary']
    x.insert(0, 'coefficient', np.ones(len(data.index)))

Assim como as saídas e parâmetros, nas variáveis Y e THETA respectivamente

    y = data['Legendary']
    theta = np.ones(len(x.columns))

Por último, utilizamos a função `train_test_split` da biblioteca `sklearn` para gerar aleatóriamente os datasets de treino e testes, com os tamanhos anteriormente definidos. Também iremos gerar vetores da biblioteca `numpy` com as estruturas geradas para facilitar suas manipulações

    x_train, x_test, y_train, y_test = train_test_split(x, y, test_size = TEST_SIZE, random_state = 0)

    x_train = np.array(x_train)
    y_train = np.array(y_train)
    x_test = np.array(x_test)
    y_test = np.array(y_test)
    theta = np.array(theta).T

Dessa forma, finalizamos o tratamentos dos dados e estamos prontos para colocar o modelo para treinar.

## Função Sigmoid

Na regressão logística, o resultado final não deve ser um resultado continuo, mas um que varia entre 0 (falso) e 1 (verdadeiro). Para obter isso, usaremos a função sigmoid, que garante que para qualquer valor passado o resultado estará nesse intervalo, não importa o quão grande sejam os parâmetros calculados.

<figure src="sig_formula.png" width="100%"></figure>

<figure src="sig_plot.png" width="100%"></figure>

Apesar de parecer complicada, a fórmula pode facilmente ser reproduziada com a seguinte função

    # Função para calcular sigmoid
    def sigmoidFunction(x, theta):
        sigma = 1 / (1 + np.exp(- np.sum(x * theta, 1)))

        return sigma

## Gradiente Descendente

Uma vez definido a função que irá calcular a saída dada uma entrada e os parâmetros THETA, a função do gradiente descendente será ajustar esses parâmetros para que a saída se aproxime cada vez mais do resultado real.

Para cada vez que a saída for calculada, uma função de custo será computada, para que possamos medir a diferença entre a previsão e o resultado esperado. Custos muito altos indicam que os parâmetros não estão bem ajustados e devem sofrer alterações maiores na próxima iteração, e vice-versa.

    # Função para calcular o custo
    def costFunction(y_pred, y):
        cost = - np.sum((y * np.log(y_pred)) + ((1 - y) * (np.log(1 - y_pred)))) / (len(y_pred))

        return cost

Sendo assim, o custo será calculado e deve ser minimizado até a convergência, um estado onde alterações em parâmetros mudam muito pouco o custo final, e podemos dizer que o algortimo está treinado. Para minimizar a função, o modelo usa a derivação do grediente descendente para cada parâmetro THETA, e atualiza todos eles simultaneamente.

<figure src="gradient.png" width="100%"></figure>

Dessa maneira, caso um bom ritmo de aprendizado `α` for escolhido, o custo deve cair a cada repetição, aumentando a precisão do algoritmo.

<figure src="cost_plot.png" width="100%"></figure>


Primeiramente, definimos o estado de convergência e o ritmo de aprendizagem

    EXPECTED_COST = 0.00000003
    ALPHA = 0.003

Após isso, estamos prontos para implementar a função que utilizará esses parâmetros

    # Função para realizar o gradiente
    def gradientDescent(x, y, theta):
        # Vetor dos custos para plotar
        costArray = []
        # Booleano para controlar a convergência
        convergence = False

        while not convergence:
            # Calcula a saída com os parâmetros atuais
            y_pred = sigmoidFunction(x, theta)
            # Calcula a perda
            loss = y_pred - y

            # Atualiza todos os parâmetros simultaneamente, utilizando
            # o ritmo de aprendizagem ALPHA
            for j in range(len(theta)):
                gradient = 0
                for m in range(len(x)):
                    gradient += loss[m] * x[m][j]
                theta[j] -= (ALPHA/len(x)) * gradient

            # Calcula o custo
            cost = costFunction(y_pred, y)
            print(cost)

            costArray.append(cost)

            # Verifica se convergiu (caso a mudança do custo atual para o custo anterior)
            # seja menor que o parâmetro EXPECTED_COST
            costReduction = costArray[-1] - cost if costArray else cost
            convergence = costReduction < EXPECTED_COST

        return theta, costArray

Assim que essa função convergir, teremos os parâmetros THETA e um vetor mostrando a minimização dos custo do modelo que agora está completamente treinado.

## Plotando o custo

A fim de curiosidade (e para ajustar constantes), podemos plotar a redução do custo do algoritmo para visulizar se o processo ocorreu com sucesso.

Para isso, utilizaremos o vetor de custos retornado pela função `gradientDescent` e plotaremos com a função `plot` da biblioteca `matplotlib`.

    theta, cost = gradientDescent(x_train, y_train, theta)

    plt.plot(list(range(len(cost))), cost, '-r')
    plt.xlabel("Number of iterations")
    plt.ylabel("Cost")
    plt.show()

## Testando o resultado

Para testar os parâmetros obtidos, definiremos uma função de teste que apenas irá tentar prever os resultados para dados desconhecidos e colocará essas previsões lado a lado com as saídas reais.

    # Função para testar os parâmetros finais
    def testModel(x, y, theta):
        # Realiza a função sigmoid em dados desconhecidos
        y_pred = sigmoidFunction(x, theta)

        # Cria um dataframe com as previsões lado a lado com as saídas reais
        df = {'y_pred': y_pred, 'y': y}
        df = pd.DataFrame(df)

        # Arredonda as previsões (pois a função sigmoid nunca retornará 1 ou 0)
        # mas valores próximos a isso
        df['y_pred'] = [round(item) for item in df['y_pred']]

        return df

Após isso, utilizaremos a função `accuracy_score` da biblioteca `sklearn` para definir a precisão geral do modelo.

    test = testModel(x_test, y_test, theta)
    score = accuracy_score(test['y'], test['y_pred'])
    print('The overall model accuracy is: ' + str(score))

Por fim, obtivemos o seguinte resultado

    EXPECTED_COST = 0.00000003
    ALPHA = 3
    TEST_SIZE = 0.3

    The overall model cost is: 0.0812384
    The overall model accuracy is: 0.9166666

    Outputs
            Name  Result
    0  Bulbasaur    0.00
    1   Squirtle    0.00
    2   Clefairy    0.00
    3    Moltres    0.35
    4      Lugia    0.99
    5      Ho-oh    0.94
    6     Celebi    0.71

# Resultado final

O resultado final desse projeto pode ser encontrado no meu [github pessoal](https://github.com/viniciuslazzari/PokemonPrediction).