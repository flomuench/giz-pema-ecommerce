***********************************************************************
* 			merge admin data with program data		   	       			  *					  
***********************************************************************
*																	  
*	PURPOSE: merge the admin data with program data and separate dataset by program					  
*																	  
*	OUTLINE: 	PART 1:   merge via matricule_fiscale 
*				PART 2:   separate into consortium and e-commerce admin data 
*			
*																	  
*	Author:  	Ayoub Chamakhi					    
*	ID variable: Id_plateforme		  					  
*	Requires:  	 cp_intermediate.dta								  
*	Creates:     cp_final.dta

***********************************************************************
* 	PART 1:    load admin data
***********************************************************************
use "${cp_intermediate}/cp_intermediate", clear

***********************************************************************
* 	PART 2:    e-commerce merge and separation
***********************************************************************


merge m:1 matricule_fiscale using "${cp_raw}/ecommerce_master_contact", ///
	keepusing (id_plateforme treatment treated present status)  
	
**Keep the matched information as e-commerce dataset and the id it did not find and drop the merge=1

keep if _merge==3 | _merge==2
	
*make second merge with baseline data to get sector information
merge m:1 id_plateforme using "${cp_raw}/bl_final", ///
	keepusing (sector subsector fte )  
		


save "${cp_intermediate}/cp_intermediate_ecommerce_transaction", replace


***********************************************************************
* 	PART 3:    consortium merge and separation
***********************************************************************