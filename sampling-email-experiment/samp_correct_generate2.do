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


***********************************************************************
* 	PART 2: improve gender assignment based on baseline data
***********************************************************************

	* generate a gender_rep variable corrected also for baseline pdg
gen gender_rep2 = .
replace gender_rep2 = car_sex_pdg
replace gender_rep2 = rg_gender_pdg if gender_rep2 == .
replace gender_rep2 = gender if gender_rep2 == .

lab val gender_rep2 sex
lab var gender_rep2 "ceo gender based on baseline, registration or API data"

***********************************************************************
* 	PART end: save in samp folder
***********************************************************************
	* change folder 
cd "$samp_final"
save "email_experiment", replace
