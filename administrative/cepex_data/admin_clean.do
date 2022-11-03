***********************************************************************
* 			clean do file, admin data			   	       			  *					  
***********************************************************************
*																	  
*	PURPOSE: clean the admin data						  
*																	  
*	OUTLINE: 	PART 1:   clean admin data  
*				PART 2:   save admin data                    	
*										  
*																	  
*	Author:  	Ayoub Chamakhi					    
*	ID variable: Id_plateforme		  					  
*	Requires:  	 cp_intermediate.dta								  
*	Creates:     cp_final.dta

***********************************************************************
* 	PART 1:    clean admin data
***********************************************************************
use "${cp_intermediate}/cp_intermediate", clear


*remove leading and trailing white space
{
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x' = stritrim(strtrim(`x'))
}
}

	* numeric 
ds, has(type numeric) 
local numvars "`r(varlist)'"
format %-25.2fc `numvars'

*format %-25.0fc id_plateforme

drop Date_Key 
* format date

format %td FullDate1

***********************************************************************
* 	PART 2:    save admin data
***********************************************************************
save "${cp_intermediate}/cp_final", replace
