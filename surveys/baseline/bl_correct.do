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
gen needs_check = 0
gen questions_needing_checks = ""
gen commentsmsb = ""
*/
}


* Needs check
//replace needs_check = 1 if id_plateforme = 572== "a"
//replace needs_check = 1 if id_plateforme = 572 == "aa"
replace needs_check = 1 if comp_benefice2020 == "§§"
replace needs_check = 1 if comp_benefice2020 == "na"
replace needs_check = 1 if exp_pays_21 ==200

* Questions needing check
replace questions_needing_check = "investcom_2021/investcom_futur" if id_plateforme==572
replace questions_needing_check = "exp_pays_21" if id_plateforme==757
replace questions_needing_check = "comp_benefice2020" if id_plateforme==592
replace questions_needing_check = "comp_benefice2020" if id_plateforme==148


***********************************************************************
* 	PART 2: use regular expressions to correct variables 		  			
***********************************************************************
/* for reference and guidance, regularly these commands are used in this section
gen XXX = ustrregexra(XXX, "^216", "")
gen id_adminrect = ustrregexm(id_admin, "([0-9]){6,7}[a-z]")

*replace id_adminrige = $check_again if id_adminrect == 1
lab def correct 1 "correct" 0 "incorrect"
lab val id_adminrect correct

*/

* Correction des variables investissement
replace investcom_2021 = ustrregexra( investcom_2021,"k","000")
replace investcom_futur = ustrregexra( investcom_futur,"dinars","")
replace investcom_futur = ustrregexra( investcom_futur,"dt","")
replace investcom_futur = ustrregexra( investcom_futur,"k","000")

* Enlever tout les déterminants du nom des produits
{
replace entr_produit1 = ustrregexra( entr_produit1 ,"la ","")
replace entr_produit1 = ustrregexra( entr_produit1 ,"le ","")
replace entr_produit1 = ustrregexra( entr_produit1 ,"les ","")
replace entr_produit1 = ustrregexra( entr_produit1 ,"un ","")
replace entr_produit1 = ustrregexra( entr_produit1 ,"une ","")
replace entr_produit1 = ustrregexra( entr_produit1 ,"des ","")

replace entr_produit2 = ustrregexra( entr_produit2 ,"la ","")
replace entr_produit2 = ustrregexra( entr_produit2 ,"le ","")
replace entr_produit2 = ustrregexra( entr_produit2 ,"les ","")
replace entr_produit2 = ustrregexra( entr_produit2 ,"un ","")
replace entr_produit2 = ustrregexra( entr_produit2 ,"une ","")
replace entr_produit2 = ustrregexra( entr_produit2 ,"des ","")

replace entr_produit3 = ustrregexra( entr_produit3 ,"la ","")
replace entr_produit3 = ustrregexra( entr_produit3 ,"le ","")
replace entr_produit3 = ustrregexra( entr_produit3 ,"les ","")
replace entr_produit3 = ustrregexra( entr_produit3 ,"un ","")
replace entr_produit3 = ustrregexra( entr_produit3 ,"une ","")
replace entr_produit3 = ustrregexra( entr_produit3 ,"des ","")
}

* Remplacer tout les points par des virgules & Enlever les virgules au niveau des numéros de téléphone



***********************************************************************
* 	PART 3:  Replace string with numeric values		  			
***********************************************************************
{
*Remplacer les textes de la variable investcom_2021
replace investcom_2021 = "100000" if investcom_2021== "100000dt"
replace investcom_2021 = "18000" if investcom_2021== "huit mille dinars"
replace investcom_2021 = "0" if investcom_2021== "zéro"
replace investcom_2021 = "7628248" if investcom_2021== "7628248,000 dt"
replace investcom_2021 = "1000" if investcom_2021== "moins que 1000dt"

*Remplacer les textes de la variable investcom_futur
replace investcom_futur = "77777777777777777" if investcom_futur == "je sais pas encore"
replace investcom_futur = "77777777777777777" if investcom_futur == "ne sais pas"
replace investcom_futur = "20000" if investcom_futur == "vingt mille dinars"
replace investcom_futur = "20000" if investcom_futur == "vingt mille "
replace investcom_futur = "10000" if investcom_futur == "dix milles"
replace investcom_futur = "15000" if investcom_futur == "10 000 à 20 000"
replace investcom_futur = "7000" if investcom_futur == "sept milles  (7000)"

*Correction de la variable compexp_2020
replace compexp_2020 = "794596" if compexp_2020== "794 596.000"
replace compexp_2020 = "110000" if compexp_2020== "110 000"
replace compexp_2020 = "7628248" if compexp_2020== "7628248000"
replace compexp_2020 = "1566010" if compexp_2020== "1.566.010"

*Correction de la variable comp_ca2020
replace comp_ca2020 = "993245" if comp_ca2020== "993 245,000"
replace comp_ca2020 = "304379" if comp_ca2020== "304 379"
replace comp_ca2020 = "10000000" if comp_ca2020== "10 000 000"
replace comp_ca2020 = "7628248" if comp_ca2020== "7628248000"
replace comp_ca2020 = "3039336" if comp_ca2020== "3 039 336"
replace comp_ca2020 = "5351160" if comp_ca2020== "5.351.160"
replace comp_ca2020 = "6987385,476" if comp_ca2020== "6987385.476"

*Correction de la variable dig_revenues_ecom
replace dig_revenues_ecom = "200000" if dig_revenues_ecom== "200 000"
replace dig_revenues_ecom = "11131" if dig_revenues_ecom== "11 131"

*Correction de la variable comp_benefice2020
replace comp_benefice2020 = "337892" if comp_benefice2020== "337 892"
replace comp_benefice2020 = "317887,923" if comp_benefice2020== "317 887,923"
replace comp_benefice2020 = "28929" if comp_benefice2020== "28 929"
replace comp_benefice2020 = "550000" if comp_benefice2020== "550 000"
replace comp_benefice2020 = "191805" if comp_benefice2020== "191805000"


}
***********************************************************************
* 	PART 4:  Convert string to numerical variaregises	  			
***********************************************************************
* local destrvar XX
*foreach x of local destrvar { 
*destring `x', replace



***********************************************************************
* 	PART 5:  Convert problematic values for open-ended questions  			
***********************************************************************
{

	* Sectionname
*replace q04 ="Hors sujet" if q04 == "OUI" 

*Correction nom du representant
*gen rg_nom_repr= rg_nom_rep            
*replace rg_nom_repr="$check_again" if rg_nom_rep == "Études géomatiques." 

* Correction de la variable investcom_2021
replace investcom_2021 = "88888888888888888" if investcom_2021== "a"




* Correction de la variable investcom_futur
replace investcom_futur = "88888888888888888" if investcom_futur== "aa"

 
}

***********************************************************************
* 	PART 6:  Traduction reponses en arabe au francais		  			
***********************************************************************
{
*Traduction des produits principaux de l'entreprise
replace entr_produit1 = "Farine à la tomate" if entr_produit1 == "فارينة طماطم"
replace entr_produit2 = "Farine aux oignons" if entr_produit2 == "فارينة بصل"
replace entr_produit3 = "farine à l'ail" if entr_produit3 == "فارينة ثوم"
replace entr_produit1 = "matériel éléctrique" if entr_produit1 == "المواد الكهربائية"
replace entr_produit2 = "matériaux de construction" if entr_produit2 == "مواد البناء"
replace entr_produit3 = "produits agro-alimentaires" if entr_produit3 == "الصناعات الغذائية"


*Traduction histoire de l'entreprise
replace entr_histoire = "International Trading and Consulting Company est une société entièrement exportatrice créée en 2006, caractérisée par une vaste expérience dans le domaine du commerce international et sa mission principale est d'améliorer l'activité des clients en fournissant la meilleure valeur pour leurs investissements dans le monde." if entr_histoire == "الشركة الدولية للتجارة والاستشارة هي شركة مصدرة بالكامل تأسست سنة 2006, تتميز بخبرة واسعة في مجال التجارة الدولية وتتمثل مهمتها الأساسية في تعزيز أعمال العملاء من خلال تقديم أفضل قيمة لاستثماراتهم في العالم، كما تقدم الشركة خدمات استشارية تمحور بالاساس حول طرق تقليل تكاليف الشراء والنقل وتسهيل عمل الحرفاء."

*Traduction avantage commerce électronique
replace investcom_benefit3_1 = "Expansion vers de nouveaux marchés" if investcom_benefit3_1 == "فتح أسواق جديدة"
replace investcom_benefit3_2 = "Renforcer la position de l'entreprise dans le monde et créer des liens de confiance avec les clients" if investcom_benefit3_2 == "تعزيز مكانة الشركة حول العالم وخلق روابط للثقة في علاقتها مع الحرفاء"
replace investcom_benefit3_3 = "Améliorer la notoriété de la marque de l'entreprise" if investcom_benefit3_3 == "تعزيز الوعي بالعلامة التجارية للشركة"

*Traduction des produits exportés en 2021
replace exp_produit_services21 = "farine" if exp_produit_services21 == "فارينة"
replace exp_produit_services21 = "Matériel électrique" if exp_produit_services21 == "مواد كهربائية"

*Traduction attente du projet
replace car_attend1 = "Apprendre de nouvelles méthodes en améliorant notre présence en ligne"  if car_attend1 == "تعلم أساليب جديدة من خلال و تعزيز الحضور على الإنترنت"
replace car_attend2 = "Corriger certains concepts mal utilisés et apprendre de nouvelles techniques"  if car_attend2 == "تصحيح بعض المفاهيم التي لم يقع استعمالها بشكل صحيح، وتعلم تقنيات جديدة"
replace car_attend3 = "Ouvrir de nouveaux horizons"  if car_attend3 == "فتح أفق جديدة"

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
* 	PART 9:  Convert data types to the appropriate format
***********************************************************************
* Convert string variable to integer variables


*Test logical values*

*All values having a too small capital social (less than 100)
*replace capitalsocialr = "$check_again" if capitalsocialr == "0"
*replace capitalsocialr = "$check_again" if capitalsocialr == "o"
*destring capitalsocialr, replace

*replace needs_check = 1 if   comp_ca2020< compexp_2020
*replace needs_check = 1 if  comp_ca2020 < dig_revenues_ecom
*replace needs_check = 1 if  comp_ca2020 < comp_benefice2020

***********************************************************************
* 	PART 10:  Identify duplicates (for removal see bl_generate)
***********************************************************************
	* formating the variables for whcih we check duplicates
*format firmname rg_emailrep rg_emailpdg %-35s
*format id_plateforme %9.0g
*sort firmname
	
	* id_plateform
*duplicates report id_plateform

	* email
*duplicates report rg_emailrep
*duplicates report rg_emailpdg
*duplicates tag rg_emailpdg, gen(dup_emailpdg)

	* firmname	
*duplicates report firmname
*duplicates tag firmname, gen(dup_firmname)


***********************************************************************
* 	PART 11:  autres / miscallaneous adjustments
***********************************************************************
	* correct the response categories for moyen de communication
*replace moyen_com = "site institution gouvernmentale" if moyen_com == "site web d'une autre institution gouvernementale" 
*replace moyen_com = "bulletin d'information giz" if moyen_com == "bulletin d'information de la giz"

	* correct wrong response categories for subsectors
*replace subsector = "industries chimiques" if subsector == "industrie chimique"

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
cd "$bl_intermediate"
save "bl_inter", replace

***********************************************************************
* 	Export an excel sheet with needs_check variables  			
***********************************************************************

cd "$bl_checks"

export excel id_plateforme needs_check questions_needing_check date-dz using "fiche_correction" if needs_check==1, firstrow(variables) replace
