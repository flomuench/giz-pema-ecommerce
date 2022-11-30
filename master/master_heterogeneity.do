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
* ancova with stratification dummies
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
	scalars("strata Strata controls" "bl_control Y0") ///
	addnotes("All standard errors are clustered at firm level.")


eststo ki_het2, r:reg knowledge_index treatment##c.fte l.knowledge_index  i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"

eststo ki_het3, r:reg knowledge_index treatment##c.rg_age l.knowledge_index  i.strata,  cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"

eststo ki_het4, r:reg knowledge_index treatment##c.(l.comp_ca2020) l.knowledge_index i.strata ,  cluster(id_plateforme)
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
	scalars("strata Strata controls" "bl_control Y0") ///
	addnotes("All standard errors are clustered at firm level.")
