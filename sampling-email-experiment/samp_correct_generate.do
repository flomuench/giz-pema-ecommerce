***********************************************************************
* 			email experiment - correct, generate								  		  
***********************************************************************
*																	   
*	PURPOSE: correct variables (e.g. gender based on firm ceo), create					  								  
*	new variables
*																	  
*	OUTLINE:														  
*	1)	create dependant variable													  
*	2)	 
*	3)	 
*	4) 	 
*																 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_final.dta & regis_corrected_matches 
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data + save it in samp_final folder				  										  *
***********************************************************************
use "${samp_final}/email_experiment", clear

	* format
lab val car_sex_pdg sex

***********************************************************************
* 	PART 2: control whether gender correctly assigned to company
***********************************************************************
	* we can only compare initial gender/name with sample gender/name of firm rep (and CEO if provided)
*format rg_position_rep %-20s /* excluded in de-identified data */
browse firmname gender rg_gender_rep rg_gender_pdg car_sex_pdg name rg_position_rep rg_nom_rep if registered == 1 

	* create a dummy for all firms were initial gender is different from CEO registration or CEO baseline gender
gen gender_dif_pdg = 0
replace gender_dif = 1 if gender != rg_gender_pdg & gender != . & rg_gender_pdg != .  /* 44 */
replace gender_dif = 1 if gender != car_sex_pdg & gender != . & car_sex_pdg != .	  /* 8 */
	
	* br firms with different CEO gender
browse firmname id_plateforme id_email gender rg_gender_rep rg_gender_pdg car_sex_pdg name rg_position_rep rg_nom_rep if gender_dif_pdg == 1

	* generate a CEO corrected gender dummy
gen gender_pdg_corrected = gender
	replace gender_pdg_corrected = 1 if id_plateforme == 498 & id_email == 3673
	replace gender_pdg_corrected = 1 if id_plateforme == 807 & id_email == 3953
	replace gender_pdg_corrected = 1 if id_plateforme == 516 & id_email == 4131
	replace gender_pdg_corrected = 0 if id_plateforme == 638 & id_email == 349
	replace gender_pdg_corrected = 0 if id_plateforme == 637 & id_email == 242
	replace gender_pdg_corrected = 1 if id_plateforme == 379 & id_email == 565
	replace gender_pdg_corrected = 1 if id_plateforme == 209 & id_email == 2837
	replace gender_pdg_corrected = 1 if id_plateforme == 841 & id_email == 3904
	replace gender_pdg_corrected = 1 if id_plateforme == 619 & id_email == 881
	replace gender_pdg_corrected = 1 if id_plateforme == 575 & id_email == 276
	replace gender_pdg_corrected = 1 if id_plateforme == 642 & id_email == 3650
	replace gender_pdg_corrected = 1 if id_plateforme == 353 & id_email == 4394
	replace gender_pdg_corrected = 1 if id_plateforme == 876 & id_email == 3038
	replace gender_pdg_corrected = 1 if id_plateforme == 688 & id_email == 4621
	replace gender_pdg_corrected = 1 if id_plateforme == 419 & id_email == 1981
	replace gender_pdg_corrected = 1 if id_plateforme == 349 & id_email == 517
* ligne 4361 id_plateforme = 409, id_email = 934 "africa flying and engineering"
	
	* create a dummy for all firms were initial gender is different from representative gender (rep registered firm and rep dif gender)
gen gender_dif_rep = 0
replace gender_dif_rep = 1 if gender != rg_gender_rep & gender != . & rg_gender_rep != .  /* 73 */

	* br firms with different rep

	* generate a Rep corrected gender
gen gender_rep_corrected = gender
replace 


***********************************************************************
* 	PART end: save in samp folder
***********************************************************************
cd "$samp_final"
save "email_experiment", replace
