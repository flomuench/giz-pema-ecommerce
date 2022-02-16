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
	
	* For the purposes of strata, I replace "i don't know'/'refused' with missing in key variables
	
	
local missing_vars compexp_2020 comp_ca2020 exp_pays_avg rg_oper_exp

foreach var of local missing_vars {
	replace `var' = . if `var' == -888
	replace `var' = . if `var' == -999
	replace `var' = . if `var' == -777
	
}	
	
	
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


/* --------------------------------------------------------------------
	STRATA 1
----------------------------------------------------------------------*/	

	*** FIRST APPROACH – ~ 10 groups with missing values outside	
	* Stratum on export revenues
g strat1_exports = 1

sum compexp_2020, d
replace strat1_exports = 2 if compexp_2020>`r(p75)' & compexp_2020!=.
replace strat1_exports = 3 if rg_oper_exp==0

	* E-commerce adoption and knowledge questions together
	
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

/* --------------------------------------------------------------------
	STRATA 2
----------------------------------------------------------------------*/	


	*** SECOND APPROACH – ~ 12 groups with missing values _inside_	
	* Stratum on export revenues
g strat2_exports = 1

sum compexp_2020, d
replace strat2_exports = 2 if compexp_2020>`r(p75)' & compexp_2020!=.
replace strat2_exports = 3 if rg_oper_exp==0
replace strat2_exports = 4 if rg_oper_exp==. | compexp_2020==.

	* E-commerce adoption and knowledge questions together
	
g strat2_digitalisation = 2
sum raw_indices, d
replace strat2_digitalisation = 1 if raw_indices<`r(p25)'
replace strat2_digitalisation = 4 if raw_indices>`r(p75)'
replace strat2_digitalisation = 3 if raw_indices>=`r(p50)'
replace strat2_digitalisation = 5 if raw_indices==.

	* Create strata
	
egen strata2 = group(strat2_exports strat2_digitalisation)



/* --------------------------------------------------------------------
	STRATA 3
----------------------------------------------------------------------*/	

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

/* --------------------------------------------------------------------
	STRATA 4
----------------------------------------------------------------------*/	

	*** FOURTH APPROACH – ~ As above but including comp_ca2020 and with higher caps for exports

	
	* Stratum on export revenues
g strat4_exports = 1

sum compexp_2020, d
replace strat4_exports = 2 if compexp_2020>`r(p50)' & compexp_2020!=.
replace strat4_exports = 3 if rg_oper_exp==0
replace strat4_exports = 4 if rg_oper_exp==. | compexp_2020==.

	* E-commerce adoption
	
g strat4_ecomm = 2
sum raw_digtalvars, d
replace strat4_ecomm = 3 if raw_digtalvars>=`r(p50)'
replace strat4_ecomm = 1 if raw_digtalvars==.

	* Knowledge adoption
	
g strat4_know = 2
sum raw_knowledge, d
replace strat4_know = 3 if raw_knowledge>=`r(p50)'
replace strat4_know = 1 if raw_knowledge==.

	* Create strata
	
egen strata4 = group(strat4_exports strat4_ecomm strat4_know)

	* Two strata are too small, put them together manually
	
replace strata4 = 15 if strata4==14

	* Finally, create a new stratum for observations with too large total revenues or too large exports
	
quietly sum comp_ca2020, d
replace strata4 = 21 if comp_ca2020>`r(p90)' & comp_ca2020!=.

quietly sum compexp_2020, d
replace strata4 = 22 if compexp_2020>`r(p90)' & compexp_2020!=.


/* --------------------------------------------------------------------
	STRATA 5
----------------------------------------------------------------------*/	


	*** FIFTH APPROACH – ~ Manually picking


	* E-commerce adoption
	
g strat5_ecomm = 2
sum raw_digtalvars, d
replace strat5_ecomm = 3 if raw_digtalvars>=`r(p50)'
replace strat5_ecomm = 1 if raw_digtalvars==.

	* Knowledge adoption
	
g strat5_know = 2
sum raw_knowledge, d
replace strat5_know = 3 if raw_knowledge>=`r(p50)'
replace strat5_know = 1 if raw_knowledge==.

	* Mix the two into one:
	
egen sub_strata5_ind = group(strat5_know strat5_ecomm)


	* Manually check compex_2020 and exp_pays_avg
	
summ compexp_2020 if compexp_2020<500000, d
tab exp_pays_avg

	* For destination countries, break points are: 0 (2) | 1 (64) | 2-5 (114) | 6-10 (20) | 11+ (8)
	* For export revenues: top 50,000,000 | 20,000,000 | 15,000,000 |6,000,000
	* Lots between 1m and 5m

scalar c_1 = 0
scalar c_2 = 2	
scalar c_3 = 6
scalar c_4 = 11	
	
	
gen strat5_countries = 0
replace strat5_countries = 2 if exp_pays_avg>=c_1 & exp_pays_avg<c_2 & exp_pays_avg!=.
replace strat5_countries = 3 if exp_pays_avg>=c_2 & exp_pays_avg<c_3 & exp_pays_avg!=.
replace strat5_countries = 4 if exp_pays_avg>=c_3 & exp_pays_avg<c_4  & exp_pays_avg!=.

replace strat5_countries = 1 if exp_pays_avg==.

scalar e_1 = 0
scalar e_2 = 100000	
scalar e_3 = 500000
scalar e_4 = 5000000	

gen strat5_exp = 1
replace strat5_exp = 2 if compexp_2020>=e_1 & compexp_2020<e_2 & compexp_2020!=.
replace strat5_exp = 3 if compexp_2020>=e_2 & compexp_2020<e_3 & compexp_2020!=.
replace strat5_exp = 3 if compexp_2020>=e_3 & compexp_2020<e_4 & compexp_2020!=.
replace strat5_exp = 4 if compexp_2020>=e_4 & compexp_2020!=.

	* Mix the two exports into one substratum
	
g strat5_exports = 1 if strat5_exp==1 & strat5_countries==1

replace strat5_exports = 2 if strat5_exp==1 & strat5_countries==2
replace strat5_exports = 2 if strat5_exp==2 & strat5_countries==1
replace strat5_exports = 2 if strat5_exp==2 & strat5_countries==2

replace strat5_exports = 3 if strat5_exp==1 & strat5_countries==3
replace strat5_exports = 3 if strat5_exp==2 & strat5_countries==3
replace strat5_exports = 3 if strat5_exp==1 & strat5_countries==4
replace strat5_exports = 3 if strat5_exp==2 & strat5_countries==4

replace strat5_exports = 4 if strat5_exp==3 & strat5_countries==1 
replace strat5_exports = 4 if strat5_exp==3 & strat5_countries==2
replace strat5_exports = 4 if strat5_exp==4 & strat5_countries==1 
replace strat5_exports = 4 if strat5_exp==4 & strat5_countries==2

replace strat5_exports = 5 if strat5_exp==3 & strat5_countries==3
replace strat5_exports = 4 if strat5_exp==3 & strat5_countries==4
replace strat5_exports = 4 if strat5_exp==4 & strat5_countries==3
replace strat5_exports = 4 if strat5_exp==4 & strat5_countries==4

egen strata5 = group(sub_strata5_ind strat5_exports)
replace strata5 = 21 if strat5_exports==1


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
local digital_sd_base: display %9.2fc  `r(sd)'
display "For firms in our sample, the e-commmerce adoption index has a standard deviation of `r(sd)'"
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

*** EXPORT REVENUES
	
sum compexp_2020, d
display "For firms in our sample, the export revenues has a standard deviation of `r(sd)'."
local rawexports_sd_base: display %-25.2fc `r(sd)'
putdocx paragraph
putdocx text ("Export revenues"), linebreak bold
putdocx text ("For firms in our sample, the export revenues has a standard deviation of `: display %9.2fc `r(sd)''."), linebreak	

*** EXPORT DESTINATIONS
	
sum exp_pays_avg, d
display "For firms in our sample,  the number of export destinations has a standard deviation of `r(sd)'."
local exportcountries_sd_base: display %9.2fc  `r(sd)'
putdocx paragraph
putdocx text ("Export destinations"), linebreak bold
putdocx text ("For firms in our sample, the number of export destinations has a standard deviation of `: display %9.2fc `r(sd)''."), linebreak	

	
	*** Now for the strata

	
/* --------------------------------------------------------------------
	STRATA 1
----------------------------------------------------------------------*/	
	
putdocx paragraph
putdocx text ("Strata1: average SDs"), linebreak bold
putdocx text ("This approach creates strata for exports (above/below p75, no exports) and the joint e-commerce adoption and digital knowledge indices (above/below median); there is also a separate stratum for observations with missing values in any of the relevant variables")

	*** Knowledge 
	
bysort strata1: egen ksd_strata1 = sd(knowledge)
sum ksd_strata1, d
local s1_know : display %9.2fc  `r(sd)'
display "With these strata, the knowledge index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the knowledge index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `knowledge_sd_base' originally).")

	*** E-commerce adoption
bysort strata1: egen dsd_strata1 = sd(digtalvars)
sum dsd_strata1, d
local s1_ecomm : display %9.2fc  `r(sd)'
display "With these strata, the e-commerce adoption index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the e-commerce adoption index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `digital_sd_base' originally).")

	*** Export outcomes
bysort strata1: egen esd_strata1 = sd(expoutcomes)
sum esd_strata1, d
local s1_exp : display %9.2fc  `r(sd)'
display "With these strata, the export outcomes index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the export outcomes index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `export_sd_base' originally).")

	*** IHS EXPORTS
	
bysort strata1: egen ihsesd_strata1 = sd(ihs_exports)
sum ihsesd_strata1, d
local s1_ihse : display %9.2fc  `r(sd)'
display "With these strata, the IHS of export by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the IHS of export by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `ihsexports_sd_base' originally)."), linebreak
putdocx pagebreak

	*** EXPORT REVENUES
	
bysort strata1: egen exp_strata1 = sd(compexp_2020)
sum exp_strata1, d
local s1_erev : display %-25.2fc  `r(sd)'
display "With these strata, the export revenues by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the export revenues by stratum has an average standard deviation of `: display %-25.2fc `r(mean)'' (compared to `rawexports_sd_base' originally)."), linebreak

	*** EXPORT DESINATIONS
	
bysort strata1: egen countries_strata1 = sd(exp_pays_avg)
sum countries_strata1, d
local s1_countries : display %9.2fc  `r(sd)'
display "With these strata, the export destinations by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the export destinations by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `exportcountries_sd_base' originally)."), linebreak


putdocx paragraph
putdocx text ("Size of strata for strata1"), linebreak bold
tab2docx strata1


	
/* --------------------------------------------------------------------
	STRATA 2
----------------------------------------------------------------------*/	
	
putdocx paragraph
putdocx text ("Strata2: average SDs"), linebreak bold
putdocx text ("This approach creates strata is the same as the first, but missing values remain inside each strata category (ie they're not a separate category). Eg for exports there is a fourth substratum for observations missing export data"), linebreak

	*** Knowledge 
	
bysort strata2: egen ksd_strata2 = sd(knowledge)
sum ksd_strata2, d
local s2_know : display %9.2fc  `r(sd)'
display "With these strata, the knowledge index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the knowledge index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `knowledge_sd_base' originally).")

	*** E-commerce adoption
bysort strata2: egen dsd_strata2 = sd(digtalvars)
sum dsd_strata2, d
local s2_ecomm : display %9.2fc  `r(sd)'
display "With these strata, the e-commerce adoption index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the e-commerce adoption index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `digital_sd_base' originally).")

	*** Export outcomes
bysort strata2: egen esd_strata2 = sd(expoutcomes)
sum esd_strata2, d
local s2_exp : display %9.2fc  `r(sd)'
display "With these strata, the export outcomes index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the export outcomes index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `export_sd_base' originally).")

	*** IHS EXPORTS
	
bysort strata2: egen ihsesd_strata2 = sd(ihs_exports)
sum ihsesd_strata2, d
local s2_ihse : display %9.2fc  `r(sd)'
display "With these strata, the IHS of export by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the IHS of export by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `ihsexports_sd_base' originally)."), linebreak

putdocx paragraph
putdocx text ("Size of strata for strata2"), linebreak bold
tab2docx strata2

	*** EXPORT REVENUES
	
bysort strata2: egen exp_strata2 = sd(compexp_2020)
sum exp_strata2, d
local s2_erev : display %-25.2fc  `r(sd)'
display "With these strata, the export revenues by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the export revenues by stratum has an average standard deviation of `: display %-25.2fc `r(mean)'' (compared to `rawexports_sd_base' originally)."), linebreak

	*** EXPORT DESINATIONS
	
bysort strata2: egen countries_strata2 = sd(exp_pays_avg)
sum countries_strata2, d
local s2_countries : display %9.2fc  `r(sd)'
display "With these strata, the export destinations by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the export destinations by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `exportcountries_sd_base' originally)."), linebreak



/* --------------------------------------------------------------------
	STRATA 3
----------------------------------------------------------------------*/	
	
putdocx paragraph
putdocx text ("Strata3: average SDs"), linebreak bold
putdocx text ("This approach creates separate (above/below median) strata for both the digital knowledge and e-commerce adoption indices; exports are treated as in strata2 above, as are missing values. Two smaller categories (for missing values on exports and high responses to the indices) are merged ex post."), linebreak

	*** Knowledge 
	
bysort strata3: egen ksd_strata3 = sd(knowledge)
sum ksd_strata3, d
local s3_know : display %9.2fc  `r(sd)'
display "With these strata, the knowledge index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the knowledge index by stratum has an average standard deviation of `: display %9.2fc `r(mean)''' (compared to `knowledge_sd_base' originally).")

	*** E-commerce adoption
bysort strata3: egen dsd_strata3 = sd(digtalvars)
sum dsd_strata3, d
local s3_ecomm : display %9.2fc  `r(sd)'
display "With these strata, the e-commerce adoption index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the e-commerce adoption index by stratum has an average standard deviation of `: display %9.2fc `r(mean)''' (compared to `digital_sd_base' originally).")

	*** Export outcomes
bysort strata3: egen esd_strata3 = sd(expoutcomes)
sum esd_strata3, d
local s3_exp : display %9.2fc  `r(sd)'
display "With these strata, the export outcomes index by stratum has an average standard deviation of `: display %9.2fc `r(mean)''."
putdocx paragraph
putdocx text ("With these strata, the export outcomes index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `export_sd_base' originally).")

	*** IHS EXPORTS
	
bysort strata3: egen ihsesd_strata3 = sd(ihs_exports)
sum ihsesd_strata3, d
local s3_ihse : display %9.2fc  `r(sd)'
display "With these strata, the IHS of export by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the IHS of export by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `ihsexports_sd_base' originally)."), linebreak

putdocx paragraph
putdocx text ("Size of strata for strata3"), linebreak bold
tab2docx strata3

	*** EXPORT REVENUES
	
bysort strata3: egen exp_strata3 = sd(compexp_2020)
sum exp_strata3, d
local s3_erev : display %-25.2fc  `r(sd)'
display "With these strata, the export revenues by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the export revenues by stratum has an average standard deviation of `: display %-25.2fc `r(mean)'' (compared to `rawexports_sd_base' originally)."), linebreak

	*** EXPORT DESINATIONS
	
bysort strata3: egen countries_strata3 = sd(exp_pays_avg)
sum countries_strata3, d
local s3_countries : display %9.2fc  `r(sd)'
display "With these strata, the export destinations by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the export destinations by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `exportcountries_sd_base' originally)."), linebreak



/* --------------------------------------------------------------------
	STRATA 4
----------------------------------------------------------------------*/	
	
	
putdocx paragraph
putdocx text ("Strata4: average SDs"), linebreak bold
putdocx text ("This approach is similar to the above, but creates export strata based on the median (so above/below median, no exports, missing exports). After creating all the 15 strata, it creates two additional strata for the top 10% in terms of total revenues and total exports respectively (ignoring the other categories). The same two small categories as above are merged."), linebreak

	*** Knowledge 
	
bysort strata4: egen ksd_strata4 = sd(knowledge)
sum ksd_strata4, d
local s4_know : display %9.2fc  `r(sd)'
display "With these strata, the knowledge index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the knowledge index by stratum has an average standard deviation of `: display %9.2fc `r(mean)''' (compared to `knowledge_sd_base' originally).")

	*** E-commerce adoption
bysort strata4: egen dsd_strata4 = sd(digtalvars)
sum dsd_strata4, d
local s4_ecomm : display %9.2fc  `r(sd)'
display "With these strata, the e-commerce adoption index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the e-commerce adoption index by stratum has an average standard deviation of `: display %9.2fc `r(mean)''' (compared to `digital_sd_base' originally).")

	*** Export outcomes
bysort strata4: egen esd_strata4 = sd(expoutcomes)
sum esd_strata4, d
local s4_exp : display %9.2fc  `r(sd)'
display "With these strata, the export outcomes index by stratum has an average standard deviation of `: display %9.2fc `r(mean)''."
putdocx paragraph
putdocx text ("With these strata, the export outcomes index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `export_sd_base' originally).")

	*** IHS EXPORTS
	
bysort strata4: egen ihsesd_strata4 = sd(ihs_exports)
sum ihsesd_strata4, d
local s4_ihse : display %9.2fc  `r(sd)'
display "With these strata, the IHS of export by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the IHS of export by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `ihsexports_sd_base' originally)."), linebreak

	*** EXPORT REVENUES
	
bysort strata4: egen exp_strata4 = sd(compexp_2020)
sum exp_strata4, d
local s4_erev : display %-25.2fc  `r(sd)'
display "With these strata, the export revenues by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the export revenues by stratum has an average standard deviation of `: display %-25.2fc `r(mean)'' (compared to `rawexports_sd_base' originally)."), linebreak

	*** EXPORT DESINATIONS
	
bysort strata4: egen countries_strata4 = sd(exp_pays_avg)
sum countries_strata4, d
local s4_countries : display %9.2fc  `r(sd)'
display "With these strata, the export destinations by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the export destinations by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `exportcountries_sd_base' originally)."), linebreak

putdocx paragraph
putdocx text ("Size of strata for strata4"), linebreak bold
tab2docx strata4



/* --------------------------------------------------------------------
	STRATA 5
----------------------------------------------------------------------*/	
	
putdocx paragraph
putdocx text ("Strata5: average SDs"), linebreak bold
putdocx text ("This approach is manual: first four substrata for the knowledge and ecommerce indices are created. Then the exports are subdivided into four substrata based on the values of both total export revenue and number of destination countries (manually checking for natural breaks/groupings – for detail see bl_stratification). Then the two substrata are grouped together (using group). Finally, observations with missing values on both export measures are brought into their own stratum"), linebreak

	*** Knowledge 
	
bysort strata5: egen ksd_strata5 = sd(knowledge)
sum ksd_strata5, d
local s5_know : display %9.2fc  `r(sd)'
display "With these strata, the knowledge index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the knowledge index by stratum has an average standard deviation of `: display %9.2fc `r(mean)''' (compared to `knowledge_sd_base' originally).")

	*** E-commerce adoption
bysort strata5: egen dsd_strata5 = sd(digtalvars)
sum dsd_strata5, d
local s5_ecomm : display %9.2fc  `r(sd)'
display "With these strata, the e-commerce adoption index by stratum has an average standard deviation of `r(mean)'."
putdocx paragraph
putdocx text ("With these strata, the e-commerce adoption index by stratum has an average standard deviation of `: display %9.2fc `r(mean)''' (compared to `digital_sd_base' originally).")

	*** Export outcomes
bysort strata5: egen esd_strata5 = sd(expoutcomes)
sum esd_strata5, d
local s5_exp : display %9.2fc  `r(sd)'
display "With these strata, the export outcomes index by stratum has an average standard deviation of `: display %9.2fc `r(mean)''."
putdocx paragraph
putdocx text ("With these strata, the export outcomes index by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `export_sd_base' originally).")

	*** IHS EXPORTS
	
bysort strata5: egen ihsesd_strata5 = sd(ihs_exports)
sum ihsesd_strata5, d
local s5_ihse : display %9.2fc  `r(sd)'
display "With these strata, the IHS of export by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the IHS of export by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `ihsexports_sd_base' originally)."), linebreak

	*** EXPORT REVENUES
	
bysort strata5: egen exp_strata5 = sd(compexp_2020)
sum exp_strata5, d
local s5_erev : display %-25.2fc  `r(sd)'
display "With these strata, the export revenues by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the export revenues by stratum has an average standard deviation of `: display %-25.2fc `r(mean)'' (compared to `rawexports_sd_base' originally)."), linebreak

	*** EXPORT DESINATIONS
	
bysort strata5: egen countries_strata5 = sd(exp_pays_avg)
sum countries_strata5, d
local s5_countries : display %9.2fc  `r(sd)'
display "With these strata, the export destinations by stratum has an average standard deviation of `r(mean)' ."
putdocx paragraph
putdocx text ("With these strata, the export destinations by stratum has an average standard deviation of `: display %9.2fc `r(mean)'' (compared to `exportcountries_sd_base' originally)."), linebreak

putdocx paragraph
putdocx text ("Size of strata for strata5"), linebreak bold
tab2docx strata5
putdocx pagebreak



*** RECAPS

putdocx paragraph
putdocx text ("Recap"), linebreak bold

putdocx paragraph
putdocx text ("To recap by outcome:"), linebreak 

putdocx paragraph
putdocx text ("For the knowledge index the original SD was `knowledge_sd_base'. With stratification it is `s1_know' for approach 1; `s2_know' for approach 2; `s3_know' for approach 3; `s4_know' for approach 4;  and `s5_know' for approach 5."), linebreak 
putdocx paragraph

putdocx text ("For the ecommerce adoption index  the original SD was `digital_sd_base'. With stratification it is`s1_ecomm' for approach 1; `s2_ecomm' for approach 2; `s3_ecomm' for approach 3; `s4_ecomm' for approach 4;  and `s5_ecomm' for approach 5."), linebreak 

putdocx paragraph
putdocx text ("For the exporting index  the original SD was `export_sd_base'. With stratification it is `s1_exp' for approach 1; `s2_exp' for approach 2; `s3_exp' for approach 3; `s4_exp' for approach 4;  and `s5_exp' for approach 5."), linebreak 

putdocx paragraph
putdocx text ("For the IHS of exports the original SD was `ihsexports_sd_base' : . With stratification it is `s1_ihse' for approach 1; `s2_ihse' for approach 2; `s3_ihse' for approach 3; `s4_ihse' for approach 4;  and `s5_ihse' for approach 5."), linebreak 

putdocx paragraph
putdocx text ("For the absolute export revenus the original SD was `rawexports_sd_base'. With stratification it is `s1_erev' for approach 1; `s2_erev' for approach 2; `s3_erev' for approach 3; `s4_erev' for approach 4;  and `s5_erev' for approach 5."), linebreak 

putdocx paragraph
putdocx text ("For the number of destination countries the original SD was `exportcountries_sd_base'. With stratification it is `s1_countries' for approach 1; `s2_countries' for approach 2; `s3_countries' for approach 3; `s4_countries' for approach 4;  and `s5_countries' for approach 5."), linebreak 






putdocx save stratification.docx, replace








