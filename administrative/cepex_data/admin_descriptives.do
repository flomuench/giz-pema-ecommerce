***********************************************************************
* 			Descriptive Statistics in data admin					  *					  
***********************************************************************
*																	  
*	PURPOSE: Understand the structure of the data from cepex					  
*																	  
*	OUTLINE: 	
*				PART 1: Statistics for e-commerce	
*				PART 2: Statistics for consortia														
*																	  
*	Author:  	Ayoub Chamakhi							    
*	ID variable: id_platforme		  					  
*	Requires:  	 multiple frames
*	 
*										  
***********************************************************************

**1. Check completeness: For how company do we have admin data and is it equal over the years?


***2. Do we have equal data completeness (% of companies) in treatment and control group


***3. do we similar coverage across sectors, firmsize 
***********************************************************************
*	PART 1: Statistics for e-commerce  			
***********************************************************************
	* create word document

cd "${cp_output}"

putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("CEPEX Data: Ecommerce revenue of firms from export"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak

*Check completeness
frame change completness_ecom
count if matricule_fiscale !=""
gen share= (`r(N)'/236)*100
graph bar share, blabel(total, format(%9.2fc)) ///
	title("Export data available for ecommerce firms") note("Date: `c(current_date)'") ///
	ytitle("Percentage") ///
	ylabel(0(10)100, nogrid)
graph export cprate_ecommerce.png, replace
putpdf paragraph, halign(center)
putpdf image cprate_ecommerce.png
putpdf pagebreak
drop share

*completness by status
frame change completness_status_ecom
*Genarte shre of answers
count if treatment==0
gen share1= (`r(N)'/148)*100
count if treatment==1
gen share2= (`r(N)'/148)*100

* Share of firms that started the survey
graph bar share*, blabel(total, format(%9.2fc)) ///
	legend (pos(6) row(6) label(1 "control") label (2 "treatment")) ///
	title("completness by status - ecommerce") note("Date: `c(current_date)'") ///
	ytitle("Percentage") ///
	ylabel(0(10)100, nogrid) 
graph export status_ecom.png, replace
putpdf paragraph, halign(center)
putpdf image status_ecom.png
putpdf pagebreak

drop share1 share2

*Evolution over the years
frame change evolution_ecom
twoway line VALEUR Year, ///
    xtitle("Year") ytitle("Value") ///
    title("Ecommerce mean value Evolution") ///
    legend(off)
graph export cpevolution_ecommerce.png, replace
putpdf paragraph, halign(center)
putpdf image cpevolution_ecommerce.png
putpdf pagebreak

*value by sector
frame change sector_ecom
sum VALEUR, d
graph bar VALEUR, over(sector, sort(VALEUR))  scale(*.75) ///
    blabel(total, format(%9.2fc)) ///
	title("Export mean value per sector - ecommerce") ///
	yline(`r(p50)', lpattern(dash)) ///
	text(`r(p50)'  0.1 "Median", size(vsmall) place(n)) ///
	ytitle("mean value in TND")
	
gr export export_by_sector_ecom.png, replace
putpdf paragraph, halign(center) 
putpdf image export_by_sector_ecom.png
putpdf pagebreak


frame change subsector_ecom
sum VALEUR, d
graph hbar VALEUR , over(subsector, sort(VALEUR))  scale(*.5) ///
    blabel(total, format(%9.2fc)) ///
	yline(`r(p50)', lpattern(dash)) ///
	text(`r(p50)'  -1 "Median", size(vsmall) place(n)) ///
	title("Export value per subsector - ecommerce") ///
	ytitle("mean value in TND")

gr export export_by_subsector_ecom.png, replace
putpdf paragraph, halign(center) 
putpdf image export_by_subsector_ecom.png
putpdf pagebreak

putpdf save "${cp_output}/CEPEX_data_descriptives_ecommerce", replace

***********************************************************************
*	PART 2: Statistics for consortia  			
***********************************************************************
cd "${consortia_output}"


putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("CEPEX Data: Consortia revenue of firms from export"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak

*Check completeness
frame change completness_consortia
count if matricule_fiscale !=""
gen share= (`r(N)'/176)*100
graph bar share, blabel(total, format(%9.2fc)) ///
	title("Export data available for consortia firms") note("Date: `c(current_date)'") ///
	ytitle("Percentage") ///
	ylabel(0(10)100, nogrid)
graph export cprate_consortia.png, replace
putpdf paragraph, halign(center)
putpdf image cprate_consortia.png
putpdf pagebreak
drop share

*completness by status
frame change completness_status_consortia
*Genarte shre of answers
count if treatment==0
gen share1= (`r(N)'/32)*100
count if treatment==1
gen share2= (`r(N)'/32)*100

* Share of firms that started the survey
graph bar share*, blabel(total, format(%9.2fc)) ///
	legend (pos(6) row(6) label(1 "control") label (2 "treatment")) ///
	title("completness by status - consortia") note("Date: `c(current_date)'") ///
	ytitle("Percentage") ///
	ylabel(0(10)100, nogrid) 
graph export status_consortia.png, replace
putpdf paragraph, halign(center)
putpdf image status_consortia.png
putpdf pagebreak

drop share1 share2

*Evolution over the years
frame change evolution_consortia
twoway line VALEUR Year, ///
    xtitle("Year") ytitle("mean value") ///
    title("Consortia Value Evolution") ///
    legend(off)
graph export cpevolution_consortia.png, replace
putpdf paragraph, halign(center)
putpdf image cpevolution_consortia.png
putpdf pagebreak

*value by pole
frame change sector_consortia
sum VALEUR, d
graph bar VALEUR, over(pole, sort(VALEUR))  scale(*.75) ///
    blabel(total, format(%9.2fc)) ///
	yline(`r(p50)', lpattern(dash)) ///
	text(`r(p50)'  0.1 "Median", size(vsmall) place(n)) ///
	title("Export value per pole - consortia") ///
	ytitle("mean value in TND")
	
gr export export_by_sector_consortia.png, replace
putpdf paragraph, halign(center) 
putpdf image export_by_sector_consortia.png
putpdf pagebreak

putpdf save "${consortia_output}/CEPEX_data_descriptives_consortia", replace
