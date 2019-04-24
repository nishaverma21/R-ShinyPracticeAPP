# R-ShinyPracticeAPP
#Practicing R-Shiny App
This application consist of following tabs
  1. LoginPage
  2. SubmitData
  3. View Result
  4. Extract Data To Analyze

--------LoginPage-------
1.	User need to enter Username and Password and then click Login Button.

2.	If user didn’t enter correct username or password , message will popup with information as “Incorrect Credentials”.

3.	If user enter correct username and password, user will direct to SubmitData tab.


LoginPage is referring username and password information from mydb database of PostgreSQL.
     
------SubmitData----------
1.	After Login successfully, this tab will display role of User.

2.	If user is “Submitter” then user can upload data that he want to be analyzed by analyst by clicking on browsing	button on this tab and user need to click submit button after browsing file to upload file to database.

  Once Submitter click ”Submit” button, data will upload to mydb database into ”sampledata” table. Message will 	pop	up “Data Uploaded Successfully”.

4.	If user is “Analyst” then user can upload result that he analyzed by clicking on browsing	button on this tab and         	user need to click submit button after browsing file to upload result to database.

5.	Once Analyst click ”Submit” button, data will upload to mydb database into ”sampledata” table. Message will 	pop	up “Result Uploaded Successfully”.

If Analyst try to upload file without result field, message will pop up “You only have access to upload result, 	kindly upload file with result field”

Additional information :

Whatever data user trying to upload will also display on this tab in main panel.
Submitter can upload csv format file with headers as “name , sampleid, analyte”.
Analyst can upload csv format file with headers as “name , sampleid, analyte, result”.


-----View Result----------
1.	If user is “Submitter” then user can enter name for which he want to find result and need to select analyte from 	dropdown to let system know for which analyte user want results and need to click “Analyze Result” button.

2.	On clicking “Analyze Result” button, result will display on this tab if such information is available in our database. 	Only data submitted by submitter will popup.

3.	If Submitter trying to fetch result of name which is not available in our database then a message will popup with 	information as “NO Record available with this data”.

4.	Entering name to fetch result is not case sensitive.

5.	Submitter can click on “Download Result” link to download result in csv format.

6.	If user is “Analyst” then on clicking “Analyze Result” button a message will popup with information as “ONLY 	SUBMITTER CAN VIEW RESULT FOR DATA SUBMIITED”.


-----Extract Data To Analyze------
1.	If  user is “Analyst” then on clicking “Extract Data” button ,if there is any record without result updated into 	database then that data will popup on this tab.

2.	Analyst can download data to analyze by clicking link “Download Data to be analyzed” on this tab.

3.	If  user is “Submitter” then on clicking “Extract Data” button a message will popup with information as 	“Submitter have no access to fetch this information”.

