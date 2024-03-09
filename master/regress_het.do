***********************************************************************
*				ecommerce: Heterogeneity Analysis - joint table
***********************************************************************
*																	   
*	PURPOSE: 
* 
*	OUTLINE:
*	1)		Set the stage
*		1.1) technicalities
*		1.2) rename variables for simpler looping	
*		1.3) generate export & business performance z-scores
*		1.4) generate YO + missing baseline dummies
*	2)		IQ outcomes
*	3)		Export outcomes
*	4)		Business Performance outcomes
*	5)		Innovation outcomes
*																
*	Author:  				         													      
*	id_plateforme variable: 	id_plateforme (example: f101)			  			
*	Requires: aqe_database_final.dta 	   								
*	Creates:  aqe_database_final.dta			   					
*
***********************************************************************
* 	PART 0: 	set the stage - import data	  
***********************************************************************

use "${master_final}/ecommerce_master_final", clear
		
		* change directory
cd "${master_gdrive}/output/ML regressions"

	* xtset data to enable use of lag operator for inclusion of baseline value of Y
xtset id_plateforme surveyround

*enable colors
set scheme s1color
***********************************************************************
* 	PART 0.1:  set the stage 	- rename variables for simpler looping	
***********************************************************************
rename ihs_w95_dig_rev20 digital_revenue
rename dig_marketing_index digmark_index
rename dig_presence_weightedz digpres_index

***********************************************************************
* 	PART 0.2:  set the stage - 	generate YO + missing baseline dummies
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
* 	PART 1: Sectoral heterogeneity
***********************************************************************
//DIGITAL REVENUE NOT SIGNIFICANT AT 90TH
//DIGITAL KNOWLEDGE INDEX SIGNIFICANT AT 95TH FOR PROD(ITT & TOT) SERVICE(T0T)
//DIGITAL MARKETING INDEX NO SIGNIFICANCE AT 90TH
//DIGITAL PRESENCE INDEX NO SIGNIFICANCE AT 90TH
//PRODUCT VS SERVICE (INTERNATIONAL COMMERCE WILL BE DISPALYED AS PRODUCT SINCE MOSTLY PRODUCTS SOLD)

//DIGITAL PRESENCE INDEX NO SIGNIFICANCE AT 90TH
{
local outcome "digpres_index"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital presence index by sector} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Presence Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}


//DIGITAL MARKETING INDEX NO SIGNIFICANCE AT 90TH
{
local outcome "digmark_index"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital marketing index by sector} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

//DIGITAL KNOWLEDGE INDEX SIGNIFICANT AT 95TH FOR PROD(ITT & TOT) SERVICE(T0T)
{
local outcome "knowledge_index"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital knowledge index by sector} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Knowledge Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

//DIGITAL REVENUE NOT SIGNIFICANT AT 90TH
{
local outcome "digital_revenue"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by sector} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

// DIGITAL REVENUE POSITIVE FOR TRADITIONAL TOT AT 95TH, SAME 90TH
//DIGITAL KNOWLEDGE INDEX POSITIVE FOR ALL AT 90TH
// DIGITAL MARKETING INDEX SIGNIFICANCE AT 90TH FOR TRADITIONAL TOT & IOT, 95TH ONLY TOT
// NEGATIVE SIGNIFICANCE AT 90TH FOR MODERN IOT & TOT, 95TH TOT ONLY.

// MODERN VS TRADITIONAL BUSINESS
* Create a new variable to store the industry group
gen industry_group = .

* Assign industries to groups
replace industry_group = 1 if inlist(subsector, 2, 5, 7, 8, 9, 11, 12, 13, 14, 15, 16, 20, 21)
replace industry_group = 2 if inlist(subsector, 1, 3, 4, 6, 10, 17, 18, 19)

// NEGATIVE SIGNIFICANCE AT 90TH FOR MODERN IOT & TOT, 95TH TOT ONLY.
{
local outcome "digpres_index"
local conditions "industry_group==1 industry_group==2"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector2_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital presence index by sector} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Modern" "Traditional", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector2_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Modern" "Traditional", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Modern (ITT)"' `outcome'_p2 = `"Modern (TOT)"' `outcome'_s1 = `"Traditional (ITT)"' `outcome'_s2 = `"Traditional (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Presence Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector2_`outcome', replace)
gr export el_het_sector2_`outcome'.png, replace

}

// DIGITAL MARKETING INDEX SIGNIFICANCE AT 90TH FOR TRADITIONAL TOT & IOT, 95TH ONLY TOT
{
local outcome "digmark_index"
local conditions "industry_group==1 industry_group==2"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector2_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital marketing index by sector} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Modern" "Traditional", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector2_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Modern" "Traditional", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Modern (ITT)"' `outcome'_p2 = `"Modern (TOT)"' `outcome'_s1 = `"Traditional (ITT)"' `outcome'_s2 = `"Traditional (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector2_`outcome', replace)
gr export el_het_sector2_`outcome'.png, replace

}

//DIGITAL KNOWLEDGE INDEX POSITIVE FOR ALL AT 90TH
{
local outcome "knowledge_index"
local conditions "industry_group==1 industry_group==2"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector2_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital knowledge index by sector} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Modern" "Traditional", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector2_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Modern" "Traditional", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Modern (ITT)"' `outcome'_p2 = `"Modern (TOT)"' `outcome'_s1 = `"Traditional (ITT)"' `outcome'_s2 = `"Traditional (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Knowledge Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector2_`outcome', replace)
gr export el_het_sector2_`outcome'.png, replace

}

// DIGITAL REVENUE POSITIVE FOR TRADITIONAL TOT AT 95TH, SAME 90TH
{
local outcome "digital_revenue"
local conditions "industry_group==1 industry_group==2"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector2_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by sector} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Modern" "Traditional", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector2_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Modern" "Traditional", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Modern (ITT)"' `outcome'_p2 = `"Modern (TOT)"' `outcome'_s1 = `"Traditional (ITT)"' `outcome'_s2 = `"Traditional (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector2_`outcome', replace)
gr export el_het_sector2_`outcome'.png, replace

}
***********************************************************************
* 	PART 2: Size heterogeneity
***********************************************************************
// MEDIUM TOT SIGNIFICANT AT 90TH FOR DIGITAL REVENUE
// KNOWLEDGE INDEX LARGE TOT & ITT SIGNIFICANT POSITIVE AT 90TH, 95TH TOT ONLY
// DIGITAL MARKETING INDEX SIGNIFICANT AT 90TH FOR LARGE TOT + AND NEGATIVE FOR SMALL TOT
//DIGITAL PRESENCE INDEX NO SIGNIFICANCE


*create bl size variable
gen bl_size = .

replace bl_size = 1 if fte <= 10
replace bl_size = 2 if fte > 10 & fte <= 40
replace bl_size = 3 if fte > 40

//DIGITAL PRESENCE INDEX NO SIGNIFICANCE
{
local outcome "digpres_index"
local conditions "bl_size==1 bl_size==2  bl_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital presence index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Presence Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace


}

// DIGITAL MARKETING INDEX SIGNIFICANT AT 90TH FOR LARGE TOT + AND NEGATIVE FOR SMALL TOT

{
local outcome "digmark_index"
local conditions "bl_size==1 bl_size==2 bl_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital marketing index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

// KNOWLEDGE INDEX LARGE TOT & ITT SIGNIFICANT POSITIVE AT 90TH, 95TH TOT ONLY
{
local outcome "knowledge_index"
local conditions "bl_size==1 bl_size==2 bl_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on knowledge index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Knowledge Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

// MEDIUM TOT SIGNIFICANT AT 90TH FOR DIGITAL REVENUE
{
local outcome "digital_revenue"
local conditions "bl_size==1 bl_size==2 bl_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}


***********************************************************************
* 	PART 3: B2C vs. B2B Heterogeneity (entreprise_models)
***********************************************************************
*take entreprise_model value of baseline to midline via id
bysort id_plateforme: egen entreprise_model = max(entreprise_models)

// DIGITAL PRESENCE INDEX: B2B OR B2C (IOT & TOT) NEGATIVELY SIGNIFICANT
// DIGITAL REVENUE: B2B AND B2C (TOT) POSITIVELY SIGNIFICANT at 90TH
// KNOWLEDGE INDEX: B2B AND B2C (ITT & TOT) POSITIVELY SIGNIFICANT
// DIGITAL MARKETING INDEX: NO SIGNIFICANCE

{
local outcome "digpres_index"
local conditions "entreprise_model==1 entreprise_model==2"
local groups "o b"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital presence index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C or B2B" "B2C and B2B" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_o1, pstyle(p1)) (`outcome'_o2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2B or B2C (ITT)"' `outcome'_o2 = `"B2B or B2C (TOT)"' `outcome'_b1 = `"B2B and B2C (ITT)"' `outcome'_b2 = `"B2B and B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Presence Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

// DIGITAL MARKETING INDEX: NO SIGNIFICANCE

{
local outcome "digmark_index"
local conditions "entreprise_model==1 entreprise_model==2"
local groups "o b"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital marketing index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C or B2B" "B2C and B2B" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_o1, pstyle(p1)) (`outcome'_o2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2B or B2C (ITT)"' `outcome'_o2 = `"B2B or B2C (TOT)"' `outcome'_b1 = `"B2B and B2C (ITT)"' `outcome'_b2 = `"B2B and B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace
}

// KNOWLEDGE INDEX: B2B AND B2C (ITT & TOT) POSITIVELY SIGNIFICANT

{
local outcome "knowledge_index"
local conditions "entreprise_model==1 entreprise_model==2"
local groups "o b"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on knowledge index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C or B2B" "B2C and B2B" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_o1, pstyle(p1)) (`outcome'_o2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2B or B2C (ITT)"' `outcome'_o2 = `"B2B or B2C (TOT)"' `outcome'_b1 = `"B2B and B2C (ITT)"' `outcome'_b2 = `"B2B and B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Knowledge Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

// DIGITAL REVENUE: B2B AND B2C (TOT) POSITIVELY SIGNIFICANT at 90TH

{
local outcome "digital_revenue"
local conditions "entreprise_model==1 entreprise_model==2"
local groups "o b"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C or B2B" "B2C and B2B" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_o1, pstyle(p1)) (`outcome'_o2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2B or B2C (ITT)"' `outcome'_o2 = `"B2B or B2C (TOT)"' `outcome'_b1 = `"B2B and B2C (ITT)"' `outcome'_b2 = `"B2B and B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

***********************************************************************
* 	PART 4: ONLINE VS NOT ONLINE Heterogeneity (entreprise_models)
***********************************************************************

// DIGITAL PRESENCE INDEX: NOT SIGNIFICANT
// DIGITAL REVENUE: Error: estimated variance-covariance matrix has missing values
// KNOWLEDGE INDEX: OFFLINE (ITT TOT) SIGNIFICANT AT 90TH
// DIGITAL MARKETING INDEX: NO SIGNIFICANCE
{
local outcome "digpres_index"
local conditions "dig_vente==1 dig_vente==0"
local groups "o b"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2 
esttab `regressions' using "rt_hetero_method_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital presence index by method of sale} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Online" "Offline" , ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2
		esttab `regressions' using "rt_hetero_method_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Online" "Offline", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_o1, pstyle(p1)) (`outcome'_o2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"Online (ITT)"' `outcome'_o2 = `"Online (TOT)"' `outcome'_b1 = `"Offline (ITT)"' `outcome'_b2 = `"Offline (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Presence Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_method_`outcome', replace)
gr export el_het_method_`outcome'.png, replace

}

// DIGITAL MARKETING INDEX: NO SIGNIFICANCE

{
local outcome "digmark_index"
local conditions "dig_vente==1 dig_vente==0"
local groups "o b"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2 
esttab `regressions' using "rt_hetero_method_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital marketing index by method of sale} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Online" "Offline" , ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2
		esttab `regressions' using "rt_hetero_method_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Online" "Offline", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_o1, pstyle(p1)) (`outcome'_o2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"Online (ITT)"' `outcome'_o2 = `"Online (TOT)"' `outcome'_b1 = `"Offline (ITT)"' `outcome'_b2 = `"Offline (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Markketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_method_`outcome', replace)
gr export el_het_method_`outcome'.png, replace

}

// KNOWLEDGE INDEX: OFFLINE (ITT TOT) SIGNIFICANT AT 90TH

{
local outcome "knowledge_index"
local conditions "dig_vente==1 dig_vente==0"
local groups "o b"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2 
esttab `regressions' using "rt_hetero_method_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on knowledge index by method of sale} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Online" "Offline" , ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2
		esttab `regressions' using "rt_hetero_method_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Online" "Offline", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_o1, pstyle(p1)) (`outcome'_o2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"Online (ITT)"' `outcome'_o2 = `"Online (TOT)"' `outcome'_b1 = `"Offline (ITT)"' `outcome'_b2 = `"Offline (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Knowledge Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_method_`outcome', replace)
gr export el_het_method_`outcome'.png, replace

}

/* DIGITAL REVENUE: Error: estimated variance-covariance matrix has missing values

{
local outcome "digital_revenue"
local conditions "dig_vente==1 dig_vente==0"
local groups "o b"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2 
esttab `regressions' using "rt_hetero_method_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by method of sale} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Online" "Offline" , ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2
		esttab `regressions' using "rt_hetero_method_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Online" "Offline", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_o1, pstyle(p1)) (`outcome'_o2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"Online (ITT)"' `outcome'_o2 = `"Online (TOT)"' `outcome'_b1 = `"Offline (ITT)"' `outcome'_b2 = `"Offline (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_method_`outcome', replace)
gr export el_het_method_`outcome'.png, replace
*/

***********************************************************************
* 	PART 5: digital marketing index below vs. above median Heterogeneity
***********************************************************************
// DIGITAL REVENUE NOT SIGNIFICANT
// KNOWLEDGE INDEX: BELOW MEDIAN (TOT & ITT) SIGNIFICANT AT 95TH
// DIGITAL PRESENCE INDEX: NOT SIGNIFICANT

/*
. sum digmark_index if surveyround==2, d



                      QI index z-score
-------------------------------------------------------------
      Percentiles      Smallest
 1%    -.9588875      -1.508786
 5%    -.6712579      -.9588875
10%    -.5162084      -.9405131       Obs                 193
25%    -.2413971      -.9250528       Sum of wgt.         193

50%     .0181997                      Mean           .0033928
                        Largest       Std. dev.      .3951199
75%     .2642947       .7523296
90%     .4945419        .869967       Variance       .1561197
95%     .6273503        .893679       Skewness       -.365657
99%      .893679       .9598359       Kurtosis       3.573998

*/

// DIGITAL PRESENCE INDEX: NOT SIGNIFICANT

{
local outcome "digpres_index"
local conditions "digmark_index<=0.0181997 digmark_index>=0.0181997"
local groups "o b"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2 
esttab `regressions' using "rt_hetero_median_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital presence index by digital marketing index pct} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Below Median" "Above Median" , ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2
		esttab `regressions' using "rt_hetero_median_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Below Median" "Above Median", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_o1, pstyle(p1)) (`outcome'_o2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"Below Median (ITT)"' `outcome'_o2 = `"Below Median (TOT)"' `outcome'_b1 = `"Above Median (ITT)"' `outcome'_b2 = `"Above Median (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Presence Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_method_`outcome', replace)
gr export el_het_method_`outcome'.png, replace

}

// DIG MARKETING INDEX NEGATIVELY SIGNIFICANT WITH ABOVE MEDIAN TOT ITT 90TH
{
local outcome "digmark_index"
local conditions "digmark_index<=0.0181997 digmark_index>=0.0181997"
local groups "o b"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2 
esttab `regressions' using "rt_hetero_median_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital presence index by digital marketing index pct} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Below Median" "Above Median" , ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2
		esttab `regressions' using "rt_hetero_median_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Below Median" "Above Median", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_o1, pstyle(p1)) (`outcome'_o2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"Below Median (ITT)"' `outcome'_o2 = `"Below Median (TOT)"' `outcome'_b1 = `"Above Median (ITT)"' `outcome'_b2 = `"Above Median (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_method_`outcome', replace)
gr export el_het_method_`outcome'.png, replace

}

// KNOWLEDGE INDEX: BELOW MEDIAN (TOT & ITT) SIGNIFICANT AT 95TH

{
local outcome "knowledge_index"
local conditions "digmark_index<=0.0181997 digmark_index>=0.0181997"
local groups "o b"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2 
esttab `regressions' using "rt_hetero_median_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on knowledge index by digital marketing index pct} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Below Median" "Above Median" , ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2
		esttab `regressions' using "rt_hetero_median_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Below Median" "Above Median", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_o1, pstyle(p1)) (`outcome'_o2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"Below Median (ITT)"' `outcome'_o2 = `"Below Median (TOT)"' `outcome'_b1 = `"Above Median (ITT)"' `outcome'_b2 = `"Above Median (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Knowledge Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_method_`outcome', replace)
gr export el_het_method_`outcome'.png, replace

}

// DIGITAL REVENUE NOT SIGNIFICANT

{
local outcome "digital_revenue"
local conditions "digmark_index<=0.0181997 digmark_index>=0.01819970"
local groups "o b"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==2, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==2, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 2 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2 
esttab `regressions' using "rt_hetero_median_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by digital marketing index pct} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Below Median" "Above Median" , ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_o1 `outcome'_o2 `outcome'_b1 `outcome'_b2
		esttab `regressions' using "rt_hetero_median_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{5}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Below Median" "Above Median", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_o1, pstyle(p1)) (`outcome'_o2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(90) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"Below Median (ITT)"' `outcome'_o2 = `"Below Median (TOT)"' `outcome'_b1 = `"Above Median (ITT)"' `outcome'_b2 = `"Above Median (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 90th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_method_`outcome', replace)
gr export el_het_method_`outcome'.png, replace



}
