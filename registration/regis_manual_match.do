***********************************************************************
* 			registration fuzzy match - (2) merge 								  	  
***********************************************************************
*																	    
*	PURPOSE: match companies registered to those in our experimental sample				  							  
*																	  
*																	  
*	OUTLINE:
*	1)	Merge with registration data (one row per firm, regis_inter.dta, )													  
*	1.1) perfect matches
*	1.1.1) remove duplicates
*	1.1.2) verify matches row-by-row eyeballing
*	1.1.3) merge with registration data
*	1.1.4) merge with sampling data
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
* 	PART 1: Import + format perfect matches
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
		save "regis_inter", replace
	restore

***********************************************************************
* 	PART 1.4: merge with sampling data
***********************************************************************
	preserve
		br if dup_id_email > 0 /* eyeballing suggests same firm with two registrations, so no loss of information when dropped */
		duplicates drop id_email, force
		merge 1:1 id_email using "${samp_gdrive}/final/giz_contact_list_final"
		save "giz_contact_list_final", replace
	restore

***********************************************************************
* 	PART 2: Import + format candidate matches
***********************************************************************
	use "candidates", clear

	******************** Label new vars
	
	lab var matched_on "Identifies on what basis the contact was matched"
	lab var score "Matching score"
	lab var id_email "ID from original GIZ mailing list (giz_contact_list_final)"
	format %-30s firmname Ufirmname email rg_emailpdg rg_emailrep
	order id_plateforme id_email score firmname Ufirmname email /*Uemail*/ rg_emailpdg rg_emailrep

***********************************************************************
* 	PART 2.1: remove duplicates
***********************************************************************
	

***********************************************************************
* 	PART 2.2: verify matches row-by-row eyeballing
***********************************************************************
	* sort observations such that will always remain in this order
gsort matched_on -score
gen id_candidates = _n
order id_candidates, a(id_email)

br

gen correct_match = 0

local flo_obs 540 541 542 543 544 545 546 547 548 549 550 551 552 553 555 557 558 559 560 561 562 563 564 565 566 567 568 569 571 573 574 583 586 588 589 594 595 599 606 605 604 610 612 619 620 618 616 623 627 635 639 642 645 651 656 653 664 666 668 665 672 679 697 709 683 692 680 730 725 758 789 798 813 802 829 828
foreach obs of local flo_obs {
	replace correct_match = 1 if id_candidates == `obs'
}


***********************************************************************
* 	PART 2.3: merge with registration data
***********************************************************************
	preserve
		keep if correct_match == 1
		merge 1:1 id_plateforme using regis_inter
		save "regis_inter", replace
	restore

***********************************************************************
* 	PART 2.4: merge with sampling data
***********************************************************************
	preserve
		keep if correct_match == 1
		br if dup_id_email > 0 /* eyeballing suggests same firm with two registrations, so no loss of information when dropped */
		duplicates drop id_email, force
		merge 1:1 id_email using "${samp_gdrive}/final/giz_contact_list_final"
		save "giz_contact_list_final", replace
	restore
	

***********************************************************************
* 	PART 5: Merge with original files to allow manual verification
***********************************************************************	
	
	******************** First append matches done previously:
	
	*append using "regis_fuzzy_merge_done"
	
	******************** Merge with regis_inter
		
	merge m:m id_plateforme using "regis_inter"
	
	keep if _merge==3
	
	******************** Keep only identifying vars (rename them for clarity)
	
	keep id_plateforme id_email score matchedon dup rg_emailpdg rg_emailrep ///
	firmname rg_adresse id_admin rg_fte sector rg_expstatus
	
	rename firmname rg_firmname
	rename sector rg_sector
	
	******************** Merge with giz_contact_list_final
	
	merge m:m id_email using "${samp_gdrive}/final/giz_contact_list_final" 
	
	******************** Keep only identifying vars (rename them for clarity)
	
	keep if _merge==3 
	
	keep id_plateforme id_email score matchedon dup rg_emailpdg rg_emailrep ///
	rg_firmname rg_adresse id_admin rg_fte rg_sector rg_expstatus firmname ///
	name email fte treatment sector export town  
	
	rename firmname samp_firmname
	rename sector samp_sector
	rename name samp_name
	rename email samp_email
	rename fte samp_fte
	rename export samp_expstatus
	rename town samp_town
	
	******************** Order to allow manual verification
	
	order id_plateforme id_email score matchedon dup ///
		  samp_email rg_emailpdg rg_emailrep ///
		  rg_firmname samp_firmname samp_town rg_adresse  ///
		  samp_fte rg_fte samp_expstatus rg_expstatus 
	
	
	gsort id_plateforme -score id_email
	
	