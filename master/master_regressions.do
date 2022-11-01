***********************************************************************
* 			Master analysis/regressions				  
***********************************************************************
*																	  
*	PURPOSE: 	Undertake treatment effect analysis of primary and secondary
*				outcomes as well as sub-group/heterogeneity analyses																	  
*
*													
*																	  
*	Author:  	Fabian Scheifele							    
*	ID variable: id_platforme		  					  
*	Requires:  	ecommerce_master_final.dta
*	Creates:

	
***********************************************************************
* 	Part 1: 	Midline analysis			  
***********************************************************************

*E-commerce and digital marketing index

*First replace missing values by zeros and create dummy for these values

/*gen dig_revenues_ecom_miss = 0 
replace dig_revenues_ecom_miss = 1 if dig_revenues_ecom == -999 |dig_revenues_ecom == -888 | ///
dig_revenues_ecom== .

recode dig_revenues_ecom (-999 -888 =.)
replace dig_revenues_ecom = 0 if dig_revenues_ecom==.
*/



*