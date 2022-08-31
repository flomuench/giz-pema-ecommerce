***********************************************************************
* 			correct do file, second part baseline e-commerce				  
***********************************************************************
*																	  
*	PURPOSE: 
*																	  
*	OUTLINE: 	PART 1: Import the data
*				PART 2: Turn binary questions numerical	
*				PART 3: Recode observations
*				PART 4: Fix missing values
*				PART 5: Save the data
*													
*																	  
*	Author:  								    
*	ID variable: 		  					  
*	Requires:  	Webpresence_answers_intermediate.dta
*	Creates:	Webpresence_answers_intermediate.dta

***********************************************************************
* 	PART 1: Import the data
***********************************************************************

use "${bl2_intermediate}/Webpresence_answers_intermediate", clear

***********************************************************************
* 	PART 2: Turn binary questions numerical
***********************************************************************

local binaryvars Lentreprisedisposetelledun Lecontenuestillisiblepare Leproduitserviceestildécrit Ladescriptionduproduitservic Lesitecomportetilunesectio Lesiteprésentetildesnormes Danslecasducommerceinterent Lesiteestilproposédansune Existetildesliensversunma U Lapageduréseausocialcomport Lapageduréseausocialcontien Lapageduréseausocialcontie Estcequelentreprisepossède Lapagedisposetelledelopti AK Leprofildelentreprisecontie Leprofildelentreprisefourni
 
foreach var of local binaryvars {
	capture replace `var' = "1" if strpos(`var', "oui")
	capture replace `var' = "0" if strpos(`var', "non")

}

***********************************************************************
*	PART 3: Recode observations 
***********************************************************************

	*rsocial media and website name and logo existance
local logonamevars social_logoname web_logoname
foreach var of local logonamevars {
	capture replace `var' = "1" if strpos(`var', "nom et logo")
	capture replace `var' = "0.49" if strpos(`var', "logo uniquement")
	capture replace `var' = "0.5" if strpos(`var', "nom seulement")
	capture replace `var' = "0" if strpos(`var', "ni le nom ni le logo ne sont clairement indiqués")


}	

	*entreprise selling methods
replace entreprise_models = "1" if entreprise_models == "l’entreprise semble vendre à la fois aux consommateurs et aux entreprises."
replace entreprise_models = "0" if entreprise_models == "l'entreprise vend à d'autres entreprises (b2b)."
replace entreprise_models = "0.01" if entreprise_models == "l'entreprise vend à des consommateurs (personnes physiques)."

	*entreprise partners
replace entreprise_partners ="0.5" if entreprise_partners == "l'entreprise ne vend qu'aux particuliers"

	*web external links
replace web_externals = "1" if web_externals == "oui, tous les liens externes fonctionnent correctement"
replace web_externals = "0.5" if web_externals == "certains liens se chargent mais d'autres non"
replace web_externals = "0.01" if web_externals == "le site web ne comporte pas de liens externes"
replace web_externals = "0" if web_externals == "aucun des liens externes ne se charge correctement"


	*web quality
replace web_quality = "0" if web_quality == "ni le texte ni le contenu visuel ne se charge rapidement"
replace web_quality = "0.5" if web_quality == "l'un des deux contenus, textuel ou visuel, est long à charger mais l'autre se charge rapidement"
replace web_quality = "1" if web_quality == "le contenu visuel et textuel se charge bien"

	*web purchase possbilities
replace web_purchase = "0" if web_purchase == "ni commander ni payer"
replace web_purchase = "0.5" if web_purchase == "commander seulement"
replace web_purchase = "1" if web_purchase == "commander et payer directement sur site"

***********************************************************************
* 	PART 4: Fix missing values
***********************************************************************

local notyesnovariables web_logoname entreprise_models web_externals web_contact web_quality web_purchase ///
web_external_names social_logoname social_contact social_contact social_others facebook_creation facebook_reviews ///
facebook_reviews_avg insta_subs insta_contact socials_link facebook_link

foreach var of local notyesnovariables {
replace `var' = "." if `var' ==""
}

***********************************************************************
* 	PART 5: Save the data
***********************************************************************

save "${bl2_intermediate}/Webpresence_answers_inter", replace
