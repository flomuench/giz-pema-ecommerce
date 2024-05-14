***********************************************************************
* 			e-commerce endline survey variable generation                    	
***********************************************************************
*																	    
*	PURPOSE: generate variables required for the monitoring of endline survey (no index creation)				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Generate summary variables of multiple answer questions	
*   2)		Generate variables for companies who answered on phone	  				  
* 	3) 		Drop useless variables	
* 	4) 		Change format type	
* 	5) 		generate normalized financial data (per employee)
* 	6) 		Create variable required for coherence test	 	
* 	6) 		Save the changes made to the data
																  															      
*	Author:  	Kaïs Jomaa		  
*	ID variable: 	id (example: f101)			  					  
*	Requires: el_intermediate.dta 	  								  
*	Creates:  el_final.dta			                          
*	
***********************************************************************
* 	PART 1:  Generate summary variables of multiple answer questions 			
***********************************************************************
use "${el_intermediate}/el_intermediate", clear																  

gen surveyround = 3
lab var surveyround "1-baseline 2-midline 3-endline"

/*
local multi_vars dig_marketing_num110 dig_moyen_paie
gen dig_marketing_num19_sea =0
replace dig_marketing_num19_sea =1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_sea") 

gen dig_marketing_num19_seo =0
replace dig_marketing_num19_seo =1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_seo") 

gen dig_marketing_num19_blg =0
replace dig_marketing_num19_blg =1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_blg") 

gen dig_marketing_num19_pub =0
replace dig_marketing_num19_pub =1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_pub") 
    
gen dig_marketing_num19_mail =0
replace dig_marketing_num19_mail =1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_mail") 
 
gen dig_marketing_num19_prtn =0
replace dig_marketing_num19_prtn =1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_prtn") 

gen dig_marketing_num19_socm=0
replace dig_marketing_num19_socm=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_socm") 
 
gen dig_marketing_num19_socm_pay=0
replace dig_marketing_num19_socm_pay=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num8") 
 
gen dig_marketing_num19_autre=0
replace dig_marketing_num19_autre=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_autre") 
 
gen dig_marketing_num19_aucu=0
replace dig_marketing_num19_aucu=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_aucu")

gen dig_marketing_num19_nsp=0
replace dig_marketing_num19_nsp=1 if ustrregexm(dig_marketing_num110, "-999")

drop dig_marketing_num110
*/

***********************************************************************
* 	PART 2:  Generate variables for companies who answered on phone	
***********************************************************************
gen survey_phone = 0
lab var survey_phone "Comapnies who answered the survey on phone (with enumerators)" 
*replace survey_phone = 1 if id_plateforme == 95
label define Surveytype 1 "Phone" 0 "En ligne"

***********************************************************************
* 	PART 3:  Drop useless variables		
***********************************************************************

***********************************************************************
* 	PART 4:  Change format type	
***********************************************************************

***********************************************************************
* 	PART 5:  generate normalized financial data (per employee)
***********************************************************************

local varn empl dig_empl mark_invest dig_invest comp_ca2023 comp_ca2024 comp_exp2023 comp_exp2024 comp_benefice2023 comp_benefice2024

foreach x of local varn { 
gen n`x' = .
replace n`x' = `x' if `x' < not_know
replace n`x' = not_know if `x' == not_know
replace n`x' = refused if `x' == refused
replace n`x' = check_again if `x' == check_again
replace n`x' = `x'/employes if n`x'!= not_know | n`x'!= refused | n`x'!= check_again
}

**********************************************************************
* 	PART 6:  save			
***********************************************************************
rename *, lower
save "${el_final}/el_final", replace
