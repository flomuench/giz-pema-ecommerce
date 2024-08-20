***********************************************************************
* 					Semrush data analysis	  
***********************************************************************
*	PURPOSE: Graph the trendline of website pre & post treatment
*																	  
*	OUTLINE: 	PART 1: 
*				PART 2: 	  
*				PART 3: 
*													
*																	  
*	Author:  	Ayoub CHAMAKHI						    
*	ID: 		id_platforme		  					  
*	Requires:	Semrush.xlsx, trendWW/TN_XX.xlsx
*	Creates:	Graphs	

***********************************************************************
* 	PART 1: 	Set standard settings & install packages			  
***********************************************************************
{
	* set standard settings
version 15
set graph on
set scheme burd
set scheme cleanplots
set scheme plotplain

	* install packages
}
***********************************************************************
* 	PART 2: 	Prepare dynamic folder paths & globals
***********************************************************************
{
		* dynamic folder path for gdrive(data,output), github(code), backup(local computer)
		
if "`c(username)'" == "amira.bouziri" |"`c(username)'" == "my rog" | "`c(username)'" == "fabi-" | "`c(username)'" == "ayoub" | "`c(username)'" == "Azra"  | "`c(username)'" == "Admin"{

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
}
***********************************************************************
* PART 1: append excels
***********************************************************************
cd "${gdrive}/12-semrush/raw"

* Loop for trendTN files
forvalues i = 1/39 {
    import excel using "trendTN_`i'.xlsx",firstrow clear
    * Append to a master dataset
    if `i' == 1 {
        save trend_combined_TN, replace
    } 
		else {
        append using trend_combined_TN
        save trend_combined_TN, replace
    }
}

* Loop for trendWW files
forvalues i = 1/39 {
    import excel using "trendWW_`i'.xlsx", firstrow clear
    * Append to the master dataset
    append using trend_combined_TN
    save trend_combined_TN, replace
}

* Rename variables one by one
rename Target link_web
rename F month1
rename G month2
rename H month3
rename I month4
rename J month5
rename K month6
rename L month7
rename M month8
rename N month9
rename O month10
rename P month11
rename Q month12
rename R month13
rename S month14
rename T month15
rename U month16
rename V month17
rename W month18
rename X month19
rename Y month20
rename Z month21
rename AA month22
rename AB month23
rename AC month24
rename AD month25
rename AE month26
rename AF month27
rename AG month28
rename AH month29
rename AI month30
rename AJ month31
rename AK month32
rename AL month33
rename AM month34
rename AN month35
rename AO month36
rename AP month37

*clean existing lin_web
replace link_web = subinstr(link_web, "http://", "", .)
replace link_web = subinstr(link_web, "https://", "", .)
replace link_web = subinstr(link_web, "www.", "", .)
replace link_web = trim(link_web)
replace link_web = subinstr(link_web, " ", "", .)

***********************************************************************
* PART 2: merge master data
***********************************************************************
merge m:m link_web using "semrush.dta"

*drop firms without websites (42)
drop if link_web==""
drop if link_web=="alpha-technology.co.uk" // duplicate

*add id_plateforme to new links of websites (latiri/sfm)
replace id_plateforme = 927 if link_web == "latirimed.com"
replace treatment = 1 if link_web == "latirimed.com"
replace strata = 106.00 if link_web == "latirimed.com"
replace take_up = 1 if link_web == "latirimed.com"

replace id_plateforme = 261 if link_web == "sfmtelecom.com"
replace treatment = 1 if link_web == "sfmtelecom.com"
replace strata = 606.00 if link_web == "sfmtelecom.com"
replace take_up = 1 if link_web == "sfmtelecom.com"

drop _merge

***********************************************************************
* PART 3: collapse & graphs
***********************************************************************
cd "${gdrive}/12-semrush/output"

gen unique_id = _n

* Reshape data from wide to long format
reshape long month, i(unique_id) j(time)

preserve
	
	keep if Metric == "Organic Traffic"
	collapse (mean) month, by(treatment take_up time)

	twoway (line month time if treatment == 1 & take_up == 1, lcolor(blue) lpattern(solid) lwidth(medium) ///
			legend(label(1 "Treatment & Take-Up"))) ///
		   (line month time if treatment == 1 & take_up == 0, lcolor(red) lpattern(solid) lwidth(medium) ///
			legend(label(2 "Treatment"))) ///
		   (line month time if treatment == 0, lcolor(green) lpattern(solid) lwidth(medium) ///
			legend(label(3 "Control"))), xline(9, lpattern(dash)) xline(27, lpattern(dash)) ///
			text(300 9 "May 2022", size(vsmall) place(n)) ///
			text(300 27 "November 2023", size(vsmall) place(n)) ///
			xtitle("Time") ytitle("Average Organic Traffic") ///
			
	gr export avg_organic_traffic.png, width(5000) replace

restore


preserve
	
	keep if Metric == "Organic Keywords"
	collapse (mean) month, by(treatment take_up time)

	twoway (line month time if treatment == 1 & take_up == 1, lcolor(blue) lpattern(solid) lwidth(medium) ///
			legend(label(1 "Treatment & Take-Up"))) ///
		   (line month time if treatment == 1 & take_up == 0, lcolor(red) lpattern(solid) lwidth(medium) ///
			legend(label(2 "Treatment"))) ///
		   (line month time if treatment == 0, lcolor(green) lpattern(solid) lwidth(medium) ///
			legend(label(3 "Control"))), xline(9, lpattern(dash)) xline(27, lpattern(dash)) ///
			text(300 9 "May 2022", size(vsmall) place(n)) ///
			text(300 27 "November 2023", size(vsmall) place(n)) ///
			xtitle("Time") ytitle("Average Organic Keywords") ///
			
	gr export avg_organic_Keywords.png, width(5000) replace

restore

preserve
	
	keep if Metric == "Backlinks"
	collapse (mean) month, by(treatment take_up time)

	twoway (line month time if treatment == 1 & take_up == 1, lcolor(blue) lpattern(solid) lwidth(medium) ///
			legend(label(1 "Treatment & Take-Up"))) ///
		   (line month time if treatment == 1 & take_up == 0, lcolor(red) lpattern(solid) lwidth(medium) ///
			legend(label(2 "Treatment"))) ///
		   (line month time if treatment == 0, lcolor(green) lpattern(solid) lwidth(medium) ///
			legend(label(3 "Control"))), xline(9, lpattern(dash)) ///
			text(300 9 "May 2022", size(vsmall) place(n)) ///
			xtitle("Time") ytitle("Average Backlinks") ///
			
	gr export avg_backlinks.png, width(5000) replace

restore

preserve
	
	keep if Metric == "Ref domains"
	collapse (mean) month, by(treatment take_up time)

	twoway (line month time if treatment == 1 & take_up == 1, lcolor(blue) lpattern(solid) lwidth(medium) ///
			legend(label(1 "Treatment & Take-Up"))) ///
		   (line month time if treatment == 1 & take_up == 0, lcolor(red) lpattern(solid) lwidth(medium) ///
			legend(label(2 "Treatment"))) ///
		   (line month time if treatment == 0, lcolor(green) lpattern(solid) lwidth(medium) ///
			legend(label(3 "Control"))), xline(9, lpattern(dash)) ///
			text(300 9 "May 2022", size(vsmall) place(n)) ///
			xtitle("Time") ytitle("Average Ref domains") ///
			
	gr export avg_ref_domains.png, width(5000) replace

restore