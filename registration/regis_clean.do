***********************************************************************
* 			baseline clean									  		  
***********************************************************************
*																	  
*	PURPOSE: clean baseline raw data					  	  			
*																	  
*																	  
*	OUTLINE:														  
*	1)		Format string & numerical variables				          
*	2)   	Drop all text windows from the survey					  
*	3)  	Make all variables names lower case						  
*	4)  	Order the variables in the data set						  	  
*	5)  	Rename the variables									  
*	6)  	Label the variables										  
*   7) 		Label variable values 								 
*   8) 		Removing trailing & leading spaces from string variables										 
*																	  													      
*	Author:  	Florian Muench & Kais Jomaa							    
*	ID variable: 	id (example: f101)			  					  
*	Requires: bl_raw.dta 	  										  
*	Creates:  bl_inter.dta			                                  
***********************************************************************
* 	PART 1: 	Format string & numerical variables		  			
***********************************************************************
use "${bl_raw}/bl_raw", clear

{
	* format numerical & string variables
ds, has(type string) 
local strvars "`r(varlist)'"
format %20s `strvars'

ds, has(type numeric) 
local numvars "`r(varlist)'"
format %25.0fc `numvars'

	* make all string obs lower case
foreach x of local strvars {
replace `x'= lower(`x')
}
}

***********************************************************************
* 	PART 2: 	Drop all text windows from the survey		  			
***********************************************************************
{
drop text* Text* TEXT* refurl seed Q14A1* Q17A1*
drop AR-AY
drop Q11 Q11Time
}

***********************************************************************
* 	PART 3: 	Make all variables names lower case		  			
***********************************************************************
rename *, lower

***********************************************************************
* 	PART 4: 	Order the variables in the data set		  			
***********************************************************************
{

}

***********************************************************************
* 	PART 5: 	Rename the variables		  			
***********************************************************************
{
	* Section eligibility
	
	* Section contact data
}
***********************************************************************
* 	PART 6: 	Label the variables		  			
***********************************************************************
{
		* Section contact details
lab var X ""

		* Section eligibility

}



***********************************************************************
* 	PART 7: 	Label variables values	  			
***********************************************************************
{
lab def labelname 1 "" 2 "" 3 ""
lab val variablename labelname
}

***********************************************************************
* 	PART 8: Removing trail and leading spaces in from string variables  			
***********************************************************************
{
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x' = stritrim(strtrim(`x'))
}
}

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
cd "$regis_intermediate"
save "regis_inter", replace
