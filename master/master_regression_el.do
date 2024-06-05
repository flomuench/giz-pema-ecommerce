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
	 dsi dmi dtp dtai eri epi bpi

foreach var of local indexes {
		* generate YO
	bys id_plateforme (surveyround): gen `var'_first = `var'[_n == 1]		 // filter out baseline value
	egen `var'_y0 = min(`var'_first), by(id_plateforme)					 // create variable = bl value for all three surveyrounds by id_plateforme
	replace `var'_y0 = 0 if inlist(`var'_y0, ., -777, -888, -999)		// replace this variable = zero if missing
	drop `var'_first													// clean up
	lab var `var'_y0 "Y0 `var'"
		* generate missing baseline dummy
	gen miss_bl_`var' = 0 if surveyround == 1											// gen dummy for baseline
	replace miss_bl_`var' = 1 if surveyround == 1 & inlist(`var',., -777, -888, -999)	// replace dummy 1 if variable missing at bl
	egen missing_bl_`var' = min(miss_bl_`var'), by(id_plateforme)									// expand dummy to ml, el
	lab var missing_bl_`var' "YO missing, `var'"
	drop miss_bl_`var'
	}
}

***********************************************************************
* 	PART 1: Attrition
***********************************************************************
*test for differential total attrition
{
	* is there differential attrition between treatment and control group?
		* column (1): at endline
eststo att1, r: areg el_attrit i.treatment if surveyround == 3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* column (2): at midline
eststo att2, r: areg ml_attrit i.treatment if surveyround == 2, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

		* column (3): at baseline
eststo att3, r: areg bl_attrit i.treatment if surveyround == 1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

local attrition att1 att2 att3
esttab `attrition' using "el_attrition.tex", replace ///
	title("Attrition: Total") ///
	mtitles("EL" "ML" "BL") ///
	label ///
	b(3) ///
	se(3) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls") ///
	addnotes("All standard errors are Hubert-White robust standord errors clustered at the firm level." "Indexes are z-score as defined in Kling et al. 2007.")
		
}

*test for selective attrition on key outcome variables (indexes)
{
		* c(1): digtech_index
eststo att4,r: areg  dsi treatment##el_attrit digtech_index_y0 i.missing_bl_digtech_index if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* c(2): digsales_index
eststo att5,r: areg  dmi treatment##el_attrit digsales_index_y0 i.missing_bl_digsales_index if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* c(3): digmarkt_index
eststo att6,r: areg  dtp treatment##el_attrit digmarkt_index_y0 i.missing_bl_digmarkt_index if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"	

		* c(4): dig_empl
eststo att7,r: areg  dtai treatment##el_attrit dig_empl_y0 i.missing_bl_dig_empl if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* c(5): dig_revenues_ecom
eststo att8,r: areg  eri treatment##el_attrit dig_revenues_ecom_y0 i.missing_bl_dig_revenues_ecom if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"		// consider replacing with quantile transformed profits instead

		* c(6): dig_invest
eststo att9,r: areg  epi treatment##el_attrit dig_invest_y0 i.missing_bl_dig_invest if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"
		
		* c(7): epi
eststo att10,r: areg  bpi treatment##el_attrit epi_y0 i.missing_bl_epi if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

local attrition att4 att5 att6 att7 att8 att9 att10
esttab `attritionkey' using "el_keyattrition.tex", replace ///
	title("Attrition: Indexes") ///
	mtitles("Digital sales index" "Digital marketing index" "Digital technology Perception" "Digital technology adoption index" "Export readiness index" "Export performance index" "Business performance index") ///
	label ///
	b(3) ///
	se(3) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls") ///
	addnotes("Notes: All Columns consider only endline response behaviour."  "All standard errors are Hubert-White robust standord errors clustered at the firm level." "Indexes are z-score as defined in Kling et al. 2007.")
}

{
*test for selective attrition on key outcome variables
		* c(1): dig_revenues_ecom
eststo att4,r: areg dig_revenues_ecom treatment##el_attrit dig_revenues_ecom _y0 i.missing_bl_dig_revenues_ecom if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"	// WINS? IHS?
		
		* c(2): dig_invest
eststo att5,r: areg dig_invest treatment##el_attrit dig_invest_y0 i.missing_bl_dig_invest if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"	// WINS? IHS?
		
		* c(3):  comp_ca2023
eststo att6,r: areg  comp_ca2023 treatment##el_attrit comp_ca2023_y0 i.missing_bl_comp_ca2023 if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"		// WINS? IHS? AVERAGE?

		* c(4): comp_ca2024
eststo att7,r: areg comp_ca2024 treatment##el_attrit comp_ca2024_y0 i.missing_bl_comp_ca2024 if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"	// WINS? IHS? AVERAGE?
		
		* c(5): comp_benefit2023
eststo att8,r: areg comp_benefit2023 treatment##el_attrit comp_benefit2023_y0 i.missing_bl_comp_benefit2023 if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"	// WINS? IHS? AVERAGE?

		* c(6): comp_benefit2024
eststo att9,r: areg  comp_benefit2024 treatment##el_attrit dcomp_benefit2024_y0 i.missing_bl_comp_benefit2024 if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"	// WINS? IHS? AVERAGE?

		* c(7): empl
eststo att10,r: areg empl treatment##el_attrit empl_y0 i.missing_bl_empl if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"	// WINS? IHS? AVERAGE?

		* c(8): dig_empl
eststo att11,r: areg dig_empl treatment##el_attrit dig_empl_y0 i.missing_bl_dig_empl if surveyround==3, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"	// WINS? IHS? AVERAGE?
		
local attrition att4 att5 att6 att7 att8 att9 att10 att11
esttab `attritionkey' using "el_keyattrition.tex", replace ///
	title("Attrition: Key outcomes") ///
	mtitles("Digital revenue" "Digital investment" "Turnover 2023" "Turnover 2024" "Profit 2023" "Profit 2024" "Employees" "Digital employees") ///
	label ///
	b(3) ///
	se(3) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls") ///
	addnotes("Notes: All Columns consider only endline response behaviour."  "All standard errors are Hubert-White robust standord errors clustered at the firm level." "Indexes are z-score as defined in Kling et al. 2007.")
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
		eststo `var'4, r: xtreg `var' i.treatment##i.post `var'_y0 i.missing_bl_`var' i.strata if surveyround != 2, cluster(id_plateforme)
		estadd local bl_control "Yes"
		estadd local strata "Yes"			

					* ATT, IV		
		eststo `var'5, r: ivreg2 `var' `var'_y0 i.missing_bl_`var' i.strata (take_up_sum2 = i.treatment) if surveyround == 3, cluster(id_plateforme) first
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
			addnotes("Column (1) presents estimates for a simple mean comparison between treatment and control group at midline."  "Column (2) presents an ANCOVA specification without strata controls." "Column (3) presents an ANCOVA specification with strata controls." "Column (4) provides estimates from a difference-in-difference specification." "Column (5) estimates are based on 2SLS instrumental variable estimation where treatment assignment is the instrument for treatment participation." "All standard errors are clustered at the firm level to account for multiple observations per firm." "Missing values in baseline outcome variable are replaced with zeros." "A dummy variable, which equals one if the variable is missing and zero otherwise, is added.")
			
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
rct_regression_table dsi dmi dtp dtai eri epi bpi
			

		* numerical outcomes
			* financial
rct_regression_table dig_revenues_ecom dig_invest comp_ca2023 comp_ca2024 comp_benefice2023 comp_benefice2024 // CONSIDER REPLACING WITH WINS-IHS TRANSFORMED & AVERAGE VAR

			* employees
rct_regression_table fte car_carempl_div1 car_carempl_div2 car_carempl_div3 dig_empl // CONSIDER REPLACING WITH WINS-IHS TRANSFORMED & AVERAGE VAR

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
	(`7'1, pstyle(p7)) (`7'2, pstyle(p7)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Digital sales index (ITT)"' `1'2 = `"Digital sales index (TOT)"' `2'1 = `"Digital marketing index (ITT)"' `2'2 = `"Digital marketing index (TOT)"' `3'1 = `"Digital technology Perception (ITT)"' ///
		`3'2 = `"Digital technology Perception (TOT)"' `4'1 = `"Digital technology adoption index (ITT)"' `4'2 = `"Digital technology adoption index"' `5'1 = `"Export readiness index (ITT)"' `5'2 = `"Export readiness index (TOT)"' ///
		`6'1 = `"Export performance index (ITT)"' `6'2 = `"Export performance index (TOT)"' `7'1 = `"Business performance index (ITT)"' `7'2 = `"Business performance index"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot, replace)
	
gr export el_`generate'_cfplot.png, replace
			
end


	* apply program to qi outcomes
rct_regression_index dsi dmi dtp dtai eri epi bpi, gen(index)

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
	(`6'1, pstyle(p6)) (`6'2, pstyle(p6)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Digital revenue (ITT)"' `1'2 = `"Digital revenue (TOT)"' `2'1 = `"Digital investment (ITT)"' `2'2 = `"Digital investment (TOT)"' `3'1 = `"Turnover 2023 (ITT)"' `3'2 = `"Turnover 2023 (TOT)"' ///
		`4'1 = `"Turnover 2024 (ITT)"' `4'2 = `"Turnover 2024 (TOT)"' `5'1 = `"Profit 2023 (ITT)"' `5'2 = `"Profit 2023  (TOT)"' `6'1 = `"Profit 2024 (ITT)"' `6'2 = `"Profit 2024 (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot1, replace)
gr export el_`generate'_cfplot1.png, replace
		
end

	* apply program to qi outcomes
rct_regression_finance dig_revenues_ecom dig_invest comp_ca2023 comp_ca2024 comp_benefice2023 comp_benefice2024, gen(finance)

}

***********************************************************************
* 	PART 6: Endline results - regression table employees outcomes
***********************************************************************
{

capture program drop rct_regression_empl // enables re-running
program rct_regression_empl
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
	
				* Put all regressions into one table
			* Top panel: ITT
*		tokenize `varlist'
		local regressions `1'1 `2'1 // adjust manually to number of variables 
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
		local regressions `1'2 `2'2 `3'2 `4'2 `5'2 `6'2 `7'2 `8'2 `9'2 `10'2    // adjust manually to number of variables 
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
	(`2'1, pstyle(p2)) (`2'2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Employees (ITT)"' `1'2 = `"Employees (TOT)"' `2'1 = `"Digital employees (ITT)"' `2'2 = `"Digital employees (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot1, replace)
gr export el_`generate'_cfplot1.png, replace
		
end

	* apply program to business performance outcomes
rct_regression_empl epml dig_empl, gen(empl)

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
	(`5'1, pstyle(p5)) (`5'2, pstyle(p5)) ///
	(`6'1, pstyle(p6)) (`6'2, pstyle(p6)) ///
	(`7'1, pstyle(p7)) (`7'2, pstyle(p7)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Digital technology adoption index (ITT)"' `1'2 = `"Digital technology adoption index (TOT)"' `2'1 = `"Digital sales index (ITT)"' `2'2 = `"Digital sales index (TOT)"' `3'1 = `"Digital marketing index (ITT)"' ///
		`3'2 = `"Digital marketing index (TOT)"' `4'1 = `"Digital employees (ITT)"' `4'2 = `"Digital employees"' `5'1 = `"Digital revenue, pct (ITT)"' `5'2 = `"Digital revenue, pct (TOT)"' ///
		`6'1 = `"Digital Invest (ITT)"' `6'2 = `"Digital Invest (TOT)"' `7'1 = `"Marketing Invest (ITT)"' `7'2 = `"Marketing Invest"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot, replace)
	
gr export el_`generate'_cfplot.png, replace
			
end


	* apply program to qi outcomes
rct_regression_dta dtai dsi dmi dig_empl dig_revenues_ecom dig_invest mark_invest, gen(dta)

}			

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
	
		* Put all regressions into one table
			* Top panel: ATE
		local regressions `1'1 `2'1 `3'1 `4'1 `5'1 `6'1 // adjust manually to number of variables 
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
		local regressions `1'2 `2'2 `3'2 `4'2 `5'2 `6'2 // adjust manually to number of variables 
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
	(`6'1, pstyle(p6)) (`6'2, pstyle(p6)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Export readiness index (ITT)"' `1'2 = `"Export readiness index (TOT)"' `2'1 = `"Export performance index (ITT)"' `2'2 = `"Export performance index (TOT)"' `3'1 = `"Exports (ITT)"' ///
		`3'2 = `"Exports (TOT)"' `4'1 = `"Export countries (ITT)"' `4'2 = `"Export countries"' `5'1 = `"Clients B2C (ITT)"' `5'2 = `"Clients B2C (TOT)"' ///
		`6'1 = `"Clients B2B (ITT)"' `6'2 = `"Clients B2Bt (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot, replace)
	
gr export el_`generate'_cfplot.png, replace
			
end


	* apply program to qi outcomes
rct_regression_exp eri epi export_1 exp_pays clients_b2c clients_b2b, gen(exp)

}	