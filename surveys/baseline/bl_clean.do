***********************************************************************
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
*   7) 		Label variable values 								 
*   8) 		Removing trailing & leading spaces from string variables										 
*																	  													      
*	Author:  	Teo Firpo						    
*	ID variable: 	id_plateforme (identifiant)			  					  
*	Requires: bl_raw.dta 	  										  
*	Creates:  bl_inter.dta			                                  
***********************************************************************
* 	PART 1: 	Format string & numerical & date variables		  			
***********************************************************************
use "${bl_raw}/bl_raw", clear

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
format Date %td


}
/* --------------------------------------------------------------------
	PART 1.2: Fix mutliple choice questions
----------------------------------------------------------------------*/

g dig_con6_referencement_payant = 0
replace dig_con6_referencement_payant = 1 if strpos(dig_con6, "r1")

g dig_con6_cout_par_clic = 0
replace dig_con6_cout_par_clic = 1 if strpos(dig_con6, "r2")

g dig_con6_cout_par_mille = 0
replace dig_con6_cout_par_mille = 1 if strpos(dig_con6, "r3")

g dig_con6_liens_sponsorisés = 0
replace dig_con6_liens_sponsorisés = 1 if strpos(dig_con6, "r4")

g dig_con6_nesaispas = 0
replace dig_con6_nesaispas = 1 if strpos(dig_con6, "-999")


	
***********************************************************************
* 	PART 2: 	Drop all unneeded columns and rows from the survey		  			
***********************************************************************
{
*drop VARNAMES

}

drop if Id_plateforme==.


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
* 	PART 5: 	Rename the variables as needed
***********************************************************************
{

	* Section suivi
* rename var var1
*rename var z "dig_con6_referencement_payant"
*rename var aa "dig_con6_cout_par_clic"
*rename var ab "dig_con6_cout_par_mille"
*rename var ac "dig_con6_liens_sponsorisés"
*rename var surlesquellesdesmarketpl dig_presence3_little_jneina
*rename var ai dig_presence3_elfabrica.tn
*rename var aj dig_presence3_savana 
*rename var surlesquellesdesmarketpla dig_presence3_jumia
*rename var al dig_presence3_amazon
*rename var am dig_presence3_ali_baba
*rename var an dig_presence3_etsy
*rename var ao dig_presence3_little_jneina
*rename var autres dig_presence3_autres
*rename au dig_miseajour2
*rename av dig_miseajour3

rename bl dig_marketing_num_autres
rename ck exp_produit_services_avant21
rename co exp_pays_principal_2021
rename exp_pays_principal exp_pays_principal_avant21
rename quelestlepaysdafrique exp_afrique_pays
rename dig_benefice2020 comp_benefice2020
rename carsoutien_gouvern car_soutien_gouvern
rename car_carempl_dive4 car_carempl_div3
rename acceptezvousdevalidervosré accord_validation
rename jattestequetouteslesinform attestation_info
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
lab var dig_con2 "définition d'un marketplace"
lab var dig_con3 "connaissance des publications d’annonces payantes en ligne"
lab var dig_con4 "définition des publications d’annonces payantes en ligne"
lab var dig_con5 "connaissance de Google Ads"
*lab var dig_con6 "définition de Google Ads"
*lab var z "dig_con6_referencement_payant"
*lab var aa "dig_con6_cout_par_clic"
*lab var ab "dig_con6_cout_par_mille"
*lab var ac "dig_con6_liens_sponsorisés"
*lab var surlesquellesdesmarketpl

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
lab var dig_logistique_retour "retours gratuits des produits vendus en ligne"
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
lab var exp_pays_principal_avant21 "principal pays pour l'export avant 2021"
lab var exp_avant21 " est ce que l'entreprise a exporté avant 2021"
lab var exp_produit_services_avant21 "produit/service exporté avant 2021"
lab var exp_pays_avant21 "nombre de pays export avant 2021"
lab var exp_pays_principal_2021 "principal pays pour l'export en 2021"
lab var exp_afrique "exportation vers un pays d'Afrique subsaharienne 12 derniers mois"
lab var exp_afrique_pays "pays Afrique subsaharienne"
lab var info_neces "possession des informations comptables nécessaires"
lab var info_compt1  "numéro de téléphone du comptable"
lab var info_compt2 "email du comptable"
lab var compexp_2020 "chiffre d'affaire export 2020"
lab var comp_ca2020 "chiffre d'affaire total 2020"
lab var dig_revenues_ecom "chiffre d'affaire ventes en ligne 2020"
lab var comp_benefice2020 "bénéfices 2020"
lab var car_soutien_gouvern "participation à d'autres programme de coopération internationale"
lab var car_sex_pdg "sexe du PDG"
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
* 	PART 7: 	Label variables values	  			
***********************************************************************
{
/*
lab def labelname 1 "" 2 "" 3 ""
lab val variablename labelname
*/
}

***********************************************************************
* 	PART 8: Removing trail and leading spaces in from string variables  			
***********************************************************************
* Creating global according to the variable type
global varstring entr_histoire entr_produit1 entr_produit2 entr_produit3 dig_marketing_num_autres investcom_benefit3_1 investcom_benefit3_2 investcom_benefit3_3 expprep_norme2 exp_produit_services21 exp_pays_principal_avant21 exp_pays_principal_2021 exp_afrique_pays info_compt2 car_attend1 car_attend2 car_attend3


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
