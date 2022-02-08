***********************************************************************
* 			
***********************************************************************
*																	   
*	PURPOSE: 	import + merge administrative information about exporter 														 
*				status
*	OUTLINE:														  
*	1)				progress		  		  			
*	2)  			eligibility					 
*	3)  			characteristics							  
*																	  
*	ID variaregise: 	id (example: f101)			  					  
*	Requires: regis_inter.dta & regis_checks_survey_progress.do 	  
*	Creates:  regis_inter.dta			  
*																	  
***********************************************************************
* 	PART 0:  set environment + create pdf file for export		  			
***********************************************************************
	* import file
use "${regis_intermediate}/regis_inter", clear

	* set directory to checks folder
cd "$regis_intermediate"

***********************************************************************
* 	PART 1:  import admin info		  			
***********************************************************************

	* import
preserve 
import excel "Vérif finale-ecommerce_eligibes_pme 2022", firstrow clear
keep in 1/251
drop R-AI
format %-30s nom_entreprise site_web Téléphone reseaux_sociaux produit_exportable
duplicates report nom_entreprise
duplicates tag nom_entreprise, gen(dup_entreprise)
	* drop duplicates
drop if matricule_fiscale == "1338465K" /* celectronix dup */
drop if matricule_fiscale == "601525v" /* delta cuisine dup */
drop if matricule_fiscale == "1182440N" /* laboratoires zahra nature */
drop if matricule_fiscale == "741285b" /* leader food process */
drop if nom_entreprise == "CYMOD INTERNATIONAL"
	* save as stata file

save "verified_ecommerce_eligibles_pme", replace
restore

***********************************************************************
* 	PART 2:  correct for changes in matricule fiscal 	  			
***********************************************************************
	* harmonize the names of the unique fiscal identifier in both data files
 rename id_admin matricule_fiscale

	* correct in master with new matricule fiscale from administrative verification
replace matricule_fiscale = "1324038w" if firmname == "cymod international"
replace matricule_fiscale = "1338465k" if firmname == "celectronix"
replace matricule_fiscale = "0601525v" if firmname == "delta cuisine"
replace matricule_fiscale = "0003856g" if firmname == "laboratoires africa parf"
replace matricule_fiscale = "1182440n" if firmname == "laboratoires zahra nature"
replace matricule_fiscale = "0741285b" if firmname == "leader food process"
replace matricule_fiscale = "1604945h" if firmname == "othmani frères dattes"
replace matricule_fiscale = "0002171d" if firmname == "plastiform"
replace matricule_fiscale = "1230480S" if firmname == "ste azaiez dattes"
replace matricule_fiscale = "383708h" if firmname == "ste ed-dar"
replace matricule_fiscale = "411643s" if firmname == "univers equipement mansour"


	* duplicates for matricule_fiscale
codebook matricule_fiscale /* only 4 are missing */
duplicates report matricule_fiscale
duplicates tag matricule_fiscale, gen(dup_matfis)
browse firmname matricule_fiscale rg_nom_rep rg_emailrep rg_emailpdg rg_siteweb rg_media if dup_matfis > 0
		* only duplicates in terms of matricule fiscale are the firms with missing one
	
***********************************************************************
* 	PART 3:  merge 	  			
***********************************************************************
	* merge regis_intermediate with admin info
drop if matricule_fiscale == ""
merge 1:1 matricule_fiscale using "verified_ecommerce_eligibles_pme"
browse if _merge == 2
*export excel matricule_fiscale nom_entreprise-export2021 using "verif_unmerged" if _merge == 2, replace firstrow(var)
drop code_douane site_web Téléphone reseaux_sociaux date_created onshore employes
gen finally_eligible = 0
replace finally_eligible = 1 if _merge == 3

drop _merge

***********************************************************************
* 	PART 4:  export contact list for baseline 	  			
***********************************************************************+
cd "$regis_final"

	* export all eligible firms
export excel id_plateforme firmname rg_nom_rep rg_position_rep rg_emailrep rg_emailpdg rg_email2 rg_telrep rg_telpdg rg_telephone2 using "eligible_finale" if finally_eligible == 1, replace firstrow(var)

	* export all ineligible firms
export excel id_plateforme firmname rg_nom_rep rg_position_rep rg_emailrep rg_emailpdg rg_email2 rg_telrep rg_telpdg rg_telephone2 using "ineligible_finale" if finally_eligible == 0, replace firstrow(var)

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$regis_intermediate"

	* save dta file
save "regis_inter", replace
