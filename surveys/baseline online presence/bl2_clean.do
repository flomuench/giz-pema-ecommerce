**********************************************************************
* 			clean do file, second part baseline e-commerce			  *					  
***********************************************************************
*																	  
*	PURPOSE: clean the questionnaire answers raw data						  
*																	  
*	OUTLINE: 	PART 1: 	  
*				PART 2: 	  
*				PART 3:                         											  
*																	  
*	Author:  								    
*	ID variable: 		  					  
*	Requires:  	 Webpresence_answers_raw.dta								  
*	Creates:     Webpresence_answers_inter.dta

***********************************************************************
* 	PART 1:    
***********************************************************************

*remove leading and trailing white space
{
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x' = stritrim(strtrim(`x'))
}
}

*destring
ds, has(type string) 
local strvars "`r(varlist)'"
format %-20s `strvars'




save "${bl2_intermediate}/Webpresence_answers_inter", replace
