***********************************************************************
* 			E-commerce field experiment:  stratification								  		  
***********************************************************************
*																	   
*	PURPOSE: Stratify firms that responded to baseline survey; select stratification approach						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Visualisation of candidate strata variables
*	2)		Generate strata using different appraoches
*	3)		Calculate variance by stratification approach
*   4)		Save														  
*
*																 																      *
*	Author:  	Teo Firpo & Fabian Scheifele													  
*	ID variable: 	id_plateforme			  									  
*	Requires:		bl_final.dta
*	Creates:		
*																	  
***********************************************************************
* 	PART I:  	define the settings as necessary 			     	  *
***********************************************************************

	* import data
use "${bl_final}/bl_final", clear

	* change directory for diagnostic files
cd "$bl_output/bl_diagnostic"
set scheme s1color	 
set graphics off 

gen row_id= _n
gen digital_avg = 15.3
gen sector_avg = 12


***********************************************************************
* 	PART I:  	make a loop to automate document creation			  *
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



