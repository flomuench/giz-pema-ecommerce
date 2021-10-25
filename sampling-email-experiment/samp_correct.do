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

	* drop obs with unknown gender (10 obs)
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
*browse if dup_fname_email > 0 /* suggest 1 firm-email dup = "masmoudi" */
duplicates report firmname email
duplicates drop firmname email, force /* 1 obs deleted */

	* email
duplicates list email
duplicates tag email, gen(dup_email)
duplicates report email /* 18 surplus obs (18 contacts with 2 emails) */
sort email origin, stable
duplicates drop email, force /* 18 obs deleted */
duplicates list email 

	* firmname
duplicates list firmname
duplicates report firmname /* surplus 59 with 1 dup,  */
duplicates tag firmname, gen(dupfirmname)
sort firmname origin, stable 
		/* duplicates come either from
		1: same firm in pema & api contact list
			Ex: alpha etiquettes, berg life sciences, bioservice tunisie, cerealis etc.
		2: several contacts for the same firm within the pema contact list
			Ex: medianet
		
		Decision: remove pema 
		*/
drop if dupfirmname < 3 & dupfirmname > 0 /* 121 */
*browse if dupfirmname > 0 & firmname != "" /* only one ober per firm */
duplicates report firmname /* only obs with missing firm name */


***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
save "giz_contact_list_inter", replace

