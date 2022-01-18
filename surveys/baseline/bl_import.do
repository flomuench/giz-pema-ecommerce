***********************************************************************
* 			baseline e-commerce experiment import					  *
***********************************************************************
*																	   
*	PURPOSE: import the baseline survey data provided by the survey 
*   institute
*																	  
*	OUTLINE:														  
*	1)	import contact list as Excel or CSV														  
*	2)	save the contact list as dta file in intermediate folder
*																	 																      *
*	Author: Teo Firpo  														  
*	ID variable: no id variable defined			  									  
*	Requires:	
*	Creates:							  
*																	  
***********************************************************************
* 	PART 1: import the list of registered firms as Excel				  										  *
***********************************************************************
cd "$bl_raw"
import excel "${bl_raw}/bl_raw.xlsx", firstrow clear


***********************************************************************
* 	PART 2: save 						
***********************************************************************
save "bl_raw", replace
