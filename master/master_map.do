***********************************************************************
* 			        building a map, e-commerce			   	          *					  
***********************************************************************
*																	  
*	PURPOSE: file for building a map for webscrapped firms data								  
*																	  
*	OUTLINE: 	PART 1: Install packages		  
*				PART 2: Prepare the data	  
*				PART 3: Draw Map                     											  
*																	  
*	Author:  						    
*	ID variable: 		  					  
*	Requires:  	  										  
*	Creates:  
***********************************************************************
* 	PART 1: 	Install package			  
***********************************************************************
	* install map package
/*
ssc install spmap, replace

ssc install geo2xy, replace     

ssc install palettes, replace        

ssc install colrspace, replace

ssc install schemepack, replace
*/

set graph on
set scheme white_tableau
***********************************************************************
* 	PART 2: 	Prepare the data
************************************************************************
*import excel lat & long
import excel "${map_raw}/ecommerce_adresse_modified_postlocation", firstrow clear

*destring longitude & latitude
destring latitude, generate(new_latitude) 
destring longitude, generate(new_longitude)

*merge with master data to get takeup
merge 1:m id_plateforme using "${master_final}/ecommerce_master_final", keepusing(take_up surveyround district sector treatment)
keep if surveyround == 2
drop _merge surveyround

*fix wrong districts
replace district = "Sousse" if id_plateforme == 493
replace district = "Tunis" if id_plateforme == 650
replace district = "Tunis" if id_plateforme == 712
replace district = "Tunis" if id_plateforme == 911

save "${map_output}/coordinates", replace
clear

*chose directory
cd "${map_output}"

*transform shape data to .dta
spshape2dta TN_regions, replace saving(tunisia)

*use
use "${map_output}/tunisia", replace

***********************************************************************
* 	PART 3: 	Draw map whole Tunisia
***********************************************************************
*initiate PDF
putpdf clear
putpdf begin, pagesize(A3)
putpdf paragraph

putpdf text ("Ecommerce: Firms Distribution Map"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak
putpdf paragraph, halign(center) 
{
	
*draw the map whole tunis by treatment
spmap using tunisia_shp, id(_ID) fcolor(eggshell) point(data("coordinates.dta") xcoord(new_longitude) ycoord(new_latitude) fcolor(red%50 navy%50) size(1.5) ocolor(white ..) osize(*0.5) by(treatment) legenda(on) legcount) ///
	legend(size(*1.8) rowgap(1.5)) ///
	title("ecommerce firms by treatment", size(*1))
graph export map_ecommerceTunisia_treatment.png, replace
putpdf paragraph, halign(center)
putpdf image map_ecommerceTunisia_treatment.png
putpdf pagebreak

*draw the map whole tunis by take-up
spmap using tunisia_shp, id(_ID) fcolor(eggshell) point(data("coordinates.dta") xcoord(new_longitude) ycoord(new_latitude) fcolor(red%50 navy%50) size(1.5) ocolor(white ..) osize(*0.5) by(take_up) select(keep if treatment == 1) legenda(on) legcount) ///
	legend(size(*1.8) rowgap(1.5)) ///
	title("ecommerce firms by take-up", size(*1))
graph export map_ecommerceTunisia_takeup.png, replace
putpdf paragraph, halign(center)
putpdf image map_ecommerceTunisia_takeup.png
putpdf pagebreak

*draw the map whole tunis by pole
	*Industrie 4
spmap using tunisia_shp, id(_ID) fcolor(eggshell) point(data("coordinates.dta") xcoord(new_longitude) ycoord(new_latitude) fcolor(red%50 navy%50) size(1.5) ocolor(white ..) osize(*0.5) by(take_up) select(keep if sector == 4 & treatment == 1) legenda(on) legcount) ///
	legend(size(*1.8) rowgap(1.5)) ///
	title("Industry ecommerce firms by take-up", size(*1))
graph export map_ecommerceTunisiaIndus_takeup.png, replace
putpdf paragraph, halign(center)
putpdf image map_ecommerceTunisiaIndus_takeup.png
putpdf pagebreak

	*Agriculture & Peche 1
spmap using tunisia_shp, id(_ID) fcolor(eggshell) point(data("coordinates.dta") xcoord(new_longitude) ycoord(new_latitude) fcolor(red%50 navy%50) size(1.5) ocolor(white ..) osize(*0.5) by(take_up) select(keep if sector == 1 & treatment == 1) legenda(on) legcount) ///
	legend(size(*1.8) rowgap(1.5)) ///
	title("Agri & Peche ecommerce firms by take-up", size(*1))
graph export map_ecommerceTunisiaAgri_takeup.png, replace
putpdf paragraph, halign(center)
putpdf image map_ecommerceTunisiaAgri_takeup.png
putpdf pagebreak

	*Commerce International 3
spmap using tunisia_shp, id(_ID) fcolor(eggshell) point(data("coordinates.dta") xcoord(new_longitude) ycoord(new_latitude) fcolor(red%50 navy%50) size(1.5) ocolor(white ..) osize(*0.5) by(take_up) select(keep if sector == 3 & treatment == 1) legenda(on) legcount) ///
	legend(size(*1.8) rowgap(1.5)) ///
	title("Commerce Int ecommerce firms by take-up", size(*1))
graph export map_ecommerceTunisiaComm_takeup.png, replace
putpdf paragraph, halign(center)
putpdf image map_ecommerceTunisiaComm_takeup.png
putpdf pagebreak

	*Services 5
spmap using tunisia_shp, id(_ID) fcolor(eggshell) point(data("coordinates.dta") xcoord(new_longitude) ycoord(new_latitude) fcolor(red%50 navy%50) size(1.5) ocolor(white ..) osize(*0.5) by(take_up) select(keep if sector == 5 & treatment == 1) legenda(on) legcount) ///
	legend(size(*1.8) rowgap(1.5)) ///
	title("Service ecommerce firms by take-up", size(*1))
graph export map_ecommerceTunisiaService_takeup.png, replace
putpdf paragraph, halign(center)
putpdf image map_ecommerceTunisiaService_takeup.png
putpdf pagebreak

	*Artisanat 2
spmap using tunisia_shp, id(_ID) fcolor(eggshell) point(data("coordinates.dta") xcoord(new_longitude) ycoord(new_latitude) fcolor(red%50 navy%50) size(1.5) ocolor(white ..) osize(*0.5) by(take_up) select(keep if sector == 2 & treatment == 1) legenda(on) legcount) ///
	legend(size(*1.8) rowgap(1.5)) ///
	title("Artisanat ecommerce firms by take-up", size(*1))
graph export map_ecommerceTunisiaEnergy_takeup.png, replace
putpdf paragraph, halign(center)
putpdf image map_ecommerceTunisiaEnergy_takeup.png
putpdf pagebreak

	*TIC 6
spmap using tunisia_shp, id(_ID) fcolor(eggshell) point(data("coordinates.dta") xcoord(new_longitude) ycoord(new_latitude) fcolor(red%50 navy%50) size(1.5) ocolor(white ..) osize(*0.5) by(take_up) select(keep if sector == 6 & treatment == 1) legenda(on) legcount) ///
	legend(size(*1.8) rowgap(1.5)) ///
	title("TIC ecommerce firms by take-up", size(*1))
graph export map_ecommerceTunisiaInfo_takeup.png, replace
putpdf paragraph, halign(center)
putpdf image map_ecommerceTunisiaInfo_takeup.png
putpdf pagebreak

***********************************************************************
* 	PART 4: 	Draw map parts of tunisia
***********************************************************************
*transform shape data to .dta
spshape2dta TN_districts, replace saving(tunisia_regions)

*use
use "${map_output}/tunisia_regions", replace

*extract labels that need to be on seperate .dta
preserve

keep _ID _CY _CX dis_en
compress
keep if dis_en == "Tunis 1" | dis_en == "Tunis 2" |  dis_en == "Ariana" | dis_en == "Ben Arous" | dis_en == "Mannouba"
replace _CX = _CX - 0.04 if dis_en=="Tunis 1"  // Tunis1 label
replace _CY = _CY - 0.025 if dis_en=="Tunis 2"  // Tunis 2 label

save tunis_labels, replace

restore

*Tunis/Ariana/Ben Arous
spmap using tunisia_regions_shp if _ID == 1 | _ID == 2 | _ID == 3| _ID == 4 | _ID == 5, id(_ID) fcolor(eggshell) point(data("coordinates.dta") xcoord(new_longitude) ycoord(new_latitude) fcolor(red%50 navy%50) ocolor(white ..) select(keep if district == "Tunis" | district == "Ariana" | district == "Ben Arous") by(treatment) size(v.Small ..) legenda(on) legcount) ///
	legend(size(*1.8) rowgap(1.5)) ///
	label(data(tunis_labels) x(_CX) y(_CY) label(dis_en)) ///
	title("Grand Tunis consorita firms by treatment", size(*1))
graph export map_ecommerceTunis_treatment.png, replace
putpdf paragraph, halign(center)
putpdf image map_ecommerceTunis_treatment.png
putpdf pagebreak

*Sfax
spmap using tunisia_regions_shp if _ID == 17 | _ID == 18, id(_ID) fcolor(eggshell) point(data("coordinates.dta") xcoord(new_longitude) ycoord(new_latitude) fcolor(red%50 navy%50) ocolor(white ..) select(keep if district == "Sfax") by(treatment) size(Small ..) legenda(on) legcount) ///
	legend(pos(5) size(*1.8) rowgap(1.5)) ///
	title("Sfax consorita firms by treatment", size(*1))
graph export map_ecommerceSfax_treatment.png, replace
putpdf paragraph, halign(center)
putpdf image map_ecommerceSfax_treatment.png
putpdf pagebreak

*Sousse
spmap using tunisia_regions_shp if _ID == 14, id(_ID) fcolor(eggshell) point(data("coordinates.dta") xcoord(new_longitude) ycoord(new_latitude) fcolor(red%50 navy%50) ocolor(white ..) select(keep if district == "Sousse") by(treatment) size(Small ..) legenda(on) legcount) ///
	legend(size(*1.7) rowgap(1.5)) ///
	title("Sousse consorita firms by treatment", size(*1))
graph export map_ecommerceSousse_treatment.png, replace
putpdf paragraph, halign(center)
putpdf image map_ecommerceSousse_treatment.png
putpdf pagebreak

*Nabeul
spmap using tunisia_regions_shp if _ID == 6 | _ID == 7, id(_ID) fcolor(eggshell) point(data("coordinates.dta") xcoord(new_longitude) ycoord(new_latitude) fcolor(red%50 navy%50) ocolor(white ..) select(keep if district == "Nabeul") by(treatment) size(Small ..) legenda(on) legcount) ///
	legend(pos(5) size(*1.8) rowgap(1.5)) ///
	title("Nabeul consorita firms by treatment", size(*1))
graph export map_ecommerceNabeul_treatment.png, replace
putpdf paragraph, halign(center)
putpdf image map_ecommerceNabeul_treatment.png

putpdf save "ecommerce_firmsmap", replace
}