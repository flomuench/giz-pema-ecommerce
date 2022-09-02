***********************************************************************
* 			E-commerce - master merge									  
***********************************************************************
*																	  
*	PURPOSE: make all data work reproducible, merge & analysis survey 
*            & pii data related to ecommerce program Tunisia
*  
*	OUTLINE: 	PART 1:   
*				PART 2: 	  
*				PART 3:               
*																	  
*																	  
*	Author:  						    
*	ID variable: 	id_plateforme			  					  
*	Requires: ecommerce_bl_pii.dta	ecommerce_regis_pii.dta										  
*	Creates:  ecommerce_master_contact.dta			                                  
***********************************************************************
* 	PART 1: merge to create master data set (pii)
***********************************************************************
	* merge baseline data with registration pii
use "${bl_intermediate}/ecommerce_bl_pii", clear
		
		* change directory to regis folder for merge with regis_final
cd "$regis_final"

		* merge 1:1 based on project id_plateforme
merge 1:1 id_plateforme using ecommerce_regis_pii
drop _merge

    * create panel ID
gen survey_round=1

***********************************************************************
* 	PART 2: save as ecommerce_contact_database
***********************************************************************
cd "$master_gdrive"
save "ecommerce_master_contact", replace

***********************************************************************
* 	PART 3: append to create master data set (pii)
***********************************************************************

/*
	* append registration +  baseline data with midline
cd "$midline_final"
merge 1:1 id using ml_final_pii
drop _merge


	* append with endline
cd "$endline_final"
merge 1:1 id using el_final_pii
drop _merge

*/
***********************************************************************
* 	PART 3: integrate and replace contact updates
***********************************************************************

* import Update_file:
* Note: here should the Update_file.xlsx be downloaded from teams, renamed and uploaded again in 6-master

clear
import excel "${master_gdrive}/Update_file.xlsx", sheet("update_entreprises") firstrow clear
duplicates report
duplicates drop
drop W-AU treatment firmname region sector subsector entr_bien_service entr_produit1 siteweb media Update
/*
remove old infor
reshape
rename J firmname
rename M emailrep
rename O telrep
Note: those 3 variables are repeated in the Update_file, what is that mean?
*/

rename M firmname2
rename P emailrep2
rename R telrep2

reshape wide emailrep telrep firmname2 nom_rep position_rep emailrep2 emailpdg telrep2 telpdg adresse, i(id_plateforme) j(surveyround, string)

merge 1:1 id_plateforme using ecommerce_master_contact 
drop _merge
*drop session1 session2 session3 session4
save "ecommerce_master_contact", replace

***********************************************************************
* 	PART 4: merge to create analysis data set
***********************************************************************
		* change directory to master folder for merge with regis + baseline (final)
cd "$master_raw"

	* merge registration with baseline data

clear 

use "${regis_final}/regis_final", clear
*rename email treatment indicator to avoid replacement
rename treatment treatment_email

merge 1:1 id_plateforme using "${bl_final}/bl_final"

keep if _merge==3 /* companies that were eligible and answered on the registration + baseline surveys */
drop _merge

*generate surveyround variable
gen surveyround = 1
lab var surveyround "1-baseline 2-midline 3-endline"

    * save as ecommerce_database

save "${master_raw}/ecommerce_database_raw", replace


***********************************************************************
* 	PART 5: append to create analysis data set
***********************************************************************
/*
	* append registration +  baseline data with midline
cd "$midline_final"
append using ml_final


	* append with endline
cd "$endline_final"
append using el_final
*/

***********************************************************************
* 	PART 5: merge with participation data
***********************************************************************

*Note: here should the Suivi_mise_en_oeuvre_ecommerce.xlsx be downloaded from teams, legend deleted, renamed and uploaded again in 6-master
clear 
import excel "${master_gdrive}/suivi_ecommerce.xlsx", sheet("Suivi_formation") firstrow clear
keep id_plateforme groupe module1 module2 module3 module4 module5 present absent
drop if id_plateforme== ""
drop if id_plateforme== "id_plateforme"
destring id_plateforme,replace

merge 1:1 id_plateforme using "${master_raw}/ecommerce_database_raw"
drop _merge

*generate take up variable
gen take_up = 0
replace take_up = 1 if present>2 & present<.
lab var take_up "1 if company was present in 3/5 trainings"
gen take_up2 = 0
replace take_up2 = 1 if present>0 & present<.
lab var take_up2 "alternative take-up indicator, 1 if present in at least one training"
    * save as ecommerce_database

save "${master_raw}/ecommerce_database_raw", replace



