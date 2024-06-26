***********************************************************************
* 			master do file baseline survey, e-commerce 				  *					  
***********************************************************************
*																	  
*	PURPOSE: make all data work reproducible from first import to analysis
* 	for all team members & outsiders								  
*																	  
*	OUTLINE: 	PART 1: Set standard settings & install packages	  
*				PART 2: Prepare dynamic folder paths & globals		  
*				PART 3: Run all do-files                          											  
*																	  
*	Author:  	Teo Firpo & Florian Münch							    
*	ID variable: id_email		  					  
*	Requires:  	  										  
*	Creates:  master-data-ecommerce; 
***********************************************************************
* 	PART 1: 	Set standard settings & install packages			  
***********************************************************************
{
	* set standard settings
version 15
clear all
graph drop _all
scalar drop _all
set more off
set graphics off /* switch off to on to display graphs */
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
}

***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals			  	  *
***********************************************************************		
{
		* dynamic folder path for gdrive(data,output), github(code), backup(local computer)
if "`c(username)'" == "amira.bouziri" |"`c(username)'" == "my rog" | "`c(username)'" == "Fabian Scheifele" | "`c(username)'" == "ayoub" | "`c(username)'" == "Azra" {

		global gdrive = "G:/.shortcut-targets-by-id/1bVknNNmRT3qZhosLmEQwPJeB-O24_QKT"	
}
if "`c(username)'" == "MUNCHFA" {
		global gdrive = "G:/My Drive"
}
if "`c(username)'" == "ASUS" { 

		global gdrive = "G:/Meine Ablage"
	}
	
if c(os) == "Windows" {
	global bl_gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/2-baseline"
	global bl_github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/surveys/baseline"
	global master_gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/6-master"
}

		
if c(os) == "Windows" {
	global regis_gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/1-registration"
	global regis_github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/registration"
}
		* paths within gdrive
			* data
global bl_raw = "${bl_gdrive}/raw"
global bl_intermediate = "${bl_gdrive}/intermediate"
global bl_final = "${bl_gdrive}/final"
global bl_output = "${bl_gdrive}/output"
global bl_checks = "${bl_gdrive}/checks"

global master_raw = "${master_gdrive}/raw"


		* paths within gdrive
			* data
*bl
global bl_raw = "${bl_gdrive}/raw"
global bl_intermediate = "${bl_gdrive}/intermediate"
global bl_final = "${bl_gdrive}/final"
global bl_checks = "${bl_gdrive}/checks"
global bl_output = "${bl_gdrive}/output"

*regis
global regis_raw = "${regis_gdrive}/raw"
global regis_intermediate = "${regis_gdrive}/intermediate"
global regis_final = "${regis_gdrive}/final"
global regis_checks = "${regis_gdrive}/checks"

			* output (regression tables, figures)
global bl_output = "${bl_gdrive}/output"
global bl_figures = "${bl_output}/descriptive-statistics-figures"
global bl_progress = "${bl_output}/progress-eligibility-characteristics"


			* set seeds for replication
			
set seed 20222202
set sortseed 20222202
}
		
***********************************************************************

* 	PART 3: 	Run do-files for data cleaning & survey progress

***********************************************************************
/* --------------------------------------------------------------------
	PART 3.1: Import & raw data (Nrows = 344, incl. duplicates)
----------------------------------------------------------------------*/		
if (1) do "${bl_github}/bl_import.do"
/* --------------------------------------------------------------------
	PART 3.2: Clean raw data & save as intermediate data
----------------------------------------------------------------------*/	
if (1) do "${bl_github}/bl_clean.do"
/* --------------------------------------------------------------------
	PART 3.3: Correct & save intermediate data (Nrows = 236)
----------------------------------------------------------------------*/	
if (1) do "${bl_github}/bl_correct.do"
/* --------------------------------------------------------------------
	PART 3.4: Match to registration data
----------------------------------------------------------------------*/	
if (1) do "${bl_github}/bl_match.do"
/* --------------------------------------------------------------------
	PART 3.5: Generate variables for analysis or implementation
----------------------------------------------------------------------*/	
if (1) do "${bl_github}/bl_generate.do"
/* --------------------------------------------------------------------
	PART 3.6: export open text or number variables for RA check
----------------------------------------------------------------------*/	
if (0) do "${bl_github}/bl_open_question_checks.do"
 /* --------------------------------------------------------------------
	PART 3.7: Perform logical check
	Generates: bl_final.dta
----------------------------------------------------------------------*/	
if (1) do "${bl_github}/bl_test.do"
/* --------------------------------------------------------------------
	PART 3.8: Export pdf with descriptive statistics on responses
----------------------------------------------------------------------*/	
if (0) do "${bl_github}/bl_statistics.do"
/* --------------------------------------------------------------------
	PART 3.9: Generate stratifiers
----------------------------------------------------------------------*/	
if (1) do "${bl_github}/bl_stratification.do"
/* --------------------------------------------------------------------
	PART 3.10: Single Randomisation (dont put on 1!)
----------------------------------------------------------------------*/	
if (0) do "${bl_github}/bl_randomisation.do"
/* --------------------------------------------------------------------
	PART 3.11: Add treatment status after randomisation
----------------------------------------------------------------------*/	
if (1) do "${bl_github}/bl_treat.do"

/* --------------------------------------------------------------------
	PART 4.2 Diagnostic creation
----------------------------------------------------------------------*/	
if (0) do "${bl_github}/bl_diagnostic.do"
