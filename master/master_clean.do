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
* 	PART 1:    clean merged analysis file (midline)
***********************************************************************
use "${master_intermediate}/ecommerce_master_inter", clear

* put key variables first
order id_plateforme surveyround treatment, first

* sort
sort id_plateforme surveyround, stable

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
lab def treatment_status 0 "Control" 1 "Treatment" 
lab values treatment treatment_status

	* surveyround
lab def surveys 1 "baseline" 2 "midline"
lab values surveyround surveys

label define yesno 0 "no" 1 "yes" -999 "Don't know", replace

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
* 	PART 2:    Add Tunis to rg_adresse using PII data 
***********************************************************************
use "${master_pii}/ecommerce_master_contact", clear

*gen dummy if tunis in variable
gen contains_tunis = strpos(rg_adresse, "tunis") > 0 | strpos(rg_adresse, "tunisia") > 0

*gen new rg_adresse just in case
gen rg_adresse_modified = rg_adresse

*add tunis if it does not contain it or tunisia
replace rg_adresse_modified = rg_adresse_modified + ", tunis" if !contains_tunis

save "${master_pii}/ecommerce_master_contact", replace

