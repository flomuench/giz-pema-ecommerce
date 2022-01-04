***********************************************************************
* 			regisling email experiment import						
***********************************************************************
*																	   
*	PURPOSE: import the GIZ-API contact list as prepared					  								  
*	by Teo			  
*																	  
*	OUTLINE:														  
*	1)	import contact list as Excel or CSV														  
*	2)	save the contact list as dta file in intermediate folder
*																	 																      *
*	Author: Florian  														  
*	ID variable: no id variable defined			  									  
*	Requires:	
*	Creates:							  
*																	  
***********************************************************************
* 	PART 1: import the list of registered firms as Excel				  										  *
***********************************************************************
cd "$regis_raw"
import excel "${regis_raw}/regis_raw.xlsx", firstrow clear


***********************************************************************
* 	PART 2: save list of registered firms in registration raw 			  						
***********************************************************************
save "regis_raw", replace
