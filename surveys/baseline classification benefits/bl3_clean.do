***********************************************************************
* 			clean do file, benefit classifications baseline e-commerce*					  
***********************************************************************
*																	  
*	PURPOSE: clean the questionnaire answers intermediate data						  
*																	  
*	OUTLINE: 		 PART 1: Import the data
*					 PART 2: Removing whitespace & format string & lower case
*					 PART 3: Drop variables	  
*					 PART 4: Rename variables
*					 PART 5: Label variables 
*				 	 PART 6: Label the variables values        											
*					 PART 7: Save the data
*					 								  
*	Author:  	 	 Ayoub Chamakhi					    
*	ID variable: 	 id_platforme		  					  
*	Requires:  		 classification_investbenefit_intermediate.dta								  
*	Creates:    	 classification_investbenefit_final.dta

***********************************************************************
* 	PART 1:    Import the data
***********************************************************************

use "${bl3_intermediate}/classification_investbenefit_intermediate", clear

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

***********************************************************************
* 	PART 3: Drop variables   
***********************************************************************
drop investcom_benefit3_1 investcom_benefit3_2 investcom_benefit3_3

***********************************************************************
* 	PART 4: Rename variables   
***********************************************************************

rename classification1 investbenefit1
rename classification2 investbenefit2
rename classification3 investbenefit3

***********************************************************************
* 	PART 5: Label variables   
***********************************************************************

lab var investbenefit1 "classified sought ecommerce adventage 1"
lab var investbenefit2 "classified sought ecommerce adventage 2"
lab var investbenefit3 "classified sought ecommerce adventage 3"

***********************************************************************
* 	PART 6: 	Label the variables values	  			
***********************************************************************
* List of variables
local varlist investbenefit1 investbenefit2 investbenefit3

* Loop over each variable
foreach var of local varlist {
    gen `var'_classified = .
    replace `var'_classified = 1 if `var' == "export"
    replace `var'_classified = 2 if `var' == "business growth"
    replace `var'_classified = 3 if `var' == "marketing"
    replace `var'_classified = 4 if `var' == "operations"
    replace `var'_classified = 5 if `var' == "other"
}

* Define labels
label define category_label 1 "Export" 2 "Business Growth" 3 "Marketing" 4 "Operations" 5 "Other"

* Apply labels to each variable
foreach var of local varlist {
    label values `var'_classified category_label
}

***********************************************************************
* 	PART 7: 	Save the data	  			
***********************************************************************

save "${bl3_final}/classification_investbenefit_final", replace
