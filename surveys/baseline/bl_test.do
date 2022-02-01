***********************************************************************
* 			e-commerce baseline survey logical tests                  *	
***********************************************************************
*																	    
*	PURPOSE: Check that answers make logical sense			  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Preamble
* 	2) 		Define logical tests
*	2.1) 	Tests for accounting
*	2.1) 	Tests for indices									  															      
*	Author:  	Teo Firpo							  
*	ID variable: 	id_plateforme (example: f101)			  					  
*	Requires: bl_inter.dta 	  								  
*	Creates:  bl_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  Create word file for export		  		
***********************************************************************
	* import file
	
use "${bl_intermediate}/bl_inter", clear


***********************************************************************
* 	PART 2:  Define logical tests
***********************************************************************

/* --------------------------------------------------------------------
	PART 2.1: Comptabilité / accounting questions
----------------------------------------------------------------------*/		

* If 'benefices' is larger than 'chiffres d'affaires' need to check:

replace needs_check = 1 if comp_benefice2020>comp_ca2020
replace questions_needing_checks = questions_needing_checks + "Benefices sont plus élevés que comptes d'affaires'" if comp_benefice2020>comp_ca2020

* Check if export values, or online revenues, are larger than total revenues 

replace needs_check = 1 if   comp_ca2020< compexp_2020
replace questions_needing_checks = questions_needing_checks +  "Export sont plus élevés que comptes d'affaires" if   comp_ca2020< compexp_2020

* Check if online revenu is higher than overall revenue

replace needs_check = 1 if  comp_ca2020 < dig_revenues_ecom
replace questions_needing_checks = questions_needing_checks +  "Revenues en ligne sont plus élevés que comptes d'affaires" if  comp_ca2020 < dig_revenues_ecom


/* --------------------------------------------------------------------
	PART 2.2: Indices / questions with points
----------------------------------------------------------------------*/		
replace needs_check = 1 if dig_presence_score>1
replace questions_needing_checks = questions_needing_checks +  "Index wrong dig_presence_score" if dig_presence_score>1

replace needs_check = 1 if dig_presence_score<0
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_presence_score" if dig_presence_score<0 

replace needs_check = 1 if dig_miseajour1>1 | dig_miseajour2>1 |  dig_miseajour3>1 
replace needs_check = 1 if dig_miseajour1<0 | dig_miseajour2<0 |  dig_miseajour3<0
replace questions_needing_checks = questions_needing_checks +  "Index wrong dig_miseajour1" if dig_miseajour1<0 | dig_miseajour2<0 |  dig_miseajour3<0
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_miseajour1" if dig_miseajour1>1 | dig_miseajour2>1 |  dig_miseajour3>1 

replace needs_check = 1 if dig_payment1>1 | dig_payment2>1 | dig_payment3>1 
replace needs_check = 1 if dig_payment1<0 | dig_payment2<0 | dig_payment3<0 | 
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_payment1" if dig_payment1>1 | dig_payment2>1 | dig_payment3>1 
replace questions_needing_checks = questions_needing_checks +  "Index wrong dig_payment1" if dig_payment1<0 | dig_payment2<0 | dig_payment3<0 | 

replace needs_check = 1 if dig_vente>1  
replace needs_check = 1 if dig<0 & dig_presence_score>-999
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_vente" if dig_vente>1  
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_vente" if dig_vente<0 & dig_presence_score>-999

replace needs_check = 1 if dig_marketing_lien>1 
replace needs_check = 1 if dig_marketing_lien<0 & dig_presence_score>-999
replace questions_needing_checks = questions_needing_checks +  "Index wrong dig_marketing_lien" if dig_marketing_lien>1  
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_marketing_lien" if dig_marketing_lien<0 & dig_presence_score>-999

replace needs_check = 1 if dig_marketing_score>1 | dig_marketing_score<0
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_marketing_score" if dig_marketing_score>1 | dig_marketing_score<0

replace needs_check = 1 if dig_marketing_ind1>1 
replace needs_check = 1 if dig_marketing_ind1<0 & dig_marketing_ind1>-999
replace questions_needing_checks = questions_needing_checks +  "Index wrong dig_marketing_ind1" if dig_marketing_ind1>1  
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_marketing_ind1" if dig_marketing_ind1<0 & dig_marketing_ind1>-999

replace needs_check = 1 if dig_marketing_ind2>1 
replace needs_check = 1 if dig_marketing_ind2<0 & dig_marketing_ind2>-999
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_marketing_ind2" if dig_marketing_ind2>1  
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_marketing_ind2" if dig_marketing_ind2<0 & dig_marketing_ind2>-999

replace needs_check = 1 if dig_marketing_respons<0 
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_marketing_respons" if dig_marketing_respons<0

replace needs_check = 1 if dig_logistique_entrepot<0 & dig_logistique_entrepot>-999
replace needs_check = 1 if dig_logistique_entrepot>1
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_logistique_entrepot" if dig_logistique_entrepot<0 & dig_logistique_entrepot>-999
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_logistique_entrepot" if dig_logistique_entrepot>1

replace needs_check = 1 if dig_logistique_retour_score<0
replace needs_check = 1 if dig_logistique_retour_score>1  
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_logistique_retour_score" if dig_logistique_retour_score>1
replace questions_needing_checks = questions_needing_checks +  "Index wrong dig_logistique_retour_score" if dig_logistique_retour_score<0

replace needs_check = 1 if dig_service_responsable<0
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_service_responsable" if dig_service_responsable<0


replace needs_check = 1 if  dig_service_satisfaction<0 &  dig_service_satisfaction>-999
replace needs_check = 1 if  dig_service_satisfaction>1  
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_service_satisfaction" if  dig_service_satisfaction<0 &  dig_service_satisfaction>-999
replace questions_needing_checks =  questions_needing_checks + "Index wrong dig_service_satisfaction" if  dig_service_satisfaction>1  

replace needs_check = 1 if expprep_cible<0
replace needs_check = 1 if expprep_cible>1  
replace questions_needing_checks =  questions_needing_checks + "Index wrong expprep_cible" if expprep_cible<0
replace questions_needing_checks =  questions_needing_checks + "Index wrong expprep_cible" if expprep_cible>1

replace needs_check = 1 if expprep_responsable<0  
replace questions_needing_checks =  questions_needing_checks + "Index wrong expprep_responsable" if expprep_responsable<0


replace needs_check = 1 if expprep_norme<0 & expprep_norme>-999
replace needs_check = 1 if expprep_norme>1  
replace questions_needing_checks =  questions_needing_checks + "Index wrong expprep_norme" if expprep_norme<0 & expprep_norme>-999
replace questions_needing_checks =  questions_needing_checks + "Index wrong expprep_norme" if expprep_norme>1  

replace needs_check = 1 if rg_oper_exp<0 & rg_oper_exp>-999
replace needs_check = 1 if rg_oper_exp>1  
replace questions_needing_checks =  questions_needing_checks + "Index wrong rg_oper_exp" if rg_oper_exp<0 & rg_oper_exp>-999
replace questions_needing_checks =  questions_needing_checks + "Index wrong rg_oper_exp" if rg_oper_exp>1  

replace needs_check = 1 if exp_pays_avant21<0 & exp_pays_avant21!=-999
replace questions_needing_checks =  questions_needing_checks + "Index wrong exp_pays_avant21" if exp_pays_avant21<0 & exp_pays_avant21!=-999 

replace needs_check = 1 if exp_pays_21<0 & exp_pays_21!=-999
replace questions_needing_checks = questions_needing_checks +  "Index wrong exp_pays_21" if if exp_pays_21<0 & exp_pays_21!=-999

replace needs_check = 1 if exp_afrique<0 & exp_afrique!=-999
replace needs_check = 1 if exp_afrique>1  
replace questions_needing_checks =  questions_needing_checks + "Index wrong exp_afrique" if exp_afrique<0 & exp_afrique!=-999
replace questions_needing_checks =  questions_needing_checks + "Index wrong exp_afrique" if exp_afrique>1 



***********************************************************************
* 	End:  save dta, word file		  			
***********************************************************************
	* word file
cd "$bl_checks"

capture export excel id_plateforme needs_check questions_needing_check date-dig_logistique_retour_score using "reponses_illogiques" if needs_check==1, firstrow(variables) replace
