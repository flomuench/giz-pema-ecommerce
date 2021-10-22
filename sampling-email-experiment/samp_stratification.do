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
	blabel(bar, format(%-4.0f) size(vsmall))
	
graph export gender_firms_bar_abs.png, replace
	putdocx paragraph, halign(center)
	putdocx image gender_firms_bar_abs.png, width(4)	

		* female firms by sector
graph hbar (count) if gender == 1, over(sector) ///
	title("Number of female firms across sectors") ///
	blabel(bar, format(%4.0f) size(vsmall)) ///
	ylabel(, labsize(minuscule) format(%-100s))
	
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
	ylabel(, labsize(minuscule) format(%-100s))
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
	
graph export female_firm_Sector.png, replace
	putdocx paragraph, halign(center)
	putdocx image female_firm_Sector.png, width(4)
	
				* male firms by sector
graph hbar (count) if gender == 0, over(Sector) ///
	title("Number of male firms across sectors") ///
	blabel(bar, format(%4.0f) size(vsmall)) ///
	ylabel(, labsize(minuscule) format(%-100s)) ///
	
graph export male_firm_Sector.png, replace
	putdocx paragraph, halign(center)
	putdocx image male_firm_Sector.png, width(4)
	
	
			* sectors, gender, firm size
graph hbar (count), over(size) over(gender, lab(labs(tiny))) over(Sector, lab(labs(tiny))) ///
	title("(Fe-) Male firms by size & sector") ///
	blabel(bar, format(%4.0f) size(half_tiny)) ///
	ylabel(, labsize(minuscule) format(%-100s))
	
graph export gender_Sector_size.png, replace
	putdocx paragraph, halign(center)
	putdocx image gender_Sector_size.png, width(4)
	
		* stratas option 1
egen strata1 = group(Sector size gender)

		* stratas option 2 --> manually define strata such that minimum
			* strata size = 
gen strata2 = .
				* define female categories
replace strata2 = 1 if Sector == 13 & gender == 1 /* "Industries textiles et habillement" */
replace strata2 = 1 if Sector == 12 & gender == 1  /* "Industries du cuir et de la chaussure" */

replace strata2 = 2 if Sector == 1 & gender == 1   /* "Autres industries extractives" */
replace strata2 = 2 if Sector == 11 & gender == 1 /* "Industries agricoles et alimentaires" */
replace strata2 = 2 if Sector == 15 & gender == 1 /* "Travail du bois et fabrication d'articles en bois" */

replace strata2 = 3 if Sector == 9  & gender == 1 /* "Industrie du caoutchouc et des plastiques" */
replace strata2 = 3 if Sector == 8  & gender == 1 /* "Industrie chimique" */
replace strata2 = 3 if Sector == 10 & gender == 1 /* "Industrie du papier et du carton, édition et imprimerie" */

replace strata2 = 4 if Sector ==  2 & gender == 1  /* "Autres industries manufacturières" */
replace strata2 = 4 if Sector ==  5 & gender == 1  /* "Fabrication d'equipements électriques et électroniques" */
replace strata2 = 4 if Sector ==  6 & gender == 1  /* "Fabrication de machines et équipements" */
replace strata2 = 4 if Sector ==  14 & gender == 1 /* "Métallurgie et travail des métaux" */
replace strata2 = 4 if Sector ==  4  & gender == 1 /* "Fabrication d'autres produits non métalliques" */

				* define male categories
					* aggregated male categories
replace strata2 = 5 if Sector == 1 & gender == 0 /* "Autres industries extractives" */
replace strata2 = 5 if Sector == 3 & gender == 0 /* "Cokefaction, raffinage, industries nucléaires" */

replace strata2 = 6 if Sector == 11 & gender == 0 /*  Industries agricoles et alimentaires*/
replace strata2 = 6 if Sector == 15 & gender == 0 /* Travail du bois et fabrication d'articles en bois */

replace strata2 = 7 if Sector == 2 & gender == 0 /* "Autres industries manufacturières" */
replace strata2 = 7 if Sector == 6 & gender == 0 /* "Fabrication de machines et équipements" */
replace strata2 = 7 if Sector == 7 & gender == 0 /* "Fabrication de matériel de transport" */

					* simple male categories
replace strata2 = 8 if Sector == 4  & gender == 0  /* "Fabrication d'autres produits non métalliques" */
replace strata2 = 9 if Sector == 5 & gender == 0   /* "Fabrication d'equipements électriques et électroniques" */
replace strata2 = 10 if Sector == 8 & gender == 0  /* "Industrie chimique" */
replace strata2 = 11 if Sector == 9 & gender == 0   /* "Industrie du caoutchouc et des plastiques" */
replace strata2 = 12 if Sector == 10 & gender == 0    /* "Industrie du papier et du carton, édition et imprimerie" */
replace strata2 = 13 if Sector == 14 & gender == 0    /* "Métallurgie et travail des métaux" */
replace strata2 = 14 if Sector == 13 & gender == 0    /* "Industries textiles et habillement" */
replace strata2 = 15 if Sector == 12 & gender == 0    /* "Industries du cuir et de la chaussure" */
					
					* unknown
replace strata2 = 16 if Sector == 16 & gender == 1    /* "Undefined" */
replace strata2 = 17 if Sector == 16 & gender == 0    /* "Undefined" */


label define strata2_categories 1 "Women - Textiles, leather & shoes" ///
	2 "Women - Primary goods" 3 "Women - Chemical industry"  4 "Women - Metals & Manufacturing" ///
	5 "Men - Extracting industries" 6 "Men - Agriculture" 7 "Men - Manufacturing" ////
	8 "Men - Non-metal products" 9 "Men - Electronics" 10 "Men - Chemical industry" ///
	11 "Men - Plastics" 12 "Men - Paper" 13 "Men - metals" 14 "Men - textiles" 15 "Men - Leather & shoes" ///
	16 "Women - undefined" 17 "Men - undefined"
	
lab values strata2 strata2_categories


***********************************************************************
* 	PART 3: visualise number of observations per strata				  										  
***********************************************************************
		* strata option 1
graph bar (count), over(strata1, sort(1) label(labs(half_tiny))) ///
	title("Number of firms per strata") ///
	subtitle("Strata option 1") ///
	blabel(bar, format(%4.0f) size(tiny)) ///
	ytitle("Number of firms")
graph export firms_per_strata1.png, replace
	putdocx pagebreak
	putdocx paragraph, halign(center)
	putdocx text ("Visualisation of strata size"), bold linebreak(1)
	putdocx image firms_per_strata1.png, width(4)

	
		* strata option 1
graph hbar (count), over(strata2, sort(1) label(labs(vsmall))) ///
	title("Number of firms per strata") ///
	subtitle("Strata option 2") ///
	blabel(bar, format(%4.0f) size(vsmall)) ///
	ytitle("Number of firms")
graph export firms_per_strata2.png, replace
	putdocx pagebreak
	putdocx paragraph, halign(center)
	putdocx text ("Visualisation of strata size"), bold linebreak(1)
	putdocx image firms_per_strata2.png, width(4)

***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
	* save word document with visualisations
putdocx save descriptive-statistics-strata-variables.docx, replace

	* save dta file with stratas
save "giz_contact_list_inter", replace
