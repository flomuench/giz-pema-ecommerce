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
*	ID variable: 		  					  
*	Requires:  	  		Webpresence_answers_intermediate.dta									  
*	Creates:  			Webpresence_answers_intermediate.dta
***********************************************************************
* 	PART 1: Import the data
***********************************************************************

use "${bl2_intermediate}/Webpresence_answers_intermediate", clear


***********************************************************************
* 	PART 2: Generate date		  			
***********************************************************************

gen date1 = date(social_last_publication, "MDY")
format date1 %td

***********************************************************************
* 	PART 3: Generate multiple-choice questions		  			
***********************************************************************

gen linkedin = regexm(social_others, "linkedin")
***********************************************************************
* 	PART 4: Generate date difference facebook posts		  			
***********************************************************************

gen datediff = date1 - social_beforelast_publication
***********************************************************************
* 	PART 5: 	Save the data
***********************************************************************

save "${bl2_intermediate}/Webpresence_answers_intermediate", replace
