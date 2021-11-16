***********************************************************************
* 			registration corrections									  	  
***********************************************************************
*																	    
*	PURPOSE: correct all incoherent responses				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Define non-response categories 			  				  
* 	2) 		correct unique identifier - matricule fiscal
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

	* replace "-" with missing value
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
		replace `x' = "" if `x' == "-"
	}
	

{

scalar not_know    = 77777777777777777
scalar refused     = 99999999999999999
scalar check_again = 88888888888888888

	* replace, gen, label
	
*/
}

***********************************************************************
* 	PART 2: use regular expressions to correct variables 		  			
***********************************************************************
	* idea: use regular expression to create a dummy = 1 for all responses
		* with correct fiscal number that fulfill 7 digit, 1 character condition
gen id_admin_correct = ustrregexm(id_admin, "([0-9]){7}[a-z]")
order id_admin_correct, a(id_admin)
lab def correct 1 "correct" 0 "incorrect"
lab val id_admin_correct correct
*browse identifiant*


	* correct telephone numbers with regular expressions
		* representative
gen rg_telrep_cor = ustrregexra(rg_telrep, "^216", "")
gen diff = length(rg_telrep) - length(rg_telrep_cor)
order rg_telrep_cor diff, a(rg_telrep)
*browse rg_telrep* diff
drop rg_telrep diff
rename rg_telrep_cor rg_telrep


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
destring rg_fte_femmes, replace

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

destring id_plateforme, replace

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
*duplicates report id_plateform

	* email
*duplicates report rg_email
*duplicates tag rg_email, gen(dup_email)

	* firmname	
	
***********************************************************************
* 	PART 10:  autres / miscallaneous adjustments
***********************************************************************
	* correct the response categories for moyen de communication
replace moyen_com = "site institution gouvernmentale" if moyen_com == "site web d'une autre institution gouvernementale" 
replace moyen_com = "bulletin d'information giz" if moyen_com == "bulletin d'information de la giz"

	* correct wrong response categories for subsectors
replace subsector = "industries chimiques" if subsector == "industrie chimique"

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
cd "$regis_intermediate"
save "regis_inter", replace
