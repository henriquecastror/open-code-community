 ---

title: "Estimadores da Volatilidade"

categories: []

date: '2021-05-28T00:00:00Z'

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
- Volatilidade
- Open Code

authors:
- BernadoMendes


---
## Estimadores da Volatilidade
Para medir a volatilidade hist�rica, � comum calcular o desvio padr�o dos retornos di�rios. No entanto, essa � uma medida que desconsidera as din�micas intraday. Imagine, por exemplo, uma a��o que tenha fechamento do dia atual igual ao fechamento do dia anterior, mas que durante o dia oscilou 5%. Nessa situa��o, o indicador close-to-close n�o medir� a volatilidade com efici�ncia. Dessa forma, surgiram v�rios estimadores, cada um com seus pontos fortes e fracos, que auxiliam no c�lculo da verdadeira volatilidade hist�rica.
Alguns desses estimadores s�o:
Close-to-Close (C): � a medida de volatilidade hist�rica mais comum, utiliza apenas dados de fechamento.
Parkinson (HL) O primeiro estimador de volatilidade mais avan�ado surgiu em 1980, criado por Parkinson. Em vez de usar os pre�os de fechamento, utiliza as m�ximas e m�nimas. Um ponto fraco do estimador � a premissa de mercados cont�nuos, o que leva a subestimar a volatilidade, pois movimentos como Gaps entre dias diferentes s�o ignorados.
Garman-Klass (OHLC): Esse estimador � uma extens�o de Parkinson, adicionando os pre�os de abertura e fechamento em seus c�lculos. Como Gaps entre os dias s�o ignorados, tamb�m subestima a volatilidade.
Garman-Klass-Yang-Zhang (OHLC): � uma extens�o do estimador anterior, pois considera os saltos entre a abertura de um dia em rela��o ao fechamento do dia anterior.
Rogers-Satchell (OHLC): O estimador de Rogers-Satchell foi criado no in�cio da d�cada de 90. � capaz de medir adequadamente a volatilidade com drift diferente de zero. No entanto, ainda n�o lida com saltos, subestimando a volatilidade.
Yang-Zhang (OHLC): Em 2000, Yang-Zhang criaram o estimador mais poderoso, que lida tanto com Gaps de abertura quanto com drift diferente de zero. Seu c�lculo envolve a soma da volatilidade do fechamento at� a abertura do dia seguinte com a m�dia ponderada do estimador de Rogers-Satchell e da volatilidade da abertura at� o fechamento de um mesmo dia.
Nesse estudo, calculei a volatilidade em janelas m�veis de 30 dias para o ibovespa desde junho/2014 at� abril/2021.
Importa��o do pacote do Yahoo e selecionando o c�digo do Ibovespa:

    from yahooquery import Ticker
    ibov = Ticker("^bvsp")

Fazendo o upload das f�rmulas dos estimadores:

    from google.colab import files
    uploaded = files.upload()


Saving estimadoresvol.jpg to estimadoresvol.jpg

C�digo para mostrar a imagem:

    import cv2
    from google.colab.patches import cv2_imshow
    
    img = cv2.imread('estimadoresvol.jpg')
    cv2_imshow(img)
    cv2.waitKey()



{{< figure library="true" src="1.png" width="100%" >}}

Na Imagem, F � igual � frequ�ncia de retornos em um ano (252 para retornos di�rios, por exemplo).
{{< figure library="true" src="2.png" width="100%" >}}


C - Dados de Fechamento
H - Dados de M�xima
L - Dados de M�nima
O - Dados de Abertura
Efici�ncia: Compara a vari�ncia de um estimador em rela��o � vari�ncia do estimador Close-to-Close.
Mais detalhes podem ser encontrados no material: https://dynamiproject.files.wordpress.com/2016/01/measuring_historic_volatility.pdf
Importando as cota��es do Ibovespa de 01/06/2014 at� 01/05/2021, com periodicidade di�ria. Observe que os dados s�o colocados em um dataframe.

    df=ibov.history(start="2014-06-01",end="2021-05-01",interval='1d') type(df)

pandas.core.frame.DataFrame
N�mero de linhas e colunas:

    		df.shape
    		(1707, 6)

Verificando se h� valores nulos:

    		df.isnull().sum()
    low         0
    open        0
    high        0
    close       0
    volume      0
    adjclose    0
    dtype: int64


    		df.dropna(inplace=True)

Primeiras linhas do DataFrame:
		
    		df.head()

{{< figure library="true" src="2.png" width="100%" >}}
Selecionando apenas as colunas de interesse (open,low,high,close), que correspondem aos dados de abertura, m�nima, m�xima e fechamento, respectivamente.
		
    		df=df[["open","low","high","close"]]

         df

{{< figure library="true" src="4.png" width="100%" >}}

Nas fun��es abaixo, "df" � o dataframe com dados de abertura, m�nima, m�xima e fechamento e "n" � a janela m�vel usada para o c�lculo da volatilidade. O termo "np.sqrt(252)*100" anualiza os resultados.
df["close"] � a coluna do Dataframe com os dados de fechamento di�rio.
df['high'] � a coluna do Dataframe com os dados de m�xima di�ria.
df['low'] � a coluna do Dataframe com os dados de m�nima di�ria.
df['open'] � a coluna do Dataframe com os dados de abertura di�ria.

    def close_to_close(df,n):
      df["C/C(-1)-1"]=df['close']/df['close'].shift(1)-1
      df["Close-to-Close"]=df["C/C(-1)-1"].rolling(n).std()*np.sqrt(252)*100
      return df["Close-to-Close"]
    
    
    def Garman_Klass(df,n):
      df["log^2(H/L)"]=(np.log(df['high']/df['low']))**2
      df["log^2(C/O)"]=(np.log(df['close']/df['open']))**2
      df["GK"]=0.5*df["log^2(H/L)"]-(2*np.log(2)-1)*df["log^2(C/O)"]
      df["Garman-Klass"]=((df["GK"].rolling(n).mean())**0.5)*np.sqrt(252)*100
      return df["Garman-Klass"]
    
    def Parkinson(df,n):
      df["log^2(H/L)"]=(np.log(df['high']/df['low']))**2
      df["Parkinson"]=np.sqrt(df["log^2(H/L)"].rolling(n).mean()/4*np.log(2))*np.sqrt(252)*100
      return df["Parkinson"]
    
    def Yang_And_Zang(df,n):
      df["o"]=np.log(df["open"]/df['close'].shift(1))
      df["u"]=np.log(df["high"]/df["open"])
      df["d"]=np.log(df["low"]/df["open"])
      df["c"]=np.log(df["close"]/df["open"])
      df["RS"]=np.log(df["high"]/df["close"])*np.log(df["high"]/df["open"])+np.log(df["low"]/df["close"])*np.log(df["low"]/df["open"])
      k=0.34/(1.34+(n+1)/(n-1))
      df["Yang And Zang"]=(((df["o"].rolling(20).std())**2+k*(df["c"].rolling(n).std())**2+(1-k)*df["RS"].rolling(n).mean())**0.5)*np.sqrt(252)*100
      return df["Yang And Zang"]
    
    def GKYZ(df,n):
      df["o"]=np.log(df["open"]/df["close"].shift(1))
      df["c"]=np.log(df["close"]/df["open"])
      df["log^2(H/L)"]=(np.log(df['high']/df['low']))**2
      df["GKYZ"]=np.sqrt(((df["o"]**2)+0.5*df["log^2(H/L)"]-(2*np.log(2)-1)*(df["c"]**2)).rolling(n).mean())*np.sqrt(252)*100
      return df["GKYZ"]

Concatenando o resultado das fun��es, todas com n=30 dias, em um DataFrame e retornando o valor da �ltima linha

df1=pd.concat([close_to_close(df,30),Parkinson(df,30),Garman_Klass(df,30),Rogers_Satchell(df,30),GKYZ(df,30),Yang_And_Zang(df,30)],axis=1)

df1[-1:]

{{< figure library="true" src="6.png" width="100%" >}}


    df1.dropna(inplace=True)

		df1

{{< figure library="true" src="7.png" width="100%" >}}


Plotando os estimadores separadamente para o per�odo selecionado:

df1.plot(subplots=True, figsize=(20,12)); plt.legend(loc='best')

{{< figure library="true" src="8.png" width="100%" >}}

Plotando os estimadores em um mesmo gr�fico para o per�odo selecionado:
		df1.plot(subplots=False, figsize=(20,8)); plt.legend(loc='best')

