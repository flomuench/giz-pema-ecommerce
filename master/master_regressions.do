***********************************************************************
* 			Master analysis/regressions				  
***********************************************************************
*																	  
*	PURPOSE: 	Undertake treatment effect analysis of primary and secondary
*				outcomes as well as sub-group/heterogeneity analyses																	  
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
cd "${master_gdrive}/output"

* xtset data to enable use of lag operator for inclusion of baseline value of Y
encode id_platforme, gen(ID)
order ID, b(id_platforme)
xtset ID surveyround

***********************************************************************
* 	Part 1: 	Midline analysis			  
***********************************************************************

***********************************************************************
* 	PART 1.1: survey attrition 		
***********************************************************************

***********************************************************************
* 	PART 1.2: knowledge index		
***********************************************************************
	* ATE, ancova
	
			* no significant baseline differences
reg knowledge_index i.treatment if surveyround == 1, vce(hc3)

			* pure mean comparison at midline
eststo ki1, r: reg knowledge_index i.treatment if surveyround == 2, vce(hc3)
estadd local bl_control "No"
estadd local strata "No"

			

			* ancova plus stratification dummies
eststo ki2, r: reg knowledge_index i.treatment l.knowledge_index i.strata, vce(hc3)
estadd local bl_control "Yes"
estadd local strata "Yes"
estimates store ki_ate

			* DiD
eststo ki3, r: xtreg knowledge_index i.treatment##i.surveyround i.strata, vce(robust)
estadd local bl_control "Yes"
estadd local strata "Yes"			


* ATT, IV
ivreg2 knowledge_index i.strata  (take_up2 = i.treatment) if surveyround == 2, robust first
		
eststo ki4, r:ivreg2 knowledge_index l.knowledge_index i.strata (take_up2 = i.treatment), robust first
estadd local bl_control "Yes"
estadd local strata "Yes"
estimates store iv_ki4


***********************************************************************
* 	PART 1.2: Digital presence index		
***********************************************************************





***********************************************************************
* 	PART 1.3: Digital marketing index		
***********************************************************************







***********************************************************************
* 	PART 1.4: Digital revenues		
***********************************************************************
*First replace missing values by zeros and create dummy for these values

/*gen dig_revenues_ecom_miss = 0 
replace dig_revenues_ecom_miss = 1 if dig_revenues_ecom == -999 |dig_revenues_ecom == -888 | ///
dig_revenues_ecom== .

recode dig_revenues_ecom (-999 -888 =.)
replace dig_revenues_ecom = 0 if dig_revenues_ecom==.
*/



*
