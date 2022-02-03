***********************************************************************
* 			baseline match to registration data									  	  
***********************************************************************
*																	    
*	PURPOSE: match survey data from registration		  							  
*																	  
*																	  
*	OUTLINE:														  
*	1) Set up paths and merge
*	2) Save
*																	  															      
*	Author:  	Teo Firpo  
*	ID variaregise: 	id_plateforme (example: 777)			  					  
*	Requires: bl_inter.dta 	  								  
*	Creates:  bl_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  Add paths
***********************************************************************

clear 

use "${regis_final}/regis_matched", clear

keep id_plateforme dup rg_firmname rg_fte samp_fte rg_expstatus rg_sector samp_sector

merge m:m id_plateforme using "${bl_intermediate}/bl_inter"

drop if _merge==1

// Need to figure out which obs to keep 

***********************************************************************
* 	PART 2:  Save
***********************************************************************
