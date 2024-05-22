***********************************************************************
* 			e-commerce endline survey corrections                    	
***********************************************************************
*																	    
*	PURPOSE: correct all incoherent responses				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Define non-response categories 		
*   2)		Identify and remove duplicates  	  				  
* 	3) 		Automatic corrections
*	4)   	Manual corrections					  
*	5)  	Destring variables that should be numeric	  				  
*	6)  	Save the changes made to the data		  
*																  															      
*	Author:  	Kaïs Jomaa 							  
*	ID variable: 	id (example: f101)			  					  
*	Requires: el_intermediate.dta  								  
*	Creates:  el_intermediate.dta			                          
*	
																  
***********************************************************************
* 	PART 1:  Define non-response categories  			
***********************************************************************
use "${el_intermediate}/el_intermediate", clear

{
	* replace "-" with missing value
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
		replace `x' = "" if `x' == "-"
	}
	
scalar not_know    = 999
scalar refused     = 888
scalar not_answered     = 1234

local not_know    = 999
local refused     = 888
local not_answered     = 1234

	* replace, gen, label

}

***********************************************************************
* 	PART 2:  Identify and remove duplicates 
***********************************************************************
/*sort id_plateforme date, stable
quietly by id_plateforme date:  gen dup = cond(_N==1,0,_n)
drop if dup>1
*/
/*duplicates report id_plateforme heuredébut
duplicates tag id_plateforme heuredébut, gen(dup)
drop if dup>1
*/

*Individual duplicate drops (where heure debut is not the same). If the re-shape
*command in bl_test gives an error it is because there are remaining duplicates,
*please check them individually and drop (actually el-amouri is supposed to that)

*restore original order
*sort date heure, stable
***********************************************************************
* 	PART 3:  Automatic corrections
***********************************************************************
*2.1 Remove commas, dots, dt and dinar Turn zero, zéro into 0 for all numeric vars
 
local numvars dig_revenues_ecom comp_ca2023 comp_ca2024 compexp_2023 compexp_2024 comp_benefice2023 comp_benefice2024 dig_invest mark_invest dig_empl
* we may add these variables to check if they changed to string variables: ca_exp2018_cor  ca_exp2019_cor ca_exp2020_cor ca_2018_cor 
*replace dig_revenues_ecom = "700000" if dig_revenues_ecom == "SEPT CENT MILLE DINARS"

/*
foreach var of local numvars {
replace `var' = ustrregexra( `var',"dinars","")
replace `var' = ustrregexra( `var',"dinar","")
*replace `var' = ustrregexra( `var',"milles","000")
*replace `var' = ustrregexra( `var',"mille","000")
*replace `var' = ustrregexra( `var',"million","000")
*replace `var' = ustrregexra( `var',"dt","")
*replace `var' = ustrregexra( `var',"k","000")
replace `var' = ustrregexra( `var',"dt","")
replace `var' = ustrregexra( `var',"tnd","")
replace `var' = ustrregexra( `var',"TND","")
*replace `var' = ustrregexra( `var',"zéro","0")
*replace `var' = ustrregexra( `var',"zero","0")
replace `var' = ustrregexra( `var'," ","")
*replace `var' = ustrregexra( `var',"un","1")
*replace `var' = ustrregexra( `var',"deux","2")
*replace `var' = ustrregexra( `var',"trois","3")
*replace `var' = ustrregexra( `var',"quatre","4")
*replace `var' = ustrregexra( `var',"cinq","5")
*replace `var' = ustrregexra( `var',"six","6")
*replace `var' = ustrregexra( `var',"sept","7")
*replace `var' = ustrregexra( `var',"huit","8")
*replace `var' = ustrregexra( `var',"neuf","9")
*replace `var' = ustrregexra( `var',"dix","10")
*replace `var' = ustrregexra( `var',"cent","00")
*replace `var' = ustrregexra( `var',"O","0")
*replace `var' = ustrregexra( `var',"o","0")
replace `var' = ustrregexra( `var',"دينار تونسي","")
replace `var' = ustrregexra( `var',"دينار","")
replace `var' = ustrregexra( `var',"تونسي","")
replace `var' = ustrregexra( `var',"د","")
replace `var' = ustrregexra( `var',"d","")
replace `var' = ustrregexra( `var',"na","")
replace `var' = ustrregexra( `var',"r","")
*replace `var' = ustrregexra( `var',"m","000")
*replace `var' = ustrregexra( `var',"مليون","000")
*replace `var' = "1000" if `var' == "000"
replace `var' = subinstr(`var', ".", "",.)
replace `var' = subinstr(`var', ",", ".",.)
replace `var' = "`not_know'" if `var' =="je ne sais pas"
replace `var' = "`not_know'" if `var' =="لا أعرف"
replace `var' = "`not_know'" if `var' =="jenesaispas"
}
replace dig_revenues_ecom = "not_know" if dig_revenues_ecom == "jenesaispas"

*put zero digital revenues for firms that do not have any digital revenues
replace dig_revenues_ecom = "0" if dig_vente == 0
*/


***********************************************************************
* 	PART 4:  Manual corrections
***********************************************************************
replace comp_benefice2024 = "30000000" if id_plateforme == 237 // IT LOOKS WRONG, WILL RETURN IN CORRECTION FILE
replace comp_benefice2023 = "782720" if comp_benefice2023 == "782 720"

***********************************************************************
* 	PART 5:  destring variables that should be numeric
***********************************************************************
local numvars dig_revenues_ecom comp_ca2023 comp_ca2024 compexp_2023 compexp_2024 comp_benefice2023 comp_benefice2024 dig_invest mark_invest dig_empl
foreach var of local numvars {
destring `var', replace
recast int `var'
}
***********************************************************************
* 	Part 6: Save the changes made to the data		  			
***********************************************************************
cd "$el_intermediate"
save "el_intermediate", replace

