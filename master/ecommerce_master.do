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
*	Author:  	Fabian Scheifele					    
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
*set graphics off /* switch off to on to display graphs */
capture program drop zscore /* drops the program programname */
qui cap log c
set scheme burd
set scheme cleanplots
set scheme plotplain

	* install packages

/*ssc install blindschemes, replace
ssc install groups, replace
ssc install ihstrans, replace
ssc install winsor2, replace
ssc install scheme-burd, replace
ssc install ranktest
net install cleanplots, from("https://tdmize.github.io/data/cleanplots")
ssc install ivreg2, replace
ssc install estout, replace
ssc install coefplot, replace
ssc install mipolate, replace
ssc install wyoung, replace
ssc install catplot, replace
*/
}
***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals
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
	global gdrive = "${gdrive}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data"
	global github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce"
	global backup = "C:/Users/`c(username)'/Documents/e-commerce-email-back-up"
}
else if c(os) == "MacOSX" {
	global gdrive = "/Volumes/GoogleDrive/My Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data"
	global github = "/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce"
	global backup = "/Users/`c(username)'/Documents/e-commerce-email-back-up"
}	
	
* paths within gdrive
			* data
global master_intermediate = "${gdrive}/6-master/intermediate"
global master_final = "${gdrive}/6-master/final"
global master_checks = "${gdrive}/6-master/checks"
global master_output = "${gdrive}/6-master/output"
global master_raw = "${gdrive}/6-master/raw"
global master_gdrive ="${gdrive}/6-master"
global master_pii ="${master_gdrive}/pii"
global implementation = "${gdrive}/9-implementation"
global map = "${gdrive}/11-geolocation"

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
global ml_checks = "${gdrive}/3-midline/checks"

global el_raw = "${gdrive}/4-endline/raw"
global el_intermediate = "${gdrive}/4-endline/intermediate"
global el_final = "${gdrive}/4-endline/final"
global el_checks = "${gdrive}/4-endline/checks"

global map_raw = "${map}/raw"
global map_output = "${map}/output"

* paths within github
			* code
global master_github "${github}/master"

		
			* set seeds for replication
set seed 8413195
set sortseed 8413195

}	

***********************************************************************
* 	PART 3: 	Run ecommerce do-files			  	 				  *
***********************************************************************
/*--------------------------------------------------------------------
	PART 3.1: Merge and update pii data
----------------------------------------------------------------------*/
if (1) do "${master_github}/master_contact_data.do"
/*--------------------------------------------------------------------
	PART 3.2: Merge survey data
----------------------------------------------------------------------*/		
if (1) do "${master_github}/master_merge.do"
/* --------------------------------------------------------------------
	PART 3.3: clean final 
----------------------------------------------------------------------*/		
if (1) do "${master_github}/master_clean.do"
/*--------------------------------------------------------------------
	PART 3.4: Correct baseline & midline observation, if necessary
----------------------------------------------------------------------*/
if (1) do "${master_github}/master_correct.do"
/*--------------------------------------------------------------------
	PART 3.5: Generate variables
----------------------------------------------------------------------*/
if (1) do "${master_github}/master_generate.do"
/*--------------------------------------------------------------------
	PART 3.6: Test coherence between survey rounds / questions midline
----------------------------------------------------------------------*/
if (0) do "${master_github}/master_test_ml.do"
/*--------------------------------------------------------------------
	PART 3.7: Test coherence between survey rounds / questions endline
----------------------------------------------------------------------*/
if (0) do "${master_github}/master_test_el.do"

***********************************************************************
* 	PART 4: 	Run final analysis
***********************************************************************
/*--------------------------------------------------------------------
	PART 4.1: Descriptive statistics
----------------------------------------------------------------------*/		
if (0) do "${master_github}/master_descriptives.do"
/*--------------------------------------------------------------------
	PART 4.1.1: Descriptive statistics endline
----------------------------------------------------------------------*/		
if (0) do "${master_github}/master_descriptives_el.do"
/*--------------------------------------------------------------------
	PART 4.2: Power calculations with baseline data
----------------------------------------------------------------------*/		
if (0) do "${master_github}/master_power.do"
/* --------------------------------------------------------------------
	PART 4.3: Midline old regression
----------------------------------------------------------------------*/
if (0) do "${master_github}/master_oldregression_ml.do"
/* --------------------------------------------------------------------
	PART 4.4: Midline regression
----------------------------------------------------------------------*/
if (0) do "${master_github}/master_regression_ml.do"
/* --------------------------------------------------------------------
	PART 4.5: Midline heterogeneity
----------------------------------------------------------------------*/
if (0) do "${master_github}/master_heterogeneity_ml.do"
/* --------------------------------------------------------------------
/* --------------------------------------------------------------------
	PART 4.6: Endline regression
----------------------------------------------------------------------*/
if (1) do "${master_github}/master_regression_el.do"
/* --------------------------------------------------------------------
	PART 4.6: Endline heterogeneity
----------------------------------------------------------------------*/
if (1) do "${master_github}/master_heterogeneity_el.do"
----------------------------------------------------------------------*/
***********************************************************************
* 	PART 5:		Build coordinates map
***********************************************************************
if (0) do "${master_github}/master_map.do"
