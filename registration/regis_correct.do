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
*replace id_admin_corrige = $check_again if id_admin_correct == 1
lab def correct 1 "correct" 0 "incorrect"
lab val id_admin_correct correct
*browse identifiant*
    * Correct Nom et prénom du/de la participant.e à l’activité
gen rg_nom_rep_cor = rg_nom_rep
replace rg_nom_rep_cor = ustrregexra( rg_nom_rep_cor ,"mr ","")
replace rg_nom_rep_cor = "$check_again" if rg_nom_rep_cor == "Études géomatiques."
replace rg_nom_rep_cor = "$check_again" if rg_nom_rep_cor == "tunisie"
replace rg_nom_rep_cor = "$check_again" if rg_nom_rep_cor == "société internet soft erp"
replace rg_nom_rep_cor = "$check_again" if rg_nom_rep_cor == "medianet"
replace rg_nom_rep_cor = "salhi elhem" if rg_nom_rep_cor == "inspiration design salhi elhem"
replace rg_nom_rep_cor = "$check_again" if rg_nom_rep_cor == "bilel"
replace rg_nom_rep_cor = "$check_again" if rg_nom_rep_cor == "haddad"
replace rg_nom_rep_cor = "aymen bahri" if rg_nom_rep_cor == "أيمن البحري"

    * correct code de la douane
gen rg_codedouane_cor = rg_codedouane
replace rg_codedouane_cor = ustrregexra( rg_codedouane_cor ," ","")
replace rg_codedouane_cor = "0555082b" if rg_codedouane_cor == "0555082b/a/m/000"
replace rg_codedouane_cor = "1721444v" if rg_codedouane_cor == "000ma1721444/v"
replace rg_codedouane_cor = "1149015h" if rg_codedouane_cor == "1149015/h000"
replace rg_codedouane_cor = ustrregexra( rg_codedouane_cor ,"/","")
replace rg_codedouane_cor = "$check_again" if rg_codedouane_cor == "d"
replace rg_codedouane_cor = "$check_again" if rg_codedouane_cor == "n"
replace rg_codedouane_cor = "$check_again" if rg_codedouane_cor == "n2ant"
replace rg_codedouane_cor = "$check_again" if rg_codedouane_cor == "na"
replace rg_codedouane_cor = "$refused" if rg_codedouane_cor == "non"
replace rg_codedouane_cor = "$check_again" if rg_codedouane_cor == "pasencore"
replace rg_codedouane_cor = "$check_again" if rg_codedouane_cor == "0"
replace rg_codedouane_cor = "$check_again" if rg_codedouane_cor == "......"
replace rg_codedouane_cor = "$check_again" if rg_codedouane_cor == "."
replace rg_codedouane_cor = "$check_again" if rg_codedouane_cor == "620.004w"
*We a have a duplicate for the same code de douane 220711z ; count if rg_codedouane_cor == "220711z" returns 2
    * correction de la variable autres
gen autres_cor = autres
replace autres_cor = "conseil" if ustrregexm( autres_cor ,"conseil")== 1
replace autres_cor = "consulting" if ustrregexm( autres_cor ,"consulting")== 1
replace autres_cor = "services informatiques" if ustrregexm( autres_cor ,"informatique")== 1
replace autres_cor = "communication" if ustrregexm( autres_cor ,"communication")== 1
replace autres_cor = "marketing digital" if ustrregexm( autres_cor ,"marketing digital")== 1
replace autres_cor = "bureau d'études" if ustrregexm( autres_cor ,"bureau d'études")== 1
replace autres_cor = "design" if ustrregexm( autres_cor ,"design")== 1
****** pas encore terminée

	* correct telephone numbers with regular expressions
		* representative
gen rg_telrep_cor = ustrregexra(rg_telrep, "^216", "")
replace rg_telrep_cor = ustrregexra( rg_telrep_cor,"[a-z]","")
replace rg_telrep_cor = ustrregexra( rg_telrep_cor," ","")
replace rg_telrep_cor = ustrregexra( rg_telrep_cor,"00216","")
replace rg_telrep_cor = "29939431" if rg_telrep_cor == "+21629939431"
replace rg_telrep_cor = "22161622" if rg_telrep_cor == "(+216)22161622"

*Check all phone numbers having more or less than 8 digits
replace rg_telrep_cor = "$check_again" if strlen( rg_telrep_cor ) != 8

*Check phone number
gen diff = length(rg_telrep) - length(rg_telrep_cor)
order rg_telrep_cor diff, a(rg_telrep)
*browse rg_telrep* diff
drop rg_telrep diff
rename rg_telrep_cor rg_telrep


***********************************************************************
* 	PART 3:  Replace string with numeric values		  			
***********************************************************************
{
*** cleaning capital social ***
gen capitalsocial_corr = rg_capital
replace capitalsocial_corr = ustrregexra( capitalsocial_corr,",","")
replace capitalsocial_corr = ustrregexra( capitalsocial_corr," ","")
replace capitalsocial_corr = ustrregexra( capitalsocial_corr,"dinars","")
replace capitalsocial_corr = ustrregexra( capitalsocial_corr,"dt","")
replace capitalsocial_corr = ustrregexra( capitalsocial_corr,"millions","000")
replace capitalsocial_corr = ustrregexra( capitalsocial_corr,"mill","000")
replace capitalsocial_corr = ustrregexra( capitalsocial_corr,"tnd","")
replace capitalsocial_corr = "10000" if capitalsocial_corr == "10.000"
replace capitalsocial_corr = "1797000" if capitalsocial_corr == "1.797.000"
replace capitalsocial_corr = "50000" if capitalsocial_corr == "50.000"
replace capitalsocial_corr = ustrregexra( capitalsocial_corr,"e","")
replace capitalsocial_corr = ustrregexra( capitalsocial_corr,"m","")
replace capitalsocial_corr = "30000" if capitalsocial_corr == "30000n"

replace capitalsocial_corr = ustrregexra( capitalsocial_corr,"000","") if strlen( capitalsocial_corr) >= 9
replace capitalsocial_corr = "$check_again" if strlen( capitalsocial_corr) == 1
replace capitalsocial_corr = "$check_again" if strlen( capitalsocial_corr) == 2


replace capitalsocial_corr = "$check_again" if capitalsocial_corr == "tunis"

*Test logical values*

* In Tunisia, SCA and SA must have a minimum of 5000 TND of capital social

*All values having a too small capital social (less than 100)
replace capitalsocial_corr = "$check_again" if capitalsocial_corr == "0"
replace capitalsocial_corr = "$check_again" if capitalsocial_corr == "o"
destring capitalsocial_corr, replace

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

local stringvar "rg_fte_femmes id_plateforme rg_fte"
{

foreach x of local stringvar {
destring `x', replace
format `x' %9.1fc
}

{
* calculate absolute profit if profit was provided as a percentage
replace q393_corrige = q393_normalval * c_a if q393_corrige < 1
*/
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
