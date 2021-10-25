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

	* drop obs with unknown gender
drop if gender == "unknown"


***********************************************************************
* 	PART 2: destring numerical variables imported as string		  										  
***********************************************************************
destring fte, replace
format fte %-9.0fc

***********************************************************************
* 	PART 3: search & remove duplicates		  										  
***********************************************************************
	* firm-email same
duplicates tag firmname email, gen(dup_fname_email)
*browse if dup_fname_email > 0 /* suggest no firm-email duplicates */

	* email
duplicates list email /* suggests 0 observations are duplicates */
	
	* firmname
duplicates list firmname
duplicates tag firmname, gen(dupfirmname)
codebook firmname /* 598 firm names are missing */
sort firmname, stable
*browse if dupfirmname > 0 & firmname != "" /* 121 firms with several email adresses */
sort firmname origin, stable 
		/* duplicates come either from
		1: same firm in pema & api contact list
			Ex: alpha etiquettes, berg life sciences, bioservice tunisie, cerealis etc.
		2: several contacts for the same firm within the pema contact list
			Ex: medianet
		
		Decision: remove pema 
		*/
duplicates drop firmname, force		/* corresponds to 658 contacts */
*browse if dupfirmname > 0 & firmname != "" /* only one ober per firm */
duplicates list firmname


***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
save "giz_contact_list_inter", replace

