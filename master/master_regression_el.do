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
		
		* change directory
cd "${master_gdrive}/output/endline_regressions"

* xtset data to enable use of lag operator for inclusion of baseline value of Y
xtset id_plateforme surveyround

*add colors
set scheme s1color

***********************************************************************
* 	PART 0.1:  set the stage - rename variables for simpler looping	
***********************************************************************

/* 		RENAME IF NEEDED AFTER THE STRUCTURE OF MASTER IS SET
	* special case to temporary
foreach var of varlist prix q391 q393 q28_pays_nb rdd q396 {
		rename `var' `var'_temp
}
	

rename lprice prix
	
*/

***********************************************************************
* 	PART 0.2:  set the stage - generate export & business performance z-scores
***********************************************************************

{
local indexes ///
	 dig_presence_index dsi dmi dtp dtai eri epi bpi_2023 bpi_2024 ihs_digrev_99 ihs_ca99_2023 comp_ca2024 ihs_profit99_2023 ihs_profit99_2024 ihs_fte_99 dig_empl fte_femmes car_carempl_div3 ihs_mark_invest_99 ///
	 export_1 exp_pays clients_b2c clients_b2b ihs_ca97_2024 ihs_dig_invest_99 dig_margins exp_dig ihs_dig_empl_99 dig_rev_extmargin dig_invest_extmargin profit_2023_pos profit_2024_pos ///
	 ihs_fte_femmes_99 ihs_fte_young_99 ihs_clients_b2b_99 mark_online1 mark_online2 mark_online3 mark_online4 mark_online5 cost_2023 cost_2024 ihs_cost97_2023 ihs_cost97_2024 ihs_clients_b2c_97

foreach var of local indexes {
		* generate YO
	bys id_plateforme (surveyround): gen `var'_first = `var'[_n == 1]		 // filter out baseline value
	egen `var'_y0 = min(`var'_first), by(id_plateforme)					 // create variable = bl value for all three surveyrounds by id_plateforme
	replace `var'_y0 = 0 if inlist(`var'_y0, ., -777, -888, -999, 666, 777, 888, 999)		// replace this variable = zero if missing
	drop `var'_first													// clean up
	lab var `var'_y0 "Y0 `var'"
		* generate missing baseline dummy
	gen miss_bl_`var' = 0 if surveyround == 1											// gen dummy for baseline
	replace miss_bl_`var' = 1 if surveyround == 1 & inlist(`var',., -777, -888, -999, 666, 777, 888, 999)	// replace dummy 1 if variable missing at bl
	egen missing_bl_`var' = min(miss_bl_`var'), by(id_plateforme)									// expand dummy to ml, el
	lab var missing_bl_`var' "YO missing, `var'"
	drop miss_bl_`var'
	}
}

***********************************************************************
* 	PART 0.3:  balance table
***********************************************************************
* endline per take_up
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
			 

***********************************************************************
* 	PART 1: Attrition
***********************************************************************
{
*test for differential total attrition
{
	* is there differential attrition between treatment and control group?
		* column (1): at endline
eststo att1, r: areg el_refus i.treatment if surveyround == 1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* column (2): at midline
eststo att2, r: areg ml_refus i.treatment if surveyround == 1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

local attrition att1 att2
esttab `attrition' using "el_attrition.tex", replace ///
	title("Attrition: Total") ///
	mtitles("BL" "ML") ///
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


***********************************************************************
* 	PART 2: Write a program that generates generic regression table	
***********************************************************************
{
capture program drop rct_regression_table // enables re-running
program rct_regression_table
	version 15								// define Stata version 15 used
	syntax varlist(min=1 numeric)		// input is variable list, minimum 1 numeric variable. * enables any options.
	foreach var in `varlist' {			// do following for all variables in varlist seperately
			* ATE, ancova	
					* no significant baseline differences
		reg `var' i.treatment if surveyround == 1, vce(hc3)
					
					* pure mean comparison at endline
		eststo `var'1, r: reg `var' i.treatment if surveyround == 3, vce(hc3)
		estadd local bl_control "No"
		estadd local strata "No"

					* ancova without stratification dummies
		eststo `var'2, r: reg `var' i.treatment `var'_y0 i.missing_bl_`var' if surveyround == 3, cluster(id_plateforme)
		estadd local bl_control "Yes"
		estadd local strata "No"

					* ancova plus stratification dummies
		eststo `var'3, r: reg `var' i.treatment `var'_y0 i.missing_bl_`var' i.strata if surveyround == 3, cluster(id_plateforme)
		estadd local bl_control "Yes"
		estadd local strata "Yes"
		estimates store `var'_ate

					* DiD
		eststo `var'4, r: xtreg `var' i.treatment##i.surveyround `var'_y0 i.missing_bl_`var' i.strata, cluster(id_plateforme)
		estadd local bl_control "Yes"
		estadd local strata "Yes"

					* ATT, IV		
		eststo `var'5, r: ivreg2 `var' `var'_y0 i.missing_bl_`var' i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first
		estadd local bl_control "Yes"
		estadd local strata "Yes"
		estimates store `var'_att
			
			* Put all regressions into one table
		local regressions `var'1 `var'2 `var'3 `var'4 `var'5
		esttab `regressions' using "rt_`var'.tex", replace ///
			mtitles("Mean comparison" "Ancova" "Ancova" "DiD" "ATT") ///
			label ///
			b(3) ///
			se(3) ///
			drop(*.strata ?.missing_bl_* *_y0) ///
			star(* 0.1 ** 0.05 *** 0.01) ///
			nobaselevels ///
			scalars("strata Strata controls" "`var'_y0 Y0 control") ///
			addnotes("Column (1) presents estimates for a simple mean comparison between treatment and control group at mid_plateformeline."  "Column (2) presents an ANCOVA specification without strata controls." "Column (3) presents an ANCOVA specification with strata controls." "Column (4) provid_plateformees estimates from a difference-in-difference specification." "Column (5) estimates are based on 2SLS instrumental variable estimation where treatment assignment is the instrument for treatment participation." "All standard errors are clustered at the firm level to account for multiple observations per firm." "Missing values in baseline outcome variable are replaced with zeros." "A dummy variable, which equals one if the variable is missing and zero otherwise, is added.")
			
	}
	
end
}

***********************************************************************
* 	PART 3: Endline results - regression table for each variable	
***********************************************************************

{
	* generate regression table for
		* z-scores	
			* QI index variables
rct_regression_table dsi dtai bpi_2023 bpi_2024 // MISSING VARS BASELINE: dmi dtp eri epi
			

		* numerical outcomes
			* financial
				*CONSIDER REPLACING WITH WINS-IHS TRANSFORMED & AVERAGE VAR
rct_regression_table ihs_digrev_99 // MISSING VARS BASELINE: ihs_dig_invest_99 ihs_ca99_2023 comp_ca2024 ihs_profit99_2023 ihs_profit99_2024

			* employees
				*CONSIDER REPLACING WITH WINS-IHS TRANSFORMED & AVERAGE VAR
rct_regression_table ihs_fte_99 fte_femmes car_carempl_div3  // MISSING VARS BASELINE: dig_empl car_carempl_div2

}



***********************************************************************
* 	PART 2: Write a program that generates generic regression table	
***********************************************************************
{
capture program drop rct_regression_table // enables re-running
program rct_regression_table
	version 15								// define Stata version 15 used
	syntax varlist(min=1 numeric)		// input is variable list, minimum 1 numeric variable. * enables any options.
	foreach var in `varlist' {			// do following for all variables in varlist seperately
			* ATE, ancova	
					* no significant baseline differences
		reg `var' i.treatment if surveyround == 1, vce(hc3)
					
					* pure mean comparison at endline
		eststo `var'1, r: reg `var' i.treatment if surveyround == 3, vce(hc3)
		estadd local bl_control "No"
		estadd local strata "No"

					* ancova without stratification dummies
		eststo `var'2, r: reg `var' i.treatment `var'_y0 i.missing_bl_`var' if surveyround == 3, cluster(id_plateforme)
		estadd local bl_control "Yes"
		estadd local strata "No"

					* ancova plus stratification dummies
		eststo `var'3, r: reg `var' i.treatment `var'_y0 i.missing_bl_`var' i.strata if surveyround == 3, cluster(id_plateforme)
		estadd local bl_control "Yes"
		estadd local strata "Yes"
		estimates store `var'_ate

					* DiD
		eststo `var'4, r: xtreg `var' i.treatment##i.surveyround `var'_y0 i.missing_bl_`var' i.strata, cluster(id_plateforme)
		estadd local bl_control "Yes"
		estadd local strata "Yes"

					* ATT, IV		
		eststo `var'5, r: ivreg2 `var' `var'_y0 i.missing_bl_`var' i.strata (take_up = i.treatment) if surveyround == 3, cluster(id_plateforme) first
		estadd local bl_control "Yes"
		estadd local strata "Yes"
		estimates store `var'_att
			
			* Put all regressions into one table
		local regressions `var'1 `var'2 `var'3 `var'4 `var'5
		esttab `regressions' using "rt_`var'.tex", replace ///
			mtitles("Mean comparison" "Ancova" "Ancova" "DiD" "ATT") ///
			label ///
			b(3) ///
			se(3) ///
			drop(*.strata ?.missing_bl_* *_y0) ///
			star(* 0.1 ** 0.05 *** 0.01) ///
			nobaselevels ///
			scalars("strata Strata controls" "`var'_y0 Y0 control") ///
			addnotes("Column (1) presents estimates for a simple mean comparison between treatment and control group at mid_plateformeline."  "Column (2) presents an ANCOVA specification without strata controls." "Column (3) presents an ANCOVA specification with strata controls." "Column (4) provid_plateformees estimates from a difference-in-difference specification." "Column (5) estimates are based on 2SLS instrumental variable estimation where treatment assignment is the instrument for treatment participation." "All standard errors are clustered at the firm level to account for multiple observations per firm." "Missing values in baseline outcome variable are replaced with zeros." "A dummy variable, which equals one if the variable is missing and zero otherwise, is added.")
			
	}
	
end
}

***********************************************************************
* 	PART 3: Endline results - regression table for each variable	
***********************************************************************

{
	* generate regression table for
		* z-scores	
			* QI index variables
rct_regression_table dsi dtai bpi_2023 bpi_2024 // MISSING VARS BASELINE: dmi dtp eri epi
			

		* numerical outcomes
			* financial
				*CONSIDER REPLACING WITH WINS-IHS TRANSFORMED & AVERAGE VAR
rct_regression_table ihs_digrev_99 // MISSING VARS BASELINE: ihs_dig_invest_99 ihs_ca99_2023 comp_ca2024 ihs_profit99_2023 ihs_profit99_2024

			* employees
				*CONSIDER REPLACING WITH WINS-IHS TRANSFORMED & AVERAGE VAR
rct_regression_table ihs_fte_99 fte_femmes car_carempl_div3  // MISSING VARS BASELINE: dig_empl car_carempl_div2

}
***********************************************************************
* 	PART 4: Endline results - regression table index outcomes
***********************************************************************

{
	
capture program drop rct_regression_index // enables re-running
program rct_regression_index
	version 15							// define Stata version 15 used
	syntax varlist(min=1 numeric), GENerate(string)
		foreach var in `varlist' {		// do following for all variables in varlist seperately	
			
			* ITT: ancova plus stratification dummies
			eststo `var'1: reg `var' i.treatment c.`var'_y0 i.missing_bl_`var' i.strata if surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"

			* ATT, IV		
			eststo `var'2: ivreg2 `var' c.`var'_y0 i.missing_bl_`var' i.strata (take_up = i.treatment) if surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			
			* calculate control group mean
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
esttab e(rw) ci(fmt(2)) using rw_`generate'.tex, replace
*/
		* Put all regressions into one table
			* Top panel: ATE
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 `7'1  // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Impact on indicies} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{6}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
		local regressions `1'2 `2'2 `3'2 `4'2 `5'2 `6'2 `7'2 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
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
	(`4'1, pstyle(p4)) (`4'2, pstyle(p4)) ///
	(`5'1, pstyle(p5)) (`5'2, pstyle(p5)) ///
	(`6'1, pstyle(p6)) (`6'2, pstyle(p6)) ///
	(`7'1, pstyle(p7)) (`7'2, pstyle(p7)) ///
	(`8'1, pstyle(p8)) (`8'2, pstyle(p8)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Digital sales index (ITT)"' `1'2 = `"Digital sales index (TOT)"' `2'1 = `"Digital marketing index (ITT)"' `2'2 = `"Digital marketing index (TOT)"' `3'1 = `"Digital technology Perception (ITT)"' ///
		`3'2 = `"Digital technology Perception (TOT)"' `4'1 = `"Digital technology adoption index (ITT)"' `4'2 = `"Digital technology adoption index"' `5'1 = `"Export readiness index (ITT)"' `5'2 = `"Export readiness index (TOT)"' ///
		`6'1 = `"Export performance index (ITT)"' `6'2 = `"Export performance index (TOT)"' `7'1 = `"Business performance index 2023 (ITT)"' `7'2 = `"Business performance index 2023 (TOT)"' `8'1 = `"Business performance index 2024 (ITT)"' `8'2 = `"Business performance index 2024 (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot, replace)
	
gr export el_`generate'_cfplot.png, replace
			
end


	* apply program to qi outcomes
rct_regression_index dsi dmi dtp dtai eri epi bpi_2023 bpi_2024, gen(index)

}			

***********************************************************************
* 	PART 5: Endline results - regression table financial outcomes
***********************************************************************
{
	
capture program drop rct_regression_finance // enables re-running
program rct_regression_finance
	version 15							// define Stata version 15 used
	syntax varlist(min=1 numeric), GENerate(string)
		foreach var in `varlist' {		// do following for all variables in varlist seperately	
			
			* ITT: ancova plus stratification dummies
			eststo `var'1: reg `var' i.treatment c.`var'_y0 i.missing_bl_`var' i.strata if surveyround ==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"

			* ATT, IV		
			eststo `var'2: ivreg2 `var' c.`var'_y0 i.missing_bl_`var' i.strata (take_up = i.treatment) if surveyround ==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			
			* calculate control group mean
				* take mean over surveyrounds to control for time trend
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
	(reg `1' treatment `1'_y0 i.missing_bl_`1' i.strata if surveyround ==3, cluster(id_plateforme)) ///
	(ivreg2 `1' `1'_y0 i.missing_bl_`1' i.strata (take_up = treatment) if surveyround ==3, cluster(id_plateforme)) ///
	(reg `2' treatment `2'_y0 i.missing_bl_`2' i.strata if surveyround ==3, cluster(id_plateforme)) ///
	(ivreg2 `2' `2'_y0 i.missing_bl_`2' i.strata (take_up = treatment) if surveyround ==3, cluster(id_plateforme)) ///
	(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata if surveyround ==3, cluster(id_plateforme)) ///
	(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata (take_up = treatment) if surveyround ==3, cluster(id_plateforme)) ///
	(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata if surveyround ==3, cluster(id_plateforme)) ///
	(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata (take_up = treatment) if surveyround ==3, cluster(id_plateforme)) ///
	(reg `5' treatment `5'_y0 i.missing_bl_`5' i.strata if surveyround ==3, cluster(id_plateforme)) ///
	(ivreg2 `5' `5'_y0 i.missing_bl_`5' i.strata (take_up = treatment) if surveyround ==3, cluster(id_plateforme)) ///
	(reg `6' treatment `6'_y0 i.missing_bl_`6' i.strata if surveyround ==3, cluster(id_plateforme)) ///
	(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)), ///
	indepvars(treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up) ///
	seed(110723) reps(30) usevalid strata(strata)

		* save ci(fmt(2)) rw-p-values in a seperate table for manual insertion in latex document
esttab e(ci(fmt(2)) rw) using rw_`generate'.tex, replace
*/
	
		* Put all regressions into one table
			* Top panel: ATE
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Impact on financial outcomes} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{9}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{8}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
		local regressions `1'2 `2'2 `3'2 `4'2 `5'2 `6'2 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{8}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{12}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception, knowledge, and use of z-score indices calculated following Kling et al. (2007). QI investment and quality defects are winsorized at the 98th percentile. Few quality defects is dummy equal to 1 if firms report one or less percent of defective products in the last month,  and zero otherwise. QI investment is measured in units of Tunisian dinar. Units were chosen based on highest R-square as described in Aihounton and Henningsen (2020). Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`1'1, pstyle(p1)) (`1'2, pstyle(p1)) ///
	(`2'1, pstyle(p2)) (`2'2, pstyle(p2)) ///
	(`3'1, pstyle(p3)) (`3'2, pstyle(p3)) ///
	(`4'1, pstyle(p4)) (`4'2, pstyle(p4)) ///
	(`5'1, pstyle(p5)) (`5'2, pstyle(p5)) ///
	(`6'1, pstyle(p6)) (`6'2, pstyle(p6)) ///
	(`7'1, pstyle(p7)) (`7'2, pstyle(p7)) ///
	(`8'1, pstyle(p8)) (`8'2, pstyle(p8)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Digital revenue (ITT)"' `1'2 = `"Digital revenue (TOT)"' `2'1 = `"Digital investment (ITT)"' `2'2 = `"Digital investment (TOT)"' `3'1 = `"Turnover 2023 (ITT)"' `3'2 = `"Turnover 2023 (TOT)"' ///
		`4'1 = `"Turnover 2024 (ITT)"' `4'2 = `"Turnover 2024 (TOT)"' `5'1 = `"Costs 2023 (ITT)"' `5'2 = `"Costs 2023  (TOT)"' `6'1 = `"Costs 2024 (ITT)"' `6'2 = `"Costs 2024 (TOT)"' `7'1 = `"Profit 2023 (ITT)"' `7'2 = `"Profit 2023  (TOT)"' `8'1 = `"Profit 2024 (ITT)"' `8'2 = `"Profit 2024 (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot1, replace)
gr export el_`generate'_cfplot1.png, replace

* coefplot
coefplot ///
	(`9'1, pstyle(p1)) (`9'2, pstyle(p1)) ///
	(`10'1, pstyle(p2)) (`10'2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`9'1 = `"Profit 2023 > 0 (ITT)"' `9'2 = `"Profit 2023 > 0 (TOT)"' `10'1 = `"Profit 2024 > 0 (ITT)"' `10'2 = `"Profit 2024 > 0 (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'2_cfplot1, replace)
gr export el_`generate'2_cfplot1.png, replace
		
end

	* apply program to qi outcomes
rct_regression_finance ihs_digrev_99 ihs_dig_invest_99 ihs_ca99_2023 ihs_ca97_2024 ihs_cost97_2023 ihs_cost97_2024 ihs_profit99_2023 ihs_profit99_2024 profit_2023_pos profit_2024_pos, gen(finance)

}

***********************************************************************
* 	PART 6: Endline results - regression table employees outcomes
***********************************************************************
{

capture program drop rct_regression_fte // enables re-running
program rct_regression_fte
	version 15							// define Stata version 15 used
	syntax varlist(min=1 numeric), GENerate(string)
		foreach var in `varlist' {		// do following for all variables in varlist seperately	
	* ITT: ancova plus stratification dummies						
			* ITT: ancova plus stratification dummies
			eststo `var'1: reg `var' i.treatment c.`var'_y0 i.missing_bl_`var' i.strata if surveyround ==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"

			* ATT, IV		
			eststo `var'2: ivreg2 `var' c.`var'_y0 i.missing_bl_`var' i.strata (take_up = i.treatment) if surveyround ==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			
			* calculate control group mean
				* take mean over surveyrounds to control for time trend
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
	(reg `1' treatment `1'_y0 i.missing_bl_`1' i.strata if surveyround ==3, cluster(id_plateforme)) ///
	(ivreg2 `1' `1'_y0 i.missing_bl_`1' i.strata (take_up = treatment) if surveyround ==3, cluster(id_plateforme)) ///
	(reg `2' treatment `2'_y0 i.missing_bl_`2' i.strata if surveyround ==3, cluster(id_plateforme)) ///
	(ivreg2 `2' `2'_y0 i.missing_bl_`2' i.strata (take_up = treatment) if surveyround ==3, cluster(id_plateforme)), ///
	indepvars(treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up) ///
	seed(110723) reps(30) usevalid strata(strata)

	* save ci(fmt(2)) rw-p-values in a seperate table for manual insertion in latex document
esttab e(ci(fmt(2)) rw) using rw_`generate'.tex, replace  
*/	
				* Put all regressions into one table
			* Top panel: ITT
*		tokenize `varlist'
		local regressions `1'1 `2'1 `3'1 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Impact on number of employees} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{4}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				collabels(none) ///	do not use statistics names below models
				label 		/// specifies EVs have label
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
			* Bottom panel: ATT
		local regressions `1'2 `2'2 `3'2 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				label ///
				nobaselevels ///
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{11}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. All outcomes are z-scores calculated following Kling et al. (2007). Coefficients display effects in standard deviation units of the outcome. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				

			* coefplot
coefplot ///
	(`1'1, pstyle(p1)) (`1'2, pstyle(p1)) ///
	(`2'1, pstyle(p2)) (`2'2, pstyle(p2)) ///
	(`3'1, pstyle(p3)) (`3'2, pstyle(p3)) ///
	(`4'1, pstyle(p4)) (`4'2, pstyle(p4)) ///
	(`5'1, pstyle(p5)) (`5'2, pstyle(p5)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Employees (ITT)"' `1'2 = `"Employees (TOT)"' `2'1 = `"Female Employees (ITT)"' `2'2 = `"Female Employees (TOT)"' `3'1 = `"Young Employees (ITT)"' `3'2 = `"Young Employees (TOT)"' `4'1 = `"Digital employees (ITT)"' `4'2 = `"Digital employees (TOT)"' `5'1 = `"Digital margin (ITT)"' `5'2 = `"Digital margin (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot1, replace)
gr export el_`generate'_cfplot1.png, replace

end

	* apply program to business performance outcomes
rct_regression_fte ihs_fte_99 ihs_fte_femmes_99 ihs_fte_young_99 ihs_dig_empl_99 dig_margins, gen(empl)

}

*AS PER FLORIAN CLASSIFICATION
***********************************************************************
* 	PART 7: Endline results - regression table Digital Technology Adoption
***********************************************************************

capture program drop rct_regression_dta // enables re-running
program rct_regression_dta
	version 15							// define Stata version 15 used
	syntax varlist(min=1 numeric), GENerate(string)
		foreach var in `varlist' {		// do following for all variables in varlist seperately	
			
			* ITT: ancova plus stratification dummies
			eststo `var'1: reg `var' i.treatment c.`var'_y0 i.missing_bl_`var' i.strata if surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"

			* ATT, IV		
			eststo `var'2: ivreg2 `var' c.`var'_y0 i.missing_bl_`var' i.strata (take_up = i.treatment) if surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			
			* calculate control group mean
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
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 `7'1  // adjust manually to number of variables 
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
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
		local regressions `1'2 `2'2 `3'2 `4'2 `5'2 `6'2 `7'2 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
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
	(`4'1, pstyle(p4)) (`4'2, pstyle(p4)) ///
	(`5'1, pstyle(p5)) (`5'2, pstyle(p5)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Digital technology adoption index (ITT)"' `1'2 = `"Digital technology adoption index (TOT)"' `2'1 = `"Digital sales index (ITT)"' `2'2 = `"Digital sales index (TOT)"' `3'1 = `"Digital marketing index (ITT)"' ///
		`3'2 = `"Digital marketing index (TOT)"' `4'1 = `"Digital employees (ITT)"' `4'2 = `"Digital employees (TOT)"' `5'1 = `"Digital revenue, pct (ITT)"' `5'2 = `"Digital revenue, pct (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot, replace)

gr export el_`generate'_cfplot.png, replace


* coefplot
coefplot ///
	(`6'1, pstyle(p6)) (`6'2, pstyle(p6)) ///
	(`7'1, pstyle(p7)) (`7'2, pstyle(p7)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`6'1 = `"Digital Invest (ITT)"' `6'2 = `"Digital Invest (TOT)"' `7'1 = `"Marketing Invest (ITT)"' `7'2 = `"Marketing Invest (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'2_cfplot, replace)
	
gr export el_`generate'2_cfplot.png, replace
			
end


	* apply program to qi outcomes
rct_regression_dta dtai dsi dmi ihs_dig_empl_99 ihs_digrev_99 ihs_dig_invest_99 ihs_mark_invest_99, gen(dta)		

***********************************************************************
* 	PART 8: Endline results - regression table Export
***********************************************************************

capture program drop rct_regression_exp // enables re-running
program rct_regression_exp
	version 15							// define Stata version 15 used
	syntax varlist(min=1 numeric), GENerate(string)
		foreach var in `varlist' {		// do following for all variables in varlist seperately	
			
			* ITT: ancova plus stratification dummies
			eststo `var'1: reg `var' i.treatment c.`var'_y0 i.missing_bl_`var' i.strata if surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"

			* ATT, IV		
			eststo `var'2: ivreg2 `var' c.`var'_y0 i.missing_bl_`var' i.strata (take_up = i.treatment) if surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			
			* calculate control group mean
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
	(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)), ///
	indepvars(treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up) ///
	seed(110723) reps(30) usevalid strata(strata)

		* save ci(fmt(2)) rw-p-values in a seperate table for manual insertion in latex document
esttab e(ci(fmt(2)) rw) using rw_`generate'.tex, replace
*/

		* Put all regressions into one table
			* Top panel: ATE
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 `7'1 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Impact on export} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{7}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{6}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
		local regressions `1'2 `2'2 `3'2 `4'2 `5'2 `6'2 `7'2 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{6}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
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
	(`7'1, pstyle(p7)) (`7'2, pstyle(p7)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Export readiness index (ITT)"' `1'2 = `"Export readiness index (TOT)"' `2'1 = `"Export performance index (ITT)"' `2'2 = `"Export performance index (TOT)"' `3'1 = `"Exports (ITT)"' `3'2 = `"Exports (TOT)"' `7'1 = `"Digitally Exports (ITT)"' `7'2 = `"Digitally Exports (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot, replace)
	
gr export el_`generate'_cfplot.png, replace

* coefplot
coefplot ///
	(`4'1, pstyle(p4)) (`4'2, pstyle(p4)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`4'1 = `"Export countries (ITT)"' `4'2 = `"Export countries (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'2_cfplot, replace)
	
gr export el_`generate'2_cfplot.png, replace

* coefplot
coefplot ///
	(`5'1, pstyle(p5)) (`5'2, pstyle(p5)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`5'1 = `"Clients B2C (ITT)"' `5'2 = `"Clients B2C (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'3_cfplot, replace)
	
gr export el_`generate'3_cfplot.png, replace

* coefplot
coefplot ///
	(`6'1, pstyle(p6)) (`6'2, pstyle(p6)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename( `6'1 = `"IHS Clients B2B 99th wins. (ITT)"' `6'2 = `"IHS Clients B2B 99th wins. (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'4_cfplot, replace)
	
gr export el_`generate'4_cfplot.png, replace
			
			
end


	* apply program to qi outcomes
rct_regression_exp eri epi export_1 exp_pays ihs_clients_b2c_97 ihs_clients_b2b_99 exp_dig, gen(exp)

***********************************************************************
* 	PART 9: Endline results - regression digital marketing outcomes
***********************************************************************

capture program drop rct_regression_dmo // enables re-running
program rct_regression_dmo
	version 15							// define Stata version 15 used
	syntax varlist(min=1 numeric), GENerate(string)
		foreach var in `varlist' {		// do following for all variables in varlist seperately	
			
			* ITT: ancova plus stratification dummies
			eststo `var'1: reg `var' i.treatment c.`var'_y0 i.missing_bl_`var' i.strata if surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"

			* ATT, IV		
			eststo `var'2: ivreg2 `var' c.`var'_y0 i.missing_bl_`var' i.strata (take_up = i.treatment) if surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			
			* calculate control group mean
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
	(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata (take_up = treatment) if surveyround==3, cluster(id_plateforme)), ///
	indepvars(treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up) ///
	seed(110723) reps(30) usevalid strata(strata)

		* save ci(fmt(2)) rw-p-values in a seperate table for manual insertion in latex document
esttab e(ci(fmt(2)) rw) using rw_`generate'.tex, replace
*/

		* Put all regressions into one table
			* Top panel: ATE
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 `7'1 `8'1 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Impact on Digital marketing outcomes} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{7}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{6}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
		local regressions `1'2 `2'2 `3'2 `4'2 `5'2 `6'2 `7'2 `8'2 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{6}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
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
	(`4'1, pstyle(p4)) (`4'2, pstyle(p4)) ///
	(`5'1, pstyle(p5)) (`5'2, pstyle(p5)) ///
	(`9'1, pstyle(p9)) (`9'2, pstyle(p9)) ///
	(`10'1, pstyle(p10)) (`10'2, pstyle(p10)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Email online marketing (ITT)"' `1'2 = `"Email online marketing (TOT)"' `2'1 = `"SEO/SEA online marketing (ITT)"' `2'2 = `"SEO/SEA online marketing (TOT)"' `3'1 = `"Free social media marketing (ITT)"' `3'2 = `"Free social media marketing (TOT)"' `4'1 = `"Paid social media marketing (ITT)"' `4'2 = `"Paid social media marketing (TOT)"' `5'1 = `"Other online marketing (ITT)"' `5'2 = `"Other online marketing (TOT)"' `9'1 = `"Digital Revenue > 0 (ITT)"' `9'2 = `"Digital Revenue > 0 (TOT)"' `10'1 = `"Digital Invest > 0 (ITT)"' `10'2 = `"Digital Invest > 0 (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot, replace)
		
gr export el_`generate'_cfplot.png, replace

* coefplot
coefplot ///
	(`6'1, pstyle(p6)) (`6'2, pstyle(p6)) ///
	(`7'1, pstyle(p7)) (`7'2, pstyle(p7)) ///
	(`8'1, pstyle(p8)) (`8'2, pstyle(p8)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`6'1 = `"Digital employees (ITT)"' `6'2 = `"Digital employees (TOT)"' `7'1 = `"Digital Invest (ITT)"' `7'2 = `"Digital Invest (TOT)"' `8'1 = `"Marketing Invest (ITT)"' `8'2 = `"Marketing Invest (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'2_cfplot, replace)
gr export el_`generate'2_cfplot.png, replace

end
	* apply program to qi outcomes
rct_regression_dmo mark_online1 mark_online2 mark_online3 mark_online4 mark_online5 ihs_dig_empl_99 ihs_dig_invest_99 ihs_mark_invest_99 dig_rev_extmargin dig_invest_extmargin, gen(dmo)