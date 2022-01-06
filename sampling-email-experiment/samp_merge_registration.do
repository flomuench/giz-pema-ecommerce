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
	* set the directory
cd "$samp_final"

	* import the registration data from another folder
import excel "${regis_intermediate}/regis_corrected_matches.xlsx", firstrow clear


	* save as dta in samp_final folder
save "regis_corrected_matches", replace

	* make sur id_email & id_plateforme are unique identifiers
keep in 1/185
drop X-Z
lab var id_email "email used for sampling/communication campaign"
lab var id_plateforme "email firm used to register"
format samp_email rg_email* *firm* %-30s
format id_plateforme id_email dup %-9.0g
format score %-20.0g
sort id_email
browse

		* check for duplicates in terms of id_email 
duplicates report id_email
/* suggests: 7 firms with one duplicate */
duplicates tag id_email, gen(did_email)
order did_email, a(id_email)
browse if did_email == 1

		* drop all duplicates of id_email based on samp_email comparison with rg_email
*duplicates drop id_email, force
drop if id_plateforme == 188 & id_email == 113
drop if id_plateforme == 315 & id_email == 473
drop if id_plateforme == 297 & id_email == 585 & score == .958896815776824951
drop if id_plateforme == 570 | id_plateforme == 291
drop if id_plateforme == 557 | id_plateforme == 344
drop if id_plateforme == 211 & id_email == 3064 & score == .953646540641784668


		* check for duplicates in terms of id_plateforme
			* same firm but different emails for sampling
duplicates report id_plateforme
/* suggests: 10 firms with one duplicate */
sort id_plateforme
duplicates tag id_plateforme, gen(did_plateforme)
order did_plateforme, a(did_email)
browse if did_plateforme == 1

		* drop duplicates in terms of id_plateforme
*duplicates drop id_plateforme, force

	* rename 
rename treatment treat
lab var treat "treatment indicator as in regis_corrected_matches"

	* save as dta in samp_final folder
save "regis_corrected_matches", replace

	* contains 177 firms

***********************************************************************
* 	PART 1: merge matches with initial population (giz_contact_list_final) based on id_email				  										  *
***********************************************************************
use "${samp_final}/giz_contact_list_final", clear
sort id_email
	* contains 4847 firms
	
merge 1:m id_email using "regis_corrected_matches"
	* all 177 corrected matches were matched
	* after matching: 4848 firms

	* generate a dummy to indicate
gen sample = .
replace sample = 1 if _merge == 3
replace sample = 2 if _merge == 1
drop if _merge == 2
	* drop merge variable & rg_expstatus (due to solve format mismatch for matching)
drop _merge rg_expstatus

	* 
order id_email id_plateforme *firmname email samp_email rg_emailpdg rg_emailrep
order matchedon-sample, a(export)

	* save as email_experiment.dta in sampling final folder
save "email_experiment", replace

***********************************************************************
* 	PART 2: merge with registration data to get controls for registered firms				  										  *
***********************************************************************
use "${regis_intermediate}/regis_inter", clear

merge m:m id_plateforme using "email_experiment"
	* 173 matched (should be 177 no?)
	
	* define categories for company origin
replace sample = 3 if _merge == 1
lab def subsample 1 "contacted & registered" 2 "contacted & not registered" 3 "not contacted & registered"
lab values sample subsample


***********************************************************************
* 	PART end: save as email_experiment.dta in final folder				  										  *
***********************************************************************
save "email_experiment", replace

