***********************************************************************
* 			Master correct				  
***********************************************************************
*																	  
*	PURPOSE:	Correction of values from baseline/ midline survey
*																	  
			
*																	  
*	Author:  	Fabian Scheifele							    
*	ID variable: id_platforme		  					  
*	Requires:  	ecommerce_master_inter.dta
*	Creates:	ecommerce_master_inter.dta
***********************************************************************
* 	PART 1: Baseline and registration data (surveyround=1)
***********************************************************************
use "${master_intermediate}/ecommerce_master_inter", clear

{
/*Take-up data
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
*/

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

}

***********************************************************************
* 	PART 2: Correction mid-line
***********************************************************************
{
	*dig_presence1 (does the company have a website?)
*Id_plateforme 85 is not working now
replace dig_presence1=0 if id_plateforme==85 & surveyround==2

*Id_plateforme 107 has website (www.entrust-trade.com)
replace dig_presence1=0.33 if id_plateforme==107 & surveyround==2

*Id_plateforme 213 is not working now
replace dig_presence1=0 if id_plateforme==213 & surveyround==2

*Id_plateforme 375 works
replace dig_presence1=0.33 if id_plateforme==375 & surveyround==2

*Id_plateforme 427 is now a working website under https://shekaz.com

*Id_plateforme 549 works
replace dig_presence1=0.33 if id_plateforme==549 & surveyround==2

*Id_plateforme 644 not working website jinen.tn
replace dig_presence1=0 if id_plateforme==644 & surveyround==2

*Id_plateforme 681 has a bad website (https://www.groupebismuth.com/tet/presentation.html)
replace dig_presence1=0.33 if id_plateforme==681 & surveyround==2

*Id_plateforme 763 undermaintenance since baseline
replace dig_presence1=0 if id_plateforme==763 & surveyround==2

*Id_plateforme 833 has fixed its website and is now running but slow

*Id_plateforme 873 has a working website
replace dig_presence1=0.33 if id_plateforme==873 & surveyround==2

*Id_plateforme 896 does not exist (searched dully)
replace dig_presence1=0 if id_plateforme==896 & surveyround==2

*Id_plateforme 959 dosent have any links dully searched (https://www.linkedin.com/feed/update/urn:li:activity:6963407083215933441/)
replace dig_presence1=0 if id_plateforme==959 & surveyround==2

	*dig_presence2 (Presence of social media account)
*Id_plateforme 148 facebook last post october 8th
replace dig_presence2=0.33 if id_plateforme==148 & surveyround==2

*Id_plateforme 151 facebook exists but inactive
replace dig_presence2=0.33 if id_plateforme==151 & surveyround==2

*Id_plateforme 231 facebook exists but inactive
replace dig_presence2=0.33 if id_plateforme==231 & surveyround==2

*Id_plateforme 825 facebook exists but inactive
replace dig_presence2=0.33 if id_plateforme==825 & surveyround==2

*Id_plateforme 841 social media not found 
replace dig_presence2=0 if id_plateforme==841 & surveyround==2

*Id_plateforme 873 has social media  
replace dig_presence2=0.33 if id_plateforme==873 & surveyround==2

*Id_plateforme 890 facebook exists but inactive
replace dig_presence2=0.33 if id_plateforme==890 & surveyround==2

	*dig_presence3 (Presence of marketplaces)
*Id_plateforme 85 not found on any marketplace
replace dig_presence3=0 if id_plateforme==85 & surveyround==2

*Id_plateforme 80 no marketplace
replace dig_presence3=0 if id_plateforme==80 & surveyround==2

*Id_plateforme 166 present on facebook marketplace
replace dig_presence3=0.33 if id_plateforme==166 & surveyround==2

*Id_plateforme 195 is still on jumia https://www.jumia.com.tn/phytovertus/
replace dig_presence3=0.33 if id_plateforme==195 & surveyround==2

*Id_plateforme 237 has a marketplace on facebook https://www.facebook.com/WIKIOfficiel/shop/

*Id_plateforme 253 has a marketplace on facebook https://www.facebook.com/NauTikTunisia/shop/
replace dig_presence3=0.33 if id_plateforme==253 & surveyround==2

*Id_plateforme 270 dosent use marketplace anymore according to ElAmouri

*Id_plateforme 275 is service & dosent have marketplace
replace dig_presence3=0 if id_plateforme==275 & surveyround==2

*Id_plateforme 324 present on baity.tn & soon on jumia according to ELAmouri
replace dig_presence3=0.33 if id_plateforme==324 & surveyround==2

*Id_plateforme 332 not present anymore on marketplace according to ElAmouri

*Id_plateforme 356 present on jumia (ElAmouri)
replace dig_presence3=0.33 if id_plateforme==356 & surveyround==2

*Id_plateforme 360 not a single information on web
replace dig_presence3=0 if id_plateforme==360 & surveyround==2

*Id_plateforme 406 no sign of marketplace
replace dig_presence3=0 if id_plateforme==406 & surveyround==2

*Id_plateforme 424 confirmed no presence on marketplace ElAmouri

*Id_plateforme 427 was present on ElFabrica a banned website, confirmed no presence on marketplace ElAmouri

*Id_plateforme 438 not present on marketplace according to ElAmouri

*Id_plateforme 592 present on marketplace jumia although ElAmouri saying the opposite https://www.jumia.com.tn/candy-led/
replace dig_presence3=0.33 if id_plateforme==592 & surveyround==2

*Id_plateforme 637 not found on marketplaces
replace dig_presence3=0 if id_plateforme==637 & surveyround==2

*Id_plateforme 646 now present on jumia https://www.jumia.com.tn/coala/

*Id_plateforme 695 present on https://pharma-shop.tn/149_farmavans
replace dig_presence3=0.33 if id_plateforme==695 & surveyround==2

*Id_plateforme 752 not in any marketplace
replace dig_presence3=0 if id_plateforme==752 & surveyround==2

*Id_plateforme 765 nielsen is a b2b, not found on marketplaces
replace dig_presence3=0 if id_plateforme==765 & surveyround==2

*Id_plateforme 791 on jumia https://www.jumia.com.tn/medina/
replace dig_presence3=0.33 if id_plateforme==791 & surveyround==2

*Id_plateforme 956 on facebook marketplace https://www.facebook.com/GmarStore.tn/shop/
replace dig_presence3=0.33 if id_plateforme==956 & surveyround==2

*I have moved the code further down so we can see the changes
*Correct baseline value for dig_presence1,2 and 3 dependent on whether firm 
*has website, social media or market place. For the last one, if claimed yes and we dont have a link
*check major marketplaces for firmname (jumia etc) 
*Digital presence change--> Manually check those firms where dig_presenceX_check is not zero (hence there
*a change between baseline and mid-line, via browswing:	

bysort id_plateforme (surveyround): gen dig_presence1_check =  dig_presence1 - dig_presence1[_n-1]
bysort id_plateforme (surveyround): gen dig_presence2_check =  dig_presence2 - dig_presence2[_n-1]
bysort id_plateforme (surveyround): gen dig_presence3_check =  dig_presence3 - dig_presence3[_n-1]

* Correct digital presence
replace dig_presence3=0 if id_plateforme== 78 & surveyround==2
replace dig_description3=0 if id_plateforme== 78 & surveyround==2
replace dig_miseajour3=0 if id_plateforme== 78 & surveyround==2
replace dig_presence3=1 if id_plateforme== 324 & surveyround==2
replace dig_presence3=0 if id_plateforme== 424 & surveyround==2
replace dig_presence3=0 if id_plateforme== 427 & surveyround==2
replace dig_presence3=0 if id_plateforme== 438 & surveyround==2
replace dig_presence3=0 if id_plateforme== 470 & surveyround==2

replace dig_presence3=0 if id_plateforme== 478 & surveyround==2
replace dig_description3=0 if id_plateforme== 478 & surveyround==2
replace dig_miseajour3=0 if id_plateforme== 478 & surveyround==2	

replace dig_presence3=0 if id_plateforme== 581 & surveyround==2

replace dig_presence3=0 if id_plateforme== 592 & surveyround==2

replace dig_presence3=0 if id_plateforme== 791 & surveyround==2

	*Correct dig_marketing_lien for mid-line if no website link is found on website but it is claimed in the 
	*survey

	*dig_marketing_respons (Does the company have someone in charge of digital marketing)
replace dig_marketing_respons=0 if id_plateforme== 78 & surveyround==2
replace dig_marketing_respons=0 if id_plateforme== 195 & surveyround==2
replace dig_marketing_respons=0 if id_plateforme== 231 & surveyround==2
replace dig_marketing_respons=0 if id_plateforme== 253 & surveyround==2
replace dig_marketing_respons=0 if id_plateforme== 270 & surveyround==2
replace dig_marketing_respons=1 if id_plateforme== 313 & surveyround==2
replace dig_marketing_respons=1 if id_plateforme== 572 & surveyround==2
replace dig_marketing_respons=0 if id_plateforme== 735 & surveyround==2

	*dig_service_responsable (Does the company have someone in charge of online orders?)
replace dig_service_responsable=0 if id_plateforme== 78 & surveyround==2
replace dig_service_responsable=1 if id_plateforme== 195 & surveyround==2
replace dig_service_responsable=0 if id_plateforme== 216 & surveyround==2
replace dig_service_responsable=1 if id_plateforme== 323 & surveyround==2
replace dig_service_responsable=1 if id_plateforme== 451 & surveyround==2
replace dig_service_responsable= 0 if id_plateforme== 565 & surveyround==2
replace dig_service_responsable= 1 if id_plateforme== 572 & surveyround==2
replace dig_service_responsable=0 if id_plateforme== 623 & surveyround==2
replace dig_service_responsable=1 if id_plateforme== 716 & surveyround==2
replace dig_service_responsable=1 if id_plateforme== 716 & surveyround==2
replace dig_service_responsable=1 if id_plateforme== 716 & surveyround==2
replace dig_service_responsable=1 if id_plateforme== 730 & surveyround==2
replace dig_service_responsable=0 if id_plateforme== 773 & surveyround==2
replace dig_service_responsable=0 if id_plateforme== 735 & surveyround==2
replace dig_service_responsable=0 if id_plateforme== 670 & surveyround==2
replace dig_service_responsable=1 if id_plateforme== 927 & surveyround==2

	*dig_marketing_ind1 (Does the company have digital marketing objectives)
replace dig_marketing_ind1=0 if id_plateforme== 95 & surveyround==2
replace dig_marketing_ind1=0 if id_plateforme== 313 & surveyround==2
replace dig_marketing_ind1=0 if id_plateforme== 466 & surveyround==2
replace dig_marketing_ind1=0 if id_plateforme== 470 & surveyround==2
replace dig_marketing_ind1=0 if id_plateforme== 478 & surveyround==2
replace dig_marketing_ind1=0 if id_plateforme== 545 & surveyround==2
replace dig_marketing_ind1=0 if id_plateforme== 581 & surveyround==2
replace dig_marketing_ind1=0 if id_plateforme== 587 & surveyround==2
replace dig_marketing_ind1=0 if id_plateforme== 602 & surveyround==2
replace dig_marketing_ind1=0 if id_plateforme== 623 & surveyround==2
replace dig_marketing_ind1=1 if id_plateforme== 650 & surveyround==2
replace dig_marketing_ind1=1 if id_plateforme== 698 & surveyround==2
replace dig_marketing_ind1=1 if id_plateforme== 730 & surveyround==2
replace dig_marketing_ind1=1 if id_plateforme== 743 & surveyround==2
replace dig_marketing_ind1=1 if id_plateforme== 867 & surveyround==2
replace dig_marketing_ind1=0 if id_plateforme== 757 & surveyround==2
replace dig_marketing_ind1=0 if id_plateforme== 752 & surveyround==2
replace dig_marketing_ind1=0 if id_plateforme== 670 & surveyround==2

	
	
	*dig_service_satisfaction (Does the company measure the satisfaction of its online clients)
replace dig_service_satisfaction=0 if id_plateforme== 70 & surveyround==2
replace dig_service_satisfaction=0 if id_plateforme== 176 & surveyround==2
replace dig_service_satisfaction=1 if id_plateforme== 195 & surveyround==2
replace dig_service_satisfaction=1 if id_plateforme== 216 & surveyround==2
replace dig_service_satisfaction=0 if id_plateforme== 253 & surveyround==2
replace dig_service_satisfaction=1 if id_plateforme== 303 & surveyround==2
replace dig_service_satisfaction=0 if id_plateforme== 313 & surveyround==2
replace dig_service_satisfaction=0 if id_plateforme== 470 & surveyround==2
replace dig_service_satisfaction=0 if id_plateforme== 541 & surveyround==2
replace dig_service_satisfaction=1 if id_plateforme== 545 & surveyround==2
replace dig_service_satisfaction=0 if id_plateforme== 623 & surveyround==2
replace dig_service_satisfaction= 0 if id_plateforme== 629 & surveyround==2
replace dig_service_satisfaction=1 if id_plateforme== 630 & surveyround==2
replace dig_service_satisfaction=1 if id_plateforme== 724 & surveyround==2
replace dig_service_satisfaction=1 if id_plateforme== 743 & surveyround==2
replace dig_service_satisfaction= 0 if id_plateforme== 831 & surveyround==2
replace dig_service_satisfaction= 1 if id_plateforme== 833 & surveyround==2


	
	
	*dig_revenues_ecom (Online sales)
replace dig_revenues_ecom= 50000 if id_plateforme== 136 & surveyround==2
replace dig_revenues_ecom= 62000 if id_plateforme== 195 & surveyround==2
replace dig_revenues_ecom= 543 if id_plateforme== 253 & surveyround==2
replace dig_revenues_ecom= 16000 if id_plateforme== 360 & surveyround==2
replace dig_revenues_ecom= 1000 if id_plateforme== 438 & surveyround==2
replace dig_revenues_ecom= 1000 if id_plateforme== 427 & surveyround==2
replace dig_revenues_ecom= 1000 if id_plateforme== 478 & surveyround==2
replace dig_revenues_ecom= 150 if id_plateforme== 508 & surveyround==2
replace dig_revenues_ecom= 13000 if id_plateforme== 542 & surveyround==2
replace dig_revenues_ecom= 7000 if id_plateforme== 547 & surveyround==2
replace dig_revenues_ecom= 0 if id_plateforme== 565 & surveyround==2
replace dig_revenues_ecom= -888 if id_plateforme== 592 & surveyround==2
replace dig_revenues_ecom= -888 if id_plateforme== 629 & surveyround==2
replace dig_revenues_ecom= 10000 if id_plateforme== 959 & surveyround==2
replace dig_revenues_ecom= 250000 if id_plateforme== 909 & surveyround==2
replace dig_revenues_ecom= 9000000 if id_plateforme== 899 & surveyround==2
replace dig_revenues_ecom= -888 if id_plateforme== 841 & surveyround==2
replace dig_revenues_ecom= 13500 if id_plateforme== 767 & surveyround==2
replace dig_revenues_ecom= 50000 if id_plateforme== 875 & surveyround==2


* Other corrections
replace fte= 15 if id_plateforme== 767 & surveyround==2

}


***********************************************************************
* 	PART 3: endline data (surveyround==3)
***********************************************************************
/* MOVED TO ENDLINE CORRECT, IN ORDER TO FIX VIZ.
*id_plateforme 841
replace comp_ca2024 = 999 if id_plateforme == 841 & surveyround == 3
replace compexp_2024 = 999 if id_plateforme == 841 & surveyround == 3

	*id_plateforme 773
replace comp_ca2023 = 1200000 if id_plateforme == 773 & surveyround == 3

	*id_plateforme 483
replace dig_invest = 2000 if id_plateforme == 483 & surveyround == 3

	*id_plateforme 735
replace comp_ca2023 = 800000 if id_plateforme == 735 & surveyround == 3

	*id_plateforme 716
replace comp_ca2023 = 424000 if id_plateforme == 716 & surveyround == 3
replace comp_ca2024 = 550000 if id_plateforme == 716 & surveyround == 3
replace compexp_2023 = 63600 if id_plateforme == 716 & surveyround == 3
replace compexp_2024 = 82500 if id_plateforme == 716 & surveyround == 3

	*id_plateforme 827 // Refuses to give comptability
local compta_vars "comp_ca2023 comp_ca2024 compexp_2023 compexp_2024 comp_benefice2023 comp_benefice2024 mark_invest dig_invest"

foreach var of local compta_vars {
	replace `var' = 888 if id_plateforme == 827 & surveyround == 3
}

	*id_plateforme 381
replace comp_ca2023 = 11000 if id_plateforme == 381 & surveyround == 3
replace comp_ca2024 = 15000 if id_plateforme == 381 & surveyround == 3
replace compexp_2023 = 2000 if id_plateforme == 381 & surveyround == 3
replace compexp_2024 = 5000 if id_plateforme == 381 & surveyround == 3
replace comp_benefice2023 = 2000 if id_plateforme == 381 & surveyround == 3
replace comp_benefice2024 = 4000 if id_plateforme == 381 & surveyround == 3

	*id_plateforme 457
replace dig_invest = 135 if id_plateforme == 457 & surveyround == 3 // EURO TO TND : 3.37 

	*id_plateforme 237
replace comp_ca2023 = 16000000 if id_plateforme == 237 & surveyround == 3
replace comp_ca2024 = 5046270 if id_plateforme == 237 & surveyround == 3
replace comp_benefice2023 = 0 if id_plateforme == 237 & surveyround == 3
replace comp_benefice2024 = 30000 if id_plateforme == 237 & surveyround == 3
replace mark_invest = 25000 if id_plateforme == 237 & surveyround == 3 
replace dig_invest = 3000 if id_plateforme == 237 & surveyround == 3

	*id_plateforme 541
replace comp_ca2023 = 50000 if id_plateforme == 541 & surveyround == 3
replace comp_ca2024 = 10000 if id_plateforme == 541 & surveyround == 3
replace comp_benefice2023 = 20000 if id_plateforme == 541 & surveyround == 3
replace comp_benefice2024 = 20000 if id_plateforme == 541 & surveyround == 3

	*id_plateforme 231
replace comp_ca2023 = 1400000 if id_plateforme == 231 & surveyround == 3
replace compexp_2023 = 300000 if id_plateforme == 231 & surveyround == 3
replace comp_ca2024 = 600000 if id_plateforme == 231 & surveyround == 3
replace compexp_2024 = 100000 if id_plateforme == 231 & surveyround == 3
replace comp_benefice2023 = 140000 if id_plateforme == 231 & surveyround == 3
replace comp_benefice2024 = 126000 if id_plateforme == 231 & surveyround == 3

	*id_plateforme 925
replace comp_benefice2023 = 999 if id_plateforme == 925 & surveyround == 3
replace comp_benefice2024 = 999 if id_plateforme == 925 & surveyround == 3

	*id_plateforme 478
replace comp_ca2023 = 2700000 if id_plateforme == 478 & surveyround == 3
replace compexp_2023 = 120000 if id_plateforme == 478 & surveyround == 3

	*id_plateforme 466
replace comp_ca2023 = 12000000 if id_plateforme == 466 & surveyround == 3

	*id_plateforme 810 // Refuses to give comptability
foreach var of local compta_vars {
	replace `var' = 888 if id_plateforme == 810 & surveyround == 3
}

	*id_plateforme 323
replace comp_ca2024 = 2900000 if id_plateforme == 323 & surveyround == 3

	*id_plateforme 543
replace compexp_2023 = 888 if id_plateforme == 543 & surveyround == 3
replace compexp_2024 = 888 if id_plateforme == 543 & surveyround == 3

	*id_plateforme 597
replace comp_benefice2023 = 150000 if id_plateforme == 597 & surveyround == 3
replace comp_benefice2024 = 170000 if id_plateforme == 597 & surveyround == 3

	*id_plateforme 527
replace compexp_2023 = 400000 if id_plateforme == 527 & surveyround == 3
replace comp_ca2023 = 700000 if id_plateforme == 527 & surveyround == 3
replace comp_ca2024 = 467000 if id_plateforme == 527 & surveyround == 3
replace comp_benefice2023 = 700000 if id_plateforme == 527 & surveyround == 3
replace comp_benefice2024 = 720000 if id_plateforme == 527 & surveyround == 3 

	*id_plateforme 655
replace compexp_2024 = 6500000 if id_plateforme == 655 & surveyround == 3

	*id_plateforme 337
replace comp_ca2024 = 10500000 if id_plateforme == 337 & surveyround == 3

	*id_plateforme 488
replace mark_invest = 25000 if id_plateforme == 488 & surveyround == 3

	*id_plateforme 453
replace comp_ca2024 = 1500000 if id_plateforme == 453 & surveyround == 3
replace compexp_2024 = 1020000 if id_plateforme == 453 & surveyround == 3
replace comp_benefice2023 = 100000 if id_plateforme == 453 & surveyround == 3

	*id_plateforme 765
replace comp_ca2024 = 999 if id_plateforme == 765 & surveyround == 3

	*id_plateforme 259
replace dig_invest = 0 if id_plateforme == 259 & surveyround == 3
replace mark_invest = 750000 if id_plateforme == 259 & surveyround == 3
replace comp_ca2023 = 1800000 if id_plateforme == 259 & surveyround == 3
replace comp_ca2024 = 1800000 if id_plateforme == 259 & surveyround == 3

	*id_plateforme 489
replace mark_invest = 58961 if id_plateforme == 489 & surveyround ==3 //entre 15000euros et 20000 = 17500 * 3.37 Tunisian Dinar
	
	*id_plateforme 679
replace comp_ca2023 = 1650000 if id_plateforme == 679 & surveyround == 3

	*id_plateforme 511
replace mark_invest = 1500000 if id_plateforme == 511 & surveyround == 3
replace comp_benefice2023 = -180000 if id_plateforme == 511 & surveyround == 3
replace comp_ca2023 = 1082864 if id_plateforme == 511 & surveyround == 3
replace compexp_2023 = 1082864 if id_plateforme == 511 & surveyround == 3 // TOTALY EXPORTING.
replace comp_benefice2023 = 18000000 if id_plateforme == 511 & surveyround == 3

	*id_plateforme 547
replace comp_ca2023 = 400000 if id_plateforme == 547 & surveyround == 3
replace compexp_2023 = 50000 if id_plateforme == 547 & surveyround == 3
replace comp_ca2024 = 250000 if id_plateforme == 547 & surveyround == 3
replace compexp_2024 = 10000 if id_plateforme == 547 & surveyround == 3
replace comp_benefice2023 = 30000 if id_plateforme == 547 & surveyround == 3
replace comp_benefice2024 = 5000 if id_plateforme == 547 & surveyround == 3
	
	*id_plateforme 398
replace fte = 1000 if id_plateforme == 398 & surveyround == 3
replace car_carempl_div1 = 800 if id_plateforme == 398 & surveyround == 3
replace car_carempl_div2 = 500 if id_plateforme == 398 & surveyround == 3
replace car_carempl_div3 = 200 if id_plateforme == 398 & surveyround == 3

	*id_plateforme 670
replace comp_benefice2024 = -20000 if id_plateforme == 670 & surveyround == 3
replace comp_benefice2023 = -50000 if id_plateforme == 670 & surveyround == 3
replace comp_ca2023 = 500000 if id_plateforme == 670 & surveyround == 3
replace comp_ca2024 = 200000 if id_plateforme == 670 & surveyround == 3


	*id_plateforme 443
replace comp_benefice2023 = 2000000 if id_plateforme == 443 & surveyround == 3
replace comp_benefice2024 = 3000000 if id_plateforme == 443 & surveyround == 3
replace comp_ca2023 = 40000000 if id_plateforme == 443  & surveyround == 3
replace comp_ca2024 = 48000000 if id_plateforme == 443  & surveyround == 3
replace compexp_2023 = 26000000 if id_plateforme == 443  & surveyround == 3
replace compexp_2024 = 3000000 if id_plateforme == 443  & surveyround == 3
*/

***********************************************************************
* 	PART 4: Replacing missing values with zeros where applicable
***********************************************************************
{
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

*For financial data: replace "Don't know (-999) and refusal with missing value"

local finvars dig_revenues_ecom comp_ca2020 compexp_2020 comp_benefice2020 ssa_action1 ssa_action2 ssa_action3 ssa_action4 ssa_action5

foreach var of local  finvars {
	replace `var' = . if `var' == -999
	replace `var' = . if `var' == -888
	replace `var' = . if `var' == -777
	replace `var' = . if `var' == -1998
	replace `var' = . if `var' == -1776 
	replace `var' = . if `var' == -1554
}

}



***********************************************************************
* 	PART 5: Drop variables that are not needed
***********************************************************************
drop treatment_email


***********************************************************************
* 	PART 5: extent treatment status to additional surveyrounds
***********************************************************************
bysort id_plateforme (surveyround): replace treatment = treatment[_n-1] if treatment == . 


***********************************************************************
* 	PART 6: save
***********************************************************************
save "${master_intermediate}/ecommerce_master_inter", replace
