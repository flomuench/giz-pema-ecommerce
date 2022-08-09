***********************************************************************
* 			email experiment - merge population with registered firms								  		  
***********************************************************************
*																	   
*	PURPOSE: merge information from registration to population for the
*	firms that registered
*																	  
*																	  
*	OUTLINE:														  
*	1)	 													  
*	2)	 
*	3)	 save as email_experiment.dta in final folder
*
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_final.dta & regis_corrected_matches 
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data
***********************************************************************
	* set the directory
cd "$samp_final"

use "email_experiment", clear /* 4,847 firms */

***********************************************************************
* 	PART 2: merge with registration data set based on id_plateforme
***********************************************************************
merge m:1 id_plateforme using "${regis_intermediate}/regis_for_email_experiment" /* 5426 firms */
/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         5,090
        from master                     4,513  (_merge==1)
        from using                        579  (_merge==2)

    matched                               336  (_merge==3)
    -----------------------------------------
579 + 336 = 915
4847 - 4514 = 333
firms in our database that did not register = 4513
firms that registered but were not in our database = 579
firms that were in our database and registered = 336
total number of firms	= 4514 + 573 + 333 = 5426
*/

drop _merge

***********************************************************************
* 	PART 3: save as email experiment data
***********************************************************************
save "email_experiment", replace



/* archive:

***********************************************************************
* 	PART 2: merge with registration data to get additional control/explanatory variables
***********************************************************************

merge 1:1 id_plateforme using "regis_final"
	* 173 matched (should be 177 no?)
	

	
	* define categories for company origin
replace sample = 3 if _merge == 1
lab def subsample 1 "contacted & registered" 2 "contacted & not registered" 3 "not contacted & registered"
lab values sample subsample

		* drop duplicates in terms of id_plateforme
			* option 1: we keep always the CEO
			* option 2: we keep always the women
	* id 58
		* pdg = male, rep = female --> keep ceo line but change rep gender to female (gender_rep already female)
		* id_email = 1532 3321
drop if id_plateforme == 58 & id_email == 1532

	* id 83
		* id_email = 4334 270; keep first entry as second entry less info & no indication of female rep
drop if id_plateforme == 83 & id_email == 270
	
	* id 168 
		* rep = femme (Mouna), pdg = homme (Moncef), more information on pdg, both control
			* keep pdg but change sex of rep into female
drop if id_plateforme == 168 & id_email == 1076
replace rg_gender_rep = 1 if id_plateforme == 168 & id_email == 439
	
	* id 221
drop if id_plateforme == 221 /* firm both in treatment & control due to different firm name in GIZ vs. API data base */
		
	* id 258
		* id_email = 1122 2817; deux hommes presque identiques, garde le premier
drop if id_plateforme == 258 & id_email == 2817
	
	* id 293 
		* appears to different companies part of the same mother company/conglomerate with two different CEOs, reps
replace id_plateforme = 968 if id_plateforme == 293 & id_email == 4563
	
	* id 308
		* rg_email suggests pdg = wafa (femme) & rep = Marwa (femme); keep second line cause more info
drop if id_plateforme == 308 & id_email == 2394
	* id 391
		* pdg = homme & rep = femme; id_email = 278 330
			* rg_email suggests Sawssen Bouguerra has registered the company
drop if id_plateforme == 391 & id_email == 278
	* id 436
		* pdg & rep = homme, keep first entry (pdg) as more information
drop if id_plateforme == 436 & id_email == 1418
	* id 483
		* 2x hommes; keep first entry as more information
drop if id_plateforme == 483 & id_email == 4448
