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
use "${ml_intermediate}/ml_intermediate", clear																  

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
 
gen dig_marketing_num19_socm_pay=0
replace dig_marketing_num19_socm_pay=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num8") 
 
gen dig_marketing_num19_autre=0
replace dig_marketing_num19_autre=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_autre") 
 
gen dig_marketing_num19_aucu=0
replace dig_marketing_num19_aucu=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num19_aucu")

gen dig_marketing_num19_nsp=0
replace dig_marketing_num19_nsp=1 if ustrregexm(dig_marketing_num110, "-999")

foreach var of varlist dig_marketing_num19_sea dig_marketing_num19_seo dig_marketing_num19_blg dig_marketing_num19_pub dig_marketing_num19_mail dig_marketing_num19_prtn dig_marketing_num19_socm dig_marketing_num19_socm_pay dig_marketing_num19_autre dig_marketing_num19_aucu dig_marketing_num19_nsp{
replace `var' =. if dig_marketing_num110=="" 
}

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

gen dig_con1_ml = dig_con1_moyen_paie1 + dig_con1_moyen_paie3 + dig_con1_moyen_paie2 + dig_con1_moyen_paie4 + dig_con1_moyen_paie5 + dig_con1_moyen_paie6
lab var dig_con1_ml "Correct answers to knowledge question on means of payment" 

foreach var of varlist dig_con1_moyen_paie1 dig_con1_moyen_paie2 dig_con1_moyen_paie3 dig_con1_moyen_paie4 dig_con1_moyen_paie5 dig_con1_moyen_paie6 {
replace `var' =. if dig_moyen_paie=="" 
}
 
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

gen dig_con2_ml = dig_con2_contenu1 + dig_con2_contenu3 +dig_con2_contenu2 +dig_con2_contenu4 +dig_con2_contenu5
lab var dig_con2_ml "Correct answers to knowledge question on digital content" 

foreach var of varlist dig_con2_contenu1 dig_con2_contenu2 dig_con2_contenu3 dig_con2_contenu4 dig_con2_contenu5 {
replace `var' =. if dig_contenu=="" 
}

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

gen dig_con3_ml = dig_con3_google_analytics1 + dig_con3_google_analytics2 + dig_con3_google_analytics3 + dig_con3_google_analytics4 + dig_con3_google_analytics5
lab var dig_con3_ml "Correct answers to knowledge question on google analytics" 

foreach var of varlist dig_con3_google_analytics1 dig_con3_google_analytics2 dig_con3_google_analytics3 dig_con3_google_analytics4 dig_con3_google_analytics5 {
replace `var' =. if dig_google_analytics=="" 
}

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

gen dig_con4_ml = dig_con4_taux_eng1 + dig_con4_taux_eng2 + dig_con4_taux_eng3+ dig_con4_taux_eng4 + dig_con4_taux_eng5
lab var dig_con4_ml "Correct answers to knowledge question on engagement rate" 

replace dig_con4_ml=0 if dig_con4_ml> 0 & dig_con4_ml< 0.1

foreach var of varlist dig_con4_taux_eng1 dig_con4_taux_eng2 dig_con4_taux_eng3 dig_con4_taux_eng4 dig_con4_taux_eng5 {
replace `var' =. if dig_taux_eng=="" 
}

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

gen dig_con5_ml = dig_con5_techniques_seo1 + dig_con5_techniques_seo2 + dig_con5_techniques_seo3 + dig_con5_techniques_seo4+ dig_con5_techniques_seo5
lab var dig_con5_ml "Correct answers to knowledge question on SEO" 

foreach var of varlist dig_con5_techniques_seo1 dig_con5_techniques_seo2 dig_con5_techniques_seo3 dig_con5_techniques_seo4 dig_con5_techniques_seo5 {
replace `var' =. if dig_techniques_seo=="" 
}
drop dig_techniques_seo

***********************************************************************
* 	PART 3:  Generate variables for companies who answered on phone	
***********************************************************************
gen survey_phone = 0
lab var survey_phone "Comapnies who answered the survey on phone (with enumerators)" 
replace survey_phone = 1 if id_plateforme == 95
replace survey_phone = 1 if id_plateforme == 126
replace survey_phone = 1 if id_plateforme == 136
replace survey_phone = 1 if id_plateforme == 172
replace survey_phone = 1 if id_plateforme == 231
replace survey_phone = 1 if id_plateforme == 270
replace survey_phone = 1 if id_plateforme == 337
replace survey_phone = 1 if id_plateforme == 424
replace survey_phone = 1 if id_plateforme == 438
replace survey_phone = 1 if id_plateforme == 519
replace survey_phone = 1 if id_plateforme == 527
replace survey_phone = 1 if id_plateforme == 541
replace survey_phone = 1 if id_plateforme == 644
replace survey_phone = 1 if id_plateforme == 670
replace survey_phone = 1 if id_plateforme == 729
replace survey_phone = 1 if id_plateforme == 732
replace survey_phone = 1 if id_plateforme == 962
replace survey_phone = 1 if id_plateforme == 360
replace survey_phone = 1 if id_plateforme == 365
replace survey_phone = 1 if id_plateforme == 427
replace survey_phone = 1 if id_plateforme == 635
replace survey_phone = 1 if id_plateforme == 767
replace survey_phone = 1 if id_plateforme == 773
replace survey_phone = 1 if id_plateforme == 791
replace survey_phone = 1 if id_plateforme == 810
replace survey_phone = 1 if id_plateforme == 831
replace survey_phone = 1 if id_plateforme == 82
replace survey_phone = 1 if id_plateforme == 244
replace survey_phone = 1 if id_plateforme == 565
replace survey_phone = 1 if id_plateforme == 602
replace survey_phone = 1 if id_plateforme == 941
replace survey_phone = 1 if id_plateforme == 959
replace survey_phone = 1 if id_plateforme == 961
replace survey_phone = 1 if id_plateforme == 587
replace survey_phone = 1 if id_plateforme == 70
replace survey_phone = 1 if id_plateforme == 470
replace survey_phone = 1 if id_plateforme == 478
replace survey_phone = 1 if id_plateforme == 508
replace survey_phone = 1 if id_plateforme == 735
replace survey_phone = 1 if id_plateforme == 91
replace survey_phone = 1 if id_plateforme == 78
replace survey_phone = 1 if id_plateforme == 85
replace survey_phone = 1 if id_plateforme == 938
replace survey_phone = 1 if id_plateforme == 859
replace survey_phone = 1 if id_plateforme == 521
replace survey_phone = 1 if id_plateforme == 466
replace survey_phone = 1 if id_plateforme == 743
replace survey_phone = 1 if id_plateforme == 668
replace survey_phone = 1 if id_plateforme == 679
replace survey_phone = 1 if id_plateforme == 313
replace survey_phone = 1 if id_plateforme == 373
replace survey_phone = 1 if id_plateforme == 956
replace survey_phone = 1 if id_plateforme == 213
replace survey_phone = 1 if id_plateforme == 108
replace survey_phone = 1 if id_plateforme == 144
replace survey_phone = 1 if id_plateforme == 153
replace survey_phone = 1 if id_plateforme == 803
replace survey_phone = 1 if id_plateforme == 394
replace survey_phone = 1 if id_plateforme == 406
replace survey_phone = 1 if id_plateforme == 910
replace survey_phone = 1 if id_plateforme == 311
replace survey_phone = 1 if id_plateforme == 259
replace survey_phone = 1 if id_plateforme == 105
replace survey_phone = 1 if id_plateforme == 58
replace survey_phone = 1 if id_plateforme == 213
replace survey_phone = 1 if id_plateforme == 108
replace survey_phone = 1 if id_plateforme == 153
replace survey_phone = 1 if id_plateforme == 201
replace survey_phone = 1 if id_plateforme == 739
replace survey_phone = 1 if id_plateforme == 628
replace survey_phone = 1 if id_plateforme == 259
replace survey_phone = 1 if id_plateforme == 406
replace survey_phone = 1 if id_plateforme == 742
replace survey_phone = 1 if id_plateforme == 183
replace survey_phone = 1 if id_plateforme == 453
replace survey_phone = 1 if id_plateforme == 495
replace survey_phone = 1 if id_plateforme == 688
replace survey_phone = 1 if id_plateforme == 505
replace survey_phone = 1 if id_plateforme == 511











label define Surveytype 1 "Phone" 0 "En ligne"
***********************************************************************
* 	PART 4:  Drop useless variables		
***********************************************************************
drop id_ident id_ident2 verification attest bj bk bl bm bn bo bp bq br bs bt 
drop bu bv bw bx by bz ca cb cc

***********************************************************************
* 	PART 5:  Change format type	
***********************************************************************
recast float dig_con4_ml
format %9.0g dig_con4_ml

***********************************************************************
* 	PART 6:  Create variable required for coherence test	
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
* 	PART 7:  save			
***********************************************************************
rename *, lower
save "${ml_final}/ml_final", replace
