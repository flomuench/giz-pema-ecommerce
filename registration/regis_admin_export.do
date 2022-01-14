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
save "verified_ecommerce_eligibles_pme", replace
restore

	* duplicates for matricule_fiscale
rename id_admin matricule_fiscale
codebook matricule_fiscale /* only 4 are missing */
duplicates report matricule_fiscale
duplicates tag matricule_fiscale, gen(dup_matfis)
browse firmname matricule_fiscale rg_nom_rep rg_emailrep rg_emailpdg rg_siteweb rg_media if dup_matfis > 0
		* only duplicates in terms of matricule fiscale are the firms with missing one
	
	* merge regis_intermediate with admin info
drop if matricule_fiscale == ""
merge 1:1 matricule_fiscale using "verified_ecommerce_eligibles_pme"
browse if _merge == 2



***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
	* set export directory
cd "$regis_intermediate"

	* save dta file
save "regis_inter", replace
