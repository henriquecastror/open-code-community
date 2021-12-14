---

title: "VariaÃÂ§ÃÂµes do teorema central do limite para matrizes aleatÃÂ³rias: de nÃÂºcleos atÃÂ´micos a filtragem de matrizes de correlaÃÂ§ÃÂ£o"

categories: []

date: '2021-12-06T00:00:00Z' 

draft: no 

featured: no

image:
  caption: 
  focal_point: 
  preview_only: 

projects: []

subtitle: null

summary: null

tags: 
- portfolio
- correlaÃÂ§ÃÂ£o
- matrizes aleatÃÂ³rias
- teoria espectral
- python
- otmizaÃÂ§ÃÂ£o
- autovalores
- histÃÂ³ria da ciÃÂªncia
authors:
- devmessias


---

No cÃÂ©lebre trabalho Ã¢ÂÂ*Can One Hear the Shape of a Drum?*Ã¢ÂÂ[1] Kack questiona se conhecendo o espectro (*som*) de um certo operador que define as oscilaÃÂ§ÃÂµes de uma membrana (*tambor*) seria possÃÂ­vel identificar o formato de tal membrana de maneira unÃÂ­voca. Discutiremos aqui como ÃÂ© possÃÂ­vel ouvir matrizes de correlaÃÂ§ÃÂ£o usando seu espectro e como podemos remover o ruÃÂ­do desse som usando resultados da teoria de matrizes aleatÃÂ³rias. Veremos como essa filtragem pode aprimorar algoritmos de construÃÂ§ÃÂ£o de carteiras de investimentos.


> Minhas motivaÃÂ§ÃÂµes para escrever esse texto foram o movimento [Learn In Public-Sibelius Seraphini](https://twitter.com/sseraphini/status/1458169250326142978) e o Nobel de FÃÂ­sica de 2021. Um dos temas de Giorgio Parisi  ÃÂ© o estudo de matrizes aleatÃÂ³rias [www.nobelprize.org 2021](https://www.nobelprize.org/uploads/2021/10/sciback_fy_en_21.pdf).

..
> Jupyter notebook disponÃÂ­vel [aqui](https://github.com/devmessias/devmessias.github.io/blob/master/content/post/random_matrix_portfolio/index.ipynb)



# 1-IntroduÃÂ§ÃÂ£o: teorema central do limite
O teorema central do limite estÃÂ¡ no coraÃÂ§ÃÂ£o da anÃÂ¡lise estatÃÂ­stica. Em poucas palavras o mesmo estabelece o seguinte.

> Suponha uma amostra $A = (x_1, x_2, \dots, x_n)$ de uma variÃÂ¡vel aleatÃÂ³ria com mÃÂ©dia $\mu$ e variÃÂ¢ncia $\sigma^2$ finita. Se a amostragem ÃÂ© $i.i.d.$ o teorema central do limite estabelece que a 
>  distribuiÃÂ§ÃÂ£o de probababilidade da mÃÂ©dia amostral converge 
> para uma distribuiÃÂ§ÃÂ£o normal com variÃÂ¢ncia $\sigma^2/n$ e mÃÂ©dia $\mu$ a medida que $n$ aumenta.

Note que eu nÃÂ£o disse nada a respeito de como tal amostra foi gerada; em nenhum momento citei distribuiÃÂ§ÃÂ£o de Bernoulli, Gauss, Poisson, etc. Desta maneira podemos dizer que tal convergÃÂªncia ÃÂ© uma propriedade **universal** de amostras aleatÃÂ³rias $i.i.d.$. Essa universalidade ÃÂ© poderosa, pois  garante que ÃÂ© possÃÂ­vel estimar a mÃÂ©dia e variÃÂ¢ncia de uma populaÃÂ§ÃÂ£o  atravÃÂ©s de um conjunto de amostragens. 

NÃÂ£o ÃÂ© difÃÂ­cil fazer um experimento computacional onde a implicaÃÂ§ÃÂ£o desse teorema apareÃÂ§a




```python
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
import warnings
from matplotlib import style

warnings.filterwarnings('ignore')
style.use('seaborn-white')

np.random.seed(22)
```

Usaremos uma amostragem de uma distribuiÃÂ§ÃÂ£o exponencial com mÃÂ©dia $\mu = 4$. Tal distribuiÃÂ§ÃÂ£o tem uma variÃÂ¢ncia dada por $1/\mu^2$. Faremos $10000$ experimentos com amostras de tamanho $500$. Posteriormente calcularemos a media de cada experimento, `mean_by_exp`


```python
rate = 0.25

mu = 1/rate

sample_size=500
exponential_sample = np.random.exponential(mu, size=(sample_size, 30000))
mean_by_exp = exponential_sample.mean(axis=0)
```

Agora basta plotar o histograma em comparaÃÂ§ÃÂ£o com a distribuiÃÂ§ÃÂ£o normal dada pelo teorema central do limite


```python
sns.distplot(mean_by_exp, norm_hist=True, label='sample')
x = np.linspace(2.5, 5.5, 100)
var = mu**2/(sample_size)
y = np.exp(-(x-mu)**2/(2*var))/np.sqrt(2*np.pi*var)
plt.plot(x, y, label=r'$N(\mu, \sigma)$', c='tomato')
plt.legend()
plt.xlim(3., 5)
plt.savefig('exponential_distribution.png', facecolor='w')
plt.close()
```

!["exponential_distribution.png"](exponential_distribution.png)

Note  na figura acima que o plot para a funÃÂ§ÃÂ£o $\frac{e^{-\frac{(x-\mu)^2}{2\sigma^2}}}{\sqrt(2\pi\sigma^2)}$ e o histograma coincidem.  VocÃÂª pode testar essa coincidÃÂªncia com outras distribuiÃÂ§ÃÂµes, o mesmo comportamento se repetira. ÃÂ isso que quero dizer com **universalidade**.

Um questionamento vÃÂ¡lido ÃÂ© que estamos tratando apenas de uma variÃÂ¡vel aleatÃÂ³ria e sua amostragem. Mas no mundo real existem outras estruturas mais intricadas. Por exemplo
 pegue um conjunto de variÃÂ¡veis aleatÃÂ³rias 
$\mathcal C=(X_{1 1}, X_{1 2}, \cdots, X_{N N})$,  suponha que exista uma certa **simetria** nesse conjunto, uma possibilidade ÃÂ© $X_{i j} = X_{j i}$.
NÃÂ£o ÃÂ© difÃÂ­cil imaginar situaÃÂ§ÃÂµes onde tal conjunto apareÃÂ§a. 

Podemos armazenar uma realizaÃÂ§ÃÂ£o de $\mathcal C$ em uma matriz que nada mais ÃÂ© que um grafo completo com pesos. Ao estudar essas matrizes oriundas desse tipo de amostragem entramos em um novo campo da matemÃÂ¡tica, o campo das matrizes aleatÃÂ³rias. 
Nesse campo de estudos uma amostragem nÃÂ£o retorna um nÃÂºmero, mas sim uma matriz.

A funÃÂ§ÃÂ£o `normalRMT` apresentada abaixo ÃÂ© um gerador de matrizes aleatÃÂ³rias conhecidas como Gaussianas ortogonais.


```python
def normalRMT(n=100):
    """Generate a random matrix with normal distribution entries
    Args:
        n : (int) number of rows and columns
    Returns:
        m : (numpy.ndarray) random matrix

    """
    std = 1/np.sqrt(2)
    m = np.random.normal(size=(n,n), scale=std)
    m = (m+m.T)
    m /= np.sqrt(n)
    return m
np.set_printoptions(precision=3)
print(f'{normalRMT(3)},\n\n{normalRMT(3)}')
```

    [[-1.441e+00 -2.585e-01 -1.349e-01]
     [-2.585e-01 -2.304e-01  1.166e-03]
     [-1.349e-01  1.166e-03 -1.272e+00]],
    
    [[-0.742  0.607 -0.34 ]
     [ 0.607  0.678  0.277]
     [-0.34   0.277 -0.127]]


Sabemos que quando estamos trantando de variÃÂ¡veis aleatÃÂ³rias  o teorema central do limite ÃÂ© importantÃÂ­ssimo. O que vocÃÂª pode se perguntar agora ÃÂ©: **Existe um anÃÂ¡logo para o teorema central do limite para matrizes aleatÃÂ³rias?**

# 2-NÃÂºcleos atÃÂ´micos, gÃÂ¡s de nÃÂºmeros primos e universalidade

Para o bem e para o mal o conhecimento da fÃÂ­sica atÃÂ´mica foi um dos temas mais importantes desenvolvidos pela humanidade. Portanto, nÃÂ£o ÃÂ© de se estranhar que apÃÂ³s o ano de 1930 iniciou-se uma grande corrida para compreender nÃÂºcleos atÃÂ´micos pesados e a fÃÂ­sica de nÃÂªutrons [13].

Para compreender essa nova fÃÂ­sica de nÃÂªutrons era necessÃÂ¡rio conhecer a organizaÃÂ§ÃÂ£o do  espectro de ressonÃÂ¢ncia dos nÃÂºcleos pesados (esse espectro nada mais ÃÂ© que os autovalores de um operador muito especial). Uma maneira de se fazer isso ÃÂ© do jeito que muitas das coisas sÃÂ£o estudadas na fÃÂ­sica: pegando se uma coisa  e jogando na direÃÂ§ÃÂ£o da coisa a ser estudada. Essa metodologia experimental torna possÃÂ­vel amostrar alguns valores possÃÂ­veis para o espectro. Contudo, acredito que nÃÂ£o preciso argumentar que fazer isso naquela ÃÂ©poca era extremamente difÃÂ­cil e caro. Poucos centros conseguiam realizar alguns experimentos e ainda com uma resoluÃÂ§ÃÂ£o muito baixa para obter resultados suficientes para uma compreensÃÂ£o adequada dos nÃÂºcleos. Era preciso uma saÃÂ­da mais barata e ela foi encontrada. Tal saÃÂ­da dependeu apenas de fÃÂ­sica-matemÃÂ¡tica e maÃÂ§os de papel. 

![](frog.png)

Dentre os pioneiros que decidiram atacar o problema de nÃÂºcleos pesados usando matemÃÂ¡tica temos Eugene Paul Wigner (Nobel de 1963).  A grande sacada de Wigner foi perceber que o fato das interaÃÂ§ÃÂµes nucleares serem tÃÂ£o complicadas e a infinitude de graus de liberdade seria possÃÂ­vel tentar compreender essas interaÃÂ§ÃÂµes como uma amostragem sujeita a certas condiÃÂ§ÃÂµes de simetria.[10 , 11]

![wigner.png](wigner.png)


Aqui com simetria queremos dizer que as matrizes envolvidas possuem certas restriÃÂ§ÃÂµes tais como 

```python 
np.assert_equal(A, A.T)
```

Na prÃÂ³xima seÃÂ§ÃÂ£o veremos qual o impacto dessas restriÃÂ§ÃÂµes na distribuiÃÂ§ÃÂ£o de autovalores das matrizes envolvidas.



## 2-a) Universalidade e lei do   semicÃÂ­rculo


A funÃÂ§ÃÂ£o `normalRMT` gera uma matriz simÃÂ©trica onde as entradas sÃÂ£o extraÃÂ­das de uma distribuiÃÂ§ÃÂ£o normal. A funÃÂ§ÃÂ£o `laplaceRMT` gera tambÃÂ©m uma matriz simÃÂ©trica, contudo as entradas sÃÂ£o amostras de uma distribuiÃÂ§ÃÂ£o de Laplace.


```python

def laplaceRMT(n=100):
    """Generate a random matrix with Laplace distribution
    Args:
        n : (int) size of the matrix
    Returns:
        m : (numpy.ndarray) random matrix with Laplace distribution

    """
    # we know that the variance of the laplace distribution is 2*scale**2
    scale = 1/np.sqrt(2)
    m = np.zeros((n,n))

    values = np.random.laplace(size=n*(n-1)//2, scale=scale)
    m[np.triu_indices_from(m, k=1)] = values
    # copy the upper diagonal to the lower diagonal
    m[np.tril_indices_from(m, k=-1)] = values 
    np.fill_diagonal(m, np.random.laplace(size=n, scale=scale))
    m = m/np.sqrt(n)
    return m
```

As propriedades **universais** que iremos explorar aqui estÃÂ£o ligadas aos autovalores das matrizes que foram amostradas. Como nossas matrizes sÃÂ£o simÃÂ©tricas  esses autovalores sÃÂ£o todos reais.

Como cada matriz ÃÂ© diferente os autovalores tambÃÂ©m serÃÂ£o, eles tambÃÂ©m sÃÂ£o variÃÂ¡veis aleatÃÂ³rias.


```python
vals_laplace = np.array([
    np.linalg.eigh(laplaceRMT(n=100))[0]
    for i in range(100)
])
vals_normal = np.array([
    np.linalg.eigh(normalRMT(n=100))[0]
    for i in range(100)
])
```

Na decÃÂ¡da de 50 nÃÂ£o havia poder computacional 
suficiente para realizar investigaÃÂ§ÃÂµes nÃÂºmericas, mas vocÃÂª pode facilmente investigar como os  autovalores se distribuem usando seu computador e gerando os histogramas


```python
t = 1
x  =   np.linspace(-2*t, 2*t, 100)
y =  np.zeros_like(x)
x0 = x[4*t-x*2>0]
y[4*t-x*2>0] = np.sqrt(4*t-x0**2)/(2*np.pi*t)

plt.figure(facecolor='white')
plt.hist(vals_laplace.flatten(), bins=50, 
hatch ='|',
density=True, label='laplace', alpha=.2)
plt.hist(vals_normal.flatten(), bins=50,
hatch ='o', 
density=True, label='normal', alpha=.2)
#sns.distplot(vals_laplace, norm_hist=True, label='Laplace')
#sns.distplot(vals_normal, norm_hist=True, label='Normal')
#sns.distplot(vals2, norm_hist=True, label='sample2')
plt.plot(x, y, label='analytical')
plt.xlabel(r'$\lambda$')
plt.ylabel(r'$\rho(\lambda)$')
plt.legend()
plt.savefig('RMT_distribution.png', facecolor='w')
plt.close()
```

![](RMT_distribution.png)

Veja na figura acima que a distribuiÃÂ§ÃÂ£o de autovalores de matrizes simÃÂ©tricas  relacionadas com a distribuiÃÂ§ÃÂ£o normal e de Laplace coincidem. O que estamos vendo aqui ÃÂ© uma propriedade **universal**! Espero que vocÃÂª acredite em mim, mas dado que vocÃÂª tenha uma matriz aleatÃÂ³ria simÃÂ©trica, quadrada e se as entradas sÃÂ£o $i.i.d.$  a distribuiÃÂ§ÃÂ£o de autovalores seguem o que ÃÂ© conhecido como lei de   semicÃÂ­rculo de Wigner. Se a mÃÂ©dia e variÃÂ¢ncia das entradas da matriz sÃÂ£o  $0$ e $1$  respectivamente, entÃÂ£o tal lei tem a seguinte expressÃÂ£o para a distribuiÃÂ§ÃÂ£o de probabilidade dos autovalores
$$
\rho(\lambda) = \begin{cases}
\frac{\sqrt{4-\lambda^2}}{(2\pi)}  \textrm{ se } 4-\lambda^2 \leq 0\newline
0  \textrm{ caso contrÃÂ¡rio.} 
\end{cases}
$$

  Se trocarmos as simetrias, restriÃÂ§ÃÂµes ou formato (`array.shape[0]!=array.shape[1]`) das matrizes podemos encontrar variaÃÂ§ÃÂµes  da distribuiÃÂ§ÃÂ£o apresentada acima. Exemplo se a matriz ÃÂ© complexa mas Hermitiana, ou  se ÃÂ© "retangular" e real tal como algums matrizes que sÃÂ£o usadas para otimizar carteiras de investimento. A prÃÂ³xima seÃÂ§ÃÂ£o mostrarÃÂ¡ um caso com outro formato para universalidade.


## 2-b) RepulsÃÂ£o entre nÃÂºmeros primos


Inciamos nosso texto falando sobre como a teoria de matrizes aleatÃÂ³rias floreceu com os estudos estatÃÂ­sticos de nÃÂºcleos atÃÂ´micos pesados, especificamente nos trabalhos de Wigner. Embora tenha essa origem, muitas vezes ferramentas matemÃÂ¡ticas desenvolvidas apenas por motivaÃÂ§ÃÂµes prÃÂ¡ticas alcanÃÂ§am outros ramos da matemÃÂ¡tica. Brevemente discutirei aqui alguns pontos e relaÃÂ§ÃÂµes com uma das conjecturas mais famosas da matemÃÂ¡tica: a hipÃÂ³tese de Riemann.


Qualquer pessoa com alguma curiosidade sobre matemÃÂ¡tica jÃÂ¡ ouviu falar sobre a hipÃÂ³tese de Riemann. Essa hipÃÂ³tese estabele uma relaÃÂ§ÃÂ£o entre os zeros da funÃÂ§ÃÂ£o zeta de Riemann e a distribuiÃÂ§ÃÂ£o de nÃÂºmeros primos.  Dada sua importÃÂ¢ncia os maiores ciÃÂªntistas do sÃÂ©culo XX se debruÃÂ§aram sobre ela almejando a imortalidade. Um desses ciÃÂªntistas foi  Hugh Montgomery[4]. 

Por volta de 1970 Montgomery notou que os zeros da funÃÂ§ÃÂ£o zeta tinham uma certa propriedade cuirosa, pareciam repelir uns aos outros. Uma expressÃÂ£o foi obtidada,  que ÃÂ© a seguinte

$$
1 - \left( \frac{\sin (\pi u)}{\pi u}\right)^2 + \delta(u)
$$

NÃÂ£o se preocupe em entender a expressÃÂ£o acima, ela estÃÂ¡ aqui apenas for motivos estÃÂ©ticos. 
O que importa ÃÂ© que ela ÃÂ© simples, tÃÂ£o simples que quando Freeman Dyson  - um dos gigantes da fÃÂ­sica-matemÃÂ¡tica - colocou os olhos sobre tal equaÃÂ§ÃÂ£o ele notou imediatamente que tal equaÃÂ§ÃÂ£o era idÃÂªntica a obtida no contexto de matrizes aleatÃÂ³rias Hermitianas (uma matriz ÃÂ© hermitiana se ela ÃÂ© igual a sua transporta conjugada) utilizadas para compreender o comportamento de nÃÂºcleos de ÃÂ¡tomos pesados, tais como urÃÂ¢nio. A imagem abaixo ÃÂ© uma carta  escrita por Dyson.

![](carta.png)

As conexÃÂ£o entre um ferramental desenvolvido para estudar nÃÂºcleos atÃÂ´micos e nÃÂºmeros primos era realmente inesperada e talvez seja um dos caminhos para a prova da hipotese de Riemann[5, 2]. Contudo deixemos a histÃÂ³ria de lado, e voltemos ao ponto principal que ÃÂ© te dar outro exemplo de universalidade. 

Lembra que Montgomery disse que parecia haver uma repulsÃÂ£o entre os zeros da funÃÂ§ÃÂ£o Zeta? O que seria esse conceito de repulsÃÂ£o em matrizes aleatÃÂ³rias? Vamos checar numericamente 

Voltaremos a usar nossas matrizes aleatÃÂ³rias geradas por distribuiÃÂ§ÃÂµes Gaussianas e Laplacianas. Usando o mesmo conjunto de autovalores que obtivemos anteriormente iremos calular o espaÃÂ§amento entre cada par de autovalores para cada realizaÃÂ§ÃÂ£o de uma matriz aleatÃÂ³ria. ÃÂ bem fÃÂ¡cil, basta chamar a funÃÂ§ÃÂ£o `diff` do numpy


```python
diff_laplace = np.diff(vals_laplace, axis=1)
diff_normal = np.diff(vals_normal, axis=1)
```

Agora o que faremos ÃÂ© estimar a densidade de probabilidade usnado KDE. Mas antes disso aqui vai uma dica: 

>**Evite o KDE do sklearn no seu dia a dia, a implementaÃÂ§ÃÂ£o ÃÂ© lenta e nÃÂ£o flexivÃÂ©l. DifÃÂ­cilmente vocÃÂª conseguirÃÂ¡ bons resultados com milhÃÂµes de pontos. Aqui vou usar uma implementaÃÂ§ÃÂ£o de KDE mais eficiente vocÃÂª pode instalar ela execuntando o comando abaixo**


```python
!pip install KDEpy
```


```python
from KDEpy import FFTKDE

estimator_normal = FFTKDE( bw='silverman').fit(diff_normal.flatten())
x_normal, probs_normal = estimator_normal.evaluate(100)
mu_normal = np.mean(diff_normal, axis=1).mean()

estimator_laplace = FFTKDE( bw='silverman').fit(diff_laplace.flatten())
x_laplace, probs_laplace = estimator_laplace.evaluate(100)
mu_laplace = np.mean(diff_laplace, axis=1).mean()
```


```python
goe_law = lambda x: np.pi*x*np.exp(-np.pi*x**2/4)/2
spacings = np.linspace(0, 4, 100)
p_s = goe_law(spacings)

plt.plot(spacings, p_s, label=r'GOE analÃÂ­tico', c='orange', linestyle='--')
plt.plot(
    x_normal/mu_normal, 
    probs_normal*mu_normal, 
    linestyle=':',
    linewidth=2,
    zorder=1,
    label='normal', c='black')
plt.plot(x_laplace/mu_laplace, probs_laplace*mu_laplace, zorder=2,
linestyle='--', label='laplace', c='tomato')
plt.legend()
plt.savefig('RMT_diff_distribution.png', facecolor='w')
plt.close()
```

![](RMT_diff_distribution.png)

O que as distribuiÃÂ§ÃÂµes acima dizem ÃÂ© que dado sua matriz ser $i.i.d.$ quadrada e simÃÂ©trica entÃÂ£o a probabilidade que vocÃÂª encontre dois autovalores iguais ÃÂ© $0$ (zero). AlÃÂ©m do mais, existe um ponto de mÃÂ¡ximo global em relaÃÂ§ÃÂ£o a distribuiÃÂ§ÃÂ£o de espaÃÂ§amentos. Esse comportamento que balanceia repulsÃÂ£o e atraÃÂ§ÃÂ£o dos autovalores lembra o comportamento de partÃÂ­culas em um fluÃÂ­do. NÃÂ£o ÃÂ© de espantar que o mÃÂ©todo matemÃÂ¡tico desenvolvido por Wigner para compreender tais matrizes foi denominado GÃÂ¡s de Coloumb[2].

Agora que vocÃÂª tem pelo menos uma ideia do que seria essa repulsÃÂ£o para o caso que jÃÂ¡ abordamos (matrizes simÃÂ©tricas quadradas) voltemos ao problema dos nÃÂºmeros primos.

O comando a seguir baixa os primeiros 100k zeros da funÃÂ§ÃÂ£o zeta 


```python
!wget http://www.dtc.umn.edu/~odlyzko/zeta_tables/zeros1
```

Um pequeno preprocessamento dos dados:


```python
zeros = []
with open('zeros1', 'r') as f:
    for line in f.readlines():
        # remove all spaces in the line and convert it to a float
        zeros.append(float(line.replace(' ', '')))
zeta_zeros = np.array(zeros)
```

Iremos calcular os espaÃÂ§amentos entre os zeros, a  mÃÂ©dia de tais espaÃÂ§amento e executar um KDE


```python
from KDEpy import FFTKDE

diff_zeta = np.diff(zeta_zeros[10000:])
m = np.mean(diff_zeta)
estimator = FFTKDE( bw='silverman').fit(diff_zeta)

```


```python
x, probs = estimator.evaluate(100)
p = np.pi
goe_law = lambda x: p*x*np.exp(-p*x**2/4)/2
def gue(xs):
    arg = -4/np.pi*np.power(xs,2)
    vals = 32/np.pi**2*xs**2*np.exp(arg)
    return vals
spacings = np.linspace(0, 4, 100)
p_s = gue(spacings)
p_s2 = goe_law(spacings)
plt.plot(x/m, probs*m, label='zeros zeta', linestyle='--')
plt.plot(spacings, p_s, label=r'GUE analÃÂ­tico', c='blue', linestyle='-.')
plt.plot(spacings, p_s2, label=r'GOE analitico', c='orange', linestyle='-.')
plt.xlim(-0.1, 4)
plt.legend()
plt.savefig('zeta.png', facecolor='w')
plt.close()
```

![](zeta.png)

Veja que a propriedade de repulsÃÂ£o apareceu novamente. Note que dentro do plot eu coloquei uma outra curva `GOE analÃÂ­tico`, essa curva ÃÂ© aquela que melhor descreve a distribuiÃÂ§ÃÂ£o de espaÃÂ§amentos quando suas matrizes aleatÃÂ³rias sÃÂ£o simÃÂ©tricas. Isso ÃÂ© uma liÃÂ§ÃÂ£o importante aqui e resalta o que eu jÃÂ¡ disse anteriormente. NÃÂ£o temos apenas *"um limite central para matrizes aleatÃÂ³rias*", mas todo um **zoolÃÂ³gico que mudarÃÂ¡ dependendo do tipo do seu problema.**. 

# 3-Usando *RMT* para encontrar e filtrar ruÃÂ­dos em matrizes

Na seÃÂ§ÃÂ£o 1 relembramos o resultado do teorema central do limite. Na seÃÂ§ÃÂ£o 2 foi mostrado que devemos ter em mente as simetrias e restriÃÂ§ÃÂµes do nosso problema para analisar qual regra de universalidade ÃÂ© respeitada. Isto ÃÂ©: a depender da simetria e restriÃÂ§ÃÂµes das nossas matrizes temos um outro "*timbre de universalidade*".

Um exemplo de outro timbre surge no espectro de matrizes de correlaÃÂ§ÃÂ£o; matrizes que sÃÂ£o comumente utilizadas para anÃÂ¡lise de carteiras de investimento. Tais matrizes tem **pelo menos a seguinte estrutura**:

$$
\mathbf C = \mathbf X \mathbf X^T
$$
onde $\mathbf X$ ÃÂ© uma matriz real $N\times M$ e $M>N$. 

O cÃÂ³digo abaixo permite explorar em um exemplo o espectro de matrizes aleatÃÂ³rias  $N\neq M$ com entradas dadas pela distribuiÃÂ§ÃÂ£o normal.



```python
def get_marchenko_bounds(Q, sigma=1):
    """Computes the Marchenko bounds for a given Q and sigma.

    Args:
        Q : (float) The Q-value.
        sigma : (float) The std value. 
    Returns:
        (float, float): The lower and upper bounds for the eigenvalues.

    """
    QiSqrt = np.sqrt(1/Q)
    lp = np.power(sigma*(1 + QiSqrt),2) 
    lm = np.power(sigma*(1 - QiSqrt),2) 
    return lp, lm

def marchenko_pastur(l, Q, sigma=1):
    """Return the probability of a Marchenko-Pastur distribution for 
    a given Q , sigma and eigenvalue.

    Args:
        l : (float) The eigenvalue.
        Q : (float) The Q-value.
        sigma : (float) The std value.
    Returns:
        (float): The probability
    """
    lp, lm = get_marchenko_bounds(Q, sigma)
    # outside the interval [lm, lp]
    if l > lp or l < lm:
        return 0
    return (Q/(2*np.pi*sigma*sigma*l))*np.sqrt((lp-l)*(l-lm))

def plot_marchenko_pastur(ax, eigen_values, Q, sigma=1, bins=100, just_the_bulk=False):
    """Plots the Marchenko-Pastur distribution for a given Q and sigma 
    
    Args:
        ax  : (matplotlib.axes) The axes to plot on.
        eigen_values : (np.array) The eigenvalues.
        Q  : (float) : The Q-value.
        sigma : (float) std
        bins : (int) The number of bins to use.
        just_the_bulk : (bool) If True, only the eigenvalues inside of 
            the Marchenko-Pastur bounds are plotted.

    """
    l_max, l_min = get_marchenko_bounds(Q, sigma)
    eigenvalues_points = np.linspace(l_min, l_max, 100)
    pdf = np.vectorize(lambda x : marchenko_pastur(x, Q, sigma))(eigenvalues_points)
    if just_the_bulk:
        eigen_values = eigen_values[ (eigen_values < l_max)]
    ax.plot(eigenvalues_points, pdf, color = 'r', label='Marchenko-Pastur')
    ax.hist(eigen_values,  label='sample', bins=bins , density=True)
    ax.set_xlabel(r"$\lambda$")
    ax.set_ylabel(r"$\rho$")
    ax.legend()

N = 1000
T = 4000
Q = T/N

X = np.random.normal(0,1,size=(N,T))
cor = np.corrcoef(X)
vals = np.linalg.eigh(cor)[0]

fig, ax = plt.subplots(1,1)
plot_marchenko_pastur(ax, vals, Q, sigma=1, bins=100)

plt.legend()
plt.savefig('Marchenko_Pastur.png', facecolor='w')
plt.close()
```

![](Marchenko_Pastur.png)



A funÃÂ§ÃÂ£o em vermelho na figura acima ÃÂ© a **universalidade** que aparece em matrizes com a restriÃÂ§ÃÂ£o $N\times M$ e entradas $i.i.d.$ e mÃÂ©dia $0$. Tal **universalidade** tem como formato a distribuiÃÂ§ÃÂ£o de Marchenko-Pastur que ÃÂ© dada por 

$$
\rho (\lambda) = \frac{Q}{2\pi \sigma^2}\frac{\sqrt{(\lambda_{\max} - \lambda)(\lambda - \lambda_{\min})}}{\lambda}
$$
onde
$$
\lambda_{\max,\min} = \sigma^2(1 \pm \sqrt{\frac{1}{Q}})^2.
$$

Note os parÃÂ¢metros como $Q$ e $\sigma$. Tais  parÃÂ¢metros precisam ser ajustados para obter um melhor fit com dados reais. 


Agora iremos para um caso real. Vamos usar dados obtidos via Yahoo Finance com a biblioteca `yfinance` para consturir uma matriz de correlaÃÂ§ÃÂ£o com dados de ativos financeiros


```python
# vocÃÂª precisa desse pacote para baixar os dados
!pip install yfinance
```

Isso aqui ÃÂ© um post bem informal, entÃÂ£o  peguei peguei uma lista aleatÃÂ³ria com alguns tickers que encontrei na internet


```python

!wget https://raw.githubusercontent.com/shilewenuw/get_all_tickers/master/get_all_tickers/tickers.csv
```

selecionei apenas 500 para evitar que o processo de download seja muito demorado



```python
tickers = np.loadtxt('tickers.csv', dtype=str, delimiter=',').tolist()
tickers = np.random.choice(tickers, size=500, replace=False).tolist()
```

vamos baixar agora os dados em um periÃÂ³do especÃÂ­fico


```python

import yfinance as yf

df  = yf.download (tickers, 
                   start="2017-01-01", end="2019-10-01",
                   interval = "1d",
                   group_by = 'ticker',
                   progress = True)
```

o  `yfinance` vai gerar um dataframe com multiindex, entÃÂ£o precisamos separar da 
forma que queremos


```python

tickers_available = list(set([ ticket for ticket, _ in df.columns.T.to_numpy()]))
prices = pd.DataFrame()
for ticker in tickers_available:
    try:
        prices[ticker] = df[(ticker, 'Adj Close')]
    except KeyError:
        pass
```

Agora iremos calcular o retorno. Aqui entra um ponto delicado. VocÃÂª poderÃÂ¡ achar alguns posts na internet ou mesmo artigos argumentando que ÃÂ© necessÃÂ¡rio calcular o retorno como 
$\log (r+1)$ pois assim as entradas da sua matriz seguirÃÂ¡ uma distribuiÃÂ§ÃÂ£o normal o que permitirÃÂ¡ a aplicaÃÂ§ÃÂ£o de RMT. JÃÂ¡ vimos no presente texto que nÃÂ£o precisamos que as entradas da matrizes venham de uma distribuiÃÂ§ÃÂ£o normal para que a **universalidade** apareÃÂ§a. A  escolha ou nÃÂ£o de usar $\log$ nos retornos merece mais atenÃÂ§ÃÂ£o, inclusive com crÃÂ­ticas em relaÃÂ§ÃÂ£o ao uso[6, 7, 8]. Mas esse  post nÃÂ£o pretende te vender nada, por isso vou ficar com o mais simples.


```python
# calculamos os retornos
returns_all = prices.pct_change()

# a primeira linha nÃÂ£o faz sentido, nÃÂ£o existe retorno no primeiro dia
returns_all = returns_all.iloc[1:, :]

# vamos limpar todas as linhas se mnegociaÃÂ§ÃÂ£o e dropar qualquer coluna com muitos NaN
returns_all.dropna(axis = 1, thresh=len(returns_all.index)/2, inplace=True)
returns_all.dropna(axis = 0, inplace=True)
# seleciona apenas 150 colunas 
returns_all = returns_all[np.random.choice(returns_all.columns, size=120, replace=False)]
#returns_all = returns_all.iloc[150:]
```

Com o `df` pronto calcularemos a matriz de correlaÃÂ§ÃÂ£o e seus autovalores


```python
correlation_matrix = returns_all.interpolate().corr()
vals = np.linalg.eigh(correlation_matrix.values)[0]
```

Vamos usar os parÃÂ¢metros padrÃÂµes para $Q$ e $\sigma$ e torcer para que funcione


```python

T, N = returns_all.shape
Q=T/N
sigma= 1

fig, ax = plt.subplots(1,1)
plot_marchenko_pastur(ax, vals, Q, sigma=1, bins=200, just_the_bulk=False)

plt.legend()
plt.savefig('Marchenko_Pastur_all.png', facecolor='w')
plt.close()
```

![](Marchenko_Pastur_all.png)

Usando todo o intervalo de tempo do nosso `df` obtivemos o que parece um ajuste razoÃÂ¡vel. ÃÂ claro que vocÃÂª poderia (deveria) rodar algum teste estatistico para verificar tal ajuste. 
Existem alguns trabalhos que fizeram essa anÃÂ¡lise de forma rigorosa, comparando mercados e periÃÂ³dos especÃÂ­ficos em relaÃÂ§ÃÂ£o a distribuiÃÂ§ÃÂ£o de Marchenko-Pastur[9].  

Se vocÃÂª for uma pessoa atenta notarÃÂ¡ que na imagem acima existem alguns autovalores fora do suporte da Marchenko-Pastur.  A ideia de filtragem via RMT ÃÂ© como dito em [9] testar seus dados em relaÃÂ§ÃÂ£o a "*hipÃÂ³tese nula*" da RMT. No caso se seus autovalores estÃÂ£o dentro do *bulk* da distribuiÃÂ§ÃÂ£o que descreve um modelo de entradas *i.i.d.*. 


Como isso foi aplicado em alguns trabalhos? Vamos ver na prÃÂ¡tica. 


Usaremos $70$% da sÃÂ©rie histÃÂ³rica para calcular uma nova matriz de correlaÃÂ§ÃÂ£o. Com a matriz de correlaÃÂ§ÃÂ£o em mÃÂ£os vamos computar os autovalores e autovetores.



```python
# iremos usar 70% da serie para realizar a filtragem
returns_all.shape[0]*0.70
n_days = returns_all.shape[0]
n_days_in = int(n_days*(1-0.70))


returns = returns_all.copy()
sample = returns.iloc[:(returns.shape[0]-n_days_in), :].copy()

correlation_matrix = sample.interpolate().corr()
vals, vecs = np.linalg.eigh(correlation_matrix.values)

```

Os autovalores e autovetores podem ser compreendidos como a decomposiÃÂ§ÃÂ£o de uma dada matriz. 
Portanto, o seguinte teste precisa passar 


```python
 assert np.abs(
    np.dot(vecs, np.dot(np.diag(vals), np.transpose(vecs))).flatten()
    - correlation_matrix.values.flatten()
 ).max() < 1e-10
```

A distribuiÃÂ§ÃÂ£o de Marchenko-Pastur serve como um indicativo para nossa filtragem. O que faremos ÃÂ© jogar fora todos os autovalores 
que estÃÂ£o dentro da distribuiÃÂ§ÃÂ£o de Marchenko-Pastur, posteriormente reconstruiremos a matriz de correlaÃÂ§ÃÂ£o. 


```python
T, N = returns.shape
Q=T/N
sigma = 1
lp, lm = get_marchenko_bounds(Q, sigma)

# Filter the eigenvalues out
vals[vals <= lp ] = 0
# Reconstruct the matrix
filtered_matrix =  np.dot(vecs, np.dot(np.diag(vals), np.transpose(vecs)))
np.fill_diagonal(filtered_matrix, 1)

```

Com a matriz de correlaÃÂ§ÃÂ£o filtrada  vocÃÂª pode fazer o que bem entender com ela - existem outras maneiras de se realizar uma filtragem  - uma das possÃÂ­veis aplicaÃÂ§ÃÂµes que precisa ser utilizada com cuidado ÃÂ© usar tal matriz filtrada como input para algoritmos de otimizaÃÂ§ÃÂ£o de carteira. Talvez faÃÂ§a um outro post descrevendo essa otimizaÃÂ§ÃÂ£o de forma mais clara, mas esse nÃÂ£o ÃÂ© meu enfoque nesse post e nem minha especialidade. Portanto, se vocÃÂª quiser dar uma lida recomendo os seguintes posts: [17, 18]


O que vocÃÂª precisa saber ÃÂ© que uma matriz de covariÃÂ¢ncia, $\mathbf C_\sigma$, adimite uma decomposiÃÂ§ÃÂ£o em relaÃÂ§ÃÂ£o a matriz de correlaÃÂ§ÃÂ£o atrÃÂ¡ves da seguinte forma 

$$
\mathbf C_\sigma = \mathbf D^{-1/2} \mathbf C \mathbf D^{-1/2}
$$
onde $\mathbf D^{-1/2}$ ÃÂ© uma matriz diagonal com as entradas sendo os desvios padrÃÂ£o para cada serie de dados, isto ÃÂ©  
$$
 \begin{bmatrix} 
 \sigma_{1} &0 &\cdots &0 \\\
  0 &\sigma_{2} &\cdots &0 \\\
    \vdots &\vdots &\ddots &\vdots \\\
    0 &0 &\cdots &\sigma_{M} \end{bmatrix}
$$

Discutimos uma maneira de obter uma matriz de correlaÃÂ§ÃÂ£o filtrada, $\mathbf{\tilde C}$,  atravÃÂ©s de RMT,
a ideia  ÃÂ© plugar essa nova matriz na equaÃÂ§ÃÂ£o anterior e obter uma nova matriz de covariÃÂ¢ncia onde as informaÃÂ§ÃÂµes menos relevantes foram eliminadas. 

$$
\mathbf{\tilde  C_\sigma} = \mathbf D^{-1/2} \mathbf{\tilde C} \mathbf D^{-1/2}.
$$

Tendo essa nova matriz de covÃÂ¢riancia filtrada agora basta vocÃÂª ingerir ela em algum mÃÂ©todo preferido para otimizaÃÂ§ÃÂ£o e comparar com o resultado obtido usando a matriz original.  Aqui usaremos o clÃÂ¡ssico Markowitz


```python
# Reconstruct the filtered covariance matrix
covariance_matrix = sample.cov()
inv_cov_mat = np.linalg.pinv(covariance_matrix)

# Construct minimum variance weights
ones = np.ones(len(inv_cov_mat))
inv_dot_ones = np.dot(inv_cov_mat, ones)
min_var_weights = inv_dot_ones/ np.dot( inv_dot_ones , ones)



variances = np.diag(sample.cov().values)
standard_deviations = np.sqrt(variances) 

D = np.diag(standard_deviations)
filtered_cov = np.dot(D ,np.dot(filtered_matrix,D))
filtered_cov = filtered_matrix

filtered_cov = (np.dot(np.diag(standard_deviations), 
            np.dot(filtered_matrix,np.diag(standard_deviations))))

filt_inv_cov = np.linalg.pinv(filtered_cov)

# Construct minimum variance weights
ones = np.ones(len(filt_inv_cov))
inv_dot_ones = np.dot(filt_inv_cov, ones)
filt_min_var_weights = inv_dot_ones/ np.dot( inv_dot_ones , ones)
def get_cumulative_returns_over_time(sample, weights):
    weights[weights <= 0 ] = 0 
    weights = weights / weights.sum()
    return (((1+sample).cumprod(axis=0))-1).dot(weights)
    
cumulative_returns = get_cumulative_returns_over_time(returns, min_var_weights).values
cumulative_returns_filt = get_cumulative_returns_over_time(returns, filt_min_var_weights).values



```


```python

in_sample_ind = np.arange(0, (returns.shape[0]-n_days_in+1))
out_sample_ind = np.arange((returns.shape[0]-n_days_in), returns.shape[0])
f = plt.figure()

ax = plt.subplot(111)
points = np.arange(0, len(cumulative_returns))[out_sample_ind]
ax.plot(points, cumulative_returns[out_sample_ind], 'orange', linestyle='--', label='original')

ax.plot(points, cumulative_returns_filt[out_sample_ind], 'b', linestyle='-.', label='filtrado')
ymax = max(cumulative_returns[out_sample_ind].max(), cumulative_returns_filt[out_sample_ind].max())
ymin = min(cumulative_returns[out_sample_ind].min(), cumulative_returns_filt[out_sample_ind].min())
plt.legend()
plt.savefig('comp.png', facecolor='w')
plt.close()

```

![](comp.png)

Obtivemos uma melhora, mas novamente ressaltamos que uma analise mais criteriosa deveria ter sido feita. Vamos listar alguns pontos

1.  Em relaÃÂ§ÃÂ£o a questÃÂ£o da escolha do intervalo de tempo. Isto ÃÂ©, se o tamanho foi pequeno de mais para capturar a correlaÃÂ§ÃÂ£o ou se foi grande de mais tal que as correlaÃÂ§ÃÂµes entre ativos nÃÂ£o sÃÂ£o estacionÃÂ¡rias.
2. O (nÃÂ£o) uso do  $\log$-retorno e seu impacto
3. Uma escolha nÃÂ£o aleatÃÂ³ria do que seria analisado 
4. MÃÂ©todos de unfolding dos autovalores (tema para outro post)

# 5 - Vantagens, crÃÂ­ticas e sugestÃÂµes

VocÃÂª poderÃÂ¡ encontrar alguns trabalhos e posts descrevendo o uso de matrizes aleatÃÂ³rias para filtragem de matrizes de correlaÃÂ§ÃÂ£o sem uma boa crÃÂ­tica ou explicitaÃÂ§ÃÂ£o das limitaÃÂ§ÃÂµes vou linkar aqui alguns pontos positivos e negativos e limitaÃÂ§ÃÂµes

## Onde realmente RMT se mostrou ÃÂºtil

  - Obviamente a RMT ÃÂ© indiscutivelmente bem sucedida na matemÃÂ¡tica e fÃÂ­sica permitindo compreender sistemas apenas analisando a estatÃÂ­stica dos *gases matriciais*.
  - Em machine learning a RMT tambÃÂ©m estÃÂ¡ provando ser uma ferramenta ÃÂºtil para compreender e melhorar o processo de aprendizado [15].
  - Entender comportamentos de sistemas sociais, biolÃÂ³gicos e econÃÂ´micos. Aqui com entender o comportamento digo apenas saber se um dado segue uma caracterÃÂ­stica dada por alguma lei especÃÂ­fica como a lei de semicÃÂ­rculo. Isto ÃÂ©, nÃÂ£o existe discussÃÂ£o em vocÃÂª pegar um dado sistema que ÃÂ© representado por uma matriz, estudar o comportamento do seu espectro de autovalores e autovetores e verificar que seguem algumas lei de universalidade. **Isso ÃÂ© bem diferente de dizer que se vocÃÂª filtrar uma matriz de correlaÃÂ§ÃÂ£o via RMT vocÃÂª irÃÂ¡ obter sempre resultados melhores.**

## LimitaÃÂ§ÃÂµes
  - Note que nÃÂ£o realizamos nenhum tipo de teste para decidir se realmente a distribuiÃÂ§ÃÂ£o de autovalores era a distribuiÃÂ§ÃÂ£o desejada. Baseamos isso sÃÂ³ no olhometro, obviamente nÃÂ£o ÃÂ© uma boa ideia. 
  - A filtragem apenas removendo os autovalores apesar de simples ÃÂ© limitada e pode ser contra produtiva, outros mÃÂ©todos de filtragem podem ser inclusive melhores[14]. Inclusive nÃÂ£o ÃÂ© uma das ÃÂºnicas aplicaÃÂ§ÃÂµes de RMT para tratamento desse tipo de dado [16]

## Para conhecer mais

### CiÃÂªntistas
- Alguns grandes nomes de RMT: Madan Lal Mehta, Freeman Dyson e Terrence Tao
- Alguns brasileiros: Marcel Novaes autor do livro [Introduction to Random Matrices - Theory and Practice](https://link.springer.com/book/10.1007/978-3-319-70885-0)-[arxiv](https://arxiv.org/abs/1712.07903); Fernando Lucas Metz trabalhou com o Nobel Giorgio Parisi.

### Encontrou um erro ou quer melhorar esse texto?

- FaÃÂ§a sua contribuiÃÂ§ÃÂ£o   criando uma [issue](https://github.com/devmessias/devmessias.github.io/issues/new) ou um PR editando esse arquivo aqui [random_matrix_theory/index.md](https://github.com/devmessias/devmessias.github.io/blob/master/content/post/random_matrix_theory/index.md).


# 6-ReferÃÂªncias

- [1] M. Kac, Ã¢ÂÂCan One Hear the Shape of a Drum?,Ã¢ÂÂ The American Mathematical Monthly, vol. 73, no. 4, p. 1, Apr. 1966, doi: 10.2307/2313748.
- [2] Wigner, E.P., 1957. Statistical properties of real symmetric matrices with many dimensions (pp. 174-184). Princeton University.
- [4] Ã¢ÂÂFrom Prime Numbers to Nuclear Physics and Beyond,Ã¢ÂÂ Institute for Advanced Study. https://www.ias.edu/ideas/2013/primes-random-matrices (accessed Sep. 30, 2020).
- [5] Ã¢ÂÂGUE hypothesis,Ã¢ÂÂ WhatÃ¢ÂÂs new. https://terrytao.wordpress.com/tag/gue-hypothesis/ (accessed Nov. 22, 2021).
- [6] R. Hudson and A. Gregoriou, Ã¢ÂÂCalculating and Comparing Security Returns is Harder than you Think: A Comparison between Logarithmic and Simple Returns,Ã¢ÂÂ Social Science Research Network, Rochester, NY, SSRN Scholarly Paper ID 1549328, Feb. 2010. doi: 10.2139/ssrn.1549328.
- [7] A. Meucci, Ã¢ÂÂQuant Nugget 2: Linear vs. Compounded Returns Ã¢ÂÂ Common Pitfalls in Portfolio Management,Ã¢ÂÂ Social Science Research Network, Rochester, NY, SSRN Scholarly Paper ID 1586656, May 2010. Accessed: Dec. 01, 2021. [Online]. Available: https://papers.ssrn.com/abstract=1586656
- [8] Lidian, Ã¢ÂÂAnalysis on Stocks: Log(1+return) or Simple Return?,Ã¢ÂÂ Medium, Sep. 18, 2020. https://medium.com/@huangchingchiu/analysis-on-stocks-log-1-return-or-simple-return-371c3f60fab2 (accessed Nov. 25, 2021).
- [9] N. A. Eterovic and D. S. Eterovic, Ã¢ÂÂSeparating the Wheat from the Chaff: Understanding Portfolio Returns in an Emerging Market,Ã¢ÂÂ Social Science Research Network, Rochester, NY, SSRN Scholarly Paper ID 2161646, Oct. 2012. doi: 10.2139/ssrn.2161646.
- [10] E. P. Wigner, Ã¢ÂÂCharacteristic Vectors of Bordered Matrices With Infinite Dimensions,Ã¢ÂÂ Annals of Mathematics, vol. 62, no. 3, pp. 548Ã¢ÂÂ564, 1955, doi: 10.2307/1970079.
- [11] E. P. Wigner, Ã¢ÂÂOn the statistical distribution of the widths and spacings of nuclear resonance levels,Ã¢ÂÂ Mathematical Proceedings of the Cambridge Philosophical Society, vol. 47, no. 4, pp. 790Ã¢ÂÂ798, Oct. 1951, doi: 10.1017/S0305004100027237.
- [13] F. W. K. Firk and S. J. Miller, Ã¢ÂÂNuclei, Primes and the Random Matrix Connection,Ã¢ÂÂ Symmetry, vol. 1, no. 1, pp. 64Ã¢ÂÂ105, Sep. 2009, doi: 10.3390/sym1010064.
- [14] L. Sandoval, A. B. Bortoluzzo, and M. K. Venezuela, Ã¢ÂÂNot all that glitters is RMT in the forecasting of risk of portfolios in the Brazilian stock market,Ã¢ÂÂ Physica A: Statistical Mechanics and its Applications, vol. 410, pp. 94Ã¢ÂÂ109, Sep. 2014, doi: 10.1016/j.physa.2014.05.006.
- [15] M. E. A. Seddik, C. Louart, M. Tamaazousti, and R. Couillet, Ã¢ÂÂRandom Matrix Theory Proves that Deep Learning Representations of GAN-data Behave as Gaussian Mixtures,Ã¢ÂÂ arXiv:2001.08370 [cs, stat], Jan. 2020, Accessed: Dec. 05, 2021. [Online]. Available: http://arxiv.org/abs/2001.08370
- [16] D. B. Aires, Ã¢ÂÂAnÃÂ¡lise de crises financeiras brasileiras usando teoria das matrizes aleatÃÂ³rias,Ã¢ÂÂ Universidade Estadual Paulista (Unesp), 2021. Accessed: Dec. 05, 2021. [Online]. Available: https://repositorio.unesp.br/handle/11449/204550

- [17] S. Rome, Ã¢ÂÂEigen-vesting II. Optimize Your Portfolio With Optimization,Ã¢ÂÂ Scott Rome, Mar. 22, 2016. http://srome.github.io//Eigenvesting-II-Optimize-Your-Portfolio-With-Optimization/ (accessed Dec. 05, 2021).
- [18] Ã¢ÂÂ11.1 Portfolio Optimization Ã¢ÂÂ MOSEK Fusion API for Python 9.3.10.Ã¢ÂÂ https://docs.mosek.com/latest/pythonfusion/case-studies-portfolio.html (accessed Dec. 05, 2021).

