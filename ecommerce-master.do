***********************************************************************
* 			master do-file for e-commerce Tunisia RCT								  
***********************************************************************
*																	  
*	PURPOSE: master do file for replication from import to analysis 	
* 	of e-commerce Tunisia RCT data								  
*																	  
*	OUTLINE: 	
* 			1) Set standard settings & install packages
*			2) Prepare dynamic folder paths & globals
*			3) Merge & append to create analysis data set
*			4) Save as e-commerce database
*			5) Merge & append to create master data (pii)
*
*	Author:  	Florian Muench & Amira Bouziri	& Teo Firpo & Fabian Scheifele						  	  
*	ID variable: 	id_plateforme			  					  
*	Requires: 	  										  
*	Creates:  			                                 
***********************************************************************
* 	PART 1: 	Set standard settings & install packages
***********************************************************************
	* set standard settings
version 15
clear all
graph drop _all
scalar drop _all
set more off
qui cap log c

	* install packages
/* 
ssc install blindschemes, replace
ssc install groups, replace
*/
set scheme plotplain
	
***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals
***********************************************************************
	* set first level globals for code and data
		* dynamic folder path to data

if c(os) == "Windows" {
	global gdrive = "C:/Users/`c(username)'/Google Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data"

}
else if c(os) == "MacOSX" {
	global gdrive = "/Volumes/GoogleDrive/My Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data"
}
		
		* folder path to survey data sets
global reg_final = "${gdrive}/1-registration/final"
global baseline_final = "${gdrive}/2-baseline/final"
global midline_final = "${gdrive}/3-midline/final"
global endline_final = "${gdrive}/4-endline/final"


***********************************************************************
* 	PART 3: merge & append to create analysis data set
***********************************************************************
	* merge registration with baseline data
use "${reg_final}/regis_final", clear

		* change directory to baseline folder for merge with baseline_final
cd "$baseline_final"

		* merge 1:1 based on project id fxxx
merge 1:1 id_plateforme using bl_final

keep if _merge == 3

drop _merge
/*	
	* append registration +  baseline data with midline
cd "$midline_final"
append using ml_final
	
	* append with endline
cd "$endline_final"
append using el_final
*/

***********************************************************************
* 	PART 4: Save as ecommerce_database
***********************************************************************
cd "$gdrive"
save "ecommerce_database", replace


***********************************************************************
* 	PART 5: merge & append to create master data (pii)
***********************************************************************
	* 5.1.: merge registration with baseline data
use "${gdrive}/master_data_ecommerce", clear


		* change directory to baseline folder for merge with baseline_final
cd "$baseline_final"

		* merge 1:1 based on project id fxxx
merge 1:1 id using bl_final_pii

/*	
	* append registration +  baseline data with midline
cd "$midline_final"
merge 1:1 id using ml_final_pii
	
	* append with endline
cd "$endline_final"
merge 1:1 id using el_final_pii

*/
	
***********************************************************************
* 	PART 6: save as aqe_database
***********************************************************************
cd "$gdrive"
save "ecommerce_master_data", replace

