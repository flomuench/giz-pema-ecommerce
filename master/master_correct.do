***********************************************************************
* 			Master correct				  
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
* 	PART 1: Baseline and registration data (surveyround=1)
***********************************************************************
*Take-up data
replace groupe = "Sfax 1" if id_plateforme==78
replace groupe = "Sidi Bouzid" if id_plateforme==82
replace groupe = "Sfax 1" if id_plateforme==107
replace groupe = "Tunis 1" if id_plateforme==346
replace groupe = "Tunis 1" if id_plateforme==356
replace groupe = "Tunis 6" if id_plateforme==360
replace groupe = "Tunis 2" if id_plateforme==376
replace groupe = "Tunis 2" if id_plateforme==424
replace groupe = "Sfax 1" if id_plateforme==825
replace groupe = "Tunis 5" if id_plateforme==846
replace groupe = "Tunis 5" if id_plateforme==890
replace groupe = "Sfax 1" if id_plateforme==956

encode groupe, gen (groupe_factor)


*firms that have not exported in the past and did not report an export value for 2020 will be assumed zero
replace compexp_2020 = 0 if compexp_2020 ==. & exp_avant21 == 0
replace exp_pays_21=0 if compexp_2020==0
replace exp_pays_21=. if exp_pays_21==-999


*Reduce variables with two equal medium levels from 4 to 3 dimensions
local vars dig_description1 dig_description2 dig_description3 
foreach var of local  vars {
	replace `var' = .5 if `var'==0.49 | `var'==0.51

}


replace dig_con6_score = 1 if dig_con6_score >0.98 & dig_con6_score<.
replace dig_presence_score =1 if dig_presence_score >0.98 & dig_presence_score<.



*Editing variable that come from digital stocktake
replace social_facebook=0 if social_facebook==.
local fb_vars facebook_likes facebook_subs facebook_reviews facebook_reviews facebook_shop
foreach var of local fb_vars {
replace `var' = 0 if social_facebook == 0
}



* br id_plateforme dig_presenceX if dig_presenceX_check>0 | dig_presenceX_check<0 
*replace dig_presence1=0 if id_plateforme==XXX & surveyround==1

*Id_plateforme 82 website was always faulty according to webarchive
replace dig_presence1=0 if id_plateforme==82 & surveyround==1

*Id_plateforme 303 no website link even on our database	
replace dig_presence1=0 if id_plateforme==303 & surveyround==1

*Id_plateforme 424 no website link even on our website
replace dig_presence1=0 if id_plateforme==424 & surveyround==1

*Id_plateforme 527 was always faulty and no archive
replace dig_presence1=0 if id_plateforme==527 & surveyround==1

*Id_plateforme 595 works fine in baseline according to archive
replace dig_presence1=1 if id_plateforme==595 & surveyround==1

*Id_plateforme 657 outdated site dosent work
replace dig_presence1=0 if id_plateforme==657 & surveyround==1



*Correct dig_marketing_lien for baseline if no website link is found on website but it is claimed in the 
*survey
bysort id_plateforme (surveyround): gen dig_marketing_lien_check = dig_marketing_lien - dig_marketing_lien[_n-1]
*Manually check those where dig_marketing_lien_check is non-zero 
 
*replace dig_marketing_lien=0 if id_plateforme==XXX & surveyround==2


***********************************************************************
* 	PART 2: Correction mid-line
***********************************************************************
*replace dig_presence1=0 if id_plateforme==XXX & surveyround==2

*Id_plateforme 85 is not working now
replace dig_presence1=0 if id_plateforme==85 & surveyround==2

*Id_plateforme 213 is not working now
replace dig_presence1=0 if id_plateforme==213 & surveyround==2

*Id_plateforme 375 works
replace dig_presence1=1 if id_plateforme==375 & surveyround==2

*Id_plateforme 427 is now a working website under https://shekaz.com

*Id_plateforme 549 works
replace dig_presence1=1 if id_plateforme==549 & surveyround==2

*Id_plateforme 644 not working website jinen.tn
replace dig_presence1=0 if id_plateforme==644 & surveyround==2

*Id_plateforme 763 undermaintenance since baseline
replace dig_presence1=0 if id_plateforme==763 & surveyround==2

*Id_plateforme 833 has fixed its website and is now running but slow

*Id_plateforme 896 does not exist (searched dully)
replace dig_presence1=0 if id_plateforme==896 & surveyround==2

*Id_plateforme 959 dosent have any links dully searched (https://www.linkedin.com/feed/update/urn:li:activity:6963407083215933441/)
replace dig_presence1=0 if id_plateforme==959 & surveyround==2

*Id_plateforme 961 never had a website
replace dig_presence1=0 if id_plateforme==961 & surveyround==2

*I have moved the code further down so we can see the changes
*Correct baseline value for dig_presence1,2 and 3 dependent on whether firm 
*has website, social media or market place. For the last one, if claimed yes and we dont have a link
*check major marketplaces for firmname (jumia etc) 
*Digital presence change--> Manually check those firms where dig_presenceX_check is not zero (hence there
*a change between baseline and mid-line, via browswing:	

bysort id_plateforme (surveyround): gen dig_presence1_check =  dig_presence1 - dig_presence1[_n-1]
bysort id_plateforme (surveyround): gen dig_presence2_check =  dig_presence2 - dig_presence2[_n-1]
bysort id_plateforme (surveyround): gen dig_presence3_check =  dig_presence3 - dig_presence3[_n-1]


*Correct dig_marketing_lien for mid-line if no website link is found on website but it is claimed in the 
*survey

*replace dig_marketing_lien=0 if id_plateforme==XXX & surveyround==2


***********************************************************************
* 	PART 3: Correction end-line
***********************************************************************

***********************************************************************
* 	PART 4: Replacing missing values with zeros where applicable
***********************************************************************
*Definition of all variables that are being used in index calculation*
local allvars dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_score dig_presence_score dig_presence3_exscore dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_payment1 dig_payment2 dig_payment3 dig_vente dig_marketing_lien dig_marketing_ind1 dig_marketing_ind2 dig_marketing_score dig_logistique_entrepot dig_logistique_retour_score dig_service_responsable dig_service_satisfaction expprep_cible expprep_norme expprep_demande exp_pays_avg exp_per dig_description1 dig_description2 dig_description3 dig_mar_res_per dig_ser_res_per exp_prep_res_per

*IMPORTANT MODIFICATION: Missing values, Don't know, refuse or needs check answers are being transformed to zeros 
*because missing values or "I don't know" in practice-related variable 
*are mostly due to the fact that the company did not get to fill out this part 
*of the survey because they were screened out for this section 
*or if they don't know whether they are having a particular business practice it is quite probable that they dont perform it


foreach var of local  allvars {
	replace `var' = 0 if `var' == .
	replace `var' = 0 if `var' == -999
	replace `var' = 0 if `var' == -888
	replace `var' = 0 if `var' == -777
	replace `var' = 0 if `var' == -1998
	replace `var' = 0 if `var' == -1776 
	replace `var' = 0 if `var' == -1554
}


save "${master_intermediate}/ecommerce_master_inter", replace
