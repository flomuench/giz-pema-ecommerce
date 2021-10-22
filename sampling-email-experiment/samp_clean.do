***********************************************************************
* 			sampling email experiment clean								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)																  
*	2)	
*	3)																  
*																	 																      *
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
* 	PART 3: Change capitalisation of variables		  										  
***********************************************************************
	* name, governorate
foreach x of varlist name governorate {
replace `x' = proper(`x')
}

	* export
replace export = lower(export)
***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
save "giz_contact_list_inter", replace

