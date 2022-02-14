 ***********************************************************************
* 			baseline progress, firm characteristics
***********************************************************************
*																	   
*	PURPOSE: 		Create statistics on firms
*	OUTLINE:														  
*	1)				Set environment 		  		  			
*	2)  			Progress
*	3)  			Z-scores							  
*																	  
*	ID variable: 	id_plateforme (example: f101)			  					  
*	Requires: bl_inter.dta 
*	Creates:  baseline_statistics.pdf
*																	  
***********************************************************************
* 	PART 1:  set environment + create pdf file for export		  			
***********************************************************************
	
	* import file
use "${bl_final}/bl_final", clear

	* set directory to checks folder
cd "$bl_output"

	* create word document
putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("E-commerce: survey progress, firm characteristics"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak


/***********************************************************************
* 	PART 2:  Survey progress		  			
***********************************************************************/
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

	* Timeline of responses
	
format %-td date 
graph twoway histogram date, frequency width(1) ///
		tlabel(17jan2022(1)01mar2022, angle(60) labsize(vsmall)) ///
		ytitle("responses") ///
		title("{bf:Baseline survey: number of responses}") 
gr export survey_response_byday.png, replace
putpdf paragraph, halign(center) 
putpdf image survey_response_byday.png
putpdf pagebreak
		


***********************************************************************
*** PART 3: Z Scores 		  			
***********************************************************************

putpdf paragraph, halign(center) 
putpdf text ("E-commerce training: Z scores"), bold linebreak

	* Knowledge of igital Z-scores
	
hist knowledge, ///
	title("Zscores of knowledge of digitalisation scores") ///
	xtitle("Zscores")
graph export knowledge_zscores.png, replace
putpdf paragraph, halign(center) 
putpdf image knowledge_zscores.png
putpdf pagebreak

	* For comparison, the 'raw' index: 
	
hist raw_knowledge, ///
	title("Raw sum of all knowledge scores") ///
	xtitle("Sum")
graph export raw_knowledge.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_knowledge.png
putpdf pagebreak

	* Digital Z-scores
	
hist digtalvars, ///
	title("Zscores of digital scores") ///
	xtitle("Zscores")
graph export digital_zscores.png, replace
putpdf paragraph, halign(center) 
putpdf image digital_zscores.png
putpdf pagebreak

	* For comparison, the 'raw' index: 
	
hist raw_digtalvars, ///
	title("Raw sum of all digital scores") ///
	xtitle("Sum")
graph export raw_digital.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_digital.png
putpdf pagebreak

	* Export preparation Z-scores
	
hist expprep, ///
	title("Zscores of export preparation questions") ///
	xtitle("Zscores")
graph export expprep_zscores.png, replace
putpdf paragraph, halign(center) 
putpdf image expprep_zscores.png
putpdf pagebreak
	
	* For comparison, the 'raw' index:
	
hist raw_expprep, ///
	title("Raw sum of all export preparation questions") ///
	xtitle("Sum")
graph export raw_expprep.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_expprep.png
putpdf pagebreak

	* Export outcomes Z-scores
	
hist expoutcomes, ///
	title("Zscores of export outcomes questions") ///
	xtitle("Zscores")
graph export expoutcomes_zscores.png, replace
putpdf paragraph, halign(center) 
putpdf image expoutcomes_zscores.png
putpdf pagebreak

	* For comparison, the 'raw' index:
	
hist raw_expoutcomes, ///
	title("Raw sum of all export outcomes questions") ///
	xtitle("Sum")
graph export raw_expoutcomes.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_expoutcomes.png
putpdf pagebreak
	
***********************************************************************
* 	PART 4:  save pdf
***********************************************************************

	* change directory to progress folder
cd "$bl_output"
	* pdf
putpdf save "baseline_statistics", replace
