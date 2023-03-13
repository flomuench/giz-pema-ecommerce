***********************************************************************
* 			creating frames		   	       							  *					  
***********************************************************************
*																	  
*	PURPOSE: creating frames out of the datasets we have					  
*																	  
*	OUTLINE: 	PART 1:   frames of ecommerce 
*				PART 2:   frames of consortia 
*			
*																	  
*	Author:  	Ayoub Chamakhi					    
*	ID variable: Id_plateforme		  					  
*	Requires:  	 cp_intermediate_ecommerce_transaction.dta AND cp_intermediate_consortium_transaction	
							  
*	Creates:     multiple frames

***********************************************************************
* 	PART 1:    frames of ecommerce
***********************************************************************
*completness frame
use "${cp_intermediate}/cp_intermediate_ecommerce_transaction", replace
frame put matricule_fiscale, into(completness_ecom)
frame completness_ecom: duplicates drop

*status frame
use "${cp_intermediate}/cp_intermediate_ecommerce_transaction", clear
frame put treatment matricule_fiscale, into(completness_status_ecom)
frame completness_status_ecom: duplicates drop matricule_fiscale, force


*evolution frame
use "${cp_intermediate}/cp_intermediate_ecommerce_transaction", replace
frame put Year VALEUR, into(evolution_ecom)
frame evolution_ecom: collapse (sum) VALEUR, by(Year)

*sectors
use "${cp_intermediate}/cp_intermediate_ecommerce_transaction", clear
frame put sector VALEUR, into(sector_ecom)
frame sector_ecom: collapse VALEUR, by(sector)

*sub-sector
use "${cp_intermediate}/cp_intermediate_ecommerce_transaction", clear
frame put subsector VALEUR, into(subsector_ecom)
frame subsector_ecom: collapse VALEUR, by(subsector)

***********************************************************************
* 	PART 2:    load consortia data and collapse to firm-year level
***********************************************************************
*completness frame
use "${consortia_intermediate}/cp_intermediate_consortia_transaction", replace
frame put matricule_fiscale, into(completness_consortia)
frame completness_consortia: duplicates drop

*status frame
use "${consortia_intermediate}/cp_intermediate_consortia_transaction", replace
frame put treatment matricule_fiscale, into(completness_status_consortia)
frame completness_status_consortia: duplicates drop matricule_fiscale, force

*evolution frame
use "${consortia_intermediate}/cp_intermediate_consortia_transaction", replace
frame put Year VALEUR, into(evolution_consortia)
frame evolution_consortia: collapse (sum) VALEUR, by(Year)

*pole
use "${consortia_intermediate}/cp_intermediate_consortia_transaction", clear
frame put pole VALEUR, into(sector_consortia)
frame sector_consortia: collapse VALEUR, by(pole)

