***********************************************************************
* 			Master regression 2		  
***********************************************************************
*																	  
*	PURPOSE: 	Undertake treatment effect analysis of primary and secondary
*				outcomes as well as sub-group/heterogeneity analyses																	  
*
*													
*																	  
*	Author:  	Fabian Scheifele							    
*	ID variable: id_plateforme_platforme		  					  
*	Requires:  	ecommerce_master_final.dta
*	Creates:

***********************************************************************
* 	PART 0: 	set the stage - import data	  
***********************************************************************

use "${master_final}/ecommerce_master_final", clear
		
		* change directory
cd "${master_gdrive}/output/ML regressions"

	* xtset data to enable use of lag operator for inclusion of baseline value of Y
xtset id_plateforme surveyround

*add colors
set scheme s1color
***********************************************************************
* 	PART 0.1:  set the stage 	- rename variables for simpler looping	
***********************************************************************
rename ihs_w95_dig_rev20 digital_revenue
rename dig_marketing_index digmark_index
rename dig_presence_weightedz digpres_index

***********************************************************************
* 	PART 1:  set the stage - 	generate YO + missing baseline dummies
***********************************************************************
{
local ys ///
	 digital_revenue digmark_index digpres_index knowledge_index

foreach var of local ys {
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
		eststo `var'1, r: reg `var' i.treatment if surveyround == 2, vce(hc3)
		estadd local bl_control "No"
		estadd local strata "No"

					* ancova without stratification dummies
		eststo `var'2, r: reg `var' i.treatment `var'_y0 i.missing_bl_`var' if surveyround == 2, cluster(id_plateforme)
		estadd local bl_control "Yes"
		estadd local strata "No"

					* ancova plus stratification dummies
		eststo `var'3, r: reg `var' i.treatment `var'_y0 i.missing_bl_`var' i.strata if surveyround == 2, cluster(id_plateforme)
		estadd local bl_control "Yes"
		estadd local strata "Yes"
		estimates store `var'_ate

					* DiD
		eststo `var'4, r: xtreg `var' i.treatment##i.surveyround `var'_y0 i.missing_bl_`var' i.strata, cluster(id_plateforme)
		estadd local bl_control "Yes"
		estadd local strata "Yes"		

					* ATT, IV		
		eststo `var'5, r: ivreg2 `var' `var'_y0 i.missing_bl_`var' i.strata (take_up = i.treatment) if surveyround == 2, cluster(id_plateforme) first
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
* 	PART 3: Midline results - regression table for each variable	
***********************************************************************
{
	* generate regression table for
		* z-scores		
			* indexes
rct_regression_table digpres_index digmark_index knowledge_index

			* revenue
rct_regression_table digital_revenue


}

***********************************************************************
* 	PART 4: Midline results - regression table indexes
***********************************************************************
{
	* rd, rdd, innovator, innovations
capture program drop rct_regression_outcomes // enables re-running
program rct_regression_outcomes
	version 15							// define Stata version 15 used
	syntax varlist(min=1 numeric), GENerate(string)
		foreach var in `varlist' {		// do following for all variables in varlist seperately	
						
			* ITT: ancova plus stratification dummies
			eststo `var'1: reg `var' i.treatment c.`var'_y0 i.missing_bl_`var' i.strata if surveyround ==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"

			* ATT, IV		
			eststo `var'2: ivreg2 `var' c.`var'_y0 i.missing_bl_`var' i.strata (take_up = i.treatment) if surveyround ==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			
			* calculate control group mean
				* take mean over surveyrounds to control for time trend
sum `var' if treatment == 0 & surveyround == 2
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
		}
		
	* change logic from "to same thing to each variable" (loop) to "use all variables at the same time" (program)
		* tokenize to use all variables at the same time
tokenize `varlist'

		* Correct for MHT - FWER
rwolf2 ///
	(reg `1' treatment `1'_y0 i.missing_bl_`1' i.strata if surveyround ==2, cluster(id_plateforme)) ///
	(ivreg2 `1' `1'_y0 i.missing_bl_`1' i.strata (take_up = treatment) if surveyround ==2, cluster(id_plateforme)) ///
	(reg `2' treatment `2'_y0 i.missing_bl_`2' i.strata if surveyround ==2, cluster(id_plateforme)) ///
	(ivreg2 `2' `2'_y0 i.missing_bl_`2' i.strata (take_up = treatment) if surveyround ==2, cluster(id_plateforme)) ///
	(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata if surveyround ==2, cluster(id_plateforme)) ///
	(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata (take_up = treatment) if surveyround ==2, cluster(id_plateforme)) ///
	(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata if surveyround ==2, cluster(id_plateforme)) ///
	(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata (take_up = treatment) if surveyround ==2, cluster(id_plateforme)), ///
	indepvars(treatment, take_up, treatment, take_up, treatment, take_up, treatment, take_up) ///
	seed(110723) reps(30) usevalid strata(strata)	
	
	* save ci(fmt(2)) rw-p-values in a seperate table for manual insertion in latex document
// IS NOT WORKING 
*esttab e(ci(fmt(2)) rw) using rw_`generate'.tex, replace
		
* Put all regressions into one table
			* Top panel: ITT
*		tokenize `varlist'
		local regressions `1'1 `2'1 `3'1 `4'1 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Impact on Outcomes} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
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
		local regressions `1'2 `2'2 `3'2 `4'2 // adjust manually to number of variables 
		esttab `regressions' using "rt_`generate'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) ci(fmt(2)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				label ///
				nobaselevels ///
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{5}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. All outcomes are z-scores calculated following Kling et al. (2007). Coefficients display effects in standard deviation units of the outcome. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %

				*coefplot
coefplot ///
	(`1'1, pstyle(p1)) (`1'2, pstyle(p1)) ///
	(`2'1, pstyle(p2)) (`2'2, pstyle(p2)) ///
	(`3'1, pstyle(p3)) (`3'2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) ///
		eqrename(`1'1 = `"Digital Presence Index (ITT)"' `1'2 = `"Digital Presence Index (TOT)"' `2'1 = `"Digital Marketing Index (ITT)"' `2'2 = `"Digital Marketing Index (TOT)"' `3'1 = `"Digital Knowledge Index (ITT)"' `3'2 = `"Digital Knowledge Index (TOT)"' `4'1 = `"Digital Revenue (ITT)"' `4'2 = `"Digital Revenue (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///  
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'_cfplot, replace)
	
gr export el_`generate'_cfplot.png, replace

				*coefplot
coefplot ///
	(`4'1, pstyle(p4)) (`4'2, pstyle(p4)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) ///
		eqrename(`4'1 = `"Digital Revenue (ITT)"' `4'2 = `"Digital Revenue (TOT)"') ///
		xtitle("Treatment coefficient", size(medium)) ///  
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		name(el_`generate'rev_cfplot, replace)
	
gr export el_`generate'rev_cfplot.png, replace

end

	* apply program to innovation performance outcomes
rct_regression_outcomes digpres_index digmark_index knowledge_index digital_revenue, gen(outcomes)

}

