***********************************************************************
* 			creating pannel data		   	       							  *					  
***********************************************************************
*																	  
*	PURPOSE: creating pannels out of the datasets we have					  
*																	  
*	OUTLINE: 	PART 1:   pannels of ecommerce 
*				PART 2:   pannels of consortia 
*			
*																	  
*	Author:  	Ayoub Chamakhi					    
*	ID variable: Id_plateforme		  					  
*	Requires:  	 cp_intermediate_ecommerce_transaction.dta AND cp_intermediate_consortium_transaction	
							  
*	Creates:     multiple frames

***********************************************************************
* 	PART 1:    pannels of ecommerce
***********************************************************************
use "${cp_intermediate}/cp_intermediate_ecommerce_transaction", replace
collapse (sum) VALEUR QTE POIDS , by(matricule_fiscale)
save "${cp_intermediate}/firm_level_ecommerce", replace

use "${ecomm_pii}/ecommerce_master_contact", replace
merge 1:1 matricule_fiscale using "${cp_intermediate}/firm_level_ecommerce"


***********************************************************************
* 	PART 2:    pannels of consortia
***********************************************************************
use "${consortia_intermediate}/cp_intermediate_consortia_transaction", replace
collapse (sum) VALEUR QTE POIDS , by(matricule_fiscale)
save "${cp_intermediate}/firm_level_consortia", replace