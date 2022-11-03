***********************************************************************
* 			import do file, admin data										  
***********************************************************************
*																	  
*	PURPOSE: import cepex data
*  
*	OUTLINE: 	PART 1: import the answers from cepex data as Excel	
*               PART 2: save the answers as dta file in intermediate folder 
*																	  
*																	  
*	Author:  		Ayoub Chamakhi				    
*	ID variable: 	Id_plateforme			  					  
*	Requires: export pema.xlsx									  
*	Creates:  cp_intermediate.dta			                                  

***********************************************************************
* 	PART 1: import the answers from cepex data as Excel				  										  *
***********************************************************************

import excel "${cp_raw}/export pema.xlsx", firstrow clear

***********************************************************************
* 	PART 2: save the answers as dta file in intermediate folder 			  						
***********************************************************************

save "${cp_intermediate}/cp_intermediate", replace

