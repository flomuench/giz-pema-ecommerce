***********************************************************************
* 			sampling email experiment stratification								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)	 set seed + sort by email id													  
*	2)	 random allocation
*	3)	 balance table
*	4) 	 generate email list Excel sheets by treatment status & max. contacts per email
*																 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_inter.dta
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data + set the seed				  										  *
***********************************************************************
cd "$samp_final"
	* import the data
*import excel "${samp_final}/giz_contact_list_bounce.xlsx", firstrow clear
import excel "${samp_emaillists}/bounced_emails.xlsx", firstrow clear
	drop A
	keep in 1/953
	duplicates report id_email
save "bounced_emails", replace

***********************************************************************
* 	PART 1: format all string & numerical variables				  										  
***********************************************************************
/*
	* define format for string variables
ds, has(type string) 
local strvars "`r(varlist)'"
format %-20s `strvars'

	* define format for numerical variables
ds, has(type numeric) 
local numvars "`r(varlist)'"
format %-9.0fc `numvars'

	* 
destring fte, replace
*/

***********************************************************************
* 	PART 2: drop variables that we do not need			  										  
***********************************************************************
*drop A
*keep email Nonexistencedumail

***********************************************************************
* 	PART 3: remove blanks from string variables
***********************************************************************
/*
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x' = strtrim(strtrim(`x'))
}
*/

***********************************************************************
* 	PART 4: remove blanks from string variables
***********************************************************************
*rename Nonexistencedumail not_delivered


***********************************************************************
* 	PART 5: search & remove duplicates		  										  
***********************************************************************
	* firmname same
/*
duplicates report firmname
duplicates tag firmname, gen(dup_firmname)
*/


***********************************************************************
* 	PART 6: save bounce
***********************************************************************
save "giz_contact_list_bounce", replace
	
	
***********************************************************************
* 	PART 6: merge
***********************************************************************	
		* import data base
use "${samp_final}/giz_contact_list_final", clear


merge 1:1 id_email using "bounced_emails"

gen not_delivered = .
replace not_delivered = 0 if _merge == 1
replace not_delivered = 1 if _merge == 3

/*
merge 1:m email using giz_contact_list_bounce, update replace
	
	* drop obs that are only in giz contact list final
drop if _merge == 2
	
	* drop variables that are not necessary/come from bounce
*drop A Unnamed0 dup_firmname

	* browsing suggest 2 "new" firms
codebook treatment /* +1 dans le group free childcare et video relatif aux randomisation results  */
duplicates report email
duplicates tag email, gen(dupemail)
sort firmname
browse if dupemail > 0
duplicates drop email, force
	* drop
*/
	
	
drop _merge


***********************************************************************
* 	PART 7: save final, export excel final
***********************************************************************
	* excel
export excel "giz_contact_list_final", replace firstrow(var)
	* dta
save "giz_contact_list_final", replace



