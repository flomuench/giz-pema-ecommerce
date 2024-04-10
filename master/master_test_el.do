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
*	6)		Variable has been tagged as "needs_check" = -888, -777 or .
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
*number of product innovations
	* number of product innovations large
replace needs_check = 1 if surveyround == 3 & inno_produit_ext > 10 & inno_produit_ext !=.
replace questions_needing_checks = "nombre d'innovations de produit est grand / " if surveyround == 3 & inno_produit_ext > 10 & inno_produit_ext !=.
	
	* number of product innovations negative
replace needs_check = 1 if surveyround == 3 & inno_produit_ext < 0 & inno_produit_ext !=. & inno_produit_ext !=. -777 & inno_produit_ext != -888 & inno_produit_ext != -999
replace questions_needing_checks = "nombre d'innovations de produit est négatif / " if surveyround == 3 & inno_produit_ext < 0 & inno_produit_ext !=. & inno_produit_ext !=. -777 & inno_produit_ext != -888 & inno_produit_ext != -999

*number of employees
	*loop over all employees var
local employees_var empl car_carempl_div1 car_carempl_div2 car_carempl_div3 car_carempl_div4 dig_empl

foreach var of employees_var {
		* number of employees is over 200
	replace needs_check = 1 if surveyround == 3 & `var' > 200 & `var' !=.
	replace questions_needing_checks = "`var' est plus que 200 / " if surveyround == 3 & `var' > 200 & `var' !=.

		* number of employees is negative
	replace needs_check = 1 if surveyround == 3 & `var' < 0 & `var' !=. & `var' != -777 & `var' != -888 & `var' != -999
	replace questions_needing_checks = "`var' est négatif / " if surveyround == 3 & `var' < 0 & `var' !=. & `var' != -777 & `var' != -888 & `var' != -999

}

	*females + youth (under 36) is more than number of employees
replace needs_check = 1 if surveyround == 3 & (car_carempl_div1 + car_carempl_div2 > empl)
replace questions_needing_checks = "Nombre d'employés femmes et jeune (<36) est plus que nombre d'employés" / " if surveyround == 3 & (car_carempl_div1 + car_carempl_div2 > empl)
	
	*females + youth (under 24) is more than the number of employees
replace needs_check = 1 if surveyround == 3 & (car_carempl_div1 + car_carempl_div3 > empl)
replace questions_needing_checks = "Nombre d'employés femmes et jeune (<24) est plus que nombre d'employés" / " if surveyround == 3 & (car_carempl_div1 + car_carempl_div3 > empl)

	*permanent is more than the number of employees
replace needs_check = 1 if surveyround == 3 & car_carempl_div4 > empl
replace questions_needing_checks = "Nombre d'employés permanent est plus que nombre d'employés" / " if surveyround == 3 & car_carempl_div4 > empl

/* --------------------------------------------------------------------
	PART 2.2: Digital Technology Adoption
----------------------------------------------------------------------*/

*digital update
	*has digital employees but does not do any kind of updates
foreach var of dig_miseajour1 dig_miseajour2 dig_miseajour3 {
	replace needs_check = 1 if surveyround == 3 & `var' == 1 & dig_empl == 0
	replace questions_needing_checks = "L'entreprise utilise `var' alors qu'elle n'a pas d'employés en marketing digital / " if surveyround == 3 & `var' == 0 & dig_empl > 0
}

	*invests in digital marketing but does not do any updates
foreach var of dig_miseajour1 dig_miseajour2 dig_miseajour3 {
	replace needs_check = 1 if surveyround == 3 & `var' == 1 & dig_invest == 0
	replace questions_needing_checks = "L'entreprise utilise `var' alors qu'elle n'investie pas en marketing digital / " if surveyround == 3 & `var' == 0 & dig_empl > 0
}

/* --------------------------------------------------------------------
	PART 2.3: Marketing & Communication
----------------------------------------------------------------------*/

*online marketing
	*uses marketing tools but does not have any digital employee
foreach var of mark_online1 mark_online2 mark_online3 mark_online4 mark_online5 {
	replace needs_check = 1 if surveyround == 3 & `var' == 1 & dig_empl == 0
	replace questions_needing_checks = "L'entreprise n'a pas d'employés digital mais elle fait `var' / " if surveyround == 3 & `var' == 1 & dig_empl == 0
}

	*uses marketing tools but does not invest in digital marketing
foreach var of mark_online1 mark_online2 mark_online3 mark_online4 mark_online5 {
	replace needs_check = 1 if surveyround == 3 & `var' == 1 & mark_invest == 0
	replace questions_needing_checks = "L'entreprise n'investie pas dans le marketing digital mais elle fait `var' / " if surveyround == 3 & `var' == 1 & mark_invest == 0
}

/* --------------------------------------------------------------------
	PART 2.4: Export Questions
----------------------------------------------------------------------*/
	*a minimum of exporting countries
replace needs_check = 1 if export_3 != 1 & surveyround==3 & exp_pays==0
replace questions_needing_checks = questions_needing_checks + "l'entreprise export mais n'indique pas de pays / " if export_3 != 1 & surveyround==3 & exp_pays==0

	*a maximum of exporting countries
replace needs_check = 1 if exp_pays > 150 & surveyround==3 & exp_pays !=0
replace questions_needing_checks = questions_needing_checks + "nombre pays d'export illogique / " if exp_pays > 150 & surveyround==3 & exp_pays !=0

	*a negative exporting countries
replace needs_check = 1 if exp_pays < 0 & surveyround == 3 & exp_pays != 0 & exp_pays !=- 777 & exp_pays !=- 888 & exp_pays !=- 999
replace questions_needing_checks = questions_needing_checks + "nombre pays d'export négatif / " if exp_pays < 0 & surveyround == 3 & exp_pays != 0 & exp_pays !=- 777 & exp_pays !=- 888 & exp_pays !=- 999

	*not B2B company but sells to companies
replace needs_check = 1 if clients_b2b > 0 & clients == 1 & surveyround == 3
replace questions_needing_checks = questions_needing_checks + "l'entreprise est B2C mais vend à des entreprises / " if clients_b2b > 0 & clients == 1 & surveyround == 3

	*not B2C company but sells to clients
replace needs_check = 1 if clients_b2c > 0 & clients == 2 & surveyround == 3
replace questions_needing_checks = questions_needing_checks + "l'entreprise est B2B mais vend à des clients / " if clients_b2c > 0 & clients == 2 & surveyround == 3

	*company does not export but has int clients
replace needs_check = 1 if export_3 == 1 & clients_b2c > 0 & surveyround == 3
replace questions_needing_checks = questions_needing_checks + "l'entreprise n'export pas mais a des clients internationaux / " if export_3 == 1 & clients_b2c > 0 & surveyround == 3
	*company does not export but has int companies

	* Countries & Number of multinationals
replace needs_check = 1 if export_3 == 1 & clients_b2b > 0 & surveyround == 3
replace questions_needing_checks = questions_needing_checks + "l'entreprise n'export pas mais a des entreprises internationaux /" if export_3 == 1 & clients_b2b > 0 & surveyround == 3

	* Countries & Number of multinationals
replace needs_check = 1 if dig_presence1 != 1 & dig_presence2 != 1 & dig_presnce3 != 1 & export_1 == 1 & exp_dig == 1 & surveyround == 3
replace questions_needing_checks = questions_needing_checks + "l'entreprise exporte grace à ses plateformes enligne mais n'a pas de presence en ligne /" if dig_presence1 != 1 & dig_presence2 != 1 & dig_presnce3 != 1 & export_1 == 1 & exp_dig == 1 & surveyround == 3

	*exporting status changed throughout the surveyrounds
local exporting_vars "export"
foreach var of local exporting_vars {
	
	bys id (surveyround): replace needs_check = 1 if `var'[_n] != `var'[_n-1]  & surveyround == 3 
	bys id (surveyround): replace questions_needing_checks = questions_needing_checks + "export status a changé entre les surveyrounds, vérifier /" if `var'[_n] != `var'[_n-1]  & surveyround == 3 

}
/* --------------------------------------------- -----------------------
	PART 2.6: Accounting Questions
----------------------------------------------------------------------*/		
	*mistake in matricule fiscale
gen check_matricule = 1
replace check_matricule = 0 if ustrregexm(q29, "^[0-9]{7}[a-zA-Z]$") == 1

replace needs_check = 1 if check_matricule == 1 & surveyround == 3 & matricule_fiscale_missing  == 1
replace questions_needing_checks = questions_needing_checks + "matricule fiscale n'est pas conforme à la norme." if check_matricule == 1 & surveyround == 3 & matricule_fiscale_missing  == 1

	*mistake in telephone number
gen check_phone = 1
replace check_phone = 0 if ustrregexm(q29_tel, "((\+|00)216)?[0-9]{8}") == 1

replace needs_check = 1 if check_phone == 1 & surveyround == 3
replace questions_needing_checks = questions_needing_checks + "téléphonne n'est pas conforme à la norme." if check_phone == 1 & surveyround == 3

	*mistake in email
gen check_mail = 1
replace check_mail = 0 if ustrregexm(q29_mail, "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}") == 1

replace needs_check = 1 if check_mail == 1 & surveyround == 3
replace questions_needing_checks = questions_needing_checks + "email n'est pas conforme à la norme." if check_mail == 1 & surveyround == 3

	* Export, sales, profit, equipments value & suppliers is zero or missing
local accountvars comp_ca2023 comp_ca2023 compexp_2023 compexp_2024
foreach var of local accountvars {
		* = 0
	replace needs_check = 1 if surveyround == 3 & `var' == 0 
	replace questions_needing_checks = questions_needing_checks + "`var' zero / " if surveyround == 3 & `var' == 0 
	
}

	* Export is zero and the company is exporting
replace needs_check = 1 if (compexp_2023 > 0 | compexp_2024 > 0 ) & surveyround == 3 & (export_1 == 1 | epxort_2 == 1)
replace questions_needing_checks = questions_needing_checks + "ca export zero alors que l'entreprise export / " if (compexp_2023 > 0 | compexp_2024 > 0 ) & surveyround == 3 & (export_1 == 1 | epxort_2 == 1)

	
	* Profits > sales 2023
replace needs_check = 1 if surveyround == 3 & comp_benefice2023 > comp_ca2023 & comp_benefice2023 != -777  & comp_benefice2023 != -888  & comp_benefice2023 != -999 ///
& comp_ca2023 != -777 & comp_ca2023 != -888 & comp_ca2023 != -999 & comp_benefice2023 != . & comp_ca2023 != .
replace questions_needing_checks = questions_needing_checks + "Benefices sont plus élevés que CA 2023 / " if surveyround == 3 & comp_benefice2023 > comp_ca2023 & comp_benefice2023 != -777  & comp_benefice2023 != -888  & comp_benefice2023 != -999 ///
& comp_ca != -777 & comp_ca != -888 & comp_ca != -999 & comp_benefice2023 != . & comp_ca2023 != .

	* Profits > sales 2024
replace needs_check = 1 if surveyround == 3 & comp_benefice2024 > comp_ca2024 & comp_benefice2024 != -777  & comp_benefice2024 != -888  & comp_benefice2024 != -999 ///
& comp_ca2024 != -777 & comp_ca2024 != -888 & comp_ca2024 != -999 & comp_benefice2024 != . & comp_ca2024 != .
replace questions_needing_checks = questions_needing_checks + "Benefices sont plus élevés que CA 2024 / " if surveyround == 3 & comp_benefice2024 > comp_ca2024 & comp_benefice2024 != -777  & comp_benefice2024 != -888  & comp_benefice2024 != -999 ///
& comp_ca2024 != -777 & comp_ca2024 != -888 & comp_ca2024 != -999 & comp_benefice2024 != . & comp_ca2024 != .

	*ca - invest < profit if positive 2023
replace needs_check = 1 if surveyround == 3 & (comp_ca2023 - mark_invest - dig_invest) < comp_benefice2023 & comp_benefice2023 > 0
replace questions_needing_checks = questions_needing_checks + "Les bénéfices 2023 sont supérieurs au chiffre d'affaires et aux investissements. / " if surveyround == 3 & (comp_ca2023 - mark_invest - dig_invest) < comp_benefice2023 & comp_benefice2023 > 0

	*ca - invest < profit if positive 2024
replace needs_check = 1 if surveyround == 3 & (comp_ca2024 - mark_invest - dig_invest) < comp_benefice2024 & comp_benefice2024 > 0
replace questions_needing_checks = questions_needing_checks + "Les bénéfices 2024 sont supérieurs au chiffre d'affaires et aux investissements. / " if surveyround == 3 & (comp_ca2024 - mark_invest - dig_invest) < comp_benefice2024 & comp_benefice2024 > 0

	* Outliers/extreme values: Very low values
		* ca2023
replace needs_check = 1 if surveyround == 3 & comp_ca2023 < 5000 & comp_ca2023 > 0
replace questions_needing_checks = questions_needing_checks + "CA 2023 moins que 5000 TND, vérifier / " if surveyround == 3 & comp_ca2023 < 5000 & comp_ca2023 > 0
		* ca2024
replace needs_check = 1 if surveyround == 3 & comp_ca2024 < 5000 & comp_ca2024 > 0
replace questions_needing_checks = questions_needing_checks + "CA 2024 moins que 5000 TND, vérifier / " if surveyround == 3 & comp_ca2024 < 5000 & comp_ca2024 > 0

		* profit
				* just above zero
foreach var of 2023 2024 {
	
replace needs_check = 1 if surveyround == 3 & comp_benefice`var' < 2500 & comp_benefice`var' > 0 
replace questions_needing_checks = questions_needing_checks + "benefice `var' moins que 2500 TND / " if surveyround == 3 & comp_benefice`var' < 2500 & comp_benefice`var' > 0 

				* just below zero
replace needs_check = 1 if surveyround == 3 & comp_benefice`var' > -2500 & comp_benefice`var' < 0 & comp_benefice`var' !=-999 & comp_benefice`var' !=-888 & comp_benefice`var' !=-777
replace questions_needing_checks = questions_needing_checks + "benefice `var' + que -2500 TND mais - que zero / " if surveyround == 3 & comp_benefice`var' > -2500 & comp_benefice`var' <0 & comp_benefice`var' !=-999 & comp_benefice`var' !=-888 & comp_benefice`var' !=-777

				*Very big values
replace needs_check = 1 if surveyround == 3 & comp_benefice`var' > 1000000 & comp_benefice`var' != .
replace questions_needing_checks = questions_needing_checks + "Profit `var' trop grand, supérieur à 1 millions de dinars / " if surveyround == 3 & comp_benefice`var' > 1000000 & comp_benefice`var' != .

}
	* negative investments & ca:
local accountvars "mark_invest dig_invest comp_exp2023 comp_exp2024 comp_ca2023 comp_ca2024" 
foreach var of local accountvars {
	
	replace needs_check = 1 if surveyround == 3 & `var' < 0 & `var' != -777 & `var' != -888 & `var' != -999
	replace questions_needing_checks = questions_needing_checks + "`var' négatif / " if surveyround == 3 & `var' < 0 & `var' != -777 & `var' != -888 & `var' != -999
	
}

***********************************************************************
* 	Part 3: large Outliers	(absolute, cross-sectional values)		
***********************************************************************
local acccounting_vars "empl dig_empl mark_invest dig_invest comp_ca2023 comp_ca2024 comp_exp2023 comp_exp2024 comp_benefice2023 comp_benefice2024"
foreach var of local acccounting_vars {
	sum `var', d
	replace needs_check = 1 if `var' != .& surveyround == 3 & `var' > r(p95)
	replace questions_needing_checks = questions_needing_checks + "`var' très grand, vérifier / " if `var' != .& surveyround == 3 & `var' > r(p95)
}

***********************************************************************
* 	Part 4: large Outliers	(normalized)		
***********************************************************************

local acccounting_normalized_vars "nempl ndig_empl nmark_invest ndig_invest ncomp_ca2023 ncomp_ca2024 ncomp_exp2023 ncomp_exp2024 ncomp_benefice2023 ncomp_benefice2024"
foreach var of local acccounting_normalized_vars {
	sum `var', d
	replace needs_check = 1 if `var' != .& surveyround == 3 & `var' > r(p95)
	replace questions_needing_checks = questions_needing_checks + "`var' très grand, vérifier / " if `var' != .& surveyround == 3 & `var' > r(p95)
}

/* --------------------------------------------------------------------
	PART 5: Growth rate in accounting variables
----------------------------------------------------------------------*/
/* NOT SAME NAME OF VARS & NEW VARS ADDED HERE

local acccounting_vars "mark_invest dig_invest comp_ca2023 comp_ca2024 comp_exp2023 comp_exp2024 comp_benefice2023 comp_benefice2024"
foreach var of local acccounting_vars {
	sum `var'_abs_growth, d
	replace needs_check = 1 if `var'_abs_growth != . & `var'_abs_growth > r(p95) | `var'_abs_growth < r(p5) & surveyround == 3
	replace questions_needing_checks = questions_needing_checks + "différence extrême entre surveyrounds pour `var', vérifier / " if `var'_abs_growth != . & `var'_abs_growth > r(p95) | `var'_abs_growth < r(p5) & surveyround == 3
}
*/
***********************************************************************
* 	PART 6: Variable has been tagged as "needs_check" = -888, -777 or .
***********************************************************************

local test_vars "empl dig_empl mark_invest dig_invest comp_ca2023 comp_ca2024 comp_exp2023 comp_exp2024 comp_benefice2023 comp_benefice2024"
foreach var of local test_vars {
	replace needs_check = 1 if `var' == -888 & surveyround == 3
	replace questions_needing_checks = questions_needing_checks + "`var' = -888, vérifier / " if `var' == -888 & surveyround == 3
	replace needs_check = 1 if `var' == -777 & surveyround == 3
	replace questions_needing_checks = questions_needing_checks + "`var' = -777, vérifier / " if `var' == -777 & surveyround == 3
	replace needs_check = 1 if `var' == -999 & surveyround == 3
	replace questions_needing_checks = questions_needing_checks + "`var' = -999, vérifier / " if `var' == -999 & surveyround == 3
	replace needs_check = 1 if `var' == . & surveyround == 3 & exporter == 1
	replace questions_needing_checks = questions_needing_checks + "`var' = missing, vérifier / " if `var' == . & surveyround == 3 & exporter == 1
}


***********************************************************************
* 	PART 8:  Remove firms from needs_check in case calling them again did not solve the issue		
***********************************************************************


***********************************************************************
* 	PART 9:  Export an excel sheet with needs_check variables  			
***********************************************************************

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
egen el_completed = max(complete), by(id_plateforme)
drop if el_completed < 1
			
			* export excel file. manually add variables listed in questions_needing_check
				* group variables into lists (locals) to facilitate overview
local order_vars "id_plateforme surveyround methode_reponse endline_enqueteur needs_check complete commentaires_ElAmouri questions_needing_checks"
local accounting_vars "`order_vars' mark_invest dig_invest comp_ca2023 comp_ca2024 comp_exp2023 comp_exp2024 comp_benefice2023 comp_benefice2024"
local dig_vars "`accounting_vars' dig_miseajour1 dig_miseajour2 dig_miseajour3 mark_online1 mark_online2 mark_online3 mark_online4 mark_online5 dig_presence1 dig_presence2 dig_presence3"
local exp_vars "`dig_vars' export_1 export_2 export_3 exp_pays clients_b2b clients_b2c"
local employee_vars "`exp_vars' empl car_carempl_div1 car_carempl_div2 car_carempl_div3 car_carempl_div4 dig_empl"

/* IF NEEDED?
			* remove previous surveyround values for better visbility
local investing_vars_surveyround "smq_responsable smq_plan smq_logiciel smq_defauts_collecte smq_tracabilite q21 q24_1 q24_2 q24_3 q24_4 q28_pays_nb"

foreach var of local investing_vars_surveyround {
    replace `var' =. if surveyround == 1 | surveyround == 2
}
*/

				* export
export excel `employee_vars' ///
   using "${aqe_master_check}/fiche_correction.xlsx", replace firstrow(var) datestring("%-td")


restore
