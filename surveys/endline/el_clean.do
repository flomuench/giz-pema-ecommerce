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

lab var dig_prix "Marge plus importante grâce aux ventes en ligne"
lab var dig_revenues_ecom "% des ventes par rapport aux chiffres d'affaires total"
lab var dig_ payment_refus "Raisons pour ne pas avoir adopté le paiment en ligne"

lab var dig_presence2_sm1 "Instagram"
lab var dig_presence2_sm2 "Facebook"
lab var dig_presence2_sm3 "Twitter"
lab var dig_presence2_sm4 "Youtube"
lab var dig_presence2_sm5 "LinkedIn"
lab var dig_presence2_sm6 "Autres"

lab var dig_presence3_plateform1 "Little Jneina "
lab var dig_presence3_plateform2 "Founa"
lab var dig_presence3_plateform3 "Made in Tunisia"
lab var dig_presence3_plateform4 "Jumia"
lab var dig_presence3_plateform5 "Amazon"
lab var dig_presence3_plateform6 "Ali baba"
lab var dig_presence3_plateform7 "Upwork"
lab var dig_presence3_plateform8 "Autres"

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
lab var mark_online2 "SEO ou SEA"
lab var mark_online3 "Marketing gratuit sur les médias sociaux"
lab var mark_online4 "Publicité payante sur les médias sociaux"
lab var mark_online5 "Autres activité de marketing"

lab var dig_empl "Nombre d'émployés chargés activités en ligne"
lab var dig_invest "Investissement dans les activités de marketing en ligne en 2023 et 2024"
lab var mark_invest "Investissement dans les activités de marketing hors ligne en 2023 et 2024"

**************************************************
**********Digital Technology Perception***********
**************************************************
lab var investecom_benefit1 "Perception coût du marketing digital"
lab var investecom_benefit2 "Perception bénéfice du marketing digital"

lab var dig_barr1  "Absence/incertitude de la demande en ligne"
lab var dig_barr2  "Manque de main d’oeuvre qualifié"
lab var dig_barr3  "Mauvaise infrastructure"
lab var dig_barr4  "Coût est trop élevé"
lab var dig_barr5  "Régulations gouvernementales contraignantes"
lab var dig_barr6  "Résistance au changement"
lab var dig_barr7  "Autres"
***************************
**********Export***********
***************************
				* Export performance
label var export_1 "Export direct"
label var export_2 "Export indirect"
label var export_3 "Pas d'export"
				
				* reasons for not exporting
label var export_41 "Non rentable"
label var export_42 "N'a pas trouvé de clients à l'étranger"
label var export_43 "Trop compliqué"
label var export_44 "Nécessite un investissement trop important"
label var export_45 "Autres"

label var exp_pays "Nombre de pays d'exportation"
label var cliens_b2c "Nombre de commandes internationales"
label var cliens_b2b "Nombre d'entreprises internationales"
label var exp_dig "Export grâce à la présence digitale"
	
	* Export practices
label var exp_pra_foire "participation à des expositions/foires internationales"
label var exp_pra_sci "Trouver un partenaire commercial ou une société de commerce international"
label var exp_pra_rexp "Recrutement d'une personne chargée de l'exportation"
label var exp_pra_plan "Avoir un plan d'exportation"
label var exp_pra_norme "Certifier le produit"
label var exp_pra_fin "Engagement d'un financement externe pour les coûts préliminaires d'exportation"
label var exp_pra_vent "Investissement dans la structure de vente"
label var exp_pra_ach "Expression d'intérêt par un acheteur étranger potentiel"
	
***************************
**********Accounting*******
***************************
label var q29 "Matricule fiscal"

label var q29_nom "Nom du comptable"
label var q29_tel "Telephone du comptable"
label var q29_mail "Email du comptable"

label var comp_ca2023 "Chiffre d'affaires total en dt en 2023"
label var comp_ca2024 "Chiffre d'affaires total en dt en 2024"

label var compexp_2023 "Chiffre d'affaires à l’export en dt en 2023"
label var compexp_2024 "Chiffre d'affaires à l’export en dt en 2024"

label var comp_benefice2023 "Profit en dt en 2023"
label var comp_benefice2024 "Profit en dt en 2024"

label var profit_2023_category "Catégorie du profit en 2023"
label var profit_2024_category "Catégorie du profit en 2024"

***************************
**********Program**********
***************************
*take_up program questions
label var dropout_why "Raisons pour le désistement du programme"
label var herber_refus "Raisons pour ne pas avoir acheté le domaine d’hébergement du site web"

***********************************************************************
* 	PART 5: 	Label the variables values	  			
***********************************************************************

local yesnovariables id_ident id_ident2 product dig_presence1 dig_presence2 dig_presence3 dig_presence4 dig_payment1 dig_payment2 dig_payment3 dig_prix //
web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand  //
mark_online1 mark_online2 mark_online3 mark_online4 mark_online5 dig_barr1 dig_barr2 dig_barr3 dig_barr4 dig_barr5 dig_barr6 dig_barr7 exp_dig //
exp_pra_foire exp_pra_sci exp_pra_rexp exp_pra_plan exp_pra_norme exp_pra_fin exp_pra_vent exp_pra_ach//   

label define yesno 1 "Oui" 0 "Non" 2 "Non" 3 "Nom changé"
foreach var of local yesnovariables {
	label values `var' yesno
}

*make value labels for scale questions (see questionnaire)
label define five_low_high 1 "Très bas" 2 "Bas" 3 "Moyen" 4 "Haut" 5 "Très haut" 
label values investecom_benefit1 investecom_benefit2 five_low_high


***********************************************************************
* 	PART 6: 	Change format of variable  			
***********************************************************************
* Change format of variable
recast int fte car_carempl_div1 car_carempl_div2 car_carempl_div3 car_carempl_div4

***********************************************************************
* 	PART 7: Removing trail and leading spaces from string variables 			
***********************************************************************
ds, has(type string)
foreach x of varlist `r(varlist)' {
replace `x' = lower(strtrim(`x'))
}
***********************************************************************
* 	Part 8: Save the changes made to the data		  			
***********************************************************************
cd "$el_intermediate"
save "el_intermediate", replace

