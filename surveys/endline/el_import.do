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
* 	PART 2:  Rename variable for code	  			
************************************************************************
rename ID_Plateform id_plateforme 
rename firmname same_firmname
rename NOMESE firmname 
rename NOMREP repondant_endline 
rename Id_ident id_ident 
rename Id_ident_el id_ident_el 
rename Veuillezsaisirlenomdelentr new_firmname
rename Quelestvotrefonctionausein new_ident_repondent_position
rename Q car_carempl_div3
rename AO sm_use_com
rename CL profit_2023_category_gain
rename CN profit_2024_category_gain
rename Seriezvousenmesuredenousfo accord_q29

rename cliens_b2c clients_b2c
rename BN export_45_other
lab var export_45_other "Others reasons for not exporting"

rename BK dig_barr7_other
lab var dig_barr7_other "Others digital barriers"

rename AV mark_online5_other
lab var mark_online5_other "Others online marketing activities"

***********************************************************************
* 	PART 3:  create + save bl_pii file	  			
***********************************************************************
	* remove variables that already existin in pii
drop firmname same_firmname accord_q29
	* rename variables to indicate el as origin
local el_changes new_firmname new_ident_repondent_position q29_nom q29_tel q29_mail  
foreach var of local el_changes {
	rename `var' `var'_el
}

	* put all pii variables into a local
local pii id_plateforme new_firmname_el repondant_endline id_ident id_ident_el new_ident_repondent_position_el q29_nom_el q29_tel_el q29_mail_el q29 

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
drop new_firmname_el repondant_endline id_ident id_ident_el new_ident_repondent_position_el q29_nom_el q29_tel_el q29_mail_el q29 

***********************************************************************
* 	PART 4:  Add treatment status	
***********************************************************************
merge 1:1 id_plateforme using "${master_gdrive}/pii/endline_contactlist", keepusing(status)
drop if _merge == 2
drop _merge 
replace status ="0" if status=="groupe control"
replace status ="1" if status=="participant"

destring status, replace
format status %25.0fc

rename status treatment
label var treatment "Treatment status"
label define treat 0 "Control" 1 "Treatment" 
label values treatment treat 

***********************************************************************
* 	PART 5: save the answers as dta file in intermediate folder 			  						
***********************************************************************

save "${el_intermediate}/el_intermediate", replace
