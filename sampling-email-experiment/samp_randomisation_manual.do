***********************************************************************
* 			sampling email experiment stratification								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)	 set seed + sort by email id													  
*	2)	 random allocation
*	3)	 balance table
*	4) 	 generate email list Excel sheets by treatment status & max. contacts per email
*																 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_inter.dta
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART Start: import the data + set the seed				  										  *
***********************************************************************
	* import the data
use "${samp_intermediate}/giz_contact_list_inter", clear

	* change directory to final folder
cd "$samp_randomisation"

	* continue word export
putdocx begin
putdocx paragraph
putdocx text ("Results of manual randomisation"), bold linebreak



***********************************************************************
* 	PART 1: sort the data
***********************************************************************

	* sort the data by email_id (stable sort --> randomisation rule 2)
isid id_email, sort
browse id_email strata2 firmname


***********************************************************************
* 	PART 2: random allocation
***********************************************************************
	* gen number of observations per strata
sort strata2 id_email, stable
browse id_email firmname strata2
by strata2 : gen tot_obs = _N
browse id_email firmname strata2 tot_obs

	* gen random rank per strata
sort strata2 id_email, stable
gen random = uniform()
by strata2: egen rank = rank(random), unique
sort strata2 random, stable
browse id_email firmname strata2 tot_obs random rank

	* find out whether strata size is divisible by three
gen div3 = tot_obs / 3
sort strata2, stable
tab div3
browse id_email firmname strata2 tot_obs random rank div3

		/* suggests that the  following strata are divisible by 3:
		8, 14, 15
		
		Rest of 1:
		2, 3, 4, 5, 12, 10, 11, 9, 7
		
		Rest of 2:
		16, 1, 13, 17, 6
		
		in total there are: 1*9 + 5 * 2 = 19 misfits
		
		*/
	* gen dummies for stratas with misfit
gen misfit1 = (inlist(strata2, 2,3,4,5,12,10,11,9,7))
gen misfit2 = (inlist(strata2, 16,1,13,17,6))
codebook strata2 if misfit1 == 1
codebook strata2 if misfit2 == 1
browse id_email firmname strata2 misfit* tot_obs random rank div3
		
	* gen adopted top value for 
gen tot_obs1 = tot_obs
		* strata with 1 misfit
replace tot_obs1 = tot_obs - 1 if misfit1 == 1
codebook tot_obs1 if misfit1== 1
		* strata with 2 misfits 
replace tot_obs1 = tot_obs - 2 if misfit2 == 1
codebook tot_obs1 if misfit2== 1


	* within strata, allocate firms to treatment & control
gen treatment = .
sort strata2 rank, stable
by strata2: replace treatment = 0 if rank <= tot_obs1 / 3
browse id_email firmname treatment strata2 misfit* tot_obs random rank div3
by strata2: replace treatment = 1 if rank > tot_obs1 / 3 & rank <= 2* (tot_obs1 / 3)
by strata2: replace treatment = 2 if rank > 2*(tot_obs1 / 3) & rank <= tot_obs1
tab treatment if strata2 == 2, missing

	* create a dummy to identify observations with misfit
gen misfits = (treatment == .) /* should be 19 misfits */

	* allocate misfits randomly within each strata
		* sort the observations by strata2 and rank
sort strata2 rank, stable
		* generate a random number only for misfit observations
gen random2 = uniform() if misfits == 1
		* rank the misfits
egen rank2 = rank(random2), unique


		
		* allocate first 3rd to control, 2nd to treat1 & 3rd 
replace treatment = 0 if rank2 <= 6
replace treatment = 1 if rank2 > 6 & rank2 <= 12
replace treatment = 2 if rank2 > 12 & rank2 <= 18
		
		* allocate last remaining observation based on the value of its random number
replace treatment = 0 if rank2 == 19 & random2 <= 0.33
replace treatment = 1 if rank2 == 19 & random2 > .33 & random2 <= 0.66
replace treatment = 2 if rank2 == 19 & random2 > .66 & random2 < .

***********************************************************************
* 	PART 3: visualize randomisation results
***********************************************************************
tab treatment, missing
			/* for some reasons, 2 obs are not allocated */

	* generate treatment dummies
tab treatment, gen(Treatment)
lab var Treatment1 "control group - neutral email"
lab var Treatment2 "treatment group 1 - free childcare"
lab var Treatment3 "treatment  group 2 - influencer video"

	* label treatment assignment status
lab def treat_status 0 "Control" 1 "Free childcare" 2 "Influencer video"
lab values treatment treat_status
tab treatment, missing

	* visualising size of each treatment group
graph bar (count), over(treatment) ///
	title("Firms per treatment group") ///
	ytitle("Number of firms") ///
	blabel(bar, format(%-4.0f) size(vsmall)) ///
	note("Total sample size = 4343.", size(vsmall))
graph export firms_per_treatmentgroup.png, replace
	putdocx paragraph, halign(center)
	putdocx image firms_per_treatmentgroup.png, width(4)
	
	* visualising treatment status by strata
graph hbar (count), over(treatment, lab(labs(tiny))) over(strata2, lab(labs(small))) ///
	title("Firms per treatment group within each strata") ///
	blabel(bar, format(%4.0f) size(tiny)) ///
	ylabel(, labsize(minuscule) format(%-100s))
	graph export firms_per_treatmentgroup_strata.png, replace
	putdocx paragraph, halign(center)
	putdocx image firms_per_treatmentgroup_strata.png, width(4)		
		
		
		* balance for continuous and few units categorical variables
iebaltab fte export1 export2 Size1-Size4 Origin1 Origin2, grpvar(treatment) save(baltab_email_experiment) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
		
		* visualizing balance for categorical variables with multiple categories
graph hbar (count), over(treatment, lab(labs(tiny))) over(Sector, lab(labs(vsmall))) ///
	title("Balance across sectors") ///
	blabel(bar, format(%4.0f) size(tiny)) ///
	ylabel(, labsize(minuscule) format(%-100s))
	graph export balance_sectors.png, replace
	putdocx paragraph, halign(center)
	putdocx image balance_sectors.png, width(4)	
	
	
	* export to verify replicability
export excel id_email firmname strata2 tot_obs random* rank* using test_replicable, replace firstrow(var)

	
***********************************************************************
* 	PART 4: email lists by treatment status
***********************************************************************			 	
cd "$samp_emaillists"
	
	* check number of observations per treatment group
tab treatment, missing
	
	* sort emails for export: 
sort treatment id_email, stable
	
	* define the list of variables to included in each email list
local emaillistvar "treatment *name email"
	
	* export for control group / neutral email
preserve 
keep if treatment == 0
gen n = _n
export excel `emaillistvar' using "control1" if n <= 400, firstrow(var) replace
export excel `emaillistvar' using "control2" if n > 400 & n <= 800, firstrow(var) replace
export excel `emaillistvar' using "control3" if n > 800 & n <= 1200, firstrow(var) replace
export excel `emaillistvar' using "control4" if n > 1200 & n <= 1500, firstrow(var) replace
restore

	* export for treatment group / garde d'enfant
preserve 
keep if treatment == 1
gen n = _n
export excel `emaillistvar' using "garde_enfant1" if n <= 400, firstrow(var) replace
export excel `emaillistvar' using "garde_enfant2" if n > 400 & n <= 800, firstrow(var) replace
export excel `emaillistvar' using "garde_enfant3" if n > 800 & n <= 1200, firstrow(var) replace
export excel `emaillistvar' using "garde_enfant4" if n > 1200 & n <= 1500, firstrow(var) replace
restore	
	
	* export for treatment group / video influenceuse
preserve 
keep if treatment == 2
gen n = _n
export excel `emaillistvar' using "video_influenceuse1" if n <= 400, firstrow(var) replace
export excel `emaillistvar' using "video_influenceuse2" if n > 400 & n <= 800, firstrow(var) replace
export excel `emaillistvar' using "video_influenceuse3" if n > 800 & n <= 1200, firstrow(var) replace
export excel `emaillistvar' using "video_influenceuse4" if n > 1200 & n <= 1500, firstrow(var) replace
restore	

***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
	* save word document with visualisations
cd "$samp_randomisation"
putdocx save results_randomisation.docx, replace

	* save dta file with stratas
cd "$samp_final"
save "giz_contact_list_final", replace


