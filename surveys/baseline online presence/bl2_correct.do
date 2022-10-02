***********************************************************************
* 			correct do file, second part baseline e-commerce				  
***********************************************************************
*																	  
*	PURPOSE: correct the questionnaire answers intermediate data
*																	  
*	OUTLINE: 	PART 1: Import the data 
*				PART 2: Turn binary questions numerical
*				PART 3: Recode observations
*				PART 4: Fix missing values
*				PART 5: Drop invalid duplicates
*				PART 6: Remove incorrect entries
*				PART 7: Save the data
*													
*																	  
*	Author:  		Ayoub Chamakhi & Fabian Scheifele							    
*	ID variable: 	id_platforme	  					  
*	Requires:  		Webpresence_answers_intermediate.dta
*	Creates:		Webpresence_answers_intermediate.dta

***********************************************************************
* 	PART 1: Import the data
***********************************************************************

use "${bl2_intermediate}/Webpresence_answers_intermediate", clear


***********************************************************************
* 	PART 3: Turn binary questions numerical
***********************************************************************

local binaryvars Lentreprisedisposetelledun Lecontenuestillisiblepare Leproduitserviceestildécrit Ladescriptionduproduitservic Lesitecomportetilunesectio Lesiteprésentetildesnormes ///
Lesiteestilproposédansune Existetildesliensversunma U Lapageduréseausocialcomport Lapageduréseausocialcontien Lapageduréseausocialcontie Estcequelentreprisepossède Lapagedisposetelledelopti ///
AK Leprofildelentreprisecontie Leprofildelentreprisefourni
 
foreach var of local binaryvars {
	capture replace `var' = "1" if strpos(`var', "Oui")
	capture replace `var' = "0" if strpos(`var', "Non")

}

***********************************************************************
*	PART 4: Recode observations 
***********************************************************************

	*social media and website name and logo existance
local logonamevars Lapageduréseausocialindique LesiteWebindiquetilclairem
foreach var of local logonamevars {
	capture replace `var' = "2" if strpos(`var', "Nom et logo")
	capture replace `var' = "1" if strpos(`var', "Logo uniquement")
	capture replace `var' = "1" if strpos(`var', "Nom seulement")
	capture replace `var' = "0" if strpos(`var', "Ni le nom ni le logo ne sont clairement indiqués")


}	

	*entreprise selling methods
replace Lentreprisevendellesonprodu = "2" if Lentreprisevendellesonprodu == "L’entreprise semble vendre à la fois aux consommateurs et aux entreprises."
replace Lentreprisevendellesonprodu = "1" if Lentreprisevendellesonprodu == "L'entreprise vend à d'autres entreprises (B2B)."
replace Lentreprisevendellesonprodu = "0" if Lentreprisevendellesonprodu == "L'entreprise vend à des consommateurs (personnes physiques)."
replace Lentreprisevendellesonprodu = "." if Lentreprisevendellesonprodu == "projets de développement local et régional "

	*entreprise partners
replace Danslecasducommerceinterent ="2" if Danslecasducommerceinterent == "Oui"
replace Danslecasducommerceinterent ="." if Danslecasducommerceinterent == "l'entreprise ne vend qu'aux particuliers"
replace Danslecasducommerceinterent ="0" if Danslecasducommerceinterent == "Non"


	*web external links
replace Estcequelesliensexternesfo = "2" if Estcequelesliensexternesfo == "Oui, tous les liens externes fonctionnent correctement"
replace Estcequelesliensexternesfo = "1" if Estcequelesliensexternesfo == "Certains liens se chargent mais d'autres non"
replace Estcequelesliensexternesfo = "0" if Estcequelesliensexternesfo == "Le site web ne comporte pas de liens externes"
replace Estcequelesliensexternesfo = "0" if Estcequelesliensexternesfo == "Aucun des liens externes ne se charge correctement"


	*web quality
	
replace Lecontenusechargetilcorrec = "2" if Lecontenusechargetilcorrec == "Le contenu visuel et textuel se charge bien"
replace Lecontenusechargetilcorrec = "1" if Lecontenusechargetilcorrec == "L'un des deux contenus, textuel ou visuel, est long à charger mais l'autre se charge rapidement"
replace Lecontenusechargetilcorrec = "0" if Lecontenusechargetilcorrec == "Ni le texte ni le contenu visuel ne se charge rapidement"

	*web purchase possbilities
replace Pouvezvousacheteroucommander = "2" if Pouvezvousacheteroucommander == "Commander et payer directement sur site"
replace Pouvezvousacheteroucommander = "1" if Pouvezvousacheteroucommander == "Commander seulement"
replace Pouvezvousacheteroucommander = "0" if Pouvezvousacheteroucommander == "Ni commander ni payer"

***********************************************************************
* 	PART 5: Fix missing values
***********************************************************************

local notyesnovariables LesiteWebindiquetilclairem Leproduitserviceestildécrit Ladescriptionduproduitservic Lesitecomportetilunesectio Lesiteprésentetildesnormes  Lentreprisevendellesonprodu ///
Danslecasducommerceinterent Estcequelesliensexternesfo Lesiteestilproposédansune Parmilespossibilitésdecontac Lecontenuestillisiblepare Lecontenusechargetilcorrec Pouvezvousacheteroucommander  ///
Existetildesliensversunma Siouiversquellesplacesdem Lapageduréseausocialindique Lapageduréseausocialcomport Lapageduréseausocialcontien Lapageduréseausocialcontie Z Quandétaitladernierepublicat ///
Pourlequeldesréseauxsociaux Estcequelentreprisepossède Quelleestladatedecréationd Combiendeavislapagepossède Quelleestlamoyennedesavisa Lapagedisposetelledelopti AK Quelestlenombredefollowers ///
Leprofildelentreprisecontie Leprofildelentreprisecontie Leprofildelentreprisefourni Parmilesinformationsdecontac Veuillezcollercidessousleli Veuillezcollerleliendelapa

foreach var of local notyesnovariables {
replace `var' = "." if `var' ==""
}

***********************************************************************
* 	PART 5: Drop invalid duplicates
***********************************************************************

drop if Quelestlidentifiantdelapla == 166 & Lesitecomportetilunesectio == "0"
drop if Quelestlidentifiantdelapla == 255 & Estcequelesliensexternesfo == "1"
drop if Quelestlidentifiantdelapla == 346 & Estcequelesliensexternesfo == "1" 
drop if Quelestlidentifiantdelapla == 381 & U =="0"
drop if Quelestlidentifiantdelapla == 381 & Pourlequeldesréseauxsociaux == "Instagram"
drop if Quelestlidentifiantdelapla == 505 & Lesitecomportetilunesectio == "1"
drop if Quelestlidentifiantdelapla == 524 & Estcequelesliensexternesfo == "0"
drop if Quelestlidentifiantdelapla == 646 & Pourlequeldesréseauxsociaux == "Youtube, Instgram / Facebook"
drop if Quelestlidentifiantdelapla == 646 & Pourlequeldesréseauxsociaux == "Youtube, Instagram"
drop if Quelestlidentifiantdelapla == 833 & Pourlequeldesréseauxsociaux == "Linkedin"
drop if Quelestlidentifiantdelapla == 833 & Pourlequeldesréseauxsociaux == "Youtube, Linkedin, Instagram"
drop if Quelestlidentifiantdelapla == 867 & U =="1"
drop if Quelestlidentifiantdelapla == 925 & U =="0"

***********************************************************************
* 	PART 6: Fix incorrect entries
***********************************************************************

	*remove baity.tn added by student as external purchase link
replace Siouiversquellesplacesdem = "." if Siouiversquellesplacesdem == "baity.tn"

	*fix date entry errors*
replace Quandétaitladernierepublicat = trim(Quandétaitladernierepublicat)
replace Quandétaitladernierepublicat = "06/16/2022" if Quandétaitladernierepublicat == "3/17/2021"
replace Quandétaitladernierepublicat = "8/3/2022" if Quandétaitladernierepublicat == "8/3/0202"

	*destring remaining numeric variables
local numvars Combiendeavislapagepossède Quelleestlamoyennedesavisa Quelestlenombredefollowers Quelestlidentifiantdelapla
foreach var of local numvars {
	destring `var', replace 
}

	*checked & swapped to correct, this was the only outlier. 
replace Combiendeavislapagepossède= . if Quelestlidentifiantdelapla== 545
replace Quelleestlamoyennedesavisa= . if Quelestlidentifiantdelapla== 545
replace QuelestlenombredeLikes= . if Quelestlidentifiantdelapla== 545
replace Quelestlenombredabonnés= . if Quelestlidentifiantdelapla== 545

	*change website to an unique entry
replace Parmilesinformationsdecontac = "web site" if Parmilesinformationsdecontac == "site web"
replace Parmilesinformationsdecontac = "web site" if Parmilesinformationsdecontac == "page web"
replace Parmilesinformationsdecontac = "web site" if Parmilesinformationsdecontac == "website"

	*correct facebook creation date errors
replace Quelleestladatedecréationd = trim(Quelleestladatedecréationd)
replace Quelleestladatedecréationd = "12/10/2018" if Quelleestladatedecréationd == "11/11/1111"
replace Quelleestladatedecréationd = "9/28/2013" if Quelleestladatedecréationd == "9/28/0213"
replace Quelleestladatedecréationd = "9/26/2013" if Quelleestladatedecréationd == "1/2/1900"
replace Quelleestladatedecréationd = "11/25/2009" if Quelleestladatedecréationd == "1/2/1900"
replace Quelleestladatedecréationd = "3/13/2019" if Quelleestladatedecréationd == "1/2/1900"

***********************************************************************
* 	PART 7: Save the data
***********************************************************************

save "${bl2_intermediate}/Webpresence_answers_intermediate", replace
