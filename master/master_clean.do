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
replace firmname = "tpad ( technical and practical assistance to development)" if id_plateforme == 572
replace rg_nom_rep = "rana baabaa" if id_plateforme == 623
replace firmname = "Central cold stores / مخازن التبريد بالوسط" if id_plateforme == 642
replace firmname = "MSB" if id_plateforme == 795
replace firmname = "urba tech" if id_plateforme == 890

drop attest attest2 acceptezvousdevalidervosré ident_nom ident_entreprise ident_nom_correct_entreprise ident_email_1 qsinonident ident_email_2 id_ident2
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
