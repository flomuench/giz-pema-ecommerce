***********************************************************************
* 			email experiment - visualisations								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)														  
*	2)	
*	3)	 
*	4) 	
*																 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_final.dta & regis_corrected_matches 
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data + save it in samp_final folder				  										  *
***********************************************************************
use "${samp_final}/email_experiment", clear

	* set folder export location
cd "$samp_descriptive"

***********************************************************************
* 	PART 1: registration by treatment status & initial gender
***********************************************************************
graph bar (sum) registered, over(gender) blabel(bar)

graph bar (percent) if sample < 3, over(gender) ///
	blabel(bar, format(%9.2fc) gap(.5)) ///
	title("{it:Initial population for emailing}") ///
	name(gender_initial_sample, replace)
graph bar (percent) if registered == 1, over(gender) ///
	blabel(bar, format(%9.2fc) gap(.5)) ///
	title("{it:Sample of registered firms}") ///
	name(gender_registered, replace)
gr combine gender_initial_sample gender_registered, ///
	title("{bf:Firms by gender: population vs. sample}")
gr export gender_population_sample.png, replace


graph bar (percent) if registered == 1, over(treatment, lab(labsize(vsmall))) over(gender) ///
	blabel(bar, format(%9.2fc) gap(.5)) ///
	title("{it:Registered firms by gender & treatment status}") ///
	name(gender_registered_treatment, replace)



graph bar (sum) registered, over(treatment) blabel(bar)
graph bar (sum) registered, over(treatment, lab(labsize(vsmall))) over(gender) blabel(bar)


***********************************************************************
* 	PART 1: registrations per sector
***********************************************************************
graph hbar (sum) registered, over(sector, lab(labsize(vsmall))) blabel(bar) 
