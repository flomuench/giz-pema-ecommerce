***********************************************************************
* 			saving registration fuzzy match									  	  
***********************************************************************
*																	    
*	PURPOSE: match companies registered to those in our experimental sample				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) Load data from manually checked Excel
* 	2) Save
*																						  															      
*	Author:  	Teo Firpo						  
*	ID variable: no id variable defined				  
*	Requires: regis_match_intermediate.xls							  
*	Creates:  regis_matched.dta, regis_done.dta		                          

***********************************************************************
* 	PART 1: Load regis_inter (list of registrations)  			
***********************************************************************

	cd "$regis_intermediate"

	import excel "$regis_intermediate/regis_match_intermediate.xls", sheet("Sheet1") firstrow

	
***********************************************************************
* 	PART 2: Save  			
***********************************************************************

	******************** Save date as it is in the final folder
	
	cd "$regis_final"
	
	save "regis_matched", replace
	
	******************** Save only ids, scores and 'matched on' as regis_done:
	******************** This avoids them being matched again in the next round
	******************** Which means they don't have to be manually cleaned
	
	cd "$regis_intermediate"
	
	keep id_plateforme id_email score matchedon
	
	save "regis_done", replace
