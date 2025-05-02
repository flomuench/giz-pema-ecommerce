***********************************************************************
* 			Master generate				  
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
*	Creates:	ecommerce_master_final.dta
***********************************************************************
* 	PART 1: import data
***********************************************************************
use "${master_intermediate}/ecommerce_master_inter", clear

***********************************************************************
* PART 1: Baseline and take-up statistics
***********************************************************************
{
/*generate take up variable
gen take_up = (present>2 & present<.), a(present)
lab var take_up "1 if company was present in 3/5 trainings"
label define treated 0 "not present" 1 "present"
label value take_up treated
*/
gen take_up2= 0
replace take_up2 = 1 if take_up_for1== 1| take_up_for2== 1| take_up_for3== 1| take_up_for4== 1| take_up_for5== 1
lab var take_up2 "1 if present in at least one training"
label value take_up2 treated

* to check
*br id_plateforme surveyround treatment present take_up take_up2
bysort id_plateforme (surveyround): replace take_up_for_per = take_up_for_per[_n-1] if take_up_for_per == 0

*replace take_up=0 if take_up==. 
local take_up take_up2 take_up_for_per take_up_for take_up_for1 take_up_for2 take_up_for3 take_up_for4 take_up_for5 take_up_std take_up_seo take_up_smo take_up_smads take_up_website take_up_heber
foreach var of local take_up{
bysort id_plateforme (surveyround): replace `var' = `var'[_n-1] if `var' == .
}
*take up 4/5 workshops
gen take_up4 = 0
replace take_up4 = 1 if take_up_for1== 1 & take_up_for2== 1 & take_up_for3== 1 & take_up_for4== 1

*take up 5/5 workshops
gen take_up5 = 0
replace take_up5 = 1 if take_up_for1== 1 & take_up_for2== 1 & take_up_for3== 1 & take_up_for4== 1 & take_up_for5== 1

*replace take_up2=0 if take_up2==. 

*take_up_sm qui est = 1 si soit take_up_seo ou take_up_smads or take_up_smo = 1
gen take_up_sm = 0
lab var take_up_sm "Presence in one social media activity"

replace take_up_sm = 1 if (take_up_seo == 1 | take_up_smo == 1 | take_up_smads == 1)


*gen take_up_web_sm qui est = 1 si take_up_sm == 1 | take_up_website == 1
gen take_up_web_sm = 0
lab var take_up_web_sm "Presence in one social media activity OR website activity"

replace take_up_web_sm = 1 if (take_up_sm == 1 | take_up_website == 1)

*gen take_up  take_up_for == 1 & (take_up_sm == 1 | take_up_website == 1)
gen take_up = 0
lab var take_up "Presence in 3/5 workshops & 1 digital activity (Web/Social media)"

replace take_up = 1 if take_up_for == 1 & take_up_web_sm == 1

*3/5 workshops & sm
gen take_up_wsm = 0
replace take_up_wsm = 1 if take_up_for == 1 & take_up_sm == 1

lab var take_up_wsm "Presence in 3/5 workshops & social media activity"

*3/5 workshops & website
gen take_up_wws = 0
replace take_up_wws = 1 if take_up_for == 1 & take_up_website == 1

lab var take_up_wws "Presence in 3/5 workshops & web site activity"


*gen take_up_full
gen take_up_full = 0
replace take_up_full = 1 if (take_up_seo == 1 & take_up_smo == 1 & take_up_smads == 1 &  take_up_website == 1)
lab var take_up_full "Participated in each activity"

gen take_up_partial = 0
replace take_up_partial = 1 if (take_up_seo == 1 | take_up_smo == 1 | take_up_smads == 1 |  take_up_website == 1)
lab var take_up_partial "Participated in at least one activity"
lab def take_up_par 1 "participated" 0 "absent"	
lab values take_up_partial take_up_par

/*create simplified training group variable (tunis vs. non-tunis)
gen groupe2 = 0
replace groupe2 = 1 if groupe == "Tunis 1" |groupe == "Tunis 2"| groupe == "Tunis 3" | groupe == "Tunis 4" | groupe == "Tunis 5" | groupe == "Tunis 6"
lab var groupe2 "Classroom training in Tunis(1) or outside(0)"
*/

}

***********************************************************************
* PART 2. Create dummy variables
***********************************************************************	
{
*Since most firms have at most zero, one or two FTE and online orders 
*we use a dummyary indicator instead of continous or share of FTE, which sometimes
*leads to absurd, difficult to compare figures (small firms have 5/6 employees working on it, others 1/180)


gen dig_dummy = .
	replace dig_dummy = 0 if dig_empl == 0
	replace dig_dummy = 1 if dig_empl>0 & dig_empl<.
lab var dig_dummy "Firms has digital marketing employee (1) or not(0)"

gen dig_marketing_dummy = .
	replace dig_marketing_dummy = 0 if dig_marketing_dummy == 0
	replace dig_marketing_dummy = 1 if dig_marketing_dummy>0 & dig_marketing_dummy<.
lab var dig_marketing_dummy "Firms has employee dealing with online orders"

gen expprep_dummy = .
	replace expprep_dummy = 0 if expprep_dummy == 0
	replace expprep_dummy = 1 if expprep_dummy>0 & expprep_dummy<.
lab var expprep_dummy "Firm has employee dealing with exports"



*dummy variables for dig_rev & dig_invest (extensive margins)
	*dig_rev
gen dig_rev_extmargin = .
	replace dig_rev_extmargin = 1 if dig_revenues_ecom > 0
	replace dig_rev_extmargin = . if dig_revenues_ecom == .
	replace dig_rev_extmargin = 0 if dig_revenues_ecom == 0
lab var dig_rev_extmargin "Digital revenue > 0"

	*dig_invest
gen dig_invest_extmargin = .
	replace dig_invest_extmargin = 1 if dig_invest > 0
	replace dig_invest_extmargin = . if dig_invest == .
	replace dig_invest_extmargin = 0 if dig_invest == 0
lab var dig_invest_extmargin "Digital invest > 0"

	* Dig_rev  dig_invest with 0s instead of . for non-attrited firms
gen dig_invest_extmargin2 = dig_invest_extmargin
		replace dig_invest_extmargin2 = 0 if surveyround == 3 & attrited == 0 & dig_invest_extmargin2 == .
lab var dig_invest_extmargin2 "Digital invest > 0"
		

gen dig_rev_extmargin2 = dig_rev_extmargin
		replace dig_rev_extmargin2 = 0 if attrited == 0 & dig_rev_extmargin == .
lab var dig_rev_extmargin2 "Digital revenue > 0"



	*profit positive
gen profit_pos = .
	replace profit_pos = 1 if profit > 0
	replace profit_pos = . if profit == .
	replace profit_pos = 0 if profit <= 0
lab var profit_pos "Profit > 0"


	*profit2024 possible
gen profit_2024_pos = .
	replace profit_2024_pos = 1 if comp_benefice2024 > 0
	replace profit_2024_pos = . if comp_benefice2024 == .
	replace profit_2024_pos = 0 if comp_benefice2024 <= 0
lab var profit_2024_pos "Profit 2024 > 0"



*generate sector dummies as ordinal/categorical variable has no meaning
gen agri=(sector == 1)
	replace agri=. if sector==.

gen artisanat=(sector==2)
	replace artisanat=. if sector==.
	
gen commerce_int=(sector == 3)
	replace commerce_int=. if sector==.

gen industrie=(sector==4)
	replace industrie=. if sector==.

gen service=(sector==5)
	replace industrie=. if sector==.

gen tic=(sector==6)
	replace industrie=. if sector==.

lab var agri "agriculture"
lab var artisanat "handicraft"
lab var commerce_int "trader"
lab var industrie "industry"
lab var service "service"
lab var tic "IT"


*create final export status variable and delete other to avoid confusion
gen exporter2020=.
replace exporter2020=1 if compexp_2020 >0 & compexp_2020<. 
replace exporter2020=0 if compexp_2020 == 0 
lab var exporter2020 "dummy if company exported in the year 2020"

gen ever_exported=. 
replace ever_exported=1 if compexp_2020>0 & compexp_2020<. 
replace ever_exported=1 if exp_avant21==1
replace ever_exported=1 if export2021=="oui" | export2020=="oui" | export2019 =="oui" | export2018=="oui" |export2017=="oui"
replace ever_exported=0 if exp_avant21==0
lab var ever_exported "dummy if company has exported some time in the past 5 years"

drop exported

gen exported = (export > 0)
	replace exported = . if export == .
lab var exported "Export sales > 0"

gen exported2 = (exp_pays > 0)
	replace exported2 = . if exp_pays == .
	replace exported2 = 0 if exported == 0 & surveyround == 3
lab var exported2 "Export countries > 0"

*Adjust score for knowledge questions in the baseline
replace dig_con6_referencement_payant = 0.33 if dig_con6_referencement_payant == 1 
replace dig_con6_cout_par_clic = 0.33 if dig_con6_cout_par_clic == 1 
replace dig_con6_cout_par_mille = -0.99 if dig_con6_cout_par_mille == 1
replace dig_con6_liens_sponsorisés = 0.33 if dig_con6_liens_sponsorisés == 1
replace dig_con5 = -1 if dig_con5 == 0 
replace dig_con5 = 0 if dig_con5 == 1 


gen dig_con6_bl = dig_con6_referencement_payant + dig_con6_cout_par_clic + dig_con6_cout_par_mille + dig_con6_liens_sponsorisés + dig_con5
replace dig_con6_bl = 1 if dig_con6_bl == .99000001
replace dig_con6_bl = 0 if dig_con6_bl == 2.980e-08
lab var dig_con6_bl "Correct answers to knowledge question on Google Analaytics" 

*Additional preparatory variables required for index generation (check bl_generate)	
}

***********************************************************************
* PART 2: Generating a cost variable
***********************************************************************	
{
gen cost_2020 = comp_ca2020 - comp_benefice2020 if surveyround ==1
lab var cost_2020 "Total costs in 2020 in TND"

gen cost = sales - profit if surveyround ==3
lab var cost "Total costs in TND"

gen cost_2024 = comp_ca2024 - comp_benefice2024 if surveyround ==3
lab var cost_2024 "Total costs in 2024 in TND"

}

***********************************************************************
* PART 3: IHS-transformation & winsorization
***********************************************************************	
{


local all compexp_2020 comp_ca2020 comp_benefice2020 ///
dig_revenues_ecom dig_invest mark_invest fte fte_femmes car_carempl_div2 ///
clients_b2b dig_empl clients_b2c sales comp_ca2024 export compexp_2024 ///
exp_pays cost_2020 cost cost_2024 profit comp_benefice2024

local all_but_profit compexp_2020 comp_ca2020 comp_benefice2020 ///
dig_revenues_ecom dig_invest mark_invest fte fte_femmes car_carempl_div2 ///
clients_b2b dig_empl clients_b2c sales comp_ca2024 export compexp_2024 ///
exp_pays cost_2020 cost cost_2024

	
foreach var of local all {
		gen `var'_w99 = .
		gen `var'_w95 = .
		gen ihs_`var' = .
}


forvalues s = 1(1)3 {
	
	* over each var
	foreach var of local all_but_profit {
		* check if 
		sum `var' if surveyround == `s'
		if (`r(N)' > 0) {
		
		* Winsorisation
			winsor2 `var' if surveyround == `s', suffix(`s'_w99) cuts(0 99)
			winsor2 `var' if surveyround == `s', suffix(`s'_w95) cuts(0 95)
			
			replace `var'_w99 = `var'`s'_w99 if surveyround == `s'
			replace `var'_w95 = `var'`s'_w95 if surveyround == `s'
			
			drop `var'`s'_w99 `var'`s'_w95
		
		* IHS-transformation
			ihstrans `var' if surveyround == `s', prefix(ihs`s'_)
			
			replace ihs_`var' = ihs`s'_`var' if surveyround == `s'
			
			drop ihs`s'_`var'
	}
  }
}



		* profit
foreach var in profit comp_benefice2024 {
forvalues s = 1(1)3 {
		sum `var' if surveyround == `s'
		if (`r(N)' > 0) {
	
			* Winsorisation
			winsor2 `var' if surveyround == `s', suffix(`s'_w99) cuts(1 99)
			winsor2 `var' if surveyround == `s', suffix(`s'_w95) cuts(5 95)
			
			replace `var'_w99 = `var'`s'_w99 if surveyround == `s'
			replace `var'_w95 = `var'`s'_w95 if surveyround == `s'
			
			drop `var'`s'_w99 `var'`s'_w95
		
		* IHS-transformation
			ihstrans `var' if surveyround == `s', prefix(ihs`s'_)
			
			replace ihs_`var' = ihs`s'_`var' if surveyround == `s'
			
			drop ihs`s'_`var'
		}
	}
}


/*
{
	* pre-treatment (BL) financial values
{
*regenerate winsorized IHS exports after slight modification of underlying variable
*(assuming zero exports for firms that had missing value and declared to have not exported prior to 2021)
winsor compexp_2020, gen(w99_compexp2020) p(0.01) highonly
winsor compexp_2020, gen(w97_compexp2020) p(0.03) highonly
winsor compexp_2020, gen(w95_compexp2020) p(0.05) highonly

gen ihs_exports99_2020 = log(w99_compexp2020 + sqrt((w99_compexp2020*w99_compexp2020)+1))
lab var ihs_exports99_2020 "IHS of exports in 2020, wins.99th"
gen ihs_exports97_2020 = log(w97_compexp2020 + sqrt((w97_compexp2020*w97_compexp2020)+1))
lab var ihs_exports97_2020 "IHS of exports in 2020, wins.97th"
gen ihs_exports95_2020 = log(w95_compexp2020 + sqrt((w95_compexp2020*w95_compexp2020)+1))
lab var ihs_exports95_2020 "IHS of exports in 2020, wins.95th"

*generate domestic revenue from total revenue and exports
gen dom_rev2020= comp_ca2020-compexp_2020
lab var dom_rev2020 "Domestic revenue 2020"
winsor dom_rev2020, gen(w_dom_rev2020) p(0.01) highonly
ihstrans w_dom_rev2020

*re-generate total revenue with additional winsors

winsor comp_ca2020, gen(w99_comp_ca2020) p(0.01) highonly
winsor comp_ca2020, gen(w97_comp_ca2020) p(0.03) highonly
winsor comp_ca2020, gen(w95_comp_ca2020) p(0.05) highonly

gen ihs_ca99_2020 = log(w99_comp_ca2020 + sqrt((w99_comp_ca2020*w99_comp_ca2020)+1))
lab var ihs_ca99_2020 "IHS of revenue in 2020, wins.99th"
gen ihs_ca97_2020 = log(w97_comp_ca2020 + sqrt((w97_comp_ca2020*w97_comp_ca2020)+1))
lab var ihs_ca97_2020 "IHS of revenue in 2020, wins.97th"
gen ihs_ca95_2020 = log(w95_comp_ca2020 + sqrt((w95_comp_ca2020*w95_comp_ca2020)+1))
lab var ihs_ca95_2020 "IHS of revenue in 2020, wins.95th"


* digital revenues
winsor dig_revenues_ecom, gen(dig_rev_w95) p(0.05) highonly
	gen ihs_dig_rev_w95 = log(dig_rev_w95 + sqrt((dig_rev_w95*dig_rev_w95)+1))
	lab var ihs_dig_rev_w95 "IHS of digital revenues from ecommerce, wins.99th"

winsor dig_revenues_ecom, gen(dig_rev_w97) p(0.03) highonly
	gen ihs_dig_rev_w97 = log(dig_rev_w97 + sqrt((dig_rev_w97*dig_rev_w97)+1))
	lab var ihs_dig_rev_w97 "IHS of digital revenues from ecommerce, wins.97th"

winsor dig_revenues_ecom, gen(dig_rev_w99) p(0.01) highonly
	gen ihs_dig_rev_w99 = log(dig_rev_w99 + sqrt((dig_rev_w99*dig_rev_w99)+1))
	lab var ihs_dig_rev_w99 "IHS of digital revenues from ecommerce, wins.99th"

*re-generate total profit with additional winsors

winsor comp_benefice2020, gen(w99_comp_benefice2020) p(0.01) highonly
winsor comp_benefice2020, gen(w97_comp_benefice2020) p(0.03) highonly
winsor comp_benefice2020, gen(w95_comp_benefice2020) p(0.05) highonly

gen ihs_profit_2020_99 = log(w99_comp_benefice2020 + sqrt((w99_comp_benefice2020*w99_comp_benefice2020)+1))
lab var ihs_profit_2020_99 "IHS of profit in 2020, wins.99th"
gen ihs_profit_2020_97 = log(w97_comp_benefice2020 + sqrt((w97_comp_benefice2020*w97_comp_benefice2020)+1))
lab var ihs_profit_2020_97 "IHS of profit in 2020, wins.97th"
gen ihs_profit_2020_95 = log(w95_comp_benefice2020 + sqrt((w95_comp_benefice2020*w95_comp_benefice2020)+1))
lab var ihs_profit_2020_95 "IHS of profit in 2020, wins.95th"

}
	

	* numeric survey data
{

*Digital investment
winsor dig_invest, gen(w99_dig_invest) p(0.01) highonly
winsor dig_invest, gen(w97_dig_invest) p(0.03) highonly
winsor dig_invest, gen(w95_dig_invest) p(0.05) highonly

gen ihs_dig_invest_99 = log(w99_dig_invest + sqrt((w99_dig_invest*w99_dig_invest)+1))
lab var ihs_dig_invest_99 "IHS of digital investment, wins.99th"
gen ihs_dig_invest_97 = log(w97_dig_invest + sqrt((w97_dig_invest*w97_dig_invest)+1))
lab var ihs_dig_invest_97 "IHS of digital investment, wins.97th"
gen ihs_dig_invest_95 = log(w95_dig_invest + sqrt((w95_dig_invest*w95_dig_invest)+1))
lab var ihs_dig_invest_95 "IHS of digital investment, wins.95th"

*Offine marketing investment
winsor mark_invest, gen(w99_mark_invest) p(0.01) highonly
winsor mark_invest, gen(w97_mark_invest) p(0.03) highonly
winsor mark_invest, gen(w95_mark_invest) p(0.05) highonly

gen ihs_mark_invest_99 = log(w99_mark_invest + sqrt((w99_mark_invest*w99_mark_invest)+1))
lab var ihs_mark_invest_99 "IHS of offine marketing investment, wins.99th"
gen ihs_mark_invest_97 = log(w97_mark_invest + sqrt((w97_mark_invest*w97_mark_invest)+1))
lab var ihs_mark_invest_97 "IHS of offine marketing investment, wins.97th"
gen ihs_mark_invest_95 = log(w95_mark_invest + sqrt((w95_mark_invest*w95_mark_invest)+1))
lab var ihs_mark_invest_95 "IHS of offine marketing investment, wins.95th"

*Full time employees
winsor fte, gen(w99_fte) p(0.01) highonly
winsor fte, gen(w97_fte) p(0.03) highonly
winsor fte, gen(w95_fte) p(0.05) highonly

gen ihs_fte_99 = log(w99_fte + sqrt((w99_fte*w99_fte)+1))
lab var ihs_fte_99 "IHS of full time employees, wins.99th"
gen ihs_fte_97 = log(w97_fte + sqrt((w97_fte*w97_fte)+1))
lab var ihs_fte_97 "IHS of full time employees, wins.97th"
gen ihs_fte_95 = log(w95_fte + sqrt((w95_fte*w95_fte)+1))
lab var ihs_fte_95 "IHS of full time employees, wins.95th"

*Female employees
winsor fte_femmes, gen(w99_fte_femmes) p(0.01) highonly
winsor fte_femmes, gen(w97_fte_femmes) p(0.03) highonly
winsor fte_femmes, gen(w95_fte_femmes) p(0.05) highonly

gen ihs_fte_femmes_99 = log(w99_fte_femmes + sqrt((w99_fte_femmes*w99_fte_femmes)+1))
lab var ihs_fte_femmes_99 "IHS of female employees, wins.99th"
gen ihs_fte_femmes_97 = log(w97_fte_femmes + sqrt((w97_fte_femmes*w97_fte_femmes)+1))
lab var ihs_fte_femmes_97 "IHS of female employees, wins.97th"
gen ihs_fte_femmes_95 = log(w95_fte_femmes + sqrt((w95_fte_femmes*w95_fte_femmes)+1))
lab var ihs_fte_femmes_95 "IHS of female employees, wins.95th"

*Young employees
winsor car_carempl_div2 if surveyround ==3, gen(w99_fte_young) p(0.01) highonly
winsor car_carempl_div2 if surveyround ==3, gen(w97_fte_young) p(0.03) highonly
winsor car_carempl_div2 if surveyround ==3, gen(w95_fte_young) p(0.05) highonly

gen ihs_fte_young_99 = log(w99_fte_young + sqrt((w99_fte_young*w99_fte_young)+1))
lab var ihs_fte_young_99 "IHS of young employees, wins.99th"
gen ihs_fte_young_97 = log(w97_fte_young + sqrt((w97_fte_young*w97_fte_young)+1))
lab var ihs_fte_young_97 "IHS of young employees, wins.97th"
gen ihs_fte_young_95 = log(w95_fte_young + sqrt((w95_fte_young*w95_fte_young)+1))
lab var ihs_fte_young_95 "IHS of young employees, wins.95th"

*clients_b2b
winsor clients_b2b if surveyround==3, gen(w99_clients_b2b) p(0.01)
winsor clients_b2b if surveyround==3, gen(w97_clients_b2b) p(0.03) 
winsor clients_b2b if surveyround==3, gen(w95_clients_b2b) p(0.05) 

gen ihs_clients_b2b_99 = log(w99_clients_b2b + sqrt((w99_clients_b2b*w99_clients_b2b)+1))
lab var ihs_clients_b2b_99 "IHS of number of international companies, wins.99th"
gen ihs_clients_b2b_97 = log(w97_clients_b2b + sqrt((w97_clients_b2b*w97_clients_b2b)+1))
lab var ihs_clients_b2b_97 "IHS of number of international companies, wins.97th"
gen ihs_clients_b2b_95 = log(w95_clients_b2b + sqrt((w95_clients_b2b*w95_clients_b2b)+1))
lab var ihs_clients_b2b_95 "IHS of number of international companies, wins.95th"

*dig_empl
winsor dig_empl, gen(w99_dig_empl) p(0.01)
winsor dig_empl, gen(w97_dig_empl) p(0.03) 
winsor dig_empl, gen(w95_dig_empl) p(0.05) 

gen ihs_dig_empl_99 = log(w99_dig_empl + sqrt((w99_dig_empl*w99_dig_empl)+1))
lab var ihs_dig_empl_99 "IHS of number of digital employees, wins.99th"
gen ihs_dig_empl_97 = log(w97_dig_empl + sqrt((w97_dig_empl*w97_dig_empl)+1))
lab var ihs_dig_empl_97 "IHS of number of digital employees, wins.97th"
gen ihs_dig_empl_95 = log(w95_dig_empl + sqrt((w95_dig_empl*w95_dig_empl)+1))
lab var ihs_dig_empl_95 "IHS of number of digital employees, wins.95th"


*clients_b2c
*winsor clients_b2c, gen(w99_clients_b2c) p(0.01) 
winsor clients_b2c, gen(w97_clients_b2c) p(0.03) 
winsor clients_b2c, gen(w95_clients_b2c) p(0.05) 

*gen ihs_clients_b2c_99 = log(w99_clients_b2c + sqrt((w99_clients_b2c*w99_clients_b2c)+1))
*lab var ihs_clients_b2c_99 "IHS of number of international orders, wins.99th"
gen ihs_clients_b2c_97 = log(w97_clients_b2c + sqrt((w97_clients_b2c*w97_clients_b2c)+1))
lab var ihs_clients_b2c_97 "IHS of number of international orders, wins.97th"
gen ihs_clients_b2c_95 = log(w95_clients_b2c + sqrt((w95_clients_b2c*w95_clients_b2c)+1))
lab var ihs_clients_b2c_95 "IHS of number of international orders, wins.95th"

*Total turnover variable
	*In 2023, 2020
winsor sales, gen(w99_sales) p(0.01) highonly
winsor sales, gen(w97_sales) p(0.03) highonly
winsor sales, gen(w95_sales) p(0.05) highonly

gen w99_sales_ihs = log(w99_sales + sqrt((w99_sales*w99_sales)+1))
lab var w99_sales_ihs "IHS total turnover, wins.99th"
gen w97_sales_ihs = log(w97_sales + sqrt((w97_sales*w97_sales)+1))
lab var w97_sales_ihs "IHS total turnover, wins.97th"
gen w95_sales_ihs = log(w95_sales + sqrt((w95_sales*w95_sales)+1))
lab var w95_sales_ihs "IHS total turnover, wins.95th"

	*In 2024
*winsor comp_ca2024, gen(w99_comp_ca2024) p(0.01) highonly
winsor comp_ca2024, gen(w97_comp_ca2024) p(0.03) highonly
winsor comp_ca2024, gen(w95_comp_ca2024) p(0.05) highonly

*gen ihs_ca99_2024 = log(w99_comp_ca2024 + sqrt((w99_comp_ca2024*w99_comp_ca2024)+1))
*lab var ihs_ca99_2024 "IHS of total turnover in 2024, wins.99th"
gen ihs_ca97_2024 = log(w97_comp_ca2024 + sqrt((w97_comp_ca2024*w97_comp_ca2024)+1))
lab var ihs_ca97_2024 "IHS of total turnover in 2024, wins.97th"
gen ihs_ca95_2024 = log(w95_comp_ca2024 + sqrt((w95_comp_ca2024*w95_comp_ca2024)+1))
lab var ihs_ca95_2024 "IHS of total turnover in 2024, wins.95th"


*Export turnover variable
	*In 2023, 2020
winsor export, gen(w99_export) p(0.01) highonly
winsor export, gen(w97_export) p(0.03) highonly
winsor export, gen(w95_export) p(0.05) highonly

gen w99_export_ihs = log(w99_export + sqrt((w99_export*w99_export)+1))
lab var w99_export_ihs "IHS exports, wins.99th"
gen w97_export_ihs = log(w97_export + sqrt((w97_export*w97_export)+1))
lab var w97_export_ihs "IHS exports, wins.97th"
gen w95_export_ihs = log(w95_export + sqrt((w95_export*w95_export)+1))
lab var w95_export_ihs "IHS exports, wins.95th"

	*In 2024
winsor compexp_2024, gen(w99_compexp2024) p(0.01) highonly
winsor compexp_2024, gen(w97_compexp2024) p(0.03) highonly
winsor compexp_2024, gen(w95_compexp2024) p(0.05) highonly

*gen ihs_exports99_2024 = log(w99_compexp2024 + sqrt((w99_compexp2024*w99_compexp2024)+1))
*lab var ihs_exports99_2024 "IHS of exports in 2024, wins.99th"
gen ihs_exports97_2024 = log(w97_compexp2024 + sqrt((w97_compexp2024*w97_compexp2024)+1))
lab var ihs_exports97_2024 "IHS of exports in 2024, wins.97th"
gen ihs_exports95_2024 = log(w95_compexp2024 + sqrt((w95_compexp2024*w95_compexp2024)+1))
lab var ihs_exports95_2024 "IHS of exports in 2024, wins.95th"

winsor exp_pays, gen(w99_exp_pays) p(0.01) highonly
winsor exp_pays, gen(w95_exp_pays) p(0.05) highonly
	
*Profit variable
	*In 2023, 2020
winsor profit, gen(w99_profit) p(0.01)
winsor profit, gen(w97_profit) p(0.03)
winsor profit, gen(w95_profit) p(0.05)

gen w99_profit_ihs = log(w99_profit + sqrt((w99_profit*w99_profit)+1))
lab var w99_profit_ihs "IHS profit, wins.99th"
gen w97_profit_ihs = log(w97_profit + sqrt((w97_profit*w97_profit)+1))
lab var w97_profit_ihs "IHS profit, wins.97th"
gen w95_profit_ihs = log(w95_profit + sqrt((w95_profit*w95_profit)+1))
lab var w95_profit_ihs "IHS profit, wins.95th"

	*In 2024
winsor comp_benefice2024, gen(w99_comp_benefice2024) p(0.01)
winsor comp_benefice2024, gen(w97_comp_benefice2024) p(0.03)
winsor comp_benefice2024, gen(w95_comp_benefice2024) p(0.05)

gen ihs_profit99_2024 = log(w99_comp_benefice2024 + sqrt((w99_comp_benefice2024*w99_comp_benefice2024)+1))
lab var ihs_profit99_2024 "IHS of profit in 2024, wins.99th"
gen ihs_profit97_2024 = log(w97_comp_benefice2024 + sqrt((w97_comp_benefice2024*w97_comp_benefice2024)+1))
lab var ihs_profit97_2024 "IHS of profit in 2024, wins.97th"
gen ihs_profit95_2024 = log(w95_comp_benefice2024 + sqrt((w95_comp_benefice2024*w95_comp_benefice2024)+1))
lab var ihs_profit95_2024 "IHS of profit in 2024, wins.95th"

*Cost variable
* Generating a cost variable
gen cost_2020 = comp_ca2020 - comp_benefice2020 if surveyround ==1
lab var cost_2020 "Total costs in 2020 in TND"

gen cost = sales - profit if surveyround ==3
lab var cost "Total costs in TND"

gen cost_2024 = comp_ca2024 - comp_benefice2024 if surveyround ==3
lab var cost_2024 "Total costs in 2024 in TND"

winsor cost_2020, gen(w99_cost_2020) p(0.01) highonly
winsor cost_2020, gen(w97_cost_2020) p(0.03) highonly
winsor cost_2020, gen(w95_cost_2020) p(0.05) highonly

gen ihs_cost99_2020 = log(w99_cost_2020 + sqrt((w99_cost_2020*w99_cost_2020)+1))
lab var ihs_cost99_2020 "IHS of total costs in 2020, wins.99th"
gen ihs_cost97_2020 = log(w97_cost_2020 + sqrt((w97_cost_2020*w97_cost_2020)+1))
lab var ihs_cost97_2020 "IHS of total costs in 2020, wins.97th"
gen ihs_cost95_2020 = log(w95_cost_2020 + sqrt((w95_cost_2020*w95_cost_2020)+1))
lab var ihs_cost95_2020 "IHS of total costs in 2020, wins.95th"

*winsor cost, gen(w99_cost) p(0.01) highonly
winsor cost, gen(w97_cost) p(0.03) highonly
winsor cost, gen(w95_cost) p(0.05) highonly

gen w_99_cost_ihs = log(w99_cost + sqrt((w99_cost*w99_cost)+1))
lab var w_99_cost_ihs "IHS costs, wins.99th"
gen w_97_cost_ihs = log(w97_cost + sqrt((w97_cost*w97_cost)+1))
lab var w_97_cost_ihs "IHS costs, wins.97th"
gen w_95_cost_ihs = log(w95_cost + sqrt((w95_cost*w95_cost)+1))
lab var w_95_cost_ihs "IHS costs, wins.95th"

*winsor cost_2024, gen(w99_cost_2024) p(0.01) highonly
winsor cost_2024, gen(w97_cost_2024) p(0.03) highonly
winsor cost_2024, gen(w95_cost_2024) p(0.05) highonly

*gen ihs_cost99_2024 = log(w99_cost_2024 + sqrt((w99_cost_2024*w99_cost_2024)+1))
*lab var ihs_cost99_2024 "IHS of total costs in 2024, wins.99th"
gen ihs_cost97_2024 = log(w97_cost_2024 + sqrt((w97_cost_2024*w97_cost_2024)+1))
lab var ihs_cost97_2024 "IHS of total costs in 2024, wins.97th"
gen ihs_cost95_2024 = log(w95_cost_2024 + sqrt((w95_cost_2024*w95_cost_2024)+1))
lab var ihs_cost95_2024 "IHS of total costs in 2024, wins.95th"
}

	* manually collected website and social media data
{
*Winsorizing and IHS transformation of likes and followers data
local sm_data facebook_likes facebook_subs facebook_reviews
foreach var of local sm_data{
winsor `var', gen(w_`var') p(0.01) highonly
ihstrans w_`var'
}

*no winsorizing needed for this one
ihstrans insta_subs

lab var ihs_w_facebook_likes "no. of FB likes, winsorized 99th and IHS transformed"
lab var ihs_w_facebook_subs "no. of FB followers, winsorized 99th and IHS transformed"
lab var ihs_w_facebook_reviews "no. of FB reviews, winsorized 99th and IHS transformed"
lab var ihs_insta_subs "no. of instagram followers, IHS transformed"
}
*/

}


***********************************************************************
* PART 4: Index Creation
***********************************************************************
{
* Put all variables used to calculate indices into a local
{
	
		* E-commerce knowledge index
local knowledge_bl "dig_con1 dig_con2 dig_con3 dig_con4 dig_con5"
local knowledge_ml "dig_con1_ml dig_con2_ml dig_con3_ml dig_con4_ml dig_con5_ml"
local knowledge "`knowledge_bl' `knowledge_ml'"
		
		* E-commerce adoption index
			* Survey response data
				* Visibility/Presence
local presence_survey "dig_presence1 dig_presence2 dig_presence3"

				* Use: Website + Social media
local website_use_survey "dig_miseajour1 dig_description1 web_use_catalogue web_use_engagement web_use_com web_use_contacts web_use_brand dig_service_satisfaction"

local sm_use_survey "dig_miseajour2 dig_description2 sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand"

local use_survey "`website_use_survey' `sm_use_survey' dig_miseajour3 dig_description3"
				
				* Payment: Website + Social media + Platform
local payment_survey "dig_payment2 dig_payment3" // dig_payment1 at endline is offline payment
				
				* Digital Marketing
local dmi "mark_online1 mark_online2 mark_online3 mark_online4 mark_online5 dig_marketing_score dig_dummy dig_marketing_dummy dig_marketing_num19_sea dig_marketing_num19_seo dig_marketing_num19_blg dig_marketing_num19_pub dig_marketing_num19_mail dig_marketing_num19_prtn dig_marketing_num19_socm" // dig_marketing_lien dig_marketing_ind1 dig_marketing_ind2 are excluded as they have unclear missing values for BL & ML (FM 11.03.25)

			
			* Manually collected data
				* Visibility/Presence
local presence_manual "entreprise_web entreprise_social social_facebook social_insta"

				* Use: Website + Social media + Insta + Facebook
local use_manual_website "web_logoname web_product web_multimedia web_aboutus web_norms web_externals web_languages web_coherent web_quality"
local use_manual_sm "social_logoname social_external_website social_photos social_description"
local use_manual_facebook "facebook_likes facebook_subs facebook_reviews facebook_reviews_avg"
local use_manual_insta "insta_publications insta_subs insta_description insta_externals"
local use_manual "`use_manual_website' `use_manual_sm' `use_manual_facebook' `use_manual_insta'"	
				
				* Payment: Website + Social media + Platform
local payment_manual "web_purchase web_external_purchase facebook_shop"

		* E-commerce perception
local perception "dig_perception1 dig_perception2 dig_perception3 dig_perception4 dig_perception5 dig_barr1 dig_barr2 dig_barr3 dig_barr4 dig_barr5 dig_barr6 dig_barr7"

		
		* Export readiness
local eri "exp_pra_foire exp_pra_sci exp_pra_norme exp_pra_vent exp_pra_ach expprep_cible expprep_demande expprep_dummy expprep_responsable expprep_norme"		

		* Business performance
local bpi "fte sales profit comp_ca2024 comp_benefice2024"


local all_indexes `knowledge' `presence_survey' `presence_manual' `use_survey' `use_manual' `payment_survey' `payment_manual' `dmi' `perception' `eri' `bpi'
}


	* Create temporary variable
foreach var of local all_indexes {
	g t_`var' = `var'
    replace t_`var' = . if `var' == 999 // don't know transformed to missing values
    replace t_`var' = . if `var' == 888 
    replace t_`var' = . if `var' == 777 
    replace t_`var' = . if `var' == 666 
	replace t_`var' = . if `var' == -999 // added - since we transformed profit into negative in endline
    replace t_`var' = . if `var' == -888
    replace t_`var' = . if `var' == -777
    replace t_`var' = . if `var' == -666
    replace t_`var' = . if `var' == 1234 
}

	* calculate z-score for each individual outcome
		* write a program calculates the z-score
			* if you re-run the code, execture before: 
capture program drop zscore
program define zscore /* opens a program called zscore */
	sum `1' if treatment == 0 & surveyround == `2'
	gen `1'z`2' = (`1' - r(mean))/r(sd) /* new variable gen is called --> varnamez */
end


		* create empty variable that will be replaced with z-scores
foreach var of local all_indexes {
	g t_`var'z = .
	
}
		* calculate z-score surveyround & variable specific
levelsof surveyround, local(survey)
foreach s of local survey {
			* calcuate the z-score for each variable
	foreach var of local all_indexes {
		zscore t_`var' `s'
		replace t_`var'z = t_`var'z`s' if surveyround == `s'
		drop t_`var'z`s'
	}
}	
		
* Generate the index value: average of absolute values, zscores, high dummies
{
* Knowledge Index
drop knowledge
egen knowledge = rowmean(t_dig_con1z t_dig_con2z t_dig_con3z t_dig_con4z t_dig_con5z t_dig_con1_mlz t_dig_con2_mlz t_dig_con3_mlz t_dig_con4_mlz t_dig_con5_mlz)

egen knowledge_cont = rowtotal(dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con1_ml dig_con2_ml dig_con3_ml dig_con4_ml dig_con5_ml), missing

sum knowledge_cont if surveyround == 2, d
gen knowledge_high = (knowledge_cont >= `r(p50)')
	replace knowledge_high = . if knowledge_cont == .

* Visibility/Presence
egen presence_survey = rowmean(t_dig_presence1z t_dig_presence2z t_dig_presence3z)

egen presence_survey_cont = rowtotal(dig_presence1 dig_presence2 dig_presence3)

sum presence_survey_cont if surveyround == 3, d
gen presence_survey_high = (presence_survey_cont >= `r(p50)')
replace presence_survey_high = . if presence_survey_cont == .


egen presence_manual = rowmean(t_entreprise_webz t_entreprise_socialz t_social_facebookz t_social_instaz)

egen presence_manual_cont = rowtotal(entreprise_web entreprise_social social_facebook social_insta), missing

sum presence_manual_cont if surveyround == 3, d
gen presence_manual_high = (presence_manual_cont >= `r(p50)')
replace presence_manual_high = . if presence_manual_cont == .

* Use - Social Media
egen use_sm_survey = rowmean(t_sm_use_contactsz t_sm_use_cataloguez t_sm_use_engagementz t_sm_use_comz t_sm_use_brandz t_dig_miseajour2z)
egen use_sm_survey_cont = rowtotal(sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand dig_miseajour2), missing

sum use_sm_survey_cont if surveyround == 3, d
gen use_sm_survey_high = (use_sm_survey_cont >= `r(p50)')
replace use_sm_survey_high = . if use_sm_survey_cont == .

egen use_sm_manual = rowmean(t_social_logonamez t_social_external_websitez t_social_photosz t_social_descriptionz)
egen use_sm_manual_cont = rowmean(social_logoname social_external_website social_photos social_description)
sum use_sm_manual_cont if surveyround == 3, d
gen use_sm_manual_high = (use_sm_manual_cont >= `r(p50)')
replace use_sm_manual_high = . if use_sm_manual_cont == .

* Use - Website
egen use_website_survey = rowmean(t_web_use_contactsz t_web_use_cataloguez t_web_use_engagementz t_web_use_comz t_web_use_brandz t_dig_miseajour1z)
egen use_website_survey_cont = rowtotal(web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand dig_miseajour1), missing

sum use_website_survey_cont if surveyround == 3, d
gen use_website_survey_high = (use_website_survey_cont >= `r(p50)')
replace use_website_survey_high = . if use_website_survey_cont == .

egen use_website_manual = rowmean(t_web_logonamez t_web_productz t_web_multimediaz t_web_aboutusz t_web_normsz t_web_externalsz t_web_languagesz t_web_coherentz t_web_qualityz)
egen use_website_manual_cont = rowtotal(web_logoname web_product web_multimedia web_aboutus web_norms web_externals web_languages web_coherent web_quality), missing

sum use_website_manual_cont if surveyround == 3, d
gen use_website_manual_high = (use_website_manual_cont >= `r(p50)')
replace use_website_manual_high = . if use_website_manual_cont == .

* Use - Facebook
egen use_fb_manual = rowmean(t_facebook_likesz t_facebook_subsz t_facebook_reviewsz t_facebook_reviews_avgz)


* Use - Instagram
egen use_insta_manual = rowmean(t_insta_publicationsz t_insta_subsz t_insta_descriptionz t_insta_externalsz)


* Use - Overall
egen use_survey = rowmean(t_web_use_contactsz t_web_use_cataloguez t_web_use_engagementz t_web_use_comz t_web_use_brandz t_sm_use_contactsz t_sm_use_cataloguez t_sm_use_engagementz t_sm_use_comz t_sm_use_brandz t_dig_miseajour1z t_dig_miseajour2z t_dig_miseajour3z)

egen use_survey_cont = rowtotal(web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand dig_miseajour1 dig_miseajour2 dig_miseajour3), missing

sum use_survey_cont if surveyround == 3, d
gen use_survey_high = (use_survey_cont >= `r(p50)')
	replace use_survey_high = . if use_survey_cont == .

egen use_manual = rowmean(t_social_logonamez t_social_external_websitez t_social_photosz t_social_descriptionz t_web_logonamez t_web_productz t_web_multimediaz t_web_aboutusz t_web_normsz t_web_externalsz t_web_languagesz t_web_coherentz t_web_qualityz t_facebook_likesz t_facebook_subsz t_facebook_reviewsz t_facebook_reviews_avgz t_insta_publicationsz t_insta_subsz t_insta_descriptionz t_insta_externalsz)

egen use_manual_cont = rowmean(social_logoname social_external_website social_photos social_description web_logoname web_product web_multimedia web_aboutus web_norms web_externals web_languages web_coherent web_quality insta_description insta_externals)

sum use_manual_cont if surveyround == 3, d
gen use_manual_high = (use_manual_cont >= `r(p50)')
	replace use_manual_high = . if use_manual_cont == .

* Payment
egen payment_survey = rowmean(t_dig_payment2z t_dig_payment3z)
egen payment_survey_cont = rowtotal(dig_payment2 dig_payment3), missing

sum payment_survey_cont if surveyround == 3, d
gen payment_survey_high = (payment_survey_cont >= `r(p50)')
	replace payment_survey_high = . if payment_survey_cont == .

egen payment_manual = rowmean(t_web_purchasez t_web_external_purchasez t_facebook_shopz)
egen payment_manual_cont = rowtotal(web_purchase web_external_purchase facebook_shop), missing

sum payment_manual_cont if surveyround == 3, d
gen payment_manual_high = (payment_manual_cont >= `r(p50)')
	replace payment_manual_high = . if payment_manual_cont == .

* Digital Marketing
egen dmi = rowmean(t_mark_online1z t_mark_online2z t_mark_online3z t_mark_online4z t_dig_dummyz t_dig_marketing_dummyz t_dig_marketing_num19_seaz t_dig_marketing_num19_seoz t_dig_marketing_num19_blgz t_dig_marketing_num19_pubz t_dig_marketing_num19_mailz t_dig_marketing_num19_prtnz t_dig_marketing_num19_socmz)

egen dmi_cont = rowtotal(mark_online1 mark_online2 mark_online3 mark_online4 dig_dummy dig_marketing_dummy dig_marketing_num19_sea dig_marketing_num19_seo dig_marketing_num19_blg dig_marketing_num19_pub dig_marketing_num19_mail dig_marketing_num19_prtn dig_marketing_num19_socm), missing

sum dmi_cont if surveyround == 3, d
gen dmi_high = (dmi_cont >= `r(p50)')
replace dmi_high = . if dmi_cont == .

* Adoption Index
egen dtai_survey = rowmean(t_dig_presence1z t_dig_presence2z t_dig_presence3z t_dig_payment2z t_dig_payment3z t_web_use_contactsz t_web_use_cataloguez t_web_use_engagementz t_web_use_comz t_web_use_brandz t_sm_use_contactsz t_sm_use_cataloguez t_sm_use_engagementz t_sm_use_comz t_sm_use_brandz t_dig_miseajour1z t_dig_miseajour2z t_dig_miseajour3z)

egen dtai_survey_cont = rowtotal(dig_presence1 dig_presence2 dig_presence3 dig_payment2 dig_payment3 web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand dig_miseajour1 dig_miseajour2 dig_miseajour3), missing

sum dtai_survey_cont if surveyround == 3, d
gen dtai_survey_high = (dtai_survey_cont >= `r(p50)')
	replace dtai_survey_high = . if dtai_survey_cont == .

egen dtai_manual = rowmean(t_entreprise_webz t_entreprise_socialz t_social_facebookz t_social_instaz t_social_logonamez t_social_external_websitez t_social_photosz t_social_descriptionz t_web_logonamez t_web_productz t_web_multimediaz t_web_aboutusz t_web_normsz t_web_externalsz t_web_languagesz t_web_coherentz t_web_qualityz t_facebook_likesz t_facebook_subsz t_facebook_reviewsz t_facebook_reviews_avgz t_insta_publicationsz t_insta_subsz t_insta_descriptionz t_insta_externalsz)

egen dtai_manual_cont = rowmean(entreprise_web entreprise_social social_facebook social_insta social_logoname social_external_website social_photos social_description web_logoname web_product web_multimedia web_aboutus web_norms web_externals web_languages web_coherent web_quality insta_description insta_externals)

sum dtai_manual_cont if surveyround == 3, d
gen dtai_manual_high = (dtai_manual_cont >= `r(p50)')
	replace dtai_manual_high = . if dtai_manual_cont == .

* E-commerce perception
egen perception = rowmean(t_dig_perception1z t_dig_perception2z t_dig_perception3z t_dig_perception4z t_dig_perception5z t_dig_barr1z t_dig_barr2z t_dig_barr3z t_dig_barr4z t_dig_barr5z t_dig_barr6z t_dig_barr7z)
egen perception_cont = rowmean(dig_perception1 dig_perception2 dig_perception3 dig_perception4 dig_perception5 dig_barr1 dig_barr2 dig_barr3 dig_barr4 dig_barr5 dig_barr6 dig_barr7)

sum perception_cont if surveyround == 3, d
gen perception_high = (perception_cont >= `r(p50)')
	replace perception_high = . if perception_cont == .

* Export readiness
egen eri = rowmean(t_exp_pra_foirez t_exp_pra_sciz t_exp_pra_normez t_exp_pra_ventz t_exp_pra_achz t_expprep_ciblez t_expprep_responsablez t_expprep_normez t_expprep_demandez t_expprep_dummyz)

egen eri_cont = rowtotal(exp_pra_foire exp_pra_sci exp_pra_norme exp_pra_vent exp_pra_ach expprep_cible expprep_responsable expprep_norme expprep_demande expprep_dummy), missing

sum eri_cont if surveyround == 3, d
gen eri_high = (eri_cont >= `r(p50)')
	replace eri_high = . if eri_cont == .

	
* Business performance index
egen bpi = rowmean(t_ftez t_salesz t_profitz)
egen bpi_2024 = rowmean(t_ftez t_comp_ca2024z t_comp_benefice2024z)
		
		
		* labeling
* Knowledge
label var knowledge         "E-commerce knowledge"
label var knowledge_cont     "E-commerce knowledge"
label var knowledge_high    "E-commerce knowledge"

* Presence / Visibility
label var presence_survey       "E-commerce presence"
label var presence_survey_cont   "E-commerce presence"
label var presence_survey_high  "E-commerce presence"

label var presence_manual       "E-commerce presence"
label var presence_manual_cont   "E-commerce presence"
label var presence_manual_high  "E-commerce presence"

* Use - Overall
label var use_survey        "E-commerce use"
label var use_survey_cont    "E-commerce use"
label var use_survey_high   "E-commerce use"

label var use_manual        "E-commerce use"
label var use_manual_cont    "E-commerce use"
label var use_manual_high   "E-commerce use"

* Use - Social Media
label var use_sm_survey         "Social media use"
label var use_sm_survey_cont     "Social media use"
label var use_sm_survey_high    "Social media use"

label var use_sm_manual         "Social media use"
label var use_sm_manual_cont     "Social media use"
label var use_sm_manual_high    "Social media use"

* Use - Website
label var use_website_survey        "Website use"
label var use_website_survey_cont    "Website use"
label var use_website_survey_high   "Website use"

label var use_website_manual        "Website use"
label var use_website_manual_cont    "Website use"
label var use_website_manual_high   "Website use"

* Use - Facebook
label var use_fb_manual        "Facebook use"


* Use - Instagram
label var use_insta_manual        "Instagram use"


* Payment
label var payment_survey        "E-commerce payment"
label var payment_survey_cont    "E-commerce payment"
label var payment_survey_high   "E-commerce payment"

label var payment_manual        "E-commerce payment"
label var payment_manual_cont    "E-commerce payment"
label var payment_manual_high   "E-commerce payment"

* Digital Marketing
label var dmi        "Digital marketing"
label var dmi_cont    "Digital marketing"
label var dmi_high   "Digital marketing"

* Adoption Index
label var dtai_survey        "E-commerce adoption"
label var dtai_survey_cont    "E-commerce adoption"
label var dtai_survey_high   "E-commerce adoption"

label var dtai_manual        "E-commerce adoption"
label var dtai_manual_cont    "E-commerce adoption"
label var dtai_manual_high   "E-commerce adoption"

* Perception
label var perception         "E-commerce perception"
label var perception_cont     "E-commerce perception"
label var perception_high    "E-commerce perception"

* Export Readiness
label var eri        "Export readiness"
label var eri_cont    "Export readiness"
label var eri_high   "Export readiness"


label var eri "Export readiness"
label var bpi "BPI 2023"
label var bpi_2024 "BPI 2024"
}

		
*drop torary vars		  
drop t_*


}

***********************************************************************
* PART 5: Survey Attrition
***********************************************************************	
{
* gen refus variable
duplicates tag id_plateforme, gen(dup)
gen el_refus = (dup < 1)
drop dup
replace el_refus=1 if id_plateforme== 82 	
replace el_refus=1 if id_plateforme== 59
replace el_refus=1 if id_plateforme== 63
replace el_refus=1 if id_plateforme== 70
replace el_refus=1 if id_plateforme== 98
replace el_refus=1 if id_plateforme== 114
replace el_refus=1 if id_plateforme== 146
replace el_refus=1 if id_plateforme== 153
replace el_refus=1 if id_plateforme== 176
replace el_refus=1 if id_plateforme== 195
replace el_refus=1 if id_plateforme== 254
replace el_refus=1 if id_plateforme== 264
replace el_refus=1 if id_plateforme== 290
*replace el_refus=1 if id_plateforme== 261 TBC
replace el_refus=1 if id_plateforme== 495
replace el_refus=1 if id_plateforme== 586
*replace el_refus=1 if id_plateforme== 592 TBC
replace el_refus=1 if id_plateforme== 612
*replace el_refus=1 if id_plateforme== 617 TBC
replace el_refus=1 if id_plateforme== 632
replace el_refus=1 if id_plateforme== 637
replace el_refus=1 if id_plateforme== 643
replace el_refus=1 if id_plateforme== 714
replace el_refus=1 if id_plateforme== 729
replace el_refus=1 if id_plateforme== 782
replace el_refus=1 if id_plateforme== 791
replace el_refus=1 if id_plateforme== 818
replace el_refus=1 if id_plateforme== 831
replace el_refus=1 if id_plateforme== 901

}


***********************************************************************
* PART 6: Create an aggregate measure for ssa for treatment firms
***********************************************************************	
{
gen ssa_aggregate = .
replace ssa_aggregate =1 if ssa_action1 == 1 
replace ssa_aggregate =1 if ssa_action2 == 1 
replace ssa_aggregate =1 if ssa_action3 == 1  
replace ssa_aggregate =1 if ssa_action4 == 1 
replace ssa_aggregate =1 if ssa_action5 == 1 
lab var ssa_aggregate "The company responded yes to at least one of the ssa_actions improvements"
label define yesno1 0 "no" 1 "yes" 
label value ssa_aggregate yesno1
}

***********************************************************************
* Part 7: Create growth variabe
***********************************************************************
{
// First, make sure the data is sorted by id_plateforme and surveyround
sort id_plateforme surveyround

// Loop 1: Growth rates between baseline and endline 
foreach var of varlist sales profit export fte car_carempl_div1 car_carempl_div2 {
    
    // Calculate the value for surveyround == 1 and surveyround == 3
    bys id_plateforme (surveyround): gen `var'__1 = `var' if surveyround == 1
    bys id_plateforme (surveyround): gen `var'__3 = `var' if surveyround == 3

    // Forward fill the values for surveyround == 1 and surveyround == 3 across all rows for each id
    bys id_plateforme: egen `var'__1_filled = max(`var'__1)
    bys id_plateforme: egen `var'__3_filled = max(`var'__3)

    // Calculate relative growth rate: (value in survey 3 / value in survey 1) - 1, but only for surveyround == 3
    gen `var'_rel_growth = (`var'__3_filled / `var'__1_filled) - 1 if surveyround == 3 & `var'__1_filled != . & `var'__3_filled != .

    // Calculate absolute growth: value in survey 3 - value in survey 1, but only for surveyround == 3
    gen `var'_abs_growth = `var'__3_filled - `var'__1_filled if surveyround == 3 & `var'__1_filled != . & `var'__3_filled != .

    // Clean up intermediate variables
    drop `var'__1 `var'__3
}


* Generate 'any export action' variable
egen ssa_any = rowmax(ssa_action1 ssa_action2 ssa_action3 ssa_action4 ssa_action5)
lab var ssa_any "Any of the above"
label value ssa_any yesno1

// Loop 1: Growth rates between midline and endline for GIZ indicator (ssa_action)
* only absolute rates because dummyary variables
foreach var of varlist ssa_action1 ssa_action2 ssa_action3 ssa_action4 ssa_action5 ssa_any {
    
    // Calculate the value for surveyround == 1 and surveyround == 3
    bys id_plateforme (surveyround): gen `var'_2 = `var' if surveyround == 2
    bys id_plateforme (surveyround): gen `var'_3 = `var' if surveyround == 3

    // Forward fill the values for surveyround == 1 and surveyround == 3 across all rows for each id
    bys id_plateforme: egen `var'_2_filled = max(`var'_2)
    bys id_plateforme: egen `var'_3_filled = max(`var'_3)

    // Calculate absolute growth: value in survey 3 - value in survey 1, but only for surveyround == 3
    gen `var'_abs_growth = `var'_3_filled - `var'_2_filled if surveyround == 3  & `var'_3_filled != .

    // Clean up intermediate variables
    drop `var'_2 `var'_3
}

*Replace Negative values with missing (firms that reported yes in midline but no in endline) to simplify improve count
foreach var of varlist ssa_action1_abs_growth ssa_action2_abs_growth ssa_action3_abs_growth ssa_action4_abs_growth ssa_action5_abs_growth ssa_any_abs_growth {
    
replace `var' = . if `var' ==-1
}
/*
use links to understand the code syntax for creating the accounting variables' growth rates:
- https://www.stata.com/statalist/archive/2008-10/msg00661.html
- https://www.stata.com/support/faqs/statistics/time-series-operators/

*/


lab var sales_rel_growth "Total sales (% growth)"
lab var sales_abs_growth "Total sales (abs. growth)"
lab var export_rel_growth "Export sales (% growth)"
lab var export_abs_growth "Export sales (abs. growth)"
lab var profit_rel_growth "Profits (% growth)"
lab var profit_abs_growth "Profits (abs. growth)"
lab var fte_rel_growth "Employees (% growth)"
lab var fte_abs_growth "Employees (abs. growth)"
lab var car_carempl_div1_rel_growth "Female Employees (% growth)"
lab var car_carempl_div1_abs_growth "Female Employees (abs. growth)"
lab var car_carempl_div2_rel_growth "Young Employees (% growth)"
lab var car_carempl_div2_abs_growth "Young Employees (abs. growth)"

lab var ssa_action1_abs_growth "Change in Buyer expression of interest"
lab var ssa_action2_abs_growth "Change in Identification commercial partner"
lab var ssa_action3_abs_growth "Change in External export finance"
lab var ssa_action4_abs_growth "Change in Investment in sales structure abroad"
lab var ssa_action5_abs_growth "Change in Digital transaction system"



label define yesno2 0 "no improvement" 1 "improvement"

* Label variables
label values ssa_action1_abs_growth yesno2
label values ssa_action2_abs_growth yesno2
label values ssa_action3_abs_growth yesno2
label values ssa_action4_abs_growth yesno2
label values ssa_action5_abs_growth yesno2
label values ssa_any_abs_growth yesno2


}

***********************************************************************
* 	PART 16: export excel for semrush analysis
***********************************************************************
/*
{
preserve
	keep if surveyround == 1
	merge 1:1 id_plateforme using "${master_pii}/web_information", keepusing(link_web)
		* Remove "http://", "https://", "www.", and "error codes"
	replace link_web ="" if link_web == "-666" | link_web == "-777" | link_web == "-888" | link_web == "-888"
	replace link_web = sudummystr(link_web, "http://", "", .)
	replace link_web = sudummystr(link_web, "https://", "", .)
	replace link_web = sudummystr(link_web, "www.", "", .)
	replace link_web = trim(link_web)
	replace link_web = sudummystr(link_web, " ", "", .)
	
	drop _merge
	keep id_plateforme link_web treatment take_up strata
	save "${master_pii}/semrush.dta", replace
	export excel using "${master_pii}/semrush.xlsx", firstrow(variables) replace
restore
	
}
*/
***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${master_final}/ecommerce_master_final", replace


