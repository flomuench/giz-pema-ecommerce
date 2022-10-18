***********************************************************************
* 			e-commerce baseline survey logical tests                  *	
***********************************************************************
*																	    
*	PURPOSE: Check that answers make logical sense			  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Preamble
* 	2) 		Define logical tests
*	2.1) 	Tests for accounting
*	2.1) 	Tests for indices	
*   3) Check missing values								  															      
*	Author:  	Fabian Scheifele & Ayoub 
*	ID variable: 	id_plateforme (example: f101)			  					  
*	Requires: ml_inter.dta 	  								  
*	Creates:  fiche_correction.xls			                          
*																	  
***********************************************************************
* 	PART 1:  Load data	  		
***********************************************************************
	 
use "${master_final}/ecommerce_master_final", clear

***********************************************************************
* 	PART 2:  Define logical tests
***********************************************************************

/* --------------------------------------------------------------------
	PART 2.1: Comptabilité / accounting questions
----------------------------------------------------------------------*/		

replace needs_check = 1 if  dig_revenues_ecom == -999 & surveyround==2
replace questions_a_verifier = " | dig_revenues_ecom ne sais pas & " + questions_a_verifier if dig_revenues_ecom == -999 & surveyround==2

replace needs_check = 1 if dig_revenues_ecom == -888 & surveyround==2
replace questions_a_verifier = " | dig_revenues_ecom refusée & " + questions_a_verifier if dig_revenues_ecom == -888 & surveyround==2

***********************************************************************
* 	PART 3:  Check for missing values
***********************************************************************
	* Variables with internal logic:
replace needs_check = 1 if dig_revenues_ecom==0 & dig_vente==1 & surveyround==2
replace questions_a_verifier = questions_a_verifier +  " | vente en ligne mais pas donner chiffres" ///
 if dig_revenues_ecom==0 & dig_vente==1 & surveyround==2


	* employee data

local fte car_carempl_div1 car_carempl_div2 car_carempl_div3 car_carempl_div4 car_carempl_div5

foreach var of local closed_vars {
	capture replace needs_check = 1 if `var' == 201 & surveyround==2
	capture replace questions_a_verifier = questions_a_verifier + " | `var' ne sais pas (donnée d'emploi)" if `var' == . & surveyround==2
}



***********************************************************************
* 	PART 4:  Check for outliers
***********************************************************************
*automatic check if dig_revenues more than 10% larger than the largest value in the baseline
replace needs_check = 1 if dig_revenues_ecom> 9000000 & dig_revenues_ecom<. & surveyround==2
replace questions_a_verifier = " | dig_revenues_ecom extremement large & " + questions_a_verifier if dig_revenues_ecom> 9000000 & dig_revenues_ecom<. & surveyround==2


***********************************************************************
* 	PART 4:  Cross checks with baseline data
***********************************************************************
*Digital presence
bysort id_plateforme (surveyround): gen dig_presence1_check =  dig_presence1 - dig_presence1[_n-1]
bysort id_plateforme (surveyround): gen dig_presence2_check =  dig_presence2 - dig_presence2[_n-1]
bysort id_plateforme (surveyround): gen dig_presence3_check =  dig_presence3 - dig_presence3[_n-1]

replace needs_check = 1 if dig_presence1_check<0
replace needs_check = 1 if dig_presence2_check<0
replace needs_check = 1 if dig_presence3_check<0

replace questions_a_verifier = " | plus de site web (dig_presence1=0)" + ///
 questions_a_verifier if dig_presence1_check <0
replace questions_a_verifier = " | plus de media sociaux (dig_presence2=0)" + ///
 questions_a_verifier if dig_presence2_check <0
replace questions_a_verifier = " | plus de market place (dig_presence3=0)" + ///
 questions_a_verifier if dig_presence3_check <0

 *revenues
bysort id_plateforme (surveyround): gen dig_revenue_ratio = dig_revenues_ecom/dig_revenues_ecom[_n-1]
replace questions_a_verifier = " | revenue digital plus que doublé depuis baseline dig_revenues_ecom " + ///
 questions_a_verifier if dig_revenue_ratio>2 & dig_revenue_ratio<.

bysort id_plateforme (surveyround): gen dig_revenue_diff =  dig_revenues_ecom - dig_revenues_ecom[_n-1]

 
 *digital marketing and service personell (PROBLEM: How to filter only those that went from positive to zero but not 
bysort id_plateforme (surveyround): gen dig_marketing_respons_check = dig_marketing_respons_bin - dig_marketing_respons_bin[_n-1]
replace needs_check = 1 if dig_marketing_respons_check<0 

replace questions_a_verifier = " | plus de responsable de marketing digital (dig_marketing_respons=0) " + ///
 questions_a_verifier if dig_marketing_respons_check<0

bysort id_plateforme (surveyround): gen dig_marketing_respons_check2 = dig_marketing_respons - dig_marketing_respons[_n-1]
replace needs_check = 1 if dig_marketing_respons_check<0 
 
bysort id_plateforme (surveyround): gen dig_service_respons_check = dig_service_responsable_bin - dig_service_responsable_bin[_n-1]
replace needs_check = 1 if dig_service_respons_check<0 

replace questions_a_verifier = " | plus de responsable de client en ligne (dig_service_responsable=0) " + ///
 questions_a_verifier if dig_service_respons_check<0
 
*digital marketing objective
bysort id_plateforme (surveyround): gen dig_marketing_ind1_check = dig_marketing_ind1 - dig_marketing_ind1[_n-1]
replace needs_check = 1 if dig_marketing_ind1_check<0  

replace questions_a_verifier = " | plus d'objective marketing digital (dig_marketing_ind1=0) " + ///
 questions_a_verifier if dig_marketing_ind1_check<0  
 
bysort id_plateforme (surveyround): gen dig_service_satisfaction_check = dig_service_satisfaction - dig_service_satisfaction[_n-1]
replace needs_check = 1 if dig_service_satisfaction_check<0 

replace questions_a_verifier = " | mesurent plus la satisfaction des client en ligne (dig_service_satisfaction=0) " + ///
 questions_a_verifier if dig_service_satisfaction_check<0  

bysort id_plateforme (surveyround): gen dig_marketing_lien_check = dig_marketing_lien - dig_marketing_lien[_n-1]
replace needs_check = 1 if dig_marketing_lien_check<0 

replace questions_a_verifier = " | reseaux plus liés au site web (dig_marketing_lien=0) " + ///
 questions_a_verifier if dig_marketing_lien_check<0  
 
***********************************************************************
* 	PART 4: Manual outlier detection 
***********************************************************************

*Manually remove those plateforme IDs where unusual values where justified and confirmed or were respondent refused after verification call*

replace needs_check = 1 if id_plateforme==899 & surveyround==2
replace questions_a_verifier = " | revenue digital: zéro pour 2021 maintenant 9.Mio TND" if id_plateforme==899 & surveyround==2

*manually identify cases dig_revenue_diff is very large and from something to zero
replace needs_check = 1 if id_plateforme ==78 
replace questions_a_verifier = " | revenue digital: 99.381 TND pour 2021 maintenant zero/NSP"

replace needs_check = 1 if id_plateforme ==122 
replace questions_a_verifier = " | revenue digital: 22.000 TND pour 2021 maintenant zero/NSP"

replace needs_check = 1 if id_plateforme ==136 
replace questions_a_verifier = " | revenue digital: zero pour 2021 maintenant 50.000 TND"

replace needs_check = 1 if id_plateforme ==212 
replace questions_a_verifier = " | revenue digital: 5000 pour 2021 maintenant 130.000 TND"

replace needs_check = 1 if id_plateforme ==253 
replace questions_a_verifier = " | revenue digital: 2500 pour 2021 maintenant 543 TND"

replace needs_check = 1 if id_plateforme ==261 
replace questions_a_verifier = " | revenue digital: zero pour 2021 maintenant 10.000 TND"

replace needs_check = 1 if id_plateforme ==360 
replace questions_a_verifier = " | revenue digital: zero pour 2021 maintenant 16.000 TND"

replace needs_check = 1 if id_plateforme ==375 
replace questions_a_verifier = " | revenue digital: zero pour 2021 maintenant 28.000 TND"

replace needs_check = 1 if id_plateforme ==381 
replace questions_a_verifier = " | revenue digital: 2400 pour 2021 maintenant 350 TND"




*for calculation purposes missing to zero
replace needs_check=0 if needs_check==.
***********************************************************************
* 	Export an excel sheet with needs_check variables  			
***********************************************************************

sort id_plateforme, stable
cd "$ml_checks"

preserve
bysort id_plateforme (surveyround): gen checked= needs_check + needs_check[_n+1]
*keep both baseline and midline value for observations that need checking
keep if needs_check == 1 | checked == 1

*once updated with Ayoub's data all websites and social media links can be merged to help el amouri in argumentation
merge id_plateforme using  "${master_pii}/ecommerce_master_contact" 
keep if _merge==3
export excel id_plateforme heure date surveyround needs_check commentaires_elamouri questions_a_verifier dig_revenues_ecom dig_presence1 ///
dig_presence2 dig_presence3 dig_marketing_respons dig_service_responsable dig_marketing_ind1 dig_service_satisfaction ///
dig_marketing_lien link_web link_facebook link_instagram link_linkedin link_twitter link_youtube ///
 using "${ml_checks}/fiche_correction", sheetreplace firstrow(var)

restore



