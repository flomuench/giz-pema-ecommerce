***********************************************************************
* 			master do file sampling, email experiment e-commerce 									  
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
*	Author:  	Florian Münch, Teo Firpo							    
*	ID variable: 	?			  					  
*	Requires: ?.dta 	  										  
*	Creates:  *.dta			                                  
***********************************************************************
* 	PART 1: 	Set standard settings & install packages			  
***********************************************************************

	* set standard settings
version 15
clear all
graph drop _all
scalar drop _all
set more off
set graphics off
 /* switch off to on to display graphs */
capture program drop zscore /* drops the program programname */
qui cap log c

	* install packages
*ssc install ietoolkit /* for iebaltab */
*ssc install randtreat, replace /* for randtreat --> random allocation */
*ssc install blindschemes, replace /* for plotplain --> scheme for graphical visualisations */
*net install http://www.stata.com/users/kcrow/tab2docx
*ssc install betterbar
*ssc install mdesc 

	* define graph scheme for visual outputs
set scheme plotplain

***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals			  	  *
***********************************************************************

		* dynamic folder path for gdrive(data,output), github(code), backup(local computer)
if c(os) == "Windows" {
	global samp_gdrive = "C:/Users/`c(username)'/Google Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/0-sampling-email-experiment"
	global samp_github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/sampling-email-experiment"
	global samp_backup = "C:/Users/`c(username)'/Documents/e-commerce-email-back-up"
}
else if c(os) == "MacOSX" {
	global samp_gdrive = "Users/`c(username)'/Google Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/0-sampling-email-experiment"
	global samp_github = "Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/sampling-email-experiment"
	global samp_backup = "Users/`c(username)'/Documents/e-commerce-email-back-up"
}
		* paths within gdrive
			* data
global samp_raw = "${samp_gdrive}/raw"
global samp_intermediate "${samp_gdrive}/intermediate"
global samp_final = "${samp_gdrive}/final"
			* output (regression tables, figures)
global samp_output = "${samp_gdrive}/output"
global samp_figures = "${samp_output}/descriptive-statistics-figures"

		* global for *type* variables
***********************************************************************
* 	PART 3: 	Run midline do-files			  	 				  *
***********************************************************************
/* --------------------------------------------------------------------
	PART 3.1: Import & raw data
	Requires: 
	Creates: 
----------------------------------------------------------------------*/		
if (1) do "${samp_github}/samp_import.do"

/* --------------------------------------------------------------------
	PART 3.2: Clean raw data & save as intermediate data
	NOTE: no observation values are changed
	Requires: 
	Creates: 
----------------------------------------------------------------------*/	
if (1) do "${samp_github}/samp_clean.do"


/* --------------------------------------------------------------------
	PART 3.3: Correct & save intermediate data
	NOTE: observational values are changed, observations are dropped
	Requires: 
	Creates: 
----------------------------------------------------------------------*/	
if (1) do "${samp_github}/samp_correct.do"



/* --------------------------------------------------------------------
	PART 3.4: Generate variables for analysis or implementation
	NOTE: id_email
	Requires: 
	Creates: 
----------------------------------------------------------------------*/	
if (1) do "${samp_github}/samp_generate.do"


/* --------------------------------------------------------------------
	PART 3.5: Stratification
	Requires: 
	Creates: 
----------------------------------------------------------------------*/	
if (1) do "${samp_github}/samp_stratification.do"

/* --------------------------------------------------------------------
	PART 3.6: Randomisation
	Requires: 
	Creates: 
----------------------------------------------------------------------*/	
if (1) do "${samp_github}/samp_randomisation.do"

