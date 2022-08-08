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
*
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_final.dta & regis_corrected_matches 
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data + save it in samp_final folder
***********************************************************************
	* set the directory
cd "$samp_final"

*use "${samp_final}/giz_contact_list_final", clear

***********************************************************************
* 	PART 2: merge with perfect matches and candidate matches
***********************************************************************
************* perfect matches
	* import perfect matches
use "${regis_intermediate}/matches", clear

	* format data
lab var matched_on "Identifies on what basis the contact was matched"
lab var score "Matching score"
lab var id_email "ID from original GIZ mailing list (giz_contact_list_final)"
format %-30s firmname Ufirmname email rg_emailpdg rg_emailrep
order id_plateforme id_email score firmname Ufirmname email /*Uemail*/ rg_emailpdg rg_emailrep

	* remove duplicates to enable unique merge (duplicates arrise as some firms registered multiple times; they are separately removed within regis.do workflow)
			* id_plateforme
duplicates report id_plateforme /* 0 */

			* id_email
duplicates report id_email /* 7 */
duplicates list id_email /* 7 */
duplicates tag id_email, gen(dup_id_email)
br if dup_id_email > 0
			
			* remove duplicates in terms of id_email
duplicates drop id_email, force  /* new N = 268 */
		
			* merge based on id_email
merge 1:1 id_email using "${samp_gdrive}/final/giz_contact_list_final"
gen registered = 0
replace registered = 1 if _merge == 3
drop _merge
			
			* save as new giz_contact_list_final
save "email_experiment", replace


	
************* candidate matches
	* import candidates matches
use "${regis_intermediate}/candidates", clear

	* format data
lab var matched_on "Identifies on what basis the contact was matched"
lab var score "Matching score"
lab var id_email "ID from original GIZ mailing list (giz_contact_list_final)"
format %-30s firmname Ufirmname email rg_emailpdg rg_emailrep
order id_plateforme id_email score firmname Ufirmname email /*Uemail*/ rg_emailpdg rg_emailrep

	* sort observations such that will always remain in this order
gsort matched_on -score
gen id_candidates = _n
order id_candidates, a(id_email)

	* create new variable that identifies the manually verified matches
gen correct_match = 0

	* replace all obs with correct_match = 1 as identified via eye-balling
local observations 532 533 530 536 528 502 494 483 473 436 383 365 363 350 478 313 289 314 289 273 272 271 203 111 91 96 82 83 84 42 29 24 12 11 7 3 2 1 505 540 541 542 543 544 545 546 547 548 549 550 551 552 553 555 557 558 559 560 561 562 563 564 565 566 567 568 569 571 573 574 583 586 588 589 594 595 599 606 605 604 610 612 619 620 618 616 623 627 635 639 642 651 656 653 664 666 668 665 672 679 683 680 730 725 758 789 798 813 802 
foreach obs of local observations {
	replace correct_match = 1 if id_candidates == `obs'
}

tab correct_match /* result should be N = 108 */
	
	* remove candidates which we identified as no match
keep if correct_match == 1

	* remove duplicates where id_plateforme and id_email is identifical as there is no loss of information
duplicates report id_plateforme id_email
duplicates tag id_plateforme id_email, gen(dup_both)
br if dup_both > 0
duplicates drop id_plateforme id_email, force /* new N = 100 */

	* check remaining candidates for duplicates
duplicates report id_plateforme /* there should be zero duplicates for id_plateforme */
sort id_email
duplicates report id_email
duplicates tag id_email, gen(dup_id_email)
br if dup_id_email > 0

	* drop duplicates in terms of id_email
duplicates drop id_email, force /* new N = 95 */
		
	* merge based on id_email
merge 1:1 id_email using "${samp_final}/email_experiment"
	* add obs to perfect matches
replace registered = 1 if _merge == 3
drop _merge


	* save as new giz contact list
save "email_experiment", replace
	

***********************************************************************
* 	PART 2: merge with registration data to get additional control/explanatory variables
***********************************************************************
/*
use "${regis_final}/regis_final", clear

merge m:m id_plateforme using "email_experiment"
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


***********************************************************************
* 	PART end: save as email_experiment.dta in final folder				  										  *
***********************************************************************
save "email_experiment", replace

