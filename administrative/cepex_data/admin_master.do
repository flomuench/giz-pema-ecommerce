***********************************************************************
* 			        master do file, admin data			   	          *					  
***********************************************************************
*																	  
*	PURPOSE: merge data coming from CEPEX with our database						  
*																	  
*	OUTLINE: 	PART 1: Set standard settings & install packages	  
*				PART 2: Prepare dynamic folder paths & globals		  
*				PART 3: Run all do-files                          											  
*																	  
*	Author:  	Ayoub Chamakhi					    
*	ID variable: Id_plateforme		  					  
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
*set graphics off /* switch off to on to display graphs */
capture program drop zscore /* drops the program programname */
qui cap log c
set scheme burd
set scheme cleanplots
set scheme plotplain

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
		
if "`c(username)'" == "my rog" | "`c(username)'" == "Fabian Scheifele" | "`c(username)'" == "ayoub" | "`c(username)'" == "Azra" | "`c(username)'" == "amira.bouziri" | "`c(username)'" == "SIWAR"| "`c(username)'" == "my rog" | "`c(username)'" == "Amina"{

		global person = "G:/.shortcut-targets-by-id/1bVknNNmRT3qZhosLmEQwPJeB-O24_QKT"	
}

	else {
	global person = "G:/Meine Ablage"  | person ="G:/Documents"
}

		if c(os) == "Windows" {
	global cp_gdrive = "${person}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/5-administrative"
	global cp_github = "C:/Users/`c(username)'/Documents/GitHub/giz-pema-ecommerce/administrative/cepex_data"
	global cp_backup = "C:/Users/`c(username)'/Documents/admin-cepex-data"
	*path for ecommerce-pii
	global ecomm_pii = "${person}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/6-master/pii"
	*path for ecommerce baseline data
	global ecomm_bl = "${person}/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/2-baseline/final"
	*path for consortia-pii
	global consortia_pii = "${person}/Research_GIZ_Tunisia_exportpromotion/1. Intervention III – Consortia/data/6-master/final"
	*path for consortia_administrative
	global consortia_admin = "${person}/Research_GIZ_Tunisia_exportpromotion/1. Intervention III – Consortia/data/5-administrative"

}
else if c(os) == "MacOSX" {
	global gdrive = "/Volumes/GoogleDrive/My Drive/Research_GIZ_Tunisia_exportpromotion/1. Intervention I – E-commerce/data/5-administrative"
	global github = "/Users/`c(username)'/Documents/GitHub/administrative/cepex_data"
	global backup = "/Users/`c(username)'/Documents/admin-cepex-data"
}	

* paths within gdrive
			* data

global cp_raw = "${cp_gdrive}/raw"
global cp_intermediate = "${cp_gdrive}/intermediate"
global cp_final = "${cp_gdrive}/final"
global cp_output = "${cp_gdrive}/output"

global consortia_intermediate = "${consortia_admin}/intermediate"
global consortia_final = "${consortia_admin}/final"
global consortia_output = "${consortia_admin}/output"


		
			* set seeds for replication
set seed 1532421
set sortseed 1532421
		

***********************************************************************
* 	PART 3: 	Run admin data do-files			  	 				  *
***********************************************************************
/* --------------------------------------------------------------------
	PART 3.1: import file
----------------------------------------------------------------------*/		
if (1) do "${cp_github}/admin_import.do"
/*--------------------------------------------------------------------
	PART 3.2: clean file
----------------------------------------------------------------------*/		
if (1) do "${cp_github}/admin_clean.do"
/*--------------------------------------------------------------------
	PART 3.3: merge file
----------------------------------------------------------------------*/		
if (1) do "${cp_github}/admin_merge.do"
/*--------------------------------------------------------------------
	PART 3.4: panel file
----------------------------------------------------------------------*/		
if (1) do "${cp_github}/admin_frames.do"
/*--------------------------------------------------------------------
	PART 3.5: descriptives
----------------------------------------------------------------------*/		
if (1) do "${cp_github}/admin_descriptives.do"
/*--------------------------------------------------------------------


