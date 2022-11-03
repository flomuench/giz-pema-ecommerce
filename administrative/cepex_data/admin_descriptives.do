***********************************************************************
* 			Descriptive Statistics in data admin					  *					  
***********************************************************************
*																	  
*	PURPOSE: Understand the structure of the data from cepex					  
*																	  
*	OUTLINE: 	
*				PART1: Descriptive statistics															
*																	  
*	Author:  	Ayoub Chamakhi							    
*	ID variable: id_platforme		  					  
*	Requires:  	 cp_final.dta

										  
***********************************************************************
* 	PART 1: Descriptive statistics
***********************************************************************


***********************************************************************
*** PDF with graphs  			
***********************************************************************
	* create word document
putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("CEPEX Data: Revenue of firms from export"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak



putpdf pagebreak

putpdf save "${cp_final}/CEPEX_data_descriptives", replace




