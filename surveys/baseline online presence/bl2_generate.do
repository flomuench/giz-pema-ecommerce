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

gen linkedin = regexm(social_others, "linkedin")
*label it
***********************************************************************
* 	PART 4: Generate date difference facebook posts		  			
***********************************************************************

gen datediff = social_last_publication2 - social_beforelast_publication	
*label it
***********************************************************************
* 	PART 5: 	Save the data
***********************************************************************

save "${bl2_final}/Webpresence_answers_final", replace


*hbar (Count), over(binary_var1)
