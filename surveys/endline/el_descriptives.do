***********************************************************************
* 			endline progress, firm characteristics
***********************************************************************
*																	   
*	PURPOSE: 		Create statistics on firms
*	OUTLINE:														  
*	1)				progress		  		  			
*	2)  			eligibility					 
*	3)  			characteristics							  
*																	  
*	ID variable: 	id (example: f101)			  					  
*	Requires: el_inter.dta 
*	Creates:  endline_statistics.pdf		  
*																	  
***********************************************************************
* 	PART 1:  set environment + create pdf file for export		  			
***********************************************************************
	* import file
use "$el_final/el_final", clear

	* set directory to checks folder
cd "$el_output"
set scheme burd
	* create pdf document
putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("E-commerce: survey progress, firm characteristics"), bold linebreak
putpdf text ("Date: `c(current_date)'"), bold linebreak

***********************************************************************
* 	PART 2:  Survey progress		  			
***********************************************************************
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 1: Survey Progress Overview"), bold
{
* total number of firms starting the survey
graph bar (count), over(treatment) blabel(total, format(%9.0fc)) ///
	title("Number of companies that at least started to fill the survey",size(medium) pos(12)) note("Date: `c(current_date)'") ///
	ytitle("Number of at least initiated survey response")
graph export total.png, width(5000) replace
putpdf paragraph, halign(center)
putpdf image total.png, width(5000)
putpdf pagebreak

*Number of validated
graph bar (count) if attest ==1, over(treatment) blabel(total, format(%9.0fc)) ///
	title("Number of companies that have validated their answers" pos(12)) note("Date: `c(current_date)'") ///
	ytitle("Number of entries")
graph export valide.png, width(5000) replace
putpdf paragraph, halign(center)
putpdf image valide.png, width(5000)
putpdf pagebreak


*share
count if id_plateforme !=.
gen share_started= (`r(N)'/236)*100
graph bar share_started, blabel(total, format(%9.2fc)) ///
	title("Share of companies that at least started to fill the survey") note("Date: `c(current_date)'") ///
	ytitle("Number of complete survey response")
graph export responserate1.png, width(5000) replace
putpdf paragraph, halign(center)
putpdf image responserate1.png, width(5000)
putpdf pagebreak
drop share_started

	* total number of firms starting the survey
count if attest==1
gen share= (`r(N)'/236)*100
graph bar share, blabel(total, format(%9.2fc)) ///
	title("Proportion of companies that have validated their answers" ,size(medium) pos(12)) note("Date: `c(current_date)'") ///
	ytitle("Number of entries")
graph export responserate2.png, width(5000) replace
putpdf paragraph, halign(center)
putpdf image responserate2.png, width(5000)
putpdf pagebreak
drop share

	* Nombre d'entreprise ayant répondu du groupe de formation
*graph bar (count), over(formation) blabel(total) ///
*	name(formation, replace) ///
*	ytitle("nombre d'entreprises") ///
*	title("Participation dans les journées de formation")
*graph export grouperate.png, replace
*putpdf paragraph, halign(center)
*putpdf image grouperate.png
*putpdf pagebreak

	/* Manière avec laquelle l'entreprise a répondu au questionnaire
graph bar (count), over(survey_phone) blabel(total) ///
	name(formation, replace) ///
	ytitle("Number of firms") ///
	title("How the company responded to the questionnaire?")
graph export type_of_surveyanswer.png, width(5000) replace
putpdf paragraph, halign(center)
putpdf image type_of_surveyanswer.png, width(5000)
putpdf pagebreak
*/
	/* timeline of responses
format %-td date 
graph twoway histogram date, frequency width(1) ///
		tlabel(05oct2022(1)16nov2022, angle(60) labsize(vsmall)) ///
		ytitle("Answers") ///
		title("{bf:Endline survey: number of responses}") 
gr export survey_response_byday.png, replace
putpdf paragraph, halign(center) 
putpdf image survey_response_byday.png
putpdf pagebreak
*/
}

***********************************************************************
* 	PART 3:  Variables checking		  			
***********************************************************************	

***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 2: The company"), bold
{
*Number of product innovation
summarize inno_produit if inno_produit > 0,d
stripplot inno_produit if inno_produit > 0, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
    ytitle("Number good or service innovation") ///
		title("Number good or service innovation", pos(12)) ///
    name(el_inno_produit, replace)
gr export el_inno_produit.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_inno_produit.png, width(5000)
putpdf pagebreak 

 stripplot inno_produit if inno_produit > 0, by(treatment) jitter(4) vertical ///
		ytitle("Number good or service innovation") ///
		title("Number good or service innovation", pos(12)) ///
		name(el_inno_produit_treat, replace)
gr export el_inno_produit_treat.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_inno_produit_treat.png, width(5000)
putpdf pagebreak 
	
 graph box inno_produit if inno_produit > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Number good or service innovation", pos(12))
gr export el_inno_produit_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_inno_produit_box.png, width(5000)
putpdf pagebreak

sum inno_produit,d
histogram inno_produit if inno_produit > 0, width(1) frequency addlabels xlabel(0(1)12, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	xtitle("No. of new products") ///
	title("Number good or service innovation", pos(12)) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_inno_produit_his.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_inno_produit_his.png, width(5000)
putpdf pagebreak

*Type of clients
graph bar, over(clients) by(treatment) blabel(total, format(%9.2fc) gap(-0.2)) ///
	legend(pos(6) row(6) label(1 "Exclusively to individuals") label(2 "To other firms") ///
	label(3 "To individuals and other firms"))  ///
	title("Types of Customers") ///
	ylabel(0(20)100, nogrid) 
gr export el_customer_types.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_customer_types.png, width(5000)
putpdf pagebreak
	
    * variable employees
sum fte
stripplot fte, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Number of full-time employees" ,size(medium) pos(12)) ///
		ytitle("Number of employees") ///
		name(fte, replace)
    gr export el_fte.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_fte.png, width(5000)
	putpdf pagebreak

sum fte
stripplot fte, by(treatment) jitter(4) vertical ///
		title("Number of full-time employees" ,size(medium) pos(12)) ///
		ytitle("Number of employees") ///
		name(el_fte_treat, replace)
    gr export el_fte_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_fte_treat.png, width(5000)
	putpdf pagebreak
	
 graph box fte if fte > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Number of employees", size(medium) pos(12))
gr export el_fte_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_fte_box.png, width(5000)
putpdf pagebreak

sum fte,d
histogram fte,width(1) frequency addlabels xlabel(0(25)200, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	title("Number of full-time employees" ,size(medium) pos(12)) ///
	ytitle("No. of firms") ///
	xtitle("No. of full-time employees") ///
	ylabel(0(5)20 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_fte_box_his.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_fte_box_his.png, width(5000)
putpdf pagebreak

    * Number of female employees
sum car_carempl_div1
stripplot car_carempl_div1, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		ytitle("Number of female employees") ///
		title("Number of female employees" ,size(medium) pos(12)) ///
		name(el_car_carempl_div1, replace)
    gr export el_car_carempl_div1.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_car_carempl_div1.png, width(5000)
	putpdf pagebreak
	
stripplot car_carempl_div1, by(treatment) jitter(4) vertical  ///
		ytitle("Number of female employees") ///
		title("Number of female employees" ,size(medium) pos(12)) ///
		name(el_car_carempl_div1_treat, replace)
    gr export el_car_carempl_div1_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_car_carempl_div1_treat.png, width(5000)
	putpdf pagebreak
	
 graph box car_carempl_div1 if car_carempl_div1 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Number of female employees", pos(12))
gr export el_car_carempl_div1_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div1_box.png, width(5000)
putpdf pagebreak

sum car_carempl_div1,d
histogram car_carempl_div1, width(1) frequency addlabels xlabel(0(25)100, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	title ("Number of female employees" ,size(medium) pos(12)) ///
	ytitle("No. of firms") ///
	xtitle("No. of female employees") ///
	ylabel(0(5)20 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_car_carempl_div1_his.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div1_his.png, width(5000)
putpdf pagebreak
	
    * Number of young employees (less than 36 years old)
sum car_carempl_div2
stripplot car_carempl_div2, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Number of young employees (less than 36 yo)" ,size(medium) pos(12)) ///
		ytitle("Number of young employees (less than 36 yo)") ///
		name(el_car_carempl_div2, replace)
    gr export el_car_carempl_div2.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_car_carempl_div2.png, width(5000)
	putpdf pagebreak

stripplot car_carempl_div2, by(treatment) jitter(4) vertical ///
		title("Number of young employees (less than 36 yo)" ,size(small) pos(12)) ///
		ytitle("Number of employees") ///
		name(el_car_carempl_div2_treat, replace)
    gr export el_car_carempl_div2_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_car_carempl_div2_treat.png, width(5000)
	putpdf pagebreak
	
 graph box car_carempl_div2 if car_carempl_div2 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Number of young employees (less than 36 yo)", pos(12))
gr export el_car_carempl_div2_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div2_box.png, width(5000)
putpdf pagebreak

sum car_carempl_div2,d
histogram car_carempl_div2, width(1) frequency addlabels xlabel(0(25)150, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	xtitle("Number of employees") ///
	title("Number of young employes (less than 36 yo)", pos(12)) ///
	ylabel(0(5)20 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_car_carempl_div2_his.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div2_his.png, width(5000)
putpdf pagebreak
	
    * Number of young employees (less than 24 years old)
sum car_carempl_div3
stripplot car_carempl_div3, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Number of young employees (less than 24 yo)" ,size(small) pos(12)) ///
		ytitle("Number of employees") ///
		name(el_car_carempl_div3, replace)
    gr export el_car_carempl_div3.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_car_carempl_div3.png, width(5000)
	putpdf pagebreak	
	
stripplot car_carempl_div3, by(treatment) jitter(4) vertical  ///
		title("Number of young employees (less than 24 yo)" ,size(small) pos(12)) ///
		ytitle("Number of employees") ///
		name(el_car_carempl_div3_treat, replace)
    gr export el_car_carempl_div3_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_car_carempl_div3_treat.png, width(5000)
	putpdf pagebreak
	
 graph box car_carempl_div3 if car_carempl_div3 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Number of young employees (less than 24 yo)", pos(12))
gr export el_car_carempl_div3_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div3_box.png, width(5000)
putpdf pagebreak

sum car_carempl_div3,d
histogram car_carempl_div3, width(1) frequency addlabels xlabel(0(25)150, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	xtitle("Number employees") ///
	title("Number of young employees (less than 24 yo)", pos(12)) ///
	ylabel(0(5)20 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_car_carempl_div3_his.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div3_his.png, width(5000)
putpdf pagebreak

}
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 3: Digital Technology Adoption"), bold
{
	*Variable présence digitale
graph hbar (mean) dig_presence1 dig_presence2 dig_presence3 dig_presence4, over(treatment) percent blabel(total, format(%9.1fc)) ///
title("Presence on communication channels", position(12)) ///
legend (pos(6) row(6) label (1 "Website") label(2 "Social Medias") ///
label(3 "Marketplace") label(4 "On site")) 
gr export el_mark_online_freq.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_mark_online_freq.png, width(5000)
putpdf pagebreak

betterbar dig_presence1 dig_presence2 dig_presence3 dig_presence4, over(treatment) barlab ///
	title("Presence on communication channels", position(12)) ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_presence_digital.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_presence_digital.png, width(5000)
putpdf pagebreak

	*Variable paiement digital
graph hbar (mean) dig_payment1 dig_payment2 dig_payment3, over(treatment) percent blabel(total, format(%9.1fc)) ///
title("Means of payment", position(12)) ///
legend (pos(6) row(6) label (1 "Offline payment option") label(2 "Possibility to pay/order on website") ///
label(3 "Possibility to pay/order through a plateform")) 
graph export el_paiement_digital_freq.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_paiement_digital_freq.png, width(5000)
putpdf pagebreak

betterbar dig_payment1 dig_payment2 dig_payment3, over(treatment) ci barlab ///
	title("Means of payment", position(12)) ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_paiement_digital.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_paiement_digital.png, width(5000)
putpdf pagebreak

	*More benefits with online selling
graph pie, over(dig_prix) plabel(_all percent, format(%9.0f) size(medium)) graphregion(fcolor(none) lcolor(none)) ///
   bgcolor(white) legend(pos(6)) ///
   title("Higher margins with online sales", size(medium) pos(12))
   gr export el_dig_prix_pie.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_prix_pie.png, width(5000)
	putpdf pagebreak

graph pie, over (dig_prix) by(treatment) plabel(_all percent, format(%9.0f) size(medium)) graphregion(fcolor(none) lcolor(none)) ///
   bgcolor(white) legend(pos(6)) ///
   title("Higher margins with online sales" ,size(medium) pos(12))
   gr export el_dig_prix_pie_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_prix_pie_treat.png, width(5000)
	putpdf pagebreak
	
	 * variable dig_revenues_ecom
sum dig_revenues_ecom
 stripplot dig_revenues_ecom, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Online sales as % of total sales" ,size(medium) pos(12)) ///
		ytitle("% of total sales") ///
		name(el_dig_revenues_ecom, replace)
    gr export el_dig_revenues_ecom.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_revenues_ecom.png, width(5000)
	putpdf pagebreak 

stripplot dig_revenues_ecom, by(treatment) jitter(4) vertical  ///
title("Online sales as % of total sales" ,size(medium) pos(12)) ///
ytitle("% of total sales") ///
name(el_dig_revenues_ecom_treat, replace)
gr export el_dig_revenues_ecom_treat.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_dig_revenues_ecom_treat.png, width(5000)
putpdf pagebreak 
	
 graph box dig_revenues_ecom if dig_revenues_ecom> 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Online sales as % of total sales", pos(12))
gr export el_dig_revenues_ecom_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_dig_revenues_ecom_box.png, width(5000)
putpdf pagebreak

*Présence sur quel réseau social ?
graph hbar (mean) dig_presence2_sm1 dig_presence2_sm2 dig_presence2_sm3 dig_presence2_sm4 dig_presence2_sm5 dig_presence2_sm6, over(treatment) percent blabel(total, format(%9.1fc)) ///
title("Social media presence", position(12)) ///
legend (pos(6) row(6) label (1 "Instagram") label(2 "Facebook") ///
label(3 "Twitter") label(4 "Youtube") label(5 "LinkedIn") label(6 "Others")) 
graph export el_dig_presence2_sm_freq.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_dig_presence2_sm_freq.png, width(5000)
putpdf pagebreak

betterbar dig_presence2_sm1 dig_presence2_sm2 dig_presence2_sm3 dig_presence2_sm4 dig_presence2_sm5 dig_presence2_sm6, over(treatment) ci barlab ///
	title("Social media presence", position(12)) ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_dig_presence2_sm.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_dig_presence2_sm.png, width(5000)
putpdf pagebreak

*Présence sur quel plateforme d'e-commerce ?
graph hbar (mean) dig_presence3_plateform1 dig_presence3_plateform2 dig_presence3_plateform3 dig_presence3_plateform4 dig_presence3_plateform5 dig_presence3_plateform6 dig_presence3_plateform7 dig_presence3_plateform8, over(treatment) percent blabel(total, format(%9.1fc)) ///
title("Marketplace presence", position(12)) ///
legend (pos(6) row(6) label (1 "Little Jneina") label(2 "Founa") ///
label(3 "Made in Tunisia") label(4 "Jumia") label(5 "Amazon") label(6 "Ali baba") label(7 "Upwork") label(8 "Others")) 
graph export el_dig_presence3_plateform_freq.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_dig_presence3_plateform_freq.png, width(5000)
putpdf pagebreak

betterbar dig_presence3_plateform1 dig_presence3_plateform2 dig_presence3_plateform3 dig_presence3_plateform4 dig_presence3_plateform5 dig_presence3_plateform6 dig_presence3_plateform7 dig_presence3_plateform8, over(treatment) ci barlab ///
	title("Marketplace presence", position(12)) ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_dig_presence3_plateform.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_dig_presence3_plateform.png, width(5000)
putpdf pagebreak

*Utilisation du site web
graph hbar (mean) web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand, over(treatment) percent blabel(total, format(%9.1fc)) ///
	title("Use of the website", position(12)) ///
legend (pos(6) row(6) label (1 "Company contact details") label(2 "Cataloging goods & services") ///
label(3 "Study consumer behavior") label(4 "Communicate with customers") label(5 "Promoting a brand image")) 
graph export el_web_use_freq.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_web_use_freq.png, width(5000)
putpdf pagebreak

betterbar web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand, over(treatment) ci barlab ///
	title("Use of the website", position(12)) ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_web_use.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_web_use.png, width(5000)
putpdf pagebreak

*Utilisation des réseaux sociaux
graph hbar (mean) sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand, over(treatment) percent blabel(total, format(%9.1fc)) ///
	title("Use of social medias", position(12)) ///
legend (pos(6) row(6) label (1 "Company contact details") label(2 "Cataloging goods & services") ///
label(3 "Study consumer behavior") label(4 "Communicate with customers") label(5 "Promoting a brand image")) 
graph export el_sm_use_freq.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_sm_use_freq.png, width(5000)
putpdf pagebreak

betterbar sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand, over(treatment) ci barlab ///
	title("Use of social medias", position(12)) ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_sm_use.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_sm_use.png, width(5000)
putpdf pagebreak

*Variable mise à jour
graph hbar (mean) dig_miseajour1 dig_miseajour2 dig_miseajour3, over(treatment) percent blabel(total, format(%9.1fc)) ///
	title("Frequency of updates", position(12)) ///
	legend (pos(6) row(6) label (1 "Website update") label(2 "Social Medias update") ///
label(3 "Marketplace update")) ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_maj_digital_freq.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_maj_digital_freq.png, width(5000)
putpdf pagebreak


betterbar dig_miseajour1 dig_miseajour2 dig_miseajour3, over(treatment) ci barlab ///
	title("Frequency of updates", position(12)) ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_maj_digital.png, width(5000) replace 
putpdf paragraph, halign(center) 
putpdf image el_maj_digital.png, width(5000)
putpdf pagebreak

	*Activities of digital marketing
graph hbar (mean) mark_online1 mark_online2 mark_online3 mark_online4 mark_online5, over(treatment) percentage blabel(total, format(%9.2fc) gap(-0.2)) ///
	title("Online marketing activities" , pos(12)) ///
	legend (pos(6) row(6) label (1 "E-mailing & Newsletters") label(2 "SEO or SEA") ///
	label(3 "Free social media marketing") label(4 "Paid social media advertising") ///
	label(5 "Other marketing activities"))  ///
	ylabel(0(10)40, nogrid)    
gr export el_mark_online.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_mark_online.png, width(5000)
putpdf pagebreak


    *Nombre d'émployés chargés activités en ligne
sum dig_empl
stripplot dig_empl, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Number of employees in charge of online activities" ,size(medium) pos(12)) ///
		ytitle("Number of employees") ///
		name(el_dig_empl, replace)
    gr export el_dig_empl.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_empl.png, width(5000)
	putpdf pagebreak

stripplot dig_empl, by(treatment) jitter(4) vertical  ///
		title("Number of employees in charge of online activities" ,size(medium) pos(12)) ///
		ytitle("Number of employees") ///
		name(el_dig_empl_treat, replace)
    gr export el_dig_empl_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_empl_treat.png, width(5000)
	putpdf pagebreak
	
 graph box dig_empl if dig_empl > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Number of employees in charge of online activities", pos(12))
gr export el_dig_empl_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_dig_empl_box.png, width(5000)
putpdf pagebreak

    *Investissement dans les activités de marketing en ligne en 2023 et 2024
sum dig_invest
	stripplot dig_invest, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Investment in online marketing activities in 2023 and 2024" ,size(medium) pos(12)) ///
		ytitle("Amount invested in TND") ///
		name(el_dig_invest, replace)
    gr export el_dig_invest.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_invest.png, width(5000)
	putpdf pagebreak

	stripplot dig_invest, by(treatment) jitter(4) vertical  ///
		title("Investment in online marketing activities in 2023 and 2024", size(small)) ///
		ytitle("Amount invested in TND") ///
		name(el_dig_invest_treat, replace)
    gr export el_dig_invest_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_invest_treat.png, width(5000)
	putpdf pagebreak
	
 graph box dig_invest if dig_invest > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Investment in online marketing activities in 2023 and 2024", pos(12) size(medium))
gr export el_dig_invest_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_dig_invest_box.png, width(5000)
putpdf pagebreak

*Investissement dans les activités de marketing hors ligne en 2023 et 2024
sum mark_invest
stripplot mark_invest, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Investment in offline marketing activities in 2023 and 2024" ,size(medium) pos(12)) ///
		ytitle("Amount invested in TND") ///
		name(el_mark_invest, replace)
    gr export el_mark_invest.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_mark_invest.png, width(5000)
	putpdf pagebreak
	
stripplot mark_invest, by(treatment) jitter(4) vertical  ///
		title("Investment in offline marketing activities in 2023 and 2024", size(small)) ///
		ytitle("Amount invested in TND") ///
		name(el_mark_invest_treat, replace)
    gr export el_mark_invest_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_mark_invest_treat.png, width(5000)
	putpdf pagebreak
	
 graph box mark_invest if mark_invest > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Investment in offline marketing activities in 2023 and 2024", pos(12) size(medium))
gr export el_mark_invest_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_mark_invest_box.png, width(5000)
putpdf pagebreak
}
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 4: Digital Technology Perception"), bold
{
	 *Perception coût du marketing digital
	 graph bar (mean) investecom_benefit1, over(treatment) blabel(total, format(%9.1fc) gap(-0.2)) ///
    title("Perception of digital marketing costs", pos(12)) note("1 = very low, 5 = very high", pos(6)) ///
    ylabel(0(1)7, nogrid) ///
    ytitle("Mean perception of digital marketing costs")
gr export el_investecom_benefit1.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_investecom_benefit1.png, width(5000)
putpdf pagebreak

	 *Perception bénéfice du marketing digital
	 graph bar (mean) investecom_benefit2, over(treatment) blabel(total, format(%9.1fc) gap(-0.2)) ///
    title("Perception of digital marketing benefits", pos(12)) note("1 = very low, 5 = very high", pos(6)) ///
    ylabel(0(1)7, nogrid) ///
    ytitle("Mean perception of digital marketing benefits")
gr export el_investecom_benefit2.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_investecom_benefit2.png, width(5000)
putpdf pagebreak
	 
	*Barriers to digital adoption
graph hbar (mean) dig_barr1 dig_barr2 dig_barr3 dig_barr4 dig_barr5 dig_barr6, percentage over(treatment) blabel(total, format(%9.1fc) gap(-0.2)) ///
	title("Barriers to technology adoption" , pos(12)) ///
	legend (pos(6) row(6) label (1 "Absence/uncertainty of online demand") label(2 "Lack of skilled staff") ///
	label(3 "Inadequate infrastructure") label(4 "Cost is too high") ///
	label(5 "Restrictive government regulations") label(6 "Resistance to change"))  
gr export el_barriers.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_barriers.png, width(5000)
putpdf pagebreak
}
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 5: Export"), bold
{
	* Export: direct, indirect, no export
graph bar (mean) export_1 export_2 export_3, over(treatment) percentage blabel(total, format(%9.1fc) gap(-0.2)) ///
    legend (pos(6) row(6) label (1 "Direct export") label (2 "Indirect export") ///
	label (3 "No export")) ///
	title("Firm & export status", pos(12)) 
gr export el_firm_exports.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_firm_exports.png, width(5000)
putpdf pagebreak

	* Reasons for not exporting
graph bar (mean) export_41 export_42 export_43 export_44, over(treatment) percentage blabel(total, format(%9.1fc) gap(-0.2)) ///
    legend (pos(6) row(6) label (1 "Not profitable") label (2 "Did not find clients abroad") ///
	label (3 "Too complicated") label (4 "Requires too much investment")) ///
	ylabel(0(20)100, nogrid)  ///
	title("Reasons for not exporting", pos(12)) 
gr export el_no_exports.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_no_exports.png, width(5000)
putpdf pagebreak

	*No of export destinations
sum exp_pays
stripplot exp_pays, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		ytitle("Number of countries") ///
		title("Number of export countries" , pos(12)) ///
		name(el_exp_pays, replace)
    gr export el_exp_pays.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_exp_pays.png, width(5000)
	putpdf pagebreak
	
stripplot exp_pays, by(treatment) jitter(4) vertical ///
		ytitle("Number of countries") ///
		title("Number of export countries",size(medium) pos(12)) ///
		name(el_exp_pays_treat, replace)
    gr export el_exp_pays_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_exp_pays_treat.png, width(5000)
	putpdf pagebreak
	
 graph box exp_pays if exp_pays > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Number of export countries", pos(12))
gr export el_exp_pays_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_exp_pays_box.png, width(5000)
putpdf pagebreak

sum exp_pays,d
histogram(exp_pays), width(1) frequency addlabels xlabel(0(1)8, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	title("Number of export countries", pos(12)) ///
	xtitle("Number of export countries") ///
	ylabel(0(20)100 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_exp_pays_his.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_exp_pays_his.png, width(5000)
putpdf pagebreak
	
		*No of international orders
sum clients_b2c
stripplot clients_b2c, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Number of international orders/ clients", size(medium) pos(12)) ///
		ytitle("Number of orders") ///
		name(el_clients_b2c, replace)
    gr export el_clients_b2c.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_clients_b2c.png, width(5000)
	putpdf pagebreak

stripplot clients_b2c, by(treatment) jitter(4) vertical ///
		title("Number of international orders/ clients",size(medium) pos(12)) ///
		ytitle("Number of orders") ///
		name(el_clients_b2c_treat, replace)
    gr export el_clients_b2c_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_clients_b2c_treat.png, width(5000)
	putpdf pagebreak
	
 graph box clients_b2c if clients_b2c > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Number of international orders", pos(12))
gr export el_clients_b2c_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_clients_b2c_box.png, width(5000)
putpdf pagebreak

sum clients_b2c,d
histogram(clients_b2c), width(1) frequency addlabels xlabel(0(1)8, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	title("Number of international orders/ clients",size(medium) pos(12)) ///
	ytitle("No. of firms") ///
	xtitle("Number of orders") ///
	ylabel(0(20)100 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_clients_b2c_his.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_clients_b2c_his.png, width(5000)
putpdf pagebreak

*No of international companies
sum clients_b2b
stripplot clients_b2b, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Number of international companies",size(medium) pos(12)) ///
		ytitle("Number of companies") ///
		name(el_clients_b2b, replace)
    gr export el_clients_b2b.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_clients_b2b.png, width(5000)
	putpdf pagebreak

sum clients_b2b
stripplot clients_b2b, by(treatment) jitter(4) vertical ///
		title("Number of international companies",size(medium) pos(12)) ///
		ytitle("Number of companies") ///
		name(el_clients_b2b_treat, replace)
    gr export el_clients_b2b_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_clients_b2b_treat.png, width(5000)
	putpdf pagebreak
	
 graph box clients_b2b if clients_b2b > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Number of international companies", pos(12))
gr export el_clients_b2b_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_clients_b2b_box.png, width(5000)
putpdf pagebreak

sum clients_b2b,d
histogram(clients_b2b), width(1) frequency addlabels xlabel(0(1)8, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	title("Number of international companies",size(medium) pos(12)) ///
	ytitle("No. of firms") ///
	xtitle("Number of international companies") ///
	ylabel(0(20)100 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_clients_b2b_his.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_clients_b2b_his.png, width(5000)
putpdf pagebreak
	
	* Export trhough digital channel
graph pie, over(exp_dig) plabel(_all percent, format(%9.0f) size(medium)) graphregion(fcolor(none) lcolor(none)) ///
   bgcolor(white) legend(pos(6)) ///
   title("Exporting through digital presence", pos(12))
   gr export el_exp_dig_pie.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_exp_dig_pie.png, width(5000)
	putpdf pagebreak

graph pie, over(exp_dig) by(treatment) plabel(_all percent, format(%9.0f) size(medium)) graphregion(fcolor(none) lcolor(none)) ///
   bgcolor(white) legend(pos(6)) ///
   title("Exporting through digital presence", pos(12))
   gr export el_exp_dig_pie_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_exp_dig_pie_treat.png, width(5000)
	putpdf pagebreak
	
	*Export practices
graph hbar (mean) exp_pra_foire exp_pra_sci exp_pra_norme exp_pra_vent exp_pra_ach, percentage over(treatment) blabel(total, format(%9.2fc) gap(-0.2)) ///
	title("Export practices",size(medium) pos(12)) ///
	legend (pos(6) row(8) label (1 "International fair/exhibition") label(2 "Sales partner") ///
	label(3 "Export manager") label(4 "Export plan") ///
	label(5 "Certification") label(6 "External funding") label(7 "Sales structure") label(8 "Interest by a foreign buyer"))  ///
	ylabel(0(10)40, nogrid)    
gr export el_export_practices.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_export_practices.png, width(5000)
putpdf pagebreak
}
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 6: Accounting"), bold
{
	*Bénéfices/Perte 2023
graph pie, over(profit_2023_category) plabel(_all percent, format(%9.0f) size(medium)) graphregion(fcolor(none) lcolor(none)) ///
   bgcolor(white) legend(pos(6)) ///
   title("Did the company make a loss or a profit in 2023?", pos(12))
   gr export profit_2023_category.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image profit_2023_category.png, width(5000)
	putpdf pagebreak
	
graph pie, over(profit_2023_category) by(treatment) plabel(_all percent, format(%9.0f) size(medium)) ///
    graphregion(fcolor(none) lcolor(none)) bgcolor(white) legend(pos(6)) ///
    title("Did the company make a loss or a profit in 2023?", pos(12) size(small))
   gr export profit_2023_category_treat.png, replace
	putpdf paragraph, halign(center) 
	putpdf image profit_2023_category_treat.png, width(5000)
	putpdf pagebreak
	
    * Chiffre d'affaires total en dt en 2023 
sum comp_ca2023
stripplot comp_ca2023, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Total turnover in 2023",size(medium) pos(12)) ///
		ytitle("Amount in dt") ///
		name(el_comp_ca2023, replace)
    gr export el_comp_ca2023.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_comp_ca2023.png, width(5000)
	putpdf pagebreak

stripplot comp_ca2023, by(treatment) jitter(4) vertical  ///
		title("Total turnover in 2023",size(medium) pos(12)) ///
		ytitle("Amount in dt") ///
		name(el_comp_ca2023_treat, replace)
    gr export el_comp_ca2023_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_comp_ca2023_treat.png, width(5000)
	putpdf pagebreak
	
 graph box comp_ca2023 if comp_ca2023 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Total turnover in 2023 in dt", pos(12))
gr export el_comp_ca2023_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_comp_ca2023_box.png, width(5000)
putpdf pagebreak

    * Chiffre d'affaires total en dt en 2024 
sum comp_ca2024
stripplot comp_ca2024, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Total turnover in 2024",size(medium) pos(12)) ///
		ytitle("Amount in dt") ///
		name(el_comp_ca2024, replace)
    gr export el_comp_ca2024.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_comp_ca2024.png, width(5000)
	putpdf pagebreak

stripplot comp_ca2024, by(treatment) jitter(4) vertical ///
		title("Total turnover in 2024",size(medium) pos(12)) ///
		ytitle("Amount in dt") ///
		name(el_comp_ca2024_treat, replace)
    gr export el_comp_ca2024_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_comp_ca2024_treat.png, width(5000)
	putpdf pagebreak
	
 graph box comp_ca2024 if comp_ca2024 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Total turnover in 2024 in dt", pos(12))
gr export el_comp_ca2024_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_comp_ca2024_box.png, width(5000)
putpdf pagebreak

   *Chiffre d'affaires à l’export en dt en 2023
 sum compexp_2023
stripplot compexp_2023, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Export turnover in 2023",size(medium) pos(12)) ///
		ytitle("Amount in dt") ///
		name(el_compexp_2023, replace)
    gr export el_compexp_2023.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_compexp_2023.png, width(5000)
	putpdf pagebreak

stripplot compexp_2023, by(treatment) jitter(4) vertical ///
		title("Export turnover in 2023",size(medium) pos(12)) ///
		ytitle("Amount in dt") ///
		name(el_compexp_2023_treat, replace)
    gr export el_compexp_2023_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_compexp_2023_treat.png, width(5000)
	putpdf pagebreak
	
	
 graph box compexp_2023 if compexp_2023 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Export turnover in 2023 in dt", pos(12))
gr export el_compexp_2023_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_compexp_2023_box.png, width(5000)
putpdf pagebreak

	*Bénéfices/Perte 2024
graph pie, over(profit_2024_category) plabel(_all percent, format(%9.0f) size(medium)) graphregion(fcolor(none) lcolor(none)) ///
   bgcolor(white) legend(pos(6)) ///
   title("Did the company make a loss or a profit in 2024?", pos(12))
   gr export profit_2024_category.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image profit_2024_category.png, width(5000)
	putpdf pagebreak
	
	graph pie, over(profit_2024_category)  by(treatment) plabel(_all percent, format(%9.0f) size(medium)) graphregion(fcolor(none) lcolor(none)) ///
   bgcolor(white) legend(pos(6)) ///
   title("Did the company make a loss or a profit in 2024?", pos(12) size(small))
   gr export profit_2024_category_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image profit_2024_category_treat.png, width(5000)
	putpdf pagebreak
	
   *Chiffre d'affaires à l’export en dt en 2024
sum compexp_2024
stripplot compexp_2024, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		ytitle("Amount in dt") ///
		title("Export turnover in 2024",size(medium) pos(12)) ///
		name(el_compexp_2024, replace)
    gr export el_compexp_2024.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_compexp_2024.png, width(5000)
	putpdf pagebreak
	
stripplot compexp_2024, by(treatment) jitter(4) vertical  ///
		ytitle("Amount in dt") ///
		title("Export turnover in 2024",size(medium) pos(12)) ///
		name(el_compexp_2024_treat, replace)
    gr export el_compexp_2024_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_compexp_2024_treat.png, width(5000)
	putpdf pagebreak
	
 graph box compexp_2024 if compexp_2024 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Export turnover in 2024 in dt", pos(12))
gr export el_compexp_2024_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_compexp_2024_box.png, width(5000)
putpdf pagebreak

 *Profit en dt en 2023
sum comp_benefice2023
stripplot comp_benefice2023, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		ytitle("Amount in dt") ///
		title("Company profit in 2023",size(medium) pos(12)) ///
		name(el_comp_benefice2023, replace)
    gr export el_comp_benefice2023.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_compexp_2023.png, width(5000)
	putpdf pagebreak

stripplot comp_benefice2023, by(treatment) jitter(4) vertical ///
		ytitle("Amount in dt") ///
		title("Company profit in 2023",size(medium) pos(12)) ///
		name(el_comp_benefice2023_treat, replace)
    gr export el_comp_benefice2023_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_comp_benefice2023_treat.png, width(5000)
	putpdf pagebreak
	
 graph box comp_benefice2023, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Company profit in 2023 in dt", pos(12))
gr export el_comp_benefice2023_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_comp_benefice2023_box.png, width(5000)
putpdf pagebreak

 *Profit en dt en 2024
sum comp_benefice2024
stripplot comp_benefice2024, jitter(4) vertical yline(`=r(mean)', lcolor(red)) ///
		title("Company profit in 2024",size(medium) pos(12)) ///
		ytitle("Amount in dt") ///
		name(el_comp_benefice2024, replace)
    gr export el_comp_benefice2024.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_compexp_2024.png, width(5000)
	putpdf pagebreak
	
stripplot comp_benefice2024, by(treatment) jitter(4) vertical  ///
		title("Company profit in 2024",size(medium) pos(12)) ///
		ytitle("Amount in dt") ///
		name(el_comp_benefice2024_treat, replace)
    gr export el_comp_benefice2024_treat.png, width(5000) replace
	putpdf paragraph, halign(center) 
	putpdf image el_comp_benefice2024_treat.png, width(5000)
	putpdf pagebreak
	
 graph box comp_benefice2024, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Company profit in 2024 in dt", pos(12))
gr export el_comp_benefice2024_box.png, width(5000) replace
putpdf paragraph, halign(center) 
putpdf image el_comp_benefice2024_box.png, width(5000)
putpdf pagebreak
}
***********************************************************************
* 	PART 4:  save pdf
***********************************************************************
	* change directory to progress folder

	* pdf
putpdf save "endline_statistics", replace
