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
* 	PART 1: main effect
***********************************************************************
logit registered i.treatment , vce(robust)
outreg2 using main_effect, excel replace ctitle(logit)
margins i.treatment, post
outreg2 using main_effect, excel append ctitle(predicted probability)
logit registered i.treatment##i.gender , vce(robust)
outreg2 using main_effect, excel append ctitle(logit)
margins i.treatment##i.gender, post
outreg2 using main_effect, excel append ctitle(predicted probability)
estimates store main_effect, title("Main effect")
coefplot main_effect, drop(_cons) ///
	xtitle("Predicted probability of registration", size(small)) xlab(0.01(0.01)0.1) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	title("{bf:How to attract (female) firms to an export support program?}") ///
	subtitle("Full sample", size(small)) ///
	note("Sample size = 4403 SMEs out of which 177 registered.", size(vsmall))
gr export main_effect.png, replace
logit registered i.treatment##i.gender i.strata2 , vce(robust)
outreg2 using main_effect, excel append ctitle(logit)
margins i.treatment##i.gender, post
outreg2 using main_effect, excel append ctitle(predicted probability)

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
* 	PART : robustness check: controlling for differential delivery (bounce)
***********************************************************************
* note that 15 firms for which we could not deliver still signed up, see:
tab registered if not_delivered == 0
tab registered


logit registered i.treatment if not_delivered == 0, vce(robust)
outreg2 using robust_undelivered, excel replace ctitle(logit)
margins i.treatment, post
outreg2 using robust_undelivered, excel append ctitle(predicted probability)
logit registered i.treatment##i.gender if not_delivered == 0, vce(robust)
outreg2 using robust_undelivered, excel append ctitle(logit)
margins i.treatment##i.gender, post
outreg2 using robust_undelivered, excel append ctitle(predicted probability)
estimates store robust_undelivered, title("Main effect")
coefplot robust_undelivered, drop(_cons) ///
	xtitle("Predicted probability of registration", size(small)) xlab(0.01(0.01)0.1) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	title("{bf:How to attract (female) firms to an export support program?}") ///
	subtitle("Full sample (excluding contacts with undelivered emails)", size(small)) ///
	note("Sample size = 4403 SMEs out of which 162 registered.", size(vsmall))
gr export robust_undelivered.png, replace
logit registered i.treatment##i.gender i.strata2 if not_delivered == 0, vce(robust)
outreg2 using robust_undelivered, excel append ctitle(logit)
margins i.treatment##i.gender, post
outreg2 using robust_undelivered, excel append ctitle(predicted probability)



***********************************************************************
* 	PART : robustness check: control whether different assignment of gender changes results
***********************************************************************
	* assignment based on firm representative gender as provided at registration, API data otherwise
logit registered i.treatment, vce(robust)
outreg2 using robust_gender_rep1, excel replace ctitle(logit)
margins i.treatment, post
outreg2 using robust_gender_rep1, excel append ctitle(predicted probability)
logit registered i.treatment##i.gender_rep, vce(robust)
outreg2 using robust_gender_rep1, excel append ctitle(logit)
margins i.treatment##i.gender_rep, post
outreg2 using robust_gender_rep1, excel append ctitle(predicted probability)
estimates store robust_gender_rep, title("Main effect")
coefplot robust_gender_rep, drop(_cons) ///
	xtitle("Predicted probability of registration", size(small)) xlab(0.01(0.01)0.20) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	title("{bf:How to attract (female) firms to an export support program?}") ///
	subtitle("Full sample (gender of firm representative, not CEO)", size(small)) ///
	note("Initial gender replaced with firm representative gender. Sample size = 4848 SMEs out of which 177 registered.", size(vsmall))
gr export robust_gender_rep1.png, replace
logit registered i.treatment##i.gender_rep i.strata2 , vce(robust)
outreg2 using robust_gender_rep1, excel append ctitle(logit)
margins i.treatment##i.gender_rep, post
outreg2 using robust_gender_rep1, excel append ctitle(predicted probability)


	* as above + control for email not delivered
logit registered i.treatment if not_delivered == 0, vce(robust)
outreg2 using robust_gender_rep2, excel replace ctitle(logit)
margins i.treatment, post
outreg2 using robust_gender_rep2, excel append ctitle(predicted probability)
logit registered i.treatment##i.gender_rep if not_delivered == 0, vce(robust)
outreg2 using robust_gender_rep2, excel append ctitle(logit)
margins i.treatment##i.gender_rep, post
outreg2 using robust_gender_rep2, excel append ctitle(predicted probability)
estimates store robust_gender_rep, title("Main effect")
coefplot robust_gender_rep_rep, drop(_cons) ///
	xtitle("Predicted probability of registration", size(small)) xlab(0.01(0.01)0.20) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	title("{bf:How to attract (female) firms to an export support program?}") ///
	subtitle("Full sample (gender of firm representative, not CEO)", size(small)) ///
	note("Initial gender replaced with firm representative gender. All contacts with bounce/no delivery dropped. Sample size = 4403 SMEs out of which 162 registered.", size(vsmall))
gr export robust_gender_rep2.png, replace
logit registered i.treatment##i.gender_rep i.strata2 if not_delivered == 0, vce(robust)
outreg2 using robust_gender_rep2, excel append ctitle(logit)
margins i.treatment##i.gender_rep, post
outreg2 using robust_gender_rep2, excel append ctitle(predicted probability)

