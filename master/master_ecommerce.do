***********************************************************************
* 			        master do file, e-commerce			   	          *					  
***********************************************************************
*																	  
*	PURPOSE: master do file for replication from import to analysis 	
* 	of consortium registration data								  
*																	  
*	OUTLINE: 	PART 1: Set standard settings & install packages	  
*				PART 2: Prepare dynamic folder paths & globals		  
*				PART 3: Run all do-files                          											  
*																	  
*	Author:  	Fabian Scheifele & Siwar Hakim							    
*	ID variable: id_email		  					  
*	Requires:  	  										  
*	Creates:  master-data-ecommerce; 
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
ssc install blindschemes, replace
ssc install groups, replace
ssc install ihstrans, replace
ssc install winsor2, replace
ssc install scheme-burd, replace
ssc install ranktest
net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
ssc install ivreg2, replace
ssc install estout, replace
ssc install coefplot, replace
*/

***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals
***********************************************************************

		* dynamic folder path for gdrive(data,output), github(code), backup(local computer)
		
if "`c(username)'" == "my rog" | "`c(username)'" == "Fabian Scheifele" | "`c(username)'" == "ayoub" | "`c(username)'" == "Azra" {

		global gdrive = "G:/.shortcut-targets-by-id/1bVknNNmRT3qZhosLmEQwPJeB-O24_QKT"
}
else{

		global gdrive = "C:/Users/`c(username)'/Google Drive"
		
}

		if c(os) == "Windows" {
	global gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data"
	global github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce"
	global backup = "C:/Users/`c(username)'/Documents/e-commerce-email-back-up"
}
else if c(os) == "MacOSX" {
	global gdrive = "/Volumes/GoogleDrive/My Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data"
	global github = "/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce"
	global backup = "/Users/`c(username)'/Documents/e-commerce-email-back-up"
}	
/*
if c(os) == "Windows" {
	global bl_gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/2-baseline"
	global bl_github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/surveys/baseline"
	global bl_backup = "C:/Users/`c(username)'/Documents/e-commerce-email-back-up"
}
else if c(os) == "MacOSX" {
	global bl_gdrive = "/Volumes/GoogleDrive/My Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/2-baseline"
	global bl_github = "/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/surveys/baseline"
	global bl_backup = "/Users/`c(username)'/Documents/e-commerce-email-back-up"
}
if c(os) == "Windows" {
	global bl2_gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/2b-baseline presence enligne"
	global bl2_github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/surveys/baseline online presence"
	global bl2_backup = "C:/Users/`c(username)'/Documents/e-commerce-email-back-up"
}
else if c(os) == "MacOSX" {
	global bl2_gdrive = "/Volumes/GoogleDrive/My Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/2b-baseline presence enligne"
	global bl2_github = "/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/surveys/baseline online presence"
	global bl2_backup = "/Users/`c(username)'/Documents/e-commerce-email-back-up"
}
if c(os) == "Windows" {
	global base_gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data"

}
else if c(os) == "MacOSX" {
	global base_gdrive = "/Volumes/GoogleDrive/My Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data"

}

if c(os) == "Windows" {
	global regis_gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/1-registration"
	global regis_github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/registration"
	global regis_backup = "C:/Users/`c(username)'/Documents/e-commerce-email-back-up"
}
else if c(os) == "MacOSX" {
	global regis_gdrive = "/Volumes/GoogleDrive/My Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/1-registration"
	global regis_github = "/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/registration"
	global regis_backup = "/Users/`c(username)'/Documents/e-commerce-email-back-up"
}
*/
		
* paths within gdrive
			* data
global master_intermediate "${gdrive}/6-master/intermediate"
global master_final = "${gdrive}/6-master/final"
global master_checks = "${gdrive}/6-master/checks"
global master_output = "${gdrive}/6-master/output"
global master_raw = "${gdrive}/6-master/raw"
global master_gdrive ="${gdrive}/6-master"

global bl_raw = "${gdrive}/2-baseline/raw"
global bl_intermediate "${gdrive}/2-baseline/intermediate"
global bl_final = "${gdrive}/2-baseline/final"
global bl_checks = "${gdrive}/2-baseline/checks"
global bl_output = "${gdrive}/2-baseline/output"

global bl2_final ="${gdrive}/2b-baseline presence enligne/final"
global regis_raw = "${gdrive}/1-registration/raw"
global regis_intermediate "${gdrive}/1-registration/intermediate"
global regis_final = "${gdrive}/1-registration/final"
global regis_checks = "${gdrive}/1-registration/checks"

global ml_raw = "${gdrive}/3-midline/raw"
global ml_intermediate = "${gdrive}/3-midline/intermediate"
global ml_final = "${gdrive}/3-midline/final"

* paths within github
			* code
global master_github "${github}/master"

		
			* set seeds for replication
set seed 8413195
set sortseed 8413195
		

***********************************************************************
* 	PART 3: 	Run ecommerce do-files			  	 				  *
***********************************************************************
/*--------------------------------------------------------------------
	PART 3.1: Merge monitoring & pii data
----------------------------------------------------------------------*/		
if (1) do "${master_github}/merge.do"

/* --------------------------------------------------------------------
	PART 3.2: clean final 
----------------------------------------------------------------------*/		
if (1) do "${master_github}/master_clean.do"
/*
--------------------------------------------------------------------
	PART 3.3: Correct observations, if necessary
----------------------------------------------------------------------*/
if (1) do "${master_github}/master_correct.do"
/*--------------------------------------------------------------------
	PART 3.4: Generate variables
----------------------------------------------------------------------*/
if (1) do "${master_github}/master_generate.do"


***********************************************************************
* 	PART 4: 	Run final analysis
***********************************************************************
/*--------------------------------------------------------------------
	PART 4.1: Descriptive statistics
----------------------------------------------------------------------*/		
if (0) do "${master_github}/master_descriptives.do"

/*--------------------------------------------------------------------
	PART 4.2: Power calculations with baseline data
----------------------------------------------------------------------*/		
if (0) do "${master_github}/master_power.do"

/* --------------------------------------------------------------------
	PART 4.2: Regressions
----------------------------------------------------------------------*/
*if (0) do "${master_github}/master_regressions.do"
