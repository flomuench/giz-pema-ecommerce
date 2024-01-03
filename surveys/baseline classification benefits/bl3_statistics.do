***********************************************************************
* 	statistics do file, benefit classifications baseline e-commerce	  *		  
***********************************************************************
*																	  
*	PURPOSE: Create statistics on social media of SMEs								  
*																	  
*	OUTLINE: 	PART 1: Set environment & create pdf file for export	  
*
*
*
*				PART 4: Save the data
*                         											  
*																	  
*	Author:  			Ayoub Chamakhi				    
*	ID variable: 		id_platforme  					  
*	Requires:  	  		classification_investbenefit_final.dta									  
*	Creates:  			baseline3_statistics.pdf
***********************************************************************
* 	PART 1: Set environment & create pdf file for export	
***********************************************************************

	*import file
use "${bl3_final}/classification_investbenefit_final", clear
	
	* set directory to checks folder
cd "$bl3_output"
set graphics on
set scheme s1color

	* create word document
putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("E-commerce Baseline: Benefit Classfications"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak

***********************************************************************
* 	PART 2: 
***********************************************************************

foreach var in investbenefit1_classified investbenefit2_classified investbenefit3_classified {
    graph bar (count), over(treatment) by(`var') blabel(total, format(%9.0fc) position(inside))
    graph export "`var'_bar_chart.png", replace
	putpdf paragraph, halign(center) 
	putpdf image "`var'_bar_chart.png"
	putpdf pagebreak
	
}

foreach var in investbenefit1_classified investbenefit2_classified investbenefit3_classified {
    graph pie, over(`var') plabel(_all percent) sort descending ///
    title("Pie Chart for `var'") 
    graph export "`var'_pie_chart.png", replace
	putpdf paragraph, halign(center) 
	putpdf image "`var'_pie_chart.png"
	putpdf pagebreak
}


***********************************************************************
* 	PART 4: Save the data
***********************************************************************
	* change directory to progress folder
cd "$bl3_output"
	* pdf
putpdf save "baseline3_statistics", replace
