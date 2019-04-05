# R-ShinyPracticeAPP
#Practicing R-Shiny App
This application consist of following tabs
  1. LoginPage
  2. SubmitData
  3. View Result
  4. Extract Data To Analyze

--------LoginPage-------
This tab is connected with PostgresSql loginInfo Table in mydb database. This table consist information of username, password  and role of user.
User would able to login only if they enter correct username and password stored into logininfo table.
If user put incorrect username or password , this application will pop-up a message "Incorrect Credentials"
If user put correct username and password, user directed to SubmitData Tab with a table output having username and role information.

------SubmitData----------
If user role is as 'Submitter' then 
On SubmitData tab, Submitter can browse data that he want to be analized by analyst and then need to click on upload button to make that data store into sampledata table in mydb database. Once Data stored into database , pop-up message will display with text "Data Submitted Successfully"

If user role is as 'Analyst' 
On SubmitData tab, Analyst can browse result that he created after analysis of data submit by submitter and then need to click on upload button to make that result feild updated into sampledata table for the required records. Once Result stored into database , pop-up message will display with text " Result Updated Successfully"

-----View Result----------
If user role is as 'Submitter' then 
On View Result tab, Submitter can put the name of person whose result he want to see and need to select cordinate correspond to which he want analyst result and need to click on result button. Data from table will display on R-Shiny application but only for the data which was submitted by submitter.
If there is no such record available in database then a pop-up message will display with "NO Record available with this data"
Submitter can Download Result by clicking "Download Result" link on application on this tab

If user role is as 'Analyst' then 
On View Result tab, if analyst try to fetch result after clicking result button, pop-up message will appear which says - ONLY SUBMITTER CAR VIEW RESULT FOR DATA SUBMITTED

-----Extract Data To Analyze------
If user role is as 'Submitter' then 
When Submitter click Extract Data button, a pop up message will dispaly that tells "Submitter have no access to fetch this information"

If user role is as 'Analyst' then 
On Extract Data To Analyze tab, user can fetch data from table which need to be analyzed or for the record whose result is still not updated.
Analyst can Download Data by clicking "Download Data to be Analyzed " link on application on this tab

