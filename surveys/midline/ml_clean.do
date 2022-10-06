***********************************************************************
* 			clean do file, midline ecommerce			 			  *					  
***********************************************************************
*																	  
*	PURPOSE: clean the surveys answers					  
*																	  
*	OUTLINE: 		 PART 1: Import the data
*					 PART 2: Removing whitespace & format string & lower case
*					 PART 3: Make all variables names lower case	
*					 PART 4: Label variables  
*					 PART 5: Labvel variables values
*					 PART 6: Save the changes made to the data
*				 	 PART 7:        											
*					 PART 8: 
*					 								  
*	Author:  	 	 Ayoub Chamakhi & Fabian Scheifele					    
*	ID variable: 	 id_plateforme		  					  
*	Requires:  		 Webpresence_answers_intermediate.dta								  
*	Creates:    	 Webpresence_answers_intermediate.dta

***********************************************************************
* 	PART 1:    Import the data
***********************************************************************

use "${ml_intermediate}/ml_intermediate", clear

***********************************************************************
* 	PART 2:    Removing whitespace & format string and date & lower case 
***********************************************************************

	*remove leading and trailing white space

{
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x' = stritrim(strtrim(`x'))
}
}

	*string
ds, has(type string) 
local strvars "`r(varlist)'"
format %-20s `strvars'
	
	*make all string lower case
foreach x of local strvars {
replace `x'= lower(`x')
}

	*fix date
format Date %td


***********************************************************************
* 	PART 3: 	Make all variables names lower case		  			
***********************************************************************
rename *, lower

***********************************************************************
* 	PART 4: 	Label the variables		  			
***********************************************************************
/*lab var varname "varlabel"
* copier-coller pour les variables qui sont identiques à la baseline
* definer des nouvelles labels pour des nouvelles variables

***********************************************************************
* 	PART 5: 	Label the variables values	  			
***********************************************************************

local yesnovariables 

label define yesno 1 "Yes" 0 "No"
foreach var of local yesnovariables {
	label values `var' yesno
}

local frequencyvariables 

label define frequency 0 "Never" 1 "Annually" 2 "Monthly" 3 "Weekly" 4 "Daily"
foreach var of local frequencyvariables {
	label values `var' frequency
}

local agreevariables 

label define agree 1 "Strongly disagree" 2 "Disagree" 3 "Neither agree nor disagree" 4 "Agree" 5 "Strongly agree" 
foreach var of local agreevariables {
	label values `var' agree
}

label define label_list_group 1 "treatment_group" 0 "control_group"
label values list_group label_list_group 

*/
***********************************************************************
* 	Part 6: Save the changes made to the data		  			
***********************************************************************
cd "$ml_intermediate"
save "ml_inter", replace

