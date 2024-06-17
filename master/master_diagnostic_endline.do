
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
*	Author:  	Kaïs Jomaa												  
*	ID variable: 	id_plateforme			  									  
*	Requires:		bl_final.dta
*	Creates:		
*																	  

***********************************************************************
* 	PART Start: Import the data
***********************************************************************

	* import data
use "${master_final}/ecommerce_master_final", clear

**********************************************************************
* 	PART 1:  Final adaptation for diagnostics to be sent to firms 
* (agreed on 05.05.2022)
***********************************************************************

/* --------------------------------------------------------------------
	PART 1.2: Create scores (with overall and sector averages)
----------------------------------------------------------------------*/

* First, e-commerce / digitalisation practices: 
egen ecom_dig_raw= rowtotal(dig_presence1 dig_presence2 dig_presence3 dig_payment2 dig_payment3 dig_margins web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand dig_miseajour1 dig_miseajour2 dig_miseajour3 mark_online1 mark_online2 mark_online3 mark_online4 mark_online5) if surveyround ==3
g ecom_dig = (ecom_dig_raw/24)*100 if surveyround ==3
egen avg_ecom_dig = mean(ecom_dig) if surveyround ==3
egen sectoral_avg_ecom_dig = mean(ecom_dig) if surveyround ==3, by(sector)

lab var ecom_dig_raw "(Raw) sum of all e-commerce digitalisation practices"
lab var ecom_dig "Percentage of all e-commerce digitalisation practices"
lab var avg_ecom_dig "Average percentage of all e-commerce digitalisation practices"
lab var sectoral_avg_ecom_dig "Sectoral average percentage of all e-commerce digitalisation practices"


* Second, export preparedness practices: 
egen eri_raw = rowtotal(exp_pra_foire exp_pra_sci exp_pra_norme exp_pra_vent exp_pra_ach) if surveyround ==3
g expprep_diag = (eri_raw/5)*100 if surveyround ==3
egen avg_expprep_diag = mean(expprep_diag) if surveyround ==3
egen sectoral_avg_expprep_diag = mean(expprep_diag) if surveyround ==3, by(sector)

lab var eri_raw "Raw sum of all export preparadness practices"
lab var expprep_diag "Percentage of all export preparadness practices"
lab var avg_expprep_diag "Average percentage of all export preparadness practices"
lab var sectoral_avg_expprep_diag "Sectoral average percentage of all export preparadness practices"


/* --------------------------------------------------------------------
	PART 1.3: Create deciles for each diagnostic score
----------------------------------------------------------------------*/
sort ecom_dig
xtile ecom_decile = ecom_dig if surveyround ==3, n(10)

sort expprep_diag
xtile expprep_decile = expprep_diag if surveyround ==3, n(10)

lab var ecom_decile "Deciles for e-commerce/digitalisation score"
lab var expprep_decile "Deciles for export preparadness score"


	* Now create statements based on the deciles to be used in the text below 

gen ecom_dig_text = " "
replace ecom_dig_text = "Votre entreprise est classée dans les 10 % supérieurs en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_decile>9
replace ecom_dig_text = "Votre entreprise est classée dans les 25 % supérieurs en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig>= 67.70834 & ecom_decile<10
replace ecom_dig_text = "Votre entreprise se situe juste au-dessus de la moyenne en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig<67.70834 & ecom_dig>47.96402
replace ecom_dig_text = "Votre entreprise se situe juste en dessous de la moyenne en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig<=47.96402
replace ecom_dig_text = "Votre entreprise est classée dans les 25 % inférieurs en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig<=27.08333
replace ecom_dig_text = "Votre entreprise est classée dans les 10 % inférieurs en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig<=9.375

gen expprep_text = " "
replace expprep_text = "Votre entreprise se situe dans les 10 % supérieurs en termes d'adoption de pratiques de préparation à l'exportation." if expprep_diag>=100
replace expprep_text = "Votre entreprise se situe dans les 25 % supérieurs en termes d'adoption de pratiques de préparation à l'exportation." if expprep_diag>=80 & expprep_diag < 100
replace expprep_text = "Votre entreprise se situe juste au-dessus de la moyenne en termes d'adoption de pratiques de preparation à l'exportation." if expprep_diag>=52.42424 & expprep_diag<80
replace expprep_text = "Votre entreprise se situe juste en dessous de la moyenne en termes d'adoption de pratiques preparation à l'exportation." if expprep_diag<52.42424 & expprep_diag>40
replace expprep_text = "Votre entreprise est classée dans les 25 % inférieurs en termes d'adoption de pratiques de preparation à l'exportation." if expprep_diag<=40 &  expprep_diag>20
replace expprep_text = "Votre entreprise est classée dans les 10 % inférieurs en termes d'adoption de pratiques de preparation à l'exportation." if expprep_diag<=20


***********************************************************************
* 	PART 2:  	make a loop to automate document creation			  *
***********************************************************************
	
	* change directory for diagnostic files
cd "${master_output}/diagnostic"
set scheme s1color	 
set graphics off 
gen row_id = _n


levelsof id_plateforme if attest==1 & surveyround ==3, local(levels_id) 

set rmsg on

quietly{
	foreach x of local levels_id {
		noisily display "Working on `x' at $S_TIME"
		putdocx clear
		putdocx begin, font("Arial", 12) 
		putdocx paragraph, halign(center)
		putdocx image logos_cropped2.png, height (3 cm) linebreak
		putdocx paragraph, halign (center)
		putdocx text ("Scores du diagnostic - PEMA II GIZ “Commerce Electronique et Marketing Digital"), bold underline linebreak 
		putdocx paragraph
		putdocx text ("Cher(e) chef(fe) d’entreprise,")
		putdocx paragraph
		putdocx text ("Nous réitérons nos remerciements pour votre participation et vos réponses pour le dernier diagnostic, à l’issue duquel, nous avons pu établir ce diagnostic.")
		 
		putdocx paragraph
		putdocx text ("Ce diagnostic prend la forme de deux scores: un score de digitalisation (regroupant les questions relatives au marketing digital et à la présence en ligne) et un score de préparation à l’export (établi grâce aux questions sur l’analyse de vos marchés cibles, la certification de vos produits ou services…).")
		putdocx paragraph
		putdocx text ("Ci-dessous  vous trouverez deux graphiques avec trois barres chacun:"), linebreak
		putdocx paragraph
		putdocx text ("		- La première (rouge) correspond au pourcentage de pratiques adoptées"), bold linebreak
		putdocx text ("		  par votre entreprise."), bold linebreak
		putdocx text ("		- La deuxième (orange) correspond au pourcentage moyen de pratiques"), bold linebreak
		putdocx text ("		  adoptées par l'ensemble des entreprises interrogées."), bold linebreak
		putdocx text ("		- La troisième (gris) correspond au pourcentage moyen de pratiques"), bold linebreak
		putdocx text ("		  adoptées par l'ensemble des entreprises interrogées dans votre secteur."), bold linebreak



		graph hbar ecom_dig avg_ecom_dig sectoral_avg_ecom_dig if id_plateforme==`x', ///
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

		preserve

		keep if id_plateforme==`x'

		putdocx paragraph
		putdocx text ("`=ecom_dig_text[_n]'"), linebreak

		graph hbar expprep_diag avg_expprep_diag sectoral_avg_expprep_diag if id_plateforme==`x', ///
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
		putdocx text ("Cordialement,"), linebreak 
		putdocx paragraph
		putdocx text ("Equipe PEMA"), linebreak bold

		//local name_file id_plateforme[`x']
		//display `name_file'
		putdocx save diagnostic_`x'.docx, replace

		restore
	}
}


set rmsg off

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
putdocx text ("		- La première (rouge) correspond au pourcentage de pratiques adoptées"), bold linebreak
putdocx text ("		  par votre entreprise."), bold linebreak
putdocx text ("		- La deuxième (orange) correspond au pourcentage moyen de pratiques"), bold linebreak
putdocx text ("		  adoptées par l'ensemble des entreprises interrogées."), bold linebreak
putdocx text ("		- La troisième (grise) correspond au pourcentage moyen de pratiques"), bold linebreak
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

