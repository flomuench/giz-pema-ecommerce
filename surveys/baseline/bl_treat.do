***********************************************************************
* 			E-commerce experiment treatment status								  		  
***********************************************************************
*																	   
*	PURPOSE: After single randomisation, add treatment status (avoid repeating randomisation, but guarantee replicability)						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)	 import bl & merge with randomised list (to add treatment status)													  
*	2)	 save
*																 	 
*	Author:  	Florian Münch													  
*	ID variable: 	id_plateforme			  									  
*	Requires:		bl_final.dta, ecommerce_list
*	Creates:		bl_final.dta					  					  
***********************************************************************
* 	PART 1: Import bl data & merge to randomisation results
***********************************************************************
use "${bl_final}/bl_final", clear
merge 1:1 id_plateforme using "${bl_final}/ecommerce_list"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                               236  (_merge==3)
    -----------------------------------------
*/

tab treatment

/*
  treatment |      Freq.     Percent        Cum.
------------+-----------------------------------
    Control |        119       50.42       50.42
  Treatment |        117       49.58      100.00
------------+-----------------------------------
      Total |        236      100.00

*/ 

drop _merge
***********************************************************************
* 	PART 2: Label treatment status
***********************************************************************
replace treatment ="0" if treatment=="Control"
replace treatment ="1" if treatment=="Treatment"

destring treatment, replace
format treatment %25.0fc

label var treatment "Treatment status"
label define treat 0 "Control" 1 "Treatment" 
label values treatment treat 
***********************************************************************
* 	PART 3: Save in bl_final folder
***********************************************************************
save "${bl_final}/bl_final", replace