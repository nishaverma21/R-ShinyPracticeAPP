#This R Script contain only server Code 
#install.packages("odbc")
#install.packages("devtools")
#install.packages("RPostgreSQL")
#install.packages("dplyr")
#install.packages("caTools")
#install.packages('mime')

library(shiny)
library(RPostgreSQL)
library(DT)
library(ggplot2)

con <- DBI::dbConnect(
  drv = dbDriver("PostgreSQL", max.con = 100),
  dbname = "mydb",
  host = "localhost",
  user = "V-Arora",
  password = "mypass"
)

server <- function(input, output, session) {

  user<- reactive({
    username <-input$userName
  })
  paswd<- reactive({
    password <-input$passwd
  })
  queryout<-reactive({
    outp <- dbGetQuery(con, sqlInterpolate(ANSI(), ("SELECT count(*) from logininfo where username = 
                                                     ?username and password = ?password ; "), 
                                                      username = user(),password = paswd()))
  })
  
  AnalystRole<-reactive({
    outp <- dbGetQuery(con, sqlInterpolate(ANSI(), ("SELECT count(*) from logininfo where username = 
                                                    ?username and password = ?password and role = ?role ; "), 
                                           username = user(),password = paswd(),role = 'Analyst'))
  })
  observeEvent(input$login ,{
    x<-queryout()
    print(x)
    js_string <- 'alert("Incorrect Credentials");'
    if (x == 0 ) {
      session$sendCustomMessage(type='jsCode', list(value = js_string))
    }else
      updateTabsetPanel(session = session, inputId = "Pages",selected = "SubmitData")
  })
########################SUBMIT DATA PAGE FUNCTIONALITY#######################################  
 output$table <- DT::renderDataTable({
    sql <- ("SELECT Username,Role from logininfo where username = ?username and password = ?password ; ")
    query<- sqlInterpolate(ANSI(), sql, username = user(),password = paswd())
    outp <- dbGetQuery(con, query)
    ret <- DT::datatable(outp)
    return(ret)
  })  

  output$contents <- renderTable({
    req(input$file1)
    uploadDataframe <- read.csv(input$file1$datapath)
  })
  
  uploadDataframe <- reactive({
    uploadDataframe <- read.csv(input$file1$datapath)
  })
  
  output$datatable <- renderTable({
    uploadDataframe()
  })
  
  observeEvent(input$Submit,{
    sampledata <- read.csv(input$file1$datapath)
    submitter<-user()
    role <- AnalystRole()
    if (role ==0){
    for(i in 1:nrow(sampledata)){
      data = sampledata[i,]
      sql<- "Insert into sampledata (name,sampleid,analyte,result,submitter) values (?name,?sampleid,?analyte,?result,?submitter);"
      query<- sqlInterpolate(ANSI(), sql,name = as.character(data$name),sampleid = as.character(data$sampleid),analyte = as.character(data$analyte),result = "",submitter = as.character(submitter))
      outp <- dbSendQuery(con, query)
    }
      js_string <- 'alert("Data Submitted Successfully");'
      session$sendCustomMessage(type='jsCode', list(value =  js_string))
    }
    else{
      if (any(names(sampledata) == 'result')){
      for(i in 1:nrow(sampledata)){
        data = sampledata[i,]
        sql<- "Update sampledata set result = ?result where sampleid = ?sampleid;"
        query<- sqlInterpolate(ANSI(), sql,result = as.character(data$result),sampleid = as.character(data$sampleid))
        outp <- dbSendQuery(con, query) 
      }
      js_string <- 'alert("Result Updated Successfully");'
      session$sendCustomMessage(type='jsCode', list(value =  js_string))
      
      } 
      else{
        js_string <- 'alert("You only have access to upload result,kindly upload file with result field");'
        session$sendCustomMessage(type='jsCode', list(value =  js_string))
        
      }
        
      
    }
})


########################RESULT PAGE FUNCTIONALITY#######################################  
  
  output$SelectX<-renderUI({
    selectInput('x', 'Select Coordinate X', choices = c("cp","trestbps","chol","fbs","restecg","thalach","exang","oldpeak","slope","ca","thal","age","sex"),selected = "chol")
  })
  
  observeEvent(input$Analyze,{
    role <- AnalystRole()
    if (role==0){
    output$table1<- DT::renderDataTable({
      submitter<-user()
      sql1<- "Select * from sampledata where upper(name) = ?dataname and analyte = ?analyte and result <>'' and submitter = ?submitter ;"
      query1<- sqlInterpolate(ANSI(), sql1, dataname = toupper(input$name) ,analyte  =input$x, submitter = submitter )
      outp1 <- dbGetQuery(con, query1)
      ret <- DT::datatable(outp1)
      return(ret)
    })
    }
    else{
      js_string <- 'alert("ONLY SUBMITTER CAN VIEW RESULT FOR DATA SUBMIITED");'
      session$sendCustomMessage(type='jsCode', list(value =  js_string))
    }
  })
  
  observeEvent(input$Extract ,{
    output$table2<- (DT::renderDataTable({
      sql2<- "Select * from sampledata where result ='' ;"
      query2<- sqlInterpolate(ANSI(), sql2 )
      outp2 <- dbGetQuery(con, query2)
      ret <- DT::datatable(outp2)
      return(ret)
    }))
  })
  
  
  datatoAnalyze <- reactive( {
    outp2 <- dbGetQuery(con, sqlInterpolate(ANSI(), "Select * from sampledata where result ='' ;" ))
  })
  
  output$downloadData <- downloadHandler(
    
    filename = function() {
      paste('Data_To_Analyze')
    },
    content = function(file) {
      write.csv(datatoAnalyze(), file)
    }
  )
  
  
  AnalystResult <- reactive({
     outp1 <- dbGetQuery(con, sqlInterpolate(ANSI(), 
            "Select * from sampledata where upper(name) = ?dataname and 
            analyte = ?analyte and result <>'' and submitter = ?submitter ;",
            dataname = toupper(input$name) ,analyte  =input$x, submitter = user() ))
})
  
  output$downloadResult <- downloadHandler(
    
    filename = function() {
      paste('Analyst_Result', sep = ",")
    },
    content = function(file) {
      write.csv(AnalystResult(), file)
    }
  )
}
