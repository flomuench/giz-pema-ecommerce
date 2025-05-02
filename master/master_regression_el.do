***********************************************************************
* 				Master Endline Regression Analysis
***********************************************************************
*																	   
*	PURPOSE: Undertake treatment effect analysis of primary and secondary outcomes
*
*	OUTLINE:														  
*	0)		set the stage
*	1)  	Attrition		
*	2)		Write a program that generates generic regression table
*	3)		Regression table for each variable	
*	4)		Regression table index outcomes	
*	5)		regression table numerical outcomes 
*	6)		regression table employees outcomes	
*	7)		Balance Tables
*																
*	Author:  	Ayoub Chamakhi			         													      
*	id_plateforme variable:	id_plateforme		  			
*	Requires: ecommerce_master_final.dta 	   								
*	Creates:  regression tables			   					
*																	  
***********************************************************************
* 	PART 0: 	set the stage - import data	  
***********************************************************************

use "${master_final}/ecommerce_master_final", clear


* xtset data to enable use of lag operator for inclusion of baseline value of Y
xtset id_plateforme surveyround

*add colors
set scheme s1color

***********************************************************************
* 	PART 0.1:  set the stage - change labels for regression table output
***********************************************************************
lab var take_up "Take-up"
lab val take_up presence


***********************************************************************
* 	PART 0.2:  set the stage - generate missing baseline dummy
***********************************************************************
{

local tech_adop_indexes "knowledge dtai_manual dtai_survey" 

local tech_adop_subindexes "presence_manual presence_survey payment_manual payment_survey use_manual use_survey use_website_manual use_website_survey use_sm_manual use_sm_survey use_fb_manual use_insta_manual dmi"

local tech_perf "dig_empl dig_dummy dig_revenues_ecom dig_rev_extmargin dig_revenues_ecom_w99 dig_revenues_ecom_w95 ihs_dig_revenues_ecom ihs_dig_empl dig_empl_w99 dig_empl_w95 dig_rev_extmargin2 dtai_survey_cont dtai_manual_cont"

local tech_perc "perception investecom_benefit1 investecom_benefit2"

local sales "sales sales_w95 sales_w99 ihs_sales sales_rel_growth sales_abs_growth "
local profit "profit profit_w95 profit_w99 ihs_profit profit_rel_growth profit_abs_growth profit_pos profit_2024_pos"
local export "eri eri_cont exported export export_w95 export_w99 ihs_export export_rel_growth export_abs_growth"
local empl "fte fte_w95 fte_w99 ihs_fte fte_rel_growth fte_abs_growth"
local firm_perf "`sales' `profit' `export' `empl' bpi"

	 	 
local outcomes "`tech_adop_indexes' `tech_adop_subindexes' `tech_perf' `tech_perc' `firm_perf'"

foreach var of local outcomes {
	
	bys id_plateforme (surveyround): gen t_miss_bl_`var' = (`var' == .) if surveyround == 1
	
	egen miss_bl_`var' = min(t_miss_bl_`var'), by(id_plateforme)
	
	replace `var' = 0 if surveyround == 1 & miss_bl_`var' == 1

	drop t_miss_bl_`var'
	}

}

***********************************************************************
* 	PART 0.3:  balance table
***********************************************************************
{
{
gen uni = (car_pdg_educ == 5)
	replace uni = . if car_pdg_educ == .
	
gen small_firm = (fte <= 20)
	replace small_firm = . if fte == .
	
gen large_firm = (fte > 75)
	replace large_firm = . if fte == .
	
gen profitable_2020 = (comp_benefice2020 > 0)
	replace profitable_2020 = . if comp_benefice2020 == .
	
gen investcom_2021_pos = (investcom_2021 > 0)
	replace investcom_2021_pos = . if investcom_2021 == .

tab treatment_email, gen(treatment_email)
forvalues x = 1(1)3 {
	replace treatment_email`x' = . if treatment_email == .
	}
	
}

	* BASELINE Balance
			*Business performance
lab var fte "Employees"
lab var fte_w99 "Employees, wins. 99th pct."
lab var profit "Profit"
lab var profit_w99 "Profit, wins. 1st & 99th pct."
lab var sales "Sales"
lab var sales_w99 "Sales, wins. 99th pct."
lab var car_credit1 "Access to credit [1-10]"
lab var dig_revenues_ecom "Online sales"
lab var dig_revenues_ecom_w99 "Online sales, wins. 99th pct."
lab var dig_empl "Employees working on online business"
lab var dig_empl_w99 "Employees working on online business"
lab var export "Export sales"

			* KPIs
local bpi "fte fte_w99 profit profit_w99 sales sales_w99 export exported car_credit1"

			*Digital
local dsi "presence_survey_cont presence_manual_cont use_survey_cont use_manual_cont payment_manual_cont payment_survey_cont knowledge_cont dig_revenues_ecom dig_revenues_ecom_w99 dig_empl dig_empl_w99"

	
*codebook `dsi' `bpi' if surveyround == 1

*local all `bpi' `dsi'
foreach fmt in tex xlsx {				
					* KPIs
iebaltab `bpi' if surveyround == 1, ///
	grpvar(treatment) vce(robust) format(%12.2fc) replace ///
	rowvarlabels ///
	stats(desc(sd) pair(p)) ///
	addnote("Significance: ***=.01, **=.05, *=.1. Errors are robust. 'Sales', 'Profit' and 'Export sales' are in Tunisian Dinar. 'Access to credit' is self-reported.") ///
	save`fmt'("${bal}/bl_baltab_ecom_kpis.`fmt'")


					* Digital
iebaltab `dsi' if surveyround == 1, ///
	grpvar(treatment) vce(robust) format(%12.2fc) replace ///
	rowvarlabels ///
	stats(desc(sd) pair(p)) ///
	addnote("Significance: ***=.01, **=.05, *=.1. Errors are robust.'Survey' indicates data is collected in online baseline survey, while 'manual' indicates data is collected via manual scoring of firms digital profiles. 'Online sales' are in Tunisian Dinar.") ///
	save`fmt'("${bal}/bl_baltab_ecom_digital.`fmt'")
}
	
{
	* endline by take_up: Do any BL covariates predict take-up?
{
* put variables into locals
		* Digital Technology Adoption
local dig_tech "knowledge dtai_manual dtai_survey presence_manual presence_survey use_website_survey use_website_manual use_sm_survey use_sm_manual use_fb_manual use_insta_manual dmi" // 

local firm "w95_comp_ca2020 w95_compexp2020 exporter2020 ever_exported w95_comp_benefice2020 profitable_2020 fte small_firm large_firm rg_age fte_femmes female_share rg_gender_pdg entr_bien_service"

local dig_perc "investcom_futur investcom_2021 investcom_2021_pos investcom_benefit1 investcom_benefit2 car_credit1"

local car "car_adop_peer car_ecom_prive car_pdg_age car_risque car_soutien_gouvern uni treatment_email1 treatment_email2 treatment_email3" // car_pdg_educ

local sector "agri artisanat commerce_int industrie service tic"

local all "`dig_tech' `firm' `dig_perc' `car' `sector'"

foreach fmt in tex xlsx {

iebaltab `all' if surveyround == 1 & treatment == 1, ///
	grpvar(take_up) vce(robust) format(%15.2fc) replace ///
	rowvarlabels  ///
	save`fmt'("${take_up}/takeup_bal_ecom_long.`fmt'")
}
}

* add code for table for paper?


{
	* baseline
		* concern: F-test significant at baseline
				* major outcome variables, untransformed
			*Digital sales
local dsi "dig_margins dig_revenues_ecom"
	
			*Digital marketing 
local dmi "dig_empl dig_invest mark_invest"
	
			*Export performance
local epi "compexp_2023 compexp_2024 export_1 export_2 exp_pays clients_b2c clients_b2b exp_dig"			
			
			*Business performance
local bpi "fte fte_femmes car_carempl_div2 comp_ca2023 comp_ca2024 cost_2023 cost_2024 comp_benefice2023 comp_benefice2024"

local all_index_untransformed `dsi' `dmi' `epi' `bpi'
				
					* F-test
iebaltab `all_index_untransformed' if surveyround == 3 & treatment == 1, ///
	grpvar(take_up) vce(robust) format(%12.2fc) replace ///
	ftest rowvarlabels ///
	savetex(el_takeup_baltab_bl_unadj)

				* major outcome variables, transformed
*Digital sales
local dsi "dig_margins ihs_digrev_99"
	
			*Digital marketing 
local dmi "w99_dig_empl w99_dig_invest w99_mark_invest"
	
			*Export performance
local epi "ihs_exports99_2023 ihs_exports97_2024 export_1 export_2 exp_pays ihs_clients_b2c_97 ihs_clients_b2b_99 exp_dig"			
			
			*Business performance
local bpi "ihs_fte_99 ihs_fte_femmes_99 ihs_fte_young_99 w99_comp_ca2023 ihs_ca97_2024 ihs_cost97_2023 ihs_cost97_2024 w99_comp_benefice2023 w99_comp_benefice2024"

local all_index_transformed `dsi' `dmi' `epi' `bpi'

iebaltab `all_index_transformed' if surveyround == 3 & treatment == 1, ///
	grpvar(take_up) vce(robust) format(%15.2fc) replace ///
	ftest rowvarlabels  ///
	savetex(el_takeup_baltab_bl_adj)

}

* endline per treatment
{
		* concern: F-test significant at baseline
				* major outcome variables, untransformed
			*Digital sales
local dsi "dig_margins dig_revenues_ecom"
	
			*Digital marketing 
local dmi "dig_empl dig_invest mark_invest"
	
			*Export performance
local epi "compexp_2023 compexp_2024 export_1 export_2 exp_pays clients_b2c clients_b2b exp_dig"			
			
			*Business performance
local bpi "fte fte_femmes car_carempl_div2 comp_ca2023 comp_ca2024 cost_2023 cost_2024 comp_benefice2023 comp_benefice2024"

local all_index_untransformed `dsi' `dmi' `epi' `bpi'
				
					* F-test
iebaltab `all_index_untransformed' if surveyround == 3, ///
	grpvar(treatment) vce(robust) format(%12.2fc) replace ///
	ftest rowvarlabels ///
	savetex(el_treatment_baltab_bl_unadj)

				* major outcome variables, transformed
*Digital sales
local dsi "dig_margins ihs_digrev_99"
	
			*Digital marketing 
local dmi "w99_dig_empl w99_dig_invest w99_mark_invest"
	
			*Export performance
local epi "ihs_exports99_2023 ihs_exports97_2024 export_1 export_2 exp_pays ihs_clients_b2c_97 ihs_clients_b2b_99 exp_dig"			
			
			*Business performance
local bpi "ihs_fte_99 ihs_fte_femmes_99 ihs_fte_young_99 w99_comp_ca2023 ihs_ca97_2024 ihs_cost97_2023 ihs_cost97_2024 w99_comp_benefice2023 w99_comp_benefice2024"

local all_index_transformed `dsi' `dmi' `epi' `bpi'

iebaltab `all_index_transformed' if surveyround == 3, ///
	grpvar(take_up) vce(robust) format(%15.2fc) replace ///
	ftest rowvarlabels  ///
	savetex(el_treatment_baltab_bl_unadj)

}

	 
iebaltab fte ihs_exports95_2020 ihs_ca95_2020 ihs_w95_dig_rev20 ihs_profits compexp_2020 comp_ca2020 exp_pays_avg exporter2020 dig_revenues_ecom ///
comp_benefice2020 knowledge dig_presence_weightedz webindexz social_media_indexz  dig_marketing_index facebook_likes ///
  expprep if surveyround==1, grpvar(take_up) rowvarlabels format(%15.2fc) vce(robust) ftest savetex(bl_take_up_baltab_adj) replace

  }
}

***********************************************************************
* 	PART 1: Attrition
***********************************************************************
{
{
*test for differential total attrition
{
	* is there differential attrition between treatment and Control?
		* column (1): at endline
eststo att1, r: areg attrited i.treatment if surveyround == 3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* column (2): at midline
eststo att2, r: areg attrited i.treatment if surveyround == 2, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

local attrition att1 att2
esttab `attrition' using "el_attrition.tex", replace ///
	title("Attrition: Total") ///
	mtitles("EL" "ML") ///
	label ///
	b(3) ///
	se(3) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls") ///
	addnotes("All standard errors are Hubert-White robust standord errors clustered at the firm level." "Indexes are z-score as defined in Kling et al. 2007.")
		
}

*test for selective attrition on key outcome variables (measured at baseline)
      
{
		* c(1): dig_marketing_index
eststo att4,r: areg   dig_marketing_index treatment##el_refus if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* c(2): dmi
eststo att5,r: areg  dig_presence_index treatment##el_refus if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* c(3): dsi
eststo att6,r: areg  dsi treatment##el_refus if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"	

		* c(4): dtai
eststo att7,r: areg  dtai treatment##el_refus if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* c(5): ihs_digrev_95
eststo att8,r: areg  ihs_digrev_95 treatment##el_refus if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"		// consider replacing with quantile transformed profits instead

		* c(6): ihs_ca95_2020
eststo att9,r: areg  ihs_ca95_2020 treatment##el_refus if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* c(7): ihs_fte_95
eststo att10,r: areg  ihs_fte_95 treatment##el_refus if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

		* c(8): ever_exported
eststo att11,r: areg  ever_exported treatment##el_refus if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

local attrition att4 att5 att6 att7 att8 att9 att10 att11
esttab `attritionkey' using "el_blattrition.tex", replace ///
	title("Attrition: Baseline outcomes") ///
	mtitles("Endline attrition" "Midline attrition" "Digital marketing index" "Digital presence index" "Digital sales index" "Digital technology adoption index" "Digital revenues" "Total revenues" "Employees" "Ever exported" ) ///
	label ///
	b(3) ///
	se(3) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls") ///
	addnotes("Notes: All Columns consider only endline response behaviour."  "All standard errors are Huber-White robust standord errors clustered at the firm level." "Indexes are z-score as defined in Kling et al. 2007.")
}
}
*Regress midline outcomes on attrition dummies
{
		* c(1): dig_marketing_index
eststo ml_att4,r: areg   dig_marketing_index treatment##el_refus if surveyround==2, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* c(2): dmi
eststo ml_att5,r: areg  dig_presence_index treatment##el_refus if surveyround==2, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* c(3): dsi
eststo ml_att6,r: areg  dsi treatment##el_refus if surveyround==2, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"	

		* c(4): dtai
eststo ml_att7,r: areg  dtai treatment##el_refus if surveyround==2, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* c(7): ihs_fte_95
eststo ml_att10,r: areg  ihs_fte_95 treatment##el_refus if surveyround==2, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"


local ml_attrition ml_att4 ml_att5 ml_att6 ml_att7 ml_att10 
esttab `ml_attrition' using "el_attrition_ml_outcomes.tex", replace ///
	title("Endline attrition: Midline outcomes") ///
	mtitles("Digital marketing index" "Digital presence index" "Digital sales index" "Digital technology adoption index" "Employees" ) ///
	label ///
	b(3) ///
	se(3) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls") ///
	addnotes("Notes: All Columns consider only endline response behaviour."  "All standard errors are Huber-White robust standord errors clustered at the firm level." "Indexes are z-score as defined in Kling et al. 2007.")
}

}

***********************************************************************
* 	PART 2: Technology adoption regressions
***********************************************************************
{
* Table 1: Variables: E-commerce knowledge	E-commerce adoption	E-commerce perception	E-commerce sales	E-commerce employees
{
* view variables to check if consistent
br id_plateforme surveyround attrited knowledge dtai_survey dtai_manual dig_empl perception dig_revenues_ecom treatment strata
		* E-commerce knowledge
reg knowledge i.treatment L1.knowledge i.miss_bl_knowledge i.strata if surveyround == 2, cluster(id_plateforme)
reg knowledge i.take_up L1.knowledge i.miss_bl_knowledge i.strata if surveyround == 2, cluster(id_plateforme)

		* E-commerce perception
reg perception i.treatment L1.perception i.miss_bl_perception i.strata if surveyround == 2, cluster(id_plateforme)
reg perception i.take_up L1.perception i.miss_bl_perception i.strata if surveyround == 2, cluster(id_plateforme)

reg perception i.treatment L2.perception i.miss_bl_perception i.strata if surveyround == 3, cluster(id_plateforme)
reg perception i.take_up L2.perception i.miss_bl_perception i.strata if surveyround == 3, cluster(id_plateforme)

reg investecom_benefit1 i.treatment i.strata if surveyround == 3, cluster(id_plateforme)  // NTE
ivreg2 investecom_benefit1 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 

reg investecom_benefit2 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) // NTE
ivreg2 investecom_benefit2 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 


		* E-commerce technology adoption
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3, cluster(id_plateforme) 
reg dtai_survey i.take_up L2.dtai_survey i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 
 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3, cluster(id_plateforme) 
reg dtai_manual i.take_up L2.dtai_manual i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 
 

		* E-commerce Employees
reg dig_empl i.treatment L2.dig_empl miss_bl_dig_empl i.strata if surveyround == 3, cluster(id_plateforme) // NTE
reg dig_empl i.take_up L2.dig_empl miss_bl_dig_empl i.strata if surveyround == 3, cluster(id_plateforme) // NTE
ivreg2 dig_empl L2.dig_empl i.miss_bl_dig_empl i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) // NTE

reg dig_dummy i.treatment L2.dig_dummy i.strata if surveyround == 3, cluster(id_plateforme) // NTE
reg dig_dummy i.take_up L2.dig_dummy i.strata if surveyround == 3, cluster(id_plateforme) // TE
ivreg2 dig_dummy L2.dig_dummy i.miss_bl_dig_dummy i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) // NTE

reg ihs_dig_empl_95 i.treatment L2.ihs_dig_empl_95 i.strata if surveyround == 3, cluster(id_plateforme) // NTE
reg ihs_dig_empl_95 i.take_up L2.ihs_dig_empl_95 i.strata if surveyround == 3, cluster(id_plateforme) // TE
ivreg2 ihs_dig_empl_95 L2.ihs_dig_empl_95 i.miss_bl_ihs_dig_empl_95 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) // NTE

		* E-commerce revenues
reg dig_revenues_ecom i.treatment L2.dig_revenues_ecom i.strata if surveyround == 3, cluster(id_plateforme)
reg dig_revenues_ecom i.take_up L2.dig_revenues_ecom i.strata if surveyround == 3, cluster(id_plateforme)

reg ihs_dig_rev_w95 i.treatment L2.ihs_dig_rev_w95 i.strata if surveyround == 3, cluster(id_plateforme) 
reg ihs_dig_rev_w95 i.take_up L2.ihs_dig_rev_w95 i.strata if surveyround == 3, cluster(id_plateforme) // TE **
ivreg2 ihs_dig_rev_w95 L2.ihs_dig_rev_w95 i.miss_bl_ihs_dig_rev_w95 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first // TE *

reg dig_rev_extmargin i.treatment L2.ihs_dig_rev_w95 i.strata if surveyround == 3, cluster(id_plateforme) 
reg dig_rev_extmargin i.take_up L2.ihs_dig_rev_w95 i.strata if surveyround == 3, cluster(id_plateforme) // TE
ivreg2 dig_rev_extmargin L2.dig_rev_extmargin  i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first // TE *

		* E-commerce investment
reg dig_invest i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
reg dig_invest i.take_up i.strata if surveyround == 3, cluster(id_plateforme) 

reg ihs_dig_invest_95 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) // NTE
reg ihs_dig_invest_95 i.take_up i.strata if surveyround == 3, cluster(id_plateforme) // TE
ivreg2 ihs_dig_invest_95 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first // NTE

reg dig_invest_extmargin i.treatment i.strata if surveyround == 3, cluster(id_plateforme) // NTE
reg dig_invest_extmargin i.take_up i.strata if surveyround == 3, cluster(id_plateforme) // TE
ivreg2 dig_invest_extmargin i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first // NTE

}

	**** Write program for 1st regression table
capture program drop table1 // enables re-running
program table1
version 16							// define Stata version
	syntax varlist(min=1 numeric), GENerate(string)
	
		* Loop over each variable & regress on treatment & take-up
    foreach var in `varlist' {

		sum L2.`var'
		if r(N) == 0  {
			
// ITT: ANCOVA plus stratification dummies
            eststo `var'1: reg `var' i.treatment i.strata if surveyround == 3, cluster(id_plateforme)
            estadd local bl_control "No" : `var'1
            estadd local strata "Yes" : `var'1

            // ATT, IV
            eststo `var'2: ivreg2 `var' i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first
            estadd local bl_control "No" : `var'2
            estadd local strata "Yes" : `var'2
            
            // Calculate Control mean
            sum `var' if treatment == 0 & surveyround == 3
            estadd scalar control_mean = r(mean) : `var'2
            estadd scalar control_sd = r(sd) : `var'2
			
		}
		
		else if `var' == knowledge {
		
			eststo `var'1: reg `var' i.treatment L1.`var' i.miss_bl_`var' i.strata if surveyround == 2, cluster(id_plateforme)
			estadd local bl_control "Yes" : `var'1
			estadd local strata "Yes" : `var'1

			// ATT, IV
			eststo `var'2: ivreg2 `var' L1.`var' i.miss_bl_`var' i.strata (take_up = i.treatment) if surveyround == 2, cluster(id_plateforme) first
			estadd local bl_control "Yes" : `var'2
			estadd local strata "Yes" : `var'2

			// Calculate Control mean
			sum `var' if treatment == 0 & surveyround == 2
			estadd scalar control_mean = r(mean) : `var'2
			estadd scalar control_sd = r(sd) : `var'2
		}
        else {
			// ITT: ANCOVA plus stratification dummies
            eststo `var'1: reg `var' i.treatment L2.`var' i.miss_bl_`var' i.strata if surveyround == 3, cluster(id_plateforme)
            estadd local bl_control "Yes" : `var'1
            estadd local strata "Yes" : `var'1

            // ATT, IV
            eststo `var'2: ivreg2 `var' L2.`var' i.miss_bl_`var' i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first
            estadd local bl_control "Yes" : `var'2
            estadd local strata "Yes" : `var'2
            
            // Calculate Control mean
            sum `var' if treatment == 0 & surveyround == 3
            estadd scalar control_mean = r(mean) : `var'2
            estadd scalar control_sd = r(sd) : `var'2

        }
}

				* Put everything into a latex table	
tokenize `varlist'
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 `7'1 // `7'1 `10'1  adjust manually to number of variables 
		esttab `regressions' using "${tab_tech}/ecom_`generate'.tex", replace booktabs ///
			prehead("\begin{table}[!h] \centering \\ \caption{E-commerce: Knowledge, Technology Adoption, Performance} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabularx}{\linewidth}{l*{7}{>{\centering\arraybackslash}X}}  \toprule") ///
				posthead("\toprule \\ \multicolumn{8}{c}{Panel A: Intention-to-treat (ITT)} \\\\[-1ex]") ///			
				fragment ///
				cells(b(star fmt(2)) se(par fmt(2))) /// p(fmt(3)) rw ci(fmt(2))
				mlabels("Knowledge"  "\shortstack{Adoption \\ Survey}" "\shortstack{Adoption \\ Manual}" "\shortstack{E-Employees\\ $> 0$}" "\shortstack{E-Investment\\ $> 0$}"  "\shortstack{E-Revenue\\ $> 0$}" "E-Margin") /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				collabels(none) ///	do not use statistics names below models
				label 		/// specifies EVs have label
				drop(_cons *.strata ?.miss_bl_* L*.*) ///  L.* oL.*
				noobs
			
			* Bottom panel: ITT
		local regressions `1'2 `2'2 `3'2  `4'2 `5'2 `6'2 `7'2 // `7'2 `4'2 `5'2 `6'2 `7'2 `8'2 `9'2 `10'2 adjust manually to number of variables 
		esttab `regressions' using "${tab_tech}/ecom_`generate'.tex", append booktabs ///
				fragment ///	
				posthead("\addlinespace[0.3cm] \midrule \\ \multicolumn{8}{c}{Panel B: Treatment Effect on the Treated (TOT)} \\\\[-1ex]") ///
				cells(b(star fmt(2)) se(par fmt(2))) /// p(fmt(3)) rw ci(fmt(2))
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control mean" "Control SD" "Observations" "Strata controls" "BL controls")) ///
				drop(_cons *.strata ?.miss_bl_* L*.*) ///  L.* `5' `6'
				star(* 0.1 ** 0.05 *** 0.01) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\addlinespace[0.3cm] \midrule") ///
				postfoot("\bottomrule \addlinespace[0.2cm] \multicolumn{8}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% \textit{Notes}: Panel A reports ANCOVA estimates as defined in \citet{Bruhn.2009}. Panel B documents IV estimates, instrumenting take-up with treatment assignment. Knowledge and adoption are average z-scores as defined in \citet{Anderson.2008}. Knowledge is measured at midline, while all other outcomes are measured at the endline. Adoption survey is based on survey responses, while adoption manual is based on manual scoring of firms websites and social media accounts. Columns(4)-(6) present dummy variables. Standard errors are clustered on the firm-level and reported in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level.% \\ }} \\ \end{tabularx} \\ \end{adjustbox} \\ \end{table}")
				
				
end

table1 knowledge dtai_survey dtai_manual dig_dummy dig_invest_extmargin dig_rev_extmargin dig_margins, gen(tab1_paper_v1)
table1 knowledge dtai_survey dtai_manual dig_dummy dig_invest_extmargin2 dig_rev_extmargin2 dig_margins, gen(tab1_paper_v2) // replacement with 0 instead of . for e-commerce investment & revenue (assumption: if firm said idk, put in 0)

table1 knowledge dtai_survey_cont dtai_manual_cont dig_dummy dig_invest_extmargin2 dig_rev_extmargin2 dig_margins, gen(tab1_paper_v2_cont) 


* heterogeneity in TE on TA ?
{
	
	* high vs. low BL e-commerce technology effect on TE for ecommerce technology?
{	
foreach source in survey manual {
	gen t_bl_dtai_`source' = dtai_`source' if surveyround == 1
	egen bl_dtai_`source' = min(t_bl_dtai_`source'), by(id_plateforme)
	sum bl_dtai_`source', d
	gen bl_dtai_`source'_high = (bl_dtai_`source' > r(p50))
		replace bl_dtai_`source'_high = . if bl_dtai_`source' == .
	drop t_bl_dtai_`source'
	}
	
		* high
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3 & bl_dtai_survey_high == 1, cluster(id_plateforme) 
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3 & bl_dtai_survey_high == 1, cluster(id_plateforme) 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_dtai_manual_high == 1, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_dtai_manual_high == 1, cluster(id_plateforme) 

		* low
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3 & bl_dtai_survey_high == 0, cluster(id_plateforme) 
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3 & bl_dtai_survey_high == 0, cluster(id_plateforme) 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_dtai_manual_high == 0, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_dtai_manual_high == 0, cluster(id_plateforme) 

}

		
	* small vs. large firms?
{
foreach size in small large {
	gen t_bl_`size'_firm = `size'_firm if surveyround == 1
	egen bl_`size'_firm = min(t_bl_`size'_firm), by(id_plateforme)
	drop t_bl_`size'_firm
	}
	
		* large firms
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3 & bl_large_firm == 1, cluster(id_plateforme) 
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3 & bl_large_firm == 1, cluster(id_plateforme) 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_large_firm == 1, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_large_firm == 1, cluster(id_plateforme) 

		* small firms
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3 & bl_small_firm == 1, cluster(id_plateforme) 
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3 & bl_small_firm == 1, cluster(id_plateforme) 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_small_firm == 1, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_small_firm == 1, cluster(id_plateforme)


reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_small_firm == 0, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_small_firm == 0, cluster(id_plateforme)
}	
	
	* Peers? Do entrepreneurs with more peers using ecommerce technology respond differently to T?
{
sum car_adop_peer if surveyround == 1, d
gen t_bl_peers = (car_adop_peer > r(p50))
		replace t_bl_peers = . if car_adop_peer == .
egen bl_peers = min(t_bl_peers), by(id_plateforme)
drop t_bl_peers

		* High peers
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3 & bl_peers == 1, cluster(id_plateforme)
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3 & bl_peers == 1, cluster(id_plateforme) 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_peers == 1, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_peers == 1, cluster(id_plateforme) 

		* Low peers
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3 & bl_peers == 0, cluster(id_plateforme) 
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3 & bl_peers == 0, cluster(id_plateforme) 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_peers == 0, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_peers == 0, cluster(id_plateforme)

}
		
	* Age? Does treatment effect depends on entrepreneurs age?
{
sum car_pdg_age if surveyround == 1, d
gen t_bl_age = (car_pdg_age > r(p50))
		replace t_bl_age = . if car_pdg_age == .
egen bl_age = min(t_bl_age), by(id_plateforme)
drop t_bl_age
		
		
		* Old
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3 & bl_age == 1, cluster(id_plateforme)
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3 & bl_age == 1, cluster(id_plateforme) 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_age == 1, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_age == 1, cluster(id_plateforme) 

		* Young
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3 & bl_age == 0, cluster(id_plateforme) 
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3 & bl_age == 0, cluster(id_plateforme) 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_age == 0, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_age == 0, cluster(id_plateforme)

}

	* Risk-aversion
{
sum car_risque if surveyround == 1, d
gen t_bl_risque = (car_risque > r(p50))
		replace t_bl_risque = . if car_risque == .
egen bl_risque = min(t_bl_risque), by(id_plateforme)
drop t_bl_risque

		* Risk-averse
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3 & bl_risque == 1, cluster(id_plateforme)
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3 & bl_risque == 1, cluster(id_plateforme) 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_risque == 1, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_risque == 1, cluster(id_plateforme) 

		* Less risk averse
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3 & bl_risque == 0, cluster(id_plateforme) 
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3 & bl_risque == 0, cluster(id_plateforme) 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_risque == 0, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_risque == 0, cluster(id_plateforme)

}

	* Credit constrained
{
sum car_credit1 if surveyround == 1, d
gen t_bl_credit = (car_credit1 > r(p50))
		replace t_bl_credit = . if car_credit1 == .
egen bl_credit = min(t_bl_credit), by(id_plateforme)
drop t_bl_credit

		* More credit constrained
			* TA index
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme)
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) 

			* dig_dummy 
reg dig_dummy i.treatment L2.dig_dummy i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme)
ivreg2 dig_dummy i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) 

			* dig_invest_extmargin2
reg dig_invest_extmargin2 i.treatment i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme)
ivreg2 dig_invest_extmargin2 i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) 

			* dig_rev_extmargin2
reg dig_rev_extmargin2 i.treatment L2.dig_rev_extmargin2 i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme)
ivreg2 dig_rev_extmargin2 L2.dig_rev_extmargin2 i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) 

		
		* Less credit constrained
			* TA index
reg dtai_survey i.treatment L2.dtai_survey i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 
ivreg2 dtai_survey i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 

reg dtai_manual i.treatment L2.dtai_manual i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 
ivreg2 dtai_manual i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme)

			* dig_dummy 
reg dig_dummy i.treatment L2.dig_dummy i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme)
ivreg2 dig_dummy i.strata L2.dig_dummy (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 

			* dig_invest_extmargin2
reg dig_invest_extmargin2 i.treatment i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme)
ivreg2 dig_invest_extmargin2 i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 

			* dig_rev_extmargin2
reg dig_rev_extmargin2 i.treatment L2.dig_rev_extmargin2 i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme)
ivreg2 dig_rev_extmargin2 i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 

* there should be two } on the next lines
}
}


* Table 2: E-commerce knowledge, Variables: dig_con1_ml dig_con2_ml dig_con3_ml dig_con4_ml dig_con5_ml
	**** Write program for knowledge deep dive regression table
capture program drop deep_eknow // enables re-running
program deep_eknow
version 16							// define Stata version
	syntax varlist(min=1 numeric), GENerate(string)
	
		* Loop over each variable & regress on treatment & take-up
    foreach var in `varlist' {

		sum L2.`var'
		if r(N) == 0  {
			
// ITT: ANCOVA plus stratification dummies
            eststo `var'1: reg `var' i.treatment i.strata if surveyround == 2, cluster(id_plateforme)
            estadd local bl_control "No" : `var'1
            estadd local strata "Yes" : `var'1

            // ATT, IV
            eststo `var'2: ivreg2 `var' i.strata (take_up = i.treatment) if surveyround == 2, cluster(id_plateforme) first
            estadd local bl_control "No" : `var'2
            estadd local strata "Yes" : `var'2
            
            // Calculate Control mean
            sum `var' if treatment == 0 & surveyround == 2
            estadd scalar control_mean = r(mean) : `var'2
            estadd scalar control_sd = r(sd) : `var'2
			
		}
		
		else if `var' == knowledge {
		
			eststo `var'1: reg `var' i.treatment L1.`var' i.miss_bl_`var' i.strata if surveyround == 2, cluster(id_plateforme)
			estadd local bl_control "Yes" : `var'1
			estadd local strata "Yes" : `var'1

			// ATT, IV
			eststo `var'2: ivreg2 `var' L1.`var' i.miss_bl_`var' i.strata (take_up = i.treatment) if surveyround == 2, cluster(id_plateforme) first
			estadd local bl_control "Yes" : `var'2
			estadd local strata "Yes" : `var'2

			// Calculate Control mean
			sum `var' if treatment == 0 & surveyround == 2
			estadd scalar control_mean = r(mean) : `var'2
			estadd scalar control_sd = r(sd) : `var'2
		}
        else {
			// ITT: ANCOVA plus stratification dummies
            eststo `var'1: reg `var' i.treatment L1.`var' i.miss_bl_`var' i.strata if surveyround == 2, cluster(id_plateforme)
            estadd local bl_control "Yes" : `var'1
            estadd local strata "Yes" : `var'1

            // ATT, IV
            eststo `var'2: ivreg2 `var' L1.`var' i.miss_bl_`var' i.strata (take_up = i.treatment) if surveyround == 2, cluster(id_plateforme) first
            estadd local bl_control "Yes" : `var'2
            estadd local strata "Yes" : `var'2
            
            // Calculate Control mean
            sum `var' if treatment == 0 & surveyround == 3
            estadd scalar control_mean = r(mean) : `var'2
            estadd scalar control_sd = r(sd) : `var'2

        }
}

				* Put everything into a latex table	
tokenize `varlist'
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 // `7'1 `10'1  adjust manually to number of variables 
		esttab `regressions' using "${tab_tech}/ecom_`generate'.tex", replace booktabs ///
			prehead("\begin{table}[!h] \centering \\ \caption{E-commerce: Knowledge Index Deep Dive} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabularx}{\linewidth}{l*{6}{>{\centering\arraybackslash}X}}  \toprule") ///
				posthead("\toprule \\ \multicolumn{7}{c}{Panel A: Intention-to-treat (ITT)} \\\\[-1ex]") ///			
				fragment ///
				cells(b(star fmt(2)) se(par fmt(2))) /// p(fmt(3)) rw ci(fmt(2))
				mlabels("\shortstack{Knowledge\\ Index}"  "\shortstack{E-\\Payment}" "\shortstack{E-\\ Content}" "\shortstack{Google\\ Analytics}" "\shortstack{Engagement \\ Rate}"  "\shortstack{SEO \\ SEA}") /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				collabels(none) ///	do not use statistics names below models
				label 		/// specifies EVs have label
				drop(_cons *.strata ?.miss_bl_* L*.*) ///  L.* oL.*
				noobs
			
			* Bottom panel: ITT
		local regressions `1'2 `2'2 `3'2  `4'2 `5'2 `6'2 // `7'2 `4'2 `5'2 `6'2 `7'2 `8'2 `9'2 `10'2 adjust manually to number of variables 
		esttab `regressions' using "${tab_tech}/ecom_`generate'.tex", append booktabs ///
				fragment ///	
				posthead("\addlinespace[0.3cm] \midrule \\ \multicolumn{7}{c}{Panel B: Treatment Effect on the Treated (TOT)} \\\\[-1ex]") ///
				cells(b(star fmt(2)) se(par fmt(2))) /// p(fmt(3)) rw ci(fmt(2))
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control mean" "Control SD" "Observations" "Strata controls" "BL controls")) ///
				drop(_cons *.strata ?.miss_bl_* L*.*) ///  L.* `5' `6'
				star(* 0.1 ** 0.05 *** 0.01) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\addlinespace[0.3cm] \midrule") ///
				postfoot("\bottomrule \addlinespace[0.2cm] \multicolumn{7}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% \textit{Notes}: Panel A reports ANCOVA estimates as defined in \citet{Bruhn.2009}. Panel B documents IV estimates, instrumenting take-up with treatment assignment. Knowledge is an average z-score of all other variables, calculated as defined in \citet{Anderson.2008}. All variables are measured at midline. Columns(2)-(6) present dummy variables. Standard errors are clustered on the firm-level and reported in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level.% \\ }} \\ \end{tabularx} \\ \end{adjustbox} \\ \end{table}")
				
				
end

deep_eknow knowledge dig_con1_ml dig_con2_ml dig_con3_ml dig_con4_ml dig_con5_ml, gen(deep_eknow)



* Table 3: Variables: Online visibility	Online payment	Website use	Social media use	Digital Marketing use
{
reg presence_survey i.treatment L2.presence_survey i.strata if surveyround == 3, cluster(id_plateforme) 
reg presence_manual i.treatment L2.presence_manual i.strata if surveyround == 3, cluster(id_plateforme) 

	reg dig_presence2 i.treatment L2.dig_presence2 i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 dig_presence2 i.strata L2.dig_presence2 (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 
	
	reg entreprise_social i.treatment L2.entreprise_social i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 entreprise_social i.strata L2.entreprise_social (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 


reg payment_survey i.treatment L2.payment_survey i.strata if surveyround == 3, cluster(id_plateforme) 
reg payment_manual i.treatment L2.payment_manual i.strata if surveyround == 3, cluster(id_plateforme) 
reg use_survey i.treatment L2.use_survey i.strata if surveyround == 3, cluster(id_plateforme) 
reg use_manual i.treatment L2.use_manual i.strata if surveyround == 3, cluster(id_plateforme) 
reg use_website_survey i.treatment L2.use_website_survey i.strata if surveyround == 3, cluster(id_plateforme) 
reg use_website_manual i.treatment L2.use_website_manual i.strata if surveyround == 3, cluster(id_plateforme) 
reg use_sm_survey i.treatment L2.use_sm_survey i.strata if surveyround == 3, cluster(id_plateforme) 
ivreg2 use_sm_survey L2.use_sm_survey i.miss_bl_use_sm_survey i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 
reg use_sm_manual i.treatment L2.use_sm_manual i.strata if surveyround == 3, cluster(id_plateforme) 

 

	reg sm_use_contacts i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 sm_use_contacts i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg sm_use_catalogue i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 sm_use_catalogue i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg sm_use_engagement i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 sm_use_engagement i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg sm_use_com i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 sm_use_com i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg sm_use_brand i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 sm_use_brand i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	
	
	reg web_use_contacts i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_use_contacts i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg web_use_catalogue i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_use_catalogue i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg web_use_engagement i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_use_engagement i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg web_use_com i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_use_com i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg web_use_brand i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_use_brand i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	
	   web_aboutus web_norms web_externals web_languages web_coherent web_quality
	
	reg web_product i.treatment i.strata L2.web_product if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_product i.strata L2.web_product (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg web_logoname i.treatment i.strata L2.web_logoname if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_logoname i.strata L2.web_logoname (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg web_aboutus i.treatment i.strata L2.web_aboutus if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_aboutus i.strata L2.web_aboutus (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg web_norms i.treatment i.strata L2.web_norms if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_norms i.strata L2.web_norms (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg web_externals i.treatment i.strata L2.web_externals if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_externals i.strata L2.web_externals (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg web_languages i.treatment i.strata L2.web_languages if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_languages i.strata L2.web_languages (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg web_coherent i.treatment i.strata L2.web_coherent if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_coherent i.strata L2.web_coherent (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	
	reg web_quality i.treatment i.strata L2.web_quality if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_quality i.strata L2.web_quality (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	
	reg web_logoname i.treatment i.strata L2.web_logoname if surveyround == 3, cluster(id_plateforme) 
	ivreg2 web_logoname i.strata L2.web_logoname (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
    

reg use_fb_manual i.treatment L2.use_fb_manual i.strata if surveyround == 3, cluster(id_plateforme) 
reg use_insta_manual i.treatment L2.use_insta_manual i.strata if surveyround == 3, cluster(id_plateforme) 
reg use_insta_manual i.treatment L2.use_insta_manual i.strata if surveyround == 3, cluster(id_plateforme) 
reg dmi i.treatment L2.dmi i.strata if surveyround == 3, cluster(id_plateforme) 

	reg mark_online1 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 mark_online1 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 
	
	reg mark_online2 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 mark_online2 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	reg mark_online3 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 mark_online3 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

	reg mark_online4 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
	ivreg2 mark_online4 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

}


		**** Write program for deep-dive regression table
lab var take_up "Take-up"
capture program drop deep_dive_tadop // enables re-running
program deep_dive_tadop
version 16							// define Stata version
	syntax varlist(min=1 numeric), GENerate(string)
	
		* Loop over each variable & regress on treatment & take-up
    foreach var in `varlist' {

		sum L2.`var'
		if r(N) == 0  {
			
// ITT: ANCOVA plus stratification dummies
            eststo `var'1: reg `var' i.treatment i.strata if surveyround == 3, cluster(id_plateforme)
            estadd local bl_control "No" : `var'1
            estadd local strata "Yes" : `var'1

            // ATT, IV
            eststo `var'2: ivreg2 `var' i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first
            estadd local bl_control "No" : `var'2
            estadd local strata "Yes" : `var'2
            
            // Calculate Control mean
            sum `var' if treatment == 0 & surveyround == 3
            estadd scalar control_mean = r(mean) : `var'2
            estadd scalar control_sd = r(sd) : `var'2
			
			}		
        else {
			// ITT: ANCOVA plus stratification dummies
            eststo `var'1: reg `var' i.treatment L2.`var' i.miss_bl_`var' i.strata if surveyround == 3, cluster(id_plateforme)
            estadd local bl_control "Yes" : `var'1
            estadd local strata "Yes" : `var'1

            // ATT, IV
            eststo `var'2: ivreg2 `var' L2.`var' i.miss_bl_`var' i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first
            estadd local bl_control "Yes" : `var'2
            estadd local strata "Yes" : `var'2
            
            // Calculate Control mean
            sum `var' if treatment == 0 & surveyround == 3
            estadd scalar control_mean = r(mean) : `var'2
            estadd scalar control_sd = r(sd) : `var'2
        }
}

				* Put everything into a latex table	
tokenize `varlist'
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 `7'1 `8'1 `9'1 `10'1 `11'1 `12'1 // `7'1 `10'1  adjust manually to number of variables 
		esttab `regressions' using "${tab_tech}/ecom_`generate'.tex", replace booktabs ///
			prehead("\begin{table}[!h] \centering \\ \caption{E-commerce: Deep-Dive Technology Adoption} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabularx}{\linewidth}{l >{\centering\arraybackslash}X >{\centering\arraybackslash}X>{\centering\arraybackslash}X >{\centering\arraybackslash}X >{\centering\arraybackslash}X>{\centering\arraybackslash}X >{\centering\arraybackslash}X >{\centering\arraybackslash}X>{\centering\arraybackslash}X >{\centering\arraybackslash}X >{\centering\arraybackslash}X>{\centering\arraybackslash}X}   \toprule") ///
				posthead("\toprule \\ \multicolumn{13}{c}{Panel A: Intention-to-treat (ITT)} \\\\[-1ex]") ///			
				fragment ///
				cells(b(star fmt(1)) se(par fmt(2))) /// p(fmt(3)) rw ci(fmt(2))
				mlabels("\shortstack{Present \\ Survey}" "\shortstack{Present \\ Manual}" "\shortstack{Pay \\ Survey}" "\shortstack{Pay \\ Manual}" "\shortstack{Use \\ Survey}" "\shortstack{Use \\ Manual}" "\shortstack{Website \\ Survey}" "\shortstack{Website \\ Manual}" "\shortstack{Social \\ Media}" "\shortstack{Face-\\book}" "\shortstack{Insta-\\gram}" "\shortstack{E-\\Marketing}") /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				collabels(none) ///	do not use statistics names below models
				label 		/// specifies EVs have label
				drop(_cons *.strata ?.miss_bl_* L*.*) ///  L.* oL.*
				noobs
			
			* Bottom panel: ITT
		local regressions `1'2 `2'2 `3'2  `4'2 `5'2 `6'2 `7'2 `8'2 `9'2 `10'2 `11'2 `12'2 // `7'2 `4'2 `5'2 `6'2 `7'2 `8'2 `9'2 `10'2 adjust manually to number of variables 
		esttab `regressions' using "${tab_tech}/ecom_`generate'.tex", append booktabs ///
				fragment ///	
				posthead("\addlinespace[0.3cm] \midrule \\ \multicolumn{13}{c}{Panel B: Treatment Effect on the Treated (TOT)} \\\\[-1ex]") ///
				cells(b(star fmt(1)) se(par fmt(2))) /// p(fmt(3)) rw ci(fmt(2))
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control mean" "Control SD" "Observations" "Strata controls" "BL controls")) ///
				drop(_cons *.strata ?.miss_bl_* L*.*) ///  L.* `5' `6'
				star(* 0.1 ** 0.05 *** 0.01) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\addlinespace[0.3cm] \midrule") ///
				postfoot("\bottomrule \addlinespace[0.2cm] \multicolumn{13}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% \textit{Notes}: Panel A reports ANCOVA estimates as defined in \citet{Bruhn.2009}. Panel B documents IV estimates, instrumenting take-up with treatment assignment. Knowledge and adoption are average z-scores as defined in \citet{Anderson.2008}. Knowledge is measured at midline, while all other outcomes are measured at the endline. Adoption survey is based on survey responses, while adoption manual is based on manual scoring of firms websites and social media accounts. Columns(4)-(6) present dummy variables. Standard errors are clustered on the firm-level and reported in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level.% \\ }} \\ \end{tabularx} \\ \end{adjustbox} \\ \end{table}")
				
				
end

deep_dive_tadop presence_survey presence_manual payment_survey payment_manual use_survey use_manual use_website_survey use_website_manual use_sm_manual use_fb_manual use_insta_manual dmi, gen(deep_tech)


* Table : E-commere technology perception
reg perception i.treatment i.strata if surveyround == 2, cluster(id_plateforme) 
reg investcom_benefit1 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 


* Table: ecommerce mechanisms
{
reg dig_margins i.treatment i.strata if surveyround == 3, cluster(id_plateforme) // TE
ivreg2 dig_margins i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) // TE

reg dig_rev_per i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
ivreg2 dig_rev_per i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 


reg dig_barr1 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
ivreg2 dig_barr1 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 
reg dig_barr2 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
ivreg2 dig_barr2 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 
reg dig_barr3 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
ivreg2 dig_barr3 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 
reg dig_barr4 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
ivreg2 dig_barr4 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 
reg dig_barr5 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
ivreg2 dig_barr5 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 
reg dig_barr6 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
ivreg2 dig_barr6 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) 
reg dig_barr7 i.treatment i.strata if surveyround == 3, cluster(id_plateforme) 
ivreg2 dig_barr7 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)  
}


}


***********************************************************************
* 	PART 3: Firm performance regressions
***********************************************************************
{
* bpi
{
reg bpi i.treatment L2.bpi miss_bl_bpi i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 bpi L2.bpi i.miss_bl_bpi i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

		* Heterogenous treatment effects
			* Heterogeneity
		* More credit constrained
reg bpi i.treatment i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme)
ivreg2 bpi i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme)  

		* Less credit constrained
reg bpi i.treatment i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 
ivreg2 bpi i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 
}

* profit
{
	* 2023
reg profit i.treatment L2.profit miss_bl_profit i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 profit L2.profit i.miss_bl_profit i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg profit_pos i.treatment L2.profit_pos miss_bl_profit_pos i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 profit_pos L2.profit_pos i.miss_bl_profit_pos i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)


reg w95_profit i.treatment L2.w95_profit miss_bl_w95_profit i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 w95_profit L2.w95_profit i.miss_bl_w95_profit i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg w95_profit_ihs i.treatment L2.w95_profit_ihs miss_bl_w95_profit_ihs i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 w95_profit_ihs L2.w95_profit_ihs i.miss_bl_w95_profit_ihs i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg profit_rel_growth i.treatment L2.profit_rel_growth miss_bl_profit_rel_growth i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 profit_rel_growth L2.profit_rel_growth i.miss_bl_profit_rel_growth i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg profit_abs_growth i.treatment L2.profit_abs_growth miss_bl_profit_abs_growth i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 profit_abs_growth L2.profit_abs_growth i.miss_bl_profit_abs_growth i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

		* Heterogenous treatment effects
			* Heterogeneity
		* More credit constrained
reg profit i.treatment i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme)
ivreg2 profit i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) 

reg profit_pos i.treatment i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme)
ivreg2 profit_pos i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) 

		* Less credit constrained
reg profit i.treatment i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 
ivreg2 profit i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 

reg profit_pos i.treatment i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 
ivreg2 profit_pos i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 

reg profit_2024_category i.treatment i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 
ivreg2 profit_2024_category i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 


	* 2024
reg comp_benefice2024 i.treatment L2.profit miss_bl_profit i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 comp_benefice2024 L2.profit i.miss_bl_profit i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)


reg w95_comp_benefice2024 i.treatment L2.profit i.miss_bl_profit i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 w95_comp_benefice2024 L2.profit i.miss_bl_profit i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg w95_comp_benefice2024_ihs i.treatment L2.profit miss_bl_profit_ihs i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 w95_comp_benefice2024_ihs L2.profit i.miss_bl_profit_ihs i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

}

* sales
{
	* 2023
		* ATE
reg sales i.treatment L2.sales miss_bl_sales i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 sales L2.sales i.miss_bl_sales i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)


reg w95_sales i.treatment L2.w95_sales miss_bl_w95_sales i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 w95_sales L2.w95_sales i.miss_bl_w95_sales i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg w95_sales_ihs i.treatment L2.w95_sales_ihs miss_bl_w95_sales_ihs i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 w95_sales_ihs L2.w95_sales_ihs i.miss_bl_w95_sales_ihs i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg sales_rel_growth i.treatment L2.sales_rel_growth miss_bl_sales_rel_growth i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 sales_rel_growth L2.sales_rel_growth i.miss_bl_sales_rel_growth i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg sales_abs_growth i.treatment L2.sales_abs_growth miss_bl_sales_abs_growth i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 sales_abs_growth L2.sales_abs_growth i.miss_bl_sales_abs_growth i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
			
			* Heterogeneity
		* More credit constrained
reg w95_sales i.treatment L2.w95_sales i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme)
ivreg2 w95_sales i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) 

reg w95_sales_ihs i.treatment L2.w95_sales_ihs i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) 
ivreg2 w95_sales_ihs i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) 

		* Less credit constrained
reg w95_sales i.treatment L2.w95_sales i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 
ivreg2 w95_sales i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 

reg w95_sales_ihs i.treatment L2.w95_sales_ihs i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 
ivreg2 w95_sales_ihs i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme)
			
			
			
	* 2024
reg comp_ca2024 i.treatment L2.sales miss_bl_sales i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 comp_ca2024 L2.sales i.miss_bl_sales i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)


reg w95_comp_ca2024 i.treatment L2.sales i.miss_bl_sales i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 w95_comp_ca2024 L2.sales i.miss_bl_sales i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg w95_comp_ca2024_ihs i.treatment L2.sales miss_bl_sales_ihs i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 w95_comp_ca2024_ihs L2.sales i.miss_bl_sales_ihs i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

}

* employees
{
reg fte i.treatment L2.fte miss_bl_fte i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 fte L2.fte i.miss_bl_fte i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)


reg w95_fte i.treatment L2.w95_fte miss_bl_fte i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 w95_fte L2.w95_fte i.miss_bl_fte i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg ihs_fte_95 i.treatment L2.ihs_fte_95 miss_bl_fte i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 ihs_fte_95 L2.ihs_fte_95 i.miss_bl_fte i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg fte_rel_growth i.treatment L2.fte miss_bl_fte i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 fte_rel_growth L2.fte miss_bl_fte i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg fte_abs_growth i.treatment L2.fte miss_bl_fte i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 fte_abs_growth L2.fte miss_bl_fte i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
}


*** Firm performance table
capture program drop firm_perf // enables re-running
program firm_perf
version 16							// define Stata version
	syntax varlist(min=1 numeric), GENerate(string)

		* Loop over each variable & regress on treatment & take-up
    foreach var in `varlist' {
		
	// ITT: ANCOVA plus stratification dummies
            eststo `var'1: reg `var' i.treatment L2.`var' i.strata i.miss_bl_`var' if surveyround == 3, cluster(id_plateforme)
            estadd local bl_control "Yes" : `var'1
            estadd local strata "Yes" : `var'1
			
			local itt_`var' = r(table)[1,2]
			local fmt_itt_`var' : display %3.2f `itt_`var''	

            // ATT, IV
            eststo `var'2: ivreg2 `var'  L2.`var' i.strata i.miss_bl_`var' (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first
            estadd local bl_control "Yes" : `var'2
            estadd local strata "Yes" : `var'2
			
			local att_`var' = e(b)[1,1]
			local fmt_att_`var' : display %3.2f `att_`var''	
            
            // Calculate Control mean
            sum `var' if treatment == 0 & surveyround == 3
            estadd scalar control_mean = r(mean) : `var'2
            estadd scalar control_sd = r(sd) : `var'2
			
			local ctl_m_`var' = r(mean)
			local fmt_ctl_m_`var' : display  %3.2f `ctl_m_`var''
			
			// Calculate treatment effect
			local `var'_per_itt = (`fmt_itt_`var'' / `fmt_ctl_m_`var'')*100			
			local `var'_per_att = (`fmt_att_`var'' / `fmt_ctl_m_`var'')*100
			
			estadd scalar te_perc_itt = ``var'_per_itt' : `var'2
			estadd scalar te_perc_att = ``var'_per_att' : `var'2
			
			
			
}

				* Put everything into a latex table	
tokenize `varlist'
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 `7'1 `8'1 `9'1
		esttab `regressions' using "${tab_tech}/ecom_`generate'.tex", replace booktabs ///
			prehead("\begin{table}[H] \centering \\ \caption{Impact on Firm's Business Performance} \label{tab:kpis}  \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabularx}{\linewidth}{l*{9}{>{\centering\arraybackslash}X}}  \toprule") ///
				posthead("\toprule \\ \multicolumn{10}{c}{Panel A: Intention-to-treat (ITT)} \\\\[-1ex]") ///			
				fragment ///
				cells(b(star fmt(%-15.1fc)) se(par fmt(%-15.1fc))) /// p(fmt(3)) rw ci(fmt(2))
				mlabels("\shortstack{Sales \\ Abs.}"   "\shortstack{Sales \\ Wins.}" "\shortstack{Sales \\ IHS}"  "\shortstack{Profit \\ Abs.}"   "\shortstack{Profit \\ Wins.}" "\shortstack{Profit \\ IHS}" "\shortstack{Empl. \\ Abs.}"   "\shortstack{Empl. \\ Wins.}" "\shortstack{Growth \\ Index}") ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				collabels(none) ///	do not use statistics names below models
				label 		/// specifies EVs have label
				drop(_cons *.strata ?.miss_bl_* L*.*) ///  L.* oL.*
				noobs
			
			* Bottom panel: ITT
		local regressions `1'2 `2'2 `3'2  `4'2 `5'2 `6'2 `7'2 `8'2 `9'2
		esttab `regressions' using "${tab_tech}/ecom_`generate'.tex", append booktabs ///
				fragment ///	
				posthead("\addlinespace[0.3cm] \midrule \\ \multicolumn{10}{c}{Panel B: Treatment Effect on the Treated (TOT)} \\\\[-1ex]") ///
				cells(b(star fmt(%-15.1fc)) se(par fmt(%-15.1fc))) /// p(fmt(3)) rw ci(fmt(2))
				stats(te_perc_itt control_mean control_sd N strata bl_control, fmt(%9.0fc %12.2fc %12.2fc %9.0g) labels("TE in percent" "Control mean" "Control SD" "Observations" "Strata controls" "BL controls")) ///
				drop(_cons *.strata ?.miss_bl_* L*.*) ///  L.* `5' `6'
				star(* 0.1 ** 0.05 *** 0.01) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\addlinespace[0.3cm] \midrule") ///
				postfoot("\bottomrule \addlinespace[0.2cm] \multicolumn{10}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% \textit{Notes}: Panel A reports ANCOVA estimates as defined in \citet{Bruhn.2009}. Panel B documents IV estimates, instrumenting take-up with treatment assignment. Sales, profits, and employees are measured annually at endline (2023) and baseline (2020). Sales and employees are winsorized at the 95\textsuperscript{th} percentile, while profit is also winsorized at the 1\textsuperscript{st} percentile to account for negative outliers. Standard errors are clustered on the firm-level and reported in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level.% \\ }} \\ \end{tabularx} \\ \end{adjustbox} \\ \end{table}")
				
				
end

firm_perf sales sales_w95 ihs_sales profit profit_w95 ihs_profit fte fte_w99 bpi, gen(kpis)


* export
{
	* export readiness
reg eri i.treatment L2.eri miss_bl_eri i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 eri L2.eri i.miss_bl_eri i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

	* export countries
reg exp_pays i.treatment L2.exported miss_bl_exported i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 exp_pays L2.exported i.miss_bl_exported i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
reg w99_exp_pays i.treatment L2.exported miss_bl_exported i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 w99_exp_pays L2.exported i.miss_bl_exported i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg exported2 i.treatment L2.export miss_bl_export i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 exported2 L2.export i.miss_bl_export i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)
	
	* exported dummy
reg exported i.treatment L2.exported miss_bl_exported i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 exported L2.exported i.miss_bl_exported i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg export_1 i.treatment L2.export miss_bl_export i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 export_1 L2.export miss_bl_export i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg export_2 i.treatment L2.export miss_bl_export i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 export_2 L2.export miss_bl_export i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

	* Digital Exports
		* ATE
reg exp_dig i.treatment L2.exported miss_bl_exported i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 exp_dig L2.exported miss_bl_exported i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

		* Heterogenous treatment effects
			* Heterogeneity
		* More credit constrained
reg exp_dig i.treatment i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme)
ivreg2 exp_dig i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) 

		* Less credit constrained
reg exp_dig i.treatment i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 
ivreg2 exp_dig i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) 


	* continuous measure (export sales)
reg export i.treatment L2.export miss_bl_export i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 export L2.export i.miss_bl_export i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)


reg w95_export i.treatment L2.w95_export miss_bl_w95_export i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 w95_export L2.w95_export i.miss_bl_w95_export i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg w95_export_ihs i.treatment L2.w95_export_ihs miss_bl_w95_export_ihs i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 w95_export_ihs L2.w95_export_ihs i.miss_bl_w95_export_ihs i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg export_rel_growth i.treatment L2.export_rel_growth miss_bl_export_rel_growth i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 export_rel_growth L2.export_rel_growth i.miss_bl_export_rel_growth i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg export_abs_growth i.treatment L2.export_abs_growth miss_bl_export_abs_growth i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 export_abs_growth L2.export_abs_growth i.miss_bl_export_abs_growth i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)


	* reasons for not exporting (only 27 firms...too little to be reliable)
reg export_41 i.treatment i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 export_41 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg export_42 i.treatment i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 export_42 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg export_43 i.treatment i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 export_43 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg export_44 i.treatment i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 export_44 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)

reg export_45 i.treatment i.strata if surveyround == 3, cluster(id_plateforme)
ivreg2 export_45 i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme)


}


*** Export performance table
lab var exported "Export sales $>$ 0"
lab var w95_export "Export sales"
lab var w95_export_ihs "Export sales"
lab var exp_dig "Online export"

capture program drop export_perf // enables re-running
program export_perf
version 16							// define Stata version
	syntax varlist(min=1 numeric), GENerate(string)

		* Loop over each variable & regress on treatment & take-up
    foreach var in `varlist' {
		// with baseline control
	sum L2.`var'
	if r(N) == 0 {
		
	// ITT: ANCOVA plus stratification dummies
            eststo `var'1: reg `var' i.treatment i.strata if surveyround == 3, cluster(id_plateforme)
            estadd local bl_control "No" : `var'1
            estadd local strata "Yes" : `var'1
			
			local itt_`var' = r(table)[1,2]
			local fmt_itt_`var' : display %3.2f `itt_`var''	

        // ATT, IV
            eststo `var'2: ivreg2 `var' i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first
            estadd local bl_control "No" : `var'2
            estadd local strata "Yes" : `var'2
            
			local att_`var' = e(b)[1,1]
			local fmt_att_`var' : display %3.2f `att_`var''	
			
			
        // Calculate Control mean
            sum `var' if treatment == 0 & surveyround == 3
            estadd scalar control_mean = r(mean) : `var'2
            estadd scalar control_sd = r(sd) : `var'2
			
			local ctl_m_`var' = r(mean)
			local fmt_ctl_m_`var' : display  %3.2f `ctl_m_`var''
			
		// Calculate treatment effect
			local `var'_per_itt = (`fmt_itt_`var'' / `fmt_ctl_m_`var'')*100			
			local `var'_per_att = (`fmt_att_`var'' / `fmt_ctl_m_`var'')*100
			
			estadd scalar te_perc_itt = ``var'_per_itt' : `var'2
			estadd scalar te_perc_att = ``var'_per_att' : `var'2			

			
			
	} // with baseline control
	else {
		
		// ITT: ANCOVA plus stratification dummies
            eststo `var'1: reg `var' i.treatment L2.`var' i.strata i.miss_bl_`var' if surveyround == 3, cluster(id_plateforme)
            estadd local bl_control "Yes" : `var'1
            estadd local strata "Yes" : `var'1

			local itt_`var' = r(table)[1,2]
			local fmt_itt_`var' : display %3.2f `itt_`var''	
			
        // ATT, IV
            eststo `var'2: ivreg2 `var'  L2.`var' i.strata i.miss_bl_`var' (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first
            estadd local bl_control "Yes" : `var'2
            estadd local strata "Yes" : `var'2
			
			local att_`var' = e(b)[1,1]
			local fmt_att_`var' : display %3.2f `att_`var''	
            
         // Calculate Control mean
            sum `var' if treatment == 0 & surveyround == 3
			
            estadd scalar control_mean = r(mean) : `var'2
            estadd scalar control_sd = r(sd) : `var'2
			
			local ctl_m_`var' = r(mean)
			local fmt_ctl_m_`var' : display  %3.2f `ctl_m_`var''
			
		// Calculate treatment effect
			local `var'_per_itt = (`fmt_itt_`var'' / `fmt_ctl_m_`var'')*100			
			local `var'_per_att = (`fmt_att_`var'' / `fmt_ctl_m_`var'')*100
			
			estadd scalar te_perc_itt = ``var'_per_itt' : `var'2
			estadd scalar te_perc_att = ``var'_per_att' : `var'2
			
			
			
	}
}

				* Put everything into a latex table	
tokenize `varlist'
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 // `6'1 `7'1 `10'1  adjust manually to number of variables 
		esttab `regressions' using "${tab_tech}/ecom_`generate'.tex", replace booktabs ///
			prehead("\begin{table}[H] \centering \\ \caption{Impact on Export Performance} \label{tab:exp_perf} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabularx}{\linewidth}{l*{6}{>{\centering\arraybackslash}X}}  \toprule") ///
				posthead("\toprule \\ \multicolumn{7}{c}{Panel A: Intention-to-treat (ITT)} \\\\[-1ex]") ///			
				fragment ///
				cells(b(star fmt(%-15.2fc)) se(par fmt(%-15.2fc))) /// p(fmt(3)) rw ci(fmt(2))
			mlabels("\shortstack{Export \\ Readiness}"   "\shortstack{Exported \\ $>$ 0}" "\shortstack{Export Online \\ $>$ 0}"  "\shortstack{Export sales \\ Abs.}" "\shortstack{Export sales \\ Wins.}" "\shortstack{Export sales \\ IHS}") ///				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				collabels(none) ///	do not use statistics names below models
				label 		/// specifies EVs have label
				drop(_cons *.strata ?.miss_bl_* *L*.*) ///  L.* oL.*
				noobs
			
			* Bottom panel: ITT
		local regressions `1'2 `2'2 `3'2 `4'2 `5'2 `6'2  // `6'2 `7'2 `4'2 `5'2 `6'2 `7'2 `8'2 `9'2 `10'2 adjust manually to number of variables 
		esttab `regressions' using "${tab_tech}/ecom_`generate'.tex", append booktabs ///
				fragment ///	
				posthead("\addlinespace[0.3cm] \midrule \\ \multicolumn{7}{c}{Panel B: Treatment Effect on the Treated (TOT)} \\\\[-1ex]") ///
				cells(b(star fmt(%-15.2fc)) se(par fmt(%-15.2fc))) /// p(fmt(3)) rw ci(fmt(2))
				stats(te_perc_itt control_mean control_sd N strata bl_control, fmt(%9.0fc %12.2fc %12.2fc %9.0g) labels("TE in percent" "Control mean" "Control SD" "Observations" "Strata controls" "BL controls")) ///
				drop(_cons *.strata ?.miss_bl_* L*.*) ///  L.* `5' `6'
				star(* 0.1 ** 0.05 *** 0.01) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\addlinespace[0.3cm] \midrule") ///
				postfoot("\bottomrule \addlinespace[0.2cm] \multicolumn{7}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% \textit{Notes}: Panel A reports ANCOVA estimates as defined in \citet{Bruhn.2009}. Panel B documents IV estimates, instrumenting take-up with treatment assignment. All outcomes are measured at endline in 2023. 'Export readiness' is measured as an index constructed as in \citet{Anderson.2008}. Winsorization is at the 95\textsuperscript{th} percentile. Monetary values are in Tunisian Dinar. Standard errors are clustered on the firm-level and reported in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level.% \\ }} \\ \end{tabularx} \\ \end{adjustbox} \\ \end{table}")
				
				
end

export_perf eri_cont exported exp_dig export export_w95 ihs_export, gen(export)


}

***********************************************************************
* 	PART 4: Heterogeneity table: More vs. less credit constrained
***********************************************************************
* Digital Technology Adoption
capture program drop table1_het // enables re-running
program table1_het
version 16							// define Stata version
	syntax varlist(min=1 numeric), GENerate(string)
	
		* Loop over each variable & regress on treatment & take-up
    foreach var in `varlist' {

		sum L2.`var'
		if r(N) == 0  {
			
			// ITT: ANCOVA plus stratification dummies
				* More credit constrained
            eststo `var'1a: reg `var' i.treatment i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme)
            estadd local bl_control "No" : `var'1a
            estadd local strata "Yes" : `var'1a
				* Less credit constrained
			eststo `var'1b: reg `var' i.treatment i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme)
            estadd local bl_control "No" : `var'1b
            estadd local strata "Yes" : `var'1b


			// ATT, IV
				* More credit constrained
            eststo `var'2a: ivreg2 `var' i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) first
            estadd local bl_control "No" : `var'2a
            estadd local strata "Yes" : `var'2a
				
				* Less credit constrained
			eststo `var'2b: ivreg2 `var' i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) first
            estadd local bl_control "No" : `var'2b
            estadd local strata "Yes" : `var'2b
            
            // Calculate Control mean
				* More credit constrained 
            sum `var' if treatment == 0 & surveyround == 3 & bl_credit == 1
            estadd scalar control_mean = r(mean) : `var'2a
            estadd scalar control_sd = r(sd) : `var'2a
			
				* Less credit constrained
			sum `var' if treatment == 0 & surveyround == 3 & bl_credit == 0
            estadd scalar control_mean = r(mean) : `var'2b
            estadd scalar control_sd = r(sd) : `var'2b
			
		}
		
		else if `var' == knowledge {
			// ITT: ANCOVA plus stratification dummies
				* More credit constrained
			eststo `var'1a: reg `var' i.treatment L1.`var' i.miss_bl_`var' i.strata if surveyround == 2 & bl_credit == 1, cluster(id_plateforme)
			estadd local bl_control "Yes" : `var'1a
			estadd local strata "Yes" : `var'1a
				
				* Less credit constrained
			eststo `var'1b: reg `var' i.treatment L1.`var' i.miss_bl_`var' i.strata if surveyround == 2 & bl_credit == 0, cluster(id_plateforme)
			estadd local bl_control "Yes" : `var'1b
			estadd local strata "Yes" : `var'1b

			// ATT, IV
				* More credit constrained
			eststo `var'2a: ivreg2 `var' L1.`var' i.miss_bl_`var' i.strata (take_up = i.treatment) if surveyround == 2 & bl_credit == 1, cluster(id_plateforme) first
			estadd local bl_control "Yes" : `var'2a
			estadd local strata "Yes" : `var'2a

				* Less credit constrained
			eststo `var'2b: ivreg2 `var' L1.`var' i.miss_bl_`var' i.strata (take_up = i.treatment) if surveyround == 2 & bl_credit == 0, cluster(id_plateforme) first
			estadd local bl_control "Yes" : `var'2b
			estadd local strata "Yes" : `var'2b
			
			// Calculate Control mean
				* More credit constrained 
            sum `var' if treatment == 0 & surveyround == 2 & bl_credit == 1
            estadd scalar control_mean = r(mean) : `var'2a
            estadd scalar control_sd = r(sd) : `var'2a
			
				* Less credit constrained
			sum `var' if treatment == 0 & surveyround == 2 & bl_credit == 0
            estadd scalar control_mean = r(mean) : `var'2b
            estadd scalar control_sd = r(sd) : `var'2b
		}
        else {
			// ITT: ANCOVA plus stratification dummies
				* More credit constrained
            eststo `var'1a: reg `var' i.treatment L2.`var' i.miss_bl_`var' i.strata if surveyround == 3 & bl_credit == 1, cluster(id_plateforme)
            estadd local bl_control "Yes" : `var'1a
            estadd local strata "Yes" : `var'1a
			
				* Less credit constrained			
			eststo `var'1b: reg `var' i.treatment L2.`var' i.miss_bl_`var' i.strata if surveyround == 3 & bl_credit == 0, cluster(id_plateforme)
            estadd local bl_control "Yes" : `var'1b
            estadd local strata "Yes" : `var'1b

            // ATT, IV
				* More credit constrained
            eststo `var'2a: ivreg2 `var' L2.`var' i.miss_bl_`var' i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 1, cluster(id_plateforme) first
            estadd local bl_control "Yes" : `var'2a
            estadd local strata "Yes" : `var'2a
			
				* Less credit constrained		
            eststo `var'2b: ivreg2 `var' L2.`var' i.miss_bl_`var' i.strata (take_up = i.treatment) if surveyround == 3 & bl_credit == 0, cluster(id_plateforme) first
            estadd local bl_control "Yes" : `var'2b
            estadd local strata "Yes" : `var'2b
            
            // Calculate Control mean
				* More credit constrained 
            sum `var' if treatment == 0 & surveyround == 3 & bl_credit == 1
            estadd scalar control_mean = r(mean) : `var'2a
            estadd scalar control_sd = r(sd) : `var'2a
			
				* Less credit constrained
			sum `var' if treatment == 0 & surveyround == 3 & bl_credit == 0
            estadd scalar control_mean = r(mean) : `var'2b
            estadd scalar control_sd = r(sd) : `var'2b

        }
}

				* Put everything into a latex table	
tokenize `varlist'
		local regressions `1'1a `1'1b `2'1a `2'1b `3'1a `3'1b `4'1a `4'1b `5'1a `5'1b `6'1a `6'1b `7'1a `7'1b // `7'1 `10'1  adjust manually to number of variables 
		esttab `regressions' using "${tab_tech}/ecom_`generate'.tex", replace booktabs ///
			prehead("\begin{table}[!h] \centering \\ \caption{E-commerce: Heterogeneity by Baseline Credit-Constraint} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabularx}{\linewidth}{l*{14}{>{\centering\arraybackslash}X}} \toprule & \multicolumn{2}{c}{Knowledge} & \multicolumn{2}{c}{\shortstack{Adoption \\ Survey}} & \multicolumn{2}{c}{\shortstack{Adoption \\ Manual}} & \multicolumn{2}{c}{\shortstack{E-Employee \\ $>0$}} & \multicolumn{2}{c}{\shortstack{E-Invest \\ $>0$}} & \multicolumn{2}{c}{\shortstack{E-Revenue \\ $>0$}} & \multicolumn{2}{c}{E-Margin} \\ & +CC & –CC & +CC & –CC & +CC & –CC & +CC & –CC & +CC & –CC & +CC & –CC & +CC & –CC \\ \midrule") ///
				posthead("\toprule \\ \multicolumn{15}{c}{Panel A: Intention-to-treat (ITT)} \\\\[-1ex]") ///			
				fragment ///
				cells(b(star fmt(%6.2gc)) se(par fmt(%6.2gc))) /// p(fmt(3)) rw ci(fmt(2))
				mlabels(none) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				collabels(none) ///	do not use statistics names below models
				label 		/// specifies EVs have label
				drop(_cons *.strata ?.miss_bl_* L*.*) ///  L.* oL.*
				noobs
			
			* Bottom panel: ITT
		local regressions `1'2a `1'2b `2'2a `2'2b `3'2a `3'2b `4'2a `4'2b `5'2a `5'2b `6'2a `6'2b `7'2a `7'2b // `7'2 `4'2 `5'2 `6'2 `7'2 `8'2 `9'2 `10'2 adjust manually to number of variables 
		esttab `regressions' using "${tab_tech}/ecom_`generate'.tex", append booktabs ///
				fragment ///	
				posthead("\addlinespace[0.3cm] \midrule \\ \multicolumn{15}{c}{Panel B: Treatment Effect on the Treated (TOT)} \\\\[-1ex]") ///
				cells(b(star fmt(%6.2gc)) se(par fmt(%6.2gc))) /// p(fmt(3)) rw ci(fmt(2))
				stats(control_mean control_sd N strata bl_control, fmt(%9.2gc %9.2gc %9.0g) labels("Control mean" "Control SD" "Observations" "Strata" "BL controls")) ///
				drop(_cons *.strata ?.miss_bl_* L*.*) ///  L.* `5' `6'
				star(* 0.1 ** 0.05 *** 0.01) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\addlinespace[0.3cm] \midrule") ///
				postfoot("\bottomrule \addlinespace[0.2cm] \multicolumn{15}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% \textit{Notes}: Panel A reports ANCOVA estimates as defined in \citet{Bruhn.2009}. Panel B documents IV estimates, instrumenting take-up with treatment assignment. Knowledge and adoption are average z-scores as defined in \citet{Anderson.2008}. Knowledge is measured at midline, while all other outcomes are measured at the endline. Adoption survey is based on survey responses, while adoption manual is based on manual scoring of firms websites and social media accounts. Columns(4)-(6) present dummy variables. Standard errors are clustered on the firm-level and reported in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level.% \\ }} \\ \end{tabularx} \\ \end{adjustbox} \\ \end{table}")
				
				
end

table1_het knowledge dtai_survey dtai_manual dig_dummy dig_invest_extmargin dig_rev_extmargin dig_margins, gen(ta_het)
table1_het knowledge dtai_survey dtai_manual dig_dummy dig_invest_extmargin2 dig_rev_extmargin2 dig_margins, gen(ta_het) 
// replacement with 0 instead of . for e-commerce investment & revenue (assumption: if firm said idk, put in 0)



* Firm performance














***********************************************************************
* 	PART 10: Endline results - Presentation
***********************************************************************

capture program drop rct_presentation_exp // enables re-running
program rct_presentation_exp
	version 15							// define Stata version 15 used
	syntax varlist(min=1 numeric), GENerate(string)
		foreach var in `varlist' {		// do following for all variables in varlist seperately	
			
			* ITT: ancova plus stratification dummies
			eststo `var'1: reg `var' i.treatment i.strata if surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"

			* ATT, IV		
			eststo `var'2: ivreg2 `var' i.strata (take_up = i.treatment) if surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			
			* calculate Control mean
				* take mean at endline to control for time trends
sum `var' if treatment == 0 & surveyround == 3
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)

		}
	
	* change logic from "to same thing to each variable" (loop) to "use all variables at the same time" (program)
		* tokenize to use all variables at the same time
tokenize `varlist'

/*
		* Correct for MHT - FWER
rwolf2 ///
	(reg `1' treatment `1'_y0 i.missing_bl_`1' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `1' `1'_y0 i.missing_bl_`1' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)) ///
	(reg `2' treatment `2'_y0 i.missing_bl_`2' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `2' `2'_y0 i.missing_bl_`2' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)) ///
	(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)) ///
	(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)) ///
	(reg `5' treatment `5'_y0 i.missing_bl_`5' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `5' `5'_y0 i.missing_bl_`5' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)) ///
	(reg `6' treatment `6'_y0 i.missing_bl_`3' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)) ///
	(reg `7' treatment `7'_y0 i.missing_bl_`7' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `7' `7'_y0 i.missing_bl_`7' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)), ///
	indepvars(treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up) ///
	seed(110723) reps(30) usevalid strata(strata)

		* save ci(fmt(2)) rw-p-values in a seperate table for manual insertion in latex document
esttab e(ci(fmt(2)) rw) using rw_`generate'.tex, replace
*/

		* Put all regressions into one table
			* Top panel: ATE
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 `7'1 `8'1 `9'1 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Impact on digital technology adoption} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{6}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata) ///  ?.missing_bl_* *_y0
				noobs
				
				* Bottom panel: ITT
		local regressions `1'2 `2'2 `3'2 `4'2 `5'2 `6'2 `7'2 `8'2 `9'2 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control mean" "Control SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata) /// ?.missing_bl_* *_y0
				star(* 0.1 ** 0.05 *** 0.01) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{8}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception, knowledge, and use of z-score indices calculated following Kling et al. (2007). QI investment and quality defects are winsorized at the 98th percentile. Few quality defects is dummy equal to 1 if firms report one or less percent of defective products in the last month,  and zero otherwise. QI investment is measured in units of Tunisian dinar. Units were chosen based on the highest R-square as described in Aihounton and Henningsen (2020). Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`1'1, pstyle(p1)) (`1'2, pstyle(p1)) ///
	(`2'1, pstyle(p2)) (`2'2, pstyle(p2)) ///
	(`3'1, pstyle(p3)) (`3'2, pstyle(p3)) ///
	(`4'1, pstyle(p4)) (`4'2, pstyle(p4)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Exports 2023 (ITT)"' `1'2 = `"Exports 2023 (TOT)"' `2'1 = `"Exports 2024 (ITT)"' `2'2 = `"Exports 2024 (TOT)"' `3'1 = `"Digitally exports (ITT)"' ///
		`3'2 = `"Digitally exports (TOT)"' `4'1 = `"Digital margin (ITT)"' `4'2 = `"Digital margin (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot, replace)

gr export el_`generate'_cfplot.png, replace


* coefplot
coefplot ///
	(`5'1, pstyle(p5)) (`5'2, pstyle(p5)) ///
	(`6'1, pstyle(p6)) (`6'2, pstyle(p6)) ///
	(`7'1, pstyle(p7)) (`7'2, pstyle(p7)) ///
	(`8'1, pstyle(p8)) (`8'2, pstyle(p8)) ///
	(`9'1, pstyle(p9)) (`9'2, pstyle(p9)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`5'1 = `"Export not profitable (ITT)"' `5'2 = `"Export not profitable (TOT)"' `6'1 = `"Did not find clients abroad (ITT)"' `6'2 = `"Did not find clients abroad (TOT)"' `7'1 = `"Export complicated (ITT)"' `7'2 = `"Export complicated (TOT)"' `8'1 = `"Export requires investment (ITT)"' `8'2 = `"Export requires investment (TOT)"' `9'1 = `"Other (ITT)"' `9'2 = `"Other (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'2_cfplot, replace)
	
gr export el_`generate'2_cfplot.png, replace
			
end

	* apply program to qi outcomes
rct_presentation_exp exported exported_2024 exp_dig dig_margins export_41 export_42 export_43 export_44 export_45, gen(pres_exp)


capture program drop rct_presentation_nb // enables re-running
program rct_presentation_nb
	version 15							// define Stata version 15 used
	syntax varlist(min=1 numeric), GENerate(string)
		foreach var in `varlist' {		// do following for all variables in varlist seperately	
			
			* ITT: ancova plus stratification dummies
			eststo `var'1: reg `var' i.treatment i.strata if surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"

			* ATT, IV		
			eststo `var'2: ivreg2 `var' i.strata (take_up = i.treatment) if surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			
			* calculate Control mean
				* take mean at endline to control for time trends
sum `var' if treatment == 0 & surveyround == 3
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)

		}
	
	* change logic from "to same thing to each variable" (loop) to "use all variables at the same time" (program)
		* tokenize to use all variables at the same time
tokenize `varlist'

/*
		* Correct for MHT - FWER
rwolf2 ///
	(reg `1' treatment `1'_y0 i.missing_bl_`1' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `1' `1'_y0 i.missing_bl_`1' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)) ///
	(reg `2' treatment `2'_y0 i.missing_bl_`2' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `2' `2'_y0 i.missing_bl_`2' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)) ///
	(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)) ///
	(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)) ///
	(reg `5' treatment `5'_y0 i.missing_bl_`5' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `5' `5'_y0 i.missing_bl_`5' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)) ///
	(reg `6' treatment `6'_y0 i.missing_bl_`3' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)) ///
	(reg `7' treatment `7'_y0 i.missing_bl_`7' i.strata if surveyround==3, cluster(id_plateforme)) ///
	(ivreg2 `7' `7'_y0 i.missing_bl_`7' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)), ///
	indepvars(treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up) ///
	seed(110723) reps(30) usevalid strata(strata)

		* save ci(fmt(2)) rw-p-values in a seperate table for manual insertion in latex document
esttab e(ci(fmt(2)) rw) using rw_`generate'.tex, replace
*/

		* Put all regressions into one table
			* Top panel: ATE
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 `7'1 `8'1 `9'1 `10'1 `11'1 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Impact on digital technology adoption} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{6}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata) ///  ?.missing_bl_* *_y0
				noobs
				
				* Bottom panel: ITT
		local regressions `1'2 `2'2 `3'2 `4'2 `5'2 `6'2 `7'2 `8'2 `9'2 `10'2 `11'2 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control mean" "Control SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata) /// ?.missing_bl_* *_y0
				star(* 0.1 ** 0.05 *** 0.01) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{8}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception, knowledge, and use of z-score indices calculated following Kling et al. (2007). QI investment and quality defects are winsorized at the 98th percentile. Few quality defects is dummy equal to 1 if firms report one or less percent of defective products in the last month,  and zero otherwise. QI investment is measured in units of Tunisian dinar. Units were chosen based on the highest R-square as described in Aihounton and Henningsen (2020). Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`1'1, pstyle(p1)) (`1'2, pstyle(p1)) ///
	(`2'1, pstyle(p2)) (`2'2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Digital revenue (ITT)"' `1'2 = `"Digital revenue (TOT)"' `2'1 = `"Offline marketing investement (ITT)"' `2'2 = `"Offline marketing investement (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot, replace)

gr export el_`generate'_cfplot.png, replace


* coefplot
coefplot ///
	(`3'1, pstyle(p3)) (`3'2, pstyle(p3)) ///
	(`4'1, pstyle(p4)) (`4'2, pstyle(p4)) ///
	(`5'1, pstyle(p5)) (`5'2, pstyle(p5)) ///
	(`6'1, pstyle(p6)) (`6'2, pstyle(p6)) ///
	(`7'1, pstyle(p7)) (`7'2, pstyle(p7)) ///
	(`8'1, pstyle(p8)) (`8'2, pstyle(p8)) ///
	(`9'1, pstyle(p9)) (`9'2, pstyle(p9)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`3'1 = `"Absence/uncertainty of online demand (ITT)"' `3'2 = `"Absence/uncertainty of online demand (TOT)"' `4'1 = `"Lack of skilled staff (ITT)"' `4'2 = `"Lack of skilled staff (TOT)"' `5'1 = `"Inadequate infrastructure (ITT)"' `5'2 = `"Inadequate infrastructure (TOT)"' `6'1 = `"Cost is too high (ITT)"' `6'2 = `"Cost is too high (TOT)"' `7'1 = `"Restrictive government regulations (ITT)"' `7'2 = `"Restrictive government regulations (TOT)"' `8'1 = `"Resistance to change (ITT)"' `8'2 = `"Resistance to change (TOT)"' `9'1 = `"Other (ITT)"' `9'2 = `"Other (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'2_cfplot, replace)
	
gr export el_`generate'2_cfplot.png, replace

			* coefplot
coefplot ///
	(`10'1, pstyle(p10)) (`10'2, pstyle(p10)) ///
	(`11'1, pstyle(p11)) (`11'2, pstyle(p11)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`10'1 = `"Cost of online sales (ITT)"' `10'2 = `"Cost of online sales (TOT)"' `11'1 = `"Benefits of online sales (ITT)"' `11'2 = `"Benefits of online sales (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'3_cfplot, replace)

gr export el_`generate'3_cfplot.png, replace
			
end

	* apply program to qi outcomes
rct_presentation_nb ihs_w99_dig_rev20 ihs_mark_invest_99 dig_barr1 dig_barr2 dig_barr3 dig_barr4 dig_barr5 dig_barr6 dig_barr7 investecom_benefit1 investecom_benefit2, gen(pres_nb)
