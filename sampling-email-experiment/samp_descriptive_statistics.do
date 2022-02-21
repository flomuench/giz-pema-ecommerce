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
graph bar (sum) registered, over(gender_rep2) blabel(bar)

graph bar (percent) if sample < 3, over(gender_rep2) ///
	blabel(bar, format(%9.2fc) gap(.5)) ///
	title("{it:Initial population for emailing}") ///
	name(gender_initial_sample, replace)
graph bar (percent), over(gender_rep2) ///
	blabel(bar, format(%9.2fc) gap(.5)) ///
	title("{it:Sample of registered firms}") ///
	name(gender_registered, replace)
gr combine gender_initial_sample gender_registered, ///
	title("{bf:Firms by gender: population vs. sample}")
gr export gender_population_sample.png, replace

	* absolute count
graph bar (count) if registered == 1, over(treatment, lab(labsize(vsmall))) over(gender_rep2) ///
	blabel(bar, format(%9.0fc) gap(.5)) ///
	title("{bf:Registered firms by gender & treatment status}") ///
	subtitle("{it: Gender based on baseline, registration & administrative data}") ///
	name(gender_registered_treatment, replace)
gr export gender_registered_by_treatment.png,replace

	* percent relative to group total (example: registered female vs. total female in control)
forvalues x = 0(1)2 {
	graph bar (percent) if treatment == `x', over(registered) ///
		blabel(total, format(%9.2fc)) ///
		name(registered_vs_total`x', replace)
}

gr combine registered_vs_total0 registered_vs_total1 registered_vs_total2, ///
	title("Percentage of firms registered by treatment & CEO gender") ///
	subtitle("Left: control group, Middle: Free Childcare, Left: Influencer video") ///
	r(1)



* share of female representatives among male-managed companies
graph bar (percent) if registered == 1 & gender_rep2 == 0, over(treatment, lab(labsize(vsmall))) over(gender_rep) ///
	blabel(bar, format(%9.2fc) gap(.5)) ///
	title("{bf:Registered, male-managed firms' representatives by gender & treatment status}") ///
	subtitle("{it: Gender based on baseline, registration & administrative data}") ///
	name(gender_rep_male_treatment, replace)
graph bar (percent) if registered == 1 & gender_rep2 == 0, over(treatment, lab(labsize(vsmall))) over(gender_rep) ///
	blabel(bar, format(%9.2fc) gap(.5)) ///
	title("{bf:Registered, male-managed firms' representatives by gender & treatment status}") ///
	subtitle("{it: Gender based on baseline, registration & administrative data}") ///
	name(gender_rep_male_treatment, replace)
gr export gender_rep_male_treatment.png,replace


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
				* based on API gender
cd "$samp_regressions"
eststo clear
estpost tab treatment gender if registered == 1
esttab using resultstable.csv, cells("b(lab(n)) pct(fmt(2) lab(% of total)) colpct(fmt(2) lab(% of group))") ///
 nomtitle nonumber noobs replace
				
				* based on corrected CEO gender (after baseline + registration)
eststo clear
estpost tab treatment gender_rep2 if registered == 1
esttab using resultstable.csv, cells("b(lab(n)) pct(fmt(2) lab(% of total)) colpct(fmt(2) lab(% of group))") ///
 nomtitle nonumber noobs replace

			* for unregistered firms
eststo clear
estpost tab treatment gender if registered == 0
esttab using resultstable0.csv, cells("b(lab(n)) pct(fmt(2) lab(% of total)) colpct(fmt(2) lab(% of group))") ///
 nomtitle nonumber noobs replace

			
***********************************************************************
* 	PART 2: bounce rate in the three treatment groups
***********************************************************************

***********************************************************************
* 	PART 3: importance of different treatments for registration
***********************************************************************
	graph hbar (count), over(perc_video) over(gender_rep2) by(treatment) name(pvideo, replace) ///
		title("{bf:Importance of video for registration decision}") ///
		ylabel(0(1)5) ///
		blabel(total, format(%9.0fc))

	graph hbar (count), over(perc_car) over(gender_rep2) by(treatment) name(pvideo, replace) ///
		title("{bf:Importance of childcare for registration decision}") ///
		ylabel(0(1)5) ///
		blabel(total, format(%9.0fc))
gr combine pvideo pccare

		* among only firms that said yes to have been aware
graph hbar (count) if perc_com1 == 1, over(perc_video) over(gender_rep2) name(pvideo, replace) ///
	title("{bf:Video}") ///
	ylabel(0(1)15) ///
	blabel(total)
graph hbar (count) if perc_com2 == 1, over(perc_car) over(gender_rep2) name(pccare, replace) ///
	title("{bf:Free childcare}") ///
	ylabel(0(1)15) ///
	blabel(total)
gr combine pvideo pccare


		* identification with the video
graph hbar (count), over(perc_ident) over(gender_rep2) name(identification_video, replace) ///
		title("{bf:Identification with inspirational video}") ///
		ylabel(0(1)5) ///
		blabel(total, format(%9.0fc))
		
graph hbar (count), over(perc_ident) over(gender_rep2) by(treatment) name(identification_video, replace) ///
		title("{bf:Identification with inspirational video}") ///
		ylabel(0(1)5) ///
		blabel(total, format(%9.0fc))



***********************************************************************
* 	PART 1: registrations per sector
***********************************************************************
graph hbar (sum) registered, over(sector, lab(labsize(vsmall))) blabel(bar) 
