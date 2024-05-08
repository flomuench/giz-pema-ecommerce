***********************************************************************
* 			second part endline ecommerce							  *
***********************************************************************
*																	   
*	PURPOSE: import the survey raw file					  								  
*			  
*																	  
*	OUTLINE:														  
*	1)	Import the answers from questionnaire as Excel		
*	2)  Create + save bl_pii file												  
*	3)	Save a de-identified analysis file	
*	4)	Add treatment status
*	5)	Save the answers as dta file in intermediate folder 
*																 																      *
*	Author:  	 	 Kaïs Jomaa														  
*	ID variable: 		id_plateforme  									  
*	Requires:			el_raw.xlsx
*	Creates:			el_intermediate.dta		
		
***********************************************************************
* 	PART 1: import the answers from questionnaire as Excel				  										  *
***********************************************************************

import excel "${el_raw}/el_raw.xlsx", firstrow clear

***********************************************************************
* 	PART 2:  create + save bl_pii file	  			
***********************************************************************
	* remove variables that already existin in pii
drop ident_base_respondent

	* rename variables to indicate el as origin
local el_changes firmname ident_repondent_position q29_nom q29_tel q29_mail 
foreach var of local el_changes {
	rename `var' `var'_el
}

	* put all pii variables into a local
local pii id_plateforme firmname_el id_ident id_ident_el ident_repondent_position_el q29_nom_el q29_tel_el q29_mail_el q29


	* save as stata master data
preserve
keep `pii'

	* export the pii data as new consortia_master_data 
export excel `pii' using "${el_raw}/ecommerce_el_pii", firstrow(var) replace
save "${el_raw}/ecommerce_el_pii", replace

restore


***********************************************************************
* 	PART 3:  save a de-identified analysis file	
***********************************************************************
	* drop all pii
drop firmname_el id_ident id_ident_el ident_repondent_position_el q29_nom_el q29_tel_el q29_mail_el q29

***********************************************************************
* 	PART 4:  Add treatment status	
***********************************************************************
merge 1:1 id_plateforme using "${ml_final}/ml_final", keepusing(treatment)
drop if _merge == 2
drop _merge 

***********************************************************************
* 	PART 5: save the answers as dta file in intermediate folder 			  						
***********************************************************************

save "${el_intermediate}/el_intermediate", replace
