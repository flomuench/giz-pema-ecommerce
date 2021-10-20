***********************************************************************
* 			sampling email experiment stratification								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)		visualisation of candidate strata variables														  
*	2)		gen stratification dummy
*	3)		visualise number of observations per strata														  
*	4)
*   5) 
*
*																 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_inter.dta
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART START: define the settings as necessary 				  										  *
***********************************************************************
use "${samp_intermediate}/giz_contact_list_inter", clear

***********************************************************************
* 	PART 1: create dummy variables for each category of factor variables				  										  
***********************************************************************

***********************************************************************
* 	PART 2: gen stratification dummy				  										  
***********************************************************************

***********************************************************************
* 	PART 3: visualise number of observations per strata				  										  
***********************************************************************#
* how many strata? Depending on number of strata, decide on visualisation
* graph bar (sum), over(strata)




***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
save "giz_contact_list_inter", replace
