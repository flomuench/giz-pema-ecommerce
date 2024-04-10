***********************************************************************
*				ecommerce: Heterogeneity Analysis - Endline
***********************************************************************
*																	   
*	PURPOSE: 
* 
*	OUTLINE:
*	0)		Set the stage
*	1)		Sectoral heterogeneity
*	2)		Product/Service heterogeneity
*	3)		B2B/B2C heterogeneity
*	4)		Size Heterogeneity
*																
*	Author: Ayoub Chamakhi 				         													      
*	id_plateforme variable: id_plateforme			  			
*	Requires:				ecommerce_master_final.dta 	   								
*	Creates:				regression tables & coefplots		   					
*
***********************************************************************
* 	PART 0: 	set the stage - import data	  
***********************************************************************

use "${master_final}/ecommerce_master_final", clear
		
		* change directory
cd "${master_gdrive}/output/endline_regressions"

	* xtset data to enable use of lag operator for inclusion of baseline value of Y
xtset id_plateforme surveyround

*enable colors
set scheme s1color

***********************************************************************
* 	PART 0.1:  set the stage 	- rename variables for simpler looping	
***********************************************************************

*RENAME IF NEEDED

***********************************************************************
* 	PART 0.2:  set the stage - 	generate YO + missing baseline dummies
***********************************************************************

{
local ys ///
	 dtai dsi dmi epi dig_revenues_ecom dig_invest comp_ca comp_benefit

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

// need to set sectors.

***********************************************************************
* 	PART 2: Product/Service heterogeneity
***********************************************************************

{
local outcome "dtai"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		xtitle("Digital Technology Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "dsi"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital sales index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		xtitle("Digital Sales Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}


{
local outcome "dmi"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital marketing index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "epi"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export perception index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		xtitle("Export Perception Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "dtp"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology perception index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		xtitle("Digital Technology Perception") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "eri"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export readiness index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		xtitle("Export Readiness Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "bpi"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on business performance index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		xtitle("Business Performance Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "dig_revenues_ecom"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		xtitle("Digital Revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "comp_benefice"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on profit by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		xtitle("Profit") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "comp_ca"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		xtitle("Turnover") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "dig_invest"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital investment by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		xtitle("Digital Investment") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "dig_empl"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital employees by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		xtitle("Digital Employees") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

***********************************************************************
* 	PART 3: B2C vs. B2B Heterogeneity (entreprise_models)
***********************************************************************
{
local outcome "dtai"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
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


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dsi"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
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


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital sales index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Sales Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dmi"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
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


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital marketing index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dtp"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
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


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology perception by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Perception") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "eri"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
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


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export readiness index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Export Readiness Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "bpi"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
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


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on business performance index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Business Performance Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dig_empl"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
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


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export digital employees by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Employees") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dig_revenues_ecom"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
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


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dig_invest"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
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


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital investment by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital investment") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "comp_ca"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
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


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Turnover") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "comp_benefit"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
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


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on prift by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Profit") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

***********************************************************************
* 	PART 3: Size heterogeneity
***********************************************************************

*create bl size variable
gen bl_size = .

replace bl_size = 1 if fte <= 10
replace bl_size = 2 if fte > 10 & fte <= 40
replace bl_size = 3 if fte > 40

{
local outcome "dtai"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace


}

{
local outcome "dsi"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital sales index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Sales Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "dmi"
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
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "epi"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export perception index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Export Perception Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "dtp"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology perception by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Perception") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "eri"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export readiness index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Export Readiness Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "bpi"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on business performance index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Business Performance Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "dig_empl"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital employees by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Employees") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "dig_revenues_ecom"
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
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "dig_invest"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digita investment by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Investment") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "comp_ca"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Turnover") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "comp_benefit"
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
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on profit by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
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
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Profit") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}