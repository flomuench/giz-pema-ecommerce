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

cd "$final_figures"
graph bar (percent) if sample == 1 | sample == 3, over(gender) ///
	blabel(bar, format(%9.0fc) gap(.5)) ///
	subtitle("{it:Initial population for emailing}") ///
	ylabel(0 20 40 60 80 100) ///
	name(gender_initial_sample, replace)
graph bar (percent) if sample > 1, over(gender) ///
	blabel(bar, format(%9.0fc) gap(.5)) ///
	subtitle("{it:Sample of registered firms}") ///
	ylabel(0 20 40 60 80 100) ///
	ytitle("") ///
	name(gender_registered, replace)
gr combine gender_initial_sample gender_registered, ///
	name(gender_population_sample, replace)
gr export gender_population_sample.png, replace

	* absolute count
cd "$samp_descriptive"
graph bar (count) if registered == 1, over(treatment, lab(labsize(vsmall))) over(gender) ///
	blabel(bar, format(%9.0fc) gap(.5)) ///
	title("{bf:Registered firms by gender & treatment status}") ///
	subtitle("{it: Gender based on baseline, registration & administrative data}") ///
	name(gender_registered_treatment, replace)
gr export gender_registered_by_treatment.png,replace
			
***********************************************************************
* 	PART 2: bounce rate in the three treatment groups
***********************************************************************
cd "$final_figures"
lab def delivery 1 "bounce" 0 "delivered"
lab val not_delivered delivery
graph bar (percent) ,over(not_delivered) over(treatment) ///
	blabel(total, format(%9.0fc)) ///
	name(bounce_ecommerce, replace)
gr export bounce_ecommerce.png, replace


***********************************************************************
* 	PART 3: importance of different treatments for registration
***********************************************************************
	graph hbar (count), over(perc_video) over(rg_gender_rep) by(treatment) name(pvideo, replace) ///
		title("{bf:Importance of video for registration decision}") ///
		ylabel(0(1)5) ///
		blabel(total, format(%9.0fc))

	graph hbar (count), over(perc_car) over(rg_gender_rep) by(treatment) name(pvideo, replace) ///
		title("{bf:Importance of childcare for registration decision}") ///
		ylabel(0(1)5) ///
		blabel(total, format(%9.0fc))
gr combine pvideo pccare, ///
	name(perception_video_ccare, replace)
gr export perception_video_ccare.png, replace

		* among only firms that said yes to have been aware
graph hbar (count) if perc_com1 == 1, over(perc_video) over(rg_gender_rep) name(pvideo, replace) ///
	title("{bf:Video}") ///
	ylabel(0(1)15) ///
	blabel(total)
graph hbar (count) if perc_com2 == 1, over(perc_car) over(rg_gender_rep) name(pccare, replace) ///
	title("{bf:Free childcare}") ///
	ylabel(0(1)15) ///
	blabel(total)
gr combine pvideo pccare


graph hbar (mean) perc_video if perc_com1 == 1, over(rg_gender_rep) name(pvideo, replace) ///
	title("{bf:Video}") ///
	ylabel(0(1)15) ///
	blabel(total)
graph hbar (mean) perc_car if perc_com2 == 1, over(rg_gender_rep) name(pccare, replace) ///
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
