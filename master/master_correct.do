***********************************************************************
* 			Master correct				  
***********************************************************************
*																	  
*	PURPOSE: Generate additional variables for final analysis, not yet created
*				in surveyrround
*																	  
*	OUTLINE: 	PART 1: Baseline and take-up
*				PART 2: Mid-line	  
*				PART 3: Endline 
*													
*																	  
*	Author:  	Fabian Scheifele							    
*	ID variable: id_platforme		  					  
*	Requires:  	ecommerce_master_inter.dta
*	Creates:	ecommerce_master_inter.dta

use "${master_intermediate}/ecommerce_master_inter", clear

***********************************************************************
* 	PART 1: Baseline and registration data
***********************************************************************
replace groupe = "Sfax 1" if id_plateforme==78
replace groupe = "Sidi Bouzid" if id_plateforme==82
replace groupe = "Sfax 1" if id_plateforme==107
replace groupe = "Tunis 1" if id_plateforme==346
replace groupe = "Tunis 1" if id_plateforme==356
replace groupe = "Tunis 6" if id_plateforme==360
replace groupe = "Tunis 2" if id_plateforme==376
replace groupe = "Tunis 2" if id_plateforme==424
replace groupe = "Sfax 1" if id_plateforme==825
replace groupe = "Tunis 5" if id_plateforme==846
replace groupe = "Tunis 5" if id_plateforme==890
replace groupe = "Sfax 1" if id_plateforme==956

encode groupe, gen (groupe_factor)



save "${master_intermediate}/ecommerce_master_inter", replace
