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
	 
use "${master_intermediate}/ecommerce_master_final", clear

***********************************************************************
* 	PART 2:  Define logical tests
***********************************************************************

/* --------------------------------------------------------------------
	PART 2.1: Comptabilité / accounting questions
----------------------------------------------------------------------*/		

replace needs_check = 2 if dig_revenues_ecom == -999 & surveyround==2
replace questions_a_verifier = " | dig_revenues_ecom ne sais pas & " + questions_a_verifier if dig_revenues_ecom == -999 

replace needs_check = 2 if dig_revenues_ecom == -888 & surveyround==2
replace questions_a_verifier = " | dig_revenues_ecom refusée & " + questions_a_verifier if dig_revenues_ecom == -888 

***********************************************************************
* 	PART 3:  Check for missing values
***********************************************************************
	* Variables with internal logic:
replace needs_check = 3 if dig_revenues_ecom==0 & dig_vente==1 & surveyround==2
replace questions_a_verifier = questions_a_verifier +  " | present en ligne mais dig_revenues_ecom manque" ///
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
 
***********************************************************************
* 	PART 4: Manual outlier detection 
***********************************************************************

*Manually remove those plateforme IDs where unusual values where justified and confirmed or were respondent refused after verification call*

*replace needs_check = 1 if id_plateforme==XXX
*




***********************************************************************
* 	PART 4:  Cross checks with baseline data
***********************************************************************
bysort id_plateforme (surveyround): gen dig_presence1_check = dig_presence1 - dig_presence1[_n-1]
bysort id_plateforme (surveyround): gen dig_presence2_check = dig_presence2 - dig_presence2[_n-1]
bysort id_plateforme (surveyround): gen dig_presence3_check = dig_presence3 - dig_presence3[_n-1]
bysort id_plateforme (surveyround): gen dig_revenue_check = dig_revenues_ecom/dig_revenues_ecom[_n-1]

replace needs_check = 3 if dig_presence1_check<0
replace needs_check = 3 if dig_presence2_check<0
replace needs_check = 3 if dig_presence3_check<0
replace needs_check = 3 if dig_revenue_check>1.5

replace questions_a_verifier = " | plus de site web dig_presence3 (incoherene avec baseline) " + ///
 questions_a_verifier if dig_presence1_check <0
replace questions_a_verifier = " | plus de media sociaux dig_presence2 (incoherene avec baseline) " + ///
 questions_a_verifier if dig_presence2_check <0
 replace questions_a_verifier = " | plus de market place dig_presence3 (incoherene avec baseline) " + ///
 questions_a_verifier if dig_presence3_check <0
 
 replace questions_a_verifier = " | revenue digital plus que 50% croisée depuis baseline dig_revenues_ecom " + ///
 questions_a_verifier if dig_revenue_check>1.5 & dig_revenue_check<.
***********************************************************************
* 	PART 5:  Export fiche correction and save as final
***********************************************************************

***********************************************************************
* 	Export an excel sheet with needs_check variables  			
***********************************************************************

sort id_plateforme, stable


cd "$ml_checks"


export excel id_plateforme heure date commentaires_ElAmouri commentsmsb needs_check questions_a_verifier ///
 using "${ml_checks}/fiche_correction" if needs_check>0, firstrow(variables) replace


	* Save as final

drop needs_check questions_a_verifier commentsmsb commentaires_ElAmouri

cd "$ml_final"

save "ml_final", replace


