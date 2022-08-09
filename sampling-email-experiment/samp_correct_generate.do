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
browse gender rg_gender_rep rg_gender_pdg car_sex_pdg name rg_position_rep rg_nom_rep if registered == 1 

	* create a dummy for all firms were initial gender is different from CEO registration or CEO baseline gender
gen gender_dif_pdg = 0
replace gender_dif = 1 if gender != rg_gender_pdg & gender != . & rg_gender_pdg != .  /* 44 */
replace gender_dif = 1 if gender != car_sex_pdg & gender != . & car_sex_pdg != .	  /* 8 */
	
	* br firms with different CEO gender
browse gender rg_gender_rep rg_gender_pdg car_sex_pdg name rg_position_rep rg_nom_rep if gender_dif_pdg == 1

	* generate a CEO corrected gender dummy
gen gender_pdg_corrected

	* create a dummy for all firms were initial gender is different from representative gender (rep registered firm and rep dif gender)
gen gender_dif_rep = 0
replace gender_dif_rep = 1 if gender != rg_gender_rep & gender != . & rg_gender_rep != .  /* 73 */

	* br firms with different rep

	* generate a Rep corrected gender
gen gender_rep_corrected = gender
replace 


	* restrict browse only to firms where we observe mismatch in gender
browse gender rg_gender_rep rg_gender_pdg name if registered == 1 & rg_gender_pdg != gender
/* final is de-identified, hence following variables not included: rg_nom_rep rg_position_rep */
	
	* generate a new (corrected) gender
gen gender_corrected = .
replace gender_corrected = gender if rg_gender_rep == .
replace gender_corrected = rg_gender_rep if rg_gender_rep != .
lab val gender_rep sex

browse gender rg_gender_rep rg_gender_pdg name if registered == 1 & rg_gender_pdg != gender
/* final is de-identified, hence following variables not included: rg_nom_rep rg_position_rep */
gen difgen1 = (gender != rg_gender_rep)
tab difgen if registered == 1
	* suggests 44 companies would have a change in gender of ceo would we take rep instead of ceo


***********************************************************************
* 	PART end: save in samp folder
***********************************************************************
	* change folder 
cd "$samp_final"
save "email_experiment", replace
