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
*	Requires: bl_inter.dta 	  								  
*	Creates:  bl_inter.dta			                          
*	
																  
***********************************************************************
* 	PART 1:  Generate summary variables of multiple answer questions 			
***********************************************************************
local multi_vars dig_marketing_num110 dig_moyen_paie
gen dig_marketing_num1=0
replace dig_marketing_num1=1 if ustrregexm(dig_marketing_num110, "dig_marketing_num1") 
