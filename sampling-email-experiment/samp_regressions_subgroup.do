***********************************************************************
* 			email experiment - regressions - main effect								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)	 import corrected matches and save as dta in sampling folder													  
*	2)	 merge with initial population based on id_email
*	3)	 merge with registration data to get controls for registered firms
*	4) 	 save as email_experiment.dta in final folder
*																 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_final.dta & regis_corrected_matches 
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data + save it in samp_final folder				  										  *
***********************************************************************
use "${samp_final}/email_experiment", clear

	* set folder path for export
cd "$samp_regressions"


***********************************************************************
* 	PART 1: how the firms attracted by control, childcare and video differ?
***********************************************************************
	* continuous variables
cd "$final_tables"
winsor2 rg_fte, cuts(0 99)
rename rg_fte_w w_rg_fte
local variables1 w_rg_fte female_share rg_gender_pdg rg_gender_rep presence_enligne rg_age 
local variables2 rg_capital rg_resident rg_produitexp rg_oper_exp rg_intention
local variables3 w_compca w_compbe w_compexp w_compdrev
			
			* as Excel
iebaltab `variables1' `variables2' `variables3' if inrange(rg_capital,0,10000000) & inrange(rg_age, 0, 100) & inrange(rg_fte, 0, 250), ///
		grpvar(treatment) save(post_ecommerce_differences) replace ///
		vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
		format(%12.2fc)
			 
			* as tex
iebaltab `variables1' `variables2' `variables3' if inrange(rg_capital,0,10000000) & inrange(rg_age, 0, 100) & inrange(rg_fte, 0, 250), ///
		grpvar(treatment) savetex(post_ecommerce_differences) replace ///
		vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
		format(%12.2fc)
		 
	* categorical variables
		* district
		
		
		* sector
		
		
		* origin
		
		


***********************************************************************
* 	PART 2: sub-group analysis by firm size
***********************************************************************
