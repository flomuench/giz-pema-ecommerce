***********************************************************************
* 			email experiment - correct, generate								  		  
***********************************************************************
*																	   
*	PURPOSE: correct variables (e.g. gender based on firm ceo), create					  								  
*	new variables
*																	  
*	OUTLINE:														  
*	1)	create dependant variable													  
*	2)	 
*	3)	 
*	4) 	 
*																 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_final.dta & regis_corrected_matches 
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data + save it in samp_final folder				  										  *
***********************************************************************
use "${samp_final}/email_experiment", clear

	* create dependent variable
gen registered = .
replace registered = 1 if sample == 1
replace registered = 0 if sample == 2
