***********************************************************************
* 			Descriptive Statistics in master file for endline survey  *					  
***********************************************************************
*																	  
*	PURPOSE: Understand the structure of the data from the different survey.					  
*																	  
*	OUTLINE: 	PART 1: Baseline and take-up
*				PART 2: Mid-line	  
*				PART 3: Endline 
*				PART 4: Intertemporal descriptive statistics															
*																	  
*	Author:  	Fabian Scheifele & Kaïs Jomaa							    
*	ID variable: id_platforme		  					  
*	Requires:  	 ecommerce_data_final.dta
***********************************************************************
* 	PART0: load data
***********************************************************************
use "${master_final}/ecommerce_master_final", clear
set graphics on		
		* change directory to regis folder for merge with regis_final
cd "${master_gdrive}/output/giz_el_simplified"
set scheme burd

*temporarily generate a variable that compares only companies that took up to control

gen take_up_control=.
replace take_up_control=1 if take_up==1 & treatment==1
replace take_up_control=0 if take_up==0 & treatment==0
label define take_up_control_lbl 1 "Participants" 0 "Groupe de comparaison"
label values take_up_control take_up_control_lbl
	
lab var dig_con5_ml "Google Ads"
lab var dig_con4_ml "Recherche organique"
lab var dig_con3_ml "Announce payantes"
lab var dig_con2_ml "Contenu digitale"
lab var knowledge_index "Connaissance globale"

lab var exported "Proportion des exporteurs"
lab var ihs_ca95_2024 "Chiffre d'affaire 2024"
lab var ihs_ca95_2023 "Chiffre d'affaire 2023"
lab var ihs_profit95_2023 "Benefice 2023"
lab var ihs_profit95_2024 "Benefice 2024"
lab var  w95_fte_young  "Employés jeunes"
lab var  eri  "Préparation à l'exportation"
lab var  dsi  "Practiques de vente numérique"
lab var  dmi  "Marketing numérique (qualitative)"
lab var  dtp  "Perception du marketing num./e-commerce"

lab var  dig_marketing_index  "Marketing numérique (quant. et qualitative)"
lab var  dtai  "Adoption technologie numérique"
lab var  ihs_exports95_2024  "Exports 2024"
lab var  ihs_exports95_2023  "Exports 2023"

gen share_profit_2023 = profit_2023_pos*100
gen share_profit_2024 = profit_2024_pos*100

lab var  share_profit_2023  "% avec benefice >0  en 2023"
lab var  share_profit_2024  "% avec benefice >0  en 2024"
lab var  fte_femmes  "Employés feminines"
lab var  fte  "Employés"

***********************************************************************
* 	PART 1: Adoption of digital practices and technologys
***********************************************************************
*Knowledge index midline
betterbar knowledge_index dig_con5_ml dig_con4_ml dig_con3_ml dig_con2_ml dig_con1_ml if surveyround == 2, over(take_up_control) barlab ci scale(0.8) ///     
    title("Connaissance du commerce électronique/numérique", size(small)) ///
    xtitle("", size(tiny)) ///
    ytitle("", size(tiny)) ///
    legend(size(small)) ///
    subtitle("", size(small)) ///
    note("", size(small)) 
	
gr export knowledge_ml.png, replace

*Digital Marketing and e-commerce practices (NO financials)
betterbar dsi dmi dtp dtai dig_marketing_index if surveyround == 3, ///
    over(take_up_control) barlab ci /// 
    title("Practiques de marketing numérique", size(small)) ///
    xtitle("", size(small)) ///
    ytitle("", size(small)) ///
    legend(size(small)) ///
    subtitle("", size(small)) ///
    note("", size(small))

	
gr export dig_practices.png, replace


*Exports
betterbar exported exported_2024 eri ihs_exports95_2023 ihs_exports95_2024 if surveyround == 3, over(take_up_control) barlab ci ///     
    title("Export", pos(12) size(small)) ///
    xtitle("", size(small)) ///
    ytitle("", size(small)) ///
    legend(size(small)) ///
    subtitle("", size(small)) ///
    note("", size(small))
	
gr export exports_overview.png, replace

*Profits, revenues employment
betterbar ihs_ca95_2024 ihs_ca95_2023 share_profit_2024 share_profit_2023 ihs_profit95_2024 ihs_profit95_2023 fte fte_femmes w95_fte_young if surveyround == 3, over(take_up_control) barlab ci ///     
    title("Résultats financiers", pos(12) size(small)) ///
    xtitle("", size(small)) ///
    ytitle("", size(small)) ///
    legend(size(small)) ///
    subtitle("", size(small)) ///
    note("", size(small))
	
gr export profit_ca_empl.png, replace


* Digital barriers
betterbar dig_barr1 dig_barr2 dig_barr3 dig_barr4 dig_barr5 dig_barr6 dig_barr7 if surveyround == 3, over(take_up_control) barlab ci ///     
    title("Raisons de la non-adoption des technologies numériques", pos(12) size(small)) ///
    xtitle("", size(small)) ///
    ytitle("", size(small)) ///
    legend(size(small)) ///
    subtitle("", size(small)) ///
    note("", size(small))
	
gr export dig_barr.png, replace