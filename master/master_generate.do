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
/*generate take up variable
gen take_up = (present>2 & present<.), a(present)
lab var take_up "1 if company was present in 3/5 trainings"
label define treated 0 "not present" 1 "present"
label value take_up treated
*/
gen take_up2= 0
replace take_up2 = 1 if take_up_for1== 1| take_up_for2== 1| take_up_for3== 1| take_up_for4== 1| take_up_for5== 1
lab var take_up2 "1 if present in at least one training"
label value take_up2 treated

* to check
*br id_plateforme surveyround treatment present take_up take_up2

*extent treatment status to additional surveyrounds
bysort id_plateforme (surveyround): replace treatment = treatment[_n-1] if treatment == . 
bysort id_plateforme (surveyround): replace take_up_for_per = take_up_for_per[_n-1] if take_up_for_per == 0

*replace take_up=0 if take_up==. 
local take_up take_up2 take_up_for_per take_up_for take_up_for1 take_up_for2 take_up_for3 take_up_for4 take_up_for5 take_up_std take_up_seo take_up_smo take_up_smads take_up_website take_up_heber
foreach var of local take_up{
bysort id_plateforme (surveyround): replace `var' = `var'[_n-1] if `var' == .
}
*take up 4/5 workshops
gen take_up4 = 0
replace take_up4 = 1 if take_up_for1== 1 & take_up_for2== 1 & take_up_for3== 1 & take_up_for4== 1

*take up 5/5 workshops
gen take_up5 = 0
replace take_up5 = 1 if take_up_for1== 1 & take_up_for2== 1 & take_up_for3== 1 & take_up_for4== 1 & take_up_for5== 1

*replace take_up2=0 if take_up2==. 

*take_up_sm qui est = 1 si soit take_up_seo ou take_up_smads or take_up_smo = 1
gen take_up_sm = 0
lab var take_up_sm "Presence in one social media activity"

replace take_up_sm = 1 if (take_up_seo == 1 | take_up_smo == 1 | take_up_smads == 1)


*gen take_up_web_sm qui est = 1 si take_up_sm == 1 | take_up_website == 1
gen take_up_web_sm = 0
lab var take_up_web_sm "Presence in one social media activity OR website activity"

replace take_up_web_sm = 1 if (take_up_sm == 1 | take_up_website == 1)

*gen take_up  take_up_for == 1 & (take_up_sm == 1 | take_up_website == 1)
gen take_up = 0
lab var take_up "Presence in 3/5 workshops & 1 digital activity (Web/Social media)"

replace take_up = 1 if take_up_for == 1 & take_up_web_sm == 1

*3/5 workshops & sm
gen take_up_wsm = 0
replace take_up_wsm = 1 if take_up_for == 1 & take_up_sm == 1

lab var take_up_wsm "Presence in 3/5 workshops & social media activity"

*3/5 workshops & website
gen take_up_wws = 0
replace take_up_wws = 1 if take_up_for == 1 & take_up_website == 1

lab var take_up_wws "Presence in 3/5 workshops & web site activity"


*gen take_up_full
gen take_up_full = 0
replace take_up_full = 1 if (take_up_seo == 1 & take_up_smo == 1 & take_up_smads == 1 &  take_up_website == 1)
lab var take_up_full "Participated in each activity"

gen take_up_partial = 0
replace take_up_partial = 1 if (take_up_seo == 1 | take_up_smo == 1 | take_up_smads == 1 |  take_up_website == 1)
lab var take_up_partial "Participated in at least one activity"
lab def take_up_par 1 "participated" 0 "absent"	
lab values take_up_partial take_up_par

/*create simplified training group variable (tunis vs. non-tunis)
gen groupe2 = 0
replace groupe2 = 1 if groupe == "Tunis 1" |groupe == "Tunis 2"| groupe == "Tunis 3" | groupe == "Tunis 4" | groupe == "Tunis 5" | groupe == "Tunis 6"
lab var groupe2 "Classroom training in Tunis(1) or outside(0)"
*/
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
winsor compexp_2020, gen(w99_compexp2020) p(0.01) highonly
winsor compexp_2020, gen(w97_compexp2020) p(0.03) highonly
winsor compexp_2020, gen(w95_compexp2020) p(0.05) highonly

gen ihs_exports99_2020 = log(w99_compexp2020 + sqrt((w99_compexp2020*w99_compexp2020)+1))
lab var ihs_exports99_2020 "IHS of exports in 2020, wins.99th"
gen ihs_exports97_2020 = log(w97_compexp2020 + sqrt((w97_compexp2020*w97_compexp2020)+1))
lab var ihs_exports97_2020 "IHS of exports in 2020, wins.97th"
gen ihs_exports95_2020 = log(w95_compexp2020 + sqrt((w95_compexp2020*w95_compexp2020)+1))
lab var ihs_exports95_2020 "IHS of exports in 2020, wins.95th"

*generate domestic revenue from total revenue and exports
gen dom_rev2020= comp_ca2020-compexp_2020
lab var dom_rev2020 "Domestic revenue 2020"
winsor dom_rev2020, gen(w_dom_rev2020) p(0.01) highonly
ihstrans w_dom_rev2020

*re-generate total revenue with additional winsors

winsor comp_ca2020, gen(w99_comp_ca2020) p(0.01) highonly
winsor comp_ca2020, gen(w97_comp_ca2020) p(0.03) highonly
winsor comp_ca2020, gen(w95_comp_ca2020) p(0.05) highonly

gen ihs_ca99_2020 = log(w99_comp_ca2020 + sqrt((w99_comp_ca2020*w99_comp_ca2020)+1))
lab var ihs_ca99_2020 "IHS of revenue in 2020, wins.99th"
gen ihs_ca97_2020 = log(w97_comp_ca2020 + sqrt((w97_comp_ca2020*w97_comp_ca2020)+1))
lab var ihs_ca97_2020 "IHS of revenue in 2020, wins.97th"
gen ihs_ca95_2020 = log(w95_comp_ca2020 + sqrt((w95_comp_ca2020*w95_comp_ca2020)+1))
lab var ihs_ca95_2020 "IHS of revenue in 2020, wins.95th"


* digital revenues
winsor dig_revenues_ecom, gen(w95_dig_rev20) p(0.05) highonly
ihstrans w95_dig_rev20
winsor dig_revenues_ecom, gen(w97_dig_rev20) p(0.03) highonly
ihstrans w97_dig_rev20
winsor dig_revenues_ecom, gen(w99_dig_rev20) p(0.01) highonly
ihstrans w99_dig_rev20

*re-generate total profit with additional winsors

winsor comp_benefice2020, gen(w99_comp_benefice2020) p(0.01) highonly
winsor comp_benefice2020, gen(w97_comp_benefice2020) p(0.03) highonly
winsor comp_benefice2020, gen(w95_comp_benefice2020) p(0.05) highonly

gen ihs_profit_2020_99 = log(w99_comp_benefice2020 + sqrt((w99_comp_benefice2020*w99_comp_benefice2020)+1))
lab var ihs_profit_2020_99 "IHS of profit in 2020, wins.99th"
gen ihs_profit_2020_97 = log(w97_comp_benefice2020 + sqrt((w97_comp_benefice2020*w97_comp_benefice2020)+1))
lab var ihs_profit_2020_97 "IHS of profit in 2020, wins.97th"
gen ihs_profit_2020_95 = log(w95_comp_benefice2020 + sqrt((w95_comp_benefice2020*w95_comp_benefice2020)+1))
lab var ihs_profit_2020_95 "IHS of profit in 2020, wins.95th"

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
replace dig_presence_weightedz=0.7*max_presencez +0.3*min_presencez ///
if dig_presence_score>0.65 & dig_presence_score<0.67 
replace dig_presence_weightedz=max_presencez if dig_presence_score>0.32 & dig_presence_score<0.34

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

*BPI_2020
local bpi "fte comp_ca2020 comp_benefice2020"

* IMPORTANT MODIFICATION: Missing values, Don't know, refuse or needs check answers are being transformed to zeros
foreach var of local bpi {
    gen temp_`var' = `var'
    replace temp_`var' = . if `var' == 999 // don't know transformed to zeros
    replace temp_`var' = . if `var' == 888 
    replace temp_`var' = . if `var' == 777 
    replace temp_`var' = . if `var' == 666 
	replace temp_`var' = . if `var' == -999 // added - since we transformed profit into negative in endline
    replace temp_`var' = . if `var' == -888 
    replace temp_`var' = . if `var' == -777 
    replace temp_`var' = . if `var' == -666 
}

		* calcuate the z-score for each variable
foreach var of local bpi {
	sum temp_`var' if treatment == 0
	gen temp_`var'z = (`var' - r(mean))/r(sd) /* new variable gen is called --> varnamez */
}

	* calculate the index value: average of zscores
			*Digital sales index
egen bpi_2020 = rowmean(temp_ftez temp_comp_ca2020z temp_comp_benefice2020z)

drop temp_*
***********************************************************************
*PART 4.2. Export preparation index (z-score based, only BL and EL)
***********************************************************************
*egen expprep = rowmean(expprep_ciblez expprep_normez expprep_demandez expprep_responsable_binz) ///
 *if surveyround==1
*label var expprep "Z-score index export preparation"
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
lab var ihs_w_facebook_subs "no. of FB followers, winsorized 99th and IHS transformed"
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
gen el_attrit2 = .
replace el_attrit2=1 if treatment ==. 
bysort id_plateforme : mipolate el_attrit2 surveyround, gen(el_attrit) groupwise
replace el_attrit=0 if el_attrit==.
drop el_attrit2
lab var el_attrit "Not present in endline"

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


/*copy treatment, attrition status and strata to empty rows
bysort id_plateforme (surveyround): replace treatment = treatment[_n-1] if treatment == . 
bysort id_plateforme (surveyround): replace take_up = take_up[_n-1] if take_up == 0
replace take_up=0 if take_up==. 

bysort id_plateforme (surveyround): replace take_up2 = take_up2[_n-1] if take_up2 == 0
replace take_up2=0 if take_up2==. 
*/
*Completing other relevant static controls
local complet strata rg_age sector subsector rg_gender_pdg rg_gender_rep urban
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
replace status=1 if treatment==1 & take_up_for==0
replace status=2 if treatment==1 & take_up_for==1
lab var status "0= Control, 1= T-not compliant, 2=T-compliant"
label define status1 0 "Control" 1 "T-not present" 2"T-present"
label value status status1



***********************************************************************
*PART 8: Creation of index for the endline
***********************************************************************	

	* Put all variables used to calculate indices into a local
			*Digital sales index
local dsi "dig_presence1 dig_presence2 dig_presence3 dig_payment2 dig_payment3 web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand dig_miseajour1 dig_miseajour2 dig_miseajour3"
			
			*Digital marketing index
local dmi "mark_online1 mark_online2 mark_online3 mark_online4 mark_online5"
			
			*Digital Technology Perception
local dtp "investecom_benefit1 investecom_benefit2"
	
			*Export practices index
local eri "exp_pra_foire exp_pra_sci exp_pra_norme exp_pra_vent exp_pra_ach"		
			
			*Export performance index
local epi "compexp_2023 compexp_2024 export_1 export_2 exp_pays clients_b2c clients_b2b exp_dig"			
			
			
			*Business performance index
local bpi "fte comp_ca2023 comp_benefice2023 comp_ca2024 comp_benefice2024"

			*Investment variables
local invest "dig_margins dig_revenues_ecom  dig_empl dig_invest mark_invest"
local all_index `dsi' `dmi' `dtp' `eri' `epi' `bpi' `invest'

* IMPORTANT MODIFICATION: Missing values, Don't know, refuse or needs check answers are being transformed to zeros
foreach var of local all_index {
    gen temp_`var' = `var'
    replace temp_`var' = . if `var' == 999 // don't know transformed to missing values
    replace temp_`var' = . if `var' == 888 
    replace temp_`var' = . if `var' == 777 
    replace temp_`var' = . if `var' == 666 
	replace temp_`var' = . if `var' == -999 // added - since we transformed profit into negative in endline
    replace temp_`var' = . if `var' == -888 
    replace temp_`var' = . if `var' == -777 
    replace temp_`var' = . if `var' == -666 
}

		* calcuate the z-score for each variable
foreach var of local all_index {
	sum temp_`var' if treatment == 0
	gen temp_`var'z = (`var' - r(mean))/r(sd) /* new variable gen is called --> varnamez */
}

	* calculate the index value: average of zscores
			*Digital sales index
egen dsi= rowmean(temp_dig_presence1z temp_dig_presence2z temp_dig_presence3z temp_dig_payment2z temp_dig_payment3z  temp_web_use_contactsz temp_web_use_cataloguez temp_web_use_engagementz temp_web_use_comz temp_web_use_brandz temp_sm_use_contactsz temp_sm_use_cataloguez temp_sm_use_engagementz temp_sm_use_comz temp_sm_use_brandz temp_dig_miseajour1z temp_dig_miseajour2z temp_dig_miseajour3z)

			*Digital marketing index
egen dmi = rowmean(temp_mark_online1z temp_mark_online2z temp_mark_online3z temp_mark_online4z temp_mark_online5z)
			
			*Digital Technology Perception
egen dtp = rowmean(temp_investecom_benefit1z temp_investecom_benefit2z)
	
			*Digital technology adoption index
egen dtai = rowmean(dsi dmi)		
			
			*Export readiness index
egen eri = rowmean(temp_exp_pra_foirez temp_exp_pra_sciz temp_exp_pra_normez temp_exp_pra_ventz temp_exp_pra_achz)			
			
			*Export performance index
egen epi = rowmean(temp_export_1z temp_export_2z temp_exp_paysz temp_clients_b2cz temp_clients_b2bz temp_exp_digz)			
			
			*Business performance index
egen bpi_2023 = rowmean(temp_ftez temp_comp_ca2023z temp_comp_benefice2023z)
egen bpi_2024 = rowmean(temp_ftez temp_comp_ca2024z temp_comp_benefice2024z)

		* labeling
label var dsi "Digital sales index -Z Score"
label var dmi "Digital marketing index -Z Score"
label var dtp "Digital technology Perception index -Z Score"
label var dtai "Digital technology adoption index -Z Score"
label var eri "Export readiness index -Z Score"
label var epi "Export performance index -Z Score"
label var bpi_2023 "Business performance index- Z-score in 2023"
label var bpi_2024 "Business performance index- Z-score in 2024"


	* create total points per index dimension
			
			*Digital sales index
egen dsi_points= rowtotal(dig_presence1 dig_presence2 dig_presence3 dig_payment2 dig_payment3 web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand dig_miseajour1 dig_miseajour2 dig_miseajour3), missing // total 19 points
			
			*Digital marketing index
egen dmi_points= rowtotal(mark_online1 mark_online2 mark_online3 mark_online4 mark_online5), missing // total 5 points
			
			*Digital technology adoption index
egen dtai_points = rowtotal(dsi_points dmi_points), missing // total 24 points	
			
			* export readiness index (eri)
egen eri_points = rowtotal(exp_pra_foire exp_pra_sci exp_pra_norme exp_pra_vent exp_pra_ach), missing // total 5 points


		* labeling
label var dsi_points "Digital sales index points"
label var dmi_points "Digital marketing index points"
label var dtai_points "Digital technology adoption index points"
label var eri_points "Export readiness index points"



***********************************************************************
*PART 9: Transform enline variables
***********************************************************************	
*generate values for digital revenues
replace dig_revenues_ecom = ((dig_revenues_ecom*0.01)*comp_ca2023) if surveyround ==3 & dig_revenues_ecom!=99

winsor temp_dig_revenues_ecom, gen(w99_dig_revenues_ecom) p(0.01) highonly
winsor temp_dig_revenues_ecom, gen(w97_dig_revenues_ecom) p(0.03) highonly
winsor temp_dig_revenues_ecom, gen(w95_dig_revenues_ecom) p(0.05) highonly


gen ihs_digrev_99 = log(w99_dig_revenues_ecom + sqrt((w99_dig_revenues_ecom*w99_dig_revenues_ecom)+1))
lab var ihs_digrev_99 "IHS of digital revenues from ecommerce, wins.99th"

gen ihs_digrev_97 = log(w97_dig_revenues_ecom + sqrt((w97_dig_revenues_ecom*w97_dig_revenues_ecom)+1))
lab var ihs_digrev_97 "IHS of digital revenues from ecommerce, wins.97th"

gen ihs_digrev_95 = log(w95_dig_revenues_ecom + sqrt((w95_dig_revenues_ecom*w95_dig_revenues_ecom)+1))
lab var ihs_digrev_95 "IHS of digital revenues from ecommerce, wins.95th"

*Digital investment
winsor temp_dig_invest, gen(w99_dig_invest) p(0.01) highonly
winsor temp_dig_invest, gen(w97_dig_invest) p(0.03) highonly
winsor temp_dig_invest, gen(w95_dig_invest) p(0.05) highonly

gen ihs_dig_invest_99 = log(w99_dig_invest + sqrt((w99_dig_invest*w99_dig_invest)+1))
lab var ihs_dig_invest_99 "IHS of digital investment, wins.99th"
gen ihs_dig_invest_97 = log(w97_dig_invest + sqrt((w97_dig_invest*w97_dig_invest)+1))
lab var ihs_dig_invest_97 "IHS of digital investment, wins.97th"
gen ihs_dig_invest_95 = log(w95_dig_invest + sqrt((w95_dig_invest*w95_dig_invest)+1))
lab var ihs_dig_invest_95 "IHS of digital investment, wins.95th"

*Offine marketing investment
winsor temp_mark_invest, gen(w99_mark_invest) p(0.01) highonly
winsor temp_mark_invest, gen(w97_mark_invest) p(0.03) highonly
winsor temp_mark_invest, gen(w95_mark_invest) p(0.05) highonly

gen ihs_mark_invest_99 = log(w99_mark_invest + sqrt((w99_mark_invest*w99_mark_invest)+1))
lab var ihs_mark_invest_99 "IHS of offine marketing investment, wins.99th"
gen ihs_mark_invest_97 = log(w97_mark_invest + sqrt((w97_mark_invest*w97_mark_invest)+1))
lab var ihs_mark_invest_97 "IHS of offine marketing investment, wins.97th"
gen ihs_mark_invest_95 = log(w95_mark_invest + sqrt((w95_mark_invest*w95_mark_invest)+1))
lab var ihs_mark_invest_95 "IHS of offine marketing investment, wins.95th"

*Full time employees
winsor temp_fte, gen(w99_fte) p(0.01) highonly
winsor temp_fte, gen(w97_fte) p(0.03) highonly
winsor temp_fte, gen(w95_fte) p(0.05) highonly

gen ihs_fte_99 = log(w99_fte + sqrt((w99_fte*w99_fte)+1))
lab var ihs_fte_99 "IHS of full time employees, wins.99th"
gen ihs_fte_97 = log(w97_fte + sqrt((w97_fte*w97_fte)+1))
lab var ihs_fte_97 "IHS of full time employees, wins.97th"
gen ihs_fte_95 = log(w95_fte + sqrt((w95_fte*w95_fte)+1))
lab var ihs_fte_95 "IHS of full time employees, wins.95th"

*Female employees
winsor fte_femmes, gen(w99_fte_femmes) p(0.01) highonly
winsor fte_femmes, gen(w97_fte_femmes) p(0.03) highonly
winsor fte_femmes, gen(w95_fte_femmes) p(0.05) highonly

gen ihs_fte_femmes_99 = log(w99_fte_femmes + sqrt((w99_fte_femmes*w99_fte_femmes)+1))
lab var ihs_fte_femmes_99 "IHS of female employees, wins.99th"
gen ihs_fte_femmes_97 = log(w97_fte_femmes + sqrt((w97_fte_femmes*w97_fte_femmes)+1))
lab var ihs_fte_femmes_97 "IHS of female employees, wins.97th"
gen ihs_fte_femmes_95 = log(w95_fte_femmes + sqrt((w95_fte_femmes*w95_fte_femmes)+1))
lab var ihs_fte_femmes_95 "IHS of female employees, wins.95th"

*Young employees
winsor car_carempl_div2 if surveyround ==3, gen(w99_fte_young) p(0.01) highonly
winsor car_carempl_div2 if surveyround ==3, gen(w97_fte_young) p(0.03) highonly
winsor car_carempl_div2 if surveyround ==3, gen(w95_fte_young) p(0.05) highonly

gen ihs_fte_young_99 = log(w99_fte_young + sqrt((w99_fte_young*w99_fte_young)+1))
lab var ihs_fte_young_99 "IHS of young employees, wins.99th"
gen ihs_fte_young_97 = log(w97_fte_young + sqrt((w97_fte_young*w97_fte_young)+1))
lab var ihs_fte_young_97 "IHS of young employees, wins.97th"
gen ihs_fte_young_95 = log(w95_fte_young + sqrt((w95_fte_young*w95_fte_young)+1))
lab var ihs_fte_young_95 "IHS of young employees, wins.95th"

*clients_b2b
winsor clients_b2b if surveyround==3, gen(w99_clients_b2b) p(0.01)
winsor clients_b2b if surveyround==3, gen(w97_clients_b2b) p(0.03) 
winsor clients_b2b if surveyround==3, gen(w95_clients_b2b) p(0.05) 

gen ihs_clients_b2b_99 = log(w99_clients_b2b + sqrt((w99_clients_b2b*w99_clients_b2b)+1))
lab var ihs_clients_b2b_99 "IHS of number of international companies, wins.99th"
gen ihs_clients_b2b_97 = log(w97_clients_b2b + sqrt((w97_clients_b2b*w97_clients_b2b)+1))
lab var ihs_clients_b2b_97 "IHS of number of international companies, wins.97th"
gen ihs_clients_b2b_95 = log(w95_clients_b2b + sqrt((w95_clients_b2b*w95_clients_b2b)+1))
lab var ihs_clients_b2b_95 "IHS of number of international companies, wins.95th"

*dig_empl
winsor dig_empl if surveyround==3, gen(w99_dig_empl) p(0.01)
winsor dig_empl if surveyround==3, gen(w97_dig_empl) p(0.03) 
winsor dig_empl if surveyround==3, gen(w95_dig_empl) p(0.05) 

gen ihs_dig_empl_99 = log(w99_dig_empl + sqrt((w99_dig_empl*w99_dig_empl)+1))
lab var ihs_dig_empl_99 "IHS of number of digital employees, wins.99th"
gen ihs_dig_empl_97 = log(w97_dig_empl + sqrt((w97_dig_empl*w97_dig_empl)+1))
lab var ihs_dig_empl_97 "IHS of number of digital employees, wins.97th"
gen ihs_dig_empl_95 = log(w95_dig_empl + sqrt((w95_dig_empl*w95_dig_empl)+1))
lab var ihs_dig_empl_95 "IHS of number of digital employees, wins.95th"


*clients_b2c
*winsor clients_b2c if surveyround==3, gen(w99_clients_b2c) p(0.01) 
winsor clients_b2c if surveyround==3, gen(w97_clients_b2c) p(0.03) 
winsor clients_b2c if surveyround==3, gen(w95_clients_b2c) p(0.05) 

*gen ihs_clients_b2c_99 = log(w99_clients_b2c + sqrt((w99_clients_b2c*w99_clients_b2c)+1))
*lab var ihs_clients_b2c_99 "IHS of number of international orders, wins.99th"
gen ihs_clients_b2c_97 = log(w97_clients_b2c + sqrt((w97_clients_b2c*w97_clients_b2c)+1))
lab var ihs_clients_b2c_97 "IHS of number of international orders, wins.97th"
gen ihs_clients_b2c_95 = log(w95_clients_b2c + sqrt((w95_clients_b2c*w95_clients_b2c)+1))
lab var ihs_clients_b2c_95 "IHS of number of international orders, wins.95th"

*Total turnover variable
	*In 2023
winsor temp_comp_ca2023, gen(w99_comp_ca2023) p(0.01) highonly
winsor temp_comp_ca2023, gen(w97_comp_ca2023) p(0.03) highonly
winsor temp_comp_ca2023, gen(w95_comp_ca2023) p(0.05) highonly

gen ihs_ca99_2023 = log(w99_comp_ca2023 + sqrt((w99_comp_ca2023*w99_comp_ca2023)+1))
lab var ihs_ca99_2023 "IHS of total turnover in 2023, wins.99th"
gen ihs_ca97_2023 = log(w97_comp_ca2023 + sqrt((w97_comp_ca2023*w97_comp_ca2023)+1))
lab var ihs_ca97_2023 "IHS of total turnover in 2023, wins.97th"
gen ihs_ca95_2023 = log(w95_comp_ca2023 + sqrt((w95_comp_ca2023*w95_comp_ca2023)+1))
lab var ihs_ca95_2023 "IHS of total turnover in 2023, wins.95th"

	*In 2024
*winsor temp_comp_ca2024, gen(w99_comp_ca2024) p(0.01) highonly
winsor temp_comp_ca2024, gen(w97_comp_ca2024) p(0.03) highonly
winsor temp_comp_ca2024, gen(w95_comp_ca2024) p(0.05) highonly

*gen ihs_ca99_2024 = log(w99_comp_ca2024 + sqrt((w99_comp_ca2024*w99_comp_ca2024)+1))
*lab var ihs_ca99_2024 "IHS of total turnover in 2024, wins.99th"
gen ihs_ca97_2024 = log(w97_comp_ca2024 + sqrt((w97_comp_ca2024*w97_comp_ca2024)+1))
lab var ihs_ca97_2024 "IHS of total turnover in 2024, wins.97th"
gen ihs_ca95_2024 = log(w95_comp_ca2024 + sqrt((w95_comp_ca2024*w95_comp_ca2024)+1))
lab var ihs_ca95_2024 "IHS of total turnover in 2024, wins.95th"


*Export turnover variable
	*In 2023
winsor temp_compexp_2023, gen(w99_compexp2023) p(0.01) highonly
winsor temp_compexp_2023, gen(w97_compexp2023) p(0.03) highonly
winsor temp_compexp_2023, gen(w95_compexp2023) p(0.05) highonly

gen ihs_exports99_2023 = log(w99_compexp2023 + sqrt((w99_compexp2023*w99_compexp2023)+1))
lab var ihs_exports99_2023 "IHS of exports in 2023, wins.99th"
gen ihs_exports97_2023 = log(w97_compexp2023 + sqrt((w97_compexp2023*w97_compexp2023)+1))
lab var ihs_exports97_2023 "IHS of exports in 2023, wins.97th"
gen ihs_exports95_2023 = log(w95_compexp2023 + sqrt((w95_compexp2023*w95_compexp2023)+1))
lab var ihs_exports95_2023 "IHS of exports in 2023, wins.95th"

	*In 2024
*winsor temp_compexp_2024, gen(w99_compexp2024) p(0.01) highonly
winsor temp_compexp_2024, gen(w97_compexp2024) p(0.03) highonly
winsor temp_compexp_2024, gen(w95_compexp2024) p(0.05) highonly

*gen ihs_exports99_2024 = log(w99_compexp2024 + sqrt((w99_compexp2024*w99_compexp2024)+1))
*lab var ihs_exports99_2024 "IHS of exports in 2024, wins.99th"
gen ihs_exports97_2024 = log(w97_compexp2024 + sqrt((w97_compexp2024*w97_compexp2024)+1))
lab var ihs_exports97_2024 "IHS of exports in 2024, wins.97th"
gen ihs_exports95_2024 = log(w95_compexp2024 + sqrt((w95_compexp2024*w95_compexp2024)+1))
lab var ihs_exports95_2024 "IHS of exports in 2024, wins.95th"

	
*Profit variable
	*In 2023
winsor temp_comp_benefice2023, gen(w99_comp_benefice2023) p(0.01) highonly
winsor temp_comp_benefice2023, gen(w97_comp_benefice2023) p(0.03) highonly
winsor temp_comp_benefice2023, gen(w95_comp_benefice2023) p(0.05) highonly

gen ihs_profit99_2023 = log(w99_comp_benefice2023 + sqrt((w99_comp_benefice2023*w99_comp_benefice2023)+1))
lab var ihs_profit99_2023 "IHS of profit in 2023, wins.99th"
gen ihs_profit97_2023 = log(w97_comp_benefice2023 + sqrt((w97_comp_benefice2023*w97_comp_benefice2023)+1))
lab var ihs_profit97_2023 "IHS of profit in 2023, wins.97th"
gen ihs_profit95_2023 = log(w95_comp_benefice2023 + sqrt((w95_comp_benefice2023*w95_comp_benefice2023)+1))
lab var ihs_profit95_2023 "IHS of profit in 2023, wins.95th"

	*In 2024
winsor temp_comp_benefice2024, gen(w99_comp_benefice2024) p(0.01) highonly
winsor temp_comp_benefice2024, gen(w97_comp_benefice2024) p(0.03) highonly
winsor temp_comp_benefice2024, gen(w95_comp_benefice2024) p(0.05) highonly

gen ihs_profit99_2024 = log(w99_comp_benefice2024 + sqrt((w99_comp_benefice2024*w99_comp_benefice2024)+1))
lab var ihs_profit99_2024 "IHS of profit in 2024, wins.99th"
gen ihs_profit97_2024 = log(w97_comp_benefice2024 + sqrt((w97_comp_benefice2024*w97_comp_benefice2024)+1))
lab var ihs_profit97_2024 "IHS of profit in 2024, wins.97th"
gen ihs_profit95_2024 = log(w95_comp_benefice2024 + sqrt((w95_comp_benefice2024*w95_comp_benefice2024)+1))
lab var ihs_profit95_2024 "IHS of profit in 2024, wins.95th"

*Cost variable
* Generating a cost variable
*gen cost_2020 = temp_comp_ca2020 - temp_comp_benefice2020 if surveyround ==1
*lab var cost_2020 "Total costs in 2020 in TND"

gen cost_2023 = temp_comp_ca2023 - temp_comp_benefice2023 if surveyround ==3
lab var cost_2023 "Total costs in 2023 in TND"

gen cost_2024 = temp_comp_ca2024 - temp_comp_benefice2024 if surveyround ==3
lab var cost_2024 "Total costs in 2024 in TND"

*winsor cost_2020, gen(w99_cost_2020) p(0.01) highonly
*winsor cost_2020, gen(w97_cost_2020) p(0.03) highonly
*winsor cost_2020, gen(w95_cost_2020) p(0.05) highonly

*gen ihs_cost99_2020 = log(w99_cost_2020 + sqrt((w99_cost_2020*w99_cost_2020)+1))
*lab var ihs_cost99_2020 "IHS of total costs in 2020, wins.99th"
*gen ihs_cost97_2020 = log(w97_cost_2020 + sqrt((w97_cost_2020*w97_cost_2020)+1))
*lab var ihs_cost97_2020 "IHS of total costs in 2020, wins.97th"
*gen ihs_cost95_2020 = log(w95_cost_2020 + sqrt((w95_cost_2020*w95_cost_2020)+1))
*lab var ihs_cost95_2020 "IHS of total costs in 2020, wins.95th"

*winsor cost_2023, gen(w99_cost_2023) p(0.01) highonly
winsor cost_2023, gen(w97_cost_2023) p(0.03) highonly
winsor cost_2023, gen(w95_cost_2023) p(0.05) highonly

*gen ihs_cost99_2023 = log(w99_cost_2023 + sqrt((w99_cost_2023*w99_cost_2023)+1))
*lab var ihs_cost99_2023 "IHS of total costs in 2023, wins.99th"
gen ihs_cost97_2023 = log(w97_cost_2023 + sqrt((w97_cost_2023*w97_cost_2023)+1))
lab var ihs_cost97_2023 "IHS of total costs in 2023, wins.97th"
gen ihs_cost95_2023 = log(w95_cost_2023 + sqrt((w95_cost_2023*w95_cost_2023)+1))
lab var ihs_cost95_2023 "IHS of total costs in 2023, wins.95th"

*winsor cost_2024, gen(w99_cost_2024) p(0.01) highonly
winsor cost_2024, gen(w97_cost_2024) p(0.03) highonly
winsor cost_2024, gen(w95_cost_2024) p(0.05) highonly

*gen ihs_cost99_2024 = log(w99_cost_2024 + sqrt((w99_cost_2024*w99_cost_2024)+1))
*lab var ihs_cost99_2024 "IHS of total costs in 2024, wins.99th"
gen ihs_cost97_2024 = log(w97_cost_2024 + sqrt((w97_cost_2024*w97_cost_2024)+1))
lab var ihs_cost97_2024 "IHS of total costs in 2024, wins.97th"
gen ihs_cost95_2024 = log(w95_cost_2024 + sqrt((w95_cost_2024*w95_cost_2024)+1))
lab var ihs_cost95_2024 "IHS of total costs in 2024, wins.95th"


*drop temporary vars		  
drop temp_*

* gen refus variable
duplicates tag id_plateforme, gen(dup)
gen el_refus = (dup < 1)
drop dup
replace el_refus=1 if id_plateforme== 82 	
replace el_refus=1 if id_plateforme== 59
replace el_refus=1 if id_plateforme== 63
replace el_refus=1 if id_plateforme== 70
replace el_refus=1 if id_plateforme== 98
replace el_refus=1 if id_plateforme== 114
replace el_refus=1 if id_plateforme== 146
replace el_refus=1 if id_plateforme== 153
replace el_refus=1 if id_plateforme== 176
replace el_refus=1 if id_plateforme== 195
replace el_refus=1 if id_plateforme== 254
replace el_refus=1 if id_plateforme== 264
replace el_refus=1 if id_plateforme== 290
*replace el_refus=1 if id_plateforme== 261 TBC
replace el_refus=1 if id_plateforme== 495
replace el_refus=1 if id_plateforme== 586
*replace el_refus=1 if id_plateforme== 592 TBC
replace el_refus=1 if id_plateforme== 612
*replace el_refus=1 if id_plateforme== 617 TBC
replace el_refus=1 if id_plateforme== 632
replace el_refus=1 if id_plateforme== 637
replace el_refus=1 if id_plateforme== 643
replace el_refus=1 if id_plateforme== 714
replace el_refus=1 if id_plateforme== 729
replace el_refus=1 if id_plateforme== 782
replace el_refus=1 if id_plateforme== 791
replace el_refus=1 if id_plateforme== 818
replace el_refus=1 if id_plateforme== 831
replace el_refus=1 if id_plateforme== 901

*dummy variables for dig_rev & dig_invest (extensive margins)
	*dig_rev
gen dig_rev_extmargin = 1 if dig_revenues_ecom > 0 & dig_revenues_ecom != .
replace dig_rev_extmargin = . if dig_revenues_ecom == .
replace dig_rev_extmargin = 0 if dig_revenues_ecom == 0

 
lab var dig_rev_extmargin "Digital revenue > 0"

*dig_invest
gen dig_invest_extmargin = 1 if dig_invest > 0
replace dig_invest_extmargin = . if dig_invest == .
replace dig_invest_extmargin = 0 if dig_invest == 0

lab var dig_invest_extmargin "Digital invest > 0"

	*profit2023 positive
gen profit_2023_pos = 1 if comp_benefice2023 >= 0
replace profit_2023_pos = 0 if comp_benefice2023 < 0

lab var profit_2023_pos "Profit 2023 > 0"
	*profit2024 possible
gen profit_2024_pos = 1 if comp_benefice2024 >= 0
replace profit_2024_pos = 0 if comp_benefice2024 < 0

lab var profit_2024_pos "Profit 2024 > 0"

***********************************************************************
* 	PART 10:   generate survey-to-survey growth rates
***********************************************************************

*generate uniform variable names for accounting variable to do growth rates, between 2023 and 2024 values choose larger one

gen ca =. 
replace ca = comp_ca2020 if surveyround == 1
replace ca = comp_ca2023 if surveyround == 3 & !missing(comp_ca2023) 
replace ca = comp_ca2024 if surveyround == 3 & !missing(comp_ca2024) & missing(comp_ca2023)
replace ca = max(comp_ca2023, comp_ca2024) if surveyround == 3 & !missing(comp_ca2024) & !missing(comp_ca2023)
lab var ca "Chiffre d'Affaire"

gen ca_exp =. 
replace ca_exp = compexp_2020 if surveyround == 1
replace ca_exp = compexp_2023 if surveyround == 3 & !missing(compexp_2023) 
replace ca_exp = compexp_2024 if surveyround == 3 & !missing(compexp_2024) & missing(compexp_2023)
replace ca_exp = max(compexp_2023, compexp_2024) if surveyround == 3 & !missing(compexp_2024) & !missing(compexp_2023)
lab var ca_exp "Chiffre d'Affaire export"

gen profit =. 
replace profit = comp_benefice2020 if surveyround == 1
replace profit = comp_benefice2023 if surveyround == 3 & !missing(comp_benefice2023) 
replace profit = comp_benefice2024 if surveyround == 3 & !missing(comp_benefice2024) & missing(comp_benefice2023)
replace profit = max(comp_benefice2023, comp_benefice2024) if surveyround == 3 & !missing(comp_benefice2024) & !missing(comp_benefice2023)
lab var profit "Profits"
 
*female employes is called car_carempl_div1 in surveys 1 and 2 but fte_femmes in the third and car_carempl_div2 is car_carempl_dive2 during baseline

replace car_carempl_div1=fte_femmes if surveyround==3
replace car_carempl_div2=car_carempl_dive2 if surveyround==1
replace exported= exporter2020 if surveyround==1
replace exp_pays=exp_pays_21 if surveyround==1

replace ssa_action1 = exp_pra_ach if surveyround==3
replace ssa_action2 = exp_pra_sci if surveyround==3
replace ssa_action3 = exp_pra_foire if surveyround==3
replace ssa_action4 = exp_pra_vent if surveyround==3
replace ssa_action5 = 1 if surveyround==3 & inno_produit>0 & inno_produit!=.

***********************************************************************
*PART 7: Create an aggregate measure for ssa for treatment firms
***********************************************************************	
gen ssa_aggregate = .
replace ssa_aggregate =1 if ssa_action1 == 1 
replace ssa_aggregate =1 if ssa_action2 == 1 
replace ssa_aggregate =1 if ssa_action3 == 1  
replace ssa_aggregate =1 if ssa_action4 == 1 
replace ssa_aggregate =1 if ssa_action5 == 1 
lab var ssa_aggregate "The company responded yes to at least one of the ssa_actions improvements"
label define yesno1 0 "no" 1 "yes" 
label value ssa_aggregate yesno1

***********************************************************************
* 	Part 9: Final check to convert all remaining refusal codes to missing
***********************************************************************
ds, has(type numeric)
foreach var of varlist `r(varlist)' {
    replace `var' = . if inlist(`var', 666, -666, 777, -777, 888, -888,8888,999,-999)
}

***********************************************************************
* 	Part 9: Create growth variabe
***********************************************************************
// First, make sure the data is sorted by id_plateforme and surveyround
sort id_plateforme surveyround

// Loop 1: Growth rates between baseline and endline 
foreach var of varlist ca ca_exp profit fte car_carempl_div1 car_carempl_div2 {
    
    // Calculate the value for surveyround == 1 and surveyround == 3
    bys id_plateforme (surveyround): gen `var'_1 = `var' if surveyround == 1
    bys id_plateforme (surveyround): gen `var'_3 = `var' if surveyround == 3

    // Forward fill the values for surveyround == 1 and surveyround == 3 across all rows for each id
    bys id_plateforme: egen `var'_1_filled = max(`var'_1)
    bys id_plateforme: egen `var'_3_filled = max(`var'_3)

    // Calculate relative growth rate: (value in survey 3 / value in survey 1) - 1, but only for surveyround == 3
    gen `var'_rel_growth = (`var'_3_filled / `var'_1_filled) - 1 if surveyround == 3 & `var'_1_filled != . & `var'_3_filled != .

    // Calculate absolute growth: value in survey 3 - value in survey 1, but only for surveyround == 3
    gen `var'_abs_growth = `var'_3_filled - `var'_1_filled if surveyround == 3 & `var'_1_filled != . & `var'_3_filled != .

    // Clean up intermediate variables
    drop `var'_1 `var'_3
}


* Generate 'any export action' variable
egen ssa_any = rowmax(ssa_action1 ssa_action2 ssa_action3 ssa_action4 ssa_action5)
lab var ssa_any "Any of the above"
label value ssa_any yesno1

// Loop 1: Growth rates between midline and endline for GIZ indicator (ssa_action)
* only absolute rates because binary variables
foreach var of varlist ssa_action1 ssa_action2 ssa_action3 ssa_action4 ssa_action5 ssa_any {
    
    // Calculate the value for surveyround == 1 and surveyround == 3
    bys id_plateforme (surveyround): gen `var'_2 = `var' if surveyround == 2
    bys id_plateforme (surveyround): gen `var'_3 = `var' if surveyround == 3

    // Forward fill the values for surveyround == 1 and surveyround == 3 across all rows for each id
    bys id_plateforme: egen `var'_2_filled = max(`var'_2)
    bys id_plateforme: egen `var'_3_filled = max(`var'_3)

    // Calculate absolute growth: value in survey 3 - value in survey 1, but only for surveyround == 3
    gen `var'_abs_growth = `var'_3_filled - `var'_2_filled if surveyround == 3  & `var'_3_filled != .

    // Clean up intermediate variables
    drop `var'_2 `var'_3
}

*Replace Negative values with missing (firms that reported yes in midline but no in endline) to simplify improve count
foreach var of varlist ssa_action1_abs_growth ssa_action2_abs_growth ssa_action3_abs_growth ssa_action4_abs_growth ssa_action5_abs_growth ssa_any_abs_growth {
    
replace `var' = . if `var' ==-1
}
/*
use links to understand the code syntax for creating the accounting variables' growth rates:
- https://www.stata.com/statalist/archive/2008-10/msg00661.html
- https://www.stata.com/support/faqs/statistics/time-series-operators/

*/


lab var ca_rel_growth "Total sales (% growth)"
lab var ca_abs_growth "Total sales (abs. growth)"
lab var ca_exp_rel_growth "Export sales (% growth)"
lab var ca_exp_abs_growth "Export sales (abs. growth)"
lab var profit_rel_growth "Profits (% growth)"
lab var profit_abs_growth "Profits (abs. growth)"
lab var fte_rel_growth "Employees (% growth)"
lab var fte_abs_growth "Employees (abs. growth)"
lab var car_carempl_div1_rel_growth "Female Employees (% growth)"
lab var car_carempl_div1_abs_growth "Female Employees (abs. growth)"
lab var car_carempl_div2_rel_growth "Young Employees (% growth)"
lab var car_carempl_div2_abs_growth "Young Employees (abs. growth)"

lab var ssa_action1_abs_growth "Change in Buyer expression of interest"
lab var ssa_action2_abs_growth "Change in Identification commercial partner"
lab var ssa_action3_abs_growth "Change in External export finance"
lab var ssa_action4_abs_growth "Change in Investment in sales structure abroad"
lab var ssa_action5_abs_growth "Change in Digital transaction system"
label define surveyround_lab 1 "Baseline" 2 "Mid-line" 3"Endline" 
label values surveyround surveyround_lab


label define yesno2 0 "no improvement" 1 "improvement"

* Label variables
label values ssa_action1_abs_growth yesno2
label values ssa_action2_abs_growth yesno2
label values ssa_action3_abs_growth yesno2
label values ssa_action4_abs_growth yesno2
label values ssa_action5_abs_growth yesno2
label values ssa_any_abs_growth yesno2

***********************************************************************
* 	PART 10: export excel for semrush analysis
***********************************************************************
{
preserve
	keep if surveyround == 1
	merge 1:1 id_plateforme using "${master_pii}/web_information", keepusing(link_web)
		* Remove "http://", "https://", "www.", and "error codes"
	replace link_web ="" if link_web == "-666" | link_web == "-777" | link_web == "-888" | link_web == "-888"
	replace link_web = subinstr(link_web, "http://", "", .)
	replace link_web = subinstr(link_web, "https://", "", .)
	replace link_web = subinstr(link_web, "www.", "", .)
	replace link_web = trim(link_web)
	replace link_web = subinstr(link_web, " ", "", .)
	
	drop _merge
	keep id_plateforme link_web treatment take_up strata
	save "${master_pii}/semrush.dta", replace
	export excel using "${master_pii}/semrush.xlsx", firstrow(variables) replace
restore
	
}
***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
save "${master_final}/ecommerce_master_final", replace
