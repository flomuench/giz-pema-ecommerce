***********************************************************************
* 			registration generate									  	  
***********************************************************************
*																	    
*	PURPOSE: generate registration variables				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		 create factor variables
							* sector
							* gender
							* onshore / offshore
* 	2) 		
*	3)   							  
*	4)  		  				  
*	5)  			  
*	6)  					  
*   7)                         
*	8)		
*	9)		
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
* 	PART 2: create factor variables from categorical string variables				  										  
***********************************************************************

******************** sector & subsector 
label define sector_name 1 "Agriculture & Peche" ///
	2 "Artisanat" ///
	3 "Commerce international" ///
	4 "Industrie" ///
	5 "Services" ///
	6 "TIC" ///

label define subsector_name 1 "agriculture" ///
	2 "architecture" ///
	3 "artisanat" ///
	4 "assitance" ///
	5 "audit" ///
	6 "autres" ///
	7 "centre d'appel" ///
	8 "commerce international" ///
	9 "développement informatique" ///
	10 "enseignement" ///
	11 "environnement et formation" ///
	12 "industries chimiques" ///
	13 "industries des matériaux de construction, de la céramique et du verre" ///
	14 "stries du cuir et de la chaussure" ///
	15 "industries du textile et de l'habillement" ///
	16 "pêche" ///
	17 "réseaux et télécommunication" 

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

******************** gender
label define sex 1 "female" 0 "male"
tempvar Gender
encode rg_gender, gen(`Gender')
drop rg_gender
rename `Gender' rg_gender
replace rg_gender = 0 if rg_gender == 2
lab values rg_gender sex

******************** onshore
encode rg_onshore, gen(rg_resident)
drop rg_onshore
lab var rg_resident "HQ en Tunisie"

******************** produit exportable
encode rg_exportable, gen(rg_produitexp)
drop rg_exportable
lab var rg_produitexp "Entreprise pense avoir un produit exportable"

******************** intention exporter
encode rg_intexp, gen(rg_intention)
drop rg_intexp
lab var rg_intention "Entreprise a l'intention d'exporter dans les prochains 12 mois"

******************** une opération d'export
encode rg_export, gen(rg_oper_exp)
drop rg_export
lab var rg_oper_exp "Entreprise exprime avoir réalisé au moins une opération d'export"


	* export status
label def total_export 1 "totalement exportatrice" 0 "non totalement exportatrice"
tempvar Export
encode export, gen(`export_status) label(total_export) noextend
drop export
rename `Export' export
