***********************************************************************
* 			registration fuzzy match									  	  
***********************************************************************
*																	    
*	PURPOSE: match companies registered to those in our experimental sample				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) Load data		 
*	2) Match on registration emails (rg_emailrep) and append results to  regis_matched 							  
*	3) Match on pdg/ceo email (rg_emailpdg) and and append results to  regis_matched 							    		  				  
*	5) Merge result with original regis_inter to enable manual verification 			  
*	6) Save as both 'regis_matched' (final file) and 'regis_done' (intermediate only file for further matching ) 																						  															      
*	Author:  	Teo Firpo						  
*	ID variable: no id variable defined				  
*	Requires: regis_inter.dta, giz_contact_list_final 	  								  
*	Creates:  regis_match_intermediate.xls	                          
*									

								  
***********************************************************************
* 	PART 1: Load regis_inter (list of registrations)  			
***********************************************************************

	cd "$regis_intermediate"
	
	/*
	******************** Only the first time the matching is run:
	
	
	******************** Create an regis_done.dta file that includes
	******************** all previously correct matches (which includes the 
	******************** id_plateforme and id_email) so that they don't have to 
	******************** be checked again. 
	clear 
	
	gen id_plateforme = ""
	gen id_email = ""
	destring id_plateforme, replace
	destring id_email, replace
	
	save "regis_fuzzy_merge_done", replace
	*/
	******************** You also need a regis_matched to be created once
	******************** Otherwise the 'save regis_matched, replace' later 
	******************** won't work

	
	use "regis_inter", clear


***********************************************************************
* 	PART 2: Fuzzy matching on the email of the main rep (rg_emailrep)
***********************************************************************

	******************** To use the fuzzy matching package, we need the two
	******************** email vars to be called the same; so we create a 
	******************** duplicate var called 'email' 
	******************** (as in giz_contact_list_final) 

	gen email = rg_emailrep

	******************** Now do fuzzy matching

	reclink email firmname using "${samp_gdrive}/final/giz_contact_list_final",	///
	idmaster(id_plateforme) idusing(id_email) gen(score) wmatch(100 1) exclude(regis_fuzzy_merge_done)

	******************** Don't keep those that did not match at all:
	
	drop if score==.
	
	keep id_plateforme id_email score
	
	gen matchedon = "rep_email"
		
	******************** Add to existing data 

	*append using "regis_matched"
	
	save "regis_potential_matches", replace
	
***********************************************************************
* 	PART 3: Fuzzy matching on the email of the CEO/PDG (rg_emailpdg)
***********************************************************************
	
	use "regis_inter", clear
	
	******************** As above generate a dup email variable
	
	gen email = rg_emailpdg
	
	******************** A couple rows don't have this email; drop them
	
	drop if email==""
	
	reclink email firmname using "${samp_gdrive}/final/giz_contact_list_final",	///
	idmaster(id_plateforme) idusing(id_email) gen(score) wmatch(100 1) exclude(regis_fuzzy_merge_done)

	drop if score==.
	
	keep id_plateforme id_email score

	gen matchedon = "pdg_email"
		
	append using "regis_potential_matches"
	
	save "regis_potential_matches", replace
	
	******************** As there are many duplicates, rank them by score
	******************** and identify the duplicates
	
	gsort id_plateforme -score id_email
	
	*drop dup
	
	gen dup = 0
	replace dup = 1 if id_plateforme[_n]==id_plateforme[_n+1] & id_email[_n]==id_email[_n+1] & score[_n]==score[_n+1]
	drop if dup==1
	drop dup
	
	by id_plateforme: gen dup = _n
	
	******************** Label new vars
	
	lab var matchedon "Identifies on what basis the contact was matched"
	lab var score "Matching score"
	lab var id_email "ID from original GIZ mailing list (giz_contact_list_final)"
	lab var dup "Duplicates (in order from top scoring)"

***********************************************************************
* 	PART 4: Merge with original files to allow manual verification 
*	of results
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
	
	
***********************************************************************
* 	PART 5: save & export potential matches for manual check
***********************************************************************	
	* save list of potential matches as dta file & export as Excel for manuel check
	
	save "regis_potential_matches", replace
	
	export excel using "$regis_intermediate/regis_potential_matches", firstrow(variables) replace


***********************************************************************
* 	PART 6: define list of already merged firms not to be merged in next round
***********************************************************************	
	
	******************** Save only ids, scores and 'matched on' as regis_done:
	******************** This avoids them being matched again in the next round
	******************** Which means they don't have to be manually cleaned
	
	
	keep id_plateforme id_email score matchedon
	
	save "regis_fuzzy_merge_done", replace





