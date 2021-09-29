***********************************************************************
* 			sampling email experiment clean								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)																  
*	2)
*	3)																  
*																	 																      *
*	Author:  	Teo Firpo													  
*	ID variable: 				  									  
*	Requires:			´
*	Creates:														  
*																	  
***********************************************************************
* 	PART START: define the settings as necessary 				  										  *
***********************************************************************
* either import Excel raw 
import excel "${ml_raw}/samp_raw.xlsx", firstrow clear

* or use intermediate dta
use "${samp_intermediate}/samp_inter", clear




***********************************************************************
* 	PART 1: 				  										  
***********************************************************************



***********************************************************************
* 	PART 2: 				  										  
***********************************************************************



***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
* either save raw
cd "$samp_raw"
save "samp_raw", replace
* or save intermediate
cd "$samp_intermediate"
save "samp_inter", replace
* or save final
cd "$samp_final"
save "samp_final", replace
