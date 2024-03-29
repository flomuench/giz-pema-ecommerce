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
*generate take up variable
gen take_up = (present>2 & present<.), a(present)
lab var take_up "1 if company was present in 3/5 trainings"
label define treated 0 "not present" 1 "present"
label value take_up treated

gen take_up2 = (present>0 & present<.), a(take_up)
lab var take_up2 "1 if present in at least one training"
label value take_up2 treated

* to check
*br id_plateforme surveyround treatment present take_up take_up2

*extent treatment status to additional surveyrounds
bysort id_plateforme (surveyround): replace treatment = treatment[_n-1] if treatment == . 
bysort id_plateforme (surveyround): replace take_up = take_up[_n-1] if take_up == 0
replace take_up=0 if take_up==. 

bysort id_plateforme (surveyround): replace take_up2 = take_up2[_n-1] if take_up2 == 0
replace take_up2=0 if take_up2==. 

*create simplified training group variable (tunis vs. non-tunis)
gen groupe2 = 0
replace groupe2 = 1 if groupe == "Tunis 1" |groupe == "Tunis 2"| groupe == "Tunis 3" | groupe == "Tunis 4" | groupe == "Tunis 5" | groupe == "Tunis 6"
lab var groupe2 "Classroom training in Tunis(1) or outside(0)"

***********************************************************************
*PART 2. Intermediate variables or change variables created in baseline
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

*Adjust score for knowledge questions in the baseline
replace dig_con6_referencement_payant = 0.33 if dig_con6_referencement_payant == 1 
replace dig_con6_cout_par_clic = 0.33 if dig_con6_cout_par_clic == 1 
replace dig_con6_cout_par_mille = -0.99 if dig_con6_cout_par_mille == 1
replace dig_con6_liens_sponsorisés = 0.33 if dig_con6_liens_sponsorisés == 1
replace dig_con5 = -1 if dig_con5 == 0 
replace dig_con5 = 0 if dig_con5 == 1 


gen dig_con6_bl = dig_con6_referencement_payant + dig_con6_cout_par_clic + dig_con6_cout_par_mille + dig_con6_liens_sponsorisés + dig_con5
replace dig_con6_bl = 1 if dig_con6_bl == .99000001
replace dig_con6_bl = 0 if dig_con6_bl == 2.980e-08
lab var dig_con6_bl "Correct answers to knowledge question on Google Analaytics" 

*Additional preparatory variables required for index generation (check bl_generate)	


***********************************************************************
*PART 3. Financial indicators
***********************************************************************	
*regenerate winsorized IHS exports after slight modification of underlying variable
*(assuming zero exports for firms that had missing value and declared to have not exported prior to 2021)
winsor compexp_2020, gen(w99_compexp) p(0.01) highonly
winsor compexp_2020, gen(w97_compexp) p(0.03) highonly
winsor compexp_2020, gen(w95_compexp) p(0.05) highonly

gen ihs_exports99 = log(w99_compexp + sqrt((w99_compexp*w99_compexp)+1))
lab var ihs_exports99 "IHS of exports in 2020, wins.99th"
gen ihs_exports97 = log(w97_compexp + sqrt((w97_compexp*w97_compexp)+1))
lab var ihs_exports97 "IHS of exports in 2020, wins.97th"
gen ihs_exports95 = log(w95_compexp + sqrt((w95_compexp*w95_compexp)+1))
lab var ihs_exports95 "IHS of exports in 2020, wins.95th"

*generate domestic revenue from total revenue and exports
gen dom_rev2020= comp_ca2020-compexp_2020
lab var dom_rev2020 "Domestic revenue 2020"
winsor dom_rev2020, gen(w_dom_rev2020) p(0.01) highonly
ihstrans w_dom_rev2020

*re-generate total revenue with additional winsors

winsor comp_ca2020, gen(w99_comp_ca2020) p(0.01) highonly
winsor comp_ca2020, gen(w97_comp_ca2020) p(0.03) highonly
winsor comp_ca2020, gen(w95_comp_ca2020) p(0.05) highonly

gen ihs_revenue99 = log(w99_comp_ca2020 + sqrt((w99_comp_ca2020*w99_comp_ca2020)+1))
lab var ihs_revenue99 "IHS of revenue in 2020, wins.99th"
gen ihs_revenue97 = log(w97_comp_ca2020 + sqrt((w97_comp_ca2020*w97_comp_ca2020)+1))
lab var ihs_revenue97 "IHS of revenue in 2020, wins.97th"
gen ihs_revenue95 = log(w95_comp_ca2020 + sqrt((w95_comp_ca2020*w95_comp_ca2020)+1))
lab var ihs_revenue95 "IHS of revenue in 2020, wins.95th"


* digital revenues
winsor dig_revenues_ecom, gen(w95_dig_rev20) p(0.05) highonly
ihstrans w95_dig_rev20
winsor dig_revenues_ecom, gen(w97_dig_rev20) p(0.03) highonly
ihstrans w97_dig_rev20
winsor dig_revenues_ecom, gen(w99_dig_rev20) p(0.01) highonly
ihstrans w99_dig_rev20

***********************************************************************
*PART 4. Index Creation
***********************************************************************	
*Recreate z-scores with control mean and control SD 
*(in BL was done with overall mean/SD)
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

***********************************************************************
*PART 4.1 E-commerce and digital marketing indices
***********************************************************************	
* Creation of the weighted e-commerce presence index without penalizing non-existant channels 
	*web index
zscorecond dig_miseajour1 dig_presence1
zscorecond dig_description1 dig_presence1
zscorecond dig_payment1 dig_presence1
egen webindexz = rowmean (dig_miseajour1z dig_description1z dig_payment1z)
lab var webindexz "Z-score index of web presence"

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
lab var social_media_indexz "Z-score index of social media presence"

	*platform index
zscorecond dig_miseajour3 dig_presence3
zscorecond dig_description3 dig_presence3
zscorecond dig_payment3 dig_presence3
zscorecond dig_presence3_exscore dig_presence3
egen platform_indexz = rowmean (dig_miseajour3z dig_description3z ///
dig_payment3z dig_presence3_exscorez)
lab var platform_indexz "Z-score index of platform presence"

	*CREATE WEIGHTED INDEX THAT ALSO RECOGNIZES DIVERSITY OF CHANNELS AND existing sales
egen max_presencez = rowmax(webindexz social_media_indexz platform_indexz)
egen min_presencez = rowmin(webindexz social_media_indexz platform_indexz)
gen mid_presencez = webindexz+social_media_indexz+platform_indexz-max_presencez-min_presencez

gen dig_presence_weightedz= 0.5*max_presencez + 0.3*mid_presencez+ 0.2*min_presencez ///
if dig_presence_score==1
replace dig_presence_weightedz=0.7*max_presence +0.3*min_presencez ///
if dig_presence_score>0.65 & dig_presence_score<0.67 
replace dig_presence_weightedz=max_presence if dig_presence_score>0.32 & dig_presence_score<0.34

	*add up 0.2 for channel diversity (0.2 max for three channels, max. 1/5 SD)
replace dig_presence_weightedz = dig_presence_weightedz+0.2*dig_presence_score
label var dig_presence_weightedz "Weighted e-commerce presence index (z-score)"

*other indices
local knowledge_bl dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_bl 
local knowledge_ml dig_con1_ml dig_con2_ml dig_con3_ml dig_con4_ml dig_con5_ml 
local dig_marketing_index dig_marketing_lien dig_marketing_ind1 dig_marketing_ind2 ///
		dig_marketing_score dig_service_satisfaction dig_service_responsable_bin dig_marketing_respons_bin 
local expprep expprep_cible expprep_norme expprep_demande expprep_responsable_bin
local dig_presence dig_presence1 dig_presence2 dig_presence3
local dig_perception_ml dig_perception1 dig_perception2 dig_perception3 dig_perception4 dig_perception5

foreach z in dig_presence knowledge_bl knowledge_ml dig_marketing_index dig_perception_ml expprep exportcomes {
	foreach x of local `z'  {
			zscore `x' 
		}
}	


*Calculate the index value: average of zscores 
egen knowledge_index_bl = rowmean(dig_con1z dig_con2z dig_con3z dig_con4z dig_con5z dig_con6_blz) ///
					if surveyround==1

egen knowledge_index_ml = rowmean(dig_con1_mlz dig_con2_mlz dig_con3_mlz dig_con4_mlz dig_con5_mlz) ///
					if surveyround==2

*join both knowledge indices under one variable
gen knowledge_index= . 
replace knowledge_index=knowledge_index_bl if surveyround==1
replace knowledge_index=knowledge_index_ml if surveyround==2					
drop knowledge_index_bl knowledge_index_ml
lab var knowledge_index "Z-score index for e-commerce/dig.marketing knowledge"				

egen perception_index_ml = rowmean(dig_perception1z dig_perception2z dig_perception3z dig_perception4z dig_perception5z) ///
					if surveyround==2



egen dig_presence_index = rowmean(dig_presence1 dig_presence2 dig_presence3) 

lab var dig_presence_index "Z-score index for digital presence (extensive margin)"


egen dig_marketing_index = rowmean (dig_marketing_lienz dig_marketing_ind1z ///
		dig_marketing_ind2z dig_marketing_scorez dig_service_satisfactionz dig_service_responsable_binz ///
		dig_marketing_respons_binz)
lab var dig_marketing_index "Z-score index onquantity and quality of digital marketing activities"



***********************************************************************
*PART 4.2. Export preparation index (z-score based, only BL and EL)
***********************************************************************
egen expprep = rowmean(expprep_ciblez expprep_normez expprep_demandez expprep_responsable_binz) ///
 if surveyround==1
label var expprep "Z-score index export preparation"
***********************************************************************
*PART 4.3. Create alternative non-normalized -index (in %of maximum points possible)
***********************************************************************	
*knowledge
drop raw_knowledge
egen raw_knowledge_bl = rowtotal(dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_bl ) if surveyround==1
egen raw_knowledge_ml = rowtotal (dig_con1_ml dig_con2_ml dig_con3_ml dig_con4_ml dig_con5_ml) if surveyround==2
gen raw_knowledge= raw_knowledge_bl if surveyround==1
replace raw_knowledge= raw_knowledge_ml if surveyround==2
drop raw_knowledge_bl raw_knowledge_ml

lab var raw_knowledge "Knowledge score (non-normalized)"

egen web_share=rowtotal(dig_miseajour1 dig_description1 dig_payment1)
replace web_share=web_share/3
lab var web_share "Web presence score in %"

egen social_m_share=rowtotal(dig_miseajour2 dig_description2 dig_payment2)
replace social_m_share=social_m_share/3
lab var social_m_share "Social media presence score in %"

egen platform_share=rowtotal(dig_presence3_exscore dig_miseajour3 dig_description3 dig_payment3)
replace platform_share=platform_share/4
lab var platform_share "Platform presence score in %"

egen dig_marketing_share=rowtotal(dig_marketing_lien dig_marketing_ind1 ///
		dig_marketing_ind2 dig_marketing_score dig_service_satisfaction dig_service_responsable_bin ///
		dig_marketing_respons_bin)
replace dig_marketing_share	= dig_marketing_share/7
lab var dig_marketing_share "Share of digital marketing practices"

egen dig_logistic_share=rowtotal(dig_logistique_entrepot dig_logistique_retour_score)
replace dig_logistic_share = dig_logistic_share/ 2
lab var dig_logistic_share "Logistics score in %"

***********************************************************************
*PART 4.4. Additional indicators from social media baseline stocktaking
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
*PART 5 Variables required for survey checks
***********************************************************************	
gen commentaires_elamouri=""
gen needs_check=0
gen questions_a_verifier=""
gen commentsmsb=""
lab var needs_check" if larger than 0, this rows needs to be checked"

***********************************************************************
*PART 6 Create empty rows of attrited firms
***********************************************************************	
*xtset id_plateforme surveyround
*tsfill, full

*generate attrition variables for baseline, midline and endline
gen ml_attrit2 = .
replace ml_attrit2=1 if treatment ==. 
bysort id_plateforme : mipolate ml_attrit2 surveyround, gen(ml_attrit) groupwise
replace ml_attrit=0 if ml_attrit==.
drop ml_attrit2
lab var ml_attrit "Not present in midline"

gen bl_attrit2 = .
replace bl_attrit2=1 if entr_bien_service ==. & surveyround==1
bysort id_plateforme : mipolate bl_attrit2 surveyround, gen(bl_attrit) groupwise
replace bl_attrit=0 if bl_attrit==.
drop bl_attrit2
lab var bl_attrit "Not present in baseline"


*copy treatment, attrition status and strata to empty rows
bysort id_plateforme (surveyround): replace treatment = treatment[_n-1] if treatment == . 
bysort id_plateforme (surveyround): replace take_up = take_up[_n-1] if take_up == 0
replace take_up=0 if take_up==. 

bysort id_plateforme (surveyround): replace take_up2 = take_up2[_n-1] if take_up2 == 0
replace take_up2=0 if take_up2==. 

*Completing other relevant static controls
local complet strata rg_age present sector subsector rg_gender_pdg rg_gender_rep urban
foreach var of local complet{
bysort id_plateforme (surveyround): replace `var' = `var'[_n-1] if `var' == .
}

*repeat for string variables
local strings district
foreach var of local strings{
bysort id_plateforme (surveyround): replace `var' = `var'[_n-1] if `var' == ""
}

*status variable for graphs
gen status=0
replace status=1 if treatment==1 & take_up==0
replace status=2 if treatment==1 & take_up==1
lab var status "0= Control, 1= T-not compliant, 2=T-compliant"
label define status1 0 "Control" 1 "T-not present" 2"T-present"
label value status status1

***********************************************************************
*PART 7: Create an aggregate measure for ssa for treatment firms
***********************************************************************	
gen ssa_aggregate = 0
replace ssa_aggregate =1 if ssa_action1 == 1 & surveyround==2 
replace ssa_aggregate =1 if ssa_action2 == 1 & surveyround==2
replace ssa_aggregate =1 if ssa_action3 == 1 & surveyround==2
replace ssa_aggregate =1 if ssa_action4 == 1 & surveyround==2
replace ssa_aggregate =1 if ssa_action5 == 1 & surveyround==2
lab var ssa_aggregate "The company responded yes to at least one of the ssa_actions improvements"
label define yesno1 0 "no" 1 "yes" 
label value ssa_aggregate yesno1



save "${master_final}/ecommerce_master_final", replace
