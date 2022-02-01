***********************************************************************
* 			baseline survey checks of string/open questions
***********************************************************************
*																	   
*	PURPOSE: 		check whether string answer to open questions are 														 
*					logical
*	OUTLINE:														  
*	1)				Create wordfile for export		  		  			
*	2)  			Check for & visualise duplicates						 
*	3)  			Open question variables							  
*	6)  			
*																	  
*	ID variaregise: 	id_plateforme (example: 373)			  					  
*	Requires: bl_inter.dta & bl_checks_survey_progress.do 	  
*	Creates:  bl_inter.dta			  
*																	  
***********************************************************************
* 	PART 1:  Create word file for export		  			
***********************************************************************
	* import file
use "${bl_intermediate}/bl_inter", clear

	* set directory to checks folder
cd "$bl_checks"

	* create word document
putdocx begin 
putdocx paragraph
putdocx text ("Quality checks open question variables: baseline E-commerce training"), bold

***********************************************************************
* 	PART 2:  Check for & visualise duplicates		  			
***********************************************************************

		* put all variables to for which we want to check for duplicates into a local
local dupcontrol id_plateforme commentvousappelezvous adresseéléctronique

		* generate a variable = 1 if the observation of the variable has a duplicate
foreach x of local dupcontrol {
gen duplabel`x' = .
duplicates tag `x', gen(dup`x')
replace duplabel`x' = id_plateforme if dup`x' > 0

}
		* visualise and save the visualisations
/*
alternative code for jitter dot plots instead of bar plots which allow to identify the id of the duplicate response:
gen duplabel = .
replace duplabel = id_plateforme if dup_id_admin > 0 | dup_firmname > 0 | dup_rg_nom_rep > 0 | dup_rg_telrep > 0 | dup_rg_emailrep > 0 | dup_rg_telpdg > 0 | dup_rg_emailpdg > 0
stripplot id_plateforme, over(dup_firmname) jitter(4) vertical mlabel(duplabel) /* alternative: scatter id_plateforme dup_firmname, jitter(4) mlabel(duplabel) */
code for bar plot:
gr bar (count), over(dup_`x') ///
		name(`x') ///
		title(`x') ///
		ytitle("Nombre des observations") ///
		blabel(bar)
*/		

foreach x of local dupcontrol {
stripplot id_plateforme, over(dup`x') jitter(4) vertical  ///
		name(`x', replace) ///
		title(`x') ///
		ytitle("ID des observations") ///
		mlabel(duplabel`x')
}
		* combine all the graphs into one figure
gr combine `dupcontrol'
gr export duplicates.png, replace
		
		* put the figure into the pdf
putdocx paragraph, halign(center)
putdocx image duplicates.png

		* indicate to RA's where to write code to search & remove duplicates
putdocx paragraph
putdocx text ("Go to do-file 'bl_correct' part 10 'Identify duplicates' to examine & potentially remove duplicates manually/via code."), bold
putdocx pagebreak

***********************************************************************
* 	PART 3:  Open question variables		  			
***********************************************************************

		* define all the variables where respondent had to enter text
local bl_open  investcom_benefit3_1 investcom_benefit3_2 investcom_benefit3_3 expprep_norme2 exp_pays_principal_avant21 /* I removed exp_pays_principal from this line/* /// /* firm characteristics */
	   entr_histoire entr_produit1 entr_produit2 entr_produit3  /// /* personal */
	   id_base_repondent id_repondent_position car_pdg_age /// /* numerical * / 
	   dig_marketing_respons dig_service_responsable investcom_2021 investcom_futur expprep_responsable exp_pays_avant21 exp_pays_21 compexp_2020 comp_ca2020 dig_revenues_ecom comp_benefice2020 car_carempl_div1 car_carempl_dive2 car_carempl_div3 car_adop_peer
				
		* export all the variables into a word document
foreach x of local bl_open {
putdocx paragraph, halign(center)
tab2docx `x'
putdocx pagebreak
}


***********************************************************************
* 	End:  save dta, word file		  			
***********************************************************************
	* word file
cd "$bl_checks"
putdocx save "regis-checks-question-ouvertes.docx", replace
	* restore all the observations


