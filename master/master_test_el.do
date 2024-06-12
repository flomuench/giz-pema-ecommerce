***********************************************************************
* 			Ecommerce endline logical tests            	              *	
***********************************************************************
*																	    
*	PURPOSE: Check that answers make logical sense			  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Load data & generate check variables
* 	2) 		Define logical tests
*	2.1) 	Firm and product questions
*	2.2) 	Digital Technology Adoption
*	2.3)	Marketing & Communication
*	2.4)	Export Questions
*	2.5)	Accounting Questions
*   3) 		large Outliers	(absolute, cross-sectional values)	
*	4)		large Outliers	(normalized)		
*   5) 		Growth rate in accounting variables
*	6)		Variable has been tagged as "needs_check" = 888, 777 or .
*	7)		Main product and unit
*	8)		Remove firms from needs_check in case calling them again did not solve the issue	
*	9)		Export an excel sheet with needs_check variables  
*	10)		Reset check variables & define logical tests
*	11)		Export an excel sheet for no answers & outliers
*						  															      
*	Author:  	Ayoub Chamakhi		
*	ID variable: 	id_plateforme (example: 101)			  					  
*	Requires: aqe_database_inter.dta	  								  
*	Creates:  fiche_correction.xls			                          
*																	  
***********************************************************************
* 	PART 1:  Load data & generate check variables 		
***********************************************************************

use "${master_final}/ecommerce_master_final", clear

drop needs_check
gen needs_check = 0
lab var needs_check "logical test to be checked by El Amouri"

gen questions_needing_checks  = ""
lab var questions_needing_checks "questions to be checked by El Amouri"

***********************************************************************
* 	PART 2:  Define logical tests
***********************************************************************
/* --------------------------------------------------------------------
	PART 2.1: Firm and product questions
----------------------------------------------------------------------*/	
	*any sub employee category more than the category itself
local empl_vars "car_carempl_div1 car_carempl_div2 car_carempl_div3"

foreach var of local empl_vars {
	replace needs_check = 1 if `var' > fte & surveyround == 3
	replace questions_needing_checks = questions_needing_checks + "`var' plus grand que nombre total d'employés / " if `var' > fte & surveyround == 3
}
/* --------------------------------------------------------------------
	PART 2.2: Digital Technology Adoption
----------------------------------------------------------------------*/
local dig_updates "dig_miseajour1 dig_miseajour2 dig_miseajour3"

*digital update
	*has digital employees but does not do any kind of updates
foreach var of local dig_updates {
	replace needs_check = 1 if surveyround == 3 & `var' == 1 & dig_empl == 0 & dig_empl != 666 & dig_empl != 777 & dig_empl != 888 & dig_empl != 999 & dig_empl != .
	replace questions_needing_checks = questions_needing_checks + "L'entreprise utilise `var' alors qu'elle n'a pas d'employés en marketing digital / " if surveyround == 3 & `var' == 1 ///
		& dig_empl == 0 & dig_empl != 666 & dig_empl != 777 & dig_empl != 888 & dig_empl != 999 & dig_empl != .
}

	*invests in digital marketing but does not do any updates
foreach var of local dig_updates {
	replace needs_check = 1 if surveyround == 3 & `var' == 1 & dig_invest == 0 & dig_invest != 666 & dig_invest != 777 & dig_invest != 888 & dig_invest != 999 & dig_invest != .
	replace questions_needing_checks = questions_needing_checks + "L'entreprise utilise `var' alors qu'elle n'investie pas en marketing digital / " if surveyround == 3 & `var' == 1 & dig_invest == 0 ///
		& dig_invest != 666 & dig_invest != 777 & dig_invest != 888 & dig_invest != 999 & dig_invest != .
}

/* --------------------------------------------------------------------
	PART 2.3: Marketing & Communication
----------------------------------------------------------------------*/
local dig_marketing "mark_online2 mark_online4"
*online marketing
	*uses marketing tools but does not have any digital employees
foreach var of local dig_marketing {
	replace needs_check = 1 if surveyround == 3 & `var' == 1 & dig_empl == 0 & dig_empl != 666 & dig_empl != 777 & dig_empl != 888 & dig_empl != 999 & dig_empl != .
	replace questions_needing_checks = questions_needing_checks + "L'entreprise n'a pas d'employés digital mais elle fait `var' / " if surveyround == 3 & `var' == 1 & dig_empl == 0 ///
		& dig_empl != 666 & dig_empl != 777 & dig_empl != 888 & dig_empl != 999 & dig_empl != .
}

	*uses marketing tools but does not invest in digital marketing
foreach var of local dig_marketing {
	replace needs_check = 1 if surveyround == 3 & `var' == 1 & dig_invest == 0 & dig_invest != 666 & dig_invest != 777 & dig_invest != 888 & dig_invest != 999 & dig_invest != .
	replace questions_needing_checks = questions_needing_checks + "L'entreprise n'investie pas dans le marketing digital mais elle fait `var' / " if surveyround == 3 & `var' == 1 & dig_invest == 0 ///
		& dig_invest != 666 & dig_invest != 777 & dig_invest != 888 & dig_invest != 999 & dig_invest != .
}

/* --------------------------------------------------------------------
	PART 2.4: Export Questions
----------------------------------------------------------------------*/
	* Countries & Number of multinationals
replace needs_check = 1 if dig_presence1 != 1 & dig_presence2 != 1 & dig_presence3 != 1 & export_1 == 1 & exp_dig == 1 & surveyround == 3
replace questions_needing_checks = questions_needing_checks + "L'entreprise exporte grace à ses plateformes enligne mais n'a pas de presence en ligne / " if dig_presence1 != 1 & dig_presence2 != 1 ///
	& dig_presence3 != 1 & export_1 == 1 & exp_dig == 1 & surveyround == 3

/* --------------------------------------------- -----------------------
	PART 2.6: Accounting Questions
----------------------------------------------------------------------*/		
	*mistake in matricule fiscale
gen check_matricule = 1
replace check_matricule = 0 if ustrregexm(q29, "^[0-9]{7}[a-zA-Z]$") == 1

replace needs_check = 1 if check_matricule == 1 & surveyround == 3 & matricule_miss  == 1
replace questions_needing_checks = questions_needing_checks + "matricule fiscale n'est pas conforme à la norme / " if check_matricule == 1 & surveyround == 3 & matricule_miss  == 1

	* turnover zero
local accountvars comp_ca2023 comp_ca2024
foreach var of local accountvars {
		* = 0
	replace needs_check = 1 if surveyround == 3 & `var' == 0 
	replace questions_needing_checks = questions_needing_checks + "`var' est rare d'être zero, êtes vous sure? / " if surveyround == 3 & `var' == 0 
	
}

	* turnover export zero even though it exports
local accountexpvars compexp_2023 compexp_2024
foreach var of local accountexpvars {
		* = 0
	replace needs_check = 1 if surveyround == 3 & `var' == 0 & export_1 == 1 & export_2 == 1
	replace questions_needing_checks = questions_needing_checks + "`var' est zero alors qu'elle exporte, êtes vous sure? / " if surveyround == 3 & `var' == 0  & export_1 == 1 & export_2 == 1
	
}	

	*Company does not export but has ca export
	
replace needs_check = 1 if (compexp_2023 > 0 | compexp_2024 > 0 ) & surveyround == 3 & export_1 == 0 & export_2 == 0 & compexp_2023 != 666 & compexp_2023 != 777 & compexp_2023 != 888 & compexp_2023 != 999 & compexp_2023 != . & compexp_2023 != 1234 & compexp_2024 != 666 & compexp_2024 != 777  & compexp_2024 != 888  & compexp_2024 != 999 & compexp_2024 != . & compexp_2024 != 1234
replace questions_needing_checks = questions_needing_checks + "L'entreprise n'export pas alors qu'elle a ca export / " if (compexp_2023 > 0 | compexp_2024 > 0 ) & surveyround == 3 & export_1 == 0 & export_2 == 0 & compexp_2023 != 666 & compexp_2023 != 777 & compexp_2023 != 888 & compexp_2023 != 999 & compexp_2023 != . & compexp_2023 != 1234 & compexp_2024 != 666 & compexp_2024 != 777  & compexp_2024 != 888  & compexp_2024 != 999 & compexp_2024 != . & compexp_2024 != 1234
	
	* Profits > sales 2023

replace needs_check = 1 if surveyround == 3 & comp_benefice2023 > comp_ca2023 & comp_benefice2023 != 666 & comp_benefice2023 != 777 & comp_benefice2023 != 888 & comp_benefice2023 != 999 & comp_benefice2023 != 1234 & comp_benefice2023 != . ///
	& comp_benefice2023 != 0 & comp_ca2023 != 666 & comp_ca2023 != 777 & comp_ca2023 != 888 & comp_ca2023 != 999 & comp_ca2023 != . & comp_ca2023 != 0 & comp_ca2023 != 1234 & profit_2023_category_perte!=1 & profit_2023_category_perte!=2 & profit_2023_category_perte!=3 & profit_2023_category_perte!=4 & profit_2023_category_perte!=5 & profit_2023_category_gain!=1 & profit_2023_category_gain!=2 & profit_2023_category_gain!=3 & profit_2023_category_gain!=4 & profit_2023_category_gain!=5 
replace questions_needing_checks = questions_needing_checks + "Benefices sont plus élevés que CA 2023 / "  if surveyround == 3 & comp_benefice2023 > comp_ca2023 & comp_benefice2023 != 666 & comp_benefice2023 != 777 & comp_benefice2023 != 888 & 	  comp_benefice2023 != 999 & comp_benefice2023 != 1234 & comp_benefice2023 != . & comp_benefice2023 != 0 & comp_ca2023 != 666 & comp_ca2023 != 777 & comp_ca2023 != 888 & comp_ca2023 != 999 & comp_ca2023 != . & comp_ca2023 != 0 & comp_ca2023 != 1234 & profit_2023_category_perte!=1 & profit_2023_category_perte!=2 & profit_2023_category_perte!=3 & profit_2023_category_perte!=4 & profit_2023_category_perte!=5 & profit_2023_category_gain!=1 & profit_2023_category_gain!=2 & profit_2023_category_gain!=3 & profit_2023_category_gain!=4 & profit_2023_category_gain!=5 

	* Profits > sales 2024
	
replace needs_check = 1 if surveyround == 3 & comp_benefice2024 > comp_ca2024 & comp_ca2024 != 666 & comp_ca2024 != 777 & comp_ca2024 != 888 & comp_ca2024 != 999 & comp_ca2024 != . & comp_ca2024 != 0 & comp_ca2024 != 1234 & ///
	comp_benefice2024 != 666 & comp_benefice2024 != 777  & comp_benefice2024 != 888  & comp_benefice2024 != 999 & comp_benefice2024 != . & comp_benefice2024 != 0 & comp_benefice2024 != 1234 & profit_2024_category_perte!=1 & profit_2024_category_perte!=2 & profit_2024_category_perte!=3 & profit_2024_category_perte!=4 & profit_2024_category_perte!=5 & profit_2024_category_gain!=1 & profit_2024_category_gain!=2 & profit_2024_category_gain!=3 & profit_2024_category_gain!=4 & profit_2024_category_gain!=5 

replace questions_needing_checks = questions_needing_checks + "Benefices sont plus élevés que CA 2024 / " if surveyround == 3 & comp_benefice2024 > comp_ca2024 & comp_ca2024 != 666 & comp_ca2024 != 777 & comp_ca2024 != 888 & comp_ca2024 != 999 & comp_ca2024 != . & comp_ca2024 != 0 & comp_ca2024 != 1234 & comp_benefice2024 != 666 & comp_benefice2024 != 777  & comp_benefice2024 != 888  & comp_benefice2024 != 999 & comp_benefice2024 != . & comp_benefice2024 != 0 & comp_benefice2024 != 1234 & profit_2024_category_perte!=1 & profit_2024_category_perte!=2 & profit_2024_category_perte!=3 & profit_2024_category_perte!=4 & profit_2024_category_perte!=5 & profit_2024_category_gain!=1 & profit_2024_category_gain!=2 & profit_2024_category_gain!=3 & profit_2024_category_gain!=4 & profit_2024_category_gain!=5 


	* Outliers/extreme values: Very low values
		* ca2023 just above zero
	
replace needs_check = 1 if surveyround == 3 & comp_ca2023 < 5000 & comp_ca2023 != 666 & comp_ca2023 != 777 & comp_ca2023 != 888 & comp_ca2023 != 999 & comp_ca2023 != . & comp_ca2023 != 0 & comp_ca2023 != 1234
replace questions_needing_checks = questions_needing_checks + "CA 2023 moins que 5000 TND, êtes vous sure? / " if surveyround == 3 & comp_ca2023 < 5000 & comp_ca2023 != 666 & comp_ca2023 != 777 ///
	& comp_ca2023 != 888 & comp_ca2023 != 999 & comp_ca2023 != . & comp_ca2023 != 0 & comp_ca2023 != 1234

		* ca2024 just above zero

replace needs_check = 1 if surveyround == 3 & comp_ca2024 < 5000 & comp_ca2024 != 666 & comp_ca2024 != 777 & comp_ca2024 != 888 & comp_ca2024 != 999 & comp_ca2024 != . & comp_ca2024 != 0 & comp_ca2024 != 1234
replace questions_needing_checks = questions_needing_checks + "CA 2024 moins que 5000 TND, êtes vous sure? / " if surveyround == 3 & comp_ca2024 < 5000 ///
	& comp_ca2024 != 666 & comp_ca2024 != 777 & comp_ca2024 != 888 & comp_ca2024 != 999 & comp_ca2024 != . & comp_ca2024 != 0 & comp_ca2024 != 1234
	
		*compexp_2023  just above zero
replace needs_check = 1 if surveyround == 3 & compexp_2023 < 5000 & compexp_2023 != 666 & compexp_2023 != 777 & compexp_2023 != 888 & compexp_2023 != 999 & compexp_2023 != . & compexp_2023 != 0 & compexp_2023 != 1234
replace questions_needing_checks = questions_needing_checks + "CA export 2023 moins que 5000 TND, êtes vous sure? / " if surveyround == 3 & compexp_2023 < 5000 & compexp_2023 != 666 & compexp_2023 != 777 ///
	& compexp_2023 != 888 & compexp_2023 != 999 & compexp_2023 != . & compexp_2023 != 0 & compexp_2023 != 1234
	
		*compexp_2024  just above zero
replace needs_check = 1 if surveyround == 3 & compexp_2024 < 5000 & compexp_2024 != 666 & compexp_2024 != 777 & compexp_2024 != 888 & compexp_2024 != 999 & compexp_2024 != . & compexp_2024 != 0 & compexp_2024 != 1234
replace questions_needing_checks = questions_needing_checks + "CA export 2024 moins que 5000 TND, êtes vous sure? / " if surveyround == 3 & compexp_2024 < 5000 & compexp_2024 != 666 & compexp_2024 != 777 ///
	& compexp_2024 != 888 & compexp_2024 != 999 & compexp_2024 != . & compexp_2024 != 0 & compexp_2024 != 1234

		* profit2023 just above zero

replace needs_check = 1 if surveyround == 3 & comp_benefice2023 < 2500 & comp_benefice2023 != 666 & comp_benefice2023 != 777 & comp_benefice2023 != 888 ///
	& comp_benefice2023 != 999 & comp_benefice2023 != . & comp_benefice2023 > 0 & comp_benefice2023 != 1234 
replace questions_needing_checks = questions_needing_checks + "Benefice 2023 moins que 2500 TND / " if surveyround == 3 & comp_benefice2023 < 2500 ///
	& comp_benefice2023 != 666 & comp_benefice2023 != 777 & comp_benefice2023 != 888 & comp_benefice2023 != 999 & comp_benefice2023 != . & comp_benefice2023 > 0 & comp_benefice2023 != 1234 

		* profit2024 just above zero

replace needs_check = 1 if surveyround == 3 & comp_benefice2024 < 2500 & comp_benefice2024 != 666 & comp_benefice2024 != 777 & comp_benefice2024 != 888 ///
	& comp_benefice2024 != 999 & comp_benefice2024 != . & comp_benefice2024 > 0 & comp_benefice2024 != 1234
replace questions_needing_checks = questions_needing_checks + "benefice 2024 moins que 2500 TND / " if surveyround == 3 & comp_benefice2024 < 2500 ///
	& comp_benefice2024 != 666 & comp_benefice2024 != 777 & comp_benefice2024 != 888 & comp_benefice2024 != 999 & comp_benefice2024 != . & comp_benefice2024 > 0 & comp_benefice2024 != 1234


		* profit2023 just below zero
				
replace needs_check = 1 if surveyround == 3 & comp_benefice2023 > -2500 & comp_benefice2023 < 0  & comp_benefice2023 != . & comp_benefice2023 != 1234 & comp_benefice2023 != 0
replace questions_needing_checks = questions_needing_checks + "benefice 2023 + que -2500 TND mais - que zero / " if surveyround == 3 & comp_benefice2023 > -2500 ///
	& comp_benefice2023 < 0  & comp_benefice2023 != . & comp_benefice2023 != 1234 & comp_benefice2023 != 0

		* profit2024 just below zero
				
replace needs_check = 1 if surveyround == 3 & comp_benefice2024 > -2500 & comp_benefice2024 < 0  & comp_benefice2024 != . & comp_benefice2024 != 1234 & comp_benefice2024 != 0
replace questions_needing_checks = questions_needing_checks + "benefice 2024 + que -2500 TND mais - que zero / " if surveyround == 3 & comp_benefice2024 > -2500 & comp_benefice2024 < 0 ///
	& comp_benefice2024 != . & comp_benefice2024 != 1234 & comp_benefice2024 != 0

		*profit 2023 very big value
replace needs_check = 1 if surveyround == 3 & comp_benefice2023 > 1000000 & comp_benefice2023 != . & profit_2023_category_perte!=1 & profit_2023_category_perte!=2 & profit_2023_category_perte!=3 & profit_2023_category_perte!=4 & profit_2023_category_perte!=5 & profit_2023_category_gain!=1 & profit_2023_category_gain!=2 & profit_2023_category_gain!=3 & profit_2023_category_gain!=4 & profit_2023_category_gain!=5 

replace questions_needing_checks = questions_needing_checks + "Profit 2023 trop grand, supérieur à 1 millions de dinars / " if surveyround == 3 & comp_benefice2023 > 1000000 & comp_benefice2023 != . & profit_2023_category_perte!=1 & profit_2023_category_perte!=2 & profit_2023_category_perte!=3 & profit_2023_category_perte!=4 & profit_2023_category_perte!=5 & profit_2023_category_gain!=1 & profit_2023_category_gain!=2 & profit_2023_category_gain!=3 & profit_2023_category_gain!=4 & profit_2023_category_gain!=5 



		*profit2024 very big value
				
replace needs_check = 1 if surveyround == 3 & comp_benefice2024 > 1000000 & comp_benefice2024 != . & profit_2024_category_perte!=1 & profit_2024_category_perte!=2 & profit_2024_category_perte!=3 & profit_2024_category_perte!=4 & profit_2024_category_perte!=5 & profit_2024_category_gain!=1 & profit_2024_category_gain!=2 & profit_2024_category_gain!=3 & profit_2024_category_gain!=4 & profit_2024_category_gain!=5 

replace questions_needing_checks = questions_needing_checks + "Profit 2024 trop grand, supérieur à 1 millions de dinars / " if surveyround == 3 & comp_benefice2024 > 1000000 & comp_benefice2024 != . & profit_2024_category_perte!=1 & profit_2024_category_perte!=2 & profit_2024_category_perte!=3 & profit_2024_category_perte!=4 & profit_2024_category_perte!=5 & profit_2024_category_gain!=1 & profit_2024_category_gain!=2 & profit_2024_category_gain!=3 & profit_2024_category_gain!=4 & profit_2024_category_gain!=5 

	*invest > CA
local invest_vars "mark_invest dig_invest"

foreach var of local invest_vars {
	replace needs_check = 1 if `var' > (comp_ca2023 + comp_ca2024) & `var' != 666 & `var' != 777 & `var' != 888 & `var' != 999 & `var' != 1234 & `var' != 0 & `var' != . & comp_ca2023 != 666 & comp_ca2023 != 777 & comp_ca2023 != 888 & comp_ca2023 != 999 & comp_ca2023 != 1234 & comp_ca2023 != 0 & comp_ca2023 != . & comp_ca2024 != 666 & comp_ca2024 != 777 & comp_ca2024 != 888 & comp_ca2024 != 999 & comp_ca2024 != 1234 & comp_ca2024 != 0 & comp_ca2024 != . 
	replace questions_needing_checks = questions_needing_checks + "`var' plus grand que CA2023 + CA2024 / " if `var' > (comp_ca2023 + comp_ca2024) & `var' != 666 & `var' != 777 & `var' != 888 & `var' != 999 & `var' != 1234 & `var' != 0 & `var' != . & comp_ca2023 != 666 & comp_ca2023 != 777 & comp_ca2023 != 888 & comp_ca2023 != 999 & comp_ca2023 != 1234 & comp_ca2023 != 0 & comp_ca2023 != . & comp_ca2024 != 666 & comp_ca2024 != 777 & comp_ca2024 != 888 & comp_ca2024 != 999 & comp_ca2024 != 1234 & comp_ca2024 != 0 & comp_ca2024 != . 
}

	*CA very big values
local ca_vars "comp_ca2023 comp_ca2024 compexp_2023 compexp_2024"
foreach var of local ca_vars {
	replace needs_check = 1 if surveyround == 3 & `var' > 2500000 & `var' != .
	replace questions_needing_checks = questions_needing_checks + "`var' supérieur à 2.5 millions de dinars de dinars / " if surveyround == 3 & `var' > 2500000 & `var' != .
}	

	*invest very big values
local compta_vars "mark_invest dig_invest"
foreach var of local compta_vars {
	replace needs_check = 1 if surveyround == 3 & `var' > 750000 & `var' != .
	replace questions_needing_checks = questions_needing_checks + "`var' supérieur à 750000 de dinars / " if surveyround == 3 & `var' > 750000 & `var' != .
}	

		*comptability vars that should not be 1234
local not1234_vars "comp_ca2023 comp_ca2024 compexp_2023 compexp_2024 mark_invest dig_invest"

foreach var of local not1234_vars {
	replace needs_check = 1 if `var' == 1234 & surveyround == 3
	replace questions_needing_checks = questions_needing_checks + "Les intervalles utilisés `var' ne sont possible que pour le profit / " if `var' == 1234 & surveyround == 3
}
***********************************************************************
* 	Part 3: Cross-checking answers from baseline & midline		
***********************************************************************
*manual thresholds at 95% (Only 1 surveyround value: 2020)
	*turnover total

local turnover_vars "comp_ca2023 comp_ca2024"

foreach var of local turnover_vars {
	sum comp_ca2020, d
	replace needs_check = 1 if `var' != . & surveyround == 3 & `var' > r(p95)
	replace questions_needing_checks = questions_needing_checks + "`var' très grand par rapport aux dernières vagues, êtes vous sure? / " if `var' != . & surveyround == 3 & `var' > r(p95)

}

	*turnover export
local turnoverexp_vars "compexp_2023 compexp_2024"

foreach var of local turnoverexp_vars {
	sum compexp_2020, d
	replace needs_check = 1 if `var' != . & surveyround == 3 & `var' > r(p95)
	replace questions_needing_checks = questions_needing_checks + "`var' très grand par rapport aux dernières vagues, êtes vous sure? / " if `var' != . & surveyround == 3 & `var' > r(p95)
}

	*profit
local profit_vars "comp_benefice2023 comp_benefice2024"

foreach var of local profit_vars {
	sum comp_benefice2020, d
	replace needs_check = 1 if `var' != . & surveyround == 3 & `var' >  r(p95) 
	replace questions_needing_checks = questions_needing_checks + "`var' très grand par rapport aux dernières vagues, êtes vous sure? / " if `var' != . & surveyround == 3 & `var' > r(p95) 
}	

	*employees
local fte_surveyround "surveyround==1 surveyround==2"
scalar maxm_p95 = 0

foreach var of local fte_surveyround {
    sum fte if `var', detail
    if r(p95) > maxm_p95 {
		scalar drop maxm_p95
		scalar maxm_p95 = r(p95)
		di maxm_p95
	}
}


replace needs_check = 1 if fte != . & surveyround == 3 & fte > maxm_p95
replace questions_needing_checks = questions_needing_checks + "employés très grand par rapport aux dernières vagues, êtes vous sure? / " if fte != . & surveyround == 3 & fte > maxm_p95

*employees femmes
local fte_surveyround "surveyround==1 surveyround==2"
scalar maxf_p95 = 0

foreach var of local fte_surveyround {
    sum car_carempl_div1 if `var', detail
    if r(p95) > maxf_p95 {
		scalar drop maxf_p95
		scalar maxf_p95 = r(p95)
		di maxf_p95
	}
}

replace needs_check = 1 if car_carempl_div1 != . & surveyround == 3 & car_carempl_div1 > maxm_p95
replace questions_needing_checks = questions_needing_checks + "employés femmes très grand par rapport aux dernières vagues, êtes vous sure? / " if car_carempl_div1 != . & surveyround == 3 & car_carempl_div1 > maxm_p95

***********************************************************************
* 	PART 4: Variable has been tagged as "needs_check" = 888, 777 or .
***********************************************************************
/*
local test_vars "fte dig_empl mark_invest dig_invest comp_ca2023 comp_ca2024 compexp_2023 compexp_2024 comp_benefice2023 comp_benefice2024"
foreach var of local test_vars {
	replace needs_check = 1 if `var' == 888 & surveyround == 3
	replace questions_needing_checks = questions_needing_checks + "`var' = 888, êtes vous sure? / " if `var' == 888 & surveyround == 3
	replace needs_check = 1 if `var' == 777 & surveyround == 3
	replace questions_needing_checks = questions_needing_checks + "`var' = 777, êtes vous sure? / " if `var' == 777 & surveyround == 3
	replace needs_check = 1 if `var' == 999 & surveyround == 3
	replace questions_needing_checks = questions_needing_checks + "`var' = 999, êtes vous sure? / " if `var' == 999 & surveyround == 3
	replace needs_check = 1 if `var' == . & surveyround == 3 & exporter == 1
	replace questions_needing_checks = questions_needing_checks + "`var' = missing, êtes vous sure? / " if `var' == . & surveyround == 3 & exporter == 1
}
*/

*tackling problematique answer codes
		*666
local compta_vars "mark_invest dig_invest comp_ca2023 comp_ca2024 compexp_2023 compexp_2024 comp_benefice2023 comp_benefice2024"
foreach var of local compta_vars {
	
	replace needs_check = 1 if surveyround == 3 & `var' == 666
	replace questions_needing_checks = questions_needing_checks + "`var' est 666, il faut rappeler la personne responsable de la comptabilité. / " if surveyround == 3 & `var' == 666
	
}
		*777
local compta_vars "mark_invest dig_invest comp_ca2023 comp_ca2024 compexp_2023 compexp_2024 comp_benefice2023 comp_benefice2024"
foreach var of local compta_vars {
	
	replace needs_check = 1 if surveyround == 3 & `var' == 777
	replace questions_needing_checks = questions_needing_checks + "`var' est 777, Il faut réécouter l'appel / " if surveyround == 3 & `var' == 777
	
}
***********************************************************************
* 	PART 5:  Remove firms from needs_check in case calling them again did not solve the issue		
***********************************************************************
replace needs_check = 0 if id_plateforme == 909 & surveyround == 3 // ElAmouri rechecked the call & comptability logical when checking activity/website of company
replace questions_needing_check = "" if id_plateforme == 909 & surveyround == 3


replace needs_check = 0 if id_plateforme == 938 & surveyround == 3  // ElAmouri rechecked the call & comptability logical when checking activity/website of company
replace questions_needing_check = "" if id_plateforme == 938 & surveyround == 3


replace needs_check = 0 if id_plateforme == 773 & surveyround == 3  // Fixed comp_ca2023
replace questions_needing_check = "" if id_plateforme == 773 & surveyround == 3


replace needs_check = 0 if id_plateforme == 873 & surveyround == 3  // mark_online 3 is free / code fixed
replace questions_needing_check = "" if id_plateforme == 873 & surveyround == 3


replace needs_check = 0 if id_plateforme == 890 & surveyround == 3  // mark_online 1 is free / code fixed
replace questions_needing_check = "" if id_plateforme == 890 & surveyround == 3


replace needs_check = 0 if id_plateforme == 767 & surveyround == 3  // Will answer online
replace questions_needing_check = "" if id_plateforme == 767 & surveyround == 3


replace needs_check = 0 if id_plateforme == 825 & surveyround == 3  // mark_online 1 is free / code fixed
replace questions_needing_check = "" if id_plateforme == 825 & surveyround == 3


replace needs_check = 0 if id_plateforme == 483 & surveyround == 3  // dig_invest fixed
replace questions_needing_check = "" if id_plateforme == 483 & surveyround == 3

replace needs_check = 0 if id_plateforme == 650 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 650 & surveyround == 3


replace needs_check = 0 if id_plateforme == 381 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 381 & surveyround == 3


replace needs_check = 0 if id_plateforme == 457 & surveyround == 3 // Le montant du mark_dig est faible puisqu'on ne fait pas de ventes directes / vente en ligne. On a fait du sponsoring seulement deux fois. on est présent sur des plateformes seulement pour présenter les produits et l'entreprise. On ne fait pas trop de marketing digital dans notre entreprise
replace questions_needing_check = "" if id_plateforme == 457 & surveyround == 3


replace needs_check = 0 if id_plateforme == 237 & surveyround == 3 // ElAmouri a appelé l'entreprise
replace questions_needing_check = "" if id_plateforme == 237 & surveyround == 3


replace needs_check = 0 if id_plateforme == 541 & surveyround ==3 //Nous avons rappelé l'entreprise : dig_invest=0 mark online3= 1 : effort personnel
replace questions_needing_check = "" if id_plateforme == 541 & surveyround == 3


replace needs_check = 0 if id_plateforme == 478 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 478 & surveyround == 3


replace needs_check = 0 if id_plateforme == 466 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 466 & surveyround == 3


replace needs_check = 0 if id_plateforme == 519 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 519 & surveyround == 3


replace needs_check = 0 if id_plateforme == 600 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 600 & surveyround == 3


replace needs_check = 0 if id_plateforme == 602 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 602 & surveyround == 3


replace needs_check = 0 if id_plateforme == 604 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 604 & surveyround == 3


replace needs_check = 0 if id_plateforme == 323 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 323 & surveyround == 3


replace needs_check = 0 if id_plateforme == 144 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 144 & surveyround == 3


replace needs_check = 0 if id_plateforme == 805 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 805 & surveyround == 3


replace needs_check = 0 if id_plateforme == 655 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 655 & surveyround == 3


replace needs_check = 0 if id_plateforme == 337 & surveyround == 3  // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 337 & surveyround == 3


replace needs_check = 0 if id_plateforme == 488 & surveyround == 3  // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 488 & surveyround == 3


replace needs_check = 0 if id_plateforme == 453 & surveyround == 3  // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 453 & surveyround == 3


replace needs_check = 0 if id_plateforme == 270 & surveyround == 3  // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 270 & surveyround == 3


replace needs_check = 0 if id_plateforme == 183 & surveyround == 3  // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 183 & surveyround == 3


replace needs_check = 0 if id_plateforme == 352 & surveyround == 3  // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 352 & surveyround == 3


replace needs_check = 0 if id_plateforme == 311 & surveyround == 3  // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 311 & surveyround == 3


replace needs_check = 0 if id_plateforme == 679 & surveyround == 3  // l'entreprise sous-traite ses activités digitales à une agence
replace questions_needing_check = "" if id_plateforme == 679 & surveyround == 3


replace needs_check = 0 if id_plateforme == 91 & surveyround == 3   // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 91 & surveyround == 3

replace needs_check = 0 if id_plateforme == 846 & surveyround == 3   // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 846 & surveyround == 3


replace needs_check = 0 if id_plateforme == 511 & surveyround == 3   // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 511 & surveyround == 3


replace needs_check = 0 if id_plateforme == 511 & surveyround == 3   // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 511 & surveyround == 3


replace needs_check = 0 if id_plateforme == 547 & surveyround == 3   // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 547 & surveyround == 3


replace needs_check = 0 if id_plateforme == 581 & surveyround == 3   // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 581 & surveyround == 3


replace needs_check = 0 if id_plateforme == 398 & surveyround == 3   // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 398 & surveyround == 3


replace needs_check = 0 if id_plateforme == 443 & surveyround == 3   // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 443 & surveyround == 3

replace needs_check = 0 if id_plateforme == 58 & surveyround == 3   // ElAmouri called the company
replace questions_needing_check = "" if id_plateforme == 58 & surveyround == 3

replace needs_check = 0 if id_plateforme == 78 & surveyround == 3   // ElAmouri called the company
replace questions_needing_check = "" if id_plateforme == 78 & surveyround == 3

replace needs_check = 0 if id_plateforme == 95 & surveyround == 3   // ElAmouri called the company and the firm refused to give the accounting part
replace questions_needing_check = "" if id_plateforme == 95 & surveyround == 3

replace needs_check = 0 if id_plateforme == 105 & surveyround == 3   // ElAmouri called the company 
replace questions_needing_check = "" if id_plateforme == 105 & surveyround == 3

replace needs_check = 0 if id_plateforme == 148 & surveyround == 3   // ElAmouri called the company
replace questions_needing_check = "" if id_plateforme == 148 & surveyround == 3

replace needs_check = 0 if id_plateforme == 271 & surveyround == 3   // ElAmouri called the company
replace questions_needing_check = "" if id_plateforme == 271 & surveyround == 3

replace needs_check = 0 if id_plateforme == 356 & surveyround == 3   // ElAmouri called the company and the firm refused to give the accounting part
replace questions_needing_check = "" if id_plateforme == 356 & surveyround == 3

replace needs_check = 0 if id_plateforme == 365 & surveyround == 3   // ElAmouri called the company and zero for the turnover
replace questions_needing_check = "" if id_plateforme == 365 & surveyround == 3

replace needs_check = 0 if id_plateforme == 373 & surveyround == 3   // ElAmouri called the company and refused to answer
replace questions_needing_check = "" if id_plateforme == 373 & surveyround == 3

replace needs_check = 0 if id_plateforme == 392 & surveyround == 3   // ElAmouri called the company 
replace questions_needing_check = "" if id_plateforme == 392 & surveyround == 3

replace needs_check = 0 if id_plateforme == 405 & surveyround == 3   // ElAmouri called the company 
replace questions_needing_check = "" if id_plateforme == 405 & surveyround == 3

replace needs_check = 0 if id_plateforme == 527 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 527 & surveyround == 3

replace needs_check = 0 if id_plateforme == 695 & surveyround == 3 // ElAmouri rechecked the call
replace questions_needing_check = "" if id_plateforme == 695 & surveyround == 3

replace needs_check = 0 if id_plateforme == 899 & surveyround == 3 // ElAmouri called the company 
replace questions_needing_check = "" if id_plateforme == 899 & surveyround == 3

replace needs_check = 0 if id_plateforme == 959 & surveyround == 3 // ElAmouri called the company 
replace questions_needing_check = "" if id_plateforme == 959 & surveyround == 3

*extra cases (ElAmouri correction not enough)

replace needs_check = 1 if id_plateforme == 896 & surveyround == 3
replace questions_needing_check = questions_needing_check + "Profit plus grand que chiffre d'affaire qui est declaré 0 / " if id_plateforme == 896 & surveyround == 3

replace needs_check = 1 if id_plateforme == 724 & surveyround == 3
replace questions_needing_check = questions_needing_check + "Pourquoi il/elle a donné(e) des chiffres s'ils sont confidentiels ? / "  if id_plateforme == 724 & surveyround == 3

replace needs_check = 1 if id_plateforme == 151 & surveyround == 3
replace questions_needing_check = questions_needing_check + "Le code 666 signifie qu'il faut rappeler la comptabilité, une réécoute n'est pas suffisante / "  if id_plateforme == 151 & surveyround == 3

***********************************************************************
* 	PART 6:  Manually add tests for respondant position		
***********************************************************************
/*id_plateforme	id_ident_el	new_ident_repondent_position_el
635	anwer	
628	ibtissem hamdi	responsabe de production
58	Abdelhakim Bouabdallah	
78	BECHIR BEN MAAD	
324	BEN OUIRANE KAMEL	DRH
144	Mounir bousseeta	
695	HEDI  FEKHI	
765	olfa	responsable logistique
398	khalil	
629	ghofrane ghodhbene	
508	dhoha	
773	hafedh	gérant
91	rym	
213	hbib	
521	chadlia	responsable juridique
543	ilef kacem	responsable achat et export
800	noomen	gérant
655	moaataz ben hamouda	
394	mohamed ali	administratif
670	hela	responsable grh
148	Amir masmoudi	
821	hmida chamem	gérant
576	bassem	
587	mohamed rajdi	
387	amyra ben youssef	
443	IMEN AJILI	CORDINATRICE
453	MADAME HAJER	RESPONSABLE ADMINSTRATIF
846	Insaf	
859	mariem bou zaida	
373	ben rhouma rabiaa	resseponsable ressources humaines
365	hayet	
352	hechmi dhifi	
890	Mohamed Ali Ragoubi	
916	Fawzi Yaakouni	
938	Radhouane Bouricha	
959	Basma wachem	
961	Nabil ben hsin	
*/
/*
replace needs_check = 1 if surveyround == 3 & id_plateforme == 635
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) anwer (variable vide) / " if surveyround == 3 & id_plateforme == 635

replace needs_check = 1 if surveyround == 3 & id_plateforme == 58
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) Abdelhakim Bouabdallah (variable vide) / " if surveyround == 3 & id_plateforme == 58

replace needs_check = 1 if surveyround == 3 & id_plateforme == 78
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) BECHIR BEN MAAD (variable vide) / " if surveyround == 3 & id_plateforme == 78

replace needs_check = 1 if surveyround == 3 & id_plateforme == 144
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) Mounir bousseeta (variable vide) / " if surveyround == 3 & id_plateforme == 144

replace needs_check = 1 if surveyround == 3 & id_plateforme == 695
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) HEDI FEKHI (variable vide) / " if surveyround == 3 & id_plateforme == 695

replace needs_check = 1 if surveyround == 3 & id_plateforme == 398
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) khalil (variable vide) / " if surveyround == 3 & id_plateforme == 398

replace needs_check = 1 if surveyround == 3 & id_plateforme == 629
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) ghofrane ghodhbene (variable vide) / " if surveyround == 3 & id_plateforme == 629

replace needs_check = 1 if surveyround == 3 & id_plateforme == 508
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) dhoha (variable vide) / " if surveyround == 3 & id_plateforme == 508

replace needs_check = 1 if surveyround == 3 & id_plateforme == 91
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) rym (variable vide) / " if surveyround == 3 & id_plateforme == 91

replace needs_check = 1 if surveyround == 3 & id_plateforme == 213
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) hbib (variable vide) / " if surveyround == 3 & id_plateforme == 213

replace needs_check = 1 if surveyround == 3 & id_plateforme == 655
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) moaataz ben hamouda (variable vide) / " if surveyround == 3 & id_plateforme == 655

replace needs_check = 1 if surveyround == 3 & id_plateforme == 394
replace questions_needing_checks = questions_needing_checks + "Monsieur Mohamed Ali est indiqué comme administratif seulement. Quelle position occupe-t-il au sein de ce dernier ? / " if surveyround == 3 & id_plateforme == 394

replace needs_check = 1 if surveyround == 3 & id_plateforme == 148
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) Amir masmoudi (variable vide) / " if surveyround == 3 & id_plateforme == 148

replace needs_check = 1 if surveyround == 3 & id_plateforme == 576
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) bassem (variable vide) / " if surveyround == 3 & id_plateforme == 576

replace needs_check = 1 if surveyround == 3 & id_plateforme == 587
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) mohamed rajdi (variable vide) / " if surveyround == 3 & id_plateforme == 587
	
replace needs_check = 1 if surveyround == 3 & id_plateforme == 387
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) amyra ben youssef	(variable vide) / " if surveyround == 3 & id_plateforme == 387

replace needs_check = 1 if surveyround == 3 & id_plateforme == 846
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) Insaf (variable vide) / " if surveyround == 3 & id_plateforme == 846

replace needs_check = 1 if surveyround == 3 & id_plateforme == 859
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) mariem bou zaida (variable vide) / " if surveyround == 3 & id_plateforme == 859

replace needs_check = 1 if surveyround == 3 & id_plateforme == 365
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) hayet (variable vide) / " if surveyround == 3 & id_plateforme == 365

replace needs_check = 1 if surveyround == 3 & id_plateforme == 352
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) hechmi dhifi (variable vide) / " if surveyround == 3 & id_plateforme == 352

replace needs_check = 1 if surveyround == 3 & id_plateforme == 890
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) Mohamed Ali Ragoubi (variable vide) / " if surveyround == 3 & id_plateforme == 890

replace needs_check = 1 if surveyround == 3 & id_plateforme == 916
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) Fawzi Yaakouni (variable vide) / " if surveyround == 3 & id_plateforme == 916

replace needs_check = 1 if surveyround == 3 & id_plateforme == 938
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) Radhouane Bouricha (variable vide) / " if surveyround == 3 & id_plateforme == 938

replace needs_check = 1 if surveyround == 3 & id_plateforme == 959
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) Basma wachem (variable vide) / " if surveyround == 3 & id_plateforme == 959

replace needs_check = 1 if surveyround == 3 & id_plateforme == 961
replace questions_needing_checks = questions_needing_checks + "Veuillez vérifier la position du répondant(e) Nabil ben hsin (variable vide) / " if surveyround == 3 & id_plateforme == 961
*/
***********************************************************************
* 	PART 7:  Export an excel sheet with needs_check variables  			
***********************************************************************
merge m:1 id_plateforme using "${el_raw}/ecommerce_el_pii"

preserve
			* generate empty variable for survey institute comments/corrections
gen commentaires_ElAmouri = ""

			* keep order stable
sort id_plateforme, stable

			* adjust needs check to panel structure (same value for each surveyround)
				* such that when all values for each firms are kepts dropping those firms
					* that do not need checking
						* 1: needs_check
egen keep_check = max(needs_check), by(id_plateforme)
drop needs_check
rename keep_check needs_check
keep if needs_check > 0 // drop firms that do not need check

			* consider only firms that have completed the endline
egen el_completed = max(attest), by(id_plateforme)
drop if el_completed < 1
			
			* export excel file. manually add variables listed in questions_needing_check
				* group variables into lists (locals) to facilitate overview
local order_vars "id_plateforme surveyround survey_type needs_check attest commentaires_ElAmouri questions_needing_checks fte"
local accounting_vars "`order_vars' comp_ca2023 comp_ca2024 export_1 export_2 compexp_2023 compexp_2024 comp_benefice2023 comp_benefice2024 mark_invest dig_invest"
local dig_vars "`accounting_vars' dig_miseajour1 dig_miseajour2 dig_miseajour3 mark_online1 mark_online2 mark_online3 mark_online4 mark_online5 dig_presence1 dig_presence2 dig_presence3"
local fteoyee_vars "`dig_vars' car_carempl_div1 car_carempl_div2 car_carempl_div3 dig_empl"

/*
			* remove previous surveyround values for better visbility
local investing_vars_surveyround dig_miseajour1 dig_miseajour2 dig_miseajour3 mark_online1 mark_online2 mark_online3 mark_online4 mark_online5 dig_presence1 dig_presence2 dig_presence3 ///
export_1 export_2 export_3 exp_pays clients_b2b clients_b2c export_1 export_2 export_3 exp_pays clients_b2b clients_b2c
foreach var of local investing_vars_surveyround {
    replace `var' =. if surveyround == 1 | surveyround == 2
}
*/

				* export
export excel `fteoyee_vars' ///
   using "${el_checks}/fiche_correction.xlsx" if surveyround == 3, replace firstrow(var) datestring("%-td")


restore
