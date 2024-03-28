***********************************************************************
* 			clean do file, endline ecommerce			 			  *					  
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
*	Author:  	 	 Kaïs Jomaa					    
*	ID variable: 	 id_plateforme		  					  
*	Requires:  		 el_intermediate.dta									  
*	Creates:    	 el_intermediate.dta

***********************************************************************
* 	PART 1:    Import the data
***********************************************************************

use "${el_intermediate}/el_intermediate", clear

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
lab var firmname_change "le nouveau nom de l'entreprise"
lab var id_ident2 "identifcation de la nouvelle personne"
lab var repondant_midline "le nom de du répondant"
lab var position_rep_midline "la fonction du répondant dans l'entreprise"

**********L'entreprise*********** 
lab var product "Produit/service principal de l'entreprise"
lab var product_new "Nouveau produit/service principal de l'entreprise"
lab var inno_produit "Nombre de nouveaux produits"
lab var clients "Type du client type: B2B, B2C ou les deux"

lab var fte "Nombre d'employés dans l'entreprise"
lab var car_carempl_div1 "Nombre de femmes dans l'entreprise"
lab var car_carempl_div2 "Nombre de jeunes dans l'entreprise (moins de 36 ans)"
lab var car_carempl_div3 "Nombre de jeunes dans l'entreprise (moins de 24 ans)"
lab var car_carempl_div4 "Nombre de d'employés à temps plein dans l'entreprise"

************************************************
**********Digital Technology Adoption***********
************************************************


*****Ventes et service commercial*****
lab var dig_presence1 "Présence sur un site web"
lab var dig_presence2 "Présence sur les réseaux sociaux"
lab var dig_presence3 "Présence sur une marketplace"
lab var dig_presence4 "En presentiel ou par tel/mail"

lab var dig_payment1 "Possibilité de payer en hors ligne"
lab var dig_payment2 "Possibilité de payer/commander sur site web"  
lab var dig_payment3 "Possibilité de payer/commander via une plateforme"

lab var dig_prix "Marge plus importante grace aux ventes en ligne"
lab var dig_revenues_ecom "% des ventes par rapport aux chiffres d'affaires total"
lab var dig_ payment_refus "Raisons pour ne pas avoir adopté le paiment en ligne"

lab var dig_presence3_plateform1 "Little Jneina "
lab var dig_presence3_plateform2 "Founa"
lab var dig_presence3_plateform3 "Made in Tunisia"
lab var dig_presence3_plateform4 "Jumia"
lab var dig_presence3_plateform5 "Amazon"
lab var dig_presence3_plateform6 "Ali baba"
lab var dig_presence3_plateform7 "Upwork"
lab var dig_presence3_plateform8 "Autres"

lab var dig_presence2_sm1 "Instagram"
lab var dig_presence2_sm2 "Facebook"
lab var dig_presence2_sm3 "Twitter"
lab var dig_presence2_sm4 "Youtube"
lab var dig_presence2_sm5 "LinkedIn"
lab var dig_presence2_sm6 "Autres"

lab var web_use_contacts "Details des contacts de l'entreprise sur le site web"
lab var web_use_catalogue "Cataloguer les biens et services sur le site web" 
lab var web_use_engagement "Etudier le comportement des clients sur le site web" 
lab var web_use_com  "Communiquer avec les clients sur le site web"
lab var web_use_brand  "Promouvoir une image de marque sur le site web"

lab var sm_use_contacts "Details des contacts de l'entreprise sur les reseaux sociaux"
lab var sm_use_catalogue  "Cataloguer les biens et services sur les reseaux sociaux" 
lab var sm_use_engagement "Etudier le comportement des clients sur les reseaux sociaux" 
lab var sm_use_com  "Communiquer avec les clients sur les reseaux sociaux"
lab var sm_use_brand "Promouvoir une image de marque sur les reseaux sociaux"

lab var dig_miseajour1 "Fréquence mise à jour site web"
lab var dig_miseajour2 "Fréquence mise à jour réseaux sociaux"
lab var dig_miseajour3 "Fréquence mise à jour marketplace"


*****Marketing et Communication*****
lab var mark_online1 "E-mailing & Newsletters"
lab var mark_online2 "SEO or SEA"
lab var mark_online3 "Marketing gratuit sur les médias sociaux"
lab var mark_online4 "Publicité payante sur les médias sociaux"
lab var mark_online5 "Autres activité de marketing"

lab var dig_empl "Nombre d'émployés chargés activités en ligne"

**************************************************
**********Digital Technology Perception***********
**************************************************
lab var investecom_benefit1 "perception coût du marketing digital"
lab var investecom_benefit1 "perception bénéfice du marketing digital"










***************************
**********Export***********
***************************
				* Export performance
label var export_1 "direct export"
label var export_2 "indirect export"
label var export_3 "no export"
						* reasons for not exporting
label var export_41 "not profitable"
label var export_42 "did not find clients abroad"
label var export_43 "too complicated"
label var export_44 "requires too much investment"
label var export_45 "other"

label var exp_pays "number of export countries"
label var cliens_b2c "number of international order"
label var cliens_b2b "number of international companies"

	
	* Export readiness
label var exp_pra_foire "participation in international exhibition/trade fairs"
label var q27_3 "Hiring a person in charge of commercial activities related to export"
label var q27_6 "maintain or develop an export plan"
label var q27_11 "marketing to attract foreign customers"
label var q27_12 "commitment of external funding for preliminary export costs"

	
            * comptabilité
label var employes "number of full-time employees"
label var q29 "matricule fiscale"

label var q29_nom "accountant's name"
label var q29_tel "accountant's phone number"
label var q29_mail "accountant's email"
label var q29_accord1 "initial agreement to share matricule fiscale"
label var q29_accord2 "final agreement to share matricule fiscale"

label var q391 "export turnover in 2022 in dt"
label var q392 "turnover of sales in tunisia in dt in 2022"
label var q393 "company profit in 2022 in dt"
label var q394 "the current value of all the equipment that the company used for its production in 2022"
label var q395 "the amount the company paid for its inputs in 2022"











lab var dig_vente "vente de produits/service en ligne en 2022"
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

lab var ssa_action1 "intérêt par un client potentiel en Afrique Sub-Saharienne"
lab var ssa_action2 "identification d'un partenaire commercial susceptible de promouvoir mes produit/services en Afrique Sub-Saharienne"
lab var ssa_action3 "engagement d'un financement externe pour les coûts préliminaires d’exportation"
lab var ssa_action4 "investissement dans la structure de vente sur un marché cible en Afrique Sub-Saharienne"
lab var ssa_action5 "introduction d'un système de facilitation des échanges, innovation numérique"

lab var tel_supl1 "numéro de téléphone supplémentaire"


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
* 	Part 7: Save the changes made to the data		  			
***********************************************************************
cd "$el_intermediate"
save "el_intermediate", replace

