***********************************************************************
* 			E-commerce field experiment:  stratification								  		  
***********************************************************************
*																	   
*	PURPOSE: Stratify firms that responded to baseline survey; select stratification approach						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)		
*	2)		gen stratification dummy alternatives
*	3)		visualise number of observations per strata														  
*
*																 																      *
*	Author:  	Teo Firpo													  
*	ID variable: 	id_plateforme			  									  
*	Requires:		bl_final.dta
*	Creates:		
*																	  
***********************************************************************
* 	PART I:  	define the settings as necessary 			     	  *
***********************************************************************

	* import data
use "${bl_final}/bl_final", clear

	* change directory to visualisations
cd "$bl_output/stratification"

	* begin word file to export strata visualisations
	
putdocx clear	
putdocx begin
putdocx paragraph
putdocx text ("Stratification options"), bold

***********************************************************************
* 	PART 1: visualisation of candidate strata variables				  										  
***********************************************************************


local knowledge dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_score
local ecommerce dig_presence_score dig_presence3_exscore dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_payment1 dig_payment2 dig_payment3 dig_vente dig_marketing_lien dig_marketing_ind1 dig_marketing_ind2 dig_marketing_score dig_logistique_entrepot dig_logistique_retour_score dig_service_satisfaction dig_description1 dig_description2 dig_description3 dig_mar_res_per dig_ser_res_per 
local export exp_pays_all exp_per

	
	* Indices
	
	* Digital knowledge index
	
putdocx paragraph, halign(center) 
putdocx text ("Knowledge of digitalisation index")

hist knowledge, ///
	title("Zscores of knowledge of digitalisation scores") ///
	xtitle("Zscores")
graph export knowledge_zscores.png, replace
putdocx paragraph, halign(center) 
putdocx image knowledge_zscores.png
	
hist raw_knowledge, ///
	title("Raw sum of all knowledge scores") ///
	xtitle("Sum")
graph export raw_knowledge.png, replace
putdocx paragraph, halign(center) 
putdocx image raw_knowledge.png

sum raw_knowledge, d
display "Raw digitalisation knowledge index has bottom 10 percentile at `r(p10)', median at `r(p50)' & top 90 percentile `r(p90)' ."
putdocx paragraph
putdocx text ("Raw digitalisation knowledge index statistics"), linebreak bold
putdocx text ("Firms have min. `r(min)', max. `r(max)' & median `r(p50)' in this index."), linebreak


	* Digital Z-scores
	
hist digtalvars, ///
	title("Zscores of digital scores") ///
	xtitle("Zscores")
graph export digital_zscores.png, replace
putdocx paragraph, halign(center) 
putdocx image digital_zscores.png


	* For comparison, the 'raw' index: 
	
hist raw_digtalvars, ///
	title("Raw sum of all digital scores") ///
	xtitle("Sum")
graph export raw_digital.png, replace
putdocx paragraph, halign(center) 
putdocx image raw_digital.png

sum raw_digtalvars, d
display "Raw digitalisation index has bottom 10 percentile at `r(p10)', median at `r(p50)' & top 90 percentile `r(p90)' ."
putdocx paragraph
putdocx text ("Raw digitalisation index statistics"), linebreak bold
putdocx text ("Firms have min. `r(min)', max. `r(max)' & median `r(p50)' in this index."), linebreak


	* Export outcomes Z-scores
	
hist expoutcomes, ///
	title("Zscores of export outcomes questions") ///
	xtitle("Zscores")
graph export expoutcomes_zscores.png, replace
putdocx paragraph, halign(center) 
putdocx image expoutcomes_zscores.png

	* For comparison, the 'raw' index:
	
hist raw_expoutcomes, ///
	title("Raw sum of all export outcomes questions") ///
	xtitle("Sum")
graph export raw_expoutcomes.png, replace
putdocx paragraph, halign(center) 
putdocx image raw_expoutcomes.png

sum raw_expoutcomes, d
display "Raw export outcomes index has bottom 10 percentile at `r(p10)', median at `r(p50)' & top 90 percentile `r(p90)' ."
putdocx paragraph
putdocx text ("Raw export outcomes index statistics"), linebreak bold
putdocx text ("Firms have min. `r(min)', max. `r(max)' & median `r(p50)' in this index."), linebreak
putdocx pagebreak


***********************************************************************
* 	PART 2: Create strata
***********************************************************************


	* Calculate missing values	
	
	* Digitalisation knowledge  index

local knowledge_qs dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_score 

g missing_knowledge = 1
foreach var of local  knowledge_qs {
	replace missing_knowledge = . if `var' == .
	replace missing_knowledge = . if `var' == -999
	replace missing_knowledge = . if `var' == -888
	replace missing_knowledge = . if `var' == -777
	replace missing_knowledge = . if `var' == -1998
	replace missing_knowledge = . if `var' == -1776 
	replace missing_knowledge = . if `var' == -1554
}

mdesc missing_knowledge
display "We miss some information on these variables for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx paragraph
putdocx text ("We miss some information on these variables for `r(miss)' (`r(percent)'%) out of `r(total)'.")	

	* Calculate missing values
	* E-commerce adoption index
	
local ecommerceadoption_qs  dig_presence_score  dig_miseajour1  dig_miseajour2  dig_miseajour3  dig_payment1  dig_payment2  dig_payment3  dig_vente  dig_marketing_lien  dig_marketing_ind1  dig_marketing_ind2  dig_marketing_score  dig_logistique_entrepot t_dig_logistique_retour_score  dig_service_satisfaction  dig_description1  dig_description2  dig_description3  dig_mar_res_per  dig_ser_res_per

g missing_ecommerceadopt = 1
foreach var of local  ecommerceadoption_qs {
	replace missing_ecommerceadopt = . if `var' == .
	replace missing_ecommerceadopt = . if `var' == -999
	replace missing_ecommerceadopt = . if `var' == -888
	replace missing_ecommerceadopt = . if `var' == -777
	replace missing_ecommerceadopt = . if `var' == -1998
	replace missing_ecommerceadopt = . if `var' == -1776 
	replace missing_ecommerceadopt = . if `var' == -1554
}

mdesc missing_ecommerceadopt
display "We miss some information on these variables for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx paragraph
putdocx text ("We miss some information on these variables for `r(miss)' (`r(percent)'%) out of `r(total)'.")	

	* Export outcomes Index

local export_score exp_pays_avant21 exp_pays_21 compexp_2020 comp_ca2020 

g missing_export = 1

foreach var of local  export_score {
	replace missing_export = . if `var' == .
	replace missing_export = . if `var' == -999
	replace missing_export = . if `var' == -888
	replace missing_export = . if `var' == -777
	replace missing_export = . if `var' == -1998
	replace missing_export = . if `var' == -1776 
	replace missing_export = . if `var' == -1554
}

replace missing_export = 1 if rg_oper_exp==0

mdesc missing_export
display "We miss some information on these variables for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx paragraph
putdocx text ("We miss some information on these variables for `r(miss)' (`r(percent)'%) out of `r(total)'.")	

	*** STRATA
	
	*** First approach: create simple strata for each index only
	
	* First, divide by under and above median
	
foreach var of varlist knowledge digtalvars expoutcomes {
	egen median = median(`var')
	gen strat1_`var' = 0
	replace strat1_`var' = 1 if `var' >= median & !missing(`var') 
	drop median
}

	* Second, create a separate category for indices with missing values
	
replace strat1_knowledge = 2 if missing(missing_knowledge)
replace strat1_digtalvars = 2 if missing(missing_ecommerceadopt)
replace strat1_expoutcomes = 2 if missing(missing_export)

	* Create strata
	
egen strata1 = group(strat1_knowledge strat1_digtalvars strat1_expoutcomes)

putdocx pagebreak




***********************************************************************
* 	PART 3: Calculate variance by stratification approach
***********************************************************************


	* First, calculate SD for three main outcomes zscores overall: 
	
	
	*** KNOWLEDGE DIGITALISATION INDEX: 
	
sum knowledge, d
display "For firms in our sample, this index has a standard deviation of `r(sd)"
putdocx paragraph
putdocx text ("Digitalisation knowledge index"), linebreak bold
putdocx text ("For firms in our sample, the knowledge index has a standard deviation of `r(sd)'."), linebreak

	
	*** E-COMMERCE INDEX: 

sum digtalvars, d
display "For firms in our sample, this index has a standard deviation of `r(sd)'"
putdocx paragraph
putdocx text ("E-Commerce adoption index"), linebreak bold
putdocx text ("For firms in our sample, the e-commerce adoption index has a standard deviation of `r(sd)'."), linebreak


	*** EXPORT OUTCOMES INDEX: 

sum expoutcomes, d
display "For firms in our sample, the export outcomes index has a standard deviation of `r(sd)'."
putdocx paragraph
putdocx text ("E-Commerce adoption index"), linebreak bold
putdocx text ("For firms in our sample, this index has a standard deviation of `r(sd)'."), linebreak

	
	*** Now for the strata

	
	*** Strata1
	
putdocx paragraph
putdocx text ("Strata1: average SDs"), linebreak bold

	*** Knowledge 
	
bysort strata1: egen ksd_strata1 = sd(knowledge)
sum ksd_strata1, d
display "With these strata, the knowledge index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the knowledge index by stratum has an average standard deviation of `r(mean)'."), linebreak

	*** E-commerce adoption
bysort strata1: egen dsd_strata1 = sd(digtalvars)
sum dsd_strata1, d
display "With these strata, the e-commerce adoption index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the e-commerce adoption index by stratum has an average standard deviation of `r(mean)'."), linebreak

	*** Export outcomes
bysort strata1: egen esd_strata1 = sd(expoutcomes)
sum esd_strata1, d
display "With these strata, the export outcomes index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the export outcomes index by stratum has an average standard deviation of `r(mean)'."), linebreak

putdocx save stratification.docx, replace







