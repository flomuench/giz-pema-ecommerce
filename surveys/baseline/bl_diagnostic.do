


***********************************************************************
* 	PART Start: Import the data
***********************************************************************

	* import data
use "${bl_final}/bl_final", clear


**********************************************************************
* 	PART 1:  Final adaptation for diagnostics to be sent to firms 
* (agreed on 05.05.2022)
***********************************************************************


/* --------------------------------------------------------------------
	PART 1.1: Modification of existing variables  
----------------------------------------------------------------------*/

* Scoring of online presence changes from fraction to full integers
* to wait the extensive margin higher


replace  dig_presence_score = 3 if  dig_presence_score>0.8 & dig_presence_score!=.
replace  dig_presence_score = 2 if  dig_presence_score>0.5 & dig_presence_score<1 & dig_presence_score!=.
replace  dig_presence_score = 1 if  dig_presence_score>0 & dig_presence_score<2 & dig_presence_score!=.
replace  dig_presence_score = 0 if  dig_presence_score<1
replace  dig_presence_score = 0 if  dig_presence_score==.

* For dig_logistique_entrepot, create 'extensive' version that is equal to 1 if they have any entrepot
* (The original dig_logistique_entrepot remains the intensive margin)

g dig_logistique_entrepot_ext = 0
replace  dig_logistique_entrepot_ext = 1 if dig_logistique_entrepot > 0 & dig_logistique_entrepot!=.

* Same with dig_logistique_retour_score

g dig_logistique_retour_ext = 0
replace dig_logistique_retour_ext = 1 if dig_logistique_retour_score>0 & dig_logistique_retour_score!=.


local ecomm_diagnostic dig_presence_score dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_payment1 dig_payment2 dig_payment3 dig_marketing_lien dig_marketing_num19_sea dig_marketing_num19_seo dig_marketing_num19_blg dig_marketing_num19_pub dig_marketing_num19_mail dig_marketing_num19_prtn dig_marketing_num19_socm dig_marketing_ind1 dig_marketing_ind2  dig_logistique_entrepot_ext dig_logistique_entrepot dig_logistique_retour_score dig_logistique_retour_ext

foreach var of local ecomm_diagnostic {
	replace `var' = 0 if `var'==.
	replace `var' = 0 if `var'==-999
}


egen ecom_dig_raw = rowtotal(dig_presence_score dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_payment1 dig_payment2 dig_payment3 dig_marketing_lien dig_marketing_num19_sea dig_marketing_num19_seo dig_marketing_num19_blg dig_marketing_num19_pub dig_marketing_num19_mail dig_marketing_num19_prtn dig_marketing_num19_socm dig_marketing_ind1 dig_marketing_ind2  dig_logistique_entrepot_ext dig_logistique_entrepot dig_logistique_retour_score dig_logistique_retour_ext) 

g ecom_dig = (ecom_dig_raw/23)*100

egen avg_ecom_dig = mean(ecom_dig)

egen sectoral_avg_ecom_dig = mean(ecom_dig), by(sector)



lab ecom_dig_raw "(Raw) sum of all e-commerce digitalisation practices"
lab ecom_dig "Percentage of all e-commerce digitalisation practices"
avg_ecom_dig
sectoral_avg_ecom_dig


