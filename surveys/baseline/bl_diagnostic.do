
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


/* --------------------------------------------------------------------
	PART 1.3: Create deciles for each diagnostic score
----------------------------------------------------------------------*/


sort ecom_dig
xtile ecom_decile = ecom_dig, n(10)

sort expprep_diag
xtile expprep_decile = expprep_diag, n(10)

lab var ecom_decile "Deciles for e-commerce/digitalisation score"
lab var expprep_decile "Deciles for export preparadness score"


	* Now create statements based on the deciles to be used in the text below 

gen ecom_dig_text = " "
replace ecom_dig_text = "Votre entreprise est classée dans les 10 % supérieurs en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_decile>9
replace ecom_dig_text = "Votre entreprise est classée dans les 25 % supérieurs en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig>=42.7391 & ecom_decile<10
replace ecom_dig_text = "Votre entreprise se situe juste au-dessus de la moyenne en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig<42.7391 & ecom_dig>30.7826
replace ecom_dig_text = "Votre entreprise se situe juste en dessous de la moyenne en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig<=30.7826
replace ecom_dig_text = "Votre entreprise est classée dans les 25 % inférieurs en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig<=20.6522
replace ecom_dig_text = "Votre entreprise est classée dans les 10 % inférieurs en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig<=10.1304

gen expprep_text = " "
replace expprep_text = "Votre entreprise se situe dans le tiers supérieur en termes d'adoption de pratiques de préparation à l'exportation." if expprep_decile==7
replace expprep_text = "Votre entreprise se situe juste au-dessus de la moyenne en termes d'adoption de pratiques de preparation à l'exportation." if expprep_decile==6
replace expprep_text = "Votre entreprise se situe dans la moyenne en termes d'adoption de pratiques preparation à l'exportation." if expprep_decile==3
replace expprep_text = "Votre entreprise se situe juste en dessous de la moyenne en termes d'adoption de pratiques preparation à l'exportation." if expprep_decile==2
replace expprep_text = "Votre entreprise est classée dans les 20 % inférieurs en termes d'adoption de pratiques de preparation à l'exportation." if expprep_diag<=50 &  expprep_diag>38
replace expprep_text = "Votre entreprise est classée dans les 10 % inférieurs en termes d'adoption de pratiques de preparation à l'exportation." if expprep_diag<38


***********************************************************************
* 	PART 2:  	make a loop to automate document creation			  *
***********************************************************************
	
	* change directory for diagnostic files
cd "$bl_output/bl_diagnostic"
set scheme s1color	 
set graphics off 
gen row_id = _n

forvalues x = 1(1)3 {
putdocx clear
putdocx begin
putdocx paragraph
putdocx text ("`=expprep_text[`x']'"), linebreak
putdocx text ("`=ecom_dig_text[`x']'"), linebreak
local x id_plateforme[`x']
display `x'
putdocx save test_`x'.docx, replace
}

forvalues x = 1(1)236 {

putdocx clear
putdocx begin, font("Arial", 12) 

putdocx paragraph, halign(center)
putdocx image logos_cropped2.png, height (3 cm) linebreak
putdocx paragraph, halign (center)
putdocx text ("Scores du premier diagnostic - PEMA II GIZ “Commerce Electronique et Marketing Digital"), bold underline linebreak 
putdocx paragraph
putdocx text ("Cher(e) chef(fe) d’entreprise,")
putdocx paragraph
putdocx text ("Nous réitérons nos remerciements pour votre participation et vos réponses pour le premier sondage, à l’issue duquel, nous avons pu établir un premier diagnostic, s’inscrivant dans une série de trois diagnostics, que vous allez recevoir tout au long du projet.")
 
putdocx paragraph
putdocx text ("Ce diagnostic prend la forme de deux scores: un score de digitalisation (regroupant les questions relatives au marketing digital, à la présence en ligne et à  la logistique) et un score de préparation à l’export (établi grâce aux questions sur l’analyse de vos marchés cibles, la certification de vos produits ou services…).")
putdocx paragraph
putdocx text ("Ci-dessous  vous trouverez deux graphiques avec trois barres chacun:"), linebreak
putdocx paragraph
putdocx text ("		- La première (couleur) correspond au pourcentage de pratiques adoptées"), bold linebreak
putdocx text ("		  par votre entreprise."), bold linebreak
putdocx text ("		- La deuxième (couleur) correspond au pourcentage moyen de pratiques"), bold linebreak
putdocx text ("		  adoptées par l'ensemble des entreprises interrogées."), bold linebreak
putdocx text ("		- La troisième (couleur) correspond au pourcentage moyen de pratiques"), bold linebreak
putdocx text ("		  adoptées par l'ensemble des entreprises interrogées dans votre secteur."), bold linebreak



graph hbar ecom_dig avg_ecom_dig sectoral_avg_ecom_dig if row_id==`x', ///
		subtitle ("Pourcentage de activités  adoptées") ///
		title ("Commerce electronique et marketing numerique") ///
		ysc(r(0 100)) ylab(0(10)100) ytitle("%") legend (pos (12) /// 
		lab(1 "Votre Score") lab(2 "Moyenne totale") lab(3 "Moyenne dans votre secteur")) ///
		bar (1 ,fc("208 33 36") lc("208 33 36")) ///
		bar (2 ,fc("241 160 40") lc("241 160 40")) /// 
		bar (3 ,fc("112 113 115") lc("112 113 115")) 
		
gr export dig_score_test_`x'.png, replace
putdocx paragraph, halign(center) 

putdocx image dig_score_test_`x'.png, height (6 cm)

putdocx paragraph
putdocx text ("`=ecom_dig_text[_n]'"), linebreak

graph hbar expprep_diag avg_expprep_diag sectoral_avg_expprep_diag if row_id==`x', ///
		subtitle ("Pourcentage de activités  adoptées") ///
		title ("Preparation des exportations") ///
		ysc(r(0 100)) ylab(0(10)100) ytitle("%") legend (pos (inside) /// 
		lab(1 "Votre Score") lab(2 "Moyenne totale") lab(3 "Moyenne dans votre secteur")) ///
		bar (1 ,fc("208 33 36") lc("208 33 36")) ///
		bar (2 ,fc("241 160 40") lc("241 160 40")) /// 
		bar (3 ,fc("112 113 115") lc("112 113 115")) 
		
gr export exp_score_test_`x'.png, replace
putdocx paragraph, halign(center) 
putdocx image exp_score_test_`x'.png, height (6 cm)
putdocx paragraph
putdocx text ("`=expprep_text[_n]'"), linebreak


putdocx paragraph
putdocx text ("Nous espérons que ces scores vous permettrons de vous situer parmi les entreprises dans votre secteur et en globale."), linebreak 
putdocx paragraph
putdocx text ("Vous voulez savoir quelles pratiques peuvent vous aider à améliorer encore votre marketing numérique et votre commerce électronique ?"), bold linebreak 
putdocx text ("Assurez-vous de participer aux deuxième et troisième parties du diagnostic en novembre 2022 et 2023."), linebreak 
putdocx text ("A la fin du diagnostic complet, vous recevrez un autre rapport avec des recommandations individualisées."), linebreak
putdocx paragraph
putdocx text ("Cordialement,"), linebreak 
putdocx paragraph
putdocx text ("Equipe PEMA"), linebreak bold

local name_file id_plateforme[`x']
display `name_file'
putdocx save diagnostic_`name_file'.docx, replace

}


*test code*
/*
putdocx clear
putdocx begin, font("Arial", 12) 

putdocx paragraph, halign(center)
putdocx image logos_cropped2.png, height (3 cm) linebreak
putdocx paragraph, halign (center)
putdocx text ("Scores du premier diagnostic - PEMA II GIZ “Commerce Electronique et Marketing Digital"), bold underline linebreak 
putdocx paragraph
putdocx text ("Cher(e) chef(fe) d’entreprise,")
putdocx paragraph
putdocx text ("Nous réitérons nos remerciements pour votre participation et vos réponses pour le premier sondage, à l’issue duquel, nous avons pu établir un premier diagnostic, s’inscrivant dans une série de trois diagnostics, que vous allez recevoir tout au long du projet.")
 
putdocx paragraph
putdocx text ("Ce diagnostic prend la forme de deux scores: un score de digitalisation (regroupant les questions relatives au marketing digital, à la présence en ligne et à  la logistique) et un score de préparation à l’export (établi grâce aux questions sur l’analyse de vos marchés cibles, la certification de vos produits ou services…).")
putdocx paragraph
putdocx text ("Ci-dessous  vous trouverez deux graphiques avec trois barres chacun:"), linebreak
putdocx paragraph
putdocx text ("		- La première (couleur) correspond au pourcentage de pratiques adoptées"), bold linebreak
putdocx text ("		  par votre entreprise."), bold linebreak
putdocx text ("		- La deuxième (couleur) correspond au pourcentage moyen de pratiques"), bold linebreak
putdocx text ("		  adoptées par l'ensemble des entreprises interrogées."), bold linebreak
putdocx text ("		- La troisième (couleur) correspond au pourcentage moyen de pratiques"), bold linebreak
putdocx text ("		  adoptées par l'ensemble des entreprises interrogées dans votre secteur."), bold linebreak



graph hbar ecom_dig avg_ecom_dig sectoral_avg_ecom_dig if row_id==58, ///
		subtitle ("Pourcentage de activités  adoptées") ///
		title ("Commerce electronique et marketing numerique") ///
		ysc(r(0 100)) ylab(0(10)100) ytitle("%") legend (pos (12) /// 
		lab(1 "Votre Score") lab(2 "Moyenne totale") lab(3 "Moyenne dans votre secteur")) ///
		bar (1 ,fc("208 33 36") lc("208 33 36")) ///
		bar (2 ,fc("241 160 40") lc("241 160 40")) /// 
		bar (3 ,fc("112 113 115") lc("112 113 115")) 
		
gr export dig_score_test.png, replace
putdocx paragraph, halign(center) 

putdocx image dig_score_test.png, height (6 cm)

putdocx paragraph
putdocx text ("`=ecom_dig_text[58]'"), linebreak

graph hbar expprep_diag avg_expprep_diag sectoral_avg_expprep_diag if row_id==58, ///
		subtitle ("Pourcentage de activités  adoptées") ///
		title ("Preparation des exportations") ///
		ysc(r(0 100)) ylab(0(10)100) ytitle("%") legend (pos (inside) /// 
		lab(1 "Votre Score") lab(2 "Moyenne totale") lab(3 "Moyenne dans votre secteur")) ///
		bar (1 ,fc("208 33 36") lc("208 33 36")) ///
		bar (2 ,fc("241 160 40") lc("241 160 40")) /// 
		bar (3 ,fc("112 113 115") lc("112 113 115")) 
		
gr export exp_score_test.png, replace
putdocx paragraph, halign(center) 
putdocx image exp_score_test.png, height (6 cm)
putdocx paragraph
putdocx text ("`=expprep_text[58]'"), linebreak


putdocx paragraph
putdocx text ("Nous espérons que ces scores vous permettrons de vous situer parmi les entreprises dans votre secteur et en globale."), linebreak 
putdocx paragraph
putdocx text ("Vous voulez savoir quelles pratiques peuvent vous aider à améliorer encore votre marketing numérique et votre commerce électronique ?"), bold linebreak 
putdocx text ("Assurez-vous de participer aux deuxième et troisième parties du diagnostic en novembre 2022 et 2023."), linebreak 
putdocx text ("A la fin du diagnostic complet, vous recevrez un autre rapport avec des recommandations individualisées."), linebreak
putdocx paragraph
putdocx text ("Cordialement,"), linebreak 
putdocx paragraph
putdocx text ("Equipe PEMA"), linebreak bold


putdocx save diagnostic_test2.docx, replace

