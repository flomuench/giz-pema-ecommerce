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

	* continue word export
putdocx begin
putdocx paragraph
putdocx text ("Results of randomisation"), bold linebreak(1)

***********************************************************************
* 	PART 1: set the seed + sort the data
***********************************************************************

	* set the seed (randomisation rule 1)
		* generated random number on random.org between 1 million & 1 billion
set seed 503152734

	* sort the data by email_id (stable sort --> randomisation rule 2)
sort id_email

***********************************************************************
* 	PART 2: random allocation
***********************************************************************
	* random allocation
randtreat, gen(treatment) replace strata(strata2) multiple(3) misfits(wstrata)
			/*
			14 missing values generated
			assignment produces 17 misfits
			2 missing values genreated
			*/
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
	
***********************************************************************
* 	PART 3: balance table
***********************************************************************
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
	
***********************************************************************
* 	PART 4: email lists by treatment status
***********************************************************************			 
	* change directory to final folder
cd "$samp_final"
	
	* check number of observations per treatment group
tab treatment, missing
sort treatment id_email
	
	* define the list of variables to included in each email list
local emaillistvar "id_email treatment firmname name email"
	
	* export for control group / neutral email
preserve 
keep if treatment == 0
gen n = _n
export excel `emaillistvar' using "control1" if n <= 400, firstrow(var) replace
export excel `emaillistvar' using "control2" if n > 400 & n <= 800, firstrow(var) replace
export excel `emaillistvar' using "control3" if n > 800 & n <= 1200, firstrow(var) replace
export excel `emaillistvar' using "control4" if n <= 1500, firstrow(var) replace
restore

	* export for treatment group / garde d'enfant
preserve 
keep if treatment == 1
gen n = _n
export excel `emaillistvar' using "garde_enfant1" if n <= 400, firstrow(var) replace
export excel `emaillistvar' using "garde_enfant2" if n > 400 & n <= 800, firstrow(var) replace
export excel `emaillistvar' using "garde_enfant3" if n > 800 & n <= 1200, firstrow(var) replace
export excel `emaillistvar' using "garde_enfant4" if n <= 1500, firstrow(var) replace
restore	
	
	* export for treatment group / video influenceuse
preserve 
keep if treatment == 2
gen n = _n
export excel `emaillistvar' using "video_influenceuse1" if n <= 400, firstrow(var) replace
export excel `emaillistvar' using "video_influenceuse2" if n > 400 & n <= 800, firstrow(var) replace
export excel `emaillistvar' using "video_influenceuse3" if n > 800 & n <= 1200, firstrow(var) replace
export excel `emaillistvar' using "video_influenceuse4" if n <= 1500, firstrow(var) replace
restore	

***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
	* save word document with visualisations
putdocx save results_randomisation.docx, replace

	* save dta file with stratas
save "giz_contact_list_final", replace
