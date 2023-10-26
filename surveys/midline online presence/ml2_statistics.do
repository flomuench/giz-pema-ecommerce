***********************************************************************
* 			statistics do file, second part midline e-commerce				  
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
*	Author:  			Ayoub Chamakhi				    
*	ID variable: 		id_platforme  					  
*	Requires:  	  		ml_Webpresence_answers_final.dta									  
*	Creates:  			midline2_statistics.pdf
***********************************************************************
* 	PART 1: Set environment & create pdf file for export	
***********************************************************************

	*import file
use "${ml2_final}/ml_Webpresence_answers_final", clear
	
	* set directory to checks folder
cd "$bl2_output"

	* create word document
putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("E-commerce Midline: website & social media questionnaire"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak

***********************************************************************
* 	PART 2: 
***********************************************************************

***********************************************************************
* 	PART 4: Save the data
***********************************************************************
	* change directory to progress folder
cd "$ml_output"
	* pdf
putpdf save "midline2_statistics", replace
