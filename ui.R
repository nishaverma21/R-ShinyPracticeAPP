#This R package contain only UI Code 

#install Shiny Package from tools
#install.packages("shiny")
#The downloaded source packages are in
#install.packages("shinyjs")
#‘/tmp/Rtmp0uo3Nl/downloaded_packages’
#install.packages("shinythemes")
#install.packages("RPostgreSQL")


# cleaning R memory
rm(list=ls())
# calling required libraries
library(shiny)
library(shinyjs)
#library(shinythemes) #- This can be used for attractive application

#ui code
ui <- fluidPage(#theme = shinytheme("superhero"),
  # useShinyjs for any custommessage need into application
  useShinyjs(),
  tags$head(tags$script(HTML('Shiny.addCustomMessageHandler("jsCode",function(message) {eval(message.value);});'))),
  # All Tabs of application
  tabsetPanel(id ="Pages",
              #TAB ONE - LOGINPAGE
              tabPanel(title = "LoginPage",       
                       titlePanel("Welcome to Data Analysis Tool of Health Desease"),
                       hr(),
                       mainPanel(div(width = "10px",
                                     wellPanel(
                                       textInput(inputId = "userName",label ="Username",width = "400px"),
                                       passwordInput(inputId = "passwd",label="Password",width = "400px"),
                                       br(),
                                       actionButton(inputId = "login",label="LOGIN",width = "70px",style="display:right-align")))))
              ,hr(),
              
              #TAB TWO - SUBMITDATA PAGE
              tabPanel(title = "SubmitData",
                       titlePanel("Submit Data or Result to Determine Risk of Healh Desease"),
                       hr(),
                       div(
                         sidebarLayout(
                           mainPanel(div(fluidRow(DT::dataTableOutput("table")),style = "width: 75%"),tableOutput('contents')),
                           position = "right",
                           sidebarPanel(div(width = "100px",
                                            fileInput('file1', 'Choose CSV File',width = "300px",
                                                      accept=c('text/csv', 'text/comma-separated-values,text/plain', '.csv')),
                                            actionButton(inputId = "Submit",label="Submit")
                           ))))),
              
              #TAB THREE - View Result
              tabPanel(title = "View Result",
                       titlePanel("Check the result updated by analyst correspond to different heart attributes"),
                       sidebarLayout(
                         mainPanel(div(DT::dataTableOutput("table1"),style = "width: 75%")),
                         sidebarPanel (
                           textInput(inputId = "name",label ="Name",width = "200px"),
                           uiOutput("SelectX"),
                           br(),
                           actionButton(inputId = "Analyze",label="Analyze Result",width = "200px",style="display:right-align"),
                           br(),br(),
                           downloadLink('downloadResult', 'Download Result')
                         ))),
              
              #TAB FOUR - Extract Data To Analyze
              tabPanel(title = "Extract Data To Analyze",
                       titlePanel("Analyst will extract data to be analyzed"),
                       sidebarLayout(
                         mainPanel(div(DT::dataTableOutput("table2"),style = "width: 75%")),
                         sidebarPanel (
                           actionButton(inputId = "Extract",label="Extract Data",width = "200px",style="display:right-align"),
                           br(),
                           downloadLink('downloadData', 'Download Data to be analyzed')
                         )))
  ))







