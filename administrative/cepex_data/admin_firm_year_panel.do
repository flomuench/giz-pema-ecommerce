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
*	Requires:  	 cp_intermediate_ecommerce_transaction.dta AND cp_intermediate_consortium_transaction	
							  
*	Creates:     cp_final_ecommerce.dta AND cp_final_consortium

***********************************************************************
* 	PART 1:    load e-commerce data and collapse to firm-year level
***********************************************************************
use "${cp_intermediate}/cp_intermediate_ecommerce_transaction", clear

** USE collapse to create SUM(value) and year



***********************************************************************
* 	PART 2:    load consortia data and collapse to firm-year level
***********************************************************************
use "${cp_intermediate}/cp_intermediate_ecommerce_transaction", clear

** USE collapse to create SUM(value) and year