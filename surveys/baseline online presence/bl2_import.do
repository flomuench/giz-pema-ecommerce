***********************************************************************
* 			second part baseline (google forms) import						
***********************************************************************
*																	   
*	PURPOSE: import the questionnaire Presence en ligne					  								  
*			  
*																	  
*	OUTLINE:														  
*	1)	import the questionnaire as Excel or CSV														  
*	2)	save the answers as dta file in intermediate folder
*																	 																      *
*	Author:   														  
*	ID variable: 		  									  
*	Requires:	
*	Creates:							  
*																	  
***********************************************************************
* 	PART 1: import the answers from questionnaire as Excel				  										  *
***********************************************************************
cd "$bl2_raw"
import excel "${regis_raw}/Webpresence answers.xlsx", firstrow clear


***********************************************************************
* 	PART 2: save list of registered firms in registration raw 			  						
***********************************************************************
save "Webpresence_answers_raw", replace
