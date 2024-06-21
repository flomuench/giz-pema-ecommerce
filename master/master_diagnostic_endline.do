
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

*Second, digital sales index
egen dsi_raw= rowtotal(dig_presence1 dig_presence2 dig_presence3 dig_payment2 dig_payment3 dig_margins web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand dig_miseajour1 dig_miseajour2 dig_miseajour3) if surveyround ==3
g dsi_dig = (dsi_raw/19)*100 if surveyround ==3
egen avg_dsi_dig = mean(dsi_dig) if surveyround ==3
egen sectoral_avg_dsi_dig = mean(dsi_dig) if surveyround ==3, by(sector)

lab var dsi_raw "(Raw) sum of digital sales practices"
lab var dsi_dig "Percentage of digital sales practices"
lab var avg_dsi_dig "Average percentage of all digital sales practices"
lab var sectoral_avg_dsi_dig "Sectoral average percentage of all digital sales practices"

*Thridly, digital marketing index
egen dmi_raw= rowtotal(mark_online1 mark_online2 mark_online3 mark_online4 mark_online5) if surveyround ==3
g dmi_dig = (dmi_raw/5)*100 if surveyround ==3
egen avg_dmi_dig = mean(dmi_dig) if surveyround ==3
egen sectoral_avg_dmi_dig = mean(dmi_dig) if surveyround ==3, by(sector)

lab var dmi_raw "(Raw) sum of digital marketing practices"
lab var dmi_dig "Percentage of digital marketing practices"
lab var avg_dmi_dig "Average percentage of all digital marketing practices"
lab var sectoral_avg_dmi_dig "Sectoral average percentage of all digital marketing practices"

*Fourthly, share of digital investment
replace dig_invest = . if dig_invest == 999
replace dig_invest = . if dig_invest == 888
replace dig_invest = . if dig_invest == 777
replace dig_invest = . if dig_invest == 666

replace mark_invest = . if mark_invest == 999
replace mark_invest = . if mark_invest == 888
replace mark_invest = . if mark_invest == 777
replace mark_invest = . if mark_invest == 666

gen dig_share = (dig_invest/(dig_invest+mark_invest))*100 if surveyround ==3 & dig_invest!=. & mark_invest!=.
egen avg_dig_share = mean(dig_share) if surveyround ==3
egen sectoral_avg_dig_share = mean(dig_share) if surveyround ==3, by(sector)

lab var dig_share "Share of digital marketing investment of all marketing investment"
lab var avg_ecom_dig "Average percentage of digital marketing investment of all marketing investment"
lab var sectoral_avg_ecom_dig "Sectoral average percentage of digital marketing investment of all marketing investment"


* Fifthly, export preparedness practices 
egen eri_raw = rowtotal(exp_pra_foire exp_pra_sci exp_pra_norme exp_pra_vent exp_pra_ach) if surveyround ==3
g expprep_diag = (eri_raw/5)*100 if surveyround ==3
egen avg_expprep_diag = mean(expprep_diag) if surveyround ==3
egen sectoral_avg_expprep_diag = mean(expprep_diag) if surveyround ==3, by(sector)

lab var eri_raw "Raw sum of all export preparadness practices"
lab var expprep_diag "Percentage of all export preparadness practices"
lab var avg_expprep_diag "Average percentage of all export preparadness practices"
lab var sectoral_avg_expprep_diag "Sectoral average percentage of all export preparadness practices"

*Sixthly, number of export countries
egen avg_exp_pays_diag = mean(exp_pays) if surveyround ==3
egen sectoral_avg_exp_pays_diag = mean(exp_pays) if surveyround ==3, by(sector)

lab var avg_exp_pays_diag "Average of number of export countries"
lab var sectoral_avg_exp_pays_diag "Sectoral average of number of export countries"

*Seventhly, employer productivity
replace comp_ca2023 = . if comp_ca2023 == 999
replace comp_ca2023 = . if comp_ca2023 == 888
replace comp_ca2023 = . if comp_ca2023 == 777
replace comp_ca2023 = . if comp_ca2023 == 666

gen productivity_2023 = (comp_ca2023/fte) if surveyround ==3
egen avg_productivity_2023_diag = mean(productivity_2023) if surveyround ==3
egen sectoral_productivity_2023_diag = mean(productivity_2023) if surveyround ==3, by(sector)
 
lab var productivity_2023 "Company productivity: total turnover over total number of full-time employees" 
lab var avg_productivity_2023_diag "Average employee productivity"
lab var sectoral_productivity_2023_diag "Sectoral average employee productivity"

 
 
			* Une visualisation par page
			* Aggranding la taille des visualiations
			* Rajouter des sections: 1) Performance Digital 2) Préparation et performance à l'export 3) Perfomance générale

/* --------------------------------------------------------------------
	PART 1.3: Create deciles for each diagnostic score
----------------------------------------------------------------------*/
sort dsi_dig
xtile dsi_dig_decile = dsi_dig if surveyround ==3, n(10)
lab var dsi_dig_decile "Deciles for digital sales practices"

sort dmi_dig
xtile dmi_dig_decile = dmi_dig if surveyround ==3, n(10)
lab var dmi_dig_decile "Deciles for digital marketing practices"

sort dig_share
xtile dig_share_decile = dig_share if surveyround ==3, n(10)
lab var dig_share_decile "Deciles for share of digital marketing investment"

sort ecom_dig
xtile ecom_decile = ecom_dig if surveyround ==3, n(10)
lab var ecom_decile "Deciles for e-commerce/digitalisation score"

sort expprep_diag
xtile expprep_decile = expprep_diag if surveyround ==3, n(10)
lab var expprep_decile "Deciles for export preparadness score"

sort exp_pays
xtile exp_pays_decile = exp_pays if surveyround ==3, n(10)
lab var exp_pays_decile "Deciles for export countries"

sort productivity_2023
xtile productivity_2023_decile = productivity_2023 if surveyround ==3, n(10)
lab var productivity_2023_decile "Deciles for productivity"

	* Now create statements based on the deciles to be used in the text below 
*1) Performance Digitale
gen dsi_raw_text = " "
replace dsi_raw_text = "Votre entreprise se situe dans les 10 % supérieurs en termes d'adoption de pratiques de commerce électronique et de ventes digitales." if dsi_dig > 77.63158 & surveyround ==3
replace dsi_raw_text = "Votre entreprise se situe dans les 25 % supérieurs en termes d'adoption de pratiques de commerce électronique et de ventes digitales." if dsi_dig>= 71.05264 & dsi_dig < 77.63158 & surveyround ==3
replace dsi_raw_text = "Votre entreprise se situe juste au-dessus de la moyenne en termes d'adoption de pratiques de commerce électronique et de ventes digitales." if dsi_dig>=48.82272 & dsi_dig<71.05264 & surveyround ==3
replace dsi_raw_text = "Votre entreprise se situe juste en dessous de la moyenne en termes d'adoption de pratiques commerce électronique et de ventes digitales." if dsi_dig<48.82272 & dsi_dig>27.63158 & surveyround ==3
replace dsi_raw_text = "Votre entreprise est classée dans les 25 % inférieurs en termes d'adoption de pratiques de commerce électronique et de ventes digitales." if dsi_dig<=27.63158 &  dsi_dig>10.52632  & surveyround ==3
replace dsi_raw_text = "Votre entreprise est classée dans les 10 % inférieurs en termes d'adoption de pratiques de commerce électronique et de ventes digitales." if dsi_dig<=10.52632 | dmi_dig==0 | dmi_dig_decile < 1 & surveyround ==3
replace dsi_raw_text = "Vous n’avez pas répondu à cette question et ainsi nous ne pouvons pas calculer un score pour vous" if dsi_dig==.

gen dmi_raw_text = " "
replace dmi_raw_text = "Votre entreprise se situe dans les 10 % supérieurs en termes d'adoption de pratiques de marketing digital." if dmi_dig>= 80 & surveyround ==3
replace dmi_raw_text = "Votre entreprise se situe dans les 25 % supérieurs en termes d'adoption de pratiques de marketing digital." if dmi_dig>=60  & dmi_dig < 80 & surveyround ==3
replace dmi_raw_text = "Votre entreprise se situe juste au-dessus de la moyenne en termes d'adoption de pratiques de marketing digital." if dmi_dig>=45.26316 & dmi_dig<60 & surveyround ==3
replace dmi_raw_text = "Votre entreprise se situe juste en dessous de la moyenne en termes d'adoption de pratiques de marketing digital." if dmi_dig>20 & dmi_dig<45.26316  & surveyround ==3
replace dmi_raw_text = "Votre entreprise est classée dans les 10 % inférieurs en termes d'adoption de pratiques de marketing digital." if dmi_dig<=20 | dmi_dig==0 & surveyround ==3
replace dmi_raw_text = "Vous n’avez pas répondu à cette question et ainsi nous ne pouvons pas calculer un score pour vous" if dmi_dig==.

gen ecom_dig_text = " "
replace ecom_dig_text = "Votre entreprise est classée dans les 10 % supérieurs en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig>=75 & surveyround ==3 
replace ecom_dig_text = "Votre entreprise est classée dans les 25 % supérieurs en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig>= 67.70834 & ecom_dig<75 & surveyround ==3
replace ecom_dig_text = "Votre entreprise se situe juste au-dessus de la moyenne en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig<67.70834 & ecom_dig>=48.08114 & surveyround ==3
replace ecom_dig_text = "Votre entreprise se situe juste en dessous de la moyenne en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig<48.08114 & ecom_dig > 27.08333 & surveyround ==3
replace ecom_dig_text = "Votre entreprise est classée dans les 25 % inférieurs en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig<=27.08333 & ecom_dig > 9.375 & surveyround ==3
replace ecom_dig_text = "Votre entreprise est classée dans les 10 % inférieurs en termes d'adoption de pratiques de commerce électronique et de marketing numérique." if ecom_dig<= 9.375 | ecom_dig==0 & surveyround ==3
replace ecom_dig_text = "Vous n’avez pas répondu à cette question et ainsi nous ne pouvons pas calculer un score pour vous" if ecom_dig==.

gen dig_share_text = " "
replace dig_share_text = "Votre entreprise est classée dans les 10 % supérieurs en termes de proportion d'investissement dans le marketing digital." if dig_share>=100 & surveyround ==3
replace dig_share_text = "Votre entreprise est classée dans les 25 % supérieurs en termes de proportion d'investissement dans le marketing digital." if dig_share>=50   & dig_share < 100 & surveyround ==3
replace dig_share_text = "Votre entreprise se situe juste au-dessus de la moyenne en termes de proportion d'investissement dans le marketing digital." if dig_share>= 36.62001 & dig_share<50  & surveyround ==3
replace dig_share_text = "Votre entreprise se situe juste en dessous de la moyenne en termes de proportion d'investissement dans le marketing digital." if dig_share< 36.62001 & dig_share>=3.600465 & surveyround ==3
replace dig_share_text = "Votre entreprise est classée dans les 25 % inférieurs en termes de proportion d'investissement dans le marketing digital." if dig_share<3.600465 &  dig_share> 0 & surveyround ==3
replace dig_share_text = "Votre entreprise est classée dans les 10 % inférieurs en termes de proportion d'investissement dans le marketing digital." if dig_share<=0  & surveyround ==3
replace dig_share_text = "Vous n’avez pas répondu à cette question et ainsi nous ne pouvons pas calculer un score pour vous" if dig_share==.

*2) Préparation et performance à l'export
gen expprep_text = " "
replace expprep_text = "Votre entreprise se situe dans les 10 % supérieurs en termes d'adoption de pratiques de préparation à l'exportation." if expprep_diag>=100 & surveyround ==3 
replace expprep_text = "Votre entreprise se situe dans les 25 % supérieurs en termes d'adoption de pratiques de préparation à l'exportation." if expprep_diag>=80 & expprep_diag < 100 & surveyround ==3
replace expprep_text = "Votre entreprise se situe juste au-dessus de la moyenne en termes d'adoption de pratiques de preparation à l'exportation." if expprep_diag>= 52.33083 & expprep_diag<80 & surveyround ==3
replace expprep_text = "Votre entreprise se situe juste en dessous de la moyenne en termes d'adoption de pratiques preparation à l'exportation." if expprep_diag< 52.33083 & expprep_diag>40 & surveyround ==3
replace expprep_text = "Votre entreprise est classée dans les 25 % inférieurs en termes d'adoption de pratiques de preparation à l'exportation." if expprep_diag<=40 &  expprep_diag>20 & surveyround ==3
replace expprep_text = "Votre entreprise est classée dans les 10 % inférieurs en termes d'adoption de pratiques de preparation à l'exportation." if expprep_diag<=20 | expprep_diag==0  & surveyround ==3
replace expprep_text = "Vous n’avez pas répondu à cette question et ainsi nous ne pouvons pas calculer un score pour vous" if expprep_diag==.

gen exp_pays_text = " "
replace exp_pays_text = "Votre entreprise se situe dans les 10 % supérieurs en termes de nombre de destinations pour l'export." if exp_pays_decile >=9 & surveyround ==3 
replace exp_pays_text = "Votre entreprise se situe dans les 25 % supérieurs en termes de nombre de destinations pour l'export." if exp_pays>=7 & exp_pays < 16 & surveyround ==3
replace exp_pays_text = "Votre entreprise se situe juste au-dessus de la moyenne en termes de nombre de destinations pour l'export." if exp_pays<=5 & exp_pays>7  & surveyround ==3
replace exp_pays_text = "Votre entreprise se situe juste en dessous de la moyenne en termes de nombre de destinations pour l'export." if exp_pays<5 & exp_pays>2 & surveyround ==3
replace exp_pays_text = "Votre entreprise est classée dans les 25 % inférieurs en termes de nombre de destinations pour l'export." if exp_pays<=2 &  exp_pays>1 & surveyround ==3
replace exp_pays_text = "Votre entreprise est classée dans les 10 % inférieurs en termes de pays d'export." if exp_pays<=1 | exp_pays==0 & surveyround ==3
replace exp_pays_text = "Vous n’avez pas répondu à cette question et ainsi nous ne pouvons pas calculer un score pour vous" if exp_pays==.

*3) Perfomance générale
gen productivity_2023_text = " "
replace productivity_2023_text = "Votre entreprise se situe dans les 10 % supérieurs en termes de productivité par employé." if productivity_2023>= 251473.9 & surveyround ==3 
replace productivity_2023_text = "Votre entreprise se situe juste au-dessus de la moyenne en termes de productivité par employé." if productivity_2023>=107454.9 & productivity_2023<100000 & surveyround ==3
replace productivity_2023_text = "Votre entreprise se situe juste en dessous de la moyenne en termes de productivité par employé." if productivity_2023<107454.9 & productivity_2023>177.6 & surveyround ==3
replace productivity_2023_text = "Votre entreprise est classée dans les 25 % inférieurs en termes de productivité par employé." if productivity_2023 <= 177.6 &  productivity_2023>12.10909 & surveyround ==3
replace productivity_2023_text = "Votre entreprise est classée dans les 10 % inférieurs en termes de productivité par employé." if productivity_2023 <= 12.109091 | (productivity_2023 == 0 & surveyround == 3)
replace productivity_2023_text = "Vous n’avez pas répondu à cette question et ainsi nous ne pouvons pas calculer un score pour vous" if productivity_2023==.

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
		putdocx text ("Ce diagnostic prend la forme de plusieurs scores: un score de digitalisation (regroupant les questions relatives au marketing digital et à la présence en ligne), l'investissement dans le digital, un score de préparation à l’export (établi grâce aux questions sur l’analyse de vos marchés cibles, la certification de vos produits ou services…), les pays d'exports et un score sur la productivité de votre entreprise.")
		putdocx paragraph
		putdocx paragraph
		putdocx text ("Ces scores ont été établis sur la base des réponses de plus de 200 entreprises ayant répondu aux différentes vagues de diagnostic.")
		putdocx paragraph
		putdocx text ("Ci-dessous  vous trouverez deux graphiques avec trois barres chacun:"), linebreak
		putdocx paragraph
		putdocx text ("		- La première (rouge) correspond au pourcentage de pratiques adoptées"), bold linebreak
		putdocx text ("		  par votre entreprise."), bold linebreak
		putdocx text ("		- La deuxième (orange) correspond au pourcentage moyen de pratiques"), bold linebreak
		putdocx text ("		  adoptées par l'ensemble des entreprises interrogées."), bold linebreak
		putdocx text ("		- La troisième (gris) correspond au pourcentage moyen de pratiques"), bold linebreak
		putdocx text ("		  adoptées par l'ensemble des entreprises interrogées dans votre secteur."), bold linebreak
		
		putdocx pagebreak
		putdocx paragraph,  font("Arial", 12)
		putdocx text ("Section 1: La performance digitale de l'entreprise"), bold

		putdocx paragraph
		putdocx text ("Le score du commerce éléctronique et ventes digitales a été construit sur la présence sur les différents canaux de commerce éléctronique et leur mise à jour, la possibilité de pouvoir payer en ligne et les différentes manières d'utilisation du site web et des reseaux sociaux"), linebreak
		putdocx paragraph
		
		graph    hbar dsi_dig avg_dsi_dig sectoral_avg_dsi_dig if id_plateforme==`x', blabel(total, format(%9.0fc)) ///
				subtitle ("Pourcentage des activités adoptées") ///
				title ("Commerce éléctronique et ventes digitales") ///
				ysc(r(0 100)) ylab(0(10)100) ytitle("%") legend (pos (12) /// 
				lab(1 "Votre Score") lab(2 "Moyenne totale") lab(3 "Moyenne dans votre secteur")) ///
				bar (1 ,fc("208 33 36") lc("208 33 36")) ///
				bar (2 ,fc("241 160 40") lc("241 160 40")) /// 
				bar (3 ,fc("112 113 115") lc("112 113 115")) 
				
		gr export dsi_score_test_`x'.png, replace
		putdocx paragraph, halign(center) 

		putdocx image dsi_score_test_`x'.png, height (12 cm)

		preserve
		keep if id_plateforme==`x'
		putdocx paragraph
		putdocx text ("`=dsi_raw_text[_n]'"), linebreak
		restore
		
		putdocx pagebreak
		putdocx paragraph
		putdocx text ("Le score des activités de marketing digital a été construit sur la 5 pratiques de marketing numérique : E-mailing & Newsletters, SEA & SEO, Marketing gratuit sur les réseaux sociaux, Marketing payant sur les réseaux sociaux ou d'autres activités."), linebreak
		putdocx paragraph
		
		graph hbar dmi_dig avg_dmi_dig sectoral_avg_dmi_dig  if id_plateforme==`x', blabel(total, format(%9.0fc)) ///
		subtitle ("Pourcentage des activités adoptées") ///
		title ("Activités en marketing digital") ///
		ysc(r(0 100)) ylab(0(10)100) ytitle("%") legend (pos (12) /// 
		lab(1 "Votre Score") lab(2 "Moyenne totale") lab(3 "Moyenne dans votre secteur")) ///
		bar (1 ,fc("208 33 36") lc("208 33 36")) ///
		bar (2 ,fc("241 160 40") lc("241 160 40")) /// 
		bar (3 ,fc("112 113 115") lc("112 113 115")) 
				
		gr export dmi_score_test_`x'.png, replace
		putdocx paragraph, halign(center) 

		putdocx image dmi_score_test_`x'.png, height (12 cm)
		
		preserve
		keep if id_plateforme==`x'
		putdocx paragraph
		putdocx text ("`=dmi_raw_text[_n]'"), linebreak
		restore
		
		graph hbar dig_share avg_dig_share sectoral_avg_dig_share  if id_plateforme==`x', blabel(total, format(%9.0fc)) ///
		subtitle ("Part de l'investissement du marketing digital dans l'investissement marketing") ///
		title ("Proportion de l'investissement du marketing digital en 2023") ///
		ysc(r(0 100)) ylab(0(10)100) ytitle("%") legend (pos (12) /// 
		lab(1 "Votre Score") lab(2 "Moyenne totale") lab(3 "Moyenne dans votre secteur")) ///
		bar (1 ,fc("208 33 36") lc("208 33 36")) ///
		bar (2 ,fc("241 160 40") lc("241 160 40")) /// 
		bar (3 ,fc("112 113 115") lc("112 113 115")) 
				
		gr export dig_share_score_test_`x'.png, replace
		putdocx paragraph, halign(center) 

		putdocx image dig_share_score_test_`x'.png, height (12 cm)

		preserve
		keep if id_plateforme==`x'
		putdocx paragraph
		putdocx text ("`=dig_share_text[_n]'"), linebreak
		restore
		
		putdocx pagebreak
		putdocx paragraph
		putdocx text ("Le score de commerce electronique et marketing numerique est un score aggrégé du score des activités de marketing digital et du score du commerce éléctronique."), linebreak
		putdocx paragraph

		graph hbar ecom_dig avg_ecom_dig sectoral_avg_ecom_dig if id_plateforme==`x', blabel(total, format(%9.0fc)) ///
				subtitle ("Pourcentage des activités  adoptées") ///
				title ("Commerce electronique et marketing numerique") ///
				ysc(r(0 100)) ylab(0(10)100) ytitle("%") legend (pos (12) /// 
				lab(1 "Votre Score") lab(2 "Moyenne totale") lab(3 "Moyenne dans votre secteur")) ///
				bar (1 ,fc("208 33 36") lc("208 33 36")) ///
				bar (2 ,fc("241 160 40") lc("241 160 40")) /// 
				bar (3 ,fc("112 113 115") lc("112 113 115")) 
				
		gr export dig_score_test_`x'.png, replace
		putdocx paragraph, halign(center) 

		putdocx image dig_score_test_`x'.png, height (12 cm)

		preserve
		keep if id_plateforme==`x'
		putdocx paragraph
		putdocx text ("`=ecom_dig_text[_n]'"), linebreak
		restore 
		
		putdocx pagebreak
		putdocx paragraph,  font("Arial", 12)
		putdocx text ("Section 2: Préparation et performance à l'export de l'entreprise"), bold

		putdocx paragraph
		putdocx text ("Le score de  préparation et performance à l'export a été construit sur la la base de la participation à des expositions/ foires commerciales internationales, l'expression d'intérérêt d'un acheteur potentiel, l'identification de partenaires commerciaux à l'étranger, la certification des produits selon des normes de qualité internationales et l'investissement d'une structure de vente."), linebreak
		putdocx paragraph
		

		graph hbar expprep_diag avg_expprep_diag sectoral_avg_expprep_diag if id_plateforme==`x', blabel(total, format(%9.0fc)) ///
				subtitle ("Pourcentage de activités adoptées") ///
				title ("Preparation des exportations") ///
				ysc(r(0 100)) ylab(0(10)100) ytitle("%") legend (pos (inside) /// 
				lab(1 "Votre Score") lab(2 "Moyenne totale") lab(3 "Moyenne dans votre secteur")) ///
				bar (1 ,fc("208 33 36") lc("208 33 36")) ///
				bar (2 ,fc("241 160 40") lc("241 160 40")) /// 
				bar (3 ,fc("112 113 115") lc("112 113 115")) 
				
		gr export exp_score_test_`x'.png, replace
		putdocx paragraph, halign(center) 
		putdocx image exp_score_test_`x'.png, height (10 cm)
		
		preserve
		keep if id_plateforme==`x'
		putdocx paragraph
		putdocx text ("`=expprep_text[_n]'"), linebreak
		restore 
		
		graph hbar exp_pays avg_exp_pays_diag sectoral_avg_exp_pays_diag if id_plateforme==`x', blabel(total, format(%9.0fc)) ///
				title ("Nombre de pays d'export") ///
				ytitle("Nombre de pays") legend (pos (inside) /// 
				lab(1 "Votre Score") lab(2 "Moyenne totale") lab(3 "Moyenne dans votre secteur")) ///
				bar (1 ,fc("208 33 36") lc("208 33 36")) ///
				bar (2 ,fc("241 160 40") lc("241 160 40")) /// 
				bar (3 ,fc("112 113 115") lc("112 113 115")) 
				
		gr export exp_pays_score_test_`x'.png, replace
		putdocx paragraph, halign(center) 
		putdocx image exp_pays_score_test_`x'.png, height (10 cm)
		
		preserve
		keep if id_plateforme==`x'
		putdocx paragraph
		putdocx text ("`=exp_pays_text[_n]'"), linebreak
		restore
		
		putdocx pagebreak
		putdocx paragraph,  font("Arial", 12)
		putdocx text ("Section 3: La perfomance générale de l'entreprise"), bold

		graph hbar productivity_2023 avg_productivity_2023_diag sectoral_productivity_2023_diag if id_plateforme==`x', blabel(total, format(%9.0fc)) ///
				title ("Productivité de l'entreprise") ///
				subtitle ("Chiffre d'affaires total sur le nombre total de salariés à temps plein") ///
				ytitle("Productivité") legend (pos (inside) /// 
				lab(1 "Votre Score") lab(2 "Moyenne totale") lab(3 "Moyenne dans votre secteur")) ///
				bar (1 ,fc("208 33 36") lc("208 33 36")) ///
				bar (2 ,fc("241 160 40") lc("241 160 40")) /// 
				bar (3 ,fc("112 113 115") lc("112 113 115")) 
				
		gr export productivity_score_test_`x'.png, replace
		putdocx paragraph, halign(center) 
		putdocx image productivity_score_test_`x'.png, height (10 cm)
		
		preserve
		keep if id_plateforme==`x'
		putdocx paragraph
		putdocx text ("`=productivity_2023_text[_n]'"), linebreak
		
		
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

