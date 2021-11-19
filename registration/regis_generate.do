***********************************************************************
* 			registration generate									  	  
***********************************************************************
*																	    
*	PURPOSE: generate registration variables				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) sector
* 	2) gender
* 	3) onshore / offshore  							  
*	4) produit exportable  
*	5) intention d'exporter 			  
*	6) une opération d'export				  
*   7) export status  
*	8) age
*	9) eligibility	
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


***********************************************************************
* 	PART 2: factor variable sector & subsector 			  										  
***********************************************************************
label define sector_name 1 "Agriculture & Peche" ///
	2 "Artisanat" ///
	3 "Commerce international" ///
	4 "Industrie" ///
	5 "Services" ///
	6 "TIC" 

label define subsector_name 1 "agriculture" ///
	2 "architecture" ///
	3 "artisanat" ///
	4 "assistance" ///
	5 "audit" ///
	6 "autres" ///
	7 "centre d'appel" ///
	8 "commerce international" ///
	9 "développement informatique" ///
	10 "enseignement" ///
	11 "environnement et formation" ///
	12 "industries diverses" ///
	13 "industries mécaniques et électriques" ///
	14 "industries agro-alimentaires" ///
	15 "industries chimiques" ///
	16 "industries des matériaux de construction, de la céramique et du verre" ///
	17 "industries du cuir et de la chaussure" ///
	18 "industries du textile et de l'habillement" ///
	19 "pêche" ///
	20 "réseaux et télécommunication" ///
	21 "services et études dans le domaine de batîment"

tempvar Sector
encode sector, gen(`Sector')
drop sector
rename `Sector' sector
lab values sector sector_name

tempvar Subsector
encode subsector, gen(`Subsector')
drop subsector
rename `Subsector' subsector
lab values subsector subsector_name


format %-25.0fc *sector

***********************************************************************
* 	PART 2: factor variable gender 			  										  
***********************************************************************
label define sex 1 "female" 0 "male"
tempvar Gender
encode rg_gender, gen(`Gender')
drop rg_gender
rename `Gender' rg_gender_rep
replace rg_gender = 0 if rg_gender == 2
lab values rg_gender sex

tempvar Genderpdg
encode rg_sex_pdg, gen(`Genderpdg')
drop rg_sex_pdg
rename `Genderpdg' rg_gender_pdg
replace rg_gender_pdg = 0 if rg_gender_pdg == 2
lab values rg_gender_pdg sex

***********************************************************************
* 	PART 3: factor variable onshore 			  										  
***********************************************************************
lab def onshore 1 "résidente" 0 "non résidente"
encode rg_onshore, gen(rg_resident)
replace rg_resident = 0 if rg_resident == 1
replace rg_resident = 1 if rg_resident == 2
drop rg_onshore
lab val rg_resident onshore
lab var rg_resident "HQ en Tunisie"

***********************************************************************
* 	PART 4: factor variable produit exportable		  										  
***********************************************************************
lab def exportable 1 "produit exportable" 0 "produit non exportable"
encode rg_exportable, gen(rg_produitexp)
replace rg_produitexp = 0 if rg_produitexp == 1
replace rg_produitexp = 1 if rg_produitexp == 2
drop rg_exportable
lab val rg_produitexp exportable
lab var rg_produitexp "Entreprise pense avoir un produit exportable"

***********************************************************************
* 	PART 5: factor variable intention exporter			  										  
***********************************************************************
lab def intexp 1 "intention export" 0 "pas d'intention à exporter"
encode rg_intexp, gen(rg_intention)
replace rg_intention = 0 if rg_intention == 1
replace rg_intention = 1 if rg_intention == 2
drop rg_intexp
lab val rg_intention intexp
lab var rg_intention "Entreprise a l'intention d'exporter dans les prochains 12 mois"

***********************************************************************
* 	PART 6: dummy une opération d'export			  										  
***********************************************************************
lab def oper_exp 1 "Opération d'export" 0 "Pas d'opération d'export"
encode rg_export, gen(rg_oper_exp)
replace rg_oper_exp = 0 if rg_oper_exp == 1
replace rg_oper_exp = 1 if rg_oper_exp == 2
drop rg_export
lab val rg_oper_exp oper_exp
lab var rg_oper_exp "Entreprise a realisé une opération d'export"

***********************************************************************
* 	PART 7: factor variable export status		  										  
***********************************************************************
encode rg_exportstatus, gen(rg_expstatus)
drop rg_exportstatus
lab var rg_expstatus "Régime d'export de l'entreprise"


***********************************************************************
* 	PART 8: age
***********************************************************************
gen rg_age = round((td(30nov2021)-date_created)/365.25,2)
order rg_age, a(date_created)

***********************************************************************
* 	PART 8: dummy site web ou réseau social
***********************************************************************
gen presence_enligne = (rg_siteweb != "" | rg_media != ""), b(rg_siteweb)
lab def enligne 1 "présente enligne" 0 "ne pas présente enligne"
lab values presence_enligne enligne

***********************************************************************
* 	PART 10: eligibiliy dummy
***********************************************************************
gen eligible = (id_admin_correct == 1 & rg_resident == 1 & rg_fte >= 6 & rg_fte <= 199 & rg_produitexp == 1 & rg_intention == 1 & rg_oper_exp == 1 & rg_age>=2)
lab def eligible 1 "éligible" 0 "inéligible"
lab val eligible eligible

gen eligible_sans_matricule = (rg_resident == 1 & rg_fte >= 6 & rg_fte <= 199 & rg_produitexp == 1 & rg_intention == 1 & rg_oper_exp == 1 & rg_age>=2)
lab def eligible2 1 "éligible sans matricule" 0 "inéligible sans matricule"
lab val eligible_sans_matricule eligible2

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
cd "$regis_intermediate"
save "regis_inter", replace
