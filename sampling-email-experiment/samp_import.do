***********************************************************************
* 			sampling email experiment import						
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
*	Requires:	giz_contact_list.xlsx or .csv
*	Creates:	giz_contact_list.dta						  
*																	  
***********************************************************************
* 	PART 1: import the giz contact list as Excel or csv				  										  *
***********************************************************************
* import giz-api contact list cleaned and merged by Teo
	* as Excel
import excel "${samp_intermediate}/giz_contact_list.xlsx", firstrow clear

	* as csv
*import delimited "${samp_final}/giz_contact_list.csv", varn(1) clear


***********************************************************************
* 	PART 2: save the contact list as dta file in intermediate folder			  						
***********************************************************************
* or save intermediate
cd "$samp_intermediate"
save "giz_contact_list_inter", replace
