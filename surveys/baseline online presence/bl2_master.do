***********************************************************************
* 			master do file second part baseline (google forms), e-commerce 				  *					  
***********************************************************************
*																	  
*	PURPOSE: make all data work reproducible from first import to analysis
* 	for all team members & outsiders								  
*																	  
*	OUTLINE: 	PART 1: Set standard settings & install packages	  
*				PART 2: Prepare dynamic folder paths & globals		  
*				PART 3: Run all do-files                          											  
*																	  
*	Author:  			Ayoub Chamakhi					    
*	ID variable: 		id_platforme 					  
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
if "`c(username)'" == "Azra"{
		global gdrive = "C:/Users/Azra/Google Drive Streaming/.shortcut-targets-by-id/1bVknNNmRT3qZhosLmEQwPJeB-O24_QKT"
		
}
else{
		global gdrive = "C:/Users/`c(username)'/Google Drive"
}

if c(os) == "Windows" {
	global bl2_gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/2b-baseline presence enligne"
	global bl2_github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/surveys/baseline online presence"
	global bl2_backup = "C:/Users/`c(username)'/Documents/baseline-presence-en-ligne-back-up"
}

else if c(os) == "MacOSX" {
	global bl2_gdrive = "/Volumes/GoogleDrive/My Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/2b-baseline presence enligne"
	global bl2_github = "/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/surveys/baseline online presence"
	global bl2_backup = "/Users/`c(username)'/Documents/baseline-presence-en-ligne-back-up"
}		
		

		* paths within gdrive
			* data
global bl2_raw = "${bl2_gdrive}/raw"
global bl2_intermediate "${bl2_gdrive}/intermediate"
global bl2_final = "${bl2_gdrive}/final"
global bl2_output = "${bl2_gdrive}/output"



			* set seeds for replication
			
set seed 11323211
set sortseed 11323211
		
***********************************************************************

* 	PART 3: 	Run do-files for data cleaning & survey progress

***********************************************************************
/* --------------------------------------------------------------------
	PART 3.1: Import & raw data
----------------------------------------------------------------------*/		
if (1) do "${bl2_github}/bl2_import.do"
/* --------------------------------------------------------------------
	PART 3.2: Clean raw data & save as intermediate data
----------------------------------------------------------------------*/	
if (1) do "${bl2_github}/bl2_correct.do"
/* --------------------------------------------------------------------
	PART 3.3: Correct & save intermediate data
----------------------------------------------------------------------*/	
if (1) do "${bl2_github}/bl2_clean.do"
/* --------------------------------------------------------------------
	PART 3.4: Generate new variables in intermediate data
----------------------------------------------------------------------*/	
if (1) do "${bl2_github}/bl2_generate.do"
/* --------------------------------------------------------------------
	PART 3.5: Create statistics on social media of SMEs	
----------------------------------------------------------------------*/	
if (1) do "${bl2_github}/bl2_statistics.do"
/* --------------------------------------------------------------------
