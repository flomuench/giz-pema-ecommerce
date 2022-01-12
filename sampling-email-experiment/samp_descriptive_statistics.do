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
	title("{bf:Registered firms by gender & treatment status}") ///
	subtitle("{it: Gender based on administrative data}") ///
	name(gender_registered_treatment, replace)
gr export gender_registered_by_treatment.png,replace

graph bar (percent) if registered == 1, over(treatment, lab(labsize(vsmall))) over(gender_rep) ///
	blabel(bar, format(%9.2fc) gap(.5)) ///
	title("{bf:Registered firms by gender & treatment status}") ///
	subtitle("{it: Gender based on registration data}") ///
	name(genderrep_registered_treatment, replace)
gr export genderrep_registered_by_treatment.png,replace



graph bar (sum) registered, over(treatment) blabel(bar)
graph bar (sum) registered, over(treatment, lab(labsize(vsmall))) over(gender) blabel(bar)


		* descriptive statistics with estout
bysort treatment gender: eststo: estpost tab registered
esttab, cells("mean sd") csv

			* for registered firms
cd "$samp_regressions"
eststo clear
estpost tab treatment gender if registered == 1
esttab using resultstable.csv, cells("b(lab(n)) pct(fmt(2) lab(% of total)) colpct(fmt(2) lab(% of group))") ///
 nomtitle nonumber noobs replace

			* for unregistered firms
eststo clear
estpost tab treatment gender if registered == 0
esttab using resultstable0.csv, cells("b(lab(n)) pct(fmt(2) lab(% of total)) colpct(fmt(2) lab(% of group))") ///
 nomtitle nonumber noobs replace

			
***********************************************************************
* 	PART 1: bounce rate in the three treatment groups
***********************************************************************



***********************************************************************
* 	PART 1: registrations per sector
***********************************************************************
graph hbar (sum) registered, over(sector, lab(labsize(vsmall))) blabel(bar) 
