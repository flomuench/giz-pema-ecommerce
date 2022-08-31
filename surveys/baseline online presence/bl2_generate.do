***********************************************************************
* 			generate do file, second part baseline e-commerce				  
***********************************************************************
*																	  
*	PURPOSE: generate new variables in the questionnaire answers intermediate data								  
*																	  
*	OUTLINE: 	PART 1: Import the data	  
*				PART 2: 		  
*				PART 3: 
*				PART 4: Save the data
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
*	PART 2: 
***********************************************************************



***********************************************************************
*	PART 4: Save the data
***********************************************************************

save "${bl2_intermediate}/Webpresence_answers_inter", replace
