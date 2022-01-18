***********************************************************************
* 			e-commerce baseline survey corrections                    *	***********************************************************************
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
*	Requires: bl_inter.dta 	  								  
*	Creates:  bl_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  Define non-response categories  			
***********************************************************************
use "${bl_intermediate}/bl_inter", clear

{
	* replace "-" with missing value
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
		replace `x' = "" if `x' == "-"
	}
	



scalar not_know    = 77777777777777777
scalar refused     = 99999999999999999
scalar check_again = 88888888888888888

	* replace, gen, label
gen investcom_2021_cor = investcom_2021
gen investcom_futur_cor = investcom_futur	
*/
}


* Needs check
replace needs_check = 1 if investcom_2021_cor== "a"
* Questions needing check
replace questions_needing_check = "investcom_2021" if investcom_2021_cor== "a"



***********************************************************************
* 	PART 2: use regular expressions to correct variables 		  			
***********************************************************************
/* for reference and guidance, regularly these commands are used in this section
gen XXX = ustrregexra(XXX, "^216", "")
gen id_admin_correct = ustrregexm(id_admin, "([0-9]){6,7}[a-z]")

*replace id_admin_corrige = $check_again if id_admin_correct == 1
lab def correct 1 "correct" 0 "incorrect"
lab val id_admin_correct correct

*/
replace investcom_2021_cor = ustrregexra( investcom_2021_cor ,"k","000")
replace investcom_futur_cor = ustrregexra( investcom_futur_cor ,"dinars","")
replace investcom_futur_cor = ustrregexra( investcom_futur_cor ,"dt","")
replace investcom_futur_cor = ustrregexra( investcom_futur_cor ,"k","000")

***********************************************************************
* 	PART 3:  Replace string with numeric values		  			
***********************************************************************
{
replace investcom_2021 = "100000" if investcom_2021_cor== "100000dt"
replace investcom_2021 = "18000" if investcom_2021_cor== "huit mille dinars"
replace investcom_futur = "77777777777777777" if investcom_futur_cor == "je sais pas encore"
replace investcom_futur_cor = "77777777777777777" if investcom_futur_cor == "ne sais pas"
replace investcom_futur_cor = "20000" if investcom_futur_cor == "vingt mille dinars"

*Test logical values*

* 

*All values having a too small capital social (less than 100)
replace capitalsocial_corr = "$check_again" if capitalsocial_corr == "0"
replace capitalsocial_corr = "$check_again" if capitalsocial_corr == "o"
destring capitalsocial_corr, replace




}
***********************************************************************
* 	PART 4:  Convert string to numerical variaregises	  			
***********************************************************************
* local destrvar XX
foreach x of local destrvar { 
destring `x', replace
}


***********************************************************************
* 	PART 5:  Convert problematic values for open-ended questions  			
***********************************************************************
{

	* Sectionname
*replace q04 ="Hors sujet" if q04 == "OUI" 

*Correction nom du representant
gen rg_nom_rep_corr= rg_nom_rep            
replace rg_nom_rep_corr="$check_again" if rg_nom_rep == "Études géomatiques." 

 
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
*replace bl_unite = "pièce"  if bl_unite=="par piece"
*replace bl_unite = "pièce"  if bl_unite=="Pièce" 

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

	cd "$bl_categorisation"
	
	import excel "${bl_categorisation}/Copie de categories-`x'.xlsx", firstrow clear
	
	duplicates drop id, force

	cd "$bl_intermediate"

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
* 	PART 9:  Identify duplicates (for removal see bl_generate)
***********************************************************************
	* formating the variables for whcih we check duplicates
format firmname rg_emailrep rg_emailpdg %-35s
format id_plateforme %9.0g
sort firmname
	
	* id_plateform
duplicates report id_plateform

	* email
duplicates report rg_emailrep
duplicates report rg_emailpdg
duplicates tag rg_emailpdg, gen(dup_emailpdg)

	* firmname	
duplicates report firmname
duplicates tag firmname, gen(dup_firmname)


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
cd "$bl_intermediate"
save "bl_inter", replace
