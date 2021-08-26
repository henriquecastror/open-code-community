---

title: "Shiny e banco de dados MySQL: Uma combinação perfeita."

categories: []

date: '2021-06-26T00:00:00Z' 

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
- Shiny
- MySQL
- Desenvolvimento web

# DIGITE NA LISTA ABAIXO O NOME DE TODOS OS AUTORES SEM ESPACOS
authors:
- WendelMarquesGoncalves


---

Primeiramente é preciso deixar seu banco de dados remoto. É possível criar uma conta e hospedar gratuitamente por aqui: https://www.freemysqlhosting.net/.

{{< figure src="File_1.png" width="100%" >}}

Esse é o host, o nome da base, nome do usário e a senha, que chega por e-mail.

Vamos conectar nossa base remota através do R.

Para isso, usamos o pacote keyring para proteger nossa credencial mais importante que é a senha.

    library(keyring)
    library(RMySQL)
    library(shiny)
    
    keyring::key_set(service = "my-database", 
                     username = "myusername")
                     
Conectamos com a base remota.

    conn <- RMySQL::dbConnect(RMySQL::MySQL(),
                      user = "sql4421522",
                      host = "sql4.freemysqlhosting.net",
                      password = keyring::key_get("my-database","myusername"),
                      port = 3306)
                      
Vamos adicionar a famosa base de dados mtcars, built in do R, na nossa base remota.

    RMySQL::dbSendQuery(conn, "USE sql4421522;")
    
    RMySQL::dbWriteTable(conn, "mtcars", mtcars, overwrite = TRUE)
    
    res <- RMySQL::dbSendQuery(conn, "SELECT * FROM mtcars;")
    
    data <- RMySQL::dbFetch(res, n = 2)
    
    head(data)


Com o  nosso banco de dados criado, vamos agora criar o Shiny app.
O app vai criar uma  conexão com a base remota e printar os dados na tela.
Quem quiser aprender mais sobre Shiny, sugiro o livro: https://mastering-shiny.org/. 
O app vai ser mantido localmente, mas é possível fazer o deploy facilmente pelo shinyappios:https://shiny.rstudio.com/articles/shinyapps.html. Ou por outros serviços de hospedagem como, Amazon AWS, Heroku, Google Clound etc.

    ui <- shiny::fluidPage(
      
      tableOutput("table")
    )
    
    server <- function(input, output, session) {
      
      conn <- RMySQL::dbConnect(RMySQL::MySQL(),
                                user = "sql4421522",
                                host = "sql4.freemysqlhosting.net",
                                password = keyring::key_get("my-database",
                                "myusername"),
                                port = 3306)
      
      RMySQL::dbSendQuery(conn, "USE sql4421522;")
      
      res <- RMySQL::dbSendQuery(conn, "SELECT * FROM mtcars;")
      
      data <- RMySQL::dbFetch(res)
      
      RMySQL::dbDisconnect(conn)
      
      output$table <- shiny::renderTable(data) 
      
    }
    
    shiny::shinyApp(ui, server)
    
Vamos inserir um novo dado na base e dá f5 no app para ver a mudança.

    query_inserir <- paste0("INSERT INTO mtcars(",
                           paste0(colnames(data), collapse = ","),
                           ")values('Fusca',1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1);")
                           
    RMySQL::dbSendQuery(conn, query_insert)
    
    RMySQL::dbDisconnect(conn)
                           
                           
Bom, dando F5 no app, é possível ver que foi inserido uma nova linha com as informações do Fusca.

Essa é a magia, conectar seu app em um banco de dados remoto, fazer alterações e o app atualizar instantaneamente sem precisar fazer um novo deploy.




{{% callout note %}}

**Please, cite this work:**

Marques, Wendel (2021), "Shiny e banco de dados MySQL: Uma combinação perfeita published at the "Open Code Community"", Mendeley Data, V1, doi: 10.17632/shktskbhgy.1

{{% /callout %}}
           

