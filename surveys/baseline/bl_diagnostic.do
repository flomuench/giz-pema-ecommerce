
***********************************************************************
* 			E-commerce field experiment:  diagnostic								  		  
***********************************************************************
*																	   
*	PURPOSE: Create a diagnostic for e-commerce and export preparedness scores to share with the firms			  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Adapt variables for diagnostic scores
*	2)		Automate writing of reports 
*   3)		Save														  
*
*																 																      *
*	Author:  	Teo Firpo & Fabian Scheifele													  
*	ID variable: 	id_plateforme			  									  
*	Requires:		bl_final.dta
*	Creates:		
*																	  

***********************************************************************
* 	PART Start: Import the data
***********************************************************************

	* import data
use "${bl_final}/bl_final", clear

**********************************************************************
* 	PART 1:  Final adaptation for diagnostics to be sent to firms 
* (agreed on 05.05.2022)
***********************************************************************


/* --------------------------------------------------------------------------
	PART 1.1: Modification of existing variables - e-commerce/digitalisation
----------------------------------------------------------------------------*/

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

/* --------------------------------------------------------------------------
	PART 1.2: Modification of existing variables - export preparedness
----------------------------------------------------------------------------*/

g expprep_person = 0
replace expprep_person = 1 if expprep_responsable>0 & expprep_responsable!=.

local expprep_diagnostic expprep_person expprep_cible expprep_norme expprep_demande

foreach var of local expprep_diagnostic {
	replace `var' = 0 if `var'==.
	replace `var' = 0 if `var'==-999
}

lab var expprep_person "Dummy taking value of 1 if the firm has one or more people responsible for exports"

/* --------------------------------------------------------------------
	PART 1.2: Create scores (with overall and sector averages)
----------------------------------------------------------------------*/

* First, e-commerce / digitalisation practices: 

egen ecom_dig_raw = rowtotal(dig_presence_score dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_payment1 dig_payment2 dig_payment3 dig_marketing_lien dig_marketing_num19_sea dig_marketing_num19_seo dig_marketing_num19_blg dig_marketing_num19_pub dig_marketing_num19_mail dig_marketing_num19_prtn dig_marketing_num19_socm dig_marketing_ind1 dig_marketing_ind2  dig_logistique_entrepot_ext dig_logistique_entrepot dig_logistique_retour_score dig_logistique_retour_ext) 

g ecom_dig = (ecom_dig_raw/23)*100

egen avg_ecom_dig = mean(ecom_dig)

egen sectoral_avg_ecom_dig = mean(ecom_dig), by(sector)

lab var ecom_dig_raw "(Raw) sum of all e-commerce digitalisation practices"
lab var ecom_dig "Percentage of all e-commerce digitalisation practices"
lab var avg_ecom_dig "Average percentage of all e-commerce digitalisation practices"
lab var sectoral_avg_ecom_dig "Sectoral average percentage of all e-commerce digitalisation practices"


* Second, export preparedness practices: 

egen expprep_raw = rowtotal(expprep_person expprep_cible expprep_norme expprep_demande)

g expprep_diag = (expprep_raw/4)*100

egen avg_expprep_diag = mean(expprep_diag)

egen sectoral_avg_expprep_diag = mean(expprep_diag), by(sector)

lab var expprep_raw "Raw sum of all export preparadness practices"
lab var expprep_diag "Percentage of all export preparadness practices"
lab var avg_expprep_diag "Average percentage of all export preparadness practices"
lab var sectoral_avg_expprep_diag "Sectoral average percentage of all export preparadness practices"


	* change directory for diagnostic files
cd "$bl_output/bl_diagnostic"
set scheme s1color	 
set graphics off 

gen row_id= _n
gen digital_avg = 15.3
gen sector_avg = 12


***********************************************************************
* 	PART 2:  	make a loop to automate document creation			  *
***********************************************************************

levelsof id_plateforme, local(levels_id) 

foreach x of local levels_id{

putdocx clear
putdocx begin, font("Arial", 12) 
putdocx paragraph, halign(center)

putdocx text ("Scores du premier diagnostic - PEMAII GIZ “Actvité e-commerce"), bold underline linebreak 
putdocx paragraph, halign(right)
putdocx text ("Date: `c(current_date)'"), linebreak 
putdocx paragraph


graph hbar raw_digtalvars digital_avg sector_avg if id_plateforme==`x'
gr export dig_score_`x'.png, replace
putdocx paragraph, halign(center) 
putdocx image dig_score_`x'.png

graph hbar expprep digital_avg sector_avg if id_plateforme==`x'
gr export exp_score_`x'.png, replace
putdocx paragraph, halign(center) 
putdocx image exp_score_`x'.png

putdocx save diagnostic_`x'.docx, replace

}


*test code*
putdocx clear
putdocx begin, font("Arial", 12) 
putdocx paragraph, halign(center)

putdocx text ("Scores du premier diagnostic - PEMA II GIZ “Commerce Electronique et Marketing Digital"), bold underline linebreak 
putdocx paragraph, halign(right)
putdocx text ("Date: `c(current_date)'"), linebreak 
putdocx paragraph
putdocx text ("Cher(e) chef(fe) d’entreprise,")
putdocx paragraph
putdocx text ("Nous réitérons nos remerciements pour votre participation et vos réponses pour le premier sondage, à l’issue duquel, nous avons pu établir un premier diagnostic, s’inscrivant dans une série de trois diagnostics, que vous allez recevoir tout au long du projet.")
 
putdocx paragraph
putdocx text ("Ce diagnostic prend la forme de deux scores: un score de digitalisation (regroupant les questions relatives au marketing digital, à la présence en ligne et à  la logistique) et un score de préparation à l’export (établi grâce aux questions sur l’analyse de vos marchés cibles, la certification de vos produits ou services…).")
putdocx paragraph
putdocx text ("Afin de pouvoir vous positionner par rapport aux entreprises participantes, de sonder votre niveau en termes de digitalisation et de mieux apprécier votre prédisposition à l’export, vous trouverez ci-dessous deux graphes regroupant 3 scores:")
putdocx paragraph
putdocx text ("Le premier correspond au  score individuel de votre entreprise.") 
putdocx paragraph
putdocx text ("Le second correspond à un score moyen de toutes les entreprises participantes sélectionnées du projet 'Commerce Électronique et Marketing Digital' de PEMA II.")
putdocx paragraph
putdocx text ("Le troisième correspond au score moyen des entreprises de votre secteur d’activité dans le  cadre de ce projet.")


graph hbar raw_digtalvars digital_avg sector_avg if id_plateforme==58
gr export dig_score_test.png, replace
putdocx paragraph, halign(left) 
putdocx image dig_score_test.png, width (8.25 cm) height (6cm)

graph hbar expprep digital_avg sector_avg if id_plateforme==58
gr export exp_score_test.png, replace
putdocx paragraph, halign(left) 
putdocx image exp_score_test.png, width (8.25 cm) height (6cm)

putdocx save diagnostic_test.docx, replace




