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
*	ID variable: id_plateforme			  									  
*	Requires: bl_raw.xlsx	
*	Creates: bl_raw.dta							  
*																	  
***********************************************************************
* 	PART 1: import the list of registered firms as Excel				  										  *
***********************************************************************
cd "$bl_raw"
import excel "${bl_raw}/bl_raw.xlsx", sheet("Feuil1") cellrange (A7:DZ116) firstrow



***********************************************************************
* 	PART 2: save 						
***********************************************************************
save "bl_raw", replace
