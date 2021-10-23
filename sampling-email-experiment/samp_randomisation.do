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
tab treatment

	* generate treatment dummies
tab treatment, gen(Treatment)

	* label treatment assignment status
lab def treat_status 1 "Control" 2 "Free childcare" 3 "Influencer video"
lab var treatment treat_status

	* visualising size of each treatment group
	
	
	* visualising treatment status by strata
graph hbar (count), over(treatment) over(strata)

***********************************************************************
* 	PART 3: balance table
***********************************************************************
		* balance for continuous and few units categorical variables
iebaltab fte export1 export2 Size1-Size4 Origin1 Origin2, grpvar(treatment) save(baltab_email_experiment) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
		
		* visualizing balance for categorical variables with multiple categories
graph hbar (count), over(sector) over(treatment)
			 
***********************************************************************
* 	PART 4: email lists by treatment status
***********************************************************************			 
	* control group / neutral email
	
	* treatment group / garde d'enfant
	
	
	* treatment group / video influenceuse

***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
	* save word document with visualisations
putdocx save descriptive-statistics-strata-variables.docx, replace

	* save dta file with stratas
save "giz_contact_list_inter", replace
