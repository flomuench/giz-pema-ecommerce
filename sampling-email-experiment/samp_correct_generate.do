***********************************************************************
* 			email experiment - correct, generate								  		  
***********************************************************************
*																	   
*	PURPOSE: correct variables (e.g. gender based on firm ceo), create					  								  
*	new variables
*																	  
*	OUTLINE:														  
*	1)	create dependant variable													  
*	2)	 
*	3)	 
*	4) 	 
*																 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_final.dta & regis_corrected_matches 
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data + save it in samp_final folder				  										  *
***********************************************************************
use "${samp_final}/email_experiment", clear


***********************************************************************
* 	PART 1: create dependent variable
***********************************************************************

gen registered = .
replace registered = 1 if sample == 1
replace registered = 0 if sample == 2

***********************************************************************
* 	PART 2: correct dammaged sector levels
***********************************************************************
	* first create a numeric sector variable based on API categories
drop Sector
label define samp_sector_name 1 "Autres industries extractives" ///
	2 "Autres industries manufacturières" ///
	3 "Cokefaction, raffinage, industries nucléaires" ///
	4 "Fabrication d'autres produits non métalliques" ///
	5 "Fabrication d'equipements électriques et électroniques" ///
	6 "Fabrication de machines et équipements" ///
	7 "Fabrication de matériel de transport" ///
	8 "Industrie chimique" ///
	9 "Industrie du caoutchouc et des plastiques" ///
	10 "Industrie du papier et du carton, édition et imprimerie" ///
	11 "Industries agricoles et alimentaires" ///
	12 "Industries du cuir et de la chaussure" ///
	13 "Industries textiles et habillement" ///
	14 "Métallurgie et travail des métaux" ///
	15 "Travail du bois et fabrication d'articles en bois"

	* sector
lab values sector samp_sector_name

	* second create a string sector variable to use for visualisation
decode sector, gen(Sector)

***********************************************************************
* 	PART end: save in samp folder
***********************************************************************
	* change folder 
cd "$samp_final"
save "email_experiment", replace
