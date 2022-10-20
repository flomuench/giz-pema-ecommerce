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


*firms that have not exported in the past and did not report an export value for 2020 will be assumed zero
replace compexp_2020 = 0 if compexp_2020 ==. & exp_avant21 == 0
replace exp_pays_21=0 if compexp_2020==0
replace exp_pays_21=. if exp_pays_21==-999


*Reduce variables with two equal medium levels from 4 to 3 dimensions
local vars dig_description1 dig_description2 dig_description3 
foreach var of local  vars {
	replace `var' = .5 if `var'==0.49 | `var'==0.51

}


replace dig_con6_score = 1 if dig_con6_score >0.98 & dig_con6_score<.
replace dig_presence_score =1 if dig_presence_score >0.98 & dig_presence_score<.



*Editing variable that come from digital stocktake
replace social_facebook=0 if social_facebook==.
local fb_vars facebook_likes facebook_subs facebook_reviews facebook_reviews facebook_shop
foreach var of local fb_vars {
replace `var' = 0 if social_facebook == 0
}

***********************************************************************
* 	PART 2: Correction mid-line
***********************************************************************


***********************************************************************
* 	PART 3: Correction end-line
***********************************************************************

***********************************************************************
* 	PART 4: Replacing missing values with zeros where applicable
***********************************************************************
*Definition of all variables that are being used in index calculation*
local allvars dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_score dig_presence_score dig_presence3_exscore dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_payment1 dig_payment2 dig_payment3 dig_vente dig_marketing_lien dig_marketing_ind1 dig_marketing_ind2 dig_marketing_score dig_logistique_entrepot dig_logistique_retour_score dig_service_responsable dig_service_satisfaction expprep_cible expprep_norme expprep_demande exp_pays_avg exp_per dig_description1 dig_description2 dig_description3 dig_mar_res_per dig_ser_res_per exp_prep_res_per

*IMPORTANT MODIFICATION: Missing values, Don't know, refuse or needs check answers are being transformed to zeros 
*because missing values or "I don't know" in practice-related variable 
*are mostly due to the fact that the company did not get to fill out this part 
*of the survey because they were screened out for this section 
*or if they don't know whether they are having a particular business practice it is quite probable that they dont perform it


foreach var of local  allvars {
	replace `var' = 0 if `var' == .
	replace `var' = 0 if `var' == -999
	replace `var' = 0 if `var' == -888
	replace `var' = 0 if `var' == -777
	replace `var' = 0 if `var' == -1998
	replace `var' = 0 if `var' == -1776 
	replace `var' = 0 if `var' == -1554
}


save "${master_intermediate}/ecommerce_master_inter", replace
