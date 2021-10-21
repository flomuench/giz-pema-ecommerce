***********************************************************************
* 			sampling email experiment stratification								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)		visualisation of candidate strata variables														  
*	2)		gen stratification dummy
*	3)		visualise number of observations per strata														  
*	4)
*   5) 
*
*																 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_inter.dta
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART START: define the settings as necessary 				  										  *
***********************************************************************
	* import data
use "${samp_intermediate}/giz_contact_list_inter", clear

	* change directory to visualisations
cd "$samp_figures"

	* begin word file for export of all statistics
putdocx begin

***********************************************************************
* 	PART 1: visualisation of candidate strata variables				  										  
***********************************************************************
	* fte - number of full time equivalent employees
			* describe variable distribution
sum fte, d
display "Sample firms have min. `r(min)', max. `r(max)' & median `r(p50)' employees."
putdocx paragraph
putdocx text ("Sample full time equivalent employees descriptive statistics"), linebreak(1) bold
putdocx text ("Sample firms have min. `r(min)', max. `r(max)' & median `r(p50)' employees."), linebreak(1)
mdesc fte
display "We miss employee information for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx text ("We miss employee information for `r(miss)' (`r(percent)'%) out of `r(total)'.")	
			*  plot full sample fte distribution
histogram fte, frequency ///
	title("Sample firm employees") ///
	addl

graph export fte_histogram.png, replace
	putdocx paragraph, halign(center)
	putdocx image fte_histogram.png, width(4)

			* plot fte distribution for 90% of firms
histogram fte if fte <= 240, frequency ///
	title("Sample firm employees") ///
	subtitle("Sample limited to 90% of firms with <= 240 employees") ///
	addl addlabopts(yvarformat(%-4.0f) mlabsize(vsmall)) ///
	bin(24) xlabel(10(10)240, labsize(vsmall)) ///
	name(fte_hist_abs)
	
histogram fte if fte <= 240, percent ///
	title("Sample firm employees") ///
	subtitle("Sample limited to 90% of firms with <= 240 employees") ///
	addl addlabopts(yvarformat(%-4.1f) mlabsize(vsmall)) ///
	bin(24) xlabel(10(10)240, labsize(vsmall)) ///
	name(fte_hist_perc)
	
graph bar (count), over(size) ///
	title("Firms per size category") ///
	ytitle("Number of employees (fte)") ///
	blabel(bar, format(%-4.0f) size(vsmall)) ///
	note("Small = 10-30 fte, medium = 30-100 fte, large = 100-240, big > 240 fte.", size(vsmall)) ///
	name(fte_bar_abs)
	
graph bar (percent), over(size) ///
	title("Firms per size category") ///
	ytitle("Percent of firms") ///
	blabel(bar, format(%-4.1f) size(vsmall)) ///
	note("Small = 10-30 fte, medium = 30-100 fte, large = 100-240, big > 240 fte.", size(vsmall)) ///
	name(fte_bar_perc)
	
gr combine fte_hist_abs fte_hist_perc fte_bar_abs fte_bar_perc
graph export fte_hist_bar.png, replace
	putdocx paragraph, halign(center)
	putdocx image fte_hist_bar.png, width(4)
	
	* sectors
		* firms per sector - absolute number 
mdesc sector
display "We miss sector information for `r(miss)' (`r(percent)'%) out of `r(total)'."
putdocx paragraph
putdocx text ("Sector descriptive statistics"), bold linebreak(1)
putdocx text ("We miss sector information for `r(miss)' (`r(percent)'%) out of `r(total)'.")
	
graph hbar (count), over(sector) ///
	title("Firm distribution across sectors") ///
	blabel(bar, format(%4.0f) size(vsmall)) ///
	ylabel(, labsize(minuscule) format(%-100s)) ///
	name(sectors_bar_abs)
	
		* firms per sector - percentage
graph hbar (percent), over(sector) ///
	title("Firm distribution across sectors") ///
	blabel(bar, format(%4.0f) size(vsmall)) ///
	ylabel(, labsize(minuscule) format(%-100s)) ///
	name(sectors_bar_perc)
	
gr combine sectors_bar_abs sectors_bar_perc
graph export sectors.png, replace
	putdocx paragraph, halign(center)
	putdocx image sectors.png, width(4)
	
	* combinations of variables
		* fte by sector
putdocx paragraph
putdocx text ("Conditional distribution of variables"), bold linebreak(1)

histogram fte if fte <= 240, by(sector) frequency ///
	title("Sample firm employees") ///
	note("Sample limited to firms with <= 240 employees", size(vsmall)) ///
	addl addlabopts(yvarformat(%-4.0f) mlabsize(vsmall)) ///
	bin(24) xlabel(10(10)240, labsize(vsmall)) ///
	legend(off)
graph export hist_by_sect.png, replace
	putdocx paragraph, halign(center)
	putdocx image hist_by_sect.png, width(4)

	
***********************************************************************
* 	PART 1: create dummy variables for each category of factor variables				  										  
***********************************************************************
/* foreach x of varlist sector size governorate gender {
tab `x', gen(`x')
}
*/
***********************************************************************
* 	PART 2: gen stratification dummy				  										  
***********************************************************************
		* generate dummies that contain missing values as a seperate category
			* sector
gen Sector = sector
replace Sector = 16 if sector == .
label define sector_name 16 "undefined", add
lab values Sector sector_name
			
			* gender
/* gen Gender = gender
replace Gender = 2 if gender == .
label def sex 2 "undefined", add
lab val Gender gender
*/
			
		* stratas option 1
egen strata1 = group(sector size gender)


***********************************************************************
* 	PART 3: visualise number of observations per strata				  										  
***********************************************************************#
* how many strata? Depending on number of strata, decide on visualisation
graph bar (count), over(strata1, sort(1) label(labs(half_tiny))) ///
	title("Number of firms per strata") ///
	subtitle("Strata option 1") ///
	blabel(bar, format(%4.0f) size(tiny)) ///
	ytitle("Number of firms")
graph export firms_per_strata1.png, replace
	putdocx paragraph, halign(center)
	putdocx firms_per_strata1.png, width(4)


***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
	* save word document with visualisations
putdocx save descriptive-statistics-strata-variables.docx, replace

	* save dta file with stratas
save "giz_contact_list_inter", replace
