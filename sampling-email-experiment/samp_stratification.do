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
	note("Small = 10-30 fte, medium = 31-100 fte, large = 101-240, big > 240 fte.", size(vsmall)) ///
	name(fte_bar_abs)
	
graph bar (percent), over(size) ///
	title("Firms per size category") ///
	ytitle("Percent of firms") ///
	blabel(bar, format(%-4.1f) size(vsmall)) ///
	note("Small = 10-30 fte, medium = 31-100 fte, large = 101-240, big > 240 fte.", size(vsmall)) ///
	name(fte_bar_perc)
	
gr combine fte_hist_abs fte_hist_perc fte_bar_abs fte_bar_perc
graph export fte_hist_bar.png, replace
	putdocx paragraph, halign(center)
	putdocx image fte_hist_bar.png, width(4)
	
	* gender
		* abs number of (fe-) male firms
graph bar (count) , over(gender) ///
	title("(Fe-) male firms") ///
	ytitle("Number of firms") ///
	blabel(bar, format(%-4.0f) size(vsmall)) ///
	name(gender_firms_bar_abs)
graph export gender_firms_bar_abs.png, replace
	putdocx paragraph, halign(center)
	putdocx image gender_firms_bar_abs.png, width(4)	

		* female firms by sector
graph hbar (count) if gender == 1, over(sector) ///
	title("Number of female firms across sectors") ///
	blabel(bar, format(%4.0f) size(vsmall)) ///
	ylabel(, labsize(minuscule) format(%-100s)) ///
	name(female_firm_sector)	
	
graph export female_firm_sector.png, replace
	putdocx paragraph, halign(center)
	putdocx image female_firm_sector.png, width(4)
	
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
putdocx pagebreak
putdocx paragraph
putdocx text ("Conditional distribution of variables"), bold linebreak(1)

histogram fte if fte <= 240, by(sector, title("{bf:sample firm employees") legend(off)) frequency ///
	note("Sample limited to firms with <= 240 employees", size(vsmall)) ///
	addl addlabopts(yvarformat(%-4.0f) mlabsize(vsmall)) ///
	bin(24) xlabel(10(10)240, labsize(vsmall))
graph export hist_by_sect.png, replace
	putdocx paragraph, halign(center)
	putdocx image hist_by_sect.png, width(4)
	
		* gender by sector
			* abs values
graph hbar (count), over(gender, lab(labs(tiny))) over(sector, lab(labs(tiny))) ///
	title("(Fe-) Male firms by sector") ///
	blabel(bar, format(%4.0f) size(vsmall)) ///
	ylabel(, labsize(minuscule) format(%-100s)) ///
	name(sectors_gender_bar_abs1)
	
			* percentage values
graph hbar (percent), over(gender, lab(labs(tiny))) over(sector, lab(labs(tiny))) ///
	title("(Fe-) Male firms by sector") ///
	blabel(bar, format(%4.0f) size(vsmall)) ///
	ylabel(, labsize(minuscule) format(%-75s)) ///
	name(sectors_gender_bar_perc1)	

		* gender, sector, size
graph hbar (count), over(size) over(gender, lab(labs(tiny))) over(sector, lab(labs(tiny))) ///
	title("(Fe-) Male firms by size & sector") ///
	blabel(bar, format(%4.0f) size(half_tiny)) ///
	ylabel(, labsize(minuscule) format(%-100s)) ///
	name(sectors_gender_size)
graph export sectors_gender_size.png, replace
	putdocx paragraph, halign(center)
	putdocx image sectors_gender_size.png, width(4)
	
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
			
	
		* redo visualisation of gender-sector
			* abs values
graph hbar (count), over(gender, lab(labs(tiny))) over(sector, lab(labs(tiny))) ///
	title("(Fe-) Male firms by sector") ///
	blabel(bar, format(%4.0f) size(vsmall)) ///
	ylabel(, labsize(minuscule) format(%-100s)) ///
	name(sectors_gender_bar_abs2)
	
			* percentage values
graph hbar (percent), over(gender, lab(labs(tiny))) over(sector, lab(labs(tiny))) ///
	title("(Fe-) Male firms by sector") ///
	blabel(bar, format(%4.0f) size(vsmall)) ///
	ylabel(, labsize(minuscule) format(%-75s)) ///
	name(sectors_gender_bar_perc2)	
	
gr combine sectors_gender_bar_abs1 sectors_gender_bar_perc1 sectors_gender_bar_abs2 sectors_gender_bar_perc2
graph export sector_gender.png, replace
	putdocx paragraph, halign(center)
	putdocx image sector_gender.png, width(4)
	
			* female firms by sector
graph hbar (count) if gender == 1, over(Sector) ///
	title("Number of female firms across sectors") ///
	blabel(bar, format(%4.0f) size(vsmall)) ///
	ylabel(, labsize(minuscule) format(%-100s)) ///
	name(female_firm_Sector)	
	
graph export female_firm_Sector.png, replace
	putdocx paragraph, halign(center)
	putdocx image female_firm_Sector.png, width(4)
	
				* male firms by sector
graph hbar (count) if gender == 0, over(Sector) ///
	title("Number of male firms across sectors") ///
	blabel(bar, format(%4.0f) size(vsmall)) ///
	ylabel(, labsize(minuscule) format(%-100s)) ///
	name(male_firm_Sector)	
	
graph export male_firm_Sector.png, replace
	putdocx paragraph, halign(center)
	putdocx image male_firm_Sector.png, width(4)
	
	
			* sectors, gender, firm size
graph hbar (count), over(size) over(gender, lab(labs(tiny))) over(Sector, lab(labs(tiny))) ///
	title("(Fe-) Male firms by size & sector") ///
	blabel(bar, format(%4.0f) size(half_tiny)) ///
	ylabel(, labsize(minuscule) format(%-100s)) ///
	name(gender_Sector_size)
graph export gender_Sector_size.png, replace
	putdocx paragraph, halign(center)
	putdocx image gender_Sector_size.png, width(4)
	
	
	
	
		* stratas option 1
egen strata1 = group(Sector size gender)


		* stratas option 2 --> manually define strata such that minimum
			* strata size = 
gen strata2 = .
				* define female categories
replace strata2 = 1 if Sector == "Industries textiles et habillement"  & gender == 1
replace strata2 = 1 if Sector == "Industries du cuir et de la chaussure"  & gender == 1

replace strata2 = 2 if Sector == "Autres industries extractives" & gender == 1
replace strata2 = 2 if Sector == "Industries agricoles et alimentaires" & gender == 1
replace strata2 = 2 if Sector == "Travail du bois et fabrication d'articles en bois" & gender == 1

replace strata2 = 3 if Sector == "Industrie du caoutchouc et des plastiques" & gender == 1
replace strata2 = 3 if Sector == "Industrie chimique" & gender == 1
replace strata2 = 3 if Sector == "Industrie du papier et du carton, édition et imprimerie" & gender == 1

replace strata2 = 4 if Sector ==  "Autres industries manufacturières" & gender == 1
replace strata2 = 4 if Sector ==  "Fabrication d'equipements électriques et électroniques" & gender == 1
replace strata2 = 4 if Sector ==  "Fabrication de machines et équipements" & gender == 1
replace strata2 = 4 if Sector ==  "Métallurgie et travail des métaux" & gender == 1
replace strata2 = 4 if Sector ==  "Fabrication d'autres produits non métalliques" & gender == 1

				
				* define male categories

replace strata2 = 5 if Sector ==  & gender == 0
replace strata2 = 6 if Sector ==  & gender == 0
replace strata2 = 7 if Sector ==  & gender == 0
replace strata2 = 8 if Sector ==  & gender == 0
replace strata2 = 9 if Sector ==  & gender == 0
replace strata2 = 10 if Sector ==  & gender == 0
replace strata2 = 11 if Sector ==  & gender == 0
replace strata2 = 12 if Sector ==  & gender == 0
replace strata2 = 13 if Sector ==  & gender == 0
replace strata2 = 14 if Sector ==  & gender == 0

lab def strata2_categories 



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
	putdocx pagebreak
	putdocx text ("Visualisation of strata size"), bold linebreak(1)
	putdocx paragraph, halign(center)
	putdocx image firms_per_strata1.png, width(4)


***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
	* save word document with visualisations
putdocx save descriptive-statistics-strata-variables.docx, replace

	* save dta file with stratas
save "giz_contact_list_inter", replace
