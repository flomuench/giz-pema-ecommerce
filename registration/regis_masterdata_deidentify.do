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
	

***********************************************************************
* 	PART 3:  create a new variable for survey round
***********************************************************************
/*

generate survey_round= .
replace survey_round= 1 if surveyround== "registration"
replace survey_round= 2 if surveyround== "baseline"
replace survey_round= 3 if surveyround== "session1"
replace survey_round= 4 if surveyround== "session2"
replace survey_round= 5 if surveyround== "session3"
replace survey_round= 6 if surveyround== "session4"
replace survey_round= 7 if surveyround== "session5"
replace survey_round= 8 if surveyround== "session6"
replace survey_round= 9 if surveyround== "midline"
replace survey_round= 10 if surveyround== "endline"

label var survey_round "which survey round?"

label define label_survey_round  1 "registration" 2 "baseline" 3 "session1" 4 "session2" 5 "session3" 6 "session4" 7 "session5" 8 "session6" 9 "midline" 10 "endline" 
label values survey_round  label_survey_round 

***********************************************************************
* 	PART 5:  rename variables
******************************************************************

rename rg_age age
rename rg_legalstatus legalstatus
rename rg_confidentialite confidentialite
rename rg_partage_donnees partage_donnees
rename rg_enregistrement_coordonnees enregistrement_coordonnees 
rename rg_gender_rep gender_rep
rename rg_gender_pdg gender_pdg
rename rg_resident resident
rename rg_produitexp produitexp 
rename rg_intention intention
rename rg_oper_exp oper_exp 
rename rg_expstatus expstatus 
*/

***********************************************************************
* 	PART 6:  save as final file
******************************************************************
save "regis_final", replace



