***********************************************************************
* 			sampling email experiment clean								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)		format string & numerical variables														  
*	2)		drop unneeded variables
*	3)		rename variables								  
*	4) 		change capitalisation of observations								 																      *
*	5) 
*
*	Author:  	Florian													  
*	ID variable: 				  									  
*	Requires:			´
*	Creates:														  
*																	  
***********************************************************************
* 	PART START: import the data 				  										  *
***********************************************************************
use "${samp_intermediate}/giz_contact_list_inter", clear


***********************************************************************
* 	PART 1: format all string & numerical variables				  										  
***********************************************************************
	* define format for string variables
ds, has(type string) 
local strvars "`r(varlist)'"
format %-20s `strvars'

	* define format for numerical variables
ds, has(type numeric) 
local numvars "`r(varlist)'"
format %-9.0fc `numvars'

***********************************************************************
* 	PART 2: drop variables that we do not need			  										  
***********************************************************************
drop A

***********************************************************************
* 	PART 3: rename variables			  										  
***********************************************************************
rename I town
label var town "city where firm is located"

***********************************************************************
* 	PART 4: Change capitalisation of variables		  										  
***********************************************************************
	* name, governorate
foreach x of varlist name governorate {
replace `x' = proper(`x')
}

	* export
replace export = lower(export)

	* email
replace email = lower(email)

	* firmname
replace firmname = lower(firmname)

***********************************************************************
* 	PART 5: remove blanks from string variables
***********************************************************************
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x' = strtrim(strtrim(`x'))
}

***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
save "giz_contact_list_inter", replace

