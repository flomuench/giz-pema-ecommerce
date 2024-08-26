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

*ihs & wins 99th
forvalues j = 1/37 {
    * Winsorize at 99th percentile
    winsor2 month`j', replace cuts(5 95)
}

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

* Worldwide data
	*Organic traffic 
{
		*reg
preserve
	
	keep if Database == "Worldwide"
	keep if Metric == "Organic Traffic"
	collapse (mean) month, by(treatment take_up time)

	* Generate predicted values and standard errors for confidence intervals
	regress month time if treatment == 1 & take_up == 1
	predict yhat_treat_takeup, xb
	predict se_fit_treat_takeup, stdp
	gen ci_lower_treat_takeup = yhat_treat_takeup - 1.96 * se_fit_treat_takeup
	gen ci_upper_treat_takeup = yhat_treat_takeup + 1.96 * se_fit_treat_takeup

	regress month time if treatment == 1 & take_up == 0
	predict yhat_treat, xb
	predict se_fit_treat, stdp
	gen ci_lower_treat = yhat_treat - 1.96 * se_fit_treat
	gen ci_upper_treat = yhat_treat + 1.96 * se_fit_treat

	regress month time if treatment == 0
	predict yhat_control, xb
	predict se_fit_control, stdp
	gen ci_lower_control = yhat_control - 1.96 * se_fit_control
	gen ci_upper_control = yhat_control + 1.96 * se_fit_control

	twoway (rarea ci_lower_treat_takeup ci_upper_treat_takeup time if treatment == 1 & take_up == 1, fcolor(blue%5) lcolor(blue%30) lwidth(medium) lpattern(dash)) ///
		   (rarea ci_lower_treat ci_upper_treat time if treatment == 1 & take_up == 0, fcolor(red%5) lcolor(red%30) lwidth(medium) lpattern(dash)) ///
		   (rarea ci_lower_control ci_upper_control time if treatment == 0, fcolor(green%5) lcolor(green%30) lwidth(medium) lpattern(dash)) ///
		   (line yhat_treat_takeup time if treatment == 1 & take_up == 1, lcolor(blue) lpattern(solid) lwidth(medium) ///
		   legend(label(1 "Treatment with Take-Up"))) ///
		   (line yhat_treat time if treatment == 1 & take_up == 0, lcolor(red) lpattern(solid) lwidth(medium) ///
		   legend(label(2 "Treatment without Take-Up"))) ///
		   (line yhat_control time if treatment == 0, lcolor(green) lpattern(solid) lwidth(medium) ///
		   legend(label(3 "Control"))), xline(10, lpattern(dash)) ///
		   xtitle("Time") ytitle("Average Organic Traffic using Regression") ///*
       xlabel(1 "Aug 2021" 2 "Sep 2021" 3 "Oct 2021" 4 "Nov 2021" 5 "Dec 2021" ///
              6 "Jan 2022" 7 "Feb 2022" 8 "Mar 2022" 9 "Apr 2022" 10 "May 2022" ///
              11 "Jun 2022" 12 "Jul 2022" 13 "Aug 2022" 14 "Sep 2022" 15 "Oct 2022" ///
              16 "Nov 2022" 17 "Dec 2022" 18 "Jan 2023" 19 "Feb 2023" 20 "Mar 2023" ///
              21 "Apr 2023" 22 "May 2023" 23 "Jun 2023" 24 "Jul 2023" 25 "Aug 2023" ///
              26 "Sep 2023" 27 "Oct 2023" 28 "Nov 2023" 29 "Dec 2023" 30 "Jan 2024" ///
              31 "Feb 2024" 32 "Mar 2024" 33 "Apr 2024" 34 "May 2024" 35 "Jun 2024" ///
              36 "Jul 2024" 37 "Aug 2024") ///
       xlabel(, angle(vertical) labsize(vsmall)) ///
	   note("95% CI") ///
			
	gr export reg_avg_organic_traffic.png, width(5000) replace

restore

			*means
preserve

    * Filter for specific data
    keep if Database == "Worldwide"
    keep if Metric == "Organic Traffic"

    * Collapse data to get the mean and standard deviation for each group
    collapse (mean) outcome = month (sd) outcome_sd = month, by(treatment take_up time)

    * Step 2: Calculate standard error and confidence intervals
    gen se = outcome_sd / sqrt(_N)  // Standard error of the mean
    gen lb = outcome - 1.96 * se    // Lower bound of the 95% CI
    gen ub = outcome + 1.96 * se    // Upper bound of the 95% CI

* Step 3: Plotting the data with shaded confidence intervals
twoway (rarea lb ub time if treatment == 1 & take_up == 1, ///
           fcolor(blue%5) lcolor(blue%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if treatment == 1 & take_up == 0, ///
           fcolor(red%5) lcolor(red%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if treatment == 0, ///
           fcolor(green%5) lcolor(green%50) lwidth(medium) lpattern(dash)) ///
       (line outcome time if treatment == 1 & take_up == 1, ///
           lcolor(blue) lpattern(solid) lwidth(medium) legend(label(1 "Treatment with Take-Up"))) ///
       (line outcome time if treatment == 1 & take_up == 0, ///
           lcolor(red) lpattern(solid) lwidth(medium) legend(label(2 "Treatment without Take-Up"))) ///
       (line outcome time if treatment == 0, ///
           lcolor(green) lpattern(solid) lwidth(medium) legend(label(3 "Control"))), ///
       xline(10, lpattern(dash)) ///
       xtitle("Time") ytitle("Average Organic Traffic") ///
       xlabel(1 "Aug 2021" 2 "Sep 2021" 3 "Oct 2021" 4 "Nov 2021" 5 "Dec 2021" ///
              6 "Jan 2022" 7 "Feb 2022" 8 "Mar 2022" 9 "Apr 2022" 10 "May 2022" ///
              11 "Jun 2022" 12 "Jul 2022" 13 "Aug 2022" 14 "Sep 2022" 15 "Oct 2022" ///
              16 "Nov 2022" 17 "Dec 2022" 18 "Jan 2023" 19 "Feb 2023" 20 "Mar 2023" ///
              21 "Apr 2023" 22 "May 2023" 23 "Jun 2023" 24 "Jul 2023" 25 "Aug 2023" ///
              26 "Sep 2023" 27 "Oct 2023" 28 "Nov 2023" 29 "Dec 2023" 30 "Jan 2024" ///
              31 "Feb 2024" 32 "Mar 2024" 33 "Apr 2024" 34 "May 2024" 35 "Jun 2024" ///
              36 "Jul 2024" 37 "Aug 2024") ///
       xlabel(, angle(vertical) labsize(vsmall)) ///
       note("95% CI")

* Step 4: Export the graph
gr export avg_organic_traffic.png, width(5000) replace

restore
}
	*Organic Keywords
{
		*reg
preserve
	
	keep if Database == "Worldwide"
	keep if Metric == "Organic Keywords"
	collapse (mean) month, by(treatment take_up time)

	* Generate predicted values and standard errors for confidence intervals
	regress month time if treatment == 1 & take_up == 1
	predict yhat_treat_takeup, xb
	predict se_fit_treat_takeup, stdp
	gen ci_lower_treat_takeup = yhat_treat_takeup - 1.96 * se_fit_treat_takeup
	gen ci_upper_treat_takeup = yhat_treat_takeup + 1.96 * se_fit_treat_takeup

	regress month time if treatment == 1 & take_up == 0
	predict yhat_treat, xb
	predict se_fit_treat, stdp
	gen ci_lower_treat = yhat_treat - 1.96 * se_fit_treat
	gen ci_upper_treat = yhat_treat + 1.96 * se_fit_treat

	regress month time if treatment == 0
	predict yhat_control, xb
	predict se_fit_control, stdp
	gen ci_lower_control = yhat_control - 1.96 * se_fit_control
	gen ci_upper_control = yhat_control + 1.96 * se_fit_control

	twoway (rarea ci_lower_treat_takeup ci_upper_treat_takeup time if treatment == 1 & take_up == 1, fcolor(blue%5) lcolor(blue%30) lwidth(medium) lpattern(dash)) ///
		   (rarea ci_lower_treat ci_upper_treat time if treatment == 1 & take_up == 0, fcolor(red%5) lcolor(red%30) lwidth(medium) lpattern(dash)) ///
		   (rarea ci_lower_control ci_upper_control time if treatment == 0, fcolor(green%5) lcolor(green%30) lwidth(medium) lpattern(dash)) ///
		   (line yhat_treat_takeup time if treatment == 1 & take_up == 1, lcolor(blue) lpattern(solid) lwidth(medium) ///
		   legend(label(1 "Treatment with Take-Up"))) ///
		   (line yhat_treat time if treatment == 1 & take_up == 0, lcolor(red) lpattern(solid) lwidth(medium) ///
		   legend(label(2 "Treatment without Take-Up"))) ///
		   (line yhat_control time if treatment == 0, lcolor(green) lpattern(solid) lwidth(medium) ///
		   legend(label(3 "Control"))), xline(10, lpattern(dash)) ///
		   xtitle("Time") ytitle("Average Organic Keywords using Regression") ///*
       xlabel(1 "Aug 2021" 2 "Sep 2021" 3 "Oct 2021" 4 "Nov 2021" 5 "Dec 2021" ///
              6 "Jan 2022" 7 "Feb 2022" 8 "Mar 2022" 9 "Apr 2022" 10 "May 2022" ///
              11 "Jun 2022" 12 "Jul 2022" 13 "Aug 2022" 14 "Sep 2022" 15 "Oct 2022" ///
              16 "Nov 2022" 17 "Dec 2022" 18 "Jan 2023" 19 "Feb 2023" 20 "Mar 2023" ///
              21 "Apr 2023" 22 "May 2023" 23 "Jun 2023" 24 "Jul 2023" 25 "Aug 2023" ///
              26 "Sep 2023" 27 "Oct 2023" 28 "Nov 2023" 29 "Dec 2023" 30 "Jan 2024" ///
              31 "Feb 2024" 32 "Mar 2024" 33 "Apr 2024" 34 "May 2024" 35 "Jun 2024" ///
              36 "Jul 2024" 37 "Aug 2024") ///
       xlabel(, angle(vertical) labsize(vsmall)) ///
	   note("95% CI") ///
			
	gr export reg_avg_organic_keywords.png, width(5000) replace

restore

			*means
preserve

    * Filter for specific data
    keep if Database == "Worldwide"
    keep if Metric == "Organic Keywords"

    * Collapse data to get the mean and standard deviation for each group
    collapse (mean) outcome = month (sd) outcome_sd = month, by(treatment take_up time)

    * Step 2: Calculate standard error and confidence intervals
    gen se = outcome_sd / sqrt(_N)  // Standard error of the mean
    gen lb = outcome - 1.96 * se    // Lower bound of the 95% CI
    gen ub = outcome + 1.96 * se    // Upper bound of the 95% CI

* Step 3: Plotting the data with shaded confidence intervals
twoway (rarea lb ub time if treatment == 1 & take_up == 1, ///
           fcolor(blue%5) lcolor(blue%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if treatment == 1 & take_up == 0, ///
           fcolor(red%5) lcolor(red%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if treatment == 0, ///
           fcolor(green%5) lcolor(green%50) lwidth(medium) lpattern(dash)) ///
       (line outcome time if treatment == 1 & take_up == 1, ///
           lcolor(blue) lpattern(solid) lwidth(medium) legend(label(1 "Treatment with Take-Up"))) ///
       (line outcome time if treatment == 1 & take_up == 0, ///
           lcolor(red) lpattern(solid) lwidth(medium) legend(label(2 "Treatment without Take-Up"))) ///
       (line outcome time if treatment == 0, ///
           lcolor(green) lpattern(solid) lwidth(medium) legend(label(3 "Control"))), ///
       xline(10, lpattern(dash)) ///
       xtitle("Time") ytitle("Average Organic Keywords") ///
       xlabel(1 "Aug 2021" 2 "Sep 2021" 3 "Oct 2021" 4 "Nov 2021" 5 "Dec 2021" ///
              6 "Jan 2022" 7 "Feb 2022" 8 "Mar 2022" 9 "Apr 2022" 10 "May 2022" ///
              11 "Jun 2022" 12 "Jul 2022" 13 "Aug 2022" 14 "Sep 2022" 15 "Oct 2022" ///
              16 "Nov 2022" 17 "Dec 2022" 18 "Jan 2023" 19 "Feb 2023" 20 "Mar 2023" ///
              21 "Apr 2023" 22 "May 2023" 23 "Jun 2023" 24 "Jul 2023" 25 "Aug 2023" ///
              26 "Sep 2023" 27 "Oct 2023" 28 "Nov 2023" 29 "Dec 2023" 30 "Jan 2024" ///
              31 "Feb 2024" 32 "Mar 2024" 33 "Apr 2024" 34 "May 2024" 35 "Jun 2024" ///
              36 "Jul 2024" 37 "Aug 2024") ///
       xlabel(, angle(vertical) labsize(vsmall)) ///
       note("95% CI")

* Step 4: Export the graph
gr export avg_organic_keywords.png, width(5000) replace

restore
}
	*Backlinks
{	
		*reg

preserve
	
	keep if Database == "Worldwide"
	keep if Metric == "Backlinks"
	collapse (mean) month, by(treatment take_up time)

	* Generate predicted values and standard errors for confidence intervals
	regress month time if treatment == 1 & take_up == 1
	predict yhat_treat_takeup, xb
	predict se_fit_treat_takeup, stdp
	gen ci_lower_treat_takeup = yhat_treat_takeup - 1.96 * se_fit_treat_takeup
	gen ci_upper_treat_takeup = yhat_treat_takeup + 1.96 * se_fit_treat_takeup

	regress month time if treatment == 1 & take_up == 0
	predict yhat_treat, xb
	predict se_fit_treat, stdp
	gen ci_lower_treat = yhat_treat - 1.96 * se_fit_treat
	gen ci_upper_treat = yhat_treat + 1.96 * se_fit_treat

	regress month time if treatment == 0
	predict yhat_control, xb
	predict se_fit_control, stdp
	gen ci_lower_control = yhat_control - 1.96 * se_fit_control
	gen ci_upper_control = yhat_control + 1.96 * se_fit_control

	twoway (rarea ci_lower_treat_takeup ci_upper_treat_takeup time if treatment == 1 & take_up == 1, fcolor(blue%5) lcolor(blue%30) lwidth(medium) lpattern(dash)) ///
		   (rarea ci_lower_treat ci_upper_treat time if treatment == 1 & take_up == 0, fcolor(red%5) lcolor(red%30) lwidth(medium) lpattern(dash)) ///
		   (rarea ci_lower_control ci_upper_control time if treatment == 0, fcolor(green%5) lcolor(green%30) lwidth(medium) lpattern(dash)) ///
		   (line yhat_treat_takeup time if treatment == 1 & take_up == 1, lcolor(blue) lpattern(solid) lwidth(medium) ///
		   legend(label(1 "Treatment with Take-Up"))) ///
		   (line yhat_treat time if treatment == 1 & take_up == 0, lcolor(red) lpattern(solid) lwidth(medium) ///
		   legend(label(2 "Treatment without Take-Up"))) ///
		   (line yhat_control time if treatment == 0, lcolor(green) lpattern(solid) lwidth(medium) ///
		   legend(label(3 "Control"))), xline(10, lpattern(dash)) ///
		   xtitle("Time") ytitle("Average Backlinks using Regression") ///*
       xlabel(1 "Aug 2021" 2 "Sep 2021" 3 "Oct 2021" 4 "Nov 2021" 5 "Dec 2021" ///
              6 "Jan 2022" 7 "Feb 2022" 8 "Mar 2022" 9 "Apr 2022" 10 "May 2022" ///
              11 "Jun 2022" 12 "Jul 2022" 13 "Aug 2022" 14 "Sep 2022" 15 "Oct 2022" ///
              16 "Nov 2022" 17 "Dec 2022" 18 "Jan 2023" 19 "Feb 2023" 20 "Mar 2023" ///
              21 "Apr 2023" 22 "May 2023" 23 "Jun 2023" 24 "Jul 2023" 25 "Aug 2023" ///
              26 "Sep 2023" 27 "Oct 2023" 28 "Nov 2023" 29 "Dec 2023" 30 "Jan 2024" ///
              31 "Feb 2024" 32 "Mar 2024" 33 "Apr 2024" 34 "May 2024" 35 "Jun 2024" ///
              36 "Jul 2024" 37 "Aug 2024") ///
       xlabel(, angle(vertical) labsize(vsmall)) ///
	   note("95% CI") ///
			
	gr export reg_avg_backlinks.png, width(5000) replace

restore

			*means
preserve

    * Filter for specific data
    keep if Database == "Worldwide"
    keep if Metric == "Backlinks"

    * Collapse data to get the mean and standard deviation for each group
    collapse (mean) outcome = month (sd) outcome_sd = month, by(treatment take_up time)

    * Step 2: Calculate standard error and confidence intervals
    gen se = outcome_sd / sqrt(_N)  // Standard error of the mean
    gen lb = outcome - 1.96 * se    // Lower bound of the 95% CI
    gen ub = outcome + 1.96 * se    // Upper bound of the 95% CI

* Step 3: Plotting the data with shaded confidence intervals
twoway (rarea lb ub time if treatment == 1 & take_up == 1, ///
           fcolor(blue%5) lcolor(blue%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if treatment == 1 & take_up == 0, ///
           fcolor(red%5) lcolor(red%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if treatment == 0, ///
           fcolor(green%5) lcolor(green%50) lwidth(medium) lpattern(dash)) ///
       (line outcome time if treatment == 1 & take_up == 1, ///
           lcolor(blue) lpattern(solid) lwidth(medium) legend(label(1 "Treatment with Take-Up"))) ///
       (line outcome time if treatment == 1 & take_up == 0, ///
           lcolor(red) lpattern(solid) lwidth(medium) legend(label(2 "Treatment without Take-Up"))) ///
       (line outcome time if treatment == 0, ///
           lcolor(green) lpattern(solid) lwidth(medium) legend(label(3 "Control"))), ///
       xline(10, lpattern(dash)) ///
       xtitle("Time") ytitle("Average Backlinks") ///
       xlabel(1 "Aug 2021" 2 "Sep 2021" 3 "Oct 2021" 4 "Nov 2021" 5 "Dec 2021" ///
              6 "Jan 2022" 7 "Feb 2022" 8 "Mar 2022" 9 "Apr 2022" 10 "May 2022" ///
              11 "Jun 2022" 12 "Jul 2022" 13 "Aug 2022" 14 "Sep 2022" 15 "Oct 2022" ///
              16 "Nov 2022" 17 "Dec 2022" 18 "Jan 2023" 19 "Feb 2023" 20 "Mar 2023" ///
              21 "Apr 2023" 22 "May 2023" 23 "Jun 2023" 24 "Jul 2023" 25 "Aug 2023" ///
              26 "Sep 2023" 27 "Oct 2023" 28 "Nov 2023" 29 "Dec 2023" 30 "Jan 2024" ///
              31 "Feb 2024" 32 "Mar 2024" 33 "Apr 2024" 34 "May 2024" 35 "Jun 2024" ///
              36 "Jul 2024" 37 "Aug 2024") ///
       xlabel(, angle(vertical) labsize(vsmall)) ///
       note("95% CI")

* Step 4: Export the graph
gr export avg_backlinks.png, width(5000) replace

restore
}
	*Ref domains
{
		*reg
preserve
	
	keep if Database == "Worldwide"
	keep if Metric == "Ref domains"
	collapse (mean) month, by(treatment take_up time)

	* Generate predicted values and standard errors for confidence intervals
	regress month time if treatment == 1 & take_up == 1
	predict yhat_treat_takeup, xb
	predict se_fit_treat_takeup, stdp
	gen ci_lower_treat_takeup = yhat_treat_takeup - 1.96 * se_fit_treat_takeup
	gen ci_upper_treat_takeup = yhat_treat_takeup + 1.96 * se_fit_treat_takeup

	regress month time if treatment == 1 & take_up == 0
	predict yhat_treat, xb
	predict se_fit_treat, stdp
	gen ci_lower_treat = yhat_treat - 1.96 * se_fit_treat
	gen ci_upper_treat = yhat_treat + 1.96 * se_fit_treat

	regress month time if treatment == 0
	predict yhat_control, xb
	predict se_fit_control, stdp
	gen ci_lower_control = yhat_control - 1.96 * se_fit_control
	gen ci_upper_control = yhat_control + 1.96 * se_fit_control

	twoway (rarea ci_lower_treat_takeup ci_upper_treat_takeup time if treatment == 1 & take_up == 1, fcolor(blue%5) lcolor(blue%30) lwidth(medium) lpattern(dash)) ///
		   (rarea ci_lower_treat ci_upper_treat time if treatment == 1 & take_up == 0, fcolor(blue%5) lcolor(red%30) lwidth(medium) lpattern(dash)) ///
		   (rarea ci_lower_control ci_upper_control time if treatment == 0, fcolor(green%5) lcolor(green%30) lwidth(medium) lpattern(dash)) ///
		   (line yhat_treat_takeup time if treatment == 1 & take_up == 1, lcolor(blue) lpattern(solid) lwidth(medium) ///
		   legend(label(1 "Treatment with Take-Up"))) ///
		   (line yhat_treat time if treatment == 1 & take_up == 0, lcolor(red) lpattern(solid) lwidth(medium) ///
		   legend(label(2 "Treatment without Take-Up"))) ///
		   (line yhat_control time if treatment == 0, lcolor(green) lpattern(solid) lwidth(medium) ///
		   legend(label(3 "Control"))), xline(10, lpattern(dash)) ///
		   xtitle("Time") ytitle("Average Ref domains using Regression") ///*
       xlabel(1 "Aug 2021" 2 "Sep 2021" 3 "Oct 2021" 4 "Nov 2021" 5 "Dec 2021" ///
              6 "Jan 2022" 7 "Feb 2022" 8 "Mar 2022" 9 "Apr 2022" 10 "May 2022" ///
              11 "Jun 2022" 12 "Jul 2022" 13 "Aug 2022" 14 "Sep 2022" 15 "Oct 2022" ///
              16 "Nov 2022" 17 "Dec 2022" 18 "Jan 2023" 19 "Feb 2023" 20 "Mar 2023" ///
              21 "Apr 2023" 22 "May 2023" 23 "Jun 2023" 24 "Jul 2023" 25 "Aug 2023" ///
              26 "Sep 2023" 27 "Oct 2023" 28 "Nov 2023" 29 "Dec 2023" 30 "Jan 2024" ///
              31 "Feb 2024" 32 "Mar 2024" 33 "Apr 2024" 34 "May 2024" 35 "Jun 2024" ///
              36 "Jul 2024" 37 "Aug 2024") ///
       xlabel(, angle(vertical) labsize(vsmall)) ///
	   note("95% CI") ///
			
	gr export reg_avg_ref_domains.png, width(5000) replace

restore

			*means
preserve

    * Filter for specific data
    keep if Database == "Worldwide"
    keep if Metric == "Ref domains"

    * Collapse data to get the mean and standard deviation for each group
    collapse (mean) outcome = month (sd) outcome_sd = month, by(treatment take_up time)

    * Step 2: Calculate standard error and confidence intervals
    gen se = outcome_sd / sqrt(_N)  // Standard error of the mean
    gen lb = outcome - 1.96 * se    // Lower bound of the 95% CI
    gen ub = outcome + 1.96 * se    // Upper bound of the 95% CI

* Step 3: Plotting the data with shaded confidence intervals
twoway (rarea lb ub time if treatment == 1 & take_up == 1, ///
           fcolor(blue%5) lcolor(blue%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if treatment == 1 & take_up == 0, ///
           fcolor(red%5) lcolor(red%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if treatment == 0, ///
           fcolor(green%5) lcolor(green%50) lwidth(medium) lpattern(dash)) ///
       (line outcome time if treatment == 1 & take_up == 1, ///
           lcolor(blue) lpattern(solid) lwidth(medium) legend(label(1 "Treatment with Take-Up"))) ///
       (line outcome time if treatment == 1 & take_up == 0, ///
           lcolor(red) lpattern(solid) lwidth(medium) legend(label(2 "Treatment without Take-Up"))) ///
       (line outcome time if treatment == 0, ///
           lcolor(green) lpattern(solid) lwidth(medium) legend(label(3 "Control"))), ///
       xline(10, lpattern(dash)) ///
       xtitle("Time") ytitle("Average Ref Domains") ///
       xlabel(1 "Aug 2021" 2 "Sep 2021" 3 "Oct 2021" 4 "Nov 2021" 5 "Dec 2021" ///
              6 "Jan 2022" 7 "Feb 2022" 8 "Mar 2022" 9 "Apr 2022" 10 "May 2022" ///
              11 "Jun 2022" 12 "Jul 2022" 13 "Aug 2022" 14 "Sep 2022" 15 "Oct 2022" ///
              16 "Nov 2022" 17 "Dec 2022" 18 "Jan 2023" 19 "Feb 2023" 20 "Mar 2023" ///
              21 "Apr 2023" 22 "May 2023" 23 "Jun 2023" 24 "Jul 2023" 25 "Aug 2023" ///
              26 "Sep 2023" 27 "Oct 2023" 28 "Nov 2023" 29 "Dec 2023" 30 "Jan 2024" ///
              31 "Feb 2024" 32 "Mar 2024" 33 "Apr 2024" 34 "May 2024" 35 "Jun 2024" ///
              36 "Jul 2024" 37 "Aug 2024") ///
       xlabel(, angle(vertical) labsize(vsmall)) ///
       note("95% CI")

* Step 4: Export the graph
gr export avg_ref_domains.png, width(5000) replace

restore
}
/*
* Tunisia vs Foreign

* Load and prepare the Worldwide dataset
preserve

* Filter for specific data (assuming Metric = "Ref domains" is not in your data, omit this filter)
* Collapse data to get the mean and standard deviation for each group
collapse (mean) outcome = month (sd) outcome_sd = month, by(treatment take_up time)

* Calculate standard error and confidence intervals
gen se = outcome_sd / sqrt(_N)  // Standard error of the mean
gen lb = outcome - 1.96 * se    // Lower bound of the 95% CI
gen ub = outcome + 1.96 * se    // Upper bound of the 95% CI

* Add database identifier for plotting
gen db = "Worldwide"

* Save the processed data
save worldwide_agg.dta, replace
restore

* Load and prepare the TN dataset
preserve

* Collapse data to get the mean and standard deviation for each group
collapse (mean) outcome = month (sd) outcome_sd = month, by(treatment take_up time)

* Calculate standard error and confidence intervals
gen se = outcome_sd / sqrt(_N)  // Standard error of the mean
gen lb = outcome - 1.96 * se    // Lower bound of the 95% CI
gen ub = outcome + 1.96 * se    // Upper bound of the 95% CI

* Add database identifier for plotting
gen db = "tn"

* Save the processed data
save tn_agg.dta, replace
restore

preserve
* Combine the aggregated datasets
use worldwide_agg.dta, clear
append using tn_agg.dta

* Plot the data with shaded confidence intervals
twoway (rarea lb ub time if db == "Worldwide" & treatment == 1 & take_up == 1, ///
           fcolor(none) lcolor(blue%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if db == "Worldwide" & treatment == 1 & take_up == 0, ///
           fcolor(none) lcolor(red%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if db == "Worldwide" & treatment == 0, ///
           fcolor(none) lcolor(green%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if db == "tn" & treatment == 1 & take_up == 1, ///
           fcolor(none) lcolor(cyan%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if db == "tn" & treatment == 1 & take_up == 0, ///
           fcolor(none) lcolor(magenta%50) lwidth(medium) lpattern(dash)) ///
       (rarea lb ub time if db == "tn" & treatment == 0, ///
           fcolor(none) lcolor(orange%50) lwidth(medium) lpattern(dash)) ///
       (line outcome time if db == "Worldwide" & treatment == 1 & take_up == 1, ///
           lcolor(blue) lpattern(solid) lwidth(medium) legend(label(1 "Worldwide Treatment with Take-Up"))) ///
       (line outcome time if db == "Worldwide" & treatment == 1 & take_up == 0, ///
           lcolor(red) lpattern(solid) lwidth(medium) legend(label(2 "Worldwide Treatment without Take-Up"))) ///
       (line outcome time if db == "Worldwide" & treatment == 0, ///
           lcolor(green) lpattern(solid) lwidth(medium) legend(label(3 "Worldwide Control"))) ///
       (line outcome time if db == "tn" & treatment == 1 & take_up == 1, ///
           lcolor(cyan) lpattern(solid) lwidth(medium) legend(label(4 "TN Treatment with Take-Up"))) ///
       (line outcome time if db == "tn" & treatment == 1 & take_up == 0, ///
           lcolor(magenta) lpattern(solid) lwidth(medium) legend(label(5 "TN Treatment without Take-Up"))) ///
       (line outcome time if db == "tn" & treatment == 0, ///
           lcolor(orange) lpattern(solid) lwidth(medium) legend(label(6 "TN Control"))), ///
       xline(10, lpattern(dash)) ///
       xtitle("Time") ytitle("Average Month") ///
       xlabel(1 "Aug 2021" 2 "Sep 2021" 3 "Oct 2021" 4 "Nov 2021" 5 "Dec 2021" ///
              6 "Jan 2022" 7 "Feb 2022" 8 "Mar 2022" 9 "Apr 2022" 10 "May 2022" ///
              11 "Jun 2022" 12 "Jul 2022" 13 "Aug 2022" 14 "Sep 2022" 15 "Oct 2022" ///
              16 "Nov 2022" 17 "Dec 2022" 18 "Jan 2023" 19 "Feb 2023" 20 "Mar 2023" ///
              21 "Apr 2023" 22 "May 2023" 23 "Jun 2023" 24 "Jul 2023" 25 "Aug 2023" ///
              26 "Sep 2023" 27 "Oct 2023" 28 "Nov 2023" 29 "Dec 2023" 30 "Jan 2024" ///
              31 "Feb 2024" 32 "Mar 2024" 33 "Apr 2024" 34 "May 2024" 35 "Jun 2024" ///
              36 "Jul 2024" 37 "Aug 2024") ///
       xlabel(, angle(vertical) labsize(vsmall)) ///
       note("95% CI")

* Export the graph
gr export avg_month.png, width(5000) replace

restore


* Tunisia vs Foreign
* Step 1: Load the dataset
use combined_data.dta, clear

* Step 2: Calculate percentages
gen TN_percentage = .  
gen Foreign_percentage = .

* Compute the overall mean for Tunisia and Worldwide to calculate percentages
by month, sort: egen tunisia_mean = mean(outcome) if Database == "Tunisia"
by month, sort: egen worldwide_mean = mean(outcome) if Database == "Worldwide"

* Calculate TN percentage and Foreign percentage
replace TN_percentage = (tunisia_mean / worldwide_mean) * 100 if Database == "Tunisia"
replace Foreign_percentage = 100 - TN_percentage if Database == "Tunisia"

replace TN_percentage = (outcome / worldwide_mean) * 100 if Database == "Worldwide"
replace Foreign_percentage = 100 - TN_percentage if Database == "Worldwide"

* Step 3: Split the data into Tunisia and Worldwide
preserve

keep if Database == "Tunisia"
save tn_data.dta, replace

restore
keep if Database == "Worldwide"
save worldwide_data.dta, replace

restore

* Step 4: Combine the datasets
use worldwide_data.dta, clear
append using tn_data.dta

* Step 5: Collapse data to get mean and standard deviation for each group
collapse (mean) TN_percentage (sd) TN_percentage_sd = TN_percentage ///
         (mean) Foreign_percentage (sd) Foreign_percentage_sd = Foreign_percentage, by(treatment take_up time)

* Step 6: Calculate standard error and confidence intervals for percentages
gen TN_se = TN_percentage_sd / sqrt(_N)  // Standard error for Tunisia percentage
gen TN_lb = TN_percentage - 1.96 * TN_se  // Lower bound for Tunisia percentage 95% CI
gen TN_ub = TN_percentage + 1.96 * TN_se  // Upper bound for Tunisia percentage 95% CI

gen Foreign_se = Foreign_percentage_sd / sqrt(_N)  // Standard error for Foreign percentage
gen Foreign_lb = Foreign_percentage - 1.96 * Foreign_se  // Lower bound for Foreign percentage 95% CI
gen Foreign_ub = Foreign_percentage + 1.96 * Foreign_se  // Upper bound for Foreign percentage 95% CI

* Step 7: Plotting the data with shaded confidence intervals
twoway (rarea TN_lb TN_ub time if treatment == 1 & take_up == 1, ///
           fcolor(none) lcolor(blue%50) lwidth(medium) lpattern(dash)) ///
       (rarea TN_lb TN_ub time if treatment == 1 & take_up == 0, ///
           fcolor(none) lcolor(red%50) lwidth(medium) lpattern(dash)) ///
       (rarea TN_lb TN_ub time if treatment == 0, ///
           fcolor(none) lcolor(green%50) lwidth(medium) lpattern(dash)) ///
       (rarea Foreign_lb Foreign_ub time if treatment == 1 & take_up == 1, ///
           fcolor(none) lcolor(cyan%50) lwidth(medium) lpattern(dash)) ///
       (rarea Foreign_lb Foreign_ub time if treatment == 1 & take_up == 0, ///
           fcolor(none) lcolor(magenta%50) lwidth(medium) lpattern(dash)) ///
       (rarea Foreign_lb Foreign_ub time if treatment == 0, ///
           fcolor(none) lcolor(orange%50) lwidth(medium) lpattern(dash)) ///
       (line TN_percentage time if treatment == 1 & take_up == 1, ///
           lcolor(blue) lpattern(solid) lwidth(medium) legend(label(1 "TN Treatment with Take-Up"))) ///
       (line TN_percentage time if treatment == 1 & take_up == 0, ///
           lcolor(red) lpattern(solid) lwidth(medium) legend(label(2 "TN Treatment without Take-Up"))) ///
       (line TN_percentage time if treatment == 0, ///
           lcolor(green) lpattern(solid) lwidth(medium) legend(label(3 "TN Control"))) ///
       (line Foreign_percentage time if treatment == 1 & take_up == 1, ///
           lcolor(cyan) lpattern(solid) lwidth(medium) legend(label(4 "Foreign Treatment with Take-Up"))) ///
       (line Foreign_percentage time if treatment == 1 & take_up == 0, ///
           lcolor(magenta) lpattern(solid) lwidth(medium) legend(label(5 "Foreign Treatment without Take-Up"))) ///
       (line Foreign_percentage time if treatment == 0, ///
           lcolor(orange) lpattern(solid) lwidth(medium) legend(label(6 "Foreign Control"))), ///
       xline(10, lpattern(dash)) ///
       xtitle("Time") ytitle("Percentage") ///
       xlabel(1 "Aug 2021" 2 "Sep 2021" 3 "Oct 2021" 4 "Nov 2021" 5 "Dec 2021" ///
              6 "Jan 2022" 7 "Feb 2022" 8 "Mar 2022" 9 "Apr 2022" 10 "May 2022" ///
              11 "Jun 2022" 12 "Jul 2022" 13 "Aug 2022" 14 "Sep 2022" 15 "Oct 2022" ///
              16 "Nov 2022" 17 "Dec 2022" 18 "Jan 2023" 19 "Feb 2023" 20 "Mar 2023" ///
              21 "Apr 2023" 22 "May 2023" 23 "Jun 2023" 24 "Jul 2023" 25 "Aug 2023" ///
              26 "Sep 2023" 27 "Oct 2023" 28 "Nov 2023" 29 "Dec 2023" 30 "Jan 2024" ///
              31 "Feb 2024" 32 "Mar 2024" 33 "Apr 2024" 34 "May 2024" 35 "Jun 2024" ///
              36 "Jul 2024" 37 "Aug 2024") ///
       xlabel(, angle(vertical) labsize(vsmall)) ///
       note("95% CI")

* Export the graph
gr export avg_percentage.png, width(5000) replace




		*focus on treatment & take_up since high %
preserve

keep if treatment == 1 & take_up == 1 & Metric == "Organic Traffic"

collapse (sum) month, by(time Database treatment take_up)


gen row = .
replace row = month if Database == "Worldwide"
replace row = month if Database == "tn"

twoway (line row time if Database == "Worldwide", lcolor(blue) lpattern(solid) lwidth(medium) ///
        legend(label(1 "Rest of the World with take_up"))) ///
       (line row time if Database == "tn", lcolor(red) lpattern(solid) lwidth(medium) ///
        legend(label(2 "Tunisia with take_up"))), ///
       xline(9, lpattern(dash)) xline(27, lpattern(dash)) ///
       text(300 9 "May 2022", size(vsmall) place(n)) ///
       text(300 27 "November 2023", size(vsmall) place(n)) ///
       xtitle("Time") ytitle("Sum of Organic Traffic") ///

graph export rowtakeup_sum_organic_traffic.png, width(5000) replace

restore


preserve

	keep if Metric == "Organic Keywords"
	collapse (sum) month, by(time Database)
	
	reshape wide month, i(time) j(Database) string
	gen row = monthWorldwide - monthtn


	twoway (line row time,lcolor(blue) lpattern(solid) lwidth(medium) ///
			legend(label(1 "Rest of the World"))) ///
		   (line monthtn time,lcolor(red) lpattern(solid) lwidth(medium) ///
			legend(label(2 "Tunisia"))), xline(9, lpattern(dash)) xline(27, lpattern(dash)) ///
			text(300 9 "May 2022", size(vsmall) place(n)) ///
			text(300 27 "November 2023", size(vsmall) place(n)) ///
			xtitle("Time") ytitle("Sum of Organic Keywords") ///
			
	gr export row_sum_organic_keywords.png, width(5000) replace

restore


	
/*
*Worldwide VS tunisia data
	*trendline
preserve
	
	keep if Metric == "Organic Traffic"
	collapse (sum) month, by(time Database)

	twoway (line month time if Database == "tn",lcolor(blue) lpattern(solid) lwidth(medium) ///
			legend(label(1 "Tunisia"))) ///
		   (line month time if Database == "Worldwide",lcolor(red) lpattern(solid) lwidth(medium) ///
			legend(label(2 "Worldwide"))), xline(9, lpattern(dash)) xline(27, lpattern(dash)) ///
			text(300 9 "May 2022", size(vsmall) place(n)) ///
			text(300 27 "November 2023", size(vsmall) place(n)) ///
			xtitle("Time") ytitle("Sum of Organic Traffic") ///
			
	gr export wwvstn_sum_organic_traffic.png, width(5000) replace

restore

preserve
	
	keep if Metric == "Organic Keywords"
	collapse (sum) month, by(time Database)

	twoway (line month time if Database == "tn",lcolor(blue) lpattern(solid) lwidth(medium) ///
			legend(label(1 "Tunisia"))) ///
		   (line month time if Database == "Worldwide",lcolor(red) lpattern(solid) lwidth(medium) ///
			legend(label(2 "Worldwide"))), xline(9, lpattern(dash)) xline(27, lpattern(dash)) ///
			text(300 9 "May 2022", size(vsmall) place(n)) ///
			text(300 27 "November 2023", size(vsmall) place(n)) ///
			xtitle("Time") ytitle("Sum of Organic Keywords") ///
			
	gr export wwvstn_sum_organic_keywords.png, width(5000) replace

restore
*/
