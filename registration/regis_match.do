***********************************************************************
* 			registration fuzzy merge - (1) perfect & candidate matches							  	  
***********************************************************************
*																	    
*	PURPOSE: match companies registered to those in our experimental sample				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) fuzzy merge based on firmname		 
*	2) fuzzy merge based on email_rep
*	3) fuzzy merge based on email_pdg
*														    
*	Author:  	Teo Firpo, Florian Münch					  
*	ID variable: id_plateforme, id_email				  
*	Requires: regis_inter.dta, giz_contact_list_final 	  								  
*	Creates:  matches.dta, candidates.dta									

								  
***********************************************************************
* 	PART 1: import corrected matches & save as dta  			
***********************************************************************

	cd "$regis_intermediate"
	
	use "regis_inter", clear
	
***********************************************************************
* 	PART 2: Fuzzy matching based on firm name
***********************************************************************
/* 
	To use the fuzzy matching package, we need the two
	firmname vars to be called the same in both data set,
	which is the case
	*/

	******************** Now do fuzzy matching

	reclink firmname using "${samp_gdrive}/final/giz_contact_list_final",	///
	idmaster(id_plateforme) idusing(id_email) gen(score) wmatch(10)
	
/* Result should be: 
	N = 949, matched = 610, exact = 100, unmatched = 301
																			*/
	
	******************** formating
	
	format rg_emailpdg rg_emailrep %20s
	format firmname Ufirmname %40s	
	
	******************** save perfect matches
	preserve
	
	drop if firmname == ""
	
	keep if score == 1
	
	keep id_plateforme id_email email firmname Ufirmname rg_emailpdg rg_emailrep score treatment
	
	gen matched_on = "firmname"
	
	save "matches", replace
	
	restore

/* Result should be: 
	matches.dta N = 100
																			*/
	
	******************** save candidate matches with score > 0.9
	preserve
	
	drop if firmname == ""
	
	keep if score > 0.9 & score < 1
	
	keep id_plateforme id_email email firmname Ufirmname rg_emailpdg rg_emailrep score treatment
	
	gen matched_on = "firmname"
	
	save "candidates", replace
	
	restore
	
/* Result should be: 
	candidates.dta N = 297
																			*/
		
***********************************************************************
* 	PART 3: Fuzzy matching on the email of the main rep (rg_emailrep)
***********************************************************************

use "regis_inter", clear

	******************** harmonize name of email variable

	gen email = rg_emailrep

	******************** Now do fuzzy matching

	reclink email using "${samp_gdrive}/final/giz_contact_list_final",	///
	idmaster(id_plateforme) idusing(id_email) gen(score) wmatch(10) exclude(matches)
	
/* Result should be: 
	N after excl. matches = 811, N=940, matched = 737, exact = 134, unmatched = 174
																			*/

	******************** save perfect matches
	preserve
	
	drop if email == ""
	
	keep if score == 1
	
	keep id_plateforme id_email firmname Uemail email rg_emailpdg rg_emailrep score treatment
	
	gen matched_on = "email_rep"
	
	append using "matches"
	
	save "matches", replace
	
	restore
	
/* Result should be: N in matches = 234 */
	
	******************** save candidate matches with score > 0.9
	preserve
	
	drop if email == ""
	
	keep if score > 0.9 & score < 1
	
	keep id_plateforme id_email firmname email Uemail rg_emailpdg rg_emailrep score treatment
	
	gen matched_on = "email_rep"
	
	append using "candidates"
	
	save "candidates", replace
	
	restore

/* Result should be: N in candidates = 297 + 269 */
	
***********************************************************************
* 	PART 5: Fuzzy matching on the email of the main pdg (rg_emailpdg)
***********************************************************************

use "regis_inter", clear

	******************** harmonize name of email variable

	gen email = rg_emailpdg

	******************** Now do fuzzy matching

	reclink email using "${samp_gdrive}/final/giz_contact_list_final",	///
	idmaster(id_plateforme) idusing(id_email) gen(score) wmatch(10) exclude(matches)
	
/* Result should be: 
	N after excl. matches = 677, N=949, matched = 600, exact = 41, unmatched = 311
																			*/

	******************** save perfect matches
	preserve
	
	drop if email == ""
	
	keep if score == 1
	
	keep id_plateforme id_email firmname email Uemail rg_emailpdg rg_emailpdg score treatment
	
	gen matched_on = "email_pdg"
	
	append using "matches"
	
	save "matches", replace
	
	restore
	
/* Result should be: N in matches = 275 */

	
	******************** save candidate matches with score > 0.9
	preserve
	
	drop if email == ""
	
	keep if score > 0.9 & score < 1
	
	keep id_plateforme id_email firmname email Uemail rg_emailpdg rg_emailpdg score treatment
	
	gen matched_on = "email_pdg"
	
	append using "candidates"
	
	save "candidates", replace
	
	restore
	

/* Result should be: N in candidates = 297 + 269 + 272 = 838 */

