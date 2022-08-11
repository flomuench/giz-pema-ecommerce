***********************************************************************
* 			email experiment - regressions - main effect								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)	 import corrected matches and save as dta in sampling folder													  
*	2)	 merge with initial population based on id_email
*	3)	 merge with registration data to get controls for registered firms
*	4) 	 save as email_experiment.dta in final folder
*																 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_final.dta & regis_corrected_matches 
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data + save it in samp_final folder				  										  *
***********************************************************************
use "${samp_final}/email_experiment", clear

	* set folder path for export
cd "$samp_regressions"

***********************************************************************
* 	PART 1: registration
***********************************************************************
***********************************************************************
* 	PART 1a: main effect on registration using logit model
***********************************************************************
cd "$final_tables"
	* assignment based on baseline or registration data and if not available API data
		*(c1) simple treatment dummy
_eststo registration_c1, r: logit registered i.treatment, vce(robust)
*outreg2 using ecommerce_main, excel replace ctitle(logit)
_eststo registration_m1, r: margins i.treatment, post
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)

		*(c2) interaction with gender
_eststo registration_c2, r: logit registered i.treatment##i.gender, vce(robust)
*outreg2 using ecommerce_main, excel append ctitle(logit)
_eststo registration_m2, r: margins i.treatment##i.gender, post
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)

coefplot registration_m2, drop(_cons) ///
	xtitle("Predicted probability of registration", size(small)) xlab(0.01(0.01)0.20) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	name(ecommerce_main_coefplot, replace)
gr export ecommerce_main_coefplot.png, replace

		* c(3)alternative, corrected gender definition
_eststo registration_c2, r: logit registered i.treatment##i.gender_pdg_corrected, vce(robust)
*outreg2 using ecommerce_main, excel append ctitle(logit)
_eststo registration_m2, r: margins i.treatment##i.gender, post
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)

		* (c4) adding strata
_eststo registration_c3, r: logit registered i.treatment i.strata2, vce(robust)
*outreg2 using ecommerce_main, excel append ctitle(logit)
_eststo registration_m3, r: margins i.treatment, post /* strata to small to measure interaction effect */
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)

		* exclude firms from GIZ sample?

	* create a Latex table
local regressions registration_c1 registration_m1 registration_c2 registration_m2 registration_c3 registration_m3 registration_c4 registration_m4
esttab `regressions' using registration.tex, replace ///
	mtitles("beta" "pp" "beta" "pp" "beta" "pp" "beta" "pp") ///
	label ///
	b(2) ///
	se(2) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	drop(*.strata2) ///
	scalars("Strata controls") ///
	nobaselevels ///
	addnotes("All models are estimated in Stata 15 SE using logistic regressions." "PP stands for predicted probability." "When strata controls are included, we do not include an interaction term with gender given strata are based on gender.")
	


***********************************************************************
* 	PART 1b: main effect on registration using OLS model
***********************************************************************
		*(c1) simple treatment dummy
_eststo registration_c1, r: regress registered i.treatment, vce(robust)

		*(c2) interaction with gender
_eststo registration_c2, r: regress registered i.treatment##i.gender, vce(robust)

		* (c3) adding strata
_eststo registration_c3, r: regress registered i.treatment i.strata2, vce(robust)


***********************************************************************
* 	PART 1c: bundled treatment vs. control
***********************************************************************
gen treated = .
replace treated = 1 if treatment == 1 | treatment == 2
replace treated = 0 if treatment == 0
lab def treat2 1 "treated" 0 "control"
lab var treated treat2

logit registered i.treated, vce(robust)
outreg2 using bundled, excel replace ctitle(logit)
margins i.treated, post
outreg2 using bundled, excel append ctitle(predicted probability)
logit registered i.treated##i.gender_rep2, vce(robust)
outreg2 using bundled, excel append ctitle(logit)
margins i.treated##i.gender_rep2, post
outreg2 using bundled, excel append ctitle(predicted probability)
logit registered i.treated##i.gender_rep2 i.strata2 , vce(robust)
outreg2 using bundled, excel append ctitle(logit)
margins i.treated##i.gender_rep2, post
outreg2 using bundled, excel append ctitle(predicted probability)

***********************************************************************
* 	PART : test whether effect differs between female and male firms
***********************************************************************
logit registered i.treatment##i.gender , vce(robust)
	* contrast effect of each treatment for female vs. male: 5% level
margins i.treatment##r.gender, contrast
	* contrast effect of each treatment for female vs. male: 10% level
margins i.treatment##r.gender, contrast level(90)


margins i.treatment##i.gender, post
test _b[1.treatment#1.gender] = _b[1.treatment#0.gender]
/* one can reject the hypothesis that coefficents female#treat vs. male#trat are not different;
CI overlap slightly 2.6-4.57% for male free childcare vs. 4.31-10.88% for female represented firms */



***********************************************************************
* 	PART 2: eligibility
***********************************************************************



***********************************************************************
* 	PART 3: make nice three panel tabel
***********************************************************************
	// top panel --> main effects registration
esttab  registration_c1 registration_m1 registration_c2 registration_m2 registration_c3 ///
		registration_m3 registration_c4 registration_m4 using three_panel.tex, replace  ///
		nobaselevels ///
		prehead("\begin{table}[htbp]\centering \\  \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \\ \caption{Results of Matching combined with Difference in Differences} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
		posthead("\hline \\ \multicolumn{8}{c}{\textbf{Panel A: Solar PV Patents}} \\\\[-1ex]") ///
		fragment ///
		mgroups("" "All firms" "Winner firms" "All w/o outliers", ///
		pattern(1 0 1 0 1 0 1 0)) ///
		mtitles("Simple post difference" "DiD" "caliper = 0.1" "caliper = 0.05" "caliper = 0.1" "caliper = 0.05" "caliper = 0.1" "caliper = 0.05") ///
		label /// 
		star(* 0.1 ** 0.05 *** 0.01) ///
		b(2) se(2) 
	
		
	// second middle panel --> main effects eligibility 
esttab  post_cell did_cell all_caliper01_cell all_caliper05_cell won_caliper01_cell won_caliper05_cell outliers_caliper01_cell ///
	outliers_caliper05_cell using three_panel.tex, ///
    nobaselevels ///
	posthead("\hline \\ \multicolumn{8}{c}{\textbf{Panel B: PV Module \& PV Cell Patents only}} \\\\[-1ex]") ///
	fragment ///
	append ///
	label ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	b(2) se(2) nomtitles nonumbers 		


	