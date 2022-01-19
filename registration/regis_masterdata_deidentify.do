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

	* set directory to checks folder
cd "$regis_final"

***********************************************************************
* 	PART 1:  generate master data set		  			
***********************************************************************
	* restrict sample to eligible firms
keep if eligible_sans_matricule == 1

	* control that there are no duplicates
		* id_plateforme
duplicates report id_plateforme
		* firmname
duplicates report firmname /* there are 4 firms that put legal status instead of firmname */
drop dup_firmname 
duplicates tag firmname, gen(dup_firmname)
browse firmname* rg_emailpdg rg_nom_rep rg_siteweb rg_media if dup_firmname == 3
		* email pdg
duplicates report rg_emailpdg
drop dup_emailpdg 
duplicates tag rg_emailpdg, gen(dup_emailpdg)
browse firmname* rg_emailpdg rg_nom_rep rg_siteweb rg_media if dup_emailpdg
		* id_admin
duplicates report id_admin
	* 
export excel using master_data_ecommerce

***********************************************************************
* 	PART 2:  generate de-identified regis_final		  			
***********************************************************************


***********************************************************************
* 	PART end:  set environment + create pdf file for export		  			
***********************************************************************

