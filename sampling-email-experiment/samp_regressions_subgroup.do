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
* 	PART 1: sub-group analysis by sector
***********************************************************************
	* use preserve not to loose the rest of the data
preserve 
	
	* create regression tables + coefficient plots for each sector
		* select the sector for which we can do subgroup analysis based on 
			* descriptive statistics = sufficient observations
levelsof Sector if registered != 0, local(sector_sufficient_n)
foreach x of local sector_sufficient_n {
	estimates clear
	* (1) logit - just treatment effect
	logit registered i.treatment if Sector == "`x'", vce(robust)
	outreg2 using "`x'", excel replace ctitle(logit)
	
	* (2) predicted probability - just treatment effect
	margins i.treatment, post
	outreg2 using "`x'", excel append ctitle(predicted probability)
	
	* (3) logit - interaction effect
	logit registered i.treatment##i.gender if Sector == "`x'", vce(robust)
	outreg2 using "`x'", excel append ctitle(logit)
	
	* (4) predicted probabilty - interaction effect
	margins i.treatment##i.gender, post
	outreg2 using "`x'", excel append ctitle(predicted probability)
	
	* coefficient plot of treatment + interaction effect
	estimates store sector
	coefplot sector, drop(_cons) ///
		xtitle("Predicted probability of registration", size(small)) xlab(0.01(0.01)0.2) ///
		graphr(color(white)) bgcol(white) plotr(color(white)) ///
		title("{bf:How to attract (female) firms to an export support program?}") ///
		subtitle("Sector `x'", size(small)) ///
		note("Sample size = ?", size(vsmall))
	gr export "`x'.png", replace
	
}
restore


***********************************************************************
* 	PART 2: sub-group analysis by firm size
***********************************************************************
