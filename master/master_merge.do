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
*	Creates:  ${master_pii}/ecommerce_master_contact.dta			                                  
***********************************************************************


***********************************************************************
* 	PART 1: merge to create analysis data set
***********************************************************************
		* change directory to master folder for merge with regis + baseline (final)
cd "$master_raw"

	* merge registration with baseline data

clear 

use "${regis_final}/regis_final", clear
*rename email treatment indicator to avoid replacement
rename treatment treatment_email

merge 1:1 id_plateforme using "${bl_final}/bl_final"
drop commentaires_ElAmouri
keep if _merge==3 /* companies that were eligible and answered on the registration + baseline surveys */
drop _merge

*generate surveyround variable
gen surveyround = 1
lab var surveyround "1-baseline 2-midline 3-endline"

    * save as ecommerce_database

*save "${master_raw}/ecommerce_database_raw", replace

merge 1:1 id_plateforme using "${bl2_final}/Webpresence_answers_final"
keep if _merge==3
drop _merge

*drop index and other variables can
drop ihs_exports w_compexp
drop ihs_ca w_compca
drop ihs_digrevenue w_compdrev
drop knowledge digtalvars expprep expoutcomes 

rename car_carempl_dive2 car_carempl_div2
lab var car_carempl_div2 "nombre de jeunes dans l'entreprise"
*save "${master_raw}/ecommerce_database_raw", replace

*create contact database with dig_presence for survey institut
preserve
merge 1:1 id_plateforme using "${master_pii}/ecommerce_master_contact"

export excel id_plateforme firmname nom_rep treatment status ///
emailrep rg_email2 rg_emailpdg telrep tel_sup1 tel_sup2 rg_telpdg rg_telephone2 ///
dig_presence1 dig_presence2 dig_presence3 matricule_physique matricule_missing ///
matricule_fiscale using "${master_pii}/midline_contactlist", ///
firstrow(var) sheetreplace

restore


***********************************************************************
* 	PART 2: merge with participation data
***********************************************************************

*merge participation file to have take up data also in analysis file
*clear 
*use "${master_raw}/ecommerce_database_raw", clear
preserve
	import excel "${master_pii}/suivi_ecommerce.xlsx", sheet("Suivi_formation") firstrow clear
	keep id_plateforme groupe module1 module2 module3 module4 module5 present absent
	drop if id_plateforme== ""
	drop if id_plateforme== "id_plateforme"
	destring id_plateforme,replace
	sort id_plateforme, stable
	save "${master_pii}/suivi_ecommerce.dta",replace
restore

merge 1:1 id_plateforme using "${master_pii}/suivi_ecommerce"
drop _merge


***********************************************************************
* 	PART 3: append midline and endline to create panel data set
***********************************************************************

	* append registration +  baseline data with midline
*assure variables are lower case
rename *, lower
append using "${ml_final}/ml_final"
sort id_plateforme, stable
drop survey_type survey

	* append with endline
/*cd "$endline_final"
append using el_final
*/
    * save as ecommerce_database
*deidentify
/*drop Ufirmname dup_firmname firmname_change tel_sup1 tel_sup2 tel_supl1 tel_supl2 email ///
id_email email Uemail treatment_email dup_id_email dup_emailpdg ident_email_1 ident_email_2 info_compt2
*/
sort id_plateforme, stable
order id_plateforme 
save "${master_intermediate}/ecommerce_master_inter", replace

*erase "${master_raw}/ecommerce_database_raw.dta"


/*export excel id_plateforme entr_produit1 ///
 using "${master_pii}/cepex_produits", firstrow(var) sheetreplace
