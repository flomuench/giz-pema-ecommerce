***********************************************************************
* 			benefit classifications baseline import						
***********************************************************************
*																	   
*	PURPOSE: import the questionnaire Presence en ligne					  								  
*			  
*																	  
*	OUTLINE:														  
*	1)	import the questionnaire as Excel or CSV	
*	2) 	export raw data as dta											  
*	3)	save the answers as dta file in intermediate folder
*																 																      
*	Author:   			Ayoub Chamakhi										  
*	ID variable: 		id_platforme  									  
*	Requires:			classification_investbenefit.xlsx
*	Creates:			classification_investbenefit_raw	ml_Webpresence_answers_intermediate.dta				
***********************************************************************
* 	PART 1: import the answers from questionnaire as Excel			  *
***********************************************************************

import excel "${bl3_raw}/classification_investbenefit.xlsx", firstrow clear

***********************************************************************
* 	PART 2: export raw data as dta				  					  *
***********************************************************************

save "${bl3_raw}/classification_investbenefit_raw", replace

***********************************************************************
* 	PART 3: merge with baseline data, import treatment for stats	  *
***********************************************************************
merge 1:1 id_plateforme using "${bl_final}/bl_final", keepusing(treatment)
drop _merge
***********************************************************************
* 	PART 4: save the answers as dta file in intermediate folder 			  						
***********************************************************************
save "${bl3_intermediate}/classification_investbenefit_intermediate", replace
