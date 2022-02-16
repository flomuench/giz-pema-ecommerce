************************************************************************
* 			E-commerce baseline clean					 		  	  *	  
***********************************************************************
*																	  
*	PURPOSE: clean E-commerce baseline raw data	& save as intermediate				  	  			
*																	  
*																	  
*	OUTLINE:														  
*	1)		Format string & numerical variables				          
*	2)   	Drop all text windows from the survey					  
*	3)  	Make all variables names lower case						  
*	4)  	Order the variables in the data set						  	  
*	5)  	Rename the variables									  
*	6)  	Label the variables										  
*   7) 		Removing trailing & leading spaces from string variables	
*   8) 		Remove observations for incomplete entries									 
*																	  													      
*	Author:     	Teo Firpo						    
*	ID variable: 	id_plateforme (identifiant)			  					  
*	Requires:       bl_raw.dta 	  										  
*	Creates:        bl_inter.dta			                                  
***********************************************************************
* 	PART 1: 	Format string & numerical & date variables		  			
***********************************************************************

use "${bl_raw}/bl_raw", clear


	* string
ds, has(type string) 
local strvars "`r(varlist)'"
format %-20s `strvars'

	* make all string obs lower case
foreach x of local strvars {
replace `x'= lower(`x')
}


/* --------------------------------------------------------------------
	PART 1.2: Turn binary questions numerical 
----------------------------------------------------------------------*/

local binaryvars Acceptezvousenregistrement  Nomdelapersonne Nomdelentreprise id_ident2 dig_con1 dig_con3 dig_con5 dig_presence1 dig_presence2 dig_presence3 dig_marketing_lien expprep_cible  dig_vente dig_marketing_ind1 attest attest2 dig_service_satisfaction expprep_norme expprep_demande rg_oper_exp carsoutien_gouvern perc_com1 perc_com2 exp_afrique car_ecom_prive exp_avant21 info_neces
 
foreach var of local binaryvars {
	capture replace `var' = "1" if strpos(`var', "oui")
	capture replace `var' = "0" if strpos(`var', "non")
	capture replace `var' = "-999" if strpos(`var', "sais")
	capture replace `var' = "-1200" if strpos(`var', "prévu")
	capture destring `var', replace
}

/* --------------------------------------------------------------------
	PART 1.3: Turn binary questions numerical 
----------------------------------------------------------------------*/

drop if Id_plateforme=="."

local stringvars Id_plateforme Date id_nouveau_personne id_repondent_position entr_bien_service dig_description1 dig_description2 dig_description3 dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_payment1 dig_payment2 dig_payment3 dig_marketing_ind2 dig_marketing_respons dig_logistique_entrepot dig_service_responsable investcom_2021 investcom_futur investcom_benefit1 investcom_benefit2 car_credit1 car_risque expprep_responsable exp_pays_avant21 exp_pays_21 compexp_2020 comp_ca2020 dig_revenues_ecom comp_benefice2020 car_sex_pdg car_pdg_age car_carempl_div1 car_carempl_dive2  car_carempl_dive4 car_pdg_educ car_adop_peer perc_video perc_care perc_ident Acceptezvousdevalidervosré Date


destring `stringvars', replace

	* numeric 
ds, has(type numeric) 
local numvars "`r(varlist)'"
format %-25.2fc `numvars'

	* dates
		* creation
format Date %td

/* --------------------------------------------------------------------
	PART 1.4: Fix mutliple choice questions
----------------------------------------------------------------------*/
{
	
* entr_bien_service
	
//capture encode entr_bien_service, gen(entr_service_bien)

* car_sex_pdg
/*
replace car_sex_pdg = "1" if car_sex_pdg == "femme أنثى"
replace car_sex_pdg = "2" if car_sex_pdg == "homme ذكر"
destring car_sex_pdg, replace

* car_pdg_educ

replace car_pdg_educ = "1" if car_pdg_educ == "aucune scolarité, école primaire, secondaire (sans obtention du bac) ماقراش/ تعليم ابتدائي / تعليم ثانوي (ما خذاش البكالوريا)"
replace car_pdg_educ = "1" if car_pdg_educ == "formation professionnelle diplômante (bts/ btp...)  تكوين مهني (يمكن من الحصول على شهادة)"
replace car_pdg_educ = "2" if car_pdg_educ == "diplôme de l'enseignement secondaire (baccalauréat) متحصل على شهادة ختم التعليم الثانوي (البكالوريا)"
replace car_pdg_educ = "3" if car_pdg_educ == "enseignement supérieur (diplôme universitaire) متحصل على شهادة جامعية"
replace car_pdg_educ = "-999" if car_pdg_educ == "ne sais pas (ne pas lire) - ما نعرفش (ما تقراش)"
destring car_pdg_educ, replace
*/	
	
* variable dig_con2
gen dig_con2_internationale = 0
replace dig_con2_internationale = 1 if strpos(dig_con2, "r1")

gen dig_con2_correct = 0
replace dig_con2_correct = 1 if strpos(dig_con2, "1")

gen dig_con2_pas_paiement = 0
replace dig_con2_pas_paiement = 1 if strpos(dig_con2, "r3")

gen dig_con2_commerce_entreprises = 0
replace dig_con2_commerce_entreprises = 1 if strpos(dig_con2, "r4")

gen dig_con2_nsp = 0
replace dig_con2_nsp = 1 if strpos(dig_con2, "-999")

* variable dig_con6
gen dig_con6_referencement_payant = 0
replace dig_con6_referencement_payant = 1 if strpos(dig_con6, "r1")

gen dig_con6_cout_par_clic = 0
replace dig_con6_cout_par_clic = 1 if strpos(dig_con6, "r2")

gen dig_con6_cout_par_mille = 0
replace dig_con6_cout_par_mille = 1 if strpos(dig_con6, "r3")

gen dig_con6_liens_sponsorisés = 0
replace dig_con6_liens_sponsorisés = 1 if strpos(dig_con6, "r4")

gen dig_con6_nesaispas = 0
replace dig_con6_nesaispas = 1 if strpos(dig_con6, "-999")


* Surlesquellesdesmarketplaces

g dig_presence3_ex1 = 0
replace dig_presence3_ex1 = 1 if strpos(Surlesquellesdesmarketplaces, "r1")

g dig_presence3_ex2 = 0
replace dig_presence3_ex2= 1 if strpos(Surlesquellesdesmarketplaces, "r2")

g dig_presence3_ex3 = 0
replace dig_presence3_ex3= 1 if strpos(Surlesquellesdesmarketplaces, "r3")

g dig_presence3_ex4 = 0
replace dig_presence3_ex4= 1 if strpos(Surlesquellesdesmarketplaces, "r4")

g dig_presence3_ex5 = 0
replace dig_presence3_ex5= 1 if strpos(Surlesquellesdesmarketplaces, "r5")

g dig_presence3_ex6 = 0
replace dig_presence3_ex6= 1 if strpos(Surlesquellesdesmarketplaces, "r6")

g dig_presence3_ex7 = 0
replace dig_presence3_ex7= 1 if strpos(Surlesquellesdesmarketplaces, "r7")

g dig_presence3_ex8 = 0
replace dig_presence3_ex8= 1 if strpos(Surlesquellesdesmarketplaces, "r8")

g dig_presence3_exnsp = 0
replace dig_presence3_exnsp= 1 if strpos(Surlesquellesdesmarketplaces, "-999")

* variable dig_marketing_num19
gen dig_marketing_num19_sea = 0
replace dig_marketing_num19_sea = 1 if strpos(dig_marketing_num19, "r1")

gen dig_marketing_num19_seo = 0
replace dig_marketing_num19_seo = 1 if strpos(dig_marketing_num19, "r2")

gen dig_marketing_num19_blg = 0
replace dig_marketing_num19_blg = 1 if strpos(dig_marketing_num19, "r3")

gen dig_marketing_num19_pub = 0
replace dig_marketing_num19_pub = 1 if strpos(dig_marketing_num19, "r4")

gen dig_marketing_num19_mail = 0
replace dig_marketing_num19_mail = 1 if strpos(dig_marketing_num19, "r5")

gen dig_marketing_num19_prtn = 0
replace dig_marketing_num19_prtn = 1 if strpos(dig_marketing_num19, "r6")

gen dig_marketing_num19_socm = 0
replace dig_marketing_num19_socm = 1 if strpos(dig_marketing_num19, "r7")

gen dig_marketing_num19_autre = 0
replace dig_marketing_num19_autre = 1 if strpos(dig_marketing_num19, "r8")

gen dig_marketing_num19_aucu = 0
replace dig_marketing_num19_aucu = 1 if strpos(dig_marketing_num19, "r9")

gen dig_marketing_num19_nsp = 0
replace dig_marketing_num19_nsp = 1 if strpos(dig_marketing_num19, "-999")

* variable dig_con4
gen dig_con4_org = 0
replace dig_con4_org = 1 if strpos( dig_con4, "r1")

gen dig_con4_rech = 0
replace dig_con4_rech = 1 if strpos( dig_con4, "r2")

gen dig_con4_mrkt = 0
replace dig_con4_mrkt = 1 if strpos( dig_con4, "r3")

gen dig_con4_reso = 0
replace dig_con4_reso = 1 if strpos( dig_con4, "r4")

gen dig_con4_nsp = 0
replace dig_con4_nsp = 1 if strpos( dig_con4, "r5")

* variable dig_logistique_retour
gen dig_logistique_retour_natetr = 0
replace dig_logistique_retour_natetr = 1 if strpos( dig_logistique_retour, "r1")

gen dig_logistique_retour_nat = 0
replace dig_logistique_retour_nat = 1 if strpos( dig_logistique_retour, "r2")

gen dig_logistique_retour_etr = 0
replace dig_logistique_retour_etr = 1 if strpos( dig_logistique_retour, "r3")

gen dig_logistique_retour_aucun = 0
replace dig_logistique_retour_aucun = 1 if strpos( dig_logistique_retour, "r4")

gen dig_logistique_retour_nsp = 0
replace dig_logistique_retour_nsp = 1 if strpos( dig_logistique_retour, "-999")

/* dig_description 

local vars_description  dig_description1 dig_description2 dig_description3

foreach var of local vars_description {
	replace `var' = "0.49" if `var' == "seulement une description de l’entreprise / فقط تعريف الشركة"
	replace `var' = "0.51" if `var' == "seulement une description des produits / فقط تعريف المنتجات"
	replace `var' = "1" if `var' == "description complète de l’entreprise et des produits / تعريف كامل للشركة وللمنتجات"
	replace `var' = "0" if `var' == "non / لا"
	replace `var' = "-999" if `var' == "Ne sais pas"
	destring `var', replace
}

* dig_miseajour1

local vars_misea dig_miseajour2 dig_miseajour1 dig_miseajour3

foreach var of local vars_misea {
	replace `var' = "0" if `var' == "jamais / أبدا"
	replace `var' = "0.25" if `var' == "annuellement / سنويا"
	replace `var' = "0.5" if `var' == "mensuellement / شهريا"
	replace `var' = "0.75" if `var' == "hebdomadairement / أسبوعيا"
	replace `var' = "1" if `var' == "plus qu'une fois par semaine / أكثر من مرة في الأسبوع"
	destring `var', replace
	} 
	
* dig_payment
local vars_payments dig_payment1 dig_payment2 dig_payment3

foreach var of local vars_payments {
	replace `var' = "0.5" if `var' == "seulement commander en ligne, mais le paiement se fait par d'autres moyens (virement, mandat postal, cash-on-delivery...)  / تكمندي منو فقط وتخلص بوسائل أخرى"
	replace `var' = "1" if `var' == "commander et payer en ligne /  تكمندي وتخلص منو"
	replace `var' = "0" if `var' == "ni commander ni payer en ligne / لا تكمندي لا تخلص"
	destring `var', replace
}

* dig_marketing_ind2


replace dig_marketing_ind2 = "1" if dig_marketing_ind2 == "oui, tous les mois  أي، كل شهر"
replace dig_marketing_ind2 = "0.75" if dig_marketing_ind2 == "oui, trimestriellement أي، كل تريميستا"
replace dig_marketing_ind2 = "0.5" if dig_marketing_ind2 == "oui, une fois par an  أي مرة في العام"
replace dig_marketing_ind2 = "0.25" if dig_marketing_ind2 == "oui, mais moins d'une fois par an  أي، أقل من مرة في العام"
replace dig_marketing_ind2 = "0" if dig_marketing_ind2 == "non لا"
replace dig_marketing_ind2 = "=999" if dig_marketing_ind2 == "ne sais pas"
destring dig_marketing_ind2, replace

	
	
* dig_logistique_entrepot 

replace dig_logistique_entrepot = "0.33" if dig_logistique_entrepot == "oui, mais uniquement en tunisie  / نعم, أما نستعملوا مستودعات في تونس فقط"
replace dig_logistique_entrepot = "0.66" if dig_logistique_entrepot == "oui, mais uniquement à l'étranger  / الخارج نعم نستعملوا في مستودعات في"
replace dig_logistique_entrepot = "1" if dig_logistique_entrepot == "oui, j’utilise des entrepôts nationaux et à l’étranger /  نعم نستعملوا في مستودعات في تونس وفي الخارج"
replace dig_logistique_entrepot = "0" if dig_logistique_entrepot == "non, je n’utilise pas des entrepôts / لا"
replace dig_logistique_entrepot = "-999" if dig_logistique_entrepot == "ne sais pas"
destring dig_logistique_entrepot, replace
	
	
* investcom_benefit1-2

replace investcom_benefit1 = "1" if investcom_benefit1 == "1 : très bas منخفضة برشا"
replace investcom_benefit1 = "10" if investcom_benefit1 == "10 : très haut مرتفعة برشا"
destring investcom_benefit1, replace

replace investcom_benefit2 = "1" if investcom_benefit2 == "1 : très bas منخفضة برشا"
replace investcom_benefit2 = "10" if investcom_benefit2 == "10 : très haut مرتفعة برشا"
destring investcom_benefit2, replace


replace car_credit1 = "1" if car_credit1 == "1 très difficile صعيب ياسر"
replace car_credit1 = "10" if car_credit1 == "10 très facile ساهل برشا"
destring car_credit1, replace

replace car_risque = "1" if car_risque == "1 non-disposée à prendre des risques"
replace car_risque = "10" if car_risque == "10 disposée à prendre des risques / قادرة على المخاطرة"
destring car_risque, replace
*/
*horaire_pref

	* Fix rg_oper_exp, which has 'no' as 2
	
replace rg_oper_exp = 0 if rg_oper_exp==2

label define export_status 0 "Did not export in 2021" 1 "Exported in 2021"
label value rg_oper_exp export_status

}


***********************************************************************
* 	PART 2: 	Drop all unneeded columns and rows from the survey		  			
***********************************************************************

*drop VARNAMES

drop dig_con2 dig_con6 Surlesquellesdesmarketplaces dig_marketing_num19 dig_con4 dig_logistique_retour 

drop if Id_plateforme==.

* 	Drop incomplete entries

gen complete = 0 

replace complete = 1 if attest ==1 | attest2 ==1 |  Acceptezvousdevalidervosré ==1 

// keep if complete == 1

// drop complete

***********************************************************************
* 	PART 3: 	Make all variables names lower case		  			
***********************************************************************
rename *, lower

***********************************************************************
* 	PART 4: 	Order the variables in the data set		  			
***********************************************************************

order id_plateforme heure date attest attest2 acceptezvousdevalidervosré survey_type


***********************************************************************
* 	PART 5: 	Rename the variables as needed
***********************************************************************
{

//rename entr_service_bien entr_bien_service

	* Section suivi

rename nomdelapersonne ident_nom
rename nomdelentreprise ident_entreprise
rename merciderenseignerlenomcorr ident_nom_correct_entreprise
rename adresseéléctronique ident_email_1
rename k ident_email_2
rename commentvousappelezvous id_base_respondent
*rename as dig_presence3_exemples
rename quelestlepaysdafrique exp_afrique_principal
//rename bt exp_pays_principal_21
//rename bl dig_marketing_num_autres
//rename ck exp_produit_services_avant21
//rename co exp_pays_principal_2021
//rename autres dig_presence3_ex8
//rename as dig_marketing_num19_autre
rename exp_pays_principal exp_pays_principal_avant21
//rename quelestlepaysdafrique exp_afrique_pays

*rename dig_benefice2020 comp_benefice2020
rename carsoutien_gouvern car_soutien_gouvern
rename car_carempl_dive4 car_carempl_div3
//rename acceptezvousdevalidervosré accord_validation
//rename jattestequetouteslesinform attestation_info
*rename dig_miseajou dig_miseajour1
}
***********************************************************************
* 	PART 6: 	Label the variables		  			
***********************************************************************
{
		* Section contact details
*lab var X ""
lab var  entr_histoire "histoire de l'entreprise"
lab var  entr_bien_service "est ce que l'entreprise vend un bien, un service ou les 2"
lab var entr_produit1 "produit/service principal de l'entreprise 1"
lab var entr_produit2 "produit/service principal de l'entreprise 2"
lab var entr_produit3 "produit/service principal de l'entreprise 3"
lab var dig_con1 "connaissance des marketplaces"
//lab var dig_con2 "définition d'un marketplace"
lab var dig_con3 "connaissance des publications d’annonces payantes en ligne"
//lab var dig_con4 "définition des publications d’annonces payantes en ligne"
lab var dig_con5 "connaissance de Google Ads"
*lab var dig_con6 "définition de Google Ads"
*lab var z "dig_con6_referencement_payant"
*lab var aa "dig_con6_cout_par_clic"
*lab var ab "dig_con6_cout_par_mille"
*lab var ac "dig_con6_liens_sponsorisés"
*lab var surlesquellesdesmarketpl


lab var dig_con2_internationale "envergure internationale"
lab var dig_con2_correct "mettent en relation de nombreux vendeurs et acheteurs"
lab var dig_con2_pas_paiement "ne prennent jamais en charge les paiements et la logistique"
lab var dig_con2_commerce_entreprises "utilisées que pour le commerce interentreprises"
lab var dig_con2_nsp "ne sais pas"

lab var dig_con4_org "Les résultats de recherche organiques"
lab var dig_con4_rech "La page des résultats de recherche"
lab var dig_con4_mrkt "Les marketplaces"
lab var dig_con4_reso "Les réseaux sociaux"
lab var dig_con4_nsp "Ne sais pas"

lab var dig_con6_referencement_payant "referencement payant"
lab var dig_con6_cout_par_clic "cout par clic"
lab var dig_con6_cout_par_mille "cout par mille"
lab var dig_con6_liens_sponsorisés "liens sponsorisés"
lab var dig_con6_nesaispas "ne sais pas"

lab var dig_marketing_num19_sea "SEA/ Référencement payant"
lab var dig_marketing_num19_seo "SEO/ Référencement naturel"
lab var dig_marketing_num19_blg "Blog"
lab var dig_marketing_num19_pub "Publicités display"
lab var dig_marketing_num19_mail "E-mailing & Newsletters"
lab var dig_marketing_num19_prtn "Partenariat en ligne et affiliation"
lab var dig_marketing_num19_socm "Marketing sur les médias sociaux"
lab var dig_marketing_num19_autre "Autres "
lab var dig_marketing_num19_aucu "Aucune"
lab var dig_marketing_num19_nsp "Ne sais pas"

lab var dig_logistique_retour_natetr "Retours gratuits des produits des clients étrangers et des clients nationaux"
lab var dig_logistique_retour_nat "Retours gratuits des produits seulement aux clients nationaux"
lab var dig_logistique_retour_etr "Retours gratuits des produits seulement aux clients étrangers"
lab var dig_logistique_retour_aucun "Pas de retours gratuits des produits"
lab var dig_logistique_retour_nsp "Ne sais pas"

lab var dig_presence3_ex1 "Little Jneina "
lab var dig_presence3_ex2 "elfabrica.tn"
lab var dig_presence3_ex3 "Savana"
lab var dig_presence3_ex4 "Jumia"
lab var dig_presence3_ex5 "Amazon"
lab var dig_presence3_ex6 "Ali baba"
lab var dig_presence3_ex7 "Etsy"
lab var dig_presence3_ex8 "Autres"
lab var dig_presence3_exnsp "Ne sais pas"

lab var dig_presence1 "présence sur un site web"
lab var dig_presence2 "présence sur les réseaux sociaux"
lab var dig_presence3 "présence sur une marketplace"
lab var dig_description1 "description entreprise & produit sur site web"
lab var dig_description2 "description entreprise & produit sur les réseaux sociaux"
lab var dig_description3 "description entreprise & produit sur marketplace"
lab var dig_miseajour1 "fréquence mise à jour site web"
lab var dig_miseajour2 "fréquence mise à jour réseaux sociaux"
lab var dig_miseajour3 "fréquence mise à jour marketplace"
lab var dig_vente "vente de produits/service en ligne en 2021"
lab var dig_payment1 "possibilité de payer/commander sur site web" 
lab var dig_payment2 "possibilité de payer/commander sur réseaux sociaux" 
lab var dig_payment3 "possibilité de payer/commander sur marketplace" 
lab var dig_marketing_lien "page réseaux social liée au site web"
lab var dig_marketing_ind1  "présence d'objectifs marketing digital"
lab var dig_marketing_ind2  "fréquence mesure des objectifs marketing digital"
lab var dig_marketing_respons "nombre d'émployés chargés activités marketing digital"
lab var dig_logistique_entrepot "stock des produits dans des entrepôts"
//lab var dig_logistique_retour "retours gratuits des produits vendus en ligne"
lab var dig_service_responsable "nombre d'émployés chargés demandes internautes"
lab var dig_service_satisfaction "mesure satisfaction clients en ligne"
lab var investcom_2021 "montant investi dans les acitivités e-commerce en 2021 (en TND)"
lab var investcom_futur  "montant futur pour les acitivités e-commerce en 2022 (en TND)"
lab var investcom_benefit1 "coûts vente de vos produits/ services en ligne"
lab var investcom_benefit2 "bénéfices vente de vos produits/ services en ligne"
lab var investcom_benefit3_1 "avantage commerce éléctronique 1" 
lab var investcom_benefit3_2 "avantage commerce éléctronique 2" 
lab var investcom_benefit3_3  "avantage commerce éléctronique 3" 
lab var expprep_cible "analyse marché d'exportation cibles"
lab var expprep_responsable "nombre d'employés pour les affaires export"
lab var expprep_norme "certification des produits/ services"
lab var expprep_norme2 "nom certification"
lab var expprep_demande "possibilité d’augmenter la production face à une demande accrue"  
lab var rg_oper_exp "opération d'export en 2021"
lab var exp_produit_services21 "produit/service exporté en 2021"
lab var exp_pays_21 "nombre de pays export 2021"
lab var exp_avant21 " est ce que l'entreprise a exporté avant 2021"
//lab var exp_produit_services_avant21 "produit/service exporté avant 2021"
lab var exp_pays_avant21 "nombre de pays export avant 2021"
//lab var exp_pays_principal_2021 "principal pays pour l'export en 2021"
*lab var exp_produit_services_avant21 "produit/service exporté avant 2021"
*lab var exp_pays_avant21 "nombre de pays export avant 2021"
*lab var exp_pays_principal_2021 "principal pays pour l'export en 2021"
lab var exp_afrique "exportation vers un pays d'Afrique subsaharienne 12 derniers mois"
//lab var exp_afrique_pays "pays Afrique subsaharienne"
lab var info_neces "possession des informations comptables nécessaires"
lab var info_compt1  "numéro de téléphone du comptable"
lab var info_compt2 "email du comptable"
lab var compexp_2020 "chiffre d'affaire export 2020"
lab var comp_ca2020 "chiffre d'affaire total 2020"
lab var dig_revenues_ecom "chiffre d'affaire ventes en ligne 2020"
lab var comp_benefice2020 "bénéfices 2020"
lab var car_soutien_gouvern "participation à d'autres programme de coopération internationale"
lab var car_sex_pdg "sexe du PDG - 1 = femme"
lab var car_pdg_age "age du PDG"
lab var car_carempl_div1  "nombre d'employés femmes"
lab var car_carempl_dive2 "nombre d'employés âgés entre 18 ans et 24 ans "
lab var car_carempl_div3 "nombre d'employés à temps partiel"
lab var car_pdg_educ "niveau education du PDG"
lab var car_credit1 " perception d'obtenir un crédit"
lab var car_adop_peer "nombre de personnes qui vendent leurs produits via le commerce électronique"
lab var car_risque "perception de l'avrsion au risque"
lab var car_ecom_prive "réalisation d'achats personnels en ligne"
lab var car_attend1 "attente 1 du projet"
lab var car_attend2 "attente 2 du projet"
lab var car_attend3 "attente 3 du projet"
lab var perc_video  "perception mail video"
lab var perc_care "perception mail garde enfants"
lab var perc_iden "identification avec la vidéo"
lab var horaire_pref "créneau horaire préféré(s)"
lab var tel_sup1 "numéro téléphone suppléméntaire 1"
lab var tel_sup2 "numéro téléphone suppléméntaire 2"
}


***********************************************************************
* 	PART 7: Removing trail and leading spaces in from string variables  			
***********************************************************************
* Creating global according to the variable type
global varstring info_compt2 exp_afrique_principal exp_pays_principal_21 car_attend1 car_attend2 car_attend3 exp_produit_services_avant21 exp_produit_services21 entr_histoire entr_bien_service entr_produit1 entr_produit2 entr_produit3 dig_presence3_exemples_autres investcom_benefit3_1 investcom_benefit3_2 investcom_benefit3_3 expprep_norme2
global numvars info_compt1 dig_revenues_ecom comp_benefice2020 comp_ca2020 compexp_2020 tel_sup2 tel_sup1 car_carempl_div1 car_carempl_dive2 car_carempl_div3 dig_marketing_respons investcom_futur investcom_2021 expprep_responsable exp_pays_avant21 exp_pays_principal_avant21 exp_pays_21


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
cd "$bl_intermediate"
save "bl_inter", replace
