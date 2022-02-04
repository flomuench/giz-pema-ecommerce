***********************************************************************
* 			create master data + de-identified data set
***********************************************************************
*																	   
*	PURPOSE: 		check whether string answer to open questions are 														 
*					logical
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

	* make final cleanings
			* two firmname variables, drop one with less observations
drop nom_entreprise date_created_str date_creation /* site_web Téléphone reseaux_sociaux onshore employes */
			* rename variables that we collect several times and have rg prefix
	
foreach x in fte fte_femmes capital codedouane matricule {
	rename rg_`x' `x'
}
drop matricule_cnss
rename matricule matricule_cnss

***********************************************************************
* 	PART 1:  generate master data set		  			
***********************************************************************
	* set directory to e-commerce data folder
cd "$gdrive_data"

	* restrict sample to eligible firms
keep if eligible_sans_matricule == 1

	* control that there are no duplicates
		* id_plateforme
duplicates report id_plateforme
		* firmname
duplicates report firmname /* there are 4 firms that put legal status instead of firmname */
drop dup_firmname 
duplicates tag firmname, gen(dup_firmname)
*browse firmname* rg_emailpdg rg_nom_rep rg_siteweb rg_media if dup_firmname == 3
		* email pdg
duplicates report rg_emailpdg
drop dup_emailpdg 
duplicates tag rg_emailpdg, gen(dup_emailpdg)
*browse firmname* rg_emailpdg rg_nom_rep rg_siteweb rg_media if dup_emailpdg
		* id_admin
duplicates report id_admin
	
	* export master data set
local pii1 "id_plateforme firmname rg_nom_rep rg_position_rep rg_emailrep rg_emailpdg rg_email2 rg_telrep rg_telpdg rg_telephone2 rg_adresse* rg_siteweb rg_media matricule_fiscale codedouane matricule_cnss rg_legalstatus"
export excel `pii1' using master_data_ecommerce, firstrow(var) replace

***********************************************************************
* 	PART 2:  generate de-identified regis_final		  			
***********************************************************************
	* set directory to regis_final
cd "$regis_final"
	
	* create variable to indicate surveyround
gen survey = 1
lab def surveyround 1 "registration" 2 "baseline" 3 "midline" 4 "endline"
lab val survey surveyround

	* drop all pii but id_plateforme
local pii2 "firmname rg_nom_rep rg_position_rep rg_emailrep rg_emailpdg rg_email2 rg_telrep rg_telpdg rg_telephone2 rg_adresse* rg_siteweb rg_media matricule_fiscale codedouane matricule_cnss"
drop `pii2'
	

	* save as final file
save "regis_final", replace



