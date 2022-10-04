***********************************************************************
* 			second part midline ecommerce							  *
***********************************************************************
*																	   
*	PURPOSE: import the survey raw file					  								  
*			  
*																	  
*	OUTLINE:														  
*	1)		
*	2) 											  
*	3)	
*	4)	
*																 																      *
*	Author:   														  
*	ID variable: 		id_plateforme  									  
*	Requires:			raw
*	Creates:			intermediate		
		
***********************************************************************
* 	PART 1: import the answers from questionnaire as Excel				  										  *
***********************************************************************

import excel "${ml_raw}/ml_raw", firstrow clear

***********************************************************************
* 	PART 4: save the answers as dta file in intermediate folder 			  						
***********************************************************************

save "${ml_intermediate}/ml_intermediate", replace
