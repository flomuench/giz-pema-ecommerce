***********************************************************************
* 			e-commerce endline survey variable generation                    	
***********************************************************************
*																	    
*	PURPOSE: generate variables required for the monitoring of endline survey (no index creation)				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Generate summary variables of multiple answer questions	
*   2)		Generate variables for companies who answered on phone	  				  
* 	3) 		Drop useless variables	
* 	4) 		Change format type	
* 	5) 		Change format type	
* 	6) 		Create variable required for coherence test	 	
* 	6) 		Save the changes made to the data
																  															      
*	Author:  	Kaïs Jomaa		  
*	ID variable: 	id (example: f101)			  					  
*	Requires: el_intermediate.dta 	  								  
*	Creates:  el_final.dta			                          
*	
***********************************************************************
* 	PART 1:  Generate summary variables of multiple answer questions 			
***********************************************************************
use "${el_intermediate}/el_intermediate", clear																  

gen surveyround = 3
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
 
gen dig_marketing_num19_socm_pay=0
replace dig_marketing_num19_socm_pay=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num8") 
 
gen dig_marketing_num19_autre=0
replace dig_marketing_num19_autre=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_autre") 
 
gen dig_marketing_num19_aucu=0
replace dig_marketing_num19_aucu=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_aucu")

gen dig_marketing_num19_nsp=0
replace dig_marketing_num19_nsp=1 if ustrregexm(dig_marketing_num110, "-999")

drop dig_marketing_num110

gen dig_con1_moyen_paie1= 0
replace dig_con1_moyen_paie1=0.5 if ustrregexm(dig_moyen_paie, "1") 
 
gen dig_con1_moyen_paie2=0
replace dig_con1_moyen_paie2=-0.5 if ustrregexm(dig_moyen_paie, "2") 
																  
gen dig_con1_moyen_paie3= 0
replace dig_con1_moyen_paie3=0.5 if ustrregexm(dig_moyen_paie, "3") 

gen dig_con1_moyen_paie4=0
replace dig_con1_moyen_paie4=-0.5 if ustrregexm(dig_moyen_paie, "4") 

gen dig_con1_moyen_paie5=0
replace dig_con1_moyen_paie5=-1 if ustrregexm(dig_moyen_paie, "5") 
																  
gen dig_con1_moyen_paie6=0
replace dig_con1_moyen_paie6=-1 if ustrregexm(dig_moyen_paie, "-999")

gen dig_con1_el = dig_con1_moyen_paie1 + dig_con1_moyen_paie3 + dig_con1_moyen_paie2 + dig_con1_moyen_paie4 + dig_con1_moyen_paie5 + dig_con1_moyen_paie6
lab var dig_con1_el "Correct answers to knowledge question on means of payment" 

drop dig_moyen_paie

gen dig_con2_contenu1 = 0 														  
replace dig_con2_contenu1=0.5 if ustrregexm(dig_contenu, "1")

gen dig_con2_contenu2 = 0															  
replace dig_con2_contenu2=-0.5 if ustrregexm(dig_contenu, "2")

gen dig_con2_contenu3 = 0														  
replace dig_con2_contenu3=0.5 if ustrregexm(dig_contenu, "3")

gen dig_con2_contenu4 = 0															  
replace dig_con2_contenu4=-0.5 if ustrregexm(dig_contenu, "4")

gen dig_con2_contenu5 = 0															  
replace dig_con2_contenu5=-1 if ustrregexm(dig_contenu, "-999")

gen dig_con2_el = dig_con2_contenu1 + dig_con2_contenu3 +dig_con2_contenu2 +dig_con2_contenu4 +dig_con2_contenu5
lab var dig_con2_el "Correct answers to knowledge question on digital content" 

drop dig_contenu

gen dig_con3_google_analytics1 = 0
replace dig_con3_google_analytics1= 0.5 if ustrregexm(dig_google_analytics, "1")

gen dig_con3_google_analytics2 = 0
replace dig_con3_google_analytics2= -0.5 if ustrregexm(dig_google_analytics, "2")

gen dig_con3_google_analytics3 = 0
replace dig_con3_google_analytics3= 0.5 if ustrregexm(dig_google_analytics, "3")

gen dig_con3_google_analytics4 = 0
replace dig_con3_google_analytics4= -0.5 if ustrregexm(dig_google_analytics, "4")

gen dig_con3_google_analytics5 = 0
replace dig_con3_google_analytics5=-1 if ustrregexm(dig_google_analytics, "-999")

gen dig_con3_el = dig_con3_google_analytics1 + dig_con3_google_analytics2 + dig_con3_google_analytics3 + dig_con3_google_analytics4 + dig_con3_google_analytics5
lab var dig_con3_el "Correct answers to knowledge question on google analytics" 

drop dig_google_analytics

gen dig_con4_taux_eng1 = 0
replace dig_con4_taux_eng1=0.33 if ustrregexm(dig_taux_eng, "1")

gen dig_con4_taux_eng2 = 0
replace dig_con4_taux_eng2=0.33 if ustrregexm(dig_taux_eng, "2")

gen dig_con4_taux_eng3 = 0
replace dig_con4_taux_eng3=0.33 if ustrregexm(dig_taux_eng, "3")

gen dig_con4_taux_eng4 = 0
replace dig_con4_taux_eng4=-1 if ustrregexm(dig_taux_eng, "4")

gen dig_con4_taux_eng5 = 0
replace dig_con4_taux_eng5=-1 if ustrregexm(dig_taux_eng, "-999")

gen dig_con4_el = dig_con4_taux_eng1 + dig_con4_taux_eng2 + dig_con4_taux_eng3+ dig_con4_taux_eng4 + dig_con4_taux_eng5
lab var dig_con4_el "Correct answers to knowledge question on engagement rate" 

replace dig_con4_el=0 if dig_con4_el> 0 & dig_con4_el< 0.1
drop dig_taux_eng

gen dig_con5_techniques_seo1 = 0
replace dig_con5_techniques_seo1=0.5 if ustrregexm(dig_techniques_seo, "1")

gen dig_con5_techniques_seo2 = 0
replace dig_con5_techniques_seo2=0.5 if ustrregexm(dig_techniques_seo, "2")

gen dig_con5_techniques_seo3 = 0
replace dig_con5_techniques_seo3=-0.5 if ustrregexm(dig_techniques_seo, "3")

gen dig_con5_techniques_seo4 = 0
replace dig_con5_techniques_seo4=-0.5 if ustrregexm(dig_techniques_seo, "4")

gen dig_con5_techniques_seo5 = 0
replace dig_con5_techniques_seo5=-1 if ustrregexm(dig_techniques_seo, "-999")

gen dig_con5_el = dig_con5_techniques_seo1 + dig_con5_techniques_seo2 + dig_con5_techniques_seo3 + dig_con5_techniques_seo4+ dig_con5_techniques_seo5
lab var dig_con5_el "Correct answers to knowledge question on SEO" 

drop dig_techniques_seo

***********************************************************************
* 	PART 2:  Generate variables for companies who answered on phone	
***********************************************************************
gen survey_phone = 0
lab var survey_phone "Comapnies who answered the survey on phone (with enumerators)" 
*replace survey_phone = 1 if id_plateforme == 95
label define Surveytype 1 "Phone" 0 "En ligne"

***********************************************************************
* 	PART 3:  Drop useless variables		
***********************************************************************

***********************************************************************
* 	PART 4:  Change format type	
***********************************************************************
recast float dig_con4_el
format %9.0g dig_con4_el

***********************************************************************
* 	PART 5:  Create variable required for coherence test	
***********************************************************************
gen dig_presence_score= dig_presence1+dig_presence2+dig_presence3 
lab var dig_presence_score "Digital presence score" 

gen dig_descritpion= dig_description1 + dig_description2 + dig_description3
lab var dig_descritpion "Digital description score" 

gen dig_miseajour= dig_miseajour1 + dig_miseajour2 + dig_miseajour3
lab var dig_miseajour "Digital mise à jour score" 

gen dig_payment = dig_payment1 + dig_payment2 + dig_payment3
lab var dig_payment "Digital payment score" 

gen dig_perception = dig_perception1 + dig_perception2 + dig_perception3 + dig_perception4 + dig_perception5
lab var dig_perception "Digital perception score" 

**********************************************************************
* 	PART 6:  save			
***********************************************************************
rename *, lower
save "${el_final}/el_final", replace
