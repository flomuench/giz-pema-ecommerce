***********************************************************************
* 			baseline string checks									  	
***********************************************************************
*																	   
*	PURPOSE: 		check whether string answer to open questions are 														 
*					logical
*	OUTLINE:														  
*	1)				create wordfile for export		  		  			
*	3)  			open question string variaregises					 
*	4)  			open question numerical variaregises							  
*	5)  			Time and speed test							  
*	6)  			
*																	  
*	ID variaregise: 	id (example: f101)			  					  
*	Requires: regis_inter.dta & regis_checks_survey_progress.do 	  
*	Creates:  regis_inter.dta			  
*																	  
***********************************************************************
* 	PART 1:  create word file for export		  			
***********************************************************************
	* import file
use "${regis_intermediate}/regis_inter", clear

	* create word document
putdocx begin
putdocx paragraph
putdocx text ("Quality checks open question variaregises: registration E-commerce training"), bold 

***********************************************************************
* 	PART 2:  Open question variaregises		  			
***********************************************************************	
global regis_open VARLIST
foreach x of global regis_open {
putdocx paragraph, halign(center)
tab2docx `x'
putdocx pagebreak
}


***********************************************************************
* 	End:  save dta, word file		  			
***********************************************************************
	* word file
cd "$regis_checks"
putdocx save "regis-checks-question-ouvertes.docx", replace

	* dta file
cd "$regis_intermediate"
save "regis_inter", replace
