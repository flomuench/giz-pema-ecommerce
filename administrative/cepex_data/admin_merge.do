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
*	Requires:  	 cp_final.dta								  
*	Creates:     cp_intermediate_ecommerce_transaction AND cp_intermediate_consortia_transaction
***********************************************************************
* 	PART 1:    e-commerce merge and separation
***********************************************************************
use "${cp_final}/cp_final", replace

merge m:1 matricule_fiscale using "${ecomm_pii}/ecommerce_master_contact", ///
	keepusing (id_plateforme treatment treated present status)  
	
**Keep the matched information as e-commerce dataset and the id it did not find and drop the merge=1

keep if _merge==3
drop _merge
	
*make second merge with baseline data to get sector information
merge m:1 id_plateforme using "${ecomm_bl}/bl_final", ///
	keepusing (sector subsector fte )  
keep if _merge==3
drop _merge
		

save "${cp_intermediate}/cp_intermediate_ecommerce_transaction", replace

***********************************************************************
* 	PART 2:    consortium merge and separation
***********************************************************************
use "${cp_final}/cp_final", replace

merge m:1 matricule_fiscale using "${consortia_pii}/consortium_pii_final", ///
	keepusing (id_plateforme treatment)  
	
keep if _merge==3
drop _merge
	
*make second merge  data to get sector information
merge m:1 id_plateforme using "${consortia_pii}/consortia_final", ///
	keepusing (pole employes expstatus exprep_inv take_up_per gouvernorat)  
keep if _merge==3
drop _merge
		

save "${consortia_intermediate}/cp_intermediate_consortia_transaction", replace


