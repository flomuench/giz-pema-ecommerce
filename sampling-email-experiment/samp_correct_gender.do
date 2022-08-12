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
browse firmname id_plateforme id_email  gender name rg_nom_rep rg_position_rep rg_gender_rep  rg_gender_pdg car_sex_pdg  if gender_dif_pdg == 1

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
	replace gender_pdg_corrected = 0 if id_plateforme == 309 & id_email == 1326
	replace gender_pdg_corrected = 1 if id_plateforme == 370 & id_email == 3086
	replace gender_pdg_corrected = 0 if id_plateforme == 586 & id_email == 145
	replace gender_pdg_corrected = 1 if id_plateforme == 589 & id_email == 1527
	replace gender_pdg_corrected = 1 if id_plateforme == 736 & id_email == 50
	replace gender_pdg_corrected = 1 if id_plateforme == 889 & id_email == 3707
	
lab var gender_pdg_corrected "gender of ceo corrected, female = 1"
lab val gender_pdg_corrected sex

	
*	id_plateforme = 589, id_email = 1527
* ligne 4361 id_plateforme = 409, id_email = 934 "africa flying and engineering"
	
	* create a dummy for all firms were initial gender is different from representative gender (rep registered firm and rep dif gender)
gen gender_dif_rep = 0
replace gender_dif_rep = 1 if gender != rg_gender_rep & gender != . & rg_gender_rep != .  /* 52 */

	* br firms with different rep gender
browse firmname id_plateforme id_email gender name rg_nom_rep rg_position_rep rg_gender_rep  rg_gender_pdg car_sex_pdg  if gender_dif_rep == 1

	
	* generate 
gen gender_rep_corrected = gender_pdg_corrected
	replace gender_rep_corrected = 1 if id_plateforme == 58 & id_email == 3321
	replace gender_rep_corrected = 1 if id_plateforme == 83 & id_email == 4334
	replace gender_rep_corrected = 1 if id_plateforme == 91 & id_email == 500
	replace gender_rep_corrected = 1 if id_plateforme == 105 & id_email == 2318
	replace gender_rep_corrected = 1 if id_plateforme == 129 & id_email == 341
	replace gender_rep_corrected = 1 if id_plateforme == 137 & id_email == 1099
	replace gender_rep_corrected = 1 if id_plateforme == 171 & id_email == 2093
	replace gender_rep_corrected = 0 if id_plateforme == 179 & id_email == 1512 /*cas à corriger*/
	replace gender_rep_corrected = 1 if id_plateforme == 195 & id_email == 2965
	replace gender_rep_corrected = 1 if id_plateforme == 200 & id_email == 3783
	replace gender_rep_corrected = 1 if id_plateforme == 209 & id_email == 2873 /*cas à corriger*/
	replace gender_rep_corrected = 1 if id_plateforme == 211 & id_email == 3064
	replace gender_rep_corrected = 1 if id_plateforme == 216 & id_email == 2521
	replace gender_rep_corrected = 1 if id_plateforme == 243 & id_email == 4109
    replace gender_rep_corrected = 1 if id_plateforme == 261 & id_email == 1350
    replace gender_rep_corrected = 1 if id_plateforme == 267 & id_email == 3114
    replace gender_rep_corrected = 1 if id_plateforme == 271 & id_email == 4156
    replace gender_rep_corrected = 1 if id_plateforme == 279 & id_email == 4021 /*cas à corriger*/
    replace gender_rep_corrected = 1 if id_plateforme == 286 & id_email == 2339 /*cas à corriger*/
    replace gender_rep_corrected = 1 if id_plateforme == 297 & id_email == 585
    replace gender_rep_corrected = 1 if id_plateforme == 354 & id_email == 3979
    replace gender_rep_corrected = 1 if id_plateforme == 271 & id_email == 4156

	replace gender_rep_corrected = 1 if id_plateforme == 368 & id_email == 3413 /*cas à corriger*/
    replace gender_rep_corrected = 1 if id_plateforme == 390 & id_email == 4532
    replace gender_rep_corrected = 1 if id_plateforme == 394 & id_email == 3267
    replace gender_rep_corrected = 1 if id_plateforme == 401 & id_email == 2559
    replace gender_rep_corrected = 1 if id_plateforme == 416 & id_email == 1437
    replace gender_rep_corrected = 1 if id_plateforme == 418 & id_email == 2044
    replace gender_rep_corrected = 1 if id_plateforme == 425 & id_email == 3845

    replace gender_rep_corrected = 1 if id_plateforme == 457 & id_email == 621
    replace gender_rep_corrected = 0 if id_plateforme == 460 & id_email == 460
    replace gender_rep_corrected = 0 if id_plateforme == 512 & id_email == 1567 /*cas à corriger*/
    replace gender_rep_corrected = 1 if id_plateforme == 536 & id_email == 4815
    replace gender_rep_corrected = 1 if id_plateforme == 546 & id_email == 185 /*cas à corriger*/
    replace gender_rep_corrected = 1 if id_plateforme == 598 & id_email == 640 /*cas à corriger*/
    replace gender_rep_corrected = 1 if id_plateforme == 628 & id_email == 3389
    replace gender_rep_corrected = 1 if id_plateforme == 634 & id_email == 457
    replace gender_rep_corrected = 1 if id_plateforme == 654 & id_email == 465

    replace gender_rep_corrected = 1 if id_plateforme == 692 & id_email == 2455
    replace gender_rep_corrected = 1 if id_plateforme == 700 & id_email == 2099
    replace gender_rep_corrected = 1 if id_plateforme == 706 & id_email == 3406
    replace gender_rep_corrected = 1 if id_plateforme == 713 & id_email == 3994
    replace gender_rep_corrected = 1 if id_plateforme == 726 & id_email == 2900
    replace gender_rep_corrected = 1 if id_plateforme == 757 & id_email == 2566
    replace gender_rep_corrected = 1 if id_plateforme == 807 & id_email == 4160
    replace gender_rep_corrected = 1 if id_plateforme == 821 & id_email == 4261
    replace gender_rep_corrected = 1 if id_plateforme == 825 & id_email == 1462 /*cas à corriger*/
    replace gender_rep_corrected = 1 if id_plateforme == 873 & id_email == 3466
    replace gender_rep_corrected = 1 if id_plateforme == 875 & id_email == 391
    replace gender_rep_corrected = 1 if id_plateforme == 881 & id_email == 3137
	
    replace gender_rep_corrected = 1 if id_plateforme == 884 & id_email == 2072
    replace gender_rep_corrected = 1 if id_plateforme == 896 & id_email == 1232
    replace gender_rep_corrected = 1 if id_plateforme == 900 & id_email == 24
    replace gender_rep_corrected = 1 if id_plateforme == 941 & id_email == 146
    replace gender_rep_corrected = 0 if id_plateforme == 959 & id_email == 2107
    replace gender_rep_corrected = 1 if id_plateforme == 967 & id_email == 2211
	
lab var gender_rep_corrected "gender of ceo & rep corrected, female = 1"
lab val gender_rep_corrected sex

***********************************************************************
* 	PART 2: replace initial gender with CEO gender from registration
***********************************************************************
replace gender = rg_gender_pdg if gender == .
replace gender = car_sex_pdg if gender == .
replace gender = rg_gender_rep if gender == .


***********************************************************************
* 	PART end: save in samp folder
***********************************************************************
cd "$samp_final"
save "email_experiment", replace
