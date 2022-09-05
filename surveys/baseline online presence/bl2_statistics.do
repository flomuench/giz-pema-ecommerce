***********************************************************************
* 			statistics do file, second part baseline e-commerce				  
***********************************************************************
*																	  
*	PURPOSE: Create statistics on social media of SMEs								  
*																	  
*	OUTLINE: 	PART 1: Set environment & create pdf file for export	  
*
*

*				PART 4: Save the data
*                         											  
*																	  
*	Author:  			Ayoub Chamakhi & Fabian Scheifele					    
*	ID variable: 		id_platforme  					  
*	Requires:  	  		Webpresence_answers_final.dta									  
*	Creates:  			baseline2_statistics.pdf
***********************************************************************
* 	PART 1: Set environment & create pdf file for export	
***********************************************************************

	*import file
use "${bl2_final}/Webpresence_answers_final", clear
	
	* set directory to checks folder
cd "$bl2_output"

	* create word document
putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("E-commerce: website & social media questionnaire"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak

***********************************************************************
* 	PART 2: 
***********************************************************************

***********************************************************************
* 	PART 4: Save the data
***********************************************************************
	* change directory to progress folder
cd "$bl_output"
	* pdf
putpdf save "baseline2_statistics", replace
