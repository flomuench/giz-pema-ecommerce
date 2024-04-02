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
	title("Nombre des entreprises qui au moins ont commence à remplir") note("Date: `c(current_date)'") ///
	ytitle("Number of at least initiated survey response")
graph export total.png, replace
putpdf paragraph, halign(center)
putpdf image total.png
putpdf pagebreak

*Number of validated
graph bar (count) if validation ==1, over(treatment) blabel(total, format(%9.0fc)) ///
	title("La part des entreprises qui ont validé leurs réponses") note("Date: `c(current_date)'") ///
	ytitle("Number of entries")
graph export valide.png, replace
putpdf paragraph, halign(center)
putpdf image valide.png
putpdf pagebreak


*share
count if id_plateforme !=.
gen share_started= (`r(N)'/236)*100
graph bar share_started, blabel(total, format(%9.2fc)) ///
	title("La part des entreprises qui au moins ont commence à remplir") note("Date: `c(current_date)'") ///
	ytitle("Number of complete survey response")
graph export responserate1.png, replace
putpdf paragraph, halign(center)
putpdf image responserate1.png
putpdf pagebreak
drop share_started

	* total number of firms starting the survey
count if validation==1
gen share= (`r(N)'/236)*100
graph bar share, blabel(total, format(%9.2fc)) ///
	title("La part des entreprises qui ont validé leurs réponses") note("Date: `c(current_date)'") ///
	ytitle("Number of entries")
graph export responserate2.png, replace
putpdf paragraph, halign(center)
putpdf image responserate2.png
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

	* Manière avec laquelle l'entreprise a répondu au questionnaire
graph bar (count), over(survey_phone) blabel(total) ///
	name(formation, replace) ///
	ytitle("nombre d'entreprises") ///
	title("Manière avec laquelle l'entreprise a répondu au questionnaire")
graph export type_of_surveyanswer.png, replace
putpdf paragraph, halign(center)
putpdf image type_of_surveyanswer.png
putpdf pagebreak

	* timeline of responses
format %-td date 
graph twoway histogram date, frequency width(1) ///
		tlabel(05oct2022(1)16nov2022, angle(60) labsize(vsmall)) ///
		ytitle("responses") ///
		title("{bf:Endline survey: number of responses}") 
gr export survey_response_byday.png, replace
putpdf paragraph, halign(center) 
putpdf image survey_response_byday.png
putpdf pagebreak
}
***********************************************************************
* 	PART 3:  Variables checking		  			
***********************************************************************	

***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 2: The company"), bold
{


*Number of product innovation
 stripplot inno_produit, jitter(4) vertical yline(2, lcolor(red)) ///
		ytitle("Nombre de nouveaux produits") ///
		name(el_inno_produit, replace)
    gr export el_inno_produit.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_inno_produit.png
	putpdf pagebreak 
	
 graph box inno_produit if inno_produit > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Nombre de nouveaux produits", pos(12))
gr export el_inno_produit_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_inno_produit_box.png
putpdf pagebreak


sum inno_produit,d
histogram inno_produit, width(1) frequency addlabels xlabel(0(1)10, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	xtitle("No. of new products") ///
	ylabel(0(5)20 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_inno_produit_his.png, replace
putpdf paragraph, halign(center) 
putpdf image el_inno_produit_his.png
putpdf pagebreak
*/


*Type of clients
graph bar clients, percentage over(treatment) blabel(total, format(%9.2fc) gap(-0.2)) ///
	legend(pos(6) row(6) label(1 "Exclusively to individuals") label(2 "To other firms") ///
	label(3 "To individuals and other firms"))  ///
	title("Types of Customers") ///
	ylabel(0(20)100, nogrid) 
	gr export el_customer_types.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_customer_types.png
	putpdf pagebreak
	
    * variable employees
stripplot fte, jitter(4) vertical yline(2, lcolor(red)) ///
		ytitle("Nombre d'employés") ///
		name(fte, replace)
    gr export el_fte.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_fte.png
	putpdf pagebreak
	
 graph box fte if fte > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Nombre d'employés", pos(12))
gr export el_fte_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_fte_box.png
putpdf pagebreak

sum fte,d
histogram fte,width(1) frequency addlabels xlabel(0(25)100, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	xtitle("No. of full-time employees") ///
	ylabel(0(5)20 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_fte_box_his.png, replace
putpdf paragraph, halign(center) 
putpdf image el_fte_box_his.png
putpdf pagebreak

    * Number of female employees
stripplot car_carempl_div1, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Nombre d'employés femmes") ///
		name(el_car_carempl_div1, replace)
    gr export el_car_carempl_div1.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_car_carempl_div1.png
	putpdf pagebreak
	
 graph box car_carempl_div1 if car_carempl_div1 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Nombre d'employés femmes", pos(12))
gr export el_car_carempl_div1_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div1_box.png
putpdf pagebreak

sum car_carempl_div1,d
histogram car_carempl_div1, width(1) frequency addlabels xlabel(0(25)100, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	xtitle("No. of female employees") ///
	ylabel(0(5)20 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_car_carempl_div1_his.png, replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div1_his.png
putpdf pagebreak
	
    * Number of young employees (less than 36 years old)
stripplot car_carempl_div2, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Nombre de jeunes (moins de 36 ans)") ///
		name(el_car_carempl_div2, replace)
    gr export el_car_carempl_div2.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_car_carempl_div2.png
	putpdf pagebreak
	
 graph box car_carempl_div2 if car_carempl_div2 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Nombre de jeunes (moins de 36 ans)", pos(12))
gr export el_car_carempl_div2_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div2_box.png
putpdf pagebreak

sum car_carempl_div2,d
histogram car_carempl_div2, width(1) frequency addlabels xlabel(0(25)100, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	xtitle("Nombre de jeunes (moins de 36 ans)") ///
	ylabel(0(5)20 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_car_carempl_div2_his.png, replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div2_his.png
putpdf pagebreak
	
    * Number of young employees (less than 24 years old)
stripplot car_carempl_div3, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Nombre de jeunes (moins de 24 ans)") ///
		name(el_car_carempl_div3, replace)
    gr export el_car_carempl_div3.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_car_carempl_div3.png
	putpdf pagebreak
	
 graph box car_carempl_div3 if car_carempl_div3 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Nombre de jeunes (moins de 24 ans)", pos(12))
gr export el_car_carempl_div3_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div3_box.png
putpdf pagebreak

sum car_carempl_div3,d
histogram car_carempl_div3, width(1) frequency addlabels xlabel(0(25)100, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	xtitle("Nombre de jeunes (moins de 24 ans)") ///
	ylabel(0(5)20 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_car_carempl_div3_his.png, replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div3_his.png
putpdf pagebreak


    * Number of full-time employees 
stripplot car_carempl_div4, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Nombre d'employés à plein temps") ///
		name(el_car_carempl_div4, replace)
    gr export el_car_carempl_div4.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_car_carempl_div4.png
	putpdf pagebreak
	
 graph box car_carempl_div4 if car_carempl_div4 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Nombre d'employés à plein temps", pos(12))
gr export el_car_carempl_div4_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div4_box.png
putpdf pagebreak

sum car_carempl_div4,d
histogram car_carempl_div4, width(1) frequency addlabels xlabel(0(25)100, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	xtitle("Nombre d'employés à plein temps") ///
	ylabel(0(5)20 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_car_carempl_div4_his.png, replace
putpdf paragraph, halign(center) 
putpdf image el_car_carempl_div4_his.png
putpdf pagebreak
}
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 3: Digital Technology Adoption"), bold
{


	
	*Variable présence digitale
betterbar dig_presence1 dig_presence2 dig_presence3, over(treatment) ci barlab ///
	title("Présence sur les canaux de communication") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_presence_digital.png, replace 
putpdf paragraph, halign(center) 
putpdf image el_presence_digital.png
putpdf pagebreak

	*Variable paiement digital
betterbar dig_payment1 dig_payment2 dig_payment3, over(treatment) ci barlab ///
	title("Moyens de paiement") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_paiement_digital.png, replace 
putpdf paragraph, halign(center) 
putpdf image el_paiement_digital.png
putpdf pagebreak

	*More benefits with online selling
graph pie, over(dig_prix) plabel(_all percent, format(%9.0f) size(medium)) graphregion(fcolor(none) lcolor(none)) ///
   bgcolor(white) legend(pos(6)) ///
   title("La marge est plus importante avec les ventes en ligne", pos(12))
   gr export el_dig_prix_pie.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_prix_pie.png
	putpdf pagebreak
		

	 * variable dig_revenues_ecom:
 stripplot dig_revenues_ecom, jitter(4) vertical yline(2, lcolor(red)) ///
		ytitle("% des ventes par rapport aux CA total") ///
		name(el_dig_revenues_ecom, replace)
    gr export el_dig_revenues_ecom.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_revenues_ecom.png
	putpdf pagebreak 
	
 graph box dig_revenues_ecom if dig_revenues_ecom> 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("% des ventes par rapport aux CA total", pos(12))
gr export el_dig_revenues_ecom_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_dig_revenues_ecom_box.png
putpdf pagebreak

*Présence sur quel réseau social ?
betterbar dig_presence2_sm1 dig_presence2_sm2 dig_presence2_sm3 dig_presence2_sm4 dig_presence2_sm5 dig_presence2_sm6, over(treatment) ci barlab ///
	title("Présence sur les réseaux sociaux") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_dig_presence2_sm.png, replace 
putpdf paragraph, halign(center) 
putpdf image el_dig_presence2_sm.png
putpdf pagebreak

*Présence sur quel réseau social ?
betterbar dig_presence2_sm1 dig_presence2_sm2 dig_presence2_sm3 dig_presence2_sm4 dig_presence2_sm5 dig_presence2_sm6, over(treatment) ci barlab ///
	title("Présence sur les réseaux sociaux") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_dig_presence2_sm.png, replace 
putpdf paragraph, halign(center) 
putpdf image el_dig_presence2_sm.png
putpdf pagebreak

*Présence sur quel plateforme d'e-commerce ?
betterbar dig_presence3_plateform1 dig_presence3_plateform2 dig_presence3_plateform3 dig_presence3_plateform4 dig_presence3_plateform5 dig_presence3_plateform6 dig_presence3_plateform7 dig_presence3_plateform8, over(treatment) ci barlab ///
	title("Présence sur les plateformes d'e-commerce") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_dig_presence3_plateform.png, replace 
putpdf paragraph, halign(center) 
putpdf image el_dig_presence3_plateform.png
putpdf pagebreak

*Utilisation du site web
betterbar web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand, over(treatment) ci barlab ///
	title("Utilisation du site web") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_web_use.png, replace 
putpdf paragraph, halign(center) 
putpdf image el_web_use.png
putpdf pagebreak

*Utilisation des réseaux sociaux
betterbar sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand, over(treatment) ci barlab ///
	title("Utilisation des réseaux sociaux") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_sm_use.png, replace 
putpdf paragraph, halign(center) 
putpdf image el_sm_use.png
putpdf pagebreak

*Variable mise à jour
betterbar dig_miseajour1 dig_miseajour2 dig_miseajour3, ci barlab ///
	title("Fréquence de mise à jour") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export el_maj_digital.png, replace 
putpdf paragraph, halign(center) 
putpdf image el_maj_digital.png
putpdf pagebreak

	*Activities of digital marketing
graph hbar (mean) mark_online1 mark_online2 mark_online3 mark_online4 mark_online5, percentage over(treatment) blabel(total, format(%9.2fc) gap(-0.2)) ///
	title("Activités de marketing en ligne") ///
	legend (pos(6) row(6) label (1 "E-mailing & Newsletters") label(2 "SEO ou SEA") ///
	label(3 "Marketing gratuit sur les médias sociaux") label(4 "Publicité payante sur les médias sociaux") ///
	label(5 "Autres activité de marketing"))  ///
	ylabel(0(10)40, nogrid)    
gr export el_mark_online.png, replace
putpdf paragraph, halign(center) 
putpdf image el_mark_online.png
putpdf pagebreak

    *Nombre d'émployés chargés activités en ligne
stripplot dig_empl, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Nombre d'émployés chargés activités en ligne") ///
		name(el_dig_empl, replace)
    gr export el_dig_empl.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_empl.png
	putpdf pagebreak
	
 graph box dig_empl if dig_empl > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Nombre d'émployés chargés activités en ligne", pos(12))
gr export el_dig_empl_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_dig_empl_box.png
putpdf pagebreak

    *Investissement dans les activités de marketing en ligne en 2023 et 2024
stripplot dig_invest, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Investissement dans les activités de marketing en ligne en 2023 et 2024") ///
		name(el_dig_invest, replace)
    gr export el_dig_invest.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_dig_invest.png
	putpdf pagebreak
	
 graph box dig_invest if dig_invest > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Investissement dans les activités de marketing en ligne en 2023 et 2024", pos(12))
gr export el_dig_invest_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_dig_invest_box.png
putpdf pagebreak

*Investissement dans les activités de marketing hors ligne en 2023 et 2024
stripplot mark_invest, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Investissement dans les activités de marketing hors ligne en 2023 et 2024") ///
		name(el_mark_invest, replace)
    gr export el_mark_invest.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_mark_invest.png
	putpdf pagebreak
	
 graph box mark_invest if mark_invest > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Investissement dans les activités de marketing hors ligne en 2023 et 2024", pos(12))
gr export el_mark_invest_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_mark_invest_box.png
putpdf pagebreak
}
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 4: Digital Technology Perception"), bold
{

	 
	 *Perception coût du marketing digital
	 graph bar (mean) investecom_benefit1, over(treatment) blabel(total, format(%9.1fc) gap(-0.2)) ///
    title("Perception coût du marketing digital", pos(12)) note("1 = pas importante, 5 = très importante", pos(6)) ///
    ylabel(0(1)7, nogrid) ///
    ytitle("Moyenne de la perception coût du marketing digital")
gr export el_investecom_benefit1.png, replace
putpdf paragraph, halign(center) 
putpdf image el_investecom_benefit1.png
putpdf pagebreak

	 *Perception bénéfice du marketing digital
	 graph bar (mean) investecom_benefit2, over(treatment) blabel(total, format(%9.1fc) gap(-0.2)) ///
    title("Perception bénéfice du marketing digital", pos(12)) note("1 = pas importante, 5 = très importante", pos(6)) ///
    ylabel(0(1)7, nogrid) ///
    ytitle("Moyenne de la perception bénéfice du marketing digital")
gr export el_investecom_benefit2.png, replace
putpdf paragraph, halign(center) 
putpdf image el_investecom_benefit2.png
putpdf pagebreak
	 
	*Barriers to digital adoption
graph hbar (mean) dig_barr1 dig_barr2 dig_barr3 dig_barr4 dig_barr5 dig_barr6, percentage over(treatment) blabel(total, format(%9.2fc) gap(-0.2)) ///
	title("Barriers to technology adoption") ///
	legend (pos(6) row(6) label (1 "Absence/incertitude de la demande") label(2 "Manque de main d’oeuvre qualifié") ///
	label(3 "Mauvaise infrastructure") label(4 "Coût est trop élevé") ///
	label(5 "Régulations gouvernementales contraignantes") label(6 "Résistance au changement"))  ///
	ylabel(0(10)40, nogrid)    
gr export el_barriers.png, replace
putpdf paragraph, halign(center) 
putpdf image el_barriers.png
putpdf pagebreak
}
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 5: Export"), bold
{

	 
	* Export: direct, indirect, no export
graph bar (mean) export_1 export_2 export_3, over(treatment) percentage blabel(total, format(%9.1fc) gap(-0.2)) ///
    legend (pos(6) row(6) label (1 "Export direct") label (2 "Export indirect") ///
	label (3 "Pas d'export")) ///
	title("Entreprise & status d'export", pos(12)) ///
	ylabel(0(10)60, nogrid)  
gr export el_firm_exports.png, replace
putpdf paragraph, halign(center) 
putpdf image el_firm_exports.png
putpdf pagebreak

	* Reasons for not exporting
graph bar (mean) export_41 export_42 export_43 export_44, over(treatment) percentage blabel(total, format(%9.1fc) gap(-0.2)) ///
    legend (pos(6) row(6) label (1 "Non rentable") label (2 "N'a pas trouvé de clients à l'étranger") ///
	label (3 "Trop compliqué") label (4 "Nécessite un investissement trop important")) ///
	ylabel(0(20)100, nogrid)  ///
	title("Raisons pour ne pas exporter", pos(12)) 
gr export el_no_exports.png, replace
putpdf paragraph, halign(center) 
putpdf image el_no_exports.png
putpdf pagebreak

	*No of export destinations
stripplot exp_pays, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Nombre de pays d'export") ///
		name(el_exp_pays, replace)
    gr export el_exp_pays.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_exp_pays.png
	putpdf pagebreak
	
 graph box exp_pays if exp_pays > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Nombre de pays d'export", pos(12))
gr export el_exp_pays_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_exp_pays_box.png
putpdf pagebreak

sum exp_pays,d
histogram(exp_pays), width(1) frequency addlabels xlabel(0(1)8, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	xtitle("Nombre de pays d'export") ///
	ylabel(0(20)100 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_exp_pays_his.png, replace
putpdf paragraph, halign(center) 
putpdf image el_exp_pays_his.png
putpdf pagebreak
	
		*No of international orders
stripplot cliens_b2c, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Nombre de commandes internationales") ///
		name(el_exp_pays, replace)
    gr export el_cliens_b2c.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_cliens_b2c.png
	putpdf pagebreak
	
 graph box cliens_b2c if cliens_b2c > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Nombre de commandes internationales", pos(12))
gr export el_cliens_b2c_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_cliens_b2c_box.png
putpdf pagebreak

sum cliens_b2c,d
histogram(cliens_b2c), width(1) frequency addlabels xlabel(0(1)8, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	xtitle("Nombre de commandes internationales") ///
	ylabel(0(20)100 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_cliens_b2c_his.png, replace
putpdf paragraph, halign(center) 
putpdf image el_cliens_b2c_his.png
putpdf pagebreak

*No of international companies
stripplot cliens_b2b, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Nombre d'entreprises internationales") ///
		name(el_exp_pays, replace)
    gr export el_cliens_b2b.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_cliens_b2b.png
	putpdf pagebreak
	
 graph box cliens_b2b if cliens_b2b > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Nombre d'entreprises internationales", pos(12))
gr export el_cliens_b2b_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_cliens_b2b_box.png
putpdf pagebreak

sum cliens_b2b,d
histogram(cliens_b2b), width(1) frequency addlabels xlabel(0(1)8, nogrid) discrete ///
	xline(`r(mean)', lpattern(1)) xline(`r(p50)', lpattern(dash)) ///
	ytitle("No. of firms") ///
	xtitle("Nombre d'entreprises internationales") ///
	ylabel(0(20)100 , nogrid) ///
	text(100 `r(mean)' "Mean", size(vsmall) place(e)) ///
	text(100 `r(p50)' "Median", size(vsmall) place(e))
gr export el_cliens_b2b_his.png, replace
putpdf paragraph, halign(center) 
putpdf image el_cliens_b2b_his.png
putpdf pagebreak
	
	* Export trhough digital channel
graph pie, over(exp_dig) plabel(_all percent, format(%9.0f) size(medium)) graphregion(fcolor(none) lcolor(none)) ///
   bgcolor(white) legend(pos(6)) ///
   title("Export grâce à la présence digitale", pos(12))
   gr export el_exp_dig_pie.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_exp_dig_pie.png
	putpdf pagebreak
	
	*Export practices
graph hbar (mean) exp_pra_foire exp_pra_sci exp_pra_rexp exp_pra_plan exp_pra_norme exp_pra_fin exp_pra_vent exp_pra_ach, percentage over(treatment) blabel(total, format(%9.2fc) gap(-0.2)) ///
	title("Pratiques d'export") ///
	legend (pos(6) row(8) label (1 "Foire/exposition internationale") label(2 "Partenaire commercial") ///
	label(3 "Personne chargée de l'export") label(4 "Plan d'exportation") ///
	label(5 "Certification") label(6 "Financement externe") label(7 "Structure de vente") label(8 "Intérêt par un acheteur étranger"))  ///
	ylabel(0(10)40, nogrid)    
gr export el_export_practices.png, replace
putpdf paragraph, halign(center) 
putpdf image el_export_practices.png
putpdf pagebreak
}
***********************************************************************	
putpdf paragraph,  font("Courier", 20)
putpdf text ("Section 6: Accounting"), bold
{

    * Chiffre d'affaires total en dt en 2023 
stripplot comp_ca2023, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Chiffre d'affaires total en dt en 2023") ///
		name(el_comp_ca2023, replace)
    gr export el_comp_ca2023.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_comp_ca2023.png
	putpdf pagebreak
	
 graph box comp_ca2023 if comp_ca2023 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Chiffre d'affaires total en dt en 2023", pos(12))
gr export el_comp_ca2023_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_comp_ca2023_box.png
putpdf pagebreak

    * Chiffre d'affaires total en dt en 2024 
stripplot comp_ca2024, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Chiffre d'affaires total en dt en 2024") ///
		name(el_comp_ca2024, replace)
    gr export el_comp_ca2024.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_comp_ca2024.png
	putpdf pagebreak
	
 graph box comp_ca2024 if comp_ca2024 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Chiffre d'affaires total en dt en 2024", pos(12))
gr export el_comp_ca2024_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_comp_ca2024_box.png
putpdf pagebreak

   *Chiffre d'affaires à l’export en dt en 2023
stripplot compexp_2023, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Chiffre d'affaires à l’export en dt en 2023") ///
		name(el_compexp_2023, replace)
    gr export el_compexp_2023.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_compexp_2023.png
	putpdf pagebreak
	
 graph box compexp_2023 if compexp_2023 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Chiffre d'affaires à l’export en dt en 2023", pos(12))
gr export el_compexp_2023_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_compexp_2023_box.png
putpdf pagebreak

   *Chiffre d'affaires à l’export en dt en 2024
stripplot compexp_2024, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Chiffre d'affaires à l’export en dt en 2024") ///
		name(el_compexp_2024, replace)
    gr export el_compexp_2024.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_compexp_2024.png
	putpdf pagebreak
	
 graph box compexp_2024 if compexp_2024 > 0, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Chiffre d'affaires à l’export en dt en 2024", pos(12))
gr export el_compexp_2024_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_compexp_2024_box.png
putpdf pagebreak

 *Profit en dt en 2023
stripplot comp_benefice2023, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Profit en dt en 2023") ///
		name(el_comp_benefice2023, replace)
    gr export el_comp_benefice2023.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_compexp_2023.png
	putpdf pagebreak
	
 graph box comp_benefice2023, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Profit en dt en 2023", pos(12))
gr export el_comp_benefice2023_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_comp_benefice2023_box.png
putpdf pagebreak

 *Profit en dt en 2024
stripplot comp_benefice2024, jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Profit en dt en 2024") ///
		name(el_comp_benefice2024, replace)
    gr export el_comp_benefice2024.png, replace
	putpdf paragraph, halign(center) 
	putpdf image el_compexp_2024.png
	putpdf pagebreak
	
 graph box comp_benefice2024, over(treatment) blabel(total, format(%9.2fc)) ///
	title("Profit en dt en 2024", pos(12))
gr export el_comp_benefice2024_box.png, replace
putpdf paragraph, halign(center) 
putpdf image el_comp_benefice2024_box.png
putpdf pagebreak
}
***********************************************************************
* 	PART 4:  save pdf
***********************************************************************
	* change directory to progress folder

	* pdf
putpdf save "endline_statistics", replace
