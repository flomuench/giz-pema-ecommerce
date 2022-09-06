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
*	Creates:	ecommerce_master_final.dta

										  

use "${master_intermediate}/ecommerce_master_inter", clear

***********************************************************************
* 	PART 1: Baseline and take-up statistics
***********************************************************************

***********************************************************************
*PART 1.1. Generate new variables or change variables create from bl_generate
***********************************************************************	
*Since most firms have at most zero, one or two FTE and online orders 
*we use a binary indicator instead of continous or share of FTE, which sometimes
*leads to absurd, difficult to compare figures (small firms have 5/6 employees working on it, others 1/180)

gen dig_service_responsable_bin = 0
replace dig_service_responsable_bin= 1 if dig_service_responsable>0 & dig_service_responsable<.
lab var dig_service_responsable_bin "Firms has digital marketing employee (1) or not(0)"

gen dig_marketing_respons_bin = 0
replace dig_marketing_respons_bin = 1 if dig_marketing_respons>0 & dig_marketing_respons<.
lab var dig_service_responsable_bin "Firms has employee dealing with online orders"

gen expprep_responsable_bin = 0
replace expprep_responsable_bin =1 if expprep_responsable>0 & expprep_responsable_bin<.
lab var expprep_responsable_bin "Firm has employee dealing with exports"

*generate sector dummies as ordinal/categorical variable has no meaning
gen agri=0
replace agri=1 if sector==1
gen artisanat=0
replace artisanat=1 if sector==2
gen commerce_int=0
replace commerce_int=1 if sector==3
gen industrie=0
replace industrie=1 if sector==4
gen service=0
replace service=1 if sector==5
gen tic=0
replace tic=1 if sector==6

lab var agri "dummy for sector=1"
lab var artisanat "dummy for sector=2"
lab var commerce_int "dummy for sector=3"
lab var industrie "dummy for sector=4"
lab var service "dummy for sector=5"
lab var tic "dummy for sector=6"

*regenerate IHS exports after slight modification of underlying variable
drop ihs_exports w_compexp
winsor compexp_2020, gen(w_compexp) p(0.01) highonly
gen ihs_exports = log(w_compexp + sqrt((w_compexp*w_compexp)+1))
lab var ihs_exports "IHS of exports in 2002"


*create final export status variable and delete other to avoid confusion
gen exporter2020=.
replace exporter2020=1 if compexp_2020 >0 & compexp_2020<. 
replace exporter2020=0 if compexp_2020 == 0 
lab var exporter2020 "dummy if company exported in the year 2020"

gen ever_exported=0
replace ever_exported=1 if compexp_2020>0 & compexp_2020<. 
replace ever_exported=1 if exp_avant21==1
replace ever_exported=1 if export2021=="oui" | export2020=="oui" | export2019 =="oui" | export2018=="oui" |export2017=="oui"
replace ever_exported=0 if exp_avant21==0
lab var ever_exported "dummy if company has exported some time in the past 5 years"
drop export2* export_status rg_expstatus expstatus* exp_avant21

*generate domestic revenue from total revenue and exports
gen dom_rev2020= comp_ca2020-compexp_2020
lab var dom_rev2020 "Domestic revenue 2020"
winsor dom_rev2020, gen(w_dom_rev2020) p(0.01) highonly
ihstrans w_dom_rev2020


***********************************************************************
*PART 1.2. Recreate z-scores with control mean and control SD 
*(in BL was done with overall mean/SD)
***********************************************************************	
capture program drop zscore
program define zscore /* opens a program called zscore */
	sum `1' if treatment == 0 
	gen `1'z = (`1' - r(mean))/r(sd)   /* new variable gen is called --> varnamez */
end

*create program that calculate z-score conditional on value in other variable
capture program drop zscorecond
program define zscorecond /* opens a program called zscore */
	sum `1' if treatment == 0 & `2'>0 & `2'<.
	gen `1'z = (`1' - r(mean))/r(sd) if `2'>0 & `2'<.
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

	* Creation of the weighted e-commerce presence index without penalizing non-existant channels 
*web index
zscorecond dig_miseajour1 dig_presence1
zscorecond dig_description1 dig_presence1
zscorecond dig_payment1 dig_presence1
egen webindexz = rowmean (dig_miseajour1z dig_description1z dig_payment1z)

*alternative method: first summing up raw poitns and then taking zscore
/*egen webindex1 = rowtotal (dig_miseajour1 dig_description1 dig_payment1) ///
 if dig_presence1>0 & dig_presence1<.
zscore webindex1
*/

*social media index
zscorecond dig_miseajour2 dig_presence2
zscorecond dig_description2 dig_presence2
zscorecond dig_payment2 dig_presence2

egen social_media_indexz = rowmean (dig_miseajour2z dig_description2z dig_payment2z)

*platform index
zscorecond dig_miseajour3 dig_presence3
zscorecond dig_description3 dig_presence3
zscorecond dig_payment3 dig_presence3
zscorecond dig_presence3_exscore dig_presence3
egen platform_indexz = rowmean (dig_miseajour3z dig_description3z ///
dig_payment3z dig_presence3_exscorez)

*CREATE WEIGHTED INDEX THAT ALSO RECOGNIZES DIVERSITY OF CHANNELS AND existing sales
egen max_presencez = rowmax(webindexz social_media_indexz platform_indexz)
egen min_presencez = rowmin(webindexz social_media_indexz platform_indexz)
gen mid_presencez = webindexz+social_media_indexz+platform_indexz-max_presencez-min_presencez

gen presence_index_weighted= 0.5*max_presencez + 0.3*mid_presencez+ 0.2*min_presencez ///
if dig_presence_score==1
replace presence_index_weighted=0.7*max_presence +0.3*min_presencez ///
if dig_presence_score>0.65 & dig_presence_score<0.67 
replace presence_index_weighted=max_presence if dig_presence_score>0.32 & dig_presence_score<0.34

*add up 0.2 for channel diversity (0.2 max for three channels, max. 1/5 SD)
replace presence_index_weighted = presence_index_weighted+0.2*dig_presence_score


*other indices
local knowledge dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_score
local dig_marketing_index dig_marketing_lien dig_marketing_ind1 dig_marketing_ind2 ///
		dig_marketing_score dig_service_satisfaction dig_service_responsable_bin dig_marketing_respons_bin 
local expprep expprep_cible expprep_norme expprep_demande expprep_responsable_bin
local dig_presence dig_presence1 dig_presence2 dig_presence3

foreach z in knowledge digtalvars expprep exportcomes {
	foreach x of local `z'  {
			zscore `x' 
		}
}	

*drop indices defined in bl_generate
drop knowledge digtalvars expprep expoutcomes 
*Calculate the index value: average of zscores 
egen knowledge = rowmean(dig_con1z dig_con2z dig_con3z dig_con4z dig_con5z dig_con6_scorez)
egen dig_marketing_index = rowmean (dig_marketing_lienz dig_marketing_ind1z ///
		dig_marketing_ind2z dig_marketing_scorez dig_service_satisfactionz dig_service_responsable_binz ///
		dig_marketing_respons_binz)
egen expprep = rowmean(expprep_ciblez expprep_normez expprep_demandez expprep_responsable_binz)


*drop temporary variables*
*drop web_index	social_media_index	platform_index max_presence min_presence mid_presence



***********************************************************************
*PART 1.3. Create alternative % -index (%of maximum points possible)
***********************************************************************	
*knowledge
egen knowledge_share=rowtotal(dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_score)
replace knowledge_share=knowledge_share/6
egen web_share=rowtotal(dig_miseajour1 dig_description1 dig_payment1)
replace web_share=web_share/3
egen social_m_share=rowtotal(dig_miseajour2 dig_description2 dig_payment2)
replace social_m_share=social_m_share/3
egen platform_share=rowtotal(dig_presence3_exscore dig_miseajour3 dig_description3 dig_payment3)
replace platform_share=platform_share/4
egen dig_marketing_share=rowtotal(dig_marketing_lien dig_marketing_ind1 ///
		dig_marketing_ind2 dig_marketing_score dig_service_satisfaction dig_service_responsable_bin ///
		dig_marketing_respons_bin)
replace dig_marketing_share	= dig_marketing_share/7
egen dig_logistic_share=rowtotal(dig_logistique_entrepot dig_logistique_retour_score)
replace dig_logistic_share = dig_logistic_share/ 2

***********************************************************************
*PART 1.4. Additional indicators from social media baseline stocktaking
***********************************************************************	
*Winsorizing and IHS transformation of likes and followers data
local sm_data facebook_likes facebook_subs facebook_reviews
foreach var of local sm_data{
winsor `var', gen(w_`var') p(0.01) highonly
ihstrans w_`var'
}
*no winsorizing needed for this one
ihstrans insta_subs

lab var ihs_w_facebook_likes "no. of FB likes, winsorized 99th and IHS transformed"
lab var ihs_w_facebook_sub "no. of FB followers, winsorized 99th and IHS transformed"
lab var ihs_w_facebook_reviews "no. of FB reviews, winsorized 99th and IHS transformed"
lab var ihs_insta_subs "no. of instagram followers, IHS transformed"

***********************************************************************
*PART 1.4. Take-up data
***********************************************************************	
*create simplified group variable (tunis vs. non-tunis)
gen groupe2 = 0
replace groupe2 = 1 if groupe == "Tunis 1" |groupe == "Tunis 2"| groupe == "Tunis 3" | groupe == "Tunis 4" | groupe == "Tunis 5" | groupe == "Tunis 6"

***********************************************************************
*PART 1.5. Label new variables
***********************************************************************
lab var knowledge "Z-score index for e-commerce knowledge"
lab var knowledge_share "% of knowledge questions answered correctly"
label var digtalvars   "Index of all e-commerce and dig marketing activities"
lab var dig_vitrine_index "Z-score index relating to quantity and quality of online presence"
lab var dig_marketing_index "Z-score index onquantity and quality of digital marketing activities"
lab var dig_marketing_share "Share of digital marketing practices"
lab var dig_logistic_index "Z-score index on logistics and return possibilites"
label var expprep "Z-score index export preparation"
label var expoutcomes "Index export outcomes"
label var dig_presence_weightedz "Weighted e-commerce presence index (z-score)"
lab var web_indexz "Z-score index of web presence"
lab var web_share "Web presence score in %"
lab var social_media_indexz "Z-score index of social media presence"
lab var social_m_share "Social media presence score in %"
lab var platform_indexz "Z-score index of platform presence"
lab var platform_share "Platform presence score in %"
lab var dig_logistic_share "Logistic and return score in %"
lab var groupe2 "Classroom training in Tunis(1) or outside(0)"

save "${master_intermediate}/ecommerce_master_final", replace
