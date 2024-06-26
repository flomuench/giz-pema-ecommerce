***********************************************************************
* 			baseline match to registration data									  	  
***********************************************************************
*																	    
*	PURPOSE: match survey data from registration		  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) Set up paths and merge
*	2) Label new vars 
*	3) Save
*   4) Load personal info and save
*																	  															      
*	Author:  	Teo Firpo  
*	ID variaregise: 	id_plateforme (example: 777)			  					  
*	Requires: bl_inter.dta 	  								  
*	Creates:  bl_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  Add paths
***********************************************************************
 
use "${regis_final}/regis_final.dta", clear

keep id_plateforme presence_enligne rg_age fte fte_femmes capital sector subsector rg_gender_rep rg_gender_pdg produit_exportable export2017 export2018 export2019 export2020 export2021

merge 1:m id_plateforme using "${bl_intermediate}/bl_inter"

keep if _merge==3

drop _merge

***********************************************************************
* 	PART 2:  Label new variables
***********************************************************************

lab var presence_enligne "Registration online presence question"
lab var rg_age "Registration CEO age"

***********************************************************************
* 	PART 3:  Save
***********************************************************************
cd "$bl_intermediate"
save "bl_inter", replace

