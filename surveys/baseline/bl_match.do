***********************************************************************
* 			baseline match to registration data									  	  
***********************************************************************
*																	    
*	PURPOSE: match survey data from registration		  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) Set up paths and merge
*	2) Save
*																	  															      
*	Author:  	Teo Firpo  
*	ID variaregise: 	id_plateforme (example: 777)			  					  
*	Requires: bl_inter.dta 	  								  
*	Creates:  bl_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  Add paths
***********************************************************************

clear 

use "${regis_final}/regis_final", clear

keep id_plateforme presence_enligne rg_age fte fte_femmes capital sector subsector rg_gender_rep rg_gender_pdg produit_exportable export2017 export2018 export2019 export2020 export2021
//rg_firmname rg_fte samp_fte rg_expstatus rg_sector samp_sector

merge m:m id_plateforme using "${bl_intermediate}/bl_inter"

keep if _merge==3

drop _merge

// Need to figure out which obs to keep 

***********************************************************************
* 	PART 2:  Save
***********************************************************************
