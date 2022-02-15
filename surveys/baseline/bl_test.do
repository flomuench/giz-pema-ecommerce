***********************************************************************
* 			e-commerce baseline survey logical tests                  *	
***********************************************************************
*																	    
*	PURPOSE: Check that answers make logical sense			  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Preamble
* 	2) 		Define logical tests
*	2.1) 	Tests for accounting
*	2.1) 	Tests for indices	
*   3) Check missing values								  															      
*	Author:  	Teo Firpo							  
*	ID variable: 	id_plateforme (example: f101)			  					  
*	Requires: bl_inter.dta 	  								  
*	Creates:  fiche_correction.xls			                          
*																	  
***********************************************************************
* 	PART 1:  Load data	  		
***********************************************************************
	 
use "${bl_intermediate}/bl_inter", clear

***********************************************************************
* 	PART 2:  Define logical tests
***********************************************************************

/* --------------------------------------------------------------------
	PART 2.1: Comptabilité / accounting questions
----------------------------------------------------------------------*/		

* If any of the accounting vars corresponds to the scalars (not_know: -999 ; refused: -888; or check_again = -777) change needs_check to 2

local accountvars investcom_2021 investcom_futur expprep_responsable exp_pays_avant21 exp_pays_21 compexp_2020 comp_ca2020 comp_benefice2020 dig_revenues_ecom car_carempl_div1 car_carempl_dive2 car_carempl_div3 car_adop_peer

// generate a variable that highlights this (to be used later)
gen scalar_issue = 0

foreach var of local accountvars {
	replace needs_check = 2 if `var' == -999 
	replace scalar_issue = 1 if `var' ==  -999
	replace questions_needing_checks = " | `var' pas connue & " + questions_needing_checks if `var' == -999 

	replace needs_check = 2 if `var' == -888 
	replace scalar_issue = 1 if `var' == -888
	replace questions_needing_checks = " | `var' refusée & " + questions_needing_checks if `var' == -888 
	
	replace needs_check = 2 if `var' == -777 
	replace scalar_issue = 1 if `var' == -777
	replace questions_needing_checks = " | `var' doit être verifiée & " + questions_needing_checks if `var' == -777 

}

* If profits are larger than 'chiffres d'affaires' need to check: 
 
replace needs_check = 3 if comp_benefice2020>comp_ca2020 & comp_ca2020!=. & comp_benefice2020!=. & scalar_issue==0
replace questions_needing_checks = questions_needing_checks + " | Benefices sont plus élevés que comptes d'affaires" if comp_benefice2020>comp_ca2020 & comp_ca2020!=. & comp_benefice2020!=. & scalar_issue==0

* Check if export values are larger than total revenues 

replace needs_check = 3 if comp_ca2020< compexp_2020 & comp_ca2020!=. & compexp_2020!=. & scalar_issue==0
replace questions_needing_checks = questions_needing_checks +  " | Export sont plus élevés que comptes d'affaires" if comp_ca2020< compexp_2020 & comp_ca2020!=. & compexp_2020!=. & scalar_issue==0

* Check if online revenu is higher than overall revenue

capture replace needs_check = 3 if  comp_ca2020 < dig_revenues_ecom & dig_revenues_ecom!=. & comp_ca2020!=. & scalar_issue==0
capture replace questions_needing_checks = questions_needing_checks +  " | Revenues en ligne sont plus élevés que comptes d'affaires" if  comp_ca2020 < dig_revenues_ecom & dig_revenues_ecom!=. & comp_ca2020!=. & scalar_issue==0

* If number of export countries is higher than 100 – needs check (it's sus)

capture replace needs_check = 3 if  exp_pays_avant21 > 100 & exp_pays_avant21!=. & rg_oper_exp == 1
//capture replace needs_check = 1 if exp_pays_avant21==. &  rg_oper_exp == 1 & exp_pays>1
capture replace questions_needing_checks = questions_needing_checks +  " | Vérifer nombre de pays dans exp_pays_avant21" if  exp_pays_avant21 > 100 & exp_pays_avant21!=. & rg_oper_exp == 1

capture replace needs_check = 3 if  exp_pays_21 > 100 & exp_pays_21!=. & rg_oper_exp == 1
capture replace questions_needing_checks = questions_needing_checks +  " | Vérifer nombre de pays dans exp_pays_21" if  exp_pays_21 > 100 & exp_pays_21!=. & rg_oper_exp == 1



/* --------------------------------------------------------------------
	PART 2.2: Indices / questions with points
----------------------------------------------------------------------*/		


replace needs_check = 3 if dig_presence_score==.
replace questions_needing_checks = questions_needing_checks + " | dig_presence manque " if dig_presence_score==.

local unit_scores dig_presence_score dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_payment1 dig_payment2 dig_payment3 dig_vente dig_marketing_lien dig_marketing_score dig_marketing_ind1 dig_marketing_ind2 dig_logistique_entrepot dig_logistique_retour_score dig_service_satisfaction expprep_cible expprep_norme rg_oper_exp exp_afrique 

foreach var of local unit_scores {
	replace needs_check = 1 if `var'>1 & `var'!=.
	replace questions_needing_checks = questions_needing_checks + " | `var' too high" if `var'>1 & `var'!=.
	
	replace needs_check = 1 if `var'<0 & `var'!=-999  & `var'!=-888 & `var'!=-777
	replace questions_needing_checks = questions_needing_checks + " | `var' too low" if `var'<0 & `var'!=-999  & `var'!=-888 & `var'!=-777

} 

local cont_vars dig_marketing_respons dig_service_responsable expprep_responsable exp_pays_avant21 exp_pays_21

foreach var of local cont_vars {

	replace needs_check = 1 if `var'<0 & `var'!=-999 & `var'!=-888 & `var'!=-777
	replace questions_needing_checks = questions_needing_checks + " | `var' too low" if `var'<0 & `var'!=-999 & `var'!=-888 & `var'!=-777

} 

***********************************************************************
* 	PART 3:  Check for missing values
***********************************************************************

	* Variables with internal logic:
	
replace needs_check = 3 if investcom_2021 == . & dig_presence_score>0
replace questions_needing_checks = questions_needing_checks +  " | investcom_2021 manque" if investcom_2021 == . & dig_presence_score>0
replace needs_check = 3 if investcom_futur == . & dig_presence_score>0
replace questions_needing_checks = questions_needing_checks +  " | investcom_futur manque" if investcom_futur == . & dig_presence_score>0
replace needs_check = 3 if compexp_2020==. & rg_oper_exp==1
replace questions_needing_checks = questions_needing_checks +  " | compexp_2020 manque" if compexp_2020==. & rg_oper_exp==1

replace needs_check = 3 if dig_revenues_ecom==. & dig_presence_score>0
replace questions_needing_checks = questions_needing_checks +  " | dig_revenues_ecom manque" if dig_revenues_ecom==. & dig_presence_score>0

replace needs_check = 3 if dig_con2==. & dig_con1==1
replace questions_needing_checks = questions_needing_checks +  " | dig_con2 manque" if dig_con2==. & dig_con1==1

replace needs_check = 3 if dig_con4==. & dig_con3==1
replace questions_needing_checks = questions_needing_checks +  " | dig_con4 manque"  if dig_con4==. & dig_con3==1

replace needs_check = 3 if dig_presence3_exscore==. & dig_presence3==0.33
replace questions_needing_checks = questions_needing_checks +  " | Aucune réponse aux exemples dig_presence3" if dig_presence3_exscore==. & dig_presence3==0.33 

//replace needs_check = 1 if ==. &
//replace questions_needing_checks = questions_needing_checks +  " | " 

	* Now all closed variables without a logic (ie don't require other answers to be true)

local closed_vars entr_bien_service dig_con1 dig_con3 dig_presence1 dig_presence2 dig_presence3 expprep_responsable  car_carempl_div1 car_carempl_dive2 car_carempl_div3 car_adop_peer

foreach var of local closed_vars {
	capture replace needs_check = 1 if `var' == . 
	capture replace questions_needing_checks = questions_needing_checks + " | `var' manque" if `var' == . 
}


foreach var of varlist comp_ca2020 comp_benefice2020   {
	capture replace needs_check = 3 if `var' ==.
	capture replace questions_needing_checks = questions_needing_checks + " | `var' manque" if `var' == . 
}


drop scalar_issue


***********************************************************************
* 	PART 4:  Cross checks again registration data
***********************************************************************

// check using export2017-2021 
// check 'produit exportable'
// compare car_carempl_div1 to fte_femmes

***********************************************************************
* 	PART 5:  Export fiche correction and save as final
***********************************************************************

***********************************************************************
* 	Export an excel sheet with needs_check variables  			
***********************************************************************

capture drop dup

sort id_plateforme, stable

quietly by id_plateforme:  gen dup = cond(_N==1,0,_n)

replace needs_check = 1 if dup>0

gen commentaires_ElAmouri = 0

cd "$bl_checks"

order commentaires_ElAmouri id_plateforme commentsmsb 

export excel commentaires_ElAmouri id_plateforme commentsmsb needs_check questions_needing_check heure date-dig_logistique_retour_score using "fiche_correction" if needs_check>0, firstrow(variables) replace


	* Save as final

drop export2017 export2018  export2019  export2020 export2021 attest attest2 acceptezvousdevalidervosré acceptezvousenregistrement ident_nom orienter_ ident_nom_correct_entreprise qsinonident as aq complete needs_check questions_needing_checks commentsmsb

cd "$bl_final"

save "bl_final", replace


