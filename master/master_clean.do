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
* 	PART 1:    clean ecommerce_master_contact
***********************************************************************
use "${master_pii}/ecommerce_master_contact", clear
replace firmname = "tpad ( technical and practical assistance to development)" if id_plateforme == 572
replace rg_nom_rep = "rana baabaa" if id_plateforme == 623
replace firmname = "central cold stores / مخازن التبريد بالوسط" if id_plateforme == 642
replace firmname = "msb" if id_plateforme == 795
replace firmname = "urba tech" if id_plateforme == 890

drop attest attest2 acceptezvousdevalidervosré ident_nom ident_entreprise ident_nom_correct_entreprise qsinonident
save "${master_pii}/ecommerce_master_contact", replace

***********************************************************************
* 	PART 2:    clean merged analysis file (midline)
***********************************************************************
use "${master_intermediate}/ecommerce_master_inter", clear

*remove leading and trailing white space
{
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x' = stritrim(strtrim(`x'))
}
}

*Put correct label for treatment status
lab def treatment_status 0 "Control" 1 "Treatment" 
lab values treatment treatment_status



	* numeric 
ds, has(type numeric) 
local numvars "`r(varlist)'"
format %-25.2fc `numvars'

format %-25.0fc id_plateforme

* format date
format %td date


save "${master_intermediate}/ecommerce_master_inter", replace
