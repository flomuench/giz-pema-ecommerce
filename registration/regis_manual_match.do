***********************************************************************
* 			registration fuzzy match - (2) merge 								  	  
***********************************************************************
*																	    
*	PURPOSE: match companies registered to those in our experimental sample				  							  
*																	  
*																	  
*	OUTLINE:
*	1.1) perfect matches
*	1.1) remove duplicates
*	1.2) verify matches row-by-row eyeballing
*	1.3) merge with registration data
*	1.4) merge with sampling data
*	2) candidate matches
*	2.1.) remove duplicates
*	2.2.) verify matches row-by-row eyeballing
*	2.3.) merge with registration data
*	2.4.) merge with sampling data
*														    
*	Author:  	Teo Firpo, Florian Münch					  
*	ID variable: id_plateforme, id_email				  
*	Requires: regis_inter.dta, giz_contact_list_final 	  								  
*	Creates:  matches.dta, candidates.dta		
***********************************************************************
* 	PART 1: Perfect matches - matches.dta - import and format
***********************************************************************

	cd "$regis_inter"

	use "matches", clear

	******************** Label new vars
	
	lab var matched_on "Identifies on what basis the contact was matched"
	lab var score "Matching score"
	lab var id_email "ID from original GIZ mailing list (giz_contact_list_final)"
	format %-30s firmname Ufirmname email rg_emailpdg rg_emailrep
	order id_plateforme id_email score firmname Ufirmname email /*Uemail*/ rg_emailpdg rg_emailrep
	
***********************************************************************
* 	PART 1.1: remove duplicates
***********************************************************************
	* id_plateforme
duplicates report id_plateforme /* 0 */

	* id_email
duplicates report id_email /* 7 */
duplicates list id_email /* 7 */
duplicates tag id_email, gen(dup_id_email)
br if dup_id_email > 0


duplicates report firmname if firmname != "" /* 5 */
duplicates report rg_emailpdg if rg_emailpdg != "" /* 6 */
duplicates report rg_emailrep if rg_emailrep != "" /* 0 */

***********************************************************************
* 	PART 1.2: verify matches row-by-row eyeballing
***********************************************************************
br

***********************************************************************
* 	PART 1.3: merge with registration data
***********************************************************************
	preserve
		merge 1:1 id_plateforme using regis_inter
		gen identified = 0
		replace identified = 1 if _merge == 3
		drop _merge
		save "regis_inter", replace
	restore

***********************************************************************
/* 	PART 1.4: merge with sampling data --> this part has been integrated into the samp.do workflow 
	see samp_merge_registration, line 28 ff */
***********************************************************************
/*
	preserve
		br if dup_id_email > 0 /* eyeballing suggests same firm with two registrations, so no loss of information when dropped */
		duplicates drop id_email, force
		merge 1:1 id_email using "${samp_gdrive}/final/giz_contact_list_final"
		drop _merge
		save "giz_contact_list_final", replace
	restore
*/
***********************************************************************
* 	PART 2: Candidate matches - candidates.dta - import and format
***********************************************************************
	use "candidates", clear

	******************** Label new vars
	
	lab var matched_on "Identifies on what basis the contact was matched"
	lab var score "Matching score"
	lab var id_email "ID from original GIZ mailing list (giz_contact_list_final)"
	format %-30s firmname Ufirmname email rg_emailpdg rg_emailrep
	order id_plateforme id_email score firmname Ufirmname email /*Uemail*/ rg_emailpdg rg_emailrep


***********************************************************************
* 	PART 2.1: verify matches row-by-row eyeballing
***********************************************************************
	* sort observations such that will always remain in this order
gsort matched_on -score
gen id_candidates = _n
order id_candidates, a(id_email)

br

gen correct_match = 0

local observations 532 533 530 536 528 502 494 483 473 436 383 365 363 350 478 313 289 314 289 273 272 271 203 111 82 83 84 42 29 24 12 11 7 3 2 1 505 540 541 542 543 544 545 546 547 548 549 550 551 552 553 555 557 558 559 560 561 562 563 564 565 566 567 568 569 571 573 574 583 586 588 589 594 595 599 606 605 604 610 612 619 620 618 616 623 627 635 639 642 651 656 653 664 666 668 665 672 679 683 680 730 725 758 789 798 813 802 
foreach obs of local observations {
	replace correct_match = 1 if id_candidates == `obs'
}

tab correct_match /* result should be N = 108 */
	
***********************************************************************
* 	PART 2.2: remove duplicates
***********************************************************************
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


***********************************************************************
* 	PART 2.3: merge with registration data
***********************************************************************
	preserve
		merge 1:1 id_plateforme using regis_inter
		replace identified = 1 if _merge == 3
		drop _merge
		save "regis_inter", replace
	restore

***********************************************************************
/* 	PART 2.4: merge with sampling data --> this part has been integrated into the samp.do workflow 
	see samp_merge_registration, line 65 ff */
***********************************************************************
/*
	preserve
		duplicates drop id_email, force /* new N = 95 */
		merge 1:1 id_email using "${samp_gdrive}/final/giz_contact_list_final"
		save "giz_contact_list_final", replace
	restore
*/


	
	