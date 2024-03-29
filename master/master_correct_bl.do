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

*Id_plateforme 398 no website link even on our database	
replace dig_presence1=0.33	 if id_plateforme==398 & surveyround==1

*Id_plateforme 424 no website link even on our website
replace dig_presence1=0 if id_plateforme==424 & surveyround==1

*Id_plateforme 527 was always faulty and no archive
replace dig_presence1=0 if id_plateforme==527 & surveyround==1

*Id_plateforme 595 works fine in baseline according to archive
replace dig_presence1=0.33 if id_plateforme==595 & surveyround==1

*Id_plateforme 657 outdated site dosent work
replace dig_presence1=0 if id_plateforme==657 & surveyround==1

*Id_plateforme 961 never had a website
replace dig_presence1=0 if id_plateforme==961 & surveyround==1



*dig_presence2
*Id_plateforme 244 facebook exsists since 2016 and in database
replace dig_presence2=0.33 if id_plateforme==244 & surveyround==1

*Id_plateforme 259 never had social media
replace dig_presence2=0 if id_plateforme==259 & surveyround==1

*Id_plateforme 365 never had social media
replace dig_presence2=0 if id_plateforme==365 & surveyround==1

*Id_plateforme 581 never had social media
replace dig_presence2=0 if id_plateforme==581 & surveyround==1

**Id_plateforme 597 has social media since baseline
replace dig_presence2=0.33 if id_plateforme==597 & surveyround==1

*Id_plateforme 599 never had social media
replace dig_presence2=0 if id_plateforme==599 & surveyround==1

*Id_plateforme 628 never had social media
replace dig_presence2=0 if id_plateforme==628 & surveyround==1

*Id_plateforme 642 facebook exsists since 2020 and in database
replace dig_presence2=0.33 if id_plateforme==642 & surveyround==1

*Id_plateforme 715 facebook exsists since 2014 and in database
replace dig_presence2=0.33 if id_plateforme==715 & surveyround==1

*Id_plateforme 769 facebook exsists since 2013 and in database
replace dig_presence2=0.33 if id_plateforme==769 & surveyround==1

*Id_plateforme 909 facebook exsists and active
replace dig_presence2=0.33 if id_plateforme==909 & surveyround==1

*Id_plateforme 925 has facebook
replace dig_presence2=0.33 if id_plateforme==925 & surveyround==1

*Id_plateforme 927 never had social media
replace dig_presence2=0 if id_plateforme==927 & surveyround==1




	*dig_presence3 (Marketplace presence)
*Id_plateforme 78 used to have marketplace and they dropped it

*Id_plateforme 122 is not on jumia nor on corrections of alamouri
replace dig_presence3=0 if id_plateforme==122 & surveyround==1

*Id_plateforme 303 autres marketplace cant be tracked
replace dig_presence3=0 if id_plateforme==303 & surveyround==1

*Id_plateforme 356 has no information on database and noway it was on marketplace (PARAFRIK: Claims to have Jumia, cannot find it)
replace dig_presence3=0 if id_plateforme==356 & surveyround==1

*Id_plateforme 470 no marketplace (ElAmouri)
replace dig_presence3=0 if id_plateforme==470 & surveyround==1

*Id_plateforme 478 no marketplace (ElAmouri)
replace dig_presence3=0 if id_plateforme==478 & surveyround==1

*Id_plateforme 549 not found on marketplaces (ElAmouri said bl was online form)
replace dig_presence3=0 if id_plateforme==549 & surveyround==1

*Id_plateforme 581 not found on marketplaces (ElAmouri said bl was online form)
replace dig_presence3=0 if id_plateforme==581 & surveyround==1

	*Correct dig_marketing_lien for baseline if no website link is found on website but it is claimed in the 
	*survey
bysort id_plateforme (surveyround): gen dig_marketing_lien_check = dig_marketing_lien - dig_marketing_lien[_n-1]
	
	*Correct digital presence
	
replace dig_presence3=0 if id_plateforme== 78 & surveyround==1
replace dig_description3=0 if id_plateforme== 78 & surveyround==1
replace dig_miseajour3=0 if id_plateforme== 78 & surveyround==1	

replace dig_presence3=0 if id_plateforme== 478 & surveyround==1
replace dig_description3=0 if id_plateforme== 478 & surveyround==1
replace dig_miseajour3=0 if id_plateforme== 478 & surveyround==1	

*Manually check those where dig_marketing_lien_check is non-zero 
 
*replace dig_marketing_lien=0 if id_plateforme==XXX & surveyround==1


	
	*dig_marketing_respons (Does the company have someone in charge of digital marketing)
	
replace dig_marketing_respons=0 if id_plateforme== 259 & surveyround==1
replace dig_marketing_respons=0 if id_plateforme== 265 & surveyround==1
replace dig_marketing_respons=1 if id_plateforme== 735 & surveyround==1


	
	
	*dig_service_responsable (Does the company have someone in charge of online orders?)
replace dig_service_responsable= 0 if id_plateforme== 259 & surveyround==1
replace dig_service_responsable= 1 if id_plateforme== 565 & surveyround==1
replace dig_service_responsable=1 if id_plateforme== 623 & surveyround==1
replace dig_service_responsable=1 if id_plateforme== 735 & surveyround==1
	
	
	
	*dig_marketing_ind1 (Does the company have digital marketing objectives)
replace dig_marketing_ind1=0 if id_plateforme== 259 & surveyround==1
replace dig_marketing_ind1=0 if id_plateforme== 313 & surveyround==1
replace dig_marketing_ind1=0 if id_plateforme== 478 & surveyround==1
replace dig_marketing_ind1=1 if id_plateforme== 545 & surveyround==1
replace dig_marketing_ind1=1 if id_plateforme== 587 & surveyround==1
replace dig_marketing_ind1=1 if id_plateforme== 602 & surveyround==1
replace dig_marketing_ind1=1 if id_plateforme== 623 & surveyround==1

	
	
	*dig_service_satisfaction (Does the company measure the satisfaction of its online clients)
replace dig_service_satisfaction=0 if id_plateforme== 313 & surveyround==1
replace dig_service_satisfaction=0 if id_plateforme== 541 & surveyround==1
replace dig_service_satisfaction=1 if id_plateforme== 545 & surveyround==1
replace dig_service_satisfaction=1 if id_plateforme== 623 & surveyround==1
replace dig_service_satisfaction=0 if id_plateforme== 910 & surveyround==1


	
	
	*dig_revenues_ecom (Online sales)
replace dig_revenues_ecom= 99381 if id_plateforme== 78 & surveyround==1
replace dig_revenues_ecom=0 if id_plateforme== 172 & surveyround==1
replace dig_revenues_ecom=60000 if id_plateforme== 360 & surveyround==1
replace dig_revenues_ecom= 0 if id_plateforme== 478 & surveyround==1
replace dig_revenues_ecom=60000 if id_plateforme== 505 & surveyround==1
replace dig_revenues_ecom= 0 if id_plateforme== 508 & surveyround==1
replace dig_revenues_ecom=16000 if id_plateforme== 542 & surveyround==1
replace dig_revenues_ecom= 0 if id_plateforme== 565 & surveyround==1
replace dig_revenues_ecom= 0 if id_plateforme== 767 & surveyround==1
replace dig_revenues_ecom= 0 if id_plateforme== 795 & surveyround==1
replace dig_revenues_ecom= 0 if id_plateforme== 909 & surveyround==1
replace dig_revenues_ecom= 0 if id_plateforme== 899 & surveyround==1



***********************************************************************
* 	PART 2: Save
***********************************************************************	
save "${master_intermediate}/ecommerce_master_inter", replace
