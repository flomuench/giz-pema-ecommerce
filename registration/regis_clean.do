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
* 	PART 1: 	Format string & numerical & date variables		  			
***********************************************************************
use "${regis_raw}/regis_raw", clear

{
	* string
ds, has(type string) 
local strvars "`r(varlist)'"
format %-20s `strvars'

	* make all string obs lower case
foreach x of local strvars {
replace `x'= lower(`x')
}
	* numeric 
ds, has(type numeric) 
local numvars "`r(varlist)'"
format %-25.0fc `numvars'

	* dates
		* creation
gen datedecréation = date(Datedecréation, "DMY")
order datedecréation, a(Datedecréation)
format datedecréation %td
rename Datedecréation date_created_str
		* registration
format Dateinscription %td

}
	
***********************************************************************
* 	PART 2: 	Drop all text windows from the survey		  			
***********************************************************************
{
*drop VARNAMES
drop Groupe
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
{
	* Section identification
rename id id_plateforme

	* Section informations personnelles répresentantes
rename nometprénomdudelaparticipa rg_nom_rep
rename qualitéfonction rg_position_rep
rename sexe rg_gender_rep
rename téléphonedudelaparticipante rg_telrep 
rename adressemaildudelaparticipan rg_emailrep
rename téléphonedudelagérante rg_telpdg
rename adressemaildudelagérante rg_emailpdg
rename sexedudelagérante rg_sex_pdg
rename adressesiègesociale rg_adresse 
rename raisonsociale firmname 

	* Section présence en ligne
rename sitedelentreprise rg_siteweb 
rename réseausocialdelentreprise rg_media 

	* Section firm characteristics
			* Legal
rename formejuridique rg_legalstatus
rename matriculecnss rg_matricule 
rename identifiantunique id_admin
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
rename avezvousentaméuneopérationd rg_export
rename estcequevousavezunproduit rg_exportable 
rename avezvouslintentiondexporter rg_intexp

	* Section suivi
rename commentavezvousapprisdelex moyen_com
rename politiquedeconfidentialité rg_confidentialite
rename partagerutiliserlesdonnéesco rg_partage_donnees
rename enregistrermescoordonnéessur rg_enregistrement_coordonnees
	
}
***********************************************************************
* 	PART 6: 	Label the variables		  			
***********************************************************************
{
		* Section contact details
*lab var X ""
label variable rg_nom_rep "nom et prénom du representant"
label variable rg_position_rep "qualité & fonction du representant"
label variable rg_sex_rep "Representative gender (1 = female)"
label variable rg_telrep "téléphone du representant"
label variable rg_emailrep "adresse mail du representant"
label variable rg_telpdg "téléphone du PDG"
label variable rg_emailpdg "adresse mail du PDG"
label variable rg_sex_pdg "CEO gender (1 = female)"
label variable rg_adresse "adresse du siège social"
label variable firmname "nom de l'entreprise"

	* Section présence en ligne
label variable rg_siteweb "site web de l'entreprise"
label variable rg_media "réseau  social de l'entreprise"

	* Section firm characteristics
			* Legal
label variable rg_legalstatus "forme juridique"
label variable rg_matricule "matricule CNSS"
label variable id_admin "matricule fiscale"
label variable rg_codedouane "code douane"
label variable rg_onshore "entreprise résidente en Tunisie"

			* Controls
label variable date_created "Date création de l'entreprise"
label variable rg_fte "employees"
label variable rg_fte_femmes "female employees"
label variable rg_capital "capital"
label variable sector "domaine"
label variable subsector " secteur d'acvitivté"
label var rg_age "age"

			* Export
label variable rg_exportstatus "régime d'exportation"
label variable rg_export "est-ce que l'entreprise a au moins une opération d'export"
label variable rg_exportable "est ce que l'entreprise a un produit exportable"
label variable rg_intexp "intention to export"

	* Section suivi
label variable moyen_com "communication channel"
label variable rg_confidentialite "Partager utiliser les données confidentielles"
label variable rg_partage_donnees "Partager/utiliser les données collectées et anonymisées"
label variable rg_enregistrement_coordonnees "Enregistrer mes coordonnées sur sa base de données"

		* Section eligibility
}



***********************************************************************
* 	PART 7: 	Label variables values	  			
***********************************************************************

/*
lab def labelname 1 "" 2 "" 3 ""
lab val variablename labelname
*/

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
* 	PART 9: translation
***********************************************************************
	* means of communication
replace moyen_com = "giz newsletter" if moyen_com == "bulletin d'information giz"
replace moyen_com = "government website" if moyen_com == "site institution gouvernmentale"
replace moyen_com = "giz website" if moyen_com == "site web de la giz"
replace moyen_com = "cepex website" if moyen_com == "site web du cepex"


***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
cd "$regis_intermediate"
save "regis_inter", replace
