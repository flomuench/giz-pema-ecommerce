***********************************************************************
* 			baseline generate									  	  
***********************************************************************
*																	    
*	PURPOSE: generate baseline variables				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) Sum up points of info questions
* 	2) Indices
*
*																	  															      
*	Author:  	Teo Firpo & Florian Muench & Kais Jomaa							  
*	ID variaregise: 	id_plateforme (example: 777)			  					  
*	Requires: bl_inter.dta 	  								  
*	Creates:  bl_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  Sum points in info questions 			
***********************************************************************

use "${bl_intermediate}/bl_inter", clear

g dig_con2 = 0 
replace dig_con2 = 1 if dig_con2_correct
lab var dig_con2 "Correct response to question about digital markets"

g dig_con4 = 0
replace dig_con4 = 1 if dig_con4_rech == 1
lab var dig_con4 "Correct response to question about online ads"

g dig_con6_score = 0
replace dig_con6_score = dig_con6_score + 0.33 if dig_con6_referencement_payant == 1
replace dig_con6_score = dig_con6_score + 0.33 if dig_con6_cout_par_clic == 1
replace dig_con6_score = dig_con6_score + 0.33 if dig_con6_liens_sponsorisés == 1
lab var dig_con6_score "Score on question about Google Ads"

g dig_presence_score = dig_presence1 + dig_presence2 + dig_presence3
lab var dig_presence_score "Score on question about online presence channels"

g dig_presence3_exscore = 0
replace dig_presence3_exscore = 0.125 if dig_presence3_ex1 == 1
replace dig_presence3_exscore = dig_presence3_exscore + 0.125 if dig_presence3_ex2 == 1
replace dig_presence3_exscore = dig_presence3_exscore + 0.125 if dig_presence3_ex3 == 1
replace dig_presence3_exscore = dig_presence3_exscore + 0.125 if dig_presence3_ex4 == 1
replace dig_presence3_exscore = dig_presence3_exscore + 0.125 if dig_presence3_ex5 == 1
replace dig_presence3_exscore = dig_presence3_exscore + 0.125 if dig_presence3_ex6 == 1
replace dig_presence3_exscore = dig_presence3_exscore + 0.125 if dig_presence3_ex7 == 1
replace dig_presence3_exscore = dig_presence3_exscore + 0.125 if dig_presence3_ex8 == 1
lab var dig_presence3_exscore "Score on examples of digital channels used"

g digmark1 = 0.2 if dig_marketing_num19_sea == 1 | dig_marketing_num19_seo == 1

g digmark2 = 0.1 if dig_marketing_num19_blg == 1 | dig_marketing_num19_mail == 1 | dig_marketing_num19_socm == 1 | dig_marketing_num19_autre == 1 

g digmark3 = 0.15 if dig_marketing_num19_pub == 1 |  dig_marketing_num19_prtn == 1 

g dig_marketing_score = cond(missing(digmark1), 0, digmark1) + cond(missing(digmark2), 0, digmark2) + cond(missing(digmark3), 0, digmark3)

lab var dig_marketing_score "Score on question about digital marketing activities"

drop digmark1 digmark2 digmark3

g dig_logistique_retour_score = 0
replace dig_logistique_retour_score = 1 if dig_logistique_retour_natetr == 1
replace dig_logistique_retour_score = 0.5 if dig_logistique_retour_nat == 1 | dig_logistique_retour_etr == 1

replace expprep_cible = 0.5 if expprep_cible==-1200


**********************************************************************
* 	PART 2:  Additional variables
***********************************************************************

	*** Calculate export revenues, digital revenues and profits as percentage of total revenues
	
g exp_per = compexp_2020/comp_ca2020
lab var exp_per "Export revenues as percentage of total revenues"

replace exp_per = -999 if compexp_2020==-999 | comp_ca2020==-999
replace exp_per = -888 if compexp_2020==-888 | comp_ca2020==-888
replace exp_per = -777 if compexp_2020==-777 | comp_ca2020==-777
replace exp_per = . if compexp_2020==. | comp_ca2020==.


g dig_rev_per = dig_revenues_ecom/comp_ca2020
lab var dig_rev_per "Digital revenus as percentage of total revenues"

replace dig_rev_per = -999 if dig_revenues_ecom==-999 | comp_ca2020==-999
replace dig_rev_per = -888 if dig_revenues_ecom==-888 | comp_ca2020==-888
replace dig_rev_per = -777 if dig_revenues_ecom==-777 | comp_ca2020==-777
replace dig_rev_per = . if dig_revenues_ecom==. | comp_ca2020==.


g profits_per = comp_benefice2020/comp_ca2020
lab var profits_per "Profits as percentage of total revenues"

replace profits_per = -999 if comp_benefice2020==-999 | comp_ca2020==-999
replace profits_per = -888 if comp_benefice2020==-888 | comp_ca2020==-888
replace profits_per = -777 if comp_benefice2020==-777 | comp_ca2020==-777
replace profits_per = . if comp_benefice2020==. | comp_ca2020==.


	*** Calculate variables as percentage of employees: 
	
g dig_mar_res_per =  dig_marketing_respons/fte
lab var dig_mar_res_per "FTEs working on digital marketing as percentage"

g dig_ser_res_per = dig_service_responsable/fte
lab var dig_ser_res_per "FTEs managing online clients as percentage"

g exp_prep_res_per = expprep_responsable/fte
lab var exp_prep_res_per "FTEs working on exports as percentage" 

	*** Bring together exp_pays_avant21 and exp_pays_21
	
g exp_pays_avg = (exp_pays_avant21 + exp_pays_21)/2 if exp_pays_avant21!=. & exp_pays_21!=.
replace exp_pays_avg = exp_pays_avant21 if exp_pays_21==. & exp_pays_avant21!=.
replace exp_pays_avg = exp_pays_21 if exp_pays_avant21==. & exp_pays_21!=.


	*** Winsorise main accounting variables
	
	* Total revenues is winsorised at 99percentile (only top)
	
winsor comp_ca2020, gen(w_compca) p(0.01) highonly

	* Profits is winsorised at 99percentile (top and bottom)
	
winsor comp_benefice2020, gen(w_compbe) p(0.01)

	* Exports is winsorised at 99percentile (only top)
	
winsor compexp_2020, gen(w_compexp) p(0.01) highonly

	* Digital revenues is winsorised at 99percentile (only top)
	
winsor dig_revenues_ecom, gen(w_compdrev) p(0.01) highonly


	*** Calculate inverse hyperbolic sine of revenues, profits and exports

gen ihs_ca = log(w_compca + sqrt((w_compca*w_compca)+1))
lab var ihs_ca "IHS of revenues"

gen ihs_profits = log(w_compbe + sqrt((w_compbe*w_compbe)+1))
lab var ihs_profits "IHS of profits"

gen ihs_exports = log(w_compexp + sqrt((w_compexp*w_compexp)+1))
lab var ihs_exports "IHS of exports"

gen ihs_digrevenue = log(w_compdrev + sqrt((w_compdrev*w_compdrev)+1))
lab var ihs_digrevenue "IHS of digital revenues"


 
**********************************************************************
* 	PART 3:  Index calculation based on z-score		
***********************************************************************
/*
calculation of indeces is based on Kling et al. 2007 and adopted from Mckenzie et al. 2018
JDE pre-analysis publication:
1: calculate z-score for each individual outcome
2: average the z-score of all individual outcomes --> this is the index value
	--> implies: no absolute evaluation but relative to all other firms
	--> requires: firms w/o missing values
3: average the three index values to get the QI index for firms
	--> implies: same weight for all three dimensions
*/

/* --------------------------------------------------------------------
	PART 3.1: Prepare all variables that go into indices
----------------------------------------------------------------------*/

*Definition of all variables that are being used in index calculation*
local allvars dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_score dig_presence_score dig_presence3_exscore dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_payment1 dig_payment2 dig_payment3 dig_vente dig_marketing_lien dig_marketing_ind1 dig_marketing_ind2 dig_marketing_score dig_logistique_entrepot dig_logistique_retour_score dig_service_responsable dig_service_satisfaction expprep_cible expprep_norme expprep_demande exp_pays_all exp_per dig_description1 dig_description2 dig_description3 dig_mar_res_per dig_ser_res_per exp_prep_res_per

*IMPORTANT MODIFICATION: Missing values, Don't know, refuse or needs check answers are being transformed to zeros*
* Create temp variables where missing values etc are replaced by 0s
foreach var of local  allvars {
	g temp_`var' = `var'
	replace temp_`var' = 0 if `var' == .
	replace temp_`var' = 0 if `var' == -999
	replace temp_`var' = 0 if `var' == -888
	replace temp_`var' = 0 if `var' == -777
	replace temp_`var' = 0 if `var' == -1998
	replace temp_`var' = 0 if `var' == -1776 
	replace temp_`var' = 0 if `var' == -1554
	
}

// This one's too long (32 chars) which prevents next section: 

rename temp_dig_logistique_retour_score t_dig_logistique_retour_score

/* --------------------------------------------------------------------
	PART 3.2: Calculate z-scores for each variables
----------------------------------------------------------------------*/

	* calculate z-score for each individual outcome
	* write a program calculates the z-score
	* capture program drop zscore
	
program define zscore /* opens a program called zscore */
	sum `1'
	gen `1'z = (`1' - r(mean))/r(sd)   /* new variable gen is called --> varnamez */
end

	* calculate z score for all variables that are part of the index

local knowledge temp_dig_con1 temp_dig_con2 temp_dig_con3 temp_dig_con4 temp_dig_con5 temp_dig_con6_score
local digtalvars temp_dig_presence_score temp_dig_presence3_exscore temp_dig_miseajour1 temp_dig_miseajour2 temp_dig_miseajour3 temp_dig_payment1 temp_dig_payment2 temp_dig_payment3 temp_dig_vente temp_dig_marketing_lien temp_dig_marketing_ind1 temp_dig_marketing_ind2 temp_dig_marketing_score temp_dig_logistique_entrepot t_dig_logistique_retour_score temp_dig_service_satisfaction temp_dig_description1 temp_dig_description2 temp_dig_description3 temp_dig_mar_res_per temp_dig_ser_res_per 
local expprep temp_expprep_cible temp_expprep_norme temp_expprep_demande temp_exp_prep_res_per
local exportcomes temp_exp_pays_all temp_exp_per

foreach z in knowledge digtalvars expprep exportcomes {
	foreach x of local `z'  {
			zscore `x' 
		}
}	

/* --------------------------------------------------------------------
	PART 3.3: Calculate the index value: average of zscores 
----------------------------------------------------------------------*/

egen knowledge = rowmean(temp_dig_con1z temp_dig_con2z temp_dig_con3z temp_dig_con4z temp_dig_con5z temp_dig_con6_scorez)
egen digtalvars = rowmean(temp_dig_presence_scorez temp_dig_presence3_exscorez temp_dig_miseajour1z temp_dig_miseajour2z temp_dig_miseajour3z temp_dig_payment1z temp_dig_payment2z temp_dig_payment3z temp_dig_ventez temp_dig_marketing_lienz temp_dig_marketing_ind1z temp_dig_marketing_ind2z temp_dig_marketing_scorez temp_dig_logistique_entrepotz t_dig_logistique_retour_score temp_dig_service_satisfactionz temp_dig_description1z temp_dig_description2z temp_dig_description3z temp_dig_mar_res_perz temp_dig_ser_res_perz)
egen expprep = rowmean(temp_expprep_ciblez temp_expprep_normez temp_expprep_demandez temp_exp_prep_res_perz)
egen expoutcomes = rowmean(temp_exp_pays_allz temp_exp_perz)

lab var knowledge "Index for digitalisation knowledge"
label var digtalvars   "Index digitalisation"
label var expprep "Index export preparation"
label var expoutcomes "Index export outcomes"


//drop scalar_issue


**************************************************************************
* 	PART 4: Create sum of scores of indices (not zscores) for comparison		  										  
**************************************************************************

egen raw_knowledge = rowtotal(`knowledge')

egen raw_digtalvars = rowtotal(`digtalvars')

egen raw_expprep = rowtotal(`expprep')

egen raw_expoutcomes = rowmean(`exportcomes')

label var raw_knowledge   "Raw index knowledge of digitalisation"
label var raw_digtalvars   "Raw index digitalisation"
label var raw_expprep "Raw index export preparation"
label var raw_expoutcomes "Raw index export outcomes"


// drop all temp vars:

drop temp_dig_con1z temp_dig_con2z temp_dig_con3z temp_dig_con4z temp_dig_con5z temp_dig_con6_scorez temp_dig_presence_scorez temp_dig_presence3_exscorez temp_dig_miseajour1z temp_dig_miseajour2z temp_dig_miseajour3z temp_dig_payment1z temp_dig_payment2z temp_dig_payment3z temp_dig_ventez temp_dig_marketing_lienz temp_dig_marketing_ind1z temp_dig_marketing_ind2z temp_dig_marketing_scorez temp_dig_logistique_entrepotz t_dig_logistique_retour_score temp_dig_service_satisfactionz temp_dig_description1z temp_dig_description2z temp_dig_description3z temp_dig_mar_res_perz temp_dig_ser_res_perz temp_expprep_ciblez temp_expprep_normez temp_expprep_demandez temp_exp_prep_res_perz temp_exp_pays_allz temp_exp_perz

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************


	* save dta file
cd "$bl_intermediate"
save "bl_inter", replace
