***********************************************************************
* 			email experiment - merge population with registered firms								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)	 import corrected matches and save as dta in sampling folder													  
*	2)	 merge with initial population based on id_email
*	3)	 merge with registration data to get controls for registered firms
*	4) 	 save as email_experiment.dta in final folder
*																 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_final.dta & regis_corrected_matches 
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data + save it in samp_final folder				  										  *
***********************************************************************
cd "$samp_final"

	* import the data
import excel "${regis_intermediate}/regis_corrected_matches.xlsx", firstrow clear


	* save as dta in samp_final folder
save "regis_corrected_matches", replace

	* make sur id_email & id_plateforme are unique identifiers
	
		* check for duplicates in terms of id_email 
duplicates report id_email
		* drop all duplicates
duplicates drop id_email, force

		* check for duplicates in terms of id_plateforme
duplicates report id_plateforme
		* drop duplicates in terms of id_plateforme
duplicates drop id_plateforme, force

	* rename 
rename treatment treat
lab var treat "treatment indicator as in regis_corrected_matches"

***********************************************************************
* 	PART 1: merge matches with initial population (giz_contact_list_final) based on id_email				  										  *
***********************************************************************
merge 1:1 id_email using "giz_contact_list_final"

	* generate a dummy to indicate
gen sample = .
replace sample = 1 if _merge == 3
replace sample = 2 if _merge == 2

	* drop merge variable & rg_expstatus (due to solve format mismatch for matching)
drop _merge rg_expstatus

	* save as email_experiment.dta in sampling final folder
save "email_experiment", replace

***********************************************************************
* 	PART 2: merge with registration data to get controls for registered firms				  										  *
***********************************************************************
use "${regis_intermediate}/regis_inter", clear

merge m:m id_plateforme using "email_experiment"
	
	* define categories for company origin
replace sample = 3 if _merge == 1
lab def subsample 1 "matched & registered" 2 "contacted & not registered" 3 "registered & contacted"
lab values sample subsample


***********************************************************************
* 	PART end: save as email_experiment.dta in final folder				  										  *
***********************************************************************
save "email_experiment", replace

