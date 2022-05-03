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
	* merge registration with baseline data
use "${regis_final}/ecommerce_regis_pii", clear
		
		* change directory to baseline folder for merge with baseline_final
cd "$bl_raw"

		* merge 1:1 based on project id fxxx
merge 1:m id using ecommerce_bl_pii
drop _merge

***********************************************************************
* 	PART 2: save as ecommerce_database
***********************************************************************
cd "$master_gdrive"
save "ecommerce_master_contact", replace

***********************************************************************
* 	PART 3: integrate and replace contact updates
***********************************************************************
clear
import excel "${master_gdrive}/Update_file.xlsx", sheet("update_entreprises") firstrow clear

drop T-AR
/*
rename J firmname
rename M emailrep
rename O telrep
Note: those 3 variables are repeated in the Update_file, what is that mean?
*/
    * transform byte variable of id_plateforme into string to match the data

tostring id_plateforme, gen(id_plateforme2) format(%15.0f)
        drop id_plateforme
        ren id_plateforme2 id_plateforme

merge m:m id using ecommerce_master_contact
drop _merge
drop sector subsector entr_bien_service entr_produit1
save "ecommerce_master_contact", replace
