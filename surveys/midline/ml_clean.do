***********************************************************************
* 			clean do file, midline ecommerce			 			  *					  
***********************************************************************
*																	  
*	PURPOSE: clean the surveys answers					  
*																	  
*	OUTLINE: 		 PART 1: Import the data
*					 PART 2: Removing whitespace & format string & lower case
*					 PART 3: Make all variables names lower case	
*					 PART 4: Label variables  
*					 PART 5: Labvel variables values
*					 PART 6: Save the changes made to the data
*				 	 PART 7:        											
*					 PART 8: 
*					 								  
*	Author:  	 	 Ayoub Chamakhi & Fabian Scheifele					    
*	ID variable: 	 id_plateforme		  					  
*	Requires:  		 Webpresence_answers_intermediate.dta								  
*	Creates:    	 Webpresence_answers_intermediate.dta

***********************************************************************
* 	PART 1:    Import the data
***********************************************************************

use "${ml_intermediate}/ml_intermediate", clear

***********************************************************************
* 	PART 2:    Removing whitespace & format string and date & lower case 
***********************************************************************

	*remove leading and trailing white space

{
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x' = stritrim(strtrim(`x'))
}
}

	*string
ds, has(type string) 
local strvars "`r(varlist)'"
format %-20s `strvars'
	
	*make all string lower case
foreach x of local strvars {
replace `x'= lower(`x')
}




	*fix date
format Date %td

*drop empty rows
drop if id_plateforme ==.

***********************************************************************
* 	PART 3: 	Make all variables names lower case		  			
***********************************************************************
rename *, lower
rename empl fte 
***********************************************************************
* 	PART 4: 	Label the variables		  			
***********************************************************************
* copier-coller pour les variables qui sont identiques à la baseline
* definer des nouvelles labels pour des nouvelles variables

lab var id_plateforme "L'indentité unique de la platforme"
*lab var firmname_change "le nouveau nom de l'entreprise"
*lab var id_ident2 "identifcation de la nouvelle personne"
*lab var repondant_midline "le nom de du répondant"
*lab var position_rep_midline "la fonction du répondant dans l'entreprise"

lab var dig_presence1 "présence sur un site web"
lab var dig_presence2 "présence sur les réseaux sociaux"
lab var dig_presence3 "présence sur une marketplace"

lab var dig_description1 "description entreprise & produit sur site web"
lab var dig_description2 "description entreprise & produit sur les réseaux sociaux"
lab var dig_description3 "description entreprise & produit sur marketplace"

lab var dig_miseajour1 "fréquence mise à jour site web"
lab var dig_miseajour2 "fréquence mise à jour réseaux sociaux"
lab var dig_miseajour3 "fréquence mise à jour marketplace"

lab var dig_payment1 "possibilité de payer/commander sur site web" 
lab var dig_payment2 "possibilité de payer/commander sur réseaux sociaux" 
lab var dig_payment3 "possibilité de payer/commander sur marketplace" 

lab var dig_vente "vente de produits/service en ligne en 2022"
lab var dig_revenues_ecom "chiffre d'affaire ventes en ligne 2022"

lab var dig_marketing_lien "page réseaux social liée au site web"
lab var dig_marketing_ind1  "présence d'objectifs marketing digital"
lab var dig_marketing_ind2  "fréquence mesure des objectifs marketing digital"
lab var dig_marketing_respons "nombre d'émployés chargés activités marketing digital"
/*lab var dig_marketing_num1 "SEA"
lab var dig_marketing_num2 "SEO"
lab var dig_marketing_num3 "Blog"
lab var dig_marketing_num4 "Publicités display dans le web"
lab var dig_marketing_num5 "E-mailing & Newsletters"
lab var dig_marketing_num6 "Partenariat en ligne et affiliation "
lab var dig_marketing_num7 "Marketing gratuit sur les médias sociaux"
lab var dig_marketing_num8 "Publicité payante sur les médias sociaux"
lab var dig_marketing_num9 "autres activité de marketing"
lab var dig_marketing_num10 "aucune activité de marketing"*/
lab var dig_marketing_ind1  "présence d'objectifs marketing digital"
lab var dig_marketing_ind2  "fréquence mesure des objectifs marketing digital"

lab var dig_service_satisfaction "mesure satisfaction clients en ligne"
lab var dig_service_responsable "nombre d'émployés chargés demandes internautes"

lab var investecom_benefit1 "perception coût du marketing digital"
lab var investecom_benefit1 "perception bénéfice du marketing digital"

lab var dig_perception1 "améliorer le positionnement du site sur les moteurs de recherche."
lab var dig_perception2 "analyser les données relatives aux visiteurs du site et médias sociaux"
lab var dig_perception3 "utiliser des publicités payantes ou messages automatisés sur les médias sociaux "
lab var dig_perception4 "vendre les produits/services sur une marketplace (par ex. Jumia, Souk, Amazon) "
lab var dig_perception5 "exporter (plus) grâce aux ventes en ligne "

lab var dig_moyen_paie "les modes de paiements disponible en tunisie"
lab var dig_contenu "aspect d'un bon contenu digital"
lab var dig_techniques_seo "technique d'amélioration du reféréncement naturel"
lab var dig_google_analytics "informations disponible sur google analytics"
lab var dig_taux_eng "éléments utilisés dans le calcul du taux d'engagement"
lab var matricule_miss "matricule fiscale corrigé"
lab var fte "nombre d'employés dans l'entreprise"
lab var car_carempl_div1 "nombre de femmes dans l'entreprise"
lab var car_carempl_div2 "nombre de jeunes dans l'entreprise"
lab var car_carempl_div3 "nombre d'employés à temps partiels dans l'entreprise"
lab var car_carempl_div4 "nombre de d'employés étrangers dans l'entreprise"
lab var car_carempl_div5 "nombre de d'employé repatriés dans l'entreprise"

lab var ssa_action1 "intérêt par un client potentiel en Afrique Sub-Saharienne"
lab var ssa_action2 "identification d'un partenaire commercial susceptible de promouvoir mes produit/services en Afrique Sub-Saharienne"
lab var ssa_action3 "engagement d'un financement externe pour les coûts préliminaires d’exportation"
lab var ssa_action4 "investissement dans la structure de vente sur un marché cible en Afrique Sub-Saharienne"
lab var ssa_action5 "introduction d'un système de facilitation des échanges, innovation numérique"

*lab var tel_supl1 "numéro de téléphone supplémentaire"


***********************************************************************
* 	PART 5: 	Label the variables values	  			
***********************************************************************

local yesnovariables id_ident id_ident2 formation  dig_vente dig_marketing_lien dig_marketing_ind1 dig_service_satisfaction ssa_action1  ssa_action2 ssa_action3 ssa_action4 ssa_action5	

label define yesno 1 "Oui" 0 "Non" -999 "Ne sais pas" 2 "Non" 3 "Nom changé"
foreach var of local yesnovariables {
	label values `var' yesno
}

*make value labels for scale questions (see questionnaire)

***********************************************************************
* 	PART 6: 	Change format of variable  			
***********************************************************************
* Change format of variable

recast int formation
replace formation = 0 if formation ==.


recast int dig_marketing_lien
replace dig_marketing_lien = 0 if dig_marketing_lien ==.

recast int fte car_carempl_div1 car_carempl_div2 car_carempl_div3 car_carempl_div4 car_carempl_div5
recast int dig_marketing_respons dig_service_responsable investecom_benefit1 investecom_benefit2 dig_perception1 dig_perception2 dig_perception3 dig_perception4 dig_perception5 matricule_miss


***********************************************************************
* 	Part 6: Save the changes made to the data		  			
***********************************************************************
cd "$ml_intermediate"
save "ml_intermediate", replace

