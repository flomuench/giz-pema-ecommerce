***********************************************************************
* 			clean do file, e-commerce			  *					  
***********************************************************************
*																	  
*	PURPOSE: clean the regis final and baseline final raw data						  
*																	  
*	OUTLINE: 	PART 1: clean regis_final	  
*				PART 2: clean bl_final	  
*				PART 3:                         											  
*																	  
*	Author:  	Fabian Scheifele & Siwar Hakim							    
*	ID variable: id_email		  					  
*	Requires:  	 ecommerce_master_contact.dta & 									  
*	Creates:     regis_final.dta bl_final.dta

***********************************************************************
* 	PART 1:    import merged analysis data
***********************************************************************
use "${master_raw}/ecommerce_master_raw", clear

***********************************************************************
* 	PART 1:    clean merged analysis file (midline)
***********************************************************************
*remove leading and trailing white space
{
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x' = stritrim(strtrim(`x'))
}
}

*Put correct labels 
	* treatment status
replace treatment = "1" if treatment == "Treatment"
replace treatment = "0" if treatment == "Control"
destring treatment, replace
format treatment %25.0fc
lab def treatment_status 0 "Control" 1 "Treatment" 
lab values treatment treatment_status

	* surveyround
lab def surveys 1 "baseline" 2 "midline"
lab values surveyround surveys

label define yesno 0 "no" 1 "yes" -999 "Don't know", replace

	*Presence of absent take_up
lab def presence 1 "present" 0 "absent"
lab values take_up_for take_up_for1 take_up_for2 take_up_for3 take_up_for4 take_up_for5 take_up_std take_up_seo take_up_smo take_up_smads take_up_website presence
	* numeric 
ds, has(type numeric) 
local numvars "`r(varlist)'"
format %-25.2fc `numvars'

format %-25.0fc id_plateforme

* format date
format %td date

*save e-commerce anaylsis
save "${master_intermediate}/ecommerce_master_inter", replace

***********************************************************************
* 	PART 2:    Remove useless variables
***********************************************************************
drop id_email id_candidates score matched_on correct_match dup_both dup_id_email programme id_admin_correct 
drop rg_confidentialite rg_partage_donnees rg_enregistrement_coordonnees dateinscription full_dup 
drop survey heure date ident_entreprise ident_email_1 k


*save e-commerce anaylsis
save "${master_intermediate}/ecommerce_master_inter", replace

***********************************************************************
* 	PART 3:    Add Tunis to rg_adresse using PII data 
***********************************************************************
use "${master_pii}/ecommerce_master_contact", clear

*gen dummy if tunis in variable
gen contains_tunis = strpos(rg_adresse, "tunis") > 0 | strpos(rg_adresse, "tunisia") > 0

*gen new rg_adresse just in case
gen rg_adresse_modified = rg_adresse

*add tunis if it does not contain it or tunisia
replace rg_adresse_modified = rg_adresse_modified + ", tunis" if !contains_tunis

save "${master_pii}/ecommerce_master_contact", replace

