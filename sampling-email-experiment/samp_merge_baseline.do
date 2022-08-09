* 	email experiment - merge population with baseline survey response							  		  
***********************************************************************
*																	   
*	PURPOSE: retrieve gender of CEO at least for registered firms					  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)	 merge firms in email_experiment (initial population) with bl responses 
* 	of firms registered thanks to the email (177)													  
*																 																      *
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

use "email_experiment", clear

***********************************************************************
* 	PART 2: merge with registration data set based on id_plateforme
***********************************************************************
* note: bl_final contains 236 firms/obs
merge m:1 id_plateforme using "${bl_final}/bl_final"

gen baseline_available = 0
replace baseline_available = 1 if _merge == 3

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         5,187
        from master                     5,187  (_merge==1)
        from using                          0  (_merge==2)

    matched                               239  (_merge==3)
    -----------------------------------------
*/
* 239 matches because three companies with different id_email but same id_plateforme
duplicates list id_plateforme if _merge == 3


drop _merge

***********************************************************************
* 	PART 3: save as email experiment data
***********************************************************************
save "email_experiment", replace


