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
	 
use "${ml_final}/ml_final", clear

***********************************************************************
* 	PART 2:  Define logical tests
***********************************************************************

/* --------------------------------------------------------------------
	PART 2.1: Comptabilité / accounting questions
----------------------------------------------------------------------*/		

* If any of the accounting vars corresponds to the scalars (not_know: -999 ; refused: -888; or check_again = -777) change needs_check to 2
local accountvars fte dig_revenues_ecom car_carempl_div1 car_carempl_div2 ///
car_carempl_div3 car_carempl_div4 car_carempl_div5

replace needs_check = 2 if dig_revenues_ecom == -999 
replace questions_needing_checks = " | dig_revenues_ecom ne sais pas & " + questions_needing_checks if dig_revenues_ecom == -999 

replace needs_check = 2 if dig_revenues_ecom == -888 
replace questions_needing_checks = " | dig_revenues_ecom refusée & " + questions_needing_checks if dig_revenues_ecom == -888 

***********************************************************************
* 	PART 3:  Check for missing values
***********************************************************************
	* Variables with internal logic:
replace needs_check = 3 if dig_revenues_ecom==. & dig_presence_score>0
replace questions_needing_checks = questions_needing_checks +  " | present en ligne mais dig_revenues_ecom manque" if dig_revenues_ecom==. & dig_presence_score>0

* Companies that fill in dig_presence1-3 should have no "I dont know" answer 
*for dig_description1-3, dig_miseajour1-3 dig_payment1-3 etc


//replace needs_check = 1 if ==. &
//replace questions_needing_checks = questions_needing_checks +  " | " 

	* Now all closed variables without a logic (ie don't require other answers to be true)

local dig_presence1 dig_presence2 dig_presence3 empl car_carempl_div1 car_carempl_div2 car_carempl_div3 car_carempl_div4 car_carempl_div5

foreach var of local closed_vars {
	capture replace needs_check = 1 if `var' == . 
	capture replace questions_needing_checks = questions_needing_checks + " | `var' manque" if `var' == . 
}



***********************************************************************
* 	PART 4:  Check for outliers
***********************************************************************
*automatic check if dig_revenues more than 10% larger than the largest value in the baseline
replace needs_check = 3 if dig_revenues_ecom> 9000000 & dig_revenues_ecom<. 
 
***********************************************************************
* 	PART 4: Manual outlier detection 
***********************************************************************

*Manually remove those plateforme IDs where unusual values where justified and confirmed or were respondent refused after verification call*

*replace needs_check = 1 if id_plateforme==XXX
*




***********************************************************************
* 	PART 4:  Cross checks again registration data
***********************************************************************

// check using export2017-2021 
// check 'produit exportable'
// compare car_carempl_div1 to fte_femmes

***********************************************************************
* 	PART 5:  Export fiche correction and save as final
***********************************************************************

***********************************************************************
* 	Export an excel sheet with needs_check variables  			
***********************************************************************

capture drop dup

sort id_plateforme, stable

quietly by id_plateforme:  gen dup = cond(_N==1,0,_n)

replace needs_check = 1 if dup>0

gen commentaires_ElAmouri = 0

cd "$ml_checks"


*export excel id_plateforme heure date commentselamouri commentsmsb needs_check questions_needing_check ///
 *using "fiche_correction" if needs_check>0, firstrow(variables) replace


	* Save as final

drop needs_check questions_needing_checks commentsmsb

cd "$ml_final"

save "ml_final", replace


