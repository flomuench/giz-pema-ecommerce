***********************************************************************
* 			Descriptive Statistics in master file for endline survey  *					  
***********************************************************************
*																	  
*	PURPOSE: Understand the structure of the data from the different survey.					  
*																	  
*	OUTLINE: 	PART 1: Baseline and take-up
*				PART 2: Mid-line	  
*				PART 3: Endline 
*				PART 4: Intertemporal descriptive statistics															
*																	  
*	Author:  	Fabian Scheifele & Kaïs Jomaa							    
*	ID variable: id_platforme		  					  
*	Requires:  	 ecommerce_data_final.dta
***********************************************************************
* 	PART 1: Midline and take-up statistics
***********************************************************************
use "${master_final}/ecommerce_master_final", clear
set graphics on		
		* change directory to regis folder for merge with regis_final
cd "${master_gdrive}/output"
set scheme burd

putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("E-commerce: Endline statistics"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak


putpdf paragraph, halign(center) 

local take_up take_up_for take_up_std take_up_seo take_up_smo take_up_smads take_up_website take_up_heber

***********************************************************************
* 	PART 2: The company
***********************************************************************
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 2: The company"), bold
{
*Number of validated
graph bar (count) attest if surveyround==3, over(treatment) blabel(total, format(%9.0fc)) ///
	title("Number of companies that have validated their answers", pos(12)) note("Date: `c(current_date)'") ///
	ytitle("Number of entries")
graph export valide.png, width(5000) replace
putpdf paragraph, halign(center)
putpdf image valide.png, width(5000)
putpdf pagebreak

graph bar (sum) el_refus if surveyround==1, over(treatment) blabel(total, format(%9.0fc)) ///
	title("Number of companies that refused to answer the survey", pos(12)) note("Date: `c(current_date)'") ///
	ytitle("Number of entries")
graph export refus.png, width(5000) replace
putpdf paragraph, halign(center)
putpdf image refus.png, width(5000)
putpdf pagebreak

graph hbar take_up_for take_up_std take_up_seo take_up_smo take_up_smads take_up_website take_up_heber if treatment == 1 & surveyround==1, ///
    title("Average take-up for each activity", pos(12)) ///
	legend (pos(6) row(6) label (1 "Take up for classroom training") label(2 "Take up for student intervention") ///
	label(3 "Take up for SEO intervention") label(4 "Take up for social medias organic") label(5 "Take up for social medias ads") label(6 "Take up for website intervention") label(7 "Bought the website")) 
    gr export el_take_up.png, replace
    putpdf paragraph, halign(center)
    putpdf image el_take_up.png
    putpdf pagebreak
	
*Number of product innovation	
 
 foreach x of local take_up { 
    graph box inno_produit if inno_produit > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
    title("Number good or service innovation", pos(12))
    gr export el_inno_produit_box_`x'.png, replace
    putpdf paragraph, halign(center)
    putpdf image el_inno_produit_box_`x'.png
    putpdf pagebreak
}

 	foreach x of local take_up{
	 graph box inno_produit if inno_produit > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Number good or service innovation", pos(12))
	gr export el_inno_produit_box_`x'.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_inno_produit_box_`x'.png
	putpdf pagebreak
}	
 	
	foreach x of local take_up{
twoway (kdensity inno_produit if treatment == 0 & inno_produit > 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity inno_produit if treatment == 1 & `x'==0 & inno_produit > 0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity inno_produit if treatment == 1 & `x'==1 & inno_produit > 0 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Number good or service innovation", pos(12)) ///
	   xtitle("Number good or service innovation",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_inno_produit_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_inno_produit_kdens_`x'.png, width(5000)
putpdf pagebreak
}

    * variable employees
 	foreach x of local take_up{
graph box fte if fte > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Number of employees", pos(12))
gr export el_fte_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_fte_box_`x'.png
putpdf pagebreak
}

	foreach x of local take_up{
twoway (kdensity fte if treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity fte if treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity fte if treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Number of full-time employees", pos(12)) ///
	   xtitle("Number of full-time employees",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_fte_treat_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_fte_treat_kdens_`x'.png, width(5000)
putpdf pagebreak
}
    * Number of female employees
 	foreach x of local take_up{	
 graph box car_carempl_div1 if car_carempl_div1 > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Number of female employees", pos(12))
gr export el_car_carempl_div1_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div1_box_`x'.png
putpdf pagebreak
}

	foreach x of local take_up{
twoway (kdensity car_carempl_div1 if treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity car_carempl_div1 if treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity car_carempl_div1 if treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Number of female employees", pos(12)) ///
	   xtitle("Number of female employees",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_car_carempl_div1_treat_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div1_treat_kdens_`x'.png, width(5000)
putpdf pagebreak
}	
    * Number of young employees (less than 36 years old)
 	foreach x of local take_up{	
 graph box car_carempl_div2 if car_carempl_div2 > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Number of young employees (less than 36 yo)", pos(12))
gr export el_car_carempl_div2_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div2_box_`x'.png
putpdf pagebreak
}

	foreach x of local take_up{
twoway (kdensity car_carempl_div2 if treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity car_carempl_div2 if treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity car_carempl_div2 if treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Number of female employees", pos(12)) ///
	   xtitle("Number of female employees",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_car_carempl_div2_treat_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div2_treat_kdens_`x'.png, width(5000)
putpdf pagebreak
}
    * Number of young employees (less than 24 years old)
 	foreach x of local take_up{	
 graph box car_carempl_div3 if car_carempl_div3 > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Number of young employees (less than 24 yo)", pos(12))
gr export el_car_carempl_div3_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div3_box_`x'.png
putpdf pagebreak
}

	foreach x of local take_up{
twoway (kdensity car_carempl_div3 if treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity car_carempl_div3 if treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity car_carempl_div3 if treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Number of female employees", pos(12)) ///
	   xtitle("Number of female employees",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_car_carempl_div3_treat_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div3_treat_kdens_`x'.png, width(5000)
putpdf pagebreak
}
}
***********************************************************************
* 	PART 3: Digital Technology Adoption
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 3: Digital Technology Adoption"), bold
{
	*Variable présence digitale
 	foreach x of local take_up{
graph hbar (mean) dig_presence1 dig_presence2 dig_presence3 dig_presence4 if surveyround == 3, over(`x') percent blabel(total, format(%9.1fc)) ///
title("Presence on communication channels", position(12)) ///
legend (pos(6) row(6) label (1 "Website") label(2 "Social Medias") ///
label(3 "Marketplace") label(4 "On site")) 
gr export el_mark_online_freq_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_mark_online_freq_`x'.png, width(5000)
putpdf pagebreak
}

 	foreach x of local take_up{
betterbar dig_presence1 dig_presence2 dig_presence3 if surveyround == 3, over(`x') ci barlab ///
	title("Presence on communication channels") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_presence_digital_`x'.png, replace 
putpdf paragraph, halign(center) 
putpdf image el_presence_digital_`x'.png
putpdf pagebreak
}
	*Variable paiement digital
		 	foreach x of local take_up{
	graph hbar (mean) dig_payment1 dig_payment2 dig_payment3 if surveyround == 3, over(`x') percent blabel(total, format(%9.1fc)) ///
title("Means of payment", position(12)) ///
legend (pos(6) row(6) label (1 "Offline payment option") label(2 "Possibility to pay/order on website") ///
label(3 "Possibility to pay/order through a plateform")) 
graph export el_paiement_digital_freq_`x'.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_paiement_digital_freq_`x'.png, width(5000)
putpdf pagebreak
}

	 	foreach x of local take_up{
betterbar dig_payment1 dig_payment2 dig_payment3 if surveyround == 3, over(`x') ci barlab ///
	title("Means of payment") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_paiement_digital_`x'.png, replace 
putpdf paragraph, halign(center) 
putpdf image el_paiement_digital_`x'.png
putpdf pagebreak
}
	*More benefits with online selling

graph pie if surveyround == 3, over (dig_prix) by(treatment) plabel(_all percent, format(%9.0f) size(medium)) graphregion(fcolor(none) lcolor(none)) ///
   bgcolor(white) legend(pos(6)) ///
   title("Higher margins with online sales" ,size(medium) pos(12))
   gr export el_dig_prix_pie_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_prix_pie_treat.png, width(5000)
	putpdf pagebreak
	
	 	foreach x of local take_up{
graph pie if surveyround == 3, over(dig_prix) by(`x') plabel(_all percent, format(%9.0f) size(medium)) graphregion(fcolor(none) lcolor(none)) ///
   bgcolor(white) legend(pos(6)) ///
   title("Higher margins with online sales", pos(12))
   gr export el_dig_prix_pie_`x'.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_prix_pie_`x'.png
	putpdf pagebreak
}		


	 * variable dig_revenues_ecom
	  	foreach x of local take_up{
 graph box dig_revenues_ecom if dig_revenues_ecom> 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Online sales as % of total sales", pos(12))
gr export el_dig_revenues_ecom_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_dig_revenues_ecom_box_`x'.png
putpdf pagebreak
}

	foreach x of local take_up{
twoway (kdensity dig_revenues_ecom if treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity dig_revenues_ecom if treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity dig_revenues_ecom if treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Online sales as % of total sales", pos(12)) ///
	   xtitle("% of total sales",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_dig_revenues_ecom_treat_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_dig_revenues_ecom_treat_kdens_`x'.png, width(5000)
putpdf pagebreak
}

    *Nombre d'émployés chargés activités en ligne

 	foreach x of local take_up{
 graph box dig_empl if dig_empl > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Number of employees in charge of online activities", pos(12))
gr export el_dig_empl_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_dig_empl_box_`x'.png
putpdf pagebreak
}

	foreach x of local take_up{
twoway (kdensity dig_empl if treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity dig_empl if treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity dig_empl if treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Number of employees in charge of online activities", pos(12)) ///
	   xtitle("Number of employees",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_dig_empl_treat_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_dig_empl_treat_kdens_`x'.png, width(5000)
putpdf pagebreak
}
    *Investissement dans les activités de marketing en ligne en 2023 et 2024
 	foreach x of local take_up{
 graph box dig_invest if dig_invest > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Investment in online marketing activities in 2023 and 2024", pos(12))
gr export el_dig_invest_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_dig_invest_box_`x'.png
putpdf pagebreak
}

	foreach x of local take_up{
twoway (kdensity dig_invest if dig_invest< 10000 & treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity dig_invest if dig_invest< 10000 & treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity dig_invest if dig_invest< 10000 & treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Investment in online marketing activities in 2023 and 2024", pos(12) size(medium)) ///
	   xtitle("Amount invested in TND",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_dig_invest_treat_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_dig_invest_treat_kdens_`x'.png, width(5000)
putpdf pagebreak
}

*Investissement dans les activités de marketing hors ligne en 2023 et 2024
 	foreach x of local take_up {	
 graph box mark_invest if mark_invest > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Investment in offline marketing activities in 2023 and 2024", pos(12))
gr export el_mark_invest_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_mark_invest_box_`x'.png
putpdf pagebreak
}

	foreach x of local take_up{
twoway (kdensity mark_invest if mark_invest< 10000 & treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity mark_invest if mark_invest< 10000 & treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity mark_invest if mark_invest< 10000 & treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Investment in offline marketing activities in 2023 and 2024", pos(12) size(medium)) ///
	   xtitle("Amount invested in TND",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_mark_invest_treat_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_mark_invest_treat_kdens_`x'.png, width(5000)
putpdf pagebreak
}
}
***********************************************************************
* 	PART 4: Digital Technology Perception
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 4: Digital Technology Perception"), bold

	*Barriers to digital adoption
 	foreach x of local take_up{
graph hbar (mean) dig_barr1 dig_barr2 dig_barr3 dig_barr4 dig_barr5 dig_barr6 if surveyround == 3, percentage over(`x') blabel(total, format(%9.2fc) gap(-0.2)) ///
	title("Barriers to technology adoption") ///
	legend (pos(6) row(6) label (1 "Absence/uncertainty of online demand") label(2 "Lack of skilled staff") ///
	label(3 "Inadequate infrastructure") label(4 "Cost is too high") ///
	label(5 "Restrictive government regulations") label(6 "Resistance to change"))  ///
	ylabel(0(10)40, nogrid)    
gr export el_barriers_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_barriers_`x'.png
putpdf pagebreak
}

***********************************************************************
* 	PART 5: Export
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 5: Export"), bold
{
	*No of export destinations
 	foreach x of local take_up{
 graph box exp_pays if exp_pays > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Number of export countries", pos(12))
gr export el_exp_pays_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_exp_pays_box_`x'.png
putpdf pagebreak
}	

foreach x of local take_up{
twoway (kdensity exp_pays if exp_pays <90 & treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity exp_pays if exp_pays <90 & treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity exp_pays if exp_pays <90 & treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Number of export countries", pos(12) size(medium)) ///
	   xtitle("Number of countries",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_exp_pays_treat_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_exp_pays_treat_kdens_`x'.png, width(5000)
putpdf pagebreak
}
		*No of international orders
 	foreach x of local take_up{	
 graph box clients_b2c if clients_b2c > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Number of international orders", pos(12))
gr export el_clients_b2c_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_clients_b2c_box_`x'.png
putpdf pagebreak
}

foreach x of local take_up{
twoway (kdensity clients_b2c if clients_b2c < 200 & treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity clients_b2c if clients_b2c < 200 & treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity clients_b2c if clients_b2c < 200 & treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Number of international orders/ clients", pos(12) size(medium)) ///
	   xtitle("Number of orders",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_clients_b2c_treat_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_clients_b2c_treat_kdens_`x'.png, width(5000)
putpdf pagebreak
}
*No of international companies
 	foreach x of local take_up{	
 graph box clients_b2b if clients_b2b > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Number of international companies", pos(12))
gr export el_clients_b2b_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_clients_b2b_box_`x'.png
putpdf pagebreak
}	
 	foreach x of local take_up{	
twoway (kdensity clients_b2b if clients_b2b < 60 & treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity clients_b2b if clients_b2b < 60 & treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity clients_b2b if clients_b2b < 60 & treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Number of international companies", pos(12) size(medium)) ///
	   xtitle("Number of companies",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_clients_b2b_treat_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_clients_b2b_treat_kdens_`x'.png, width(5000)
putpdf pagebreak
}
	* Export trhough digital channel
 	foreach x of local take_up{
graph pie if surveyround == 3, over(exp_dig) by(`x') plabel(_all percent, format(%9.0f) size(medium)) graphregion(fcolor(none) lcolor(none)) ///
   bgcolor(white) legend(pos(6)) ///
   title("Exporting through digital presence", pos(12))
   gr export el_exp_dig_pie_`x'.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_exp_dig_pie_`x'.png
	putpdf pagebreak
}	
}
***********************************************************************
* 	PART 6: Accounting
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 6: Accounting"), bold
{


*Chiffre d'affaires total en TND 
betterbar comp_ca2024 comp_ca2023 comp_ca2020 if surveyround !=2, over(treatment) barlab ci ///
	title("Total turnover in dt", pos(12))
gr export el_total_turnover.png, replace
putpdf paragraph, halign(center) 
putpdf image el_total_turnover.png
putpdf pagebreak

betterbar w99_comp_ca2024 w99_comp_ca2023 w99_comp_ca2020 if surveyround !=2, over(treatment) barlab ci ///     
	title("Total turnover in dt, ihs transformed win. 99th", pos(12))
gr export el_ihs_ca99.png, replace
putpdf paragraph, halign(center) 
putpdf image el_ihs_ca99.png
putpdf pagebreak

betterbar w97_comp_ca2024 w97_comp_ca2023 w97_comp_ca2020 if surveyround !=2, over(treatment) barlab ci ///     
	title("Total turnover in dt, ihs transformed win. 97th", pos(12))
gr export el_ihs_ca97.png, replace
putpdf paragraph, halign(center) 
putpdf image el_ihs_ca97.png
putpdf pagebreak

betterbar w95_comp_ca2024 w95_comp_ca2023 w95_comp_ca2020 if surveyround !=2, over(treatment) barlab ci ///     
	title("Total turnover in dt, ihs transformed win. 95th", pos(12))
gr export el_ihs_ca95.png, replace
putpdf paragraph, halign(center) 
putpdf image el_ihs_ca95.png
putpdf pagebreak

    * Chiffre d'affaires total en dt en 2023 
 	foreach x of local take_up{	
 graph box comp_ca2023 if comp_ca2023 > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Total turnover in 2023 in dt", pos(12))
gr export el_comp_ca2023_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_comp_ca2023_box_`x'.png
putpdf pagebreak
}

 	foreach x of local take_up{	
twoway (kdensity comp_ca2023 if treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity comp_ca2023 if treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity comp_ca2023 if treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Total turnover in 2023", pos(12)) ///
	   xtitle("Total turnover",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_comp_ca2023_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_comp_ca2023_kdens_`x'.png, width(5000)
putpdf pagebreak
}
    * Chiffre d'affaires total en dt en 2024 
 	foreach x of local take_up{
 graph box comp_ca2024 if comp_ca2024 > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Total turnover in 2024 in dt", pos(12))
gr export el_comp_ca2024_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_comp_ca2024_box_`x'.png
putpdf pagebreak
}

 	foreach x of local take_up{	
twoway (kdensity comp_ca2024 if treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity comp_ca2024 if treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity comp_ca2024 if treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Total turnover in 2024", pos(12)) ///
	   xtitle("Total turnover",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_comp_ca2024_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_comp_ca2024_kdens_`x'.png, width(5000)
putpdf pagebreak
}

*Chiffre d'affaires export en TND 
betterbar compexp_2024 compexp_2023 compexp_2020 if surveyround !=2, over(treatment) barlab ci ///     
	title("Export turnover in dt", pos(12))
gr export el_total_export_turnover.png, replace
putpdf paragraph, halign(center) 
putpdf image el_total_export_turnover.png
putpdf pagebreak

betterbar ihs_exports99_2024 ihs_exports99_2023 ihs_exports99_2020 if surveyround !=2, over(treatment) barlab ci ///     
	title("Export turnover in dt, ihs transformed win. 99th", pos(12))
gr export el_ihs_exports99.png, replace
putpdf paragraph, halign(center) 
putpdf image el_ihs_exports99.png
putpdf pagebreak

betterbar ihs_exports97_2024 ihs_exports97_2023 ihs_exports97_2020 if surveyround !=2, over(treatment) barlab ci ///     
	title("Export turnover in dt, ihs transformed win. 97th", pos(12))
gr export el_ihs_exports97.png, replace
putpdf paragraph, halign(center) 
putpdf image el_ihs_exports97.png
putpdf pagebreak

betterbar ihs_exports95_2024 ihs_exports95_2023 ihs_exports95_2020 if surveyround !=2, over(treatment) barlab ci ///     
	title("Export turnover in dt, ihs transformed win. 95th", pos(12))
gr export el_ihs_exports95.png, replace
putpdf paragraph, halign(center) 
putpdf image el_ihs_exports95.png
putpdf pagebreak
   *Chiffre d'affaires à l’export en dt en 2023
 	foreach x of local take_up{	
 graph box compexp_2023 if compexp_2023 > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Export turnover in 2023 in dt", pos(12))
gr export el_compexp_2023_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_compexp_2023_box_`x'.png
putpdf pagebreak
}
 	foreach x of local take_up{	
twoway (kdensity compexp_2023 if treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity compexp_2023 if treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity compexp_2023 if treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Export turnover in 2023", pos(12)) ///
	   xtitle("Export turnover",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_compexp_2023_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_compexp_2023_kdens_`x'.png, width(5000)
putpdf pagebreak
}
   *Chiffre d'affaires à l’export en dt en 2024
	 	foreach x of local take_up{
 graph box compexp_2024 if compexp_2024 > 0 & surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Export turnover in 2024 in dt", pos(12))
gr export el_compexp_2024_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_compexp_2024_box_`x'.png
putpdf pagebreak
}

 	foreach x of local take_up{	
twoway (kdensity compexp_2024 if treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity compexp_2024 if treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity compexp_2024 if treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Export turnover in 2024", pos(12)) ///
	   xtitle("Export turnover",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_compexp_2024_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_compexp_2024_kdens_`x'.png, width(5000)
putpdf pagebreak
}
	*Bénéfices/Perte 2023
 	foreach x of local take_up{	
graph pie, over(profit_2023_category) by(`x') plabel(_all percent, format(%9.0f) size(medium)) ///
    graphregion(fcolor(none) lcolor(none)) bgcolor(white) legend(pos(6)) ///
    title("Did the company make a loss or a profit in 2023?", pos(12) size(small))
   gr export profit_2023_category_treat_`x'.png, replace
	putpdf paragraph, halign(center) 
	putpdf image profit_2023_category_treat_`x'.png, width(5000)
	putpdf pagebreak
}

 *Profit en dt en 2023
 	foreach x of local take_up{
 graph box comp_benefice2023 if surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Company profit in 2023 in dt", pos(12))
gr export el_comp_benefice2023_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_comp_benefice2023_box_`x'.png
putpdf pagebreak
}
 	foreach x of local take_up{	
twoway (kdensity comp_benefice2023 if treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity comp_benefice2023 if treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity comp_benefice2023 if treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Company profit in 2023", pos(12)) ///
	   xtitle("Company profit",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_comp_benefice2023_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_comp_benefice2023_kdens_`x'.png, width(5000)
putpdf pagebreak
}

	*Bénéfices/Perte 2024
 	foreach x of local take_up{	
graph pie, over(profit_2024_category) by(`x') plabel(_all percent, format(%9.0f) size(medium)) ///
    graphregion(fcolor(none) lcolor(none)) bgcolor(white) legend(pos(6)) ///
    title("Did the company make a loss or a profit in 2024?", pos(12) size(small))
   gr export profit_2024_category_treat_`x'.png, replace
	putpdf paragraph, halign(center) 
	putpdf image profit_2024_category_treat_`x'.png, width(5000)
	putpdf pagebreak
}

 *Profit en dt en 2024
 	foreach x of local take_up{
 graph box comp_benefice2024 if surveyround == 3, over(`x') blabel(total, format(%9.2fc)) ///
	title("Company profit in 2024 in dt", pos(12))
gr export el_comp_benefice2024_box_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image el_comp_benefice2024_box_`x'.png
putpdf pagebreak
}

	foreach x of local take_up{	
twoway (kdensity comp_benefice2024 if treatment == 0 & surveyround == 3, lcolor(blue) lpattern(solid) legend(label(1 "Control"))) ///
	   (kdensity comp_benefice2024 if treatment == 1 & `x'==0 & surveyround == 3, lcolor(red) lpattern(dash) legend(label(2 "Absent"))) ///
	   (kdensity comp_benefice2024 if treatment == 1 & `x'==1 & surveyround == 3, lcolor(orange) lpattern(dash) legend(label(2 "Present"))), ///
       legend(symxsize(small) order(1 "Control" 2 "Absent" 3 "Present")) ///
	   title("Company profit in 2024", pos(12)) ///
	   xtitle("Company profit",size(medium)) ///
	   ytitle("Densitiy", size(medium))
gr export el_comp_benefice2024_kdens_`x'.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_comp_benefice2024_kdens_`x'.png, width(5000)
putpdf pagebreak
}

*Profit in TND
betterbar comp_benefice2024 comp_benefice2023 comp_benefice2020 if surveyround !=2, over(treatment) barlab ci ///    
	title("Company IHS transformed profit in dt", pos(12))
gr export el_profit.png, replace
putpdf paragraph, halign(center) 
putpdf image el_profit.png
putpdf pagebreak

betterbar ihs_profit99_2024 ihs_profit99_2023 ihs_profit_2020_99 if surveyround !=2, over(treatment) barlab ci ///    
	title("Company profit in dt, IHS transformed win. 99th", pos(12))
gr export el_ihs_profit_99.png, replace
putpdf paragraph, halign(center) 
putpdf image el_ihs_profit_99.png
putpdf pagebreak

betterbar ihs_profit97_2024 ihs_profit97_2023 ihs_profit_2020_97 if surveyround !=2, over(treatment) barlab ci ///    
	title("Company profit in dt, IHS transformed win. 97th", pos(12))
gr export el_ihs_profit_97.png, replace
putpdf paragraph, halign(center) 
putpdf image el_ihs_profit_97.png
putpdf pagebreak

betterbar ihs_profit95_2024 ihs_profit95_2023 ihs_profit_2020_95 if surveyround !=2, over(treatment) barlab ci ///    
	title("Company profit in dt, IHS transformed win. 95th", pos(12))
gr export el_ihs_profit_95.png, replace
putpdf paragraph, halign(center) 
putpdf image el_ihs_profit_95.png
putpdf pagebreak
}
***********************************************************************
* 	PART 7: Indices
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 7: Indices"), bold
{

gr tw ///
	(kdensity dsi if treatment == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dsi if treatment == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dsi if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dsi if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Digital sales index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Digital Sales Index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(2) symxsize(small) ///
               order(1 "Treatment group" ///
					 2 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(dsi_el_treat, replace)
graph export dsi_el_treat.png, replace
putpdf paragraph, halign(center) 
putpdf image dsi_el_treat.png
putpdf pagebreak

 	foreach x of local take_up{	
gr tw ///
	(kdensity dsi if treatment == 1 & `x' == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dsi if treatment == 1 & `x' == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dsi if treatment == 1 & `x' == 0 & surveyround == 3, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram dsi if treatment == 1 & `x' == 0 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity dsi if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dsi if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Digital sales index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Digital Sales Index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated" ///
                     2 "Treatment group, absent" ///
					 3 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(dsi_el_`x', replace)
graph export dsi_el_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image dsi_el_`x'.png
putpdf pagebreak
}

gr tw ///
	(kdensity dmi if treatment == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dmi if treatment == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dmi if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dmi if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Digital Marketing index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Digital Marketing Index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(2) symxsize(small) ///
               order(1 "Treatment group" ///
					 2 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(dmi_el_treat, replace)
graph export dmi_el_treat.png, replace
putpdf paragraph, halign(center) 
putpdf image dmi_el_treat.png
putpdf pagebreak

 	foreach x of local take_up{	
gr tw ///
	(kdensity dmi if treatment == 1 & `x' == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dmi if treatment == 1 & `x' == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dmi if treatment == 1 & `x' == 0 & surveyround == 3, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram dmi if treatment == 1 & `x' == 0 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity dmi if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dmi if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Digital Marketing index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Digital Marketing Index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated" ///
                     2 "Treatment group, absent" ///
					 3 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(dmi_el_`x', replace)
graph export dmi_el_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image dmi_el_`x'.png
putpdf pagebreak
}

gr tw ///
	(kdensity dtp if treatment == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dtp if treatment == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dtp if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dtp if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Digital technology Perception index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Digital technology Perception index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(2) symxsize(small) ///
               order(1 "Treatment group" ///
					 2 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(dtp_el_treat, replace)
graph export dtp_el_treat.png, replace
putpdf paragraph, halign(center) 
putpdf image dtp_el_treat.png
putpdf pagebreak


 	foreach x of local take_up{	
gr tw ///
	(kdensity dtp if treatment == 1 & `x' == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dtp if treatment == 1 & `x' == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dtp if treatment == 1 & `x' == 0 & surveyround == 3, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram dtp if treatment == 1 & `x' == 0 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity dtp if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dtp if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Digital technology Perception index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Digital technology Perception index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated" ///
                     2 "Treatment group, absent" ///
					 3 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(dtp_el_`x', replace)
graph export dtp_el_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image dtp_el_`x'.png
putpdf pagebreak
}

gr tw ///
	(kdensity dtai if treatment == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dtai if treatment == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dtai if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dtai if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Digital technology adoption index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Digital technology adoption index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(2) symxsize(small) ///
               order(1 "Treatment group" ///
					 2 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(dtai_el_treat, replace)
graph export dtai_el_treat.png, replace
putpdf paragraph, halign(center) 
putpdf image dtai_el_treat.png
putpdf pagebreak

 	foreach x of local take_up{	
gr tw ///
	(kdensity dtai if treatment == 1 & `x' == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dtai if treatment == 1 & `x' == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dtai if treatment == 1 & `x' == 0 & surveyround == 3, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram dtai if treatment == 1 & `x' == 0 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity dtai if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dtai if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Digital technology adoption index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Digital technology adoption index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated" ///
                     2 "Treatment group, absent" ///
					 3 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(dtai_el_`x', replace)
graph export dtai_el_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image dtai_el_`x'.png
putpdf pagebreak
}

gr tw ///
	(kdensity eri if treatment == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram eri if treatment == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity eri if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram eri if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Export readiness index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Export readiness index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(2) symxsize(small) ///
               order(1 "Treatment group" ///
					 2 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(eri_el_treat, replace)
graph export eri_el_treat.png, replace
putpdf paragraph, halign(center) 
putpdf image eri_el_treat.png
putpdf pagebreak

 	foreach x of local take_up{	
gr tw ///
	(kdensity eri if treatment == 1 & `x' == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram eri if treatment == 1 & `x' == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity eri if treatment == 1 & `x' == 0 & surveyround == 3, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram eri if treatment == 1 & `x' == 0 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity eri if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram eri if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Export readiness index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Export readiness index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated" ///
                     2 "Treatment group, absent" ///
					 3 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(eri_el_`x', replace)
graph export eri_el_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image eri_el_`x'.png
putpdf pagebreak
}

gr tw ///
	(kdensity epi if treatment == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram epi if treatment == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity epi if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram epi if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Export performance index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Export performance index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(2) symxsize(small) ///
               order(1 "Treatment group" ///
					 2 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(epi_el_treat, replace)
graph export epi_el_treat.png, replace
putpdf paragraph, halign(center) 
putpdf image epi_el_treat.png
putpdf pagebreak

 	foreach x of local take_up{	
gr tw ///
	(kdensity epi if treatment == 1 & `x' == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram epi if treatment == 1 & `x' == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity epi if treatment == 1 & `x' == 0 & surveyround == 3, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram epi if treatment == 1 & `x' == 0 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity epi if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram epi if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Export performance index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Export performance index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated" ///
                     2 "Treatment group, absent" ///
					 3 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(epi_el_`x', replace)
graph export epi_el_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image epi_el_`x'.png
putpdf pagebreak
}

gr tw ///
	(kdensity bpi if treatment == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram bpi if treatment == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity bpi if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram bpi if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Business performance index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Business performance index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(2) symxsize(small) ///
               order(1 "Treatment group" ///
					 2 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(bpi_el_treat, replace)
graph export bpi_el_treat.png, replace
putpdf paragraph, halign(center) 
putpdf image bpi_el_treat.png
putpdf pagebreak

	foreach x of local take_up{	
gr tw ///
	(kdensity bpi if treatment == 1 & `x' == 1 & surveyround == 3, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram bpi if treatment == 1 & `x' == 1 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity bpi if treatment == 1 & `x' == 0 & surveyround == 3, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram bpi if treatment == 1 & `x' == 0 & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity bpi if treatment == 0  & surveyround == 3, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram bpi if treatment == 0  & surveyround == 3, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Endline Distribution of Business performance index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Business performance index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated" ///
                     2 "Treatment group, absent" ///
					 3 "Control group") ///
               c(1) pos(6) ring(6)) ///
	name(bpi_el_`x', replace)
graph export bpi_el_`x'.png, replace
putpdf paragraph, halign(center) 
putpdf image bpi_el_`x'.png
putpdf pagebreak
}

 }

putpdf save "endline_statistics", replace
