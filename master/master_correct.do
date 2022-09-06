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
*Take-up data
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

*Export
local ihs_vars ihs_ca ihs_profits ihs_exports ihs_digrevenue
foreach var of local  ihs_vars {
	replace `var' = . if `var' <0 

}

*firms that have not exported in the past and did not report an export value for 2020 will be assumed zero
replace compexp_2020 = 0 if compexp_2020 ==. & exp_avant21 ==0
replace exp_pays_21=0 if compexp_2020==0
replace exp_pays_21=. if exp_pays_21==-999


*Reduce variables with two equal medium levels from 4 to 3 dimensions
local vars dig_description1 dig_description2 dig_description3 
foreach var of local  vars {
	replace `var' = .5 if `var'==0.49 | `var'==0.51

}

replace dig_con6_score = 1 if dig_con6_score >0.98 & dig_con6_score<.
replace dig_presence_score =1 if dig_presence_score >0.98 & dig_presence_score<.



save "${master_intermediate}/ecommerce_master_inter", replace
