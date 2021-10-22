***********************************************************************
* 			sampling email experiment correct								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)	search for duplicates based on email & firmname														  
*	2)
*	3)																  
*																	 																      *
*	Author:  Florian												  
*	ID variable: 				  									  
*	Requires:			´
*	Creates:														  
*																	  
***********************************************************************
* 	PART START: import the data				  										  *
***********************************************************************
use "${samp_intermediate}/giz_contact_list_inter", clear




***********************************************************************
* 	PART 1: correct observation values			  										  
***********************************************************************
replace sector = "" if sector == "N.C"


***********************************************************************
* 	PART 2: destring numerical variables imported as string		  										  
***********************************************************************
destring fte, replace
format fte %-9.0fc

***********************************************************************
* 	PART 3: search for duplicates		  										  
***********************************************************************
	* firm-email same
duplicates tag firmname email, gen(dup_fname_email)
*browse if dup_fname_email > 0 /* suggest no firm-email duplicates */
	
	* firmname
duplicates list firmname
duplicates tag firmname, gen(dupfirmname)
codebook firmname /* 598 firm names are missing */
sort firmname
*browse if dupfirmname > 0 & firmname != "" /* 121 firms with several email adresses */



	* email
	
	* combinations
		* name-town


***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
save "giz_contact_list_inter", replace

