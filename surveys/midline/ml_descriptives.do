***********************************************************************
* 			midline progress, firm characteristics
***********************************************************************
*																	   
*	PURPOSE: 		Create statistics on firms
*	OUTLINE:														  
*	1)				progress		  		  			
*	2)  			eligibility					 
*	3)  			characteristics							  
*																	  
*	ID variaregise: 	id (example: f101)			  					  
*	Requires: ml_inter.dta 
*	Creates:  midline_statistics.pdf		  
*																	  
***********************************************************************
* 	PART 1:  set environment + create pdf file for export		  			
***********************************************************************
	* import file
use "$ml_final/ml_final", clear

*merge with master contact data to identify non-responder
*preserve
preserve
merge 1:1 id_plateforme using "${master_gdrive}/pii/ecommerce_master_contact"
keep   if _merge==2 
keep if status== "participant"
export excel id_plateforme firmname nom_rep status present emailrep telrep rg_telpdg ///
	tel_supl1 tel_supl2 tel_sup1 tel_sup2 using"${master_gdrive}/pii/entreprise_restant_formé.xlsx", ///
	firstrow(var) sheetreplace
restore

	* set directory to checks folder
cd "$ml_output"

*merge treatment info for stats
merge 1:1 id_plateforme using "${master_gdrive}/pii/ecommerce_master_contact"
keep if _merge==3

	* create pdf document
putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("E-commerce: survey progress, firm characteristics"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak


***********************************************************************
* 	PART 2:  Survey progress		  			
***********************************************************************
putpdf paragraph, halign(center) 
putpdf text ("E-commerce training: survey progress")

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
graph bar (count), over(formation) blabel(total) ///
	name(formation, replace) ///
	ytitle("nombre d'entreprises") ///
	title("Participation dans les journées de formation")
graph export grouperate.png, replace
putpdf paragraph, halign(center)
putpdf image grouperate.png
putpdf pagebreak

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
		tlabel(05oct2022(1)01nov2022, angle(60) labsize(vsmall)) ///
		ytitle("responses") ///
		title("{bf:Midline survey: number of responses}") 
gr export survey_response_byday.png, replace
putpdf paragraph, halign(center) 
putpdf image survey_response_byday.png
putpdf pagebreak

***********************************************************************
* 	PART 3:  Variables checking		  			
***********************************************************************	
     * variable dig_revenues_ecom:
 stripplot dig_revenues_ecom, jitter(4) vertical yline(2, lcolor(red)) ///
		ytitle("Revenus digitaux des entreprises") ///
		name(dig_revenues_ecom, replace)
    gr export dig_revenues_ecom.png, replace
	putpdf paragraph, halign(center) 
	putpdf image dig_revenues_ecom.png
	putpdf pagebreak 

    * variable employees
stripplot fte, jitter(4) vertical yline(2, lcolor(red)) ///
		ytitle("Nombre d'employés") ///
		name(fte, replace)
    gr export empl.png, replace
	putpdf paragraph, halign(center) 
	putpdf image empl.png
	putpdf pagebreak
	
	
	*Variable présence digitale
betterbar dig_presence1 dig_presence2 dig_presence3, over(formation) ci barlab ///
	title("Présence sur les canaux de communication") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export presence_digital.png, replace 
putpdf paragraph, halign(center) 
putpdf image presence_digital.png
putpdf pagebreak
	
	
	*Variable descriptions digitale
betterbar dig_description1 dig_description2 dig_description3, over(formation) ci barlab ///
	title("Description de l'entreprise et des produits") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export description_digital.png, replace 
putpdf paragraph, halign(center) 
putpdf image description_digital.png
putpdf pagebreak


	*Variable mise à jour
betterbar dig_miseajour1 dig_miseajour2 dig_miseajour3,over(formation) ci barlab ///
	title("Fréquence de mise à jour") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export description_digital.png, replace 
putpdf paragraph, halign(center) 
putpdf image description_digital.png
putpdf pagebreak

	*Variable paiement digital
betterbar dig_payment1 dig_payment2 dig_payment3, over(formation) ci barlab ///
	title("Paiment digital") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export paiement_digital.png, replace 
putpdf paragraph, halign(center) 
putpdf image paiement_digital.png
putpdf pagebreak

	*Variable perception digital
betterbar dig_perception1 dig_perception2 dig_perception3 dig_perception4 dig_perception5, over(formation) ci barlab ///
	title("Peception digital") ///
	ylabel(,labsize(vsmall) angle(horizontal))
graph export perception_digital.png, replace 
putpdf paragraph, halign(center) 
putpdf image perception_digital.png
putpdf pagebreak

tw ///
	(kdensity dig_perception if formation == 1, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dig_perception if formation == 1, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dig_perception if formation == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dig_perception if formation == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Full sample}") ///
	subtitle("{it:Absolute points (between 0 & 5)}", size(vsmall)) ///
	xtitle("Perception digitale", size(vsmall)) ///
	ytitle("Number of observations", axis(1) size(vsmall)) ///
	ytitle("Densitiy", axis(2) size(vsmall)) ///	
	legend(symxsize(small) order(1 "Treatment group" 2 "Control group")) 
	graph export perception_digitale.png, replace 
	putpdf paragraph, halign(center) 
	putpdf image perception_digitale.png
	putpdf pagebreak
	
	
	*Knowledge questions
tw ///
	(kdensity dig_con1_ml if formation == 1, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dig_con1_ml if formation == 1, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dig_con1_ml if formation == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dig_con1_ml if formation == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Full sample}") ///
	subtitle("{it:Absolute points (between -1 & 1)}", size(vsmall)) ///
	xtitle("Knowledge question 1: Means of payment", size(vsmall)) ///
	ytitle("Number of observations", axis(1) size(vsmall)) ///
	ytitle("Densitiy", axis(2) size(vsmall)) ///	
	legend(symxsize(small) order(1 "Treatment group" 2 "Control group")) 
	graph export knowledge_question1.png, replace 
	putpdf paragraph, halign(center) 
	putpdf image knowledge_question1.png
	putpdf pagebreak

				
tw ///
	(kdensity dig_con2_ml if formation == 1, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dig_con2_ml if formation == 1, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dig_con2_ml if formation == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dig_con2_ml if formation == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Full sample}") ///
	subtitle("{it:Absolute points (between -1 & 1)}", size(vsmall)) ///
	xtitle("Knowledge question 2: Content Marketing", size(vsmall)) ///
	ytitle("Number of observations", axis(1) size(vsmall)) ///
	ytitle("Densitiy", axis(2) size(vsmall)) ///	
	legend(symxsize(small) order(1 "Treatment group" 2 "Control group")) 
	graph export knowledge_question2.png, replace 
	putpdf paragraph, halign(center) 
	putpdf image knowledge_question2.png
	putpdf pagebreak
	
tw ///
	(kdensity dig_con3_ml if formation == 1, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dig_con3_ml if formation == 1, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dig_con3_ml if formation == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dig_con3_ml if formation == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Full sample}") ///
	subtitle("{it:Absolute points (between -1 & 1)}", size(vsmall)) ///
	xtitle("Knowledge question 3: Google Analytics", size(vsmall)) ///
	ytitle("Number of observations", axis(1) size(vsmall)) ///
	ytitle("Densitiy", axis(2) size(vsmall)) ///	
	legend(symxsize(small) order(1 "Treatment group" 2 "Control group")) 
	graph export knowledge_question3.png, replace 
	putpdf paragraph, halign(center) 
	putpdf image knowledge_question3.png
	putpdf pagebreak

tw ///
	(kdensity dig_con4_ml if formation == 1, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dig_con4_ml if formation == 1, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dig_con4_ml if formation == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dig_con4_ml if formation == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Full sample}") ///
	subtitle("{it:Absolute points (between -1 & 1)}", size(vsmall)) ///
	xtitle("Knowledge question 4: Engagement rate", size(vsmall)) ///
	ytitle("Number of observations", axis(1) size(vsmall)) ///
	ytitle("Densitiy", axis(2) size(vsmall)) ///	
	legend(symxsize(small) order(1 "Treatment group" 2 "Control group")) 
	graph export knowledge_question4.png, replace 
	putpdf paragraph, halign(center) 
	putpdf image knowledge_question4.png
	putpdf pagebreak	
tw ///
	(kdensity dig_con5_ml if formation == 1, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dig_con5_ml if formation == 1, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dig_con5_ml if formation == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dig_con5_ml if formation == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Full sample}") ///
	subtitle("{it:Absolute points (between -1 & 1)}", size(vsmall)) ///
	xtitle("Knowledge question 5: SEO", size(vsmall)) ///
	ytitle("Number of observations", axis(1) size(vsmall)) ///
	ytitle("Densitiy", axis(2) size(vsmall)) ///	
	legend(symxsize(small) order(1 "Treatment group" 2 "Control group")) 
	graph export knowledge_question5.png, replace 
	putpdf paragraph, halign(center) 
	putpdf image knowledge_question5.png
	putpdf pagebreak	
	
***********************************************************************
* 	PART 4:  save pdf
***********************************************************************
	* change directory to progress folder

	* pdf
putpdf save "midline_statistics", replace
