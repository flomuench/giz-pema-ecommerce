* 	email experiment - merge population with baseline survey response							  		  
***********************************************************************
*																	   
*	PURPOSE: retrieve gender of CEO at least for registered firms					  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)	 merge firms in email_experiment (initial population) with bl responses 
* 	of firms registered thanks to the email (177)													  
*																 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_final.dta & regis_corrected_matches 
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data + save it in samp_final folder				  										  *
***********************************************************************
	* set the directory to baseline folder
cd "$bl_final"

	* load email experiment data
use "${samp_final}/email_experiment", clear
drop _merge
	
	*
sort id_plateforme 
forvalues x = 373(1)5043 { 
	replace id_plateforme = -`x' in `x'
}

	* merge email experimemt with baseline data
merge 1:1 id_plateforme using bl_final

	* check results

	* change directory back to email experiment/sampling folder
		* save updated, merged data set
cd "$samp_final"
save "email_experiment", replace
