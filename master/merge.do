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
* 	PART 1: merge & append to create master data set (pii)
***********************************************************************
	* merge baseline data with registration pii
use "${bl_intermediate}/ecommerce_bl_pii", clear
		
		* change directory to regis folder for merge with regis_final
cd "$regis_final"

		* merge 1:1 based on project id_plateforme
merge 1:1 id_plateforme using ecommerce_regis_pii
drop _merge

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
* 	PART 2: save as ecommerce_contact_database
***********************************************************************
cd "$master_gdrive"
save "ecommerce_master_contact", replace

***********************************************************************
* 	PART 3: integrate and replace contact updates
***********************************************************************
*Note: here should the Update_file.xlsx be downloaded from teams, renamed and uploaded again in 6-master

clear
import excel "${master_gdrive}/Update_file.xlsx", sheet("update_entreprises") firstrow clear

drop W-AU
/*
rename J firmname
rename M emailrep
rename O telrep
Note: those 3 variables are repeated in the Update_file, what is that mean?
*/

merge m:m id_plateforme using ecommerce_master_contact
drop _merge
duplicates drop 
drop sector subsector entr_bien_service entr_produit1
save "ecommerce_master_contact", replace

***********************************************************************
* 	PART 4: merge & append to create analysis data set
***********************************************************************
		* change directory to master folder for merge with regis + baseline (final)
cd "$master_raw"

	* merge registration with baseline data

clear 

use "${regis_final}/regis_final", clear

merge 1:1 id_plateforme using "${bl_final}/bl_final"

keep if _merge==3
drop _merge

    * save as ecommerce_database

save "ecommerce_database_raw", replace

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
import excel "${master_gdrive}/Suivi_ecommerce.xlsx", sheet("Suivi_formation") firstrow clear
keep id_plateforme groupe module1 module2 module3 module4 module5
drop if id_plateforme== ""
drop if id_plateforme== "id_plateforme"
drop _merge
encode id_plateforme, generate(id_plateforme2)
drop id_plateforme
rename id_plateforme2 id_plateforme
merge 1:1 id_plateforme using "${master_raw}/ecommerce_database_raw"


    * save as ecommerce_database

save "ecommerce_database_raw", replace

***********************************************************************
* 	PART 6: 
***********************************************************************





