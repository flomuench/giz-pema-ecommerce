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

	* set directory to checks folder
cd "$ml_output"

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

	* total number of firms registered
graph bar (count) id_plateforme, blabel(total) ///
	title("Number of firms that responded") note("Date: `c(current_date)'") ///
	ytitle("Number of complete survey response")
graph export responserate.png, replace
putpdf paragraph, halign(center)
putpdf image responserate.png
putpdf pagebreak


	* timeline of responses
format %-td date 
graph twoway histogram date, frequency width(1) ///
		tlabel(05octobre2022(1)01novembre2022, angle(60) labsize(vsmall)) ///
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
betterbar dig_presence1 dig_presence2 dig_presence3, ci barlab ///
	title("Présence sur les canaux de communication") ///
	ylabel(,labsize(vsmall) angle(vertical))
graph export presence_digital.png, replace 
putpdf paragraph, halign(center) 
putpdf image presence_digital.png
putpdf pagebreak
	
	*Variable descriptions digitale
betterbar dig_description1 dig_description2 dig_description3, ci barlab ///
	title("Description de l'entreprise et des produits") ///
	ylabel(,labsize(vsmall) angle(vertical))
graph export description_digital.png, replace 
putpdf paragraph, halign(center) 
putpdf image description_digital.png
putpdf pagebreak
	
	*Variable mise à jour
betterbar dig_miseajour1 dig_miseajour2 dig_miseajour3, ci barlab ///
	title("Fréquence de mise à jour") ///
	ylabel(,labsize(vsmall) angle(vertical))
graph export description_digital.png, replace 
putpdf paragraph, halign(center) 
putpdf image description_digital.png
putpdf pagebreak
		
	
***********************************************************************
* 	PART 4:  save pdf
***********************************************************************
	* change directory to progress folder

	* pdf
putpdf save "midline_statistics", replace
