***********************************************************************
* 			e-commerce midline survey corrections                    	
***********************************************************************
*																	    
*	PURPOSE: correct all incoherent responses				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Define non-response categories 		
*   2)		Manually fix wrong answers 	  				  
* 	3) 		Use regular expressions to correct variables
*	4)   	Replace string with numeric values						  
*	5)  	Convert string to numerical variaregises	  				  
*	6)  	Convert problematic values for open-ended questions		  
*	7)  	Traduction reponses en arabe au francais				  
*   8)      Rename and homogenize the observed values                   
*	9)		Import categorisation for opend ended QI questions
*	10)		Remove duplicates
*
*																	  															      
*	Author:  	Fabian Scheifele, Kais Jomaa & Ayounb							  
*	ID variaregise: 	id (example: f101)			  					  
*	Requires: ml_inter.dta 	  								  
*	Creates:  ml_inter.dta			                          
*	
																  
***********************************************************************
* 	PART 1:  Define non-response categories  			
***********************************************************************
use "${ml_intermediate}/ml_intermediate", clear

{
	* replace "-" with missing value
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
		replace `x' = "" if `x' == "-"
	}
	
scalar not_know    = -999
scalar refused     = -888

local not_know    = -999
local refused     = -888

	* replace, gen, label

}

***********************************************************************
* 	PART 1.2:  Identify and remove duplicates 
***********************************************************************
sort id_plateforme date, stable
quietly by id_plateforme date:  gen dup = cond(_N==1,0,_n)
drop if dup>1

/*duplicates report id_plateforme heuredébut
duplicates tag id_plateforme heuredébut, gen(dup)
drop if dup>1
*/

*Individual duplicate drops (where heure debut is not the same). If the re-shape
*command in bl_test gives an error it is because there are remaining duplicates,
*please check them individually and drop (actually el-amouri is supposed to that)

*restore original order
sort date heure, stable
***********************************************************************
* 	PART 2:  Automatic corrections
***********************************************************************
*2.1 Remove commas, dots, dt and dinar Turn zero, zéro into 0 for all numeric vars
 
local numvars dig_revenues_ecom
* we may add these variables to check if they changed to string variables: ca_exp2018_cor  ca_exp2019_cor ca_exp2020_cor ca_2018_cor 
replace dig_revenues_ecom = "700000" if dig_revenues_ecom == "SEPT CENT MILLE DINARS"
replace dig_revenues_ecom = "40000 " if dig_revenues_ecom == "40 000"
replace dig_revenues_ecom = "12000 " if dig_revenues_ecom == "12 malyoun" /*id=767 to be checked again*/
replace dig_revenues_ecom = "50000 " if dig_revenues_ecom == "50 million millimes" 
replace dig_revenues_ecom= "-999" if dig_revenues_ecom =="aucune idee"
replace dig_revenues_ecom= "36000" if dig_revenues_ecom =="4 mlayen par mois"
replace dig_revenues_ecom= "700000" if dig_revenues_ecom =="sept cent mille dinars"
replace dig_revenues_ecom= "8000" if dig_revenues_ecom =="8 mlayen"
replace dig_revenues_ecom= "250000" if dig_revenues_ecom =="250 mille dinars"
replace dig_revenues_ecom= "10000" if dig_revenues_ecom =="10000 (dix mille dinars)"
replace dig_revenues_ecom= "-888" if dig_revenues_ecom =="refus"
replace dig_revenues_ecom= "10000" if dig_revenues_ecom =="10 million millime"

  
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



***********************************************************************
* 	PART 3:  Manual corrections
***********************************************************************
*correct matricule fiscale if given in wrong format, check on registre-entreprise.tn

***********************************************************************
* 	PART 4:  destring variables that should be numeric
***********************************************************************
destring dig_revenues_ecom, replace
recast int dig_revenues_ecom
***********************************************************************
* 	Part 9: Save the changes made to the data		  			
***********************************************************************
cd "$ml_intermediate"
save "ml_intermediate", replace

