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

***********************************************************************
* 	PART 3:  Check for missing values
***********************************************************************
	* Variables with internal logic:
replace needs_check = 1 if dig_revenues_ecom==0 & dig_vente==1 & surveyround==2
replace questions_a_verifier = questions_a_verifier +  " | repondu qu'ils ont vente en ligne mais rapporter zéro" ///
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
replace needs_check = 3 if dig_revenues_ecom> 9000000 & dig_revenues_ecom<. & surveyround==2
replace questions_a_verifier = " | dig_revenues_ecom extremement large & " + questions_a_verifier if dig_revenues_ecom> 9000000 & dig_revenues_ecom<. & surveyround==2


***********************************************************************
* 	PART 4:  Cross checks with baseline data
***********************************************************************


/*VERIFICATION of websites and social media will be done internally
replace needs_check = 1 if dig_presence1_check<0
replace needs_check = 1 if dig_presence2_check<0
*/
replace needs_check = 2 if dig_presence3_check<0

replace questions_a_verifier = " | plus de market place (dig_presence3=0)" + ///
 questions_a_verifier if dig_presence3_check <0


 
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

/*CAN BE CHECKED INTERNALLY
bysort id_plateforme (surveyround): gen dig_marketing_lien_check = dig_marketing_lien - dig_marketing_lien[_n-1]
replace needs_check = 1 if dig_marketing_lien_check<0 

replace questions_a_verifier = " | reseaux plus liés au site web (dig_marketing_lien=0) " + ///
 questions_a_verifier if dig_marketing_lien_check<0  
 */
***********************************************************************
* 	PART 4: Manual outlier detection 
***********************************************************************
bysort id_plateforme (surveyround): gen dig_revenue_diff =  dig_revenues_ecom - dig_revenues_ecom[_n-1]
*Manually remove those plateforme IDs where unusual values where justified and confirmed or were respondent refused after verification call*
replace needs_check = 3 if id_plateforme==899 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zéro pour 2021 , pour 2022 9.Mio TND" + questions_a_verifier if id_plateforme==899 & surveyround==2

*manually identify cases dig_revenue_diff is very large and from something to zero
replace needs_check = 3 if id_plateforme ==78 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 99.381 TND pour 2021 , pour 2022 NSP" +questions_a_verifier if id_plateforme ==78 & surveyround==2

replace needs_check = 3 if id_plateforme ==122 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 22.000 TND pour 2021 , pour 2022 NSP" +questions_a_verifier if id_plateforme ==122 & surveyround==2

replace needs_check = 3 if id_plateforme ==136 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zero pour 2021 , pour 2022 50.000 TND" +questions_a_verifier if id_plateforme ==136 & surveyround==2

replace needs_check = 3 if id_plateforme ==172 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 8500 pour 2021 , pour 2022 zéro" +questions_a_verifier if id_plateforme ==172 & surveyround==2

replace needs_check = 3 if id_plateforme ==195 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 50000 pour 2021 , pour 2022 NSP" +questions_a_verifier if id_plateforme ==195 & surveyround==2

replace needs_check = 3 if id_plateforme ==212 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 5000 pour 2021 , pour 2022 130.000 TND" +questions_a_verifier if id_plateforme ==212 & surveyround==2

replace needs_check = 3 if id_plateforme ==253 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 2500 pour 2021 , pour 2022 543 TND" +questions_a_verifier if id_plateforme ==253 & surveyround==2

replace needs_check = 3 if id_plateforme ==261 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zero pour 2021 , pour 2022 10.000 TND" +questions_a_verifier if id_plateforme ==261 & surveyround==2

replace needs_check = 3 if id_plateforme ==360 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zero pour 2021 , pour 2022 16.000 TND" +questions_a_verifier if id_plateforme ==360 & surveyround==2

replace needs_check = 3 if id_plateforme ==375 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zero pour 2021 , pour 2022 28.000 TND" +questions_a_verifier if id_plateforme ==375 & surveyround==2

replace needs_check = 3 if id_plateforme ==381 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 2400 pour 2021 , pour 2022 350 TND" +questions_a_verifier if id_plateforme ==381 & surveyround==2

replace needs_check = 3 if id_plateforme ==427 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zero pour 2021 , pour 2022 1000 TND" +questions_a_verifier if id_plateforme ==427 & surveyround==2

replace needs_check = 3 if id_plateforme ==438 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 100.000 TND pour 2021 , pour 2022 1000 TND" +questions_a_verifier if id_plateforme ==438 & surveyround==2

replace needs_check = 3 if id_plateforme ==478 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zéro pour 2021 , pour 2022 1000 TND" +questions_a_verifier if id_plateforme ==478 & surveyround==2

replace needs_check = 3 if id_plateforme ==505 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 1.000 TND pour 2021 , pour 2022 80.000 TND" +questions_a_verifier if id_plateforme ==505 & surveyround==2

replace needs_check = 3 if id_plateforme ==508 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zéro pour 2021 , pour 2022 150 TND" +questions_a_verifier if id_plateforme ==508 & surveyround==2

replace needs_check = 3 if id_plateforme ==508 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zéro pour 2021 , pour 2022 1000 TND" +questions_a_verifier if id_plateforme ==508 & surveyround==2

replace needs_check = 3 if id_plateforme ==542 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zéro pour 2021 , pour 2022 1000 TND" +questions_a_verifier if id_plateforme ==542 & surveyround==2

replace needs_check = 3 if id_plateforme ==565 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 200.000 pour 2021 , pour 2022 zéro" +questions_a_verifier if id_plateforme ==565 & surveyround==2

replace needs_check = 3 if id_plateforme ==592 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 20.000 pour 2021 , pour 2022 zéro" +questions_a_verifier if id_plateforme ==592 & surveyround==2

replace needs_check = 3 if id_plateforme ==629 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 15.000 pour 2021 , pour 2022 NSP" +questions_a_verifier if id_plateforme ==629 & surveyround==2

replace needs_check = 3 if id_plateforme ==646 & surveyround==2 
replace questions_a_verifier = " | revenue en ligne: 200.000 pour 2021 , pour 2022 NSP" +questions_a_verifier if id_plateforme ==646 & surveyround==2

replace needs_check = 3 if id_plateforme ==695 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 200.000 pour 2021 , pour 2022 zéro" +questions_a_verifier if id_plateforme ==695 & surveyround==2

replace needs_check = 3 if id_plateforme ==710 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 200.000 pour 2021 , pour 2022 zéro" +questions_a_verifier if id_plateforme ==710 & surveyround==2

replace needs_check = 3 if id_plateforme ==729 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: valeur manquant pour 2021 , pour 2022 36.000" +questions_a_verifier if id_plateforme ==729 & surveyround==2

replace needs_check = 3 if id_plateforme ==732 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 8.332.809 pour 2021 , pour 2022 NSP" +questions_a_verifier if id_plateforme ==732 & surveyround==2

replace needs_check = 3 if id_plateforme ==765 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 30.000 pour 2021 , pour 2022 NSP" +questions_a_verifier if id_plateforme ==765 & surveyround==2

replace needs_check = 3 if id_plateforme ==767 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zéro pour 2021 , pour 2022 12.000"  +questions_a_verifier if id_plateforme ==767 & surveyround==2

replace needs_check = 3 if id_plateforme ==795 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: 1 million pour 2021 , pour 2022 zéro" +questions_a_verifier if id_plateforme ==795 & surveyround==2

replace needs_check = 3 if id_plateforme ==909 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zéro pour 2021 , pour 2022 250.000" +questions_a_verifier if id_plateforme ==909 & surveyround==2

replace needs_check = 3 if id_plateforme ==959 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zéro pour 2021 , pour 2022 10.000" +questions_a_verifier if id_plateforme ==959 & surveyround==2

replace needs_check = 3 if id_plateforme ==962 & surveyround==2
replace questions_a_verifier = " | revenue en ligne: zéro pour 2021 , pour 2022 300.000" +questions_a_verifier if id_plateforme ==962 & surveyround==2

*for calculation purposes missing to zero
replace needs_check=0 if needs_check==.

*Remove corrected observations
replace needs_check = 0 if id_plateforme == 70 & surveyround==2
replace needs_check = 0 if id_plateforme == 78 & surveyround==2
replace needs_check = 0 if id_plateforme == 95 & surveyround==2
replace needs_check = 0 if id_plateforme == 136 & surveyround==2
replace needs_check = 0 if id_plateforme == 176 & surveyround==2
replace needs_check = 0 if id_plateforme == 209 & surveyround==2
replace needs_check = 0 if id_plateforme == 216 & surveyround==2
replace needs_check = 0 if id_plateforme == 231 & surveyround==2
replace needs_check = 0 if id_plateforme == 253 & surveyround==2
replace needs_check = 0 if id_plateforme == 270 & surveyround==2
replace needs_check = 0 if id_plateforme == 313 & surveyround==2
replace needs_check = 0 if id_plateforme == 324 & surveyround==2
replace needs_check = 0 if id_plateforme == 424 & surveyround==2
replace needs_check = 0 if id_plateforme == 427 & surveyround==2
replace needs_check = 0 if id_plateforme == 438 & surveyround==2
replace needs_check = 0 if id_plateforme == 466 & surveyround==2
replace needs_check = 0 if id_plateforme == 470 & surveyround==2
replace needs_check = 0 if id_plateforme == 478 & surveyround==2
replace needs_check = 0 if id_plateforme == 508 & surveyround==2
replace needs_check = 0 if id_plateforme == 541 & surveyround==2
replace needs_check = 0 if id_plateforme == 545 & surveyround==2
replace needs_check = 0 if id_plateforme == 547 & surveyround==2
replace needs_check = 0 if id_plateforme == 565 & surveyround==2
replace needs_check = 0 if id_plateforme == 581 & surveyround==2
replace needs_check = 0 if id_plateforme == 587 & surveyround==2
replace needs_check = 0 if id_plateforme == 592 & surveyround==2
replace needs_check = 0 if id_plateforme == 602 & surveyround==2
replace needs_check = 0 if id_plateforme == 623 & surveyround==2
replace needs_check = 0 if id_plateforme == 629 & surveyround==2
replace needs_check = 0 if id_plateforme == 650 & surveyround==2
replace needs_check = 0 if id_plateforme == 670 & surveyround==2
replace needs_check = 0 if id_plateforme == 729 & surveyround==2
replace needs_check = 0 if id_plateforme == 735 & surveyround==2
replace needs_check = 0 if id_plateforme == 752 & surveyround==2
replace needs_check = 0 if id_plateforme == 757 & surveyround==2
replace needs_check = 0 if id_plateforme == 767 & surveyround==2
replace needs_check = 0 if id_plateforme == 773 & surveyround==2
replace needs_check = 0 if id_plateforme == 791 & surveyround==2
replace needs_check = 0 if id_plateforme == 831 & surveyround==2
replace needs_check = 0 if id_plateforme == 841 & surveyround==2
replace needs_check = 0 if id_plateforme == 867 & surveyround==2
replace needs_check = 0 if id_plateforme == 899 & surveyround==2
replace needs_check = 0 if id_plateforme == 909 & surveyround==2
replace needs_check = 0 if id_plateforme == 959 & surveyround==2
***********************************************************************
* 	Export an excel sheet with needs_check variables  			
***********************************************************************

sort id_plateforme, stable
cd "$ml_checks"

preserve
bysort id_plateforme (surveyround): gen checked= needs_check + needs_check[_n+1]
replace checked=0 if checked==.
*keep both baseline and midline value for observations that need checking
keep if needs_check > 0 | checked >0

*once updated with Ayoub's data all websites and social media links can be merged to help el amouri in argumentation
merge id_plateforme using  "${master_pii}/ecommerce_master_contact" 
keep if _merge==3
export excel id_plateforme heure date surveyround nom_rep id_base_respondent repondant_midline needs_check commentaires_elamouri /// 
questions_a_verifier dig_revenues_ecom /// 
dig_presence3 dig_marketing_respons dig_service_responsable dig_marketing_ind1 dig_service_satisfaction ///
 using "${ml_checks}/fiche_correction.xlsx", sheetreplace firstrow(var)

export excel id_plateforme emailrep using "${ml_checks}/email_verification.xlsx", sheetreplace firstrow(var)
restore



