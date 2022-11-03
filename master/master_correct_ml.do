***********************************************************************
* 			Master correct				  
***********************************************************************
*																	  
*	PURPOSE:	Correction of values from baseline survey
*																	  
			
*																	  
*	Author:  	Fabian Scheifele							    
*	ID variable: id_platforme		  					  
*	Requires:  	ecommerce_master_inter.dta
*	Creates:	ecommerce_master_inter.dta

use "${master_intermediate}/ecommerce_master_inter", clear
***********************************************************************
* 	PART 2: Correction mid-line
***********************************************************************
	*dig_presence1 (does the company have a website?)
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



	*dig_presence2 (Presence of social media account)
*Id_plateforme 148 facebook last post october 8th
replace dig_presence2=1 if id_plateforme==148 & surveyround==2

*Id_plateforme 151 facebook exists but inactive
replace dig_presence2=1 if id_plateforme==151 & surveyround==2

*Id_plateforme 231 facebook exists but inactive
replace dig_presence2=1 if id_plateforme==231 & surveyround==2

*Id_plateforme 825 facebook exists but inactive
replace dig_presence2=1 if id_plateforme==825 & surveyround==2

*Id_plateforme 841 social media not found 
replace dig_presence2=0 if id_plateforme==841 & surveyround==2

*Id_plateforme 890 facebook exists but inactive
replace dig_presence2=1 if id_plateforme==890 & surveyround==2



	*dig_presence3 (Presence of marketplaces)
*Id_plateforme 85 not found on any marketplace
replace dig_presence3=0 if id_plateforme==85 & surveyround==2

*Id_plateforme 166 present on facebook marketplace
replace dig_presence3=1 if id_plateforme==166 & surveyround==2

*Id_plateforme 195 is still on jumia https://www.jumia.com.tn/phytovertus/
replace dig_presence3=1 if id_plateforme==195 & surveyround==2

*Id_plateforme 237 has a marketplace on facebook https://www.facebook.com/WIKIOfficiel/shop/

*Id_plateforme 253 has a marketplace on facebook https://www.facebook.com/NauTikTunisia/shop/
replace dig_presence3=1 if id_plateforme==253 & surveyround==2

*Id_plateforme 270 dosent use marketplace anymore according to ElAmouri

*Id_plateforme 275 is service & dosent have marketplace
replace dig_presence3=0 if id_plateforme==275 & surveyround==2

*Id_plateforme 324 present on baity.tn & soon on jumia according to ELAmouri
replace dig_presence3=1 if id_plateforme==324 & surveyround==2

*Id_plateforme 332 not present anymore on marketplace according to ElAmouri

*Id_plateforme 360 to be called by el Amouri tomorrow

*Id_plateforme 406 no sign of marketplace
replace dig_presence3=0 if id_plateforme==406 & surveyround==2

*Id_plateforme 424 confirmed no presence on marketplace ElAmouri

*Id_plateforme 427 was present on ElFabrica a banned website, confirmed no presence on marketplace ElAmouri

*Id_plateforme 438 not present on marketplace according to ElAmouri

*Id_plateforme 592 present on marketplace jumia although ElAmouri saying the opposite https://www.jumia.com.tn/candy-led/
replace dig_presence3=1 if id_plateforme==592 & surveyround==2

*Id_plateforme 646 now present on jumia https://www.jumia.com.tn/coala/

*Id_plateforme 695 present on https://pharma-shop.tn/149_farmavans
replace dig_presence3=1 if id_plateforme==695 & surveyround==2

*Id_plateforme 752 not in any marketplace
replace dig_presence3=0 if id_plateforme==752 & surveyround==2

*Id_plateforme 765 will be recalled by ElAmouri

*Id_plateforme 791 on jumia https://www.jumia.com.tn/medina/
replace dig_presence3=1 if id_plateforme==791 & surveyround==2

*Id_plateforme 956 on facebook marketplace https://www.facebook.com/GmarStore.tn/shop/
replace dig_presence3=1 if id_plateforme==956 & surveyround==2

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


*replace dig_marketing_lien=0 if id_plateforme==XXX & surveyround==2


	*dig_marketing_respons (Does the company have someone in charge of digital marketing)
replace dig_marketing_respons=0 if id_plateforme== 78 & surveyround==2
*replace dig_marketing_respons=0 if id_plateforme== 195 & surveyround==2 (not clear if they have one or not)
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
