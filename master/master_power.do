***********************************************************************
* 			Descriptive Statistics in master file with different survey rounds*					  
***********************************************************************
*																	  
*	PURPOSE: Re-do power calculations with final outcome variables.					  
*																	  
*	OUTLINE: 	PART 1: Baseline and take-up
*				PART 2: Mid-line	  
*				PART 3: Endline 
*				PART 4: Intertemporal descriptive statistics															
*																	  
*	Author:  	Fabian Scheifele							    
*	ID variable: id_platforme		  					  
*	Requires:  	 ecommerce_data_final.dta

use "${master_intermediate}/ecommerce_master_final", clear
		
		* change directory for outputs
cd "${master_gdrive}/output/power"
***********************************************************************
* 	PART 1: Primary outcome 1: E-commerce adoption
***********************************************************************										  
