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
* 	PART 1:
***********************************************************************
logit registered i.treatment, vce(robust)
outreg2 using main_effect, excel replace ctitle(logit)
margins i.treatment, post
outreg2 using main_effect, excel append ctitle(predicted probability)
logit registered i.treatment##i.gender, vce(robust)
outreg2 using main_effect, excel append ctitle(logit)
margins i.treatment##i.gender, post
outreg2 using main_effect, excel append ctitle(predicted probability)
estimates store main_effect, title("Main effect")
coefplot main_effect, drop(_cons) ///
	xtitle("Predicted probability of registration", size(small)) xlab(0.01(0.01)0.1) ///
	graphr(color(white)) bgcol(white) plotr(color(white)) ///
	title("{bf:How to attract (female) firms to an export support program?}") ///
	subtitle("Full sample", size(small)) ///
	note("Sample size = ?", size(vsmall))
gr export main_effect.png, replace
logit registered i.treatment##i.gender i.strata2, vce(robust)
outreg2 using main_effect, excel append ctitle(logit)
margins i.treatment##i.gender, post
outreg2 using main_effect, excel append ctitle(predicted probability)
