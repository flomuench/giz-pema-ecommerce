***********************************************************************
* 			clean do file, e-commerce			  *					  
***********************************************************************
*																	  
*	PURPOSE: clean the regis final and baseline final raw data						  
*																	  
*	OUTLINE: 	PART 1: clean regis_final	  
*				PART 2: clean bl_final	  
*				PART 3:                         											  
*																	  
*	Author:  	Fabian Scheifele & Siwar Hakim							    
*	ID variable: id_email		  					  
*	Requires:  	 regis_final.dta bl_final.dta 										  
*	Creates:     regis_final.dta bl_final.dta


***********************************************************************
* 	PART 1:    clean ecommerce_master_contact
***********************************************************************

/*

***********************************************************************
* 	PART 2:    clean regis_final
***********************************************************************

use "${regis_final}/regis_final", clear

* 1.1 rename variables:

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

* 1.2 save new regis final:
cd "$master_final"
save "master_regis_final", replace	

***********************************************************************
* 	PART 2:    clean bl_final			  
***********************************************************************

use "${bl_final}/bl_final", clear

* 2.1 rename variables:
rename rg_gender_rep gender_rep 
rename rg_gender_pdg gender_pdg 
rename rg_oper_exp oper_exp
rename rg_age age

* 2.2 save new baseline final:
cd "$master_final"
save "master_bl_final", replace
