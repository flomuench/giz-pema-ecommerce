***********************************************************************
* 			Registration clean									  		  
***********************************************************************
*																	  
*	PURPOSE: clean Registration raw data					  	  			
*																	  
*																	  
*	OUTLINE:														  
*	1)		Format string & numerical variables				          
*	2)   	Drop all text windows from the survey					  
*	3)  	Make all variables names lower case						  
*	4)  	Order the variables in the data set						  	  
*	5)  	Rename the variables									  
*	6)  	Label the variables										  
*   7) 		Label variable values 								 
*   8) 		Removing trailing & leading spaces from string variables										 
*																	  													      
*	Author:  	Florian Muench & Kais Jomaa & Teo Firpo						    
*	ID variable: 	id (identifiant)			  					  
*	Requires: bl_raw.dta 	  										  
*	Creates:  bl_inter.dta			                                  
***********************************************************************
* 	PART 1: 	Format string & numerical variables		  			
***********************************************************************
use "${regis_raw}/regis_raw", clear

{
	* format numerical & string variables
ds, has(type string) 
local strvars "`r(varlist)'"
format %-20s `strvars'

ds, has(type numeric) 
local numvars "`r(varlist)'"
format %-25.0fc `numvars'

	* make all string obs lower case
foreach x of local strvars {
replace `x'= lower(`x')
}
}
	
***********************************************************************
* 	PART 2: 	Drop all text windows from the survey		  			
***********************************************************************
{
*drop VARNAMES
}

***********************************************************************
* 	PART 3: 	Make all variables names lower case		  			
***********************************************************************
rename *, lower

***********************************************************************
* 	PART 4: 	Order the variables in the data set		  			
***********************************************************************
{

}

***********************************************************************
* 	PART 5: 	Rename the variables in line with GIZ contact list final	  			
***********************************************************************
	* identifiant unique correct (oui ou non)
	
				
	* opération d'export
	
	* éligible vs. not éligible

{
	* Section identification
rename identifiant id_plateforme

	* Section informations personnelles répresentantes
rename nometprénom rg_nom
rename titre rg_position 
rename sexe rg_gender
rename télparticipante rg_telrep 
rename emailparticipante rg_emailrep
rename télgérante rg_telpdg
rename emailgérante rg_emailpdg
rename adresse rg_adresse 
rename raisonsociale firmname 

	* Section présence en ligne
rename siteweb rg_siteweb 
rename réseausocial rg_media 

	* Section firm characteristics
			* Legal
rename formejuridique rg_legalstatus
rename matriculecnss rg_matricule 
rename codedouane rg_codedouane
rename entreprise rg_onshore 
			* Controls
rename datedecréation date_created
rename effectiftotal rg_fte
rename nbrdefemmessalariée rg_fte_femmes 
rename capitalsocial rg_capital 
rename domaine sector
rename secteurdactivité subsector
			* Export
rename régime rg_exportstatus
rename opérationdexport rg_export
rename produitserviceexportable rg_exportable 
rename intentiondexporterdansles12 rg_intexp
	
}
***********************************************************************
* 	PART 6: 	Label the variables		  			
***********************************************************************
{
		* Section contact details
*lab var X ""

		* Section eligibility

}



***********************************************************************
* 	PART 7: 	Label variables values	  			
***********************************************************************
{
/*
lab def labelname 1 "" 2 "" 3 ""
lab val variablename labelname
*/
}

***********************************************************************
* 	PART 8: Removing trail and leading spaces in from string variables  			
***********************************************************************
{
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x' = stritrim(strtrim(`x'))
}
}

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
cd "$regis_intermediate"
save "regis_inter", replace
