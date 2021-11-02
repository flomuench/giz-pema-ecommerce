***********************************************************************
* 			baseline corrections									  	  
***********************************************************************
*																	    
*	PURPOSE: replace					  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Define non-response categories 			  				  
* 	2) 		Encode categorical variaregises
*	3)   	Replace string with numeric values						  
*	4)  	Convert string to numerical variaregises	  				  
*	5)  	Convert proregisematic values for open-ended questions		  
*	6)  	Traduction reponses en arabe au francais				  
*   7)      Rename and homogenize the observed values                   
*	8)		Import categorisation for opend ended QI questions
*	9)		Remove duplicates
*
*																	  															      
*	Author:  	Florian Muench & Kais Jomaa							  
*	ID variaregise: 	id (example: f101)			  					  
*	Requires: regis_inter.dta 	  								  
*	Creates:  regis_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  Define non-response categories  			
***********************************************************************
use "${regis_intermediate}/regis_inter", clear

{
/*	
scalar not_know    = 77777777777777777
scalar refused     = 99999999999999999
scalar check_again = 88888888888888888

	* replace, gen, label
	
*/
}

***********************************************************************
* 	PART 2:  Encode categorical variaregises		  			
***********************************************************************
{
	* Section
/*
label def labelname 1 "" 2 "" 3 "" 4 "" 5 ""
encode varname, gen(new_var_name) label(labelname) 
drop varname
rename new_var_name varname
*/

}


***********************************************************************
* 	PART 3:  Replace string with numeric values		  			
***********************************************************************
{
/*
	* q391: ventes en export 
replace q391_corrige = "254000000" if id == "f247"
replace q391_corrige = "1856000"  if q391=="1milliard856" 
replace q391_corrige = "1500000"  if q391=="1milliard500"

	* q391: Values to be checked
replace q392_corrige = "$check_again"  if q392=="2millions100"  /*Notez les ID concernés*/
replace q392_corrige = "$check_again"  if q392=="saison de plantation"  


*/

}
***********************************************************************
* 	PART 4:  Convert string to numerical variaregises	  			
***********************************************************************
{
/*
foreach x of global numvarc {
destring `x', replace
format `x' %25.0fc
}

* calculate absolute profit if profit was provided as a percentage
replace q393_corrige = q393_normalval * c_a if q393_corrige < 1
*/
}	
***********************************************************************
* 	PART 5:  Convert problematic values for open-ended questions  			
***********************************************************************
{
/*
	* Sectionname
replace q04 ="Hors sujet" if q04 == "OUI" 
*/
}

***********************************************************************
* 	PART 6:  Traduction reponses en arabe au francais		  			
***********************************************************************
{
* Sectionname
/*
replace q05="directeur des ventes"  if q05=="مدير المبيعات" 
*/

}

***********************************************************************
* 	PART 7: 	Rename and homogenize the observed values		  			
***********************************************************************
{
	* Sectionname
*replace regis_unite = "pièce"  if regis_unite=="par piece"
*replace regis_unite = "pièce"  if regis_unite=="Pièce" 

}


***********************************************************************
* 	PART 8:  Import categorisation for opend ended QI questions
***********************************************************************
{
/*
	* the manually handed categories are in the folder data/AQE/surveys/midline/categorisation/copies
			* q42, q15c5, q18m5, q10n5, q10r5, q21example
local categories "argument-vente source-informations-conformité source-informations-metrologie source-normes source-reglements-techniques verification-intrants-fournisseurs"
foreach x of local categories {
	preserve

	cd "$regis_categorisation"
	
	import excel "${regis_categorisation}/Copie de categories-`x'.xlsx", firstrow clear
	
	duplicates drop id, force

	cd "$regis_intermediate"

	save "`x'", replace

	restore

	merge 1:1 id using `x'
	
	save, replace

	drop if _merge == 2 /* drops all non matched rows from coded categories */
	
	drop _merge
}
	* format variables

format %-25s q42 q42c q15c5 q18m5 q10n5 q10r5 q21example q15c5c q18m5c q10n5c q10r5c q21examplec

	* visualise the categorical variables
			* argument de vente
codebook q42c /* suggère qu'il y a 94 valeurs uniques doit etre changé */
graph hbar (count), over(q42c, lab(labs(tiny)))
			* organisme de certification
graph hbar (count), over(q15c5c, lab(labs(tiny)))
graph hbar (count), over(q10n5c, lab(labs(tiny)))


	* label variable categories
lab var q42f "(in-) formel argument de vente"
*/
}

***********************************************************************
* 	PART 9:  Remove duplicates
***********************************************************************
	* id_plateform
	
	* email
*duplicates report rg_email
*duplicates tag rg_email, gen(dup_email)

	* firmname

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************

save "regis_inter", replace
