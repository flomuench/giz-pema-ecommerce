***********************************************************************
* 			Master generate				  
***********************************************************************
*																	  
*	PURPOSE: Generate additional variables for final analysis, not yet created
*				in surveyrround
*																	  
*	OUTLINE: 	PART 1: Baseline and take-up
*				PART 2: Mid-line	  
*				PART 3: Endline 
*													
*																	  
*	Author:  	Fabian Scheifele							    
*	ID variable: id_platforme		  					  
*	Requires:  	ecommerce_master_inter.dta
*	Creates:	ecommerce_master_inter.dta

										  

use "${master_intermediate}/ecommerce_master_inter", clear

***********************************************************************
* 	PART 1: Baseline and take-up statistics
***********************************************************************

***********************************************************************
*PART 1.1. Recreate z-scores with control mean and control SD 
*(in BL was done with overall mean/SD)
***********************************************************************	
capture program drop zscore
program define zscore /* opens a program called zscore */
	sum `1' if treatment == 0
	gen `1'z = (`1' - r(mean))/r(sd)   /* new variable gen is called --> varnamez */
end

*Definition of all variables that are being used in index calculation*
local allvars dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_score dig_presence_score dig_presence3_exscore dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_payment1 dig_payment2 dig_payment3 dig_vente dig_marketing_lien dig_marketing_ind1 dig_marketing_ind2 dig_marketing_score dig_logistique_entrepot dig_logistique_retour_score dig_service_responsable dig_service_satisfaction expprep_cible expprep_norme expprep_demande exp_pays_avg exp_per dig_description1 dig_description2 dig_description3 dig_mar_res_per dig_ser_res_per exp_prep_res_per

*IMPORTANT MODIFICATION: Missing values, Don't know, refuse or needs check answers are being transformed to zeros*
* Create temp variables where missing values etc are replaced by 0s
foreach var of local  allvars {
	replace `var' = 0 if `var' == .
	replace `var' = 0 if `var' == -999
	replace `var' = 0 if `var' == -888
	replace `var' = 0 if `var' == -777
	replace `var' = 0 if `var' == -1998
	replace `var' = 0 if `var' == -1776 
	replace `var' = 0 if `var' == -1554
	
}



	* calculate z score for all variables that are part of the index
	*QUESTION FABIAN: Can we not include a dummy of whether the firm has a dig_marketIng_response and dig_service_respo? might be better than the share no? share is discrimating large firms*

local knowledge dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_score
local digtalvars dig_presence_score dig_presence3_exscore dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_payment1 dig_payment2 dig_payment3 dig_vente dig_marketing_lien dig_marketing_ind1 dig_marketing_ind2 dig_marketing_score dig_logistique_entrepot dig_logistique_retour_score dig_service_satisfaction dig_description1 dig_description2 dig_description3 dig_mar_res_per dig_ser_res_per 
local expprep expprep_cible expprep_norme expprep_demande exp_prep_res_per
local exportcomes exp_pays_avg exp_per

foreach z in knowledge digtalvars expprep exportcomes {
	foreach x of local `z'  {
			zscore `x' 
		}
}	

*drop indices defined in bl_generate
drop knowledge digtalvars expprep expoutcomes 
*Calculate the index value: average of zscores 
egen knowledge = rowmean(dig_con1z dig_con2z dig_con3z dig_con4z dig_con5z dig_con6_scorez)
egen digtalvars = rowmean(dig_presence_scorez dig_presence3_exscorez dig_miseajour1z dig_miseajour2z dig_miseajour3z dig_payment1z dig_payment2z dig_payment3z dig_ventez dig_marketing_lienz dig_marketing_ind1z dig_marketing_ind2z dig_marketing_scorez dig_logistique_entrepotz dig_logistique_retour_score dig_service_satisfactionz dig_description1z dig_description2z dig_description3z dig_mar_res_perz dig_ser_res_perz)
egen expprep = rowmean(expprep_ciblez expprep_normez expprep_demandez exp_prep_res_perz)
egen expoutcomes = rowmean(exp_pays_avgz exp_perz)

lab var knowledge "Index for digitalisation knowledge"
label var digtalvars   "Index digitalisation"
label var expprep "Index export preparation"
label var expoutcomes "Index export outcomes"


***********************************************************************
*PART 1.2. Take-up data
***********************************************************************	
*create simplified group variable (tunis vs. non-tunis)
gen groupe2 = 0
replace groupe2 = 1 if groupe == "Tunis 1" |groupe == "Tunis 2"| groupe == "Tunis 3" | groupe == "Tunis 4" | groupe == "Tunis 5" | groupe == "Tunis 6"


save "${master_intermediate}/ecommerce_master_inter", replace
