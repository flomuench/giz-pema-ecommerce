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
*																 														
*
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_final.dta & regis_corrected_matches 
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data + save it in samp_final folder
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
_eststo registration_c1, r: logit registered i.treatment if not_delivered == 0, vce(robust)
*outreg2 using ecommerce_main, excel replace ctitle(logit)
_eststo registration_m1, r: margins i.treatment, post
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)

		*(c2) interaction with gender
_eststo registration_c2, r: logit registered i.treatment##i.gender if not_delivered == 0, vce(robust)
*outreg2 using ecommerce_main, excel append ctitle(logit)
_eststo registration_m2, r: margins i.treatment##i.gender, post
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)

coefplot registration_m2, drop(_cons) ///
	xtitle("Predicted probability of registration", size(small)) xlab(0.01(0.01)0.20) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	name(ecommerce_main_coefplot, replace)
gr export ecommerce_main_coefplot.png, replace

		* c(3)alternative, CEO corrected gender definition
rename gender gender3
rename gender_pdg_corrected gender
_eststo registration_c3, r: logit registered i.treatment##i.gender if not_delivered == 0, vce(robust)
*outreg2 using ecommerce_main, excel append ctitle(logit)
_eststo registration_m3, r: margins i.treatment##i.gender, post
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)
rename gender gender_pdg_corrected

		* c(4)alternative, CEO + Rep corrected gender definition
rename gender_rep_corrected gender
_eststo registration_c4, r: logit registered i.treatment##i.gender if not_delivered == 0, vce(robust)
*outreg2 using ecommerce_main, excel append ctitle(logit)
_eststo registration_m4, r: margins i.treatment##i.gender, post
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)
rename gender gender_rep_corrected
rename gender3 gender

		* (c5) adding strata
_eststo registration_c5, r: logit registered i.treatment i.strata2 if not_delivered == 0, vce(robust)
*outreg2 using ecommerce_main, excel append ctitle(logit)
_eststo registration_m5, r: margins i.treatment, post /* strata to small to measure interaction effect */
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)

		* exclude firms from GIZ sample?

	* create a Latex table
local regressions registration_c1 registration_m1 registration_c2 registration_m2 registration_c3 registration_m3 registration_c4 registration_m4 registration_c5 registration_m5
esttab `regressions' using registration.tex, replace ///
	mtitles("beta" "pp" "beta" "pp" "beta" "pp" "beta" "pp" "beta" "pp") ///
	label ///
	b(2) ///
	se(2) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	drop(*.strata2) ///
	scalars("Strata controls") ///
	nobaselevels ///
	addnotes("All models are estimated in Stata 15 SE using logistic regressions." "PP stands for predicted probability." "In column (3), algorithm based firms' gender assignment has been corrected manually based on the name of the person who registered the company and (s)he being the CEO." "In column (4), the same correction as in column(3) but gender is now defined as that of the person who registered the company even if that person was not the CEO." "When strata controls are included, we do not include an interaction term with gender given strata are based on gender." "The sample is reduced to 3894 as we exclude 953 firms with malfunctioning email addresses." )
	


***********************************************************************
* 	PART 1b: main effect on registration using OLS model
***********************************************************************

		*(c1) simple treatment dummy
_eststo registration_ols_c1, r: regress registered i.treatment, vce(robust)

		*(c2) interaction with gender
_eststo registration_ols_c2, r: regress registered i.treatment##i.gender, vce(robust)

rename gender gender3
rename gender_pdg_corrected gender
		* (c3) gender corrected ceo
_eststo registration_ols_c3, r: regress registered i.treatment##i.gender, vce(robust)
rename gender gender_pdg_corrected

		* (c4) gender corrected rep
rename gender_rep_corrected gender
_eststo registration_ols_c4, r: regress registered i.treatment##i.gender, vce(robust)
rename gender gender_rep_corrected
rename gender3 gender
			
		* (c5) adding strata
_eststo registration_ols_c5, r: regress registered i.treatment i.strata2, vce(robust)

		* create latex table
local regressions registration_ols_c1 registration_ols_c2 registration_ols_c3 registration_ols_c4 registration_ols_c5
esttab `regressions' using registration_ols.tex, replace ///
	mtitles("Treatment dummy" "Gender interaction" "CEO gender corrected" "Rep. gender corrected" "Strata controls") ///
	label ///
	b(2) ///
	se(2) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	drop(*.strata2) ///
	scalars("Strata controls") ///
	nobaselevels ///
	addnotes("All models are estimated in Stata 15 SE using OLS regressions." "In column (3), algorithm based firms' gender assignment has been corrected manually based on the name of the person who registered the company and (s)he being the CEO." "In column (4), the same correction as in column(3) but gender is now defined as that of the person who registered the company even if that person was not the CEO." "When strata controls are included, we do not include an interaction term with gender given strata are based on gender." "The sample is reduced to 3894 as we exclude 953 firms with malfunctioning email addresses." )
	

***********************************************************************
* 	PART 1c: bundled treatment vs. control
***********************************************************************
gen treated = .
replace treated = 1 if treatment == 1 | treatment == 2
replace treated = 0 if treatment == 0
lab def treat2 1 "treated" 0 "control"
lab val treated treat2

		*(c1) treatment dummy
_eststo registration_bundled_c1, r: logit registered i.treated if not_delivered == 0, vce(robust)
_eststo registration_bundled_m1, r: margins i.treated, post

		*(c2) interaction with gender
_eststo registration_bundled_c2, r: logit registered i.treated##i.gender if not_delivered == 0, vce(robust)
_eststo registration_bundled_m2, r: margins i.treated##i.gender, post

		* c(3)alternative, CEO corrected gender definition
rename gender gender3
rename gender_pdg_corrected gender
_eststo registration_bundled_c3, r: logit registered i.treated##i.gender if not_delivered == 0, vce(robust)
_eststo registration_bundled_m3, r: margins i.treated##i.gender, post
rename gender gender_pdg_corrected

		* c(4)alternative, CEO + Rep corrected gender definition
rename gender_rep_corrected gender
_eststo registration_bundled_c4, r: logit registered i.treated##i.gender if not_delivered == 0, vce(robust)
_eststo registration_bundled_m4, r: margins i.treated##i.gender, post
rename gender gender_rep_corrected
rename gender3 gender

		* (c5) adding strata
_eststo registration_bundled_c5, r: logit registered i.treated i.strata2 if not_delivered == 0, vce(robust)
_eststo registration_bundled_m5, r: margins i.treated, post /* strata to small to measure interaction effect */

	* create a Latex table
local regressions registration_bundled_c1 registration_bundled_m1 registration_bundled_c2 registration_bundled_m2 registration_bundled_c3 registration_bundled_m3 registration_bundled_c4 registration_bundled_m4 registration_bundled_c5 registration_bundled_m5
esttab `regressions' using registration_bundled.tex, replace ///
	mtitles("beta" "pp" "beta" "pp" "beta" "pp" "beta" "pp" "beta" "pp") ///
	label ///
	b(2) ///
	se(2) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	drop(*.strata2) ///
	scalars("Strata controls") ///
	nobaselevels ///
	addnotes("All models are estimated in Stata 15 SE using logistic regressions." "PP stands for predicted probability." "In column (3), algorithm based firms' gender assignment has been corrected manually based on the name of the person who registered the company and (s)he being the CEO." "In column (4), the same correction as in column(3) but gender is now defined as that of the person who registered the company even if that person was not the CEO." "When strata controls are included, we do not include an interaction term with gender given strata are based on gender." "The sample is reduced to 3894 as we exclude 953 firms with malfunctioning email addresses." )
	

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
		*(c1) simple treatment dummy
_eststo eligible_c1, r: logit eligible i.treatment if not_delivered != 1, vce(robust)
*outreg2 using ecommerce_main, excel replace ctitle(logit)
_eststo eligible_m1, r: margins i.treatment, post
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)

		*(c2) interaction with gender
_eststo eligible_c2, r: logit eligible i.treatment##i.gender if not_delivered != 1, vce(robust)
*outreg2 using ecommerce_main, excel append ctitle(logit)
_eststo eligible_m2, r: margins i.treatment##i.gender, post
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)

		* c(3)alternative, CEO corrected gender definition
rename gender gender3
rename gender_pdg_corrected gender
_eststo eligible_c3, r: logit eligible i.treatment##i.gender if not_delivered != 1, vce(robust)
*outreg2 using ecommerce_main, excel append ctitle(logit)
_eststo eligible_m3, r: margins i.treatment##i.gender, post
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)
rename gender gender_pdg_corrected

		* c(4)alternative, CEO + Rep corrected gender definition
rename gender_rep_corrected gender
_eststo eligible_c4, r: logit eligible i.treatment##i.gender if not_delivered != 1, vce(robust)
*outreg2 using ecommerce_main, excel append ctitle(logit)
_eststo eligible_m4, r: margins i.treatment##i.gender, post
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)
rename gender gender_rep_corrected
rename gender3 gender

		* (c5) adding strata
_eststo eligible_c5, r: logit eligible i.treatment i.strata2 if not_delivered != 1, vce(robust)
*outreg2 using ecommerce_main, excel append ctitle(logit)
_eststo eligible_m5, r: margins i.treatment, post /* strata to small to measure interaction effect */
*outreg2 using ecommerce_main, excel append ctitle(predicted probability)


	* create a Latex table
local regressions eligible_c1 eligible_m1 eligible_c2 eligible_m2 eligible_c3 eligible_m3 eligible_c4 eligible_m4 eligible_c5 eligible_m5
esttab `regressions' using eligible.tex, replace ///
	mtitles("beta" "pp" "beta" "pp" "beta" "pp" "beta" "pp" "beta" "pp") ///
	label ///
	b(2) ///
	se(2) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	drop(*.strata2) ///
	scalars("Strata controls") ///
	nobaselevels ///
	addnotes("All models are estimated in Stata 15 SE using logistic regressions." "PP stands for predicted probability." "In column (3), algorithm based firms' gender assignment has been corrected manually based on the name of the person who registered the company and (s)he being the CEO." "In column (4), the same correction as in column(3) but gender is now defined as that of the person who registered the company even if that person was not the CEO." "When strata controls are included, we do not include an interaction term with gender given strata are based on gender." "The sample is reduced to 3894 as we exclude 953 firms with malfunctioning email addresses." )


***********************************************************************
* 	PART 3: make nice three panel tabel
***********************************************************************
	// top panel --> main effects registration
esttab  registration_c1 registration_m1 registration_c2 registration_m2 registration_c3 ///
		registration_m3 registration_c4 registration_m4 registration_c5 registration_m5 using two_panel.tex, replace  ///
		nobaselevels ///
		prehead("\begin{table}[h!]\centering \\  \def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \\ \caption{Effect of particiation incentives on registration and eligibility} \\ \begin{tabular}{l*{10}{c}} \hline\hline") ///
		posthead("\hline \\ \multicolumn{10}{c}{\textbf{Panel A: Registration}} \\\\[-1ex]") ///
		fragment ///
		drop(*.strata2) ///
		scalars("Strata controls") ///
		mgroups("Treatment dummy" "Gender interaction" "CEO gender corrected" "Rep. gender" "Strata", ///
		pattern(1 0 1 0 1 0 1 0 1 0)) ///
		mtitles("beta" "pp" "beta" "pp" "beta" "pp" "beta" "pp" "beta" "pp") ///
		label /// 
		star(* 0.1 ** 0.05 *** 0.01) ///
		b(2) se(2) 
	
		
//bottom panel 
esttab eligible_c1 eligible_m1 eligible_c2 eligible_m2 eligible_c3 ///
		eligible_m3 eligible_c4 eligible_m4 eligible_c5 eligible_m5 using two_panel.tex, append ///
		nobaselevels ///
		posthead("\hline \\ \multicolumn{10}{c}{\textbf{Panel B: Eligibility}} \\\\[-1ex]") ///
		fragment ///
		label ///
		drop(*.strata2) ///
		scalars("Strata controls") ///
		star(* 0.1 ** 0.05 *** 0.01) ///
		b(2) se(2) nomtitles nonumbers  ///
		prefoot("\hline") ///
		postfoot("\multicolumn{10}{l}{\footnotesize All models are estimated in Stata 15 SE using logistic regressions. }\\\multicolumn{10}{l}{\footnotesize PP stands for predicted probability.}\\\multicolumn{10}{l}{\footnotesize In column (3), algorithm based firms' gender assignment has been corrected manually based on the name of the person who registered the company and (s)he being the CEO. }\\\multicolumn{10}{l}{\footnotesize In column (4), the same correction as in column(3) but gender is now defined as that of the person who registered the company even if that person was not the CEO.}\\\multicolumn{10}{l}{\footnotesize When strata controls are included, we do not include an interaction term with gender given strata are based on gender.}\\\multicolumn{10}{l}{\footnotesize The sample is reduced to 3894 as we exclude 953 firms with malfunctioning email addresses.}\\\multicolumn{10}{l}{\footnotesize \sym{**} \(p<0.05\), \sym{*} \(p<0.1\)}\\ \end{tabular} \\ \end{table}")

	


	