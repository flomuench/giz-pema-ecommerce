***********************************************************************
* 			e-commerce midline survey variable generation                    	
***********************************************************************
*																	    
*	PURPOSE: generate variables required for the monitoring of baseline survey (no index creation)				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Generate summary variables of multiple answer questions	
*   2)		Create composite variable, adding different scores together 	  				  
* 	3) 		Create variables required for data quality monitoring

*																	  															      
*	Author:  	Fabian Scheifele, Kais Jomaa & Ayounb							  
*	ID variaregise: 	id (example: f101)			  					  
*	Requires: ml_inter.dta 	  								  
*	Creates:  ml_final.dta			                          
*	
																  
***********************************************************************
* 	PART 1:  Generate summary variables of multiple answer questions 			
***********************************************************************
gen surveyround = 2
lab var surveyround "1-baseline 2-midline 3-endline"

local multi_vars dig_marketing_num110 dig_moyen_paie
gen dig_marketing_num19_sea =0
replace dig_marketing_num19_sea =1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_sea") 

gen dig_marketing_num19_seo =0
replace dig_marketing_num19_seo =1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_seo") 

gen dig_marketing_num19_blg =0
replace dig_marketing_num19_blg =1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_blg") 

gen dig_marketing_num19_pub =0
replace dig_marketing_num19_pub =1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_pub") 
    
gen dig_marketing_num19_mail =0
replace dig_marketing_num19_mail =1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_mail") 
 
gen dig_marketing_num19_prtn =0
replace dig_marketing_num19_prtn =1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_prtn") 

gen dig_marketing_num19_socm=0
replace dig_marketing_num19_socm=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_socm") 
 
gen dig_marketing_num8=0
replace dig_marketing_num8=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num8") 
 
gen dig_marketing_num19_autre=0
replace dig_marketing_num19_autre=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_autre") 
 
gen dig_marketing_num19_aucu=0
replace dig_marketing_num19_aucu=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_aucu")

gen dig_marketing_num19_nsp=0
replace dig_marketing_num19_nsp=1 if ustrregexm(dig_marketing_num110, "-999")

drop dig_marketing_num110

gen dig_con1_moyen_paie1=0
replace dig_con1_moyen_paie1=1 if ustrregexm(dig_moyen_paie, "1") 
 
gen dig_con1_moyen_paie2=0
replace dig_con1_moyen_paie2=1 if ustrregexm(dig_moyen_paie, "2") 
																  
gen dig_con1_moyen_paie3=0
replace dig_con1_moyen_paie3=1 if ustrregexm(dig_moyen_paie, "3") 

gen dig_con1_moyen_paie4=0
replace dig_con1_moyen_paie4=1 if ustrregexm(dig_moyen_paie, "4") 

gen dig_con1_moyen_paie5=0
replace dig_con1_moyen_paie5=1 if ustrregexm(dig_moyen_paie, "5") 
																  
gen dig_con1_moyen_paie6=0
replace dig_con1_moyen_paie6=1 if ustrregexm(dig_moyen_paie, "6")

drop dig_moyen_paie

gen dig_con2_contenu1 = 0															  
replace dig_con2_contenu1=1 if ustrregexm(dig_contenu, "1")

gen dig_con2_contenu2 = 0															  
replace dig_con2_contenu2=1 if ustrregexm(dig_contenu, "2")

gen dig_con2_contenu3 = 0															  
replace dig_con2_contenu3=1 if ustrregexm(dig_contenu, "3")

gen dig_con2_contenu4 = 0															  
replace dig_con2_contenu4=1 if ustrregexm(dig_contenu, "4")

drop dig_contenu

gen dig_con3_google_analytics1 = 0
replace dig_con3_google_analytics1=1 if ustrregexm(dig_google_analytics, "1")

gen dig_con3_google_analytics2 = 0
replace dig_con3_google_analytics2=1 if ustrregexm(dig_google_analytics, "2")

gen dig_con3_google_analytics3 = 0
replace dig_con3_google_analytics3=1 if ustrregexm(dig_google_analytics, "3")

gen dig_con3_google_analytics4 = 0
replace dig_con3_google_analytics4=1 if ustrregexm(dig_google_analytics, "4")

gen dig_con3_google_analytics5 = 0
replace dig_con3_google_analytics5=1 if ustrregexm(dig_google_analytics, "5")

drop dig_google_analytics

gen dig_con4_taux_eng1 = 0
replace dig_con4_taux_eng1=1 if ustrregexm(dig_taux_eng, "1")

gen dig_con4_taux_eng2 = 0
replace dig_con4_taux_eng2=1 if ustrregexm(dig_taux_eng, "2")

gen dig_con4_taux_eng3 = 0
replace dig_con4_taux_eng3=1 if ustrregexm(dig_taux_eng, "3")

gen dig_con4_taux_eng4 = 0
replace dig_con4_taux_eng4=1 if ustrregexm(dig_taux_eng, "4")

gen dig_con4_taux_eng5 = 0
replace dig_con4_taux_eng5=1 if ustrregexm(dig_taux_eng, "5")

drop dig_taux_eng

gen dig_con5_techniques_seo1 = 0
replace dig_con5_techniques_seo1=1 if ustrregexm(dig_techniques_seo, "1")

gen dig_con5_techniques_seo2 = 0
replace dig_con5_techniques_seo2=1 if ustrregexm(dig_techniques_seo, "2")

gen dig_con5_techniques_seo3 = 0
replace dig_con5_techniques_seo3=1 if ustrregexm(dig_techniques_seo, "3")

gen dig_con5_techniques_seo4 = 0
replace dig_con5_techniques_seo4=1 if ustrregexm(dig_techniques_seo, "4")

gen dig_con5_techniques_seo5 = 0
replace dig_con5_techniques_seo5=1 if ustrregexm(dig_techniques_seo, "5")

drop dig_techniques_seo

***********************************************************************
* 	PART 2:  Drop useless variables		
***********************************************************************
drop id_ident  id_ident2 verification validation attest
***********************************************************************
* 	PART 6:  save			
***********************************************************************
save "${ml_final}/ml_final", replace
