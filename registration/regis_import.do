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
* 	PART 1: import the giz contact list as Excel or csv				  										  *
***********************************************************************
* import giz-api contact list cleaned and merged by Teo
	* as Excel
cd "$regis_raw"
forvalues i = 1(1)2 {
import excel "${regis_raw}/fake_training_registration_list`i'.xlsx", firstrow clear
save "fake_training_registration_list`i'", replace
}

***********************************************************************
* 	PART 2: Try out the different matching algorithms: RECLINK + RECLINK2
***********************************************************************
* check whether you installed reclink & reclink2

	* reclink
	
	* reclink2

***********************************************************************
* 	PART 3: Try out the different matching algorithms: Matchit
***********************************************************************
* check whether you installed matchit


***********************************************************************
* 	PART 4: Try out the different matching algorithms: strgroup
***********************************************************************
* check whether you install strgroup



/*

***********************************************************************
* 	PART 2: save the contact list as dta file in intermediate folder			  						
***********************************************************************
* or save intermediate
cd "$regis_intermediate"
save "giz_contact_list_inter", replace
