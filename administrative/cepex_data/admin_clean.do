***********************************************************************
* 			clean do file, admin data			   	       			  *					  
***********************************************************************
*																	  
*	PURPOSE: clean the admin data						  
*																	  
*	OUTLINE: 	PART 1:   clean admin data 
*				PART 2:   drop useless columns 
*				PART 3:   label the data 
*				PART 4:   save admin data                    	
*										  
*																	  
*	Author:  	Ayoub Chamakhi					    
*	ID variable: Id_plateforme		  					  
*	Requires:  	 cp_intermediate.dta								  
*	Creates:     cp_final.dta

***********************************************************************
* 	PART 1:    clean admin data
***********************************************************************
use "${cp_intermediate}/cp_intermediate", clear


*remove leading and trailing white space
{
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x' = stritrim(strtrim(`x'))
}
}

	* numeric 
ds, has(type numeric) 
local numvars "`r(varlist)'"
format %-25.2fc `numvars'

*format %-25.0fc id_plateforme

drop Date_Key 
* format date

format %td FullDate1

***********************************************************************
* 	PART 2:    drop useless columns and rename columns
***********************************************************************

drop Libelle_flux PAYS NSH2_CODE NSH6_CODE
rename CODEDOUANE matricule_fiscale
***********************************************************************
* 	PART 4:    label the data
***********************************************************************

lab var FullDate1 "Full date of export"
lab var Month "Month of export"
lab var Year "Year of export"
lab var matricule_fiscale "Matricule fiscale"
lab var Libelle_operateur "Name of the company"
lab var Libelle_Pays_Anglais "Name of the country exported to"
lab var VALEUR "value of exported goods/service"
lab var POIDS "Weight of exported goods"
lab var QTE "Quantity of exported goods/service"
lab var Libelle_NSH2 "Classification of goods/service"
lab var NDP "NDP ou Nomenclature de Dédouanement des Produits"
lab var Libelle_NSH4 "Detailed classification of goods/service"
lab var Libelle_Secteur "Sector of the exported good/service"
lab var Libelle_Section "Section of the exported good/service"


label define Libelle_Section 1 "SECTION I - ANIMAUX VIVANTS ET PRODUITS DU REGNE ANIMAL"  ///
2 "SECTION II - PRODUITS DU REGNE VEGETAL" 3 "SECTION IV - PRODUITS DES INDUSTRIES ALIMENTAIRES; BOISSONS, LIQUIDES ALCOOLIQUES ET VINAIGRES; TABACS ET SUCCEDANES DE TABAC FABRIQUES" ///
4 "SECTION V - PRODUITS MINERAUX" 5 "SECTION VI - PRODUITS DES INDUSTRIES CHIMIQUES OU DES INDUSTRIES CONNEXES" ///
6 "SECTION IX - BOIS, CHARBON DE BOIS ET OUVRAGES EN BOIS; LIEGE ET OUVRAGES EN LIEGE; OUVRAGES DE SPARTERIE OU DE VANNERIE" ///
7 "SECTION X - PATES DE BOIS OU D'AUTRES MATIERES FIBREUSES CELLULOSIQUES; PAPIER OU CARTONA RECYCLER (DECHETS ET REBUTS); PAPIER ET SES APPLICATIONS" ///
8 "SECTION XI - MATIERES TEXTILES ET OUVRAGES EN CES MATIERES" 9 "SECTION XV - METAUX COMMUNS ET OUVRAGES EN CES METAUX" ///
10 "SECTION XX - MARCHANDISES ET PRODUITS DIVERS"


***********************************************************************
* 	PART 5:    save admin data
***********************************************************************
save "${cp_intermediate}/cp_intermediate", replace
