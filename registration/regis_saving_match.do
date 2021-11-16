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

	clear 
	
	import excel "$regis_intermediate/regis_corrected_matches.xls", sheet("Sheet1") firstrow

	
***********************************************************************
* 	PART 2: Save list with corrected matches in the final folder		
***********************************************************************

	******************** Save date as it is in the final folder
	
	cd "$regis_final"
	
	save "regis_matched_contacts", replace
	
