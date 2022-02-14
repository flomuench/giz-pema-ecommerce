***********************************************************************
* 			E-commerce field experiment:  stratification								  		  
***********************************************************************
*																	   
*	PURPOSE: Stratify firms that responded to baseline survey; select stratification approach						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)		
*	2)		gen stratification dummy alternatives
*	3)		visualise number of observations per strata														  
*
*																 																      *
*	Author:  	Teo Firpo													  
*	ID variable: 	id_plateforme			  									  
*	Requires:		bl_final.dta
*	Creates:		
*																	  
***********************************************************************
* 	PART I:  	define the settings as necessary 			     	  *
***********************************************************************

	* import data
use "${bl_final}/bl_final", clear

	* change directory to visualisations
cd "$bl_output/stratification"

	* begin word file to export strata visualisations
	
putdocx clear	
putdocx begin
putdocx paragraph
putdocx text ("Stratification options"), bold

***********************************************************************
* 	PART 1: visualisation of candidate strata variables				  										  
***********************************************************************

	* Firm size (FTE)

sum fte, d
display "Sample firms have min. `r(min)', max. `r(max)' & median `r(p50)' employees."
putdocx paragraph
putdocx text ("Sample full time equivalent employees descriptive statistics"), linebreak bold
putdocx text ("Sample firms have min. `r(min)', max. `r(max)' & median `r(p50)' employees."), linebreak
mdesc fte
display "We miss employee information for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx text ("We miss employee information for `r(miss)' (`r(percent)'%) out of `r(total)'.")	
			*  plot full sample fte distribution
histogram fte, frequency ///
	title("Sample firm employees") ///
	addl
	
graph export fte_histogram.png, replace
	putdocx paragraph, halign(center)
	putdocx image fte_histogram.png, width(4)

	
	* Indices
	
	* Digital knowledge index
	
putdocx paragraph, halign(center) 
putdocx text ("Knowledge of digitalisation index")

hist knowledge, ///
	title("Zscores of knowledge of digitalisation scores") ///
	xtitle("Zscores")
graph export knowledge_zscores.png, replace
putdocx paragraph, halign(center) 
putdocx image knowledge_zscores.png
	
hist raw_knowledge, ///
	title("Raw sum of all knowledge scores") ///
	xtitle("Sum")
graph export raw_knowledge.png, replace
putdocx paragraph, halign(center) 
putdocx image raw_knowledge.png
putdocx pagebreak

sum raw_knowledge, d
display "Raw digitalisation knowledge index has bottom 10 percentile at `r(p10)', median at `r(p50)' & top 90 percentile `r(p90)' ."
putdocx paragraph
putdocx text ("Raw digitalisation knowledge index statistics"), linebreak bold
putdocx text ("Firms have min. `r(min)', max. `r(max)' & median `r(p50)' in this index."), linebreak
putdocx pagebreak


	* Digital Z-scores
	
hist digtalvars, ///
	title("Zscores of digital scores") ///
	xtitle("Zscores")
graph export digital_zscores.png, replace
putdocx paragraph, halign(center) 
putdocx image digital_zscores.png
putdocx pagebreak

	* For comparison, the 'raw' index: 
	
hist raw_digtalvars, ///
	title("Raw sum of all digital scores") ///
	xtitle("Sum")
graph export raw_digital.png, replace
putdocx paragraph, halign(center) 
putdocx image raw_digital.png
putdocx pagebreak

sum raw_knowledge, d
display "Raw digitalisation index has bottom 10 percentile at `r(p10)', median at `r(p50)' & top 90 percentile `r(p90)' ."
putdocx paragraph
putdocx text ("Raw digitalisation index statistics"), linebreak bold
putdocx text ("Firms have min. `r(min)', max. `r(max)' & median `r(p50)' in this index."), linebreak
putdocx pagebreak


	* Export outcomes Z-scores
	
hist expoutcomes, ///
	title("Zscores of export outcomes questions") ///
	xtitle("Zscores")
graph export expoutcomes_zscores.png, replace
putdocx paragraph, halign(center) 
putdocx image expoutcomes_zscores.png
putdocx pagebreak

	* For comparison, the 'raw' index:
	
hist raw_expoutcomes, ///
	title("Raw sum of all export outcomes questions") ///
	xtitle("Sum")
graph export raw_expoutcomes.png, replace
putdocx paragraph, halign(center) 
putdocx image raw_expoutcomes.png
putdocx pagebreak

sum raw_knowledge, d
display "Raw export outcomes index has bottom 10 percentile at `r(p10)', median at `r(p50)' & top 90 percentile `r(p90)' ."
putdocx paragraph
putdocx text ("Raw export outcomes index statistics"), linebreak bold
putdocx text ("Firms have min. `r(min)', max. `r(max)' & median `r(p50)' in this index."), linebreak
putdocx pagebreak



***********************************************************************
* 	PART 2: Create strata
***********************************************************************


***********************************************************************
* 	PART 3: Calculate variance by stratification approach
***********************************************************************


	* First, calculate SD for three main outcomes zscores overall: 
	
	
	*** KNOWLEDGE DIGITALISATION INDEX: 
	
sum knowledge, d
display "For firms in our sample, this index has a standard deviation of `r(sd)"
putdocx paragraph
putdocx text ("Digitalisation knowledge index"), linebreak bold
putdocx text ("For firms in our sample, this index has a standard deviation of `r(sd)'."), linebreak

	* Calculate missing values
*Definition of all variables that are being used in index calculation*
local knowledge_qs dig_con1 dig_con2 dig_con3 dig_con4 dig_con5 dig_con6_score 

foreach var of local  knowledge_qs {
	g missing_knowledge = 1
	replace missing_knowledge = 0 if `var' == .
	replace missing_knowledge = 0 if `var' == -999
	replace missing_knowledge = 0 if `var' == -888
	replace missing_knowledge = 0 if `var' == -777
	replace missing_knowledge = 0 if `var' == -1998
	replace missing_knowledge = 0 if `var' == -1776 
	replace missing_knowledge = 0 if `var' == -1554
}

mdesc missing_knowledge
display "We miss some information on these variables for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx text ("We miss some information on these variables for `r(miss)' (`r(percent)'%) out of `r(total)'.")	

	*** E-COMMERCE INDEX: 

sum digtalvars, d
display "For firms in our sample, this index has a standard deviation of `r(sd)'"
putdocx paragraph
putdocx text ("E-Commerce adoption index"), linebreak bold
putdocx text ("For firms in our sample, this index has a standard deviation of `r(sd)'."), linebreak

	* Calculate missing values
*Definition of all variables that are being used in index calculation*
local ecommerceadoption_qs  dig_presence_score  dig_miseajour1  dig_miseajour2  dig_miseajour3  dig_payment1  dig_payment2  dig_payment3  dig_vente  dig_marketing_lien  dig_marketing_ind1  dig_marketing_ind2  dig_marketing_score  dig_logistique_entrepot t_dig_logistique_retour_score  dig_service_satisfaction  dig_description1  dig_description2  dig_description3  dig_mar_res_per  dig_ser_res_per

foreach var of local  ecommerceadoption_qs {
	g missing_ecommerceadopt = 1
	replace missing_ecommerceadopt = 0 if `var' == .
	replace missing_ecommerceadopt = 0 if `var' == -999
	replace missing_ecommerceadopt = 0 if `var' == -888
	replace missing_ecommerceadopt = 0 if `var' == -777
	replace missing_ecommerceadopt = 0 if `var' == -1998
	replace missing_ecommerceadopt = 0 if `var' == -1776 
	replace missing_ecommerceadopt = 0 if `var' == -1554
}

mdesc missing_ecommerceadopt
display "We miss some information on these variables for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx text ("We miss some information on these variables for `r(miss)' (`r(percent)'%) out of `r(total)'.")	

	*** EXPORT OUTCOMES INDEX: 

sum digtalvars, d
display "For firms in our sample, this index has a standard deviation of `r(sd)'."
putdocx paragraph
putdocx text ("E-Commerce adoption index"), linebreak bold
putdocx text ("For firms in our sample, this index has a standard deviation of `r(sd)'."), linebreak

	* Calculate missing values
*Definition of all variables that are being used in index calculation*
local export_score  exp_pays_all exp_per 

foreach var of local  export_score {
	g missing_export = 1
	replace missing_export = 0 if `var' == .
	replace missing_export = 0 if `var' == -999
	replace missing_export = 0 if `var' == -888
	replace missing_export = 0 if `var' == -777
	replace missing_export = 0 if `var' == -1998
	replace missing_export = 0 if `var' == -1776 
	replace missing_export = 0 if `var' == -1554
}

mdesc missing_export
display "We miss some information on these variables for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx text ("We miss some information on these variables for `r(miss)' (`r(percent)'%) out of `r(total)'.")	
putdocx pagebreak











