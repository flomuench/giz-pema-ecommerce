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
graph bar (percent) if sample == 1 | sample == 3, over(gender_pdg_corrected) ///
	blabel(bar, format(%9.0fc) gap(.5)) ///
	subtitle("{it:Initial population for emailing}") ///
	ylabel(0 20 40 60 80 100) ///
	name(gender_initial_sample, replace)
graph bar (percent) if sample > 1, over(gender_pdg_corrected) ///
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
graph bar (count) if registered == 1, over(treatment, lab(labsize(vsmall))) over(gender_pdg_corrected) ///
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
graph hbar (count), over(perc_video) over(rg_gender_rep) by(treatment, note("")) ///
		ylabel(0(1)5) ///
		ytitle("number of firms") ///
		blabel(total, format(%9.0fc)) ///
		name(perception_video, replace)
gr export perception_video.png, replace

graph hbar (count), over(perc_car) over(rg_gender_rep) by(treatment, note(""))  ///
		ylabel(0(1)5) ///
		ytitle("number of firms") ///
		blabel(total, format(%9.0fc)) ///
		name(perception_ccare, replace)
gr export perception_childcare.png, replace


		* among only firms that said yes to have been aware
lab var perc_com1 "aware of influencer video = 1"
lab var perc_com2 "aware of free childcare = 1"
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
graph hbar (count), over(perc_ident) over(rg_gender_rep) name(identification_video, replace) ///
		title("{bf:Identification with inspirational video}") ///
		ylabel(0(1)5) ///
		blabel(total, format(%9.0fc))
		
***********************************************************************
* 	PART 4: communication channels by treatment group
***********************************************************************
gr hbar (count), over(moyen_com, lab(labsize(vsmall))) over(treatment) ///
	blabel(total, format(%9.0fc))
		
		
***********************************************************************
* 	PART 5: firm characteristics by treatment group
***********************************************************************
	* two variables need correction given they contain code for wrong answers


* characteristcs to consider
	* variables from registration
local regis_variables rg_fte female_share rg_age rg_capital expstatus1 expstatus2 expstatus3 rg_intention rg_gender_pdg rg_gender_rep presence_enligne
	
	* variables from baseline
local baseline_variables ihs_exports ihs_profits ihs_ca ihs_digrevenue exp_pays_avg raw_expprep raw_knowledge raw_digtalvars investcom_2021 investcom_futur car_risque car_credit car_soutien_gouvern car_pdg_educ car_pdg_age

	* balance table
local variables `regis_variables' `baseline_variables'
iebaltab `variables' if registered == 1 & car_soutien_gouvern >= 0 & car_pdg_educ >= 0, grpvar(treatment) save(baltab_ecom_registered) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)	
iebaltab `variables' if registered == 1 & car_soutien_gouvern != -999 & car_pdg_educ != -999, grpvar(treatment) savetex(baltab_ecom_registered) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine  ///
			 format(%12.2fc)	
			 
***********************************************************************
* 	PART 6: firm characteristics by mean of communication
***********************************************************************			 
* characteristcs to consider
	* variables from registration
local regis_variables rg_fte female_share rg_age rg_capital expstatus1 expstatus2 expstatus3 rg_intention rg_gender_pdg rg_gender_rep presence_enligne
	
	* variables from baseline
local baseline_variables ihs_exports ihs_profits ihs_ca ihs_digrevenue exp_pays_avg raw_expprep raw_knowledge raw_digtalvars investcom_2021 investcom_futur car_risque car_credit car_soutien_gouvern car_pdg_educ

	* balance table
local variables `regis_variables' `baseline_variables'
iebaltab `variables' if registered == 1, grpvar(moyen_com) save(baltab_ecom_registered) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine nottest ///
			 format(%12.2fc)	
iebaltab `variables' registered == 1, grpvar(moyen_com) savetex(baltab_ecom_registered) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine nottest  ///
			 format(%12.2fc)
			 
***********************************************************************
* 	PART 7: registration by strata2 & sector
***********************************************************************	
gr hbar (count), over(registered, lab(labsize(vsmall))) over(strata2) ///
	blabel(bar, format(%9.0fc))
