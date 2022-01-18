***********************************************************************
* 			master do file registration, e-commerce 				  *					  
***********************************************************************
*																	  
*	PURPOSE: make all data work reproducible from first import to analysis
* 	for all team members & outsiders								  
*																	  
*	OUTLINE: 	PART 1: Set standard settings & install packages	  
*				PART 2: Prepare dynamic folder paths & globals		  
*				PART 3: Run all do-files                          
*																	  
*																	  
*	Author:  	Florian Münch							    
*	ID variable: id_email		  					  
*	Requires:  	  										  
*	Creates:  master-data-ecommerce; emailexperiment_population_regisle.dta		                                  
***********************************************************************
* 	PART 1: 	Set standard settings & install packages			  
***********************************************************************

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
	/*
ssc install ietoolkit /* for iebaltab */
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
*/


	* define graph scheme for visual outputs
set scheme plotplain

***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals			  	  *
***********************************************************************

		* dynamic folder path for gdrive(data,output), github(code), backup(local computer)
if c(os) == "Windows" {
	global bl_gdrive = "C:/Users/`c(username)'/Google Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/2-baseline"
	global bl_github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/surveys/baseline"
	global bl_backup = "C:/Users/`c(username)'/Documents/e-commerce-email-back-up"
}
else if c(os) == "MacOSX" {
	global bl_gdrive = "/Volumes/GoogleDrive/My Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/2-baseline"
	global bl_github = "/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/surveys/baseline"
	global bl_backup = "/Users/`c(username)'/Documents/e-commerce-email-back-up"
}

if c(os) == "Windows" {
	global samp_gdrive = "C:/Users/`c(username)'/Google Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/0-sampling-email-experiment"
	global samp_github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/sampling-email-experiment"
	global samp_backup = "C:/Users/`c(username)'/Documents/e-commerce-email-back-up"
}
else if c(os) == "MacOSX" {
	global samp_gdrive = "/Volumes/GoogleDrive/My Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/0-sampling-email-experiment"
	global samp_github = "/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/sampling-email-experiment"
	global samp_backup = "Users/`c(username)'/Documents/e-commerce-email-back-up"
}
		* paths within gdrive
			* data
global bl_raw = "${bl_gdrive}/raw"
global bl_intermediate "${bl_gdrive}/intermediate"
global bl_final = "${bl_gdrive}/final"
global bl_checks = "${bl_gdrive}/checks"
global samp_raw = "${samp_gdrive}/raw"
global samp_intermediate "${samp_gdrive}/intermediate"
global samp_final = "${samp_gdrive}/final"


			* output (regression tables, figures)
global bl_output = "${bl_gdrive}/output"
global bl_figures = "${bl_output}/descriptive-statistics-figures"
global bl_progress = "${bl_output}/progress-eligibility-characteristics"


		* global for *type* variables
		
		
		* set seeds for replication
set seed 8413195
set sortseed 8413195
		

***********************************************************************
* 	PART 4: 	Run do-files for data cleaning & registration progress
***********************************************************************
/* --------------------------------------------------------------------
	PART 4.1: Import & raw data
----------------------------------------------------------------------*/		
if (1) do "${bl_github}/bl_import.do"
/* --------------------------------------------------------------------
	PART 4.2: Clean raw data & save as intermediate data
----------------------------------------------------------------------*/	
if (1) do "${bl_github}/bl_clean.do"
/* --------------------------------------------------------------------
	PART 4.3: Correct & save intermediate data
----------------------------------------------------------------------*/	
if (1) do "${bl_github}/bl_correct.do"
/* --------------------------------------------------------------------
	PART 4.4: Generate variables for analysis or implementation
----------------------------------------------------------------------*/	
if (1) do "${bl_github}/bl_generate.do"
/* --------------------------------------------------------------------
	PART 4.6: export open text or number variables for RA check
----------------------------------------------------------------------*/	
if (1) do "${bl_github}/bl_open_question_checks.do"
/* --------------------------------------------------------------------
	PART 4.7: Export pdf with number, characteristics & eligibility of registered firms
----------------------------------------------------------------------*/	
if (1) do "${bl_github}/bl_progress_eligibility_characteristics.do"

/* 
add to existing do files
+ bl_generate: digital, export readiness and export performance score
+ 

new do file 1:
- high frequency checks (generate pdf with statistics)
	 - extreme values, outliers for numerical questions --> comptabilité
	 - time taken per question (per enumerator)
	 - enumerator statistics
	 - logical checks

new do file 2: (generate pdf with statistics)
- descriptive statistics of the responses

new do file 3:
- stratification

new do file 4:
- randomisation + balance check

new do file 5: 
- allocation of treated firms to treatment groups


 */


