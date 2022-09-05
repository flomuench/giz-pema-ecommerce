***********************************************************************
* 			generate do file, second part baseline e-commerce				  
***********************************************************************
*																	  
*	PURPOSE: generate new variables in the questionnaire answers intermediate data								  
*																	  
*	OUTLINE: 	PART 1: Import the data	  
*				PART 2: Generate date	  
*				PART 3: Generate multiple-choice questions
*				PART 4: Generate date difference facebook posts
*				PART 5: Save the data
*                         											  
*																	  
*	Author:  			Ayoub Chamakhi					    
*	ID variable: 		id_platforme  					  
*	Requires:  	  		Webpresence_answers_intermediate.dta									  
*	Creates:  			Webpresence_answers_final.dta
***********************************************************************
* 	PART 1: Import the data
***********************************************************************

use "${bl2_intermediate}/Webpresence_answers_intermediate", clear

***********************************************************************
* 	PART 2: Generate date		  			
***********************************************************************

gen social_last_publication2 = date(social_last_publication, "MDY")
format social_last_publication2 %td

***********************************************************************
* 	PART 3: Generate multiple-choice questions		  			
***********************************************************************
*social media accounts
gen linkedin = regexm(social_others, "linkedin")
gen youtube = regexm(social_others, "youtube")
gen twitter = regexm(social_others, "twitter")
gen instagram = regexm(social_others, "instagram")

*sum of web_contact 
*first make a dummy which forms of web contact it has, then divide by 3 
* and then sum so that company with all three (adress, telephone, email) gets full score

*do the same for social contact

*create facebook age (today - facebook creation/365)


*label it
***********************************************************************
* 	PART 4: Generate date difference facebook posts		  			
***********************************************************************

gen datediff = social_last_publication2 - social_beforelast_publication	

gen posting_rate= 1/datediff
lab var posting_rate "1/days between two last posts"
*label it

***********************************************************************
* 	PART 5: Re-scale multi-level variable to max. of 1		  			
***********************************************************************
* in case you have a variable that has several levels re-scale such that highest level is 1. 
*e.g. if so far you have 0, 1 ,2, 3 re-scale to 0,0.33, 0.66 and 1


***********************************************************************
* 	PART 5: 	Save the data
***********************************************************************

save "${bl2_final}/Webpresence_answers_final", replace


*hbar (Count), over(binary_var1)
