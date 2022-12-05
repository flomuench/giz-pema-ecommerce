***********************************************************************
* 			Master heterogeneity				  
***********************************************************************
*																	  
*	PURPOSE: 	Look at heterogeneity of treatment 			effects																	  
*
*													
*																	  
*	Author:  	Fabian Scheifele							    
*	ID variable: id_platforme		  					  
*	Requires:  	ecommerce_master_final.dta
*	Creates:

***********************************************************************
* 	Part 0: 	set the stage		  
***********************************************************************

use "${master_final}/ecommerce_master_final", clear
		
		* change directory
cd "${master_gdrive}/output/ML regressions"

***********************************************************************
* 	Part 1: 	Knowledge index	  
***********************************************************************
* ancova with stratification dummies, by sector
eststo ki_het1, r:reg knowledge_index treatment##i.sector l.knowledge_index i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"

esttab ki_het1 using "ki_hetero_sector.tex", replace ///
	mtitles("Knowledge index") ///
	label ///
	b(3) ///
	se(3) ///
	drop(*.strata) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls" "bl_control Y0 control") ///
	addnotes("All standard errors are clustered at firm level.")

*By employment, firm age and revenues
eststo ki_het2, r:reg knowledge_index treatment##c.fte l.knowledge_index  i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"

eststo ki_het3, r:reg knowledge_index treatment##c.rg_age l.knowledge_index  i.strata,  cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"

eststo ki_het4, r:reg knowledge_index treatment##c.(l.ihs_revenue95) l.knowledge_index i.strata ,  cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"

local regressions ki_het2 ki_het3 ki_het4
esttab `regressions' using "ki_hetero_other.tex", replace ///
	mtitles("Knowledge index" "Knowledge index" "Knowledge index") ///
	label ///
	b(3) ///
	se(3) ///
	drop(*.strata) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls" "bl_control Y0 control") ///
	addnotes("All standard errors are clustered at firm level.")
	
	
*Individual questions
local questions dig_con1_ml dig_con2_ml dig_con3_ml dig_con4_ml dig_con5_ml	
foreach var of local questions {
	eststo reg_`var', r:reg `var' treatment i.strata if surveyround==2, vce(hc3)
	estadd local bl_control "No"
	estadd local strata "Yes"
	}
	
esttab `questions' using "ki_questions.tex", replace ///
	mtitles("Means of payment" "Digital Content" "Google Analytics" "Engagement Rate" "SEO") ///
	label ///
	b(3) ///
	se(3) ///
	drop(*.strata) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls") ///
	addnotes("Robust standard errors in paratheses.")	