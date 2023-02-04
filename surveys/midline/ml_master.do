***********************************************************************
* 			master do file for midline ecommernce	 				  *					  
***********************************************************************
*																	  
*	PURPOSE: make all data work reproducible from first import to analysis
* 	for all team members & outsiders								  
*																	  
*	OUTLINE: 	PART 1: Set standard settings & install packages	  
*				PART 2: Prepare dynamic folder paths & globals		  
*				PART 3: Run all do-files                          											  
*																	  
*	Author:  								    
*	ID variable: 		id_plateforme 					  
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
set graphics on /* switch off to on to display graphs */
capture program drop zscore /* drops the program programname */
qui cap log c

	* install packages
	
/*ssc install ietoolkit /* for iebaltab */
ssc install randtreat, replace /* for randtreat --> random allocation */
ssc install blindschemes, replace /* for plotplain --> scheme for graphical visualisations */
net install http://www.stata.com/users/kcrow/tab2docx
ssc install betterbar
ssc install mdesc 
ssc install reclink
ssc install matchit
ssc install strgroup
ssc install stripplot
net install http://www.stata.com/users/kcrow/tab2docx
ssc install labutil
ssc inst extremes
ssc install winsor
*/


	* define graph scheme for visual outputs
set scheme plotplain

***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals			  	  *
***********************************************************************

		* dynamic folder path for gdrive(data,output), github(code), backup(local computer)
		
if "`c(username)'" == "amira.bouziri" |"`c(username)'" == "my rog" | "`c(username)'" == "Fabian Scheifele" | "`c(username)'" == "ayoub" | "`c(username)'" == "Azra" {

		global gdrive = "G:/.shortcut-targets-by-id/1bVknNNmRT3qZhosLmEQwPJeB-O24_QKT"
}
else{

		global gdrive = "C:/Users/`c(username)'/Google Drive"
}


if c(os) == "Windows" {
	global ml_gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/3-midline"
	global ml_github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/surveys/midline"
	global ml_backup = "C:/Users/`c(username)'/Documents/midline-back-up"
	global master_gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/6-master"
}

else if c(os) == "MacOSX" {
	global ml_gdrive = "/Volumes/GoogleDrive/My Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/3-midline"
	global ml_github = "/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/surveys/midline"
	global ml_backup = "/Users/`c(username)'/Documents/midline-back-up"
	global master_gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/6-master"
}		
		

		* paths within gdrive
			* data
global ml_raw = "${ml_gdrive}/raw"
global ml_intermediate "${ml_gdrive}/intermediate"
global ml_final = "${ml_gdrive}/final"
global ml_output = "${ml_gdrive}/output"
global ml_checks = "${ml_gdrive}/checks"

global master_raw = "${master_gdrive}/raw"



			* set seeds for replication
			
set seed 11343211
set sortseed 11343211
		
***********************************************************************

* 	PART 3: 	Run do-files for data cleaning & survey progress

***********************************************************************
/* --------------------------------------------------------------------
	PART 3.1: Import & raw data
	Requires: ml_raw
	Creates:  ml_intermediate
----------------------------------------------------------------------*/		
if (1) do "${ml_github}/ml_import.do"
/* --------------------------------------------------------------------
	PART 3.2: Clean raw data & save as intermediate data
----------------------------------------------------------------------*/	
if (1) do "${ml_github}/ml_clean.do"
/* --------------------------------------------------------------------
	PART 3.3: Correct & save intermediate data
----------------------------------------------------------------------*/	
if (1) do "${ml_github}/ml_correct.do"
/* --------------------------------------------------------------------
	PART 3.4: Generate new variables in intermediate data
	Requires: ml_intermediate
	Creates:  ml_final
----------------------------------------------------------------------*/	
if (1) do "${ml_github}/ml_generate.do"
/* --------------------------------------------------------------------
--------------------------------------------------------------------
	PART 3.6: Create statistics	for the survey
----------------------------------------------------------------------*/	
if (1) do "${ml_github}/ml_descriptives.do"
/* --------------------------------------------------------------------
