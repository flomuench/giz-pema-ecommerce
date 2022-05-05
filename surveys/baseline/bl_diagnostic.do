
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



lab var ecom_dig_raw "(Raw) sum of all e-commerce digital marketing practices"
lab var ecom_dig "Percentage of all e-commerce digital marketing practices"
lab var avg_ecom_dig "Sample average of e-commerce digital marketing practices"
lab var  sectoral_avg_ecom_dig "Sector averages of e-commerce digital marketing practices"



	* change directory for diagnostic files
cd "$bl_output/bl_diagnostic"
set scheme s1color	 
set graphics off 


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
putdocx text ("Ci-dessous  vous trouverez deux graphiques avec trois barres chacun:")
putdocx text ("-	La première (couleur) correspond au pourcentage de pratiques adoptées par votre entreprise."), bold
putdocx text ("-	La deuxième (couleur) correspond au pourcentage moyen de pratiques adoptées par l'ensemble des entreprises interrogées."), bold
putdocx text ("-	La troisième (couleur) correspond au pourcentage moyen de pratiques adoptées par l'ensemble des entreprises interrogées dans votre secteur.")


graph hbar ecom_dig avg_ecom_dig sectoral_avg_ecom_dig if id_plateforme==58
gr export dig_score_test.png, replace
putdocx paragraph, halign(center) 
putdocx image dig_score_test.png, width (13.75 cm) height (10 cm)




graph hbar ecom_dig avg_ecom_dig sectoral_avg_ecom_dig if id_plateforme==58
gr export exp_score_test.png, replace
putdocx paragraph, halign(center) 
putdocx image exp_score_test.png, width (13.75 cm) height (10 cm)




putdocx text ("Nous espérons que ces scores vous permettrons de vous situer parmi les entreprises dans votre secteur et en globale."), linebreak 
putdocx text ("Vous voulez savoir quelles pratiques peuvent vous aider à améliorer encore votre marketing numérique et votre commerce électronique ?"), bold 
putdocx text ("Assurez-vous de participer aux deuxième et troisième parties du diagnostic en novembre 2022 et 2023. A la fin du diagnostic complet, vous recevrez un autre rapport avec des recommandations individualisées.")


putdocx save diagnostic_test.docx, replace




