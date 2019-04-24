#This R Script contain only server Code 


# calling required libraries
library(shiny)
library(RPostgreSQL)
library(DT)

# making connection with postgresSQL to a defined database
con <- DBI::dbConnect(
  drv = dbDriver("PostgreSQL", max.con = 100),
  dbname = "mydb",
  host = "localhost",
  user = "V-Arora",
  password = "mypass"
)

# server code for application
server <- function(input, output, session) {
  
  ####################################### APP Pre-Requists ####################################
  
  # fetching usename entered by user
  user<- reactive({
    username <-input$userName
  })
  
  # fetching password entered by user
  paswd<- reactive({
    password <-input$passwd
  })
  
  
  # fetching count of records available into db with username, password and role entered by user
  # this will be used in further code to allow different access to different roles Analyst/Submitter
  AnalystRole<-reactive({
    outp <- dbGetQuery(con, sqlInterpolate(ANSI(), ("SELECT count(*) from logininfo where username = 
                                                    ?username and password = ?password and role = ?role ; "), 
                                           username = user(),password = paswd(),role = 'Analyst'))
  })
  
  ####################################### LOGINPAGE Pre-Requists ####################################
  
  # fetching count of records available into db with username and password entered by user
  # this will be used in further code to pop up messages if correct username and password is entered or not
  queryout<-reactive({
    outp <- dbGetQuery(con, sqlInterpolate(ANSI(), ("SELECT count(*) from logininfo where username = 
                                                    ?username and password = ?password ; "), 
                                           username = user(),password = paswd()))
  })
  
  ####################################### LOGINPAGE FUNCTIONALITY ####################################
  
  # What will happen when user clicks Login Button on login page
  observeEvent(input$login ,{
    x<-queryout()
    js_string <- 'alert("Incorrect Credentials");'
    if (x == 0 ) {
      session$sendCustomMessage(type='jsCode', list(value = js_string))
    }else
      updateTabsetPanel(session = session, inputId = "Pages",selected = "SubmitData")
  })
  
  ######################## SUBMITDATA PAGE Pre-Requists #######################################  
  
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
  ######################## SUBMITDATA PAGE FUNCTIONALITY#######################################  
  # Table displayed on Tab with Role and username information
  output$table <- DT::renderDataTable({
    sql <- ("SELECT Username,Role from logininfo where username = ?username and password = ?password ; ")
    query<- sqlInterpolate(ANSI(), sql, username = user(),password = paswd())
    outp <- dbGetQuery(con, query)
    ret <- DT::datatable(outp)
    return(ret)
  }) 
  # What will happen when Submit button clicks 
  observeEvent(input$Submit,{
    sampledata <- read.csv(input$file1$datapath)
    submitter<-user()
    role <- AnalystRole()
    if (role ==0){
      for(i in 1:nrow(sampledata)){
        data = sampledata[i,]
        sql<- "Insert into sampledata (name,sampleid,analyte,analyteid,result,submitter) values (?name,?sampleid,?analyte,?analyteid,?result,?submitter);"
        query<- sqlInterpolate(ANSI(), sql,name = as.character(data$name),sampleid = as.character(data$sampleid),analyte = as.character(data$analyte),analyteid = "" ,result = "",submitter = as.character(submitter))
        outp <- dbSendQuery(con, query)
      }
      js_string <- 'alert("Data Uploaded Successfully");'
      session$sendCustomMessage(type='jsCode', list(value =  js_string))
    }
    else{
      if (any(names(sampledata) == 'result')){
        for(i in 1:nrow(sampledata)){
          data = sampledata[i,]
          sql<- "Update sampledata set result = ?result,analyteid = ?analyteid where sampleid = ?sampleid;"
          query<- sqlInterpolate(ANSI(), sql,result = as.character(data$result),analyteid=as.character(data$analyteid),sampleid = as.character(data$sampleid))
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
  
  
  ######################## VIEW RESULT PAGE Pre-Requists #######################################  
  
  AnalystResult <- reactive({
    outp1 <- dbGetQuery(con, sqlInterpolate(ANSI(), 
                                            "Select * from sampledata1 where upper(name) = ?dataname and 
                                            analyte = ?analyte and result <>'' and submitter = ?submitter ;",
                                            dataname = toupper(input$name) ,analyte  =input$x, submitter = user() ))
  })
  
  NoData <-reactive({
    outp <- dbGetQuery(con, sqlInterpolate(ANSI(), ("Select count(*) from sampledata where upper(name) = ?dataname and analyte 
                                                    = ?analyte and result <>'' and submitter = ?submitter ;"), 
                                           dataname = toupper(input$name) ,analyte  =input$x, submitter = user()))
  })
  ######################## VIEW RESULT PAGE FUNCTIONALITY#######################################  
  
  # code to allow user to select different heart desease cordinates
  output$SelectX<-renderUI({
    selectInput('x', 'Select Analyte', choices = c("cp","trestbps","chol","fbs","restecg","thalach","exang","oldpeak","slope","ca","thal","age","sex"),selected = "chol")
  })
  
  # what will happen when Analyze Result button clicks
  observeEvent(input$Analyze,{
    role <- AnalystRole()
    if (role == 0 & NoData()==0){
      js_string <- 'alert("NO Record available with this data");'
      session$sendCustomMessage(type='jsCode', list(value =  js_string))
    }
    else if (role==0){
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
  
  # code for Download Result
  output$downloadResult <- downloadHandler(
    
    filename = function() {
      paste('Analyst_Result', sep = ",")
    },
    content = function(file) {
      write.csv(AnalystResult(), file)
    }
  )
  ######################## EXTRACT DATA To ANALYZE Pre-Requists #######################################  
  datatoAnalyze <- reactive( {
    outp2 <- dbGetQuery(con, sqlInterpolate(ANSI(), "Select * from sampledata where result ='' ;" ))
  })
  
  ######################## EXTRACT DATA To ANALYZE #######################################  
  
  # what will happen when Extract Data button clicks
  observeEvent(input$Extract ,{
    output$table2<- (DT::renderDataTable({
      role <- AnalystRole()
      if (role ==0){
        js_string <- 'alert("Submitter have no access to fetch this information");'
        session$sendCustomMessage(type='jsCode', list(value =  js_string))
      } else{ 
        sql2<- "Select * from sampledata where result ='' ;"
        query2<- sqlInterpolate(ANSI(), sql2 )
        outp2 <- dbGetQuery(con, query2)
        ret <- DT::datatable(outp2)
        return(ret)
      }
    }))
  })
  
  # code for Download Data to Analyze 
  output$downloadData <- downloadHandler(
    
    filename = function() {
      paste('Data_To_Analyze')
    },
    content = function(file) {
      write.csv(datatoAnalyze(), file)
    }
  )
}
