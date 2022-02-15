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
putdocx begin, pagenum(upper_roman) footer(footer1)
putdocx paragraph, halign(center) 
putdocx text ("Stratification options"), bold
putdocx pagenumber


***********************************************************************
* 	PART 1: visualisation of candidate strata variables				  										  
***********************************************************************

/* For ref, these are the three sets of vars: 
local knowledge dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_score
local ecommerce dig_presence_score dig_presence3_exscore dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_payment1 dig_payment2 dig_payment3 dig_vente dig_marketing_lien dig_marketing_ind1 dig_marketing_ind2 dig_marketing_score dig_logistique_entrepot dig_logistique_retour_score dig_service_satisfaction dig_description1 dig_description2 dig_description3 dig_mar_res_per dig_ser_res_per 
local export exp_pays_all exp_per
*/

	* Indices
	
putdocx paragraph, halign(center) 
putdocx text ("Distribution of indices and export variables"), bold
	
	* Digital knowledge index
	
putdocx paragraph, halign(center) 
putdocx text ("Knowledge of digitalisation index")
	
hist raw_knowledge, ///
	title("Raw sum of all knowledge scores") ///
	xtitle("Sum")
graph export raw_knowledge.png, replace
putdocx paragraph, halign(center) 
putdocx image raw_knowledge.png

sum raw_knowledge, d
display "Raw knowledge index has bottom 10 percentile at `r(p10)', median at `r(p50)' & top 90 percentile at  `r(p90)' ."
putdocx paragraph
putdocx text ("Raw knowledge index statistics"), linebreak bold
putdocx text ("Raw knowledge index has bottom 10 percentile at `: display %9.2fc `r(p10)'', median at `: display %9.2fc `r(p50)'' & top 90 percentile at  `: display %9.2fc `r(p90)''."), linebreak


	* E-commerce adoption: 
	
hist raw_digtalvars, ///
	title("Raw sum of all digital scores") ///
	xtitle("Sum")
graph export raw_digital.png, replace
putdocx paragraph, halign(center) 
putdocx image raw_digital.png

sum raw_digtalvars, d
display "Raw digitalisation index has bottom 10 percentile at `r(p10)', median at `r(p50)' & top 90 percentile  at `r(p90)' ."
putdocx paragraph
putdocx text ("Raw digitalisation index statistics"), linebreak bold
putdocx text ("Raw digitalisation index has bottom 10 percentile at `: display %9.2fc `r(p10)'', median at `: display %9.2fc `r(p50)'' & top 90 percentile  at `: display %9.2fc `r(p90)''."), linebreak

	* Both joint: 

hist raw_indices, ///
	title("Raw sum of digitalisation & knowledge scores") ///
	xtitle("Sum")
graph export raw_indices.png, replace
putdocx paragraph, halign(center) 
putdocx image raw_indices.png
	
sum raw_indices, d
display "Raw sum of digitalisation & knowledge indices has bottom 10 percentile at `r(p10)', median at `r(p50)' & top 90 percentile at `r(p90)' ."
putdocx paragraph
putdocx text ("Raw indices statistics"), linebreak bold
putdocx text ("Firms have min. `: display %9.2fc `r(min)'', max. `: display %9.2fc `r(max)'' & median `: display %9.2fc `r(p50)'' in the digitalisation and knowledge joint index."), linebreak


	*** NOW EXPORT VARS
	
	* Export status

graph bar (count), ///
	over(rg_oper_exp) ///
	title("Exporting status") ///
	ytitle("Number")
graph export export_status.png, replace
putdocx paragraph, halign(center) 
putdocx image export_status.png
	
	* Exporting as percentage of revenue
	
hist exp_per, ///
	title("Exporting as percentage of revenue") 
graph export exp_per.png, replace
putdocx paragraph, halign(center) 
putdocx image exp_per.png
	
sum exp_per, d
display "Exporting as percentage of revenue has bottom 10 percentile at `r(p10)', median at `r(p50)' & top 90 percentile at `r(p90)' ."
putdocx paragraph
putdocx text ("Exporting as percentage of revenue"), linebreak bold
putdocx text ("Exporting as percentage of revenue has bottom 10 percentile at `: display %9.2fc `r(p10)'', median at `: display %9.2fc `r(p50)'' & top 90 percentile at `: display %9.2fc `r(p90)''."), linebreak


	* Exporting in absolute terms
	
	
quietly sum compexp_2020, d
hist compexp_2020 if compexp_2020<`r(p99)' & rg_oper_exp==1, ///
	title("Exporting revenue") ///
	note("Top 99 percentile excluded; only exporting firms")
graph export compexp_2020.png, replace
putdocx paragraph, halign(center) 
putdocx image compexp_2020.png

quietly sum compexp_2020, d	
sum compexp_2020 if compexp_2020<`r(p99)' & rg_oper_exp==1, d
display "Exporting revenue has bottom 10 percentile at `r(p10)', median at `r(p50)' & top 90 percentile at `r(p90)' (only for exporting firms and cutting off at 99 percentile)."
putdocx paragraph
putdocx text ("Exporting revenue"), linebreak bold
putdocx text ("Exporting revenue has bottom 10 percentile at `: display %9.2fc `r(p10)'', median at `: display %9.2fc `r(p50)'' & top 90 percentile at `: display %9.2fc `r(p90)''  (only for exporting firms and cutting off at 99 percentile)."), linebreak

	* Number of exporting countries

hist exp_pays_avg if exp_pays_avg<100, ///
	title("Exporting countries") ///
	note("Outliers (countries>100) removed")
graph export exp_pays_avg.png, replace
putdocx paragraph, halign(center) 
putdocx image exp_pays_avg.png
	
sum exp_pays_avg if exp_pays_avg<100, d
display "Exporting countries has bottom 10 percentile at `r(p10)', median at `r(p50)' & top 90 percentile at `r(p90)' (outliers removed)."
putdocx paragraph
putdocx text ("Exporting countries"), linebreak bold
putdocx text ("Firms have min. `: display %9.2fc `r(min)'', max. `: display %9.2fc `r(max)'' & median `: display %9.2fc `r(p50)'' in exporting countries."), linebreak
putdocx pagebreak	
	
***********************************************************************
* 	PART 2: Create strata
***********************************************************************


	* Calculate missing values	
	
putdocx paragraph, halign(center) 
putdocx text ("Missing values"), bold
	
	* Digitalisation knowledge  index

	
putdocx paragraph
putdocx text ("Knowledge questions"), bold


g missing_knowledge = 1

local knowledge_qs dig_con1 dig_con3 dig_con4 dig_con5  
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
display "We miss some information on knowledge variables for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx paragraph
putdocx text ("We miss some information on knowledge variables for `r(miss)' (`: display %9.2fc `r(percent)''%) out of `r(total)'.")	

	* E-commerce adoption index
	
putdocx paragraph
putdocx text ("E-commerce questions"), bold

g missing_ecommerceadopt = 1
local ecommerceadoption_qs  dig_presence_score dig_presence3_exscore dig_vente  dig_marketing_score dig_marketing_ind1  dig_service_satisfaction   dig_mar_res_per  dig_ser_res_per
foreach var of local  ecommerceadoption_qs {
	replace missing_ecommerceadopt = . if `var' == .
	replace missing_ecommerceadopt = . if `var' == -999
	replace missing_ecommerceadopt = . if `var' == -888
	replace missing_ecommerceadopt = . if `var' == -777
	replace missing_ecommerceadopt = . if `var' == -1998
	replace missing_ecommerceadopt = . if `var' == -1776 
	replace missing_ecommerceadopt = . if `var' == -1554
}

replace missing_ecommerceadopt = .  if dig_miseajour1==. & dig_presence1==0.33
replace missing_ecommerceadopt = .  if dig_miseajour2==. & dig_presence2==0.33
replace missing_ecommerceadopt = .  if dig_miseajour3==. & dig_presence3==0.33

replace missing_ecommerceadopt = .  if dig_description1 ==. & dig_presence1==0.33
replace missing_ecommerceadopt = .  if dig_description2 ==. & dig_presence2==0.33
replace missing_ecommerceadopt = .  if dig_description3 ==. & dig_presence3==0.33

replace missing_ecommerceadopt = .  if dig_payment1 ==. & dig_presence1==0.33
replace missing_ecommerceadopt = .  if dig_payment2 ==. & dig_presence2==0.33
replace missing_ecommerceadopt = .  if dig_payment3 ==. & dig_presence3==0.33

replace missing_ecommerceadopt = . if dig_marketing_lien==. & dig_presence1==1 & dig_presence2==1

replace missing_ecommerceadopt = . if dig_marketing_ind2==. & dig_marketing_ind1==1

replace missing_ecommerceadopt = . if dig_logistique_entrepot==. & entr_bien_service!=2

replace missing_ecommerceadopt = . if dig_logistique_retour_score==. & entr_bien_service!=2


mdesc missing_ecommerceadopt
display "We miss some information on e-commerce variables for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx paragraph
putdocx text ("We miss some information on e-commerce variables for `r(miss)' `: display %9.2fc`r(percent)'''%) out of `r(total)'.")	

	* Export outcomes Index


putdocx paragraph
putdocx text ("Export questions"), bold

g missing_export = 1

local export_score exp_pays_avg compexp_2020 

foreach var of local export_score {
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
display "We miss some information on export variables for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx paragraph
putdocx text ("We miss some information on export variables for `r(miss)' (`: display %9.2fc `r(percent)''%) out of `r(total)'.")	

mdesc compexp_2020 if rg_oper_exp==1
display "We miss some information on export revenues specifically for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx paragraph
putdocx text ("We miss some information on export revenues specifically for `r(miss)' (`: display %9.2fc `r(percent)'''%) out of `r(total)'.")	

mdesc exp_pays_avg if rg_oper_exp==1
display "We miss some information on number of export countries specifically for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx paragraph
putdocx text ("We miss some information on number of export countries specifically for `r(miss)' (`: display %9.2fc `r(percent)''%) out of `r(total)'.")	
putdocx pagebreak


	*** STRATA
	
	
	/* 
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

putdocx pagebreak*/




	*** FIRST APPROACH – ~ 10 groups with missing values outside	
	* Stratum on export revenues
g strat1_exports = 1

sum compexp_2020, d
replace strat1_exports = 2 if compexp_2020>`r(p75)' & compexp_2020!=.
replace strat1_exports = 3 if rg_oper_exp==0

	* E-commerce adoption
	
g strat1_digitalisation = 2
sum raw_indices, d
replace strat1_digitalisation = 1 if raw_indices<`r(p25)'
replace strat1_digitalisation = 4 if raw_indices>`r(p75)'
replace strat1_digitalisation = 3 if raw_indices>=`r(p50)'

	* Create strata
	
egen strata1 = group(strat1_exports strat1_digitalisation)

	* Missing values
	
g strat1_missing = 0
replace strat1_missing = 1 if raw_indices==. 
replace strat1_missing = 1 if rg_oper_exp==. 
replace strat1_missing = 1 if compexp_2020==. & rg_oper_exp==1 	


replace strata1 = -999 if strat1_missing==1


	*** SECOND APPROACH – ~ 12 groups with missing values _inside_	
	* Stratum on export revenues
g strat2_exports = 1

sum compexp_2020, d
replace strat2_exports = 2 if compexp_2020>`r(p75)' & compexp_2020!=.
replace strat2_exports = 3 if rg_oper_exp==0
replace strat2_exports = 4 if rg_oper_exp==. | compexp_2020==.

	* E-commerce adoption
	
g strat2_digitalisation = 2
sum raw_indices, d
replace strat2_digitalisation = 1 if raw_indices<`r(p25)'
replace strat2_digitalisation = 4 if raw_indices>`r(p75)'
replace strat2_digitalisation = 3 if raw_indices>=`r(p50)'
replace strat2_digitalisation = 5 if raw_indices==.

	* Create strata
	
egen strata2 = group(strat2_exports strat2_digitalisation)


	*** THIRD APPROACH – ~ separating digtalvars and knowledge	
	
	* Stratum on export revenues
g strat3_exports = 1

sum compexp_2020, d
replace strat3_exports = 2 if compexp_2020>`r(p75)' & compexp_2020!=.
replace strat3_exports = 3 if rg_oper_exp==0
replace strat3_exports = 4 if rg_oper_exp==. | compexp_2020==.

	* E-commerce adoption
	
g strat3_ecomm = 2
sum raw_digtalvars, d
replace strat3_ecomm = 3 if raw_digtalvars>=`r(p50)'
replace strat3_ecomm = 1 if raw_digtalvars==.

	* Knowledge adoption
	
g strat3_know = 2
sum raw_knowledge, d
replace strat3_know = 3 if raw_knowledge>=`r(p50)'
replace strat3_know = 1 if raw_knowledge==.

	* Create strata
	
egen strata3 = group(strat3_exports strat3_ecomm strat3_know)

	* Two strata are too small, put them together manually
	
replace strata3 = 15 if strata3==14

***********************************************************************
* 	PART 3: Calculate variance by stratification approach
***********************************************************************

putdocx paragraph
putdocx text ("Changes in variance with stratification"), bold



	* First, calculate SD for three main outcomes zscores overall: 
	
	*** KNOWLEDGE DIGITALISATION INDEX: 
	
sum knowledge, d
display "For firms in our sample, the knowledge index has a standard deviation of `r(sd)'"
local knowledge_sd_base: display %9.2fc `r(sd)'
putdocx paragraph
putdocx text ("Digitalisation knowledge index"), linebreak bold
putdocx text ("For firms in our sample, the knowledge index has a standard deviation of `: display %9.2fc `r(sd)''.")

	
	*** E-COMMERCE INDEX: 

sum digtalvars, d
display "For firms in our sample, the e-commmerce adoption index has a standard deviation of `r(sd)'"
local digital_sd_base = strltrim("`display %9.2fc  `r(sd)'''")
putdocx paragraph
putdocx text ("E-Commerce adoption index"), linebreak bold
putdocx text ("For firms in our sample, the e-commerce adoption index has a standard deviation of `: display %9.2fc `r(sd)''.")


	*** EXPORT OUTCOMES INDEX: 

sum expoutcomes, d
display "For firms in our sample, the export outcomes index has a standard deviation of `r(sd)'."
local export_sd_base: display %9.2fc  `r(sd)'
putdocx paragraph
putdocx text ("E-Commerce adoption index"), linebreak bold
putdocx text ("For firms in our sample, this index has a standard deviation of `: display %9.2fc `r(sd)''.")

	*** IHS EXPORTS
	
sum ihs_exports, d
display "For firms in our sample, the IHS of exports has a standard deviation of `r(sd)'."
local ihsexports_sd_base: display %9.2fc  `r(sd)'
putdocx paragraph
putdocx text ("IHS of exports"), linebreak bold
putdocx text ("For firms in our sample, the IHS of exports has a standard deviation of `: display %9.2fc `r(sd)''."), linebreak	
	
	*** Now for the strata

	
	*** Strata1
	
putdocx paragraph
putdocx text ("Strata1: average SDs"), linebreak bold
putdocx text ("This approach creates strata for exports, and the joint e-commerce adoption and digital knowledge indices; there is also a separate stratum for observations with missing values in any of the relevant variables")

	*** Knowledge 
	
bysort strata1: egen ksd_strata1 = sd(knowledge)
sum ksd_strata1, d
display "With these strata, the knowledge index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the knowledge index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `knowledge_sd_base' originally).")

	*** E-commerce adoption
bysort strata1: egen dsd_strata1 = sd(digtalvars)
sum dsd_strata1, d
display "With these strata, the e-commerce adoption index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the e-commerce adoption index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `digital_sd_base' originally).")

	*** Export outcomes
bysort strata1: egen esd_strata1 = sd(expoutcomes)
sum esd_strata1, d
display "With these strata, the export outcomes index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the export outcomes index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `export_sd_base' originally).")

	*** IHS EXPORTS
	
bysort strata1: egen ihsesd_strata1 = sd(ihs_exports)
sum ihsesd_strata1, d
display "With these strata, the IHS of export by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the IHS of export by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `ihsexports_sd_base' originally)."), linebreak
putdocx pagebreak

putdocx paragraph
putdocx text ("Size of strata for strata1"), linebreak bold
tab2docx strata1


	
	*** Strata2
	
putdocx paragraph
putdocx text ("Strata2: average SDs"), linebreak bold
putdocx text ("This approach creates strata is the same as the first, but missing values remain inside each strata category (ie they're not a separate category)"), linebreak

	*** Knowledge 
	
bysort strata2: egen ksd_strata2 = sd(knowledge)
sum ksd_strata2, d
display "With these strata, the knowledge index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the knowledge index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `knowledge_sd_base' originally).")

	*** E-commerce adoption
bysort strata2: egen dsd_strata2 = sd(digtalvars)
sum dsd_strata2, d
display "With these strata, the e-commerce adoption index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the e-commerce adoption index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `digital_sd_base' originally).")

	*** Export outcomes
bysort strata2: egen esd_strata2 = sd(expoutcomes)
sum esd_strata2, d
display "With these strata, the export outcomes index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the export outcomes index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `export_sd_base' originally).")

	*** IHS EXPORTS
	
bysort strata2: egen ihsesd_strata2 = sd(ihs_exports)
sum ihsesd_strata2, d
display "With these strata, the IHS of export by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the IHS of export by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `ihsexports_sd_base' originally)."), linebreak

putdocx paragraph
putdocx text ("Size of strata for strata2"), linebreak bold
tab2docx strata2



	*** Strata3
	
putdocx paragraph
putdocx text ("Strata3: average SDs"), linebreak bold
putdocx text ("This approach creates strata for both the digital knowledge and e-commerce adoption indices (as well as exports), while keeping missing values inside each strata category"), linebreak

	*** Knowledge 
	
bysort strata3: egen ksd_strata3 = sd(knowledge)
sum ksd_strata3, d
display "With these strata, the knowledge index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the knowledge index by stratum has an average standard deviation of `: display %9.2fc `r(mean)''' (compared to `knowledge_sd_base' originally).")

	*** E-commerce adoption
bysort strata3: egen dsd_strata3 = sd(digtalvars)
sum dsd_strata3, d
display "With these strata, the e-commerce adoption index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the e-commerce adoption index by stratum has an average standard deviation of `: display %9.2fc `r(mean)''' (compared to `digital_sd_base' originally).")

	*** Export outcomes
bysort strata3: egen esd_strata3 = sd(expoutcomes)
sum esd_strata3, d
display "With these strata, the export outcomes index by stratum has an average standard deviation of `: display %9.2fc `r(mean)''."
putdocx paragraph
putdocx text ("With these strata, the export outcomes index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `export_sd_base' originally).")

	*** IHS EXPORTS
	
bysort strata3: egen ihsesd_strata3 = sd(ihs_exports)
sum ihsesd_strata3, d
display "With these strata, the IHS of export by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the IHS of export by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `ihsexports_sd_base' originally)."), linebreak

putdocx paragraph
putdocx text ("Size of strata for strata3"), linebreak bold
tab2docx strata3







putdocx save stratification.docx, replace








