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
cd "${master_gdrive}/output/ML regressions"


***********************************************************************
* 	Part 1: 	Midline analysis			  
***********************************************************************

***********************************************************************
* 	PART 1.1: survey attrition 		
***********************************************************************
*test for differential attrition using the PAP specification (cluster SE, strata)
eststo a0, r:reg  bl_attrit treatment if surveyround==1,  cluster(id_plateforme)
estadd local strata "No"

eststo a1, r:areg  bl_attrit treatment if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

eststo a2, r:reg  ml_attrit treatment if surveyround==1, cluster(id_plateforme)
estadd local strata "No"

eststo a3, r:areg  ml_attrit treatment if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

eststo a4, r:areg  ml_attrit i.sector if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

eststo a5, r:reg  ml_attrit i.sector if surveyround==1, cluster(id_plateforme)
estadd local strata "No"

local regressions a0 a1 a2 a3 a4 
esttab `regressions' using "ml_dif_attrition.tex", replace ///
	mtitles("BL attrition" "BL attrition" "ML attrition" "ML attrition" "ML attrition") ///
	label ///
	b(3) ///
	se(3) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls") ///
	addnotes("All standard errors are clustered at firm level.")

*test for selective attrition on key outcome variables
eststo a_sel5,r:areg  ihs_exports95 treatment##ml_attrit if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

eststo a_sel6, r:areg  ihs_revenue95 treatment##ml_attrit if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

eststo a_sel7, r:areg  ihs_w95_dig_rev20 treatment##ml_attrit if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

eststo a_sel8, r:areg  exp_pays_avg treatment##ml_attrit if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

eststo a_sel9, r:areg  knowledge_index treatment##ml_attrit if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

eststo a_sel10, r:areg  dig_marketing_index treatment##ml_attrit if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

eststo a_sel11, r:areg  dig_presence_weightedz treatment##ml_attrit if surveyround==1, absorb(strata) cluster(id_plateforme)
estadd local strata "Yes"

local regressions a_sel5 a_sel6 a_sel7 a_sel8 a_sel9 a_sel10 a_sel11
esttab `regressions' using "ml_sel_attrition.tex", replace ///
	mtitles("IHS Exports" "IHS Total Rev." "IHS Digital Rev." "No. of exp. countries" "Knowledge" "Dig.Marketing" "Online Presence") ///
	label ///
	b(3) ///
	se(3) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls") ///
	addnotes("All standard errors are clustered at firm level.")


/*
preserve
keep if surveyround==1
*adjusting for multiple hypothesis
wyoung ihs_revenue95 ihs_exports95 ihs_w95_dig_rev20 knowledge_index dig_marketing_index dig_presence_weightedz, cmd(regress OUTCOMEVAR treatment , cluster(id_plateforme)) cluster(id_plateforme) familyp(treatment) ///
	subgroup(ml_attrit) bootstraps(1000) seed(8291)

restore
*/

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

			

			* ancova without stratification dummies
eststo ki2, r: reg knowledge_index i.treatment l.knowledge_index, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "No"

			* ancova with stratification dummies
eststo ki3, r: reg knowledge_index i.treatment l.knowledge_index i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"

			* DiD
eststo ki4, r: xtreg knowledge_index i.treatment##i.surveyround i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"			


			* ATT, IV (with 1 session counting as taken up)
eststo ki5, r:ivreg2 knowledge_index l.knowledge_index i.strata (take_up2 = i.treatment), cluster(id_plateforme) first
estadd local bl_control "Yes"
estadd local strata "Yes"
estimates store iv_ki4


			* ATT, IV (with 1 session counting as taken up)
eststo ki6, r:ivreg2 knowledge_index l.knowledge_index i.strata (take_up = i.treatment), cluster(id_plateforme) first
estadd local bl_control "Yes"
estadd local strata "Yes"

local regressions ki1 ki2 ki3 ki4 ki5 ki6
esttab `regressions' using "ml_knowledge.tex", replace ///
	mtitles("Mean comparison" "Ancova" "Ancova" "DiD" "ATT" "ATT") ///
	label ///
	b(3) ///
	se(3) ///
	drop(*.strata) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls" "bl_control Y0 control") ///
	addnotes("Column (1) presents estimates for a simple mean comparison between treatment and control group at midline."  "Column (2) presents an ANCOVA specification without strata controls." "Column (3) presents an ANCOVA specification with strata controls." "Column (4) provides estimates from a difference-in-difference specification." "Column (5) estimates are based on 2SLS instrumental variable estimation where treatment assignment is the instrument for treatment participation." "(1) uses robust standard errors. In (2)-(5) standard errors are clustered at the firm level to account for multiple observations per firm")

***********************************************************************
* 	PART 1.2: knowledge index (non-normalized scores)		
***********************************************************************
		* ATE, ancova
	
			* no significant baseline differences
reg raw_knowledge i.treatment if surveyround == 1, vce(hc3)

			* pure mean comparison at midline
eststo ki1, r: reg raw_knowledge i.treatment if surveyround == 2, vce(hc3)
estadd local bl_control "No"
estadd local strata "No"

			

			* ancova without stratification dummies
eststo ki2, r: reg raw_knowledge i.treatment l.raw_knowledge, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "No"

			* ancova with stratification dummies
eststo ki3, r: reg raw_knowledge i.treatment l.raw_knowledge i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"

			* DiD
eststo ki4, r: xtreg raw_knowledge i.treatment##i.surveyround i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"			


			* ATT, IV (with 1 session counting as taken up)
eststo ki5, r:ivreg2 raw_knowledge l.raw_knowledge i.strata (take_up2 = i.treatment), cluster(id_plateforme) first
estadd local bl_control "Yes"
estadd local strata "Yes"
estimates store iv_ki4


			* ATT, IV (with 1 session counting as taken up)
eststo ki6, r:ivreg2 raw_knowledge l.raw_knowledge i.strata (take_up = i.treatment), cluster(id_plateforme) first
estadd local bl_control "Yes"
estadd local strata "Yes"

local regressions ki1 ki2 ki3 ki4 ki5 ki6
esttab `regressions' using "ml_knowledge_raw.tex", replace ///
	mtitles("Mean comparison" "Ancova" "Ancova" "DiD" "ATT" "ATT") ///
	label ///
	b(3) ///
	se(3) ///
	drop(*.strata) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls" "bl_control Y0 control") ///
	addnotes("Column (1) presents estimates for a simple mean comparison between treatment and control group at midline."  "Column (2) presents an ANCOVA specification without strata controls." "Column (3) presents an ANCOVA specification with strata controls." "Column (4) provides estimates from a difference-in-difference specification." "Column (5) estimates are based on 2SLS instrumental variable estimation where treatment assignment is the instrument for treatment participation." "(1) uses robust standard errors. In (2)-(5) standard errors are clustered at the firm level to account for multiple observations per firm")

***********************************************************************
* 	PART 1.2: Digital presence index		
***********************************************************************
reg dig_presence_weightedz i.treatment if surveyround == 1, vce(hc3)

* pure mean comparison at midline
eststo pres1, r: reg dig_presence_weightedz i.treatment if surveyround == 2, vce(hc3)
estadd local bl_control "No"
estadd local strata "No"
		
			* ancova without stratification dummies
eststo pres2, r: reg dig_presence_weightedz i.treatment l.dig_presence_weightedz, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "No"

			* ancova with stratification dummies
eststo pres3, r: reg dig_presence_weightedz i.treatment l.dig_presence_weightedz i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"

			* DiD
eststo pres4, r: xtreg dig_presence_weightedz i.treatment##i.surveyround i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"			


			* ATT, IV (with 1 session counting as taken up)
eststo pres5, r:ivreg2 dig_presence_weightedz l.dig_presence_weightedz i.strata (take_up2 = i.treatment), cluster(id_plateforme) first
estadd local bl_control "Yes"
estadd local strata "Yes"
estimates store iv_pres4


			* ATT, IV (with 1 session counting as taken up)
eststo pres6, r:ivreg2 dig_presence_weightedz l.dig_presence_weightedz i.strata (take_up = i.treatment), cluster(id_plateforme) first
estadd local bl_control "Yes"
estadd local strata "Yes"

local regressions pres1 pres2 pres3 pres4 pres5 pres6
esttab `regressions' using "presence_reg.tex", replace ///
	mtitles("Mean comparison" "Ancova" "Ancova" "DiD" "ATT" "ATT") ///
	label ///
	b(3) ///
	se(3) ///
	drop(*.strata) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls" "bl_control Y0 control") ///
	addnotes("Column (1) presents estimates for a simple mean comparison between treatment and control group at midline."  "Column (2) presents an ANCOVA specification without strata controls." "Column (3) presents an ANCOVA specification with strata controls." "Column (4) provides estimates from a difference-in-difference specification." "Columns (5) & (6) estimates are based on 2SLS instrumental variable estimation where treatment assignment is the instrument for treatment participation." "(1) uses robust standard errors. In (2)-(6) standard errors are clustered at the firm level to account for multiple observations per firm")

***********************************************************************
* 	PART 1.3: Digital marketing index		
***********************************************************************
	* ATE, ancova
	
			* no significant baseline differences
reg dig_marketing_index i.treatment if surveyround == 1, vce(hc3)

			* pure mean comparison at midline
eststo dig_mark1, r: reg dig_marketing_index i.treatment if surveyround == 2, vce(hc3)
estadd local bl_control "No"
estadd local strata "No"

			

			* ancova without stratification dummies
eststo dig_mark2, r: reg dig_marketing_index i.treatment l.dig_marketing_index, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "No"

			* ancova with stratification dummies
eststo dig_mark3, r: reg dig_marketing_index i.treatment l.dig_marketing_index i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"

			* DiD
eststo dig_mark4, r: xtreg dig_marketing_index i.treatment##i.surveyround i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"			


			* ATT, IV (with 1 session counting as taken up)
eststo dig_mark5, r:ivreg2 dig_marketing_index l.dig_marketing_index i.strata (take_up2 = i.treatment), cluster(id_plateforme) first
estadd local bl_control "Yes"
estadd local strata "Yes"
estimates store iv_dig_mark4


			* ATT, IV (with 1 session counting as taken up)
eststo dig_mark6, r:ivreg2 dig_marketing_index l.dig_marketing_index i.strata (take_up = i.treatment), cluster(id_plateforme) first
estadd local bl_control "Yes"
estadd local strata "Yes"

local regressions dig_mark1 dig_mark2 dig_mark3 dig_mark4 dig_mark5 dig_mark6
esttab `regressions' using "ml_dig_marketing.tex", replace ///
	mtitles("Mean comparison" "Ancova" "Ancova" "DiD" "ATT" "ATT") ///
	label ///
	b(3) ///
	se(3) ///
	drop(*.strata) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls" "bl_control Y0 control") ///
	addnotes("Column (1) presents estimates for a simple mean comparison between treatment and control group at midline."  "Column (2) presents an ANCOVA specification without strata controls." "Column (3) presents an ANCOVA specification with strata controls." "Column (4) provides estimates from a difference-in-difference specification." "Column (5) estimates are based on 2SLS instrumental variable estimation where treatment assignment is the instrument for treatment participation." "(1) uses robust standard errors. In (2)-(5) standard errors are clustered at the firm level to account for multiple observations per firm")


***********************************************************************
* 	PART 1.4: Digital revenues (no adjustment)		
***********************************************************************
	* ATE, ancova
	
			* no significant baseline differences
eststo dig_rev_bl1, r:reg ihs_w95_dig_rev20 i.treatment if surveyround == 1, vce(hc3)
estadd local bl_control "No"
estadd local strata "No"

			* no significant baseline differences (strata dummies)
eststo dig_rev_bl2, r:reg ihs_w95_dig_rev20 i.treatment i.strata if surveyround == 1, vce(hc3)
estadd local bl_control "No"
estadd local strata "Yes"

			* pure mean comparison at midline
eststo dig_rev1, r: reg ihs_w95_dig_rev20 i.treatment if surveyround == 2, vce(hc3)
estadd local bl_control "No"
estadd local strata "No"

			

			* ancova without stratification dummies
eststo dig_rev2, r: reg ihs_w95_dig_rev20 i.treatment l.ihs_w95_dig_rev20, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "No"

			* ancova with stratification dummies
eststo dig_rev3, r: reg ihs_w95_dig_rev20 i.treatment l.ihs_w95_dig_rev20 i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"

			* DiD
eststo dig_rev4, r: xtreg ihs_w95_dig_rev20 i.treatment##i.surveyround i.strata, cluster(id_plateforme)
estadd local bl_control "Yes"
estadd local strata "Yes"			


			* ATT, IV (with 1 session counting as taken up)
eststo dig_rev5, r:ivreg2 ihs_w95_dig_rev20 l.ihs_w95_dig_rev20 i.strata (take_up2 = i.treatment), cluster(id_plateforme) first
estadd local bl_control "Yes"
estadd local strata "Yes"
estimates store iv_dig_rev4


			* ATT, IV (with 3 session counting as taken up)
eststo dig_rev6, r:ivreg2 ihs_w95_dig_rev20 l.ihs_w95_dig_rev20 i.strata (take_up = i.treatment), cluster(id_plateforme) first
estadd local bl_control "Yes"
estadd local strata "Yes"

local regressions dig_rev_bl1 dig_rev_bl2 dig_rev1 dig_rev2 dig_rev3 dig_rev4 dig_rev5 dig_rev6
esttab `regressions' using "ml_dig_revenues.tex", replace ///
	mtitles("BL mean" "BL mean" "ML-Mean comparison" "Ancova" "Ancova" "DiD" "ATT" "ATT") ///
	label ///
	b(3) ///
	se(3) ///
	drop(*.strata) ///
	star(* 0.1 ** 0.05 *** 0.01) ///
	nobaselevels ///
	scalars("strata Strata controls" "bl_control Y0 control") ///
	addnotes("Column (1) presents estimates for a simple mean comparison between treatment and control group at midline."  "Column (2) presents an ANCOVA specification without strata controls." "Column (3) presents an ANCOVA specification with strata controls." "Column (4) provides estimates from a difference-in-difference specification." "Column (5) estimates are based on 2SLS instrumental variable estimation where treatment assignment is the instrument for treatment participation." "(1) uses robust standard errors. In (2)-(5) standard errors are clustered at the firm level to account for multiple observations per firm")






***********************************************************************
* 	PART 1.4: Digital revenues (missing values to zero and dummy out)		
***********************************************************************
*First replace missing values by zeros and create dummy for these values
/*
gen dig_revenues_ecom_miss = 0 
replace dig_revenues_ecom_miss = 1 if dig_revenues_ecom == -999 |dig_revenues_ecom == -888 | ///
dig_revenues_ecom== .

replace dig_revenues_ecom = 0 if dig_revenues_ecom==.


*/
