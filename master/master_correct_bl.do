***********************************************************************
* 			Master correct				  
***********************************************************************
*																	  
*	PURPOSE: 	Correction of values from baseline survey
*																	  	
*																	  
*	Author:  	Fabian Scheifele							    
*	ID variable: id_platforme		  					  
*	Requires:  	ecommerce_master_inter.dta
*	Creates:	ecommerce_master_inter.dta
* 	IMPORTANT: PUT THE CONDITION "if surveyrround ==1" to all corrections to assure only this value is changed
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


*dig_presence1
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



*dig_presence2
*Id_plateforme 244 facebook exsists since 2016 and in database
replace dig_presence2=1 if id_plateforme==244 & surveyround==1

*Id_plateforme 259 never had social media
replace dig_presence2=0 if id_plateforme==259 & surveyround==1

*Id_plateforme 365 never had social media
replace dig_presence2=0 if id_plateforme==365 & surveyround==1

*Id_plateforme 581 never had social media
replace dig_presence2=0 if id_plateforme==581 & surveyround==1

*Id_plateforme 599 never had social media
replace dig_presence2=0 if id_plateforme==599 & surveyround==1

*Id_plateforme 628 never had social media
replace dig_presence2=0 if id_plateforme==628 & surveyround==1

*Id_plateforme 642 facebook exsists since 2020 and in database
replace dig_presence2=1 if id_plateforme==642 & surveyround==1

*Id_plateforme 715 facebook exsists since 2014 and in database
replace dig_presence2=1 if id_plateforme==715 & surveyround==1

*Id_plateforme 769 facebook exsists since 2013 and in database
replace dig_presence2=1 if id_plateforme==769 & surveyround==1

*Id_plateforme 909 facebook exsists and active
replace dig_presence2=1 if id_plateforme==909 & surveyround==1

*Id_plateforme 927 never had social media
replace dig_presence2=0 if id_plateforme==927 & surveyround==1

	*dig_presence3 (Marketplace presence)
	
	

	*Correct dig_marketing_lien for baseline if no website link is found on website but it is claimed in the 
	*survey
bysort id_plateforme (surveyround): gen dig_marketing_lien_check = dig_marketing_lien - dig_marketing_lien[_n-1]
	*Manually check those where dig_marketing_lien_check is non-zero 
 
*replace dig_marketing_lien=0 if id_plateforme==XXX & surveyround==1


	
	*dig_marketing_respons (Does the company have someone in charge of digital marketing)


	
	
	*dig_service_responsable (Does the company have someone in charge of online orders?)
	
	
	
	*dig_marketing_ind1 (Does the company have digital marketing objectives)
	
	
	
	*dig_service_satisfaction (Does the company measure the satisfaction of its online clients)
	
	
	
	*dig_revenues_ecom (Online sales)
	
***********************************************************************
* 	PART 2: Save
***********************************************************************	
save "${master_intermediate}/ecommerce_master_inter", replace
