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
cd "${cp_output}"

***********************************************************************
*** PDF with graphs  			
***********************************************************************
	* create word document


putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("CEPEX Data: Revenue of firms from export"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak

graph hbar (mean) VALEUR, over(Year) blabel (total, position(inside))
graph export value_export_peryear.png, replace
putpdf paragraph, halign(center) 
putpdf image value_export_peryear.png
putpdf pagebreak

graph hbar (mean) VALEUR, over(Libelle_Section) blabel (total)
graph export value_export_persection.png, replace
putpdf paragraph, halign(center) 
putpdf image value_export_persection.png
putpdf pagebreak

graph hbar (mean) VALEUR, over(Libelle_Pays_Anglais) blabel (total)
graph export export_per_country.png, replace
putpdf paragraph, halign(center) 
putpdf image export_per_country.png
putpdf pagebreak


putpdf pagebreak

putpdf save "${cp_final}/CEPEX_data_descriptives_ecommerce", replace



**1. Check completeness: For how company do we have admin data and is it equal over the years?
gen data_available==0
replace data_available=1 if value!==. 

count id_platforme if data_available==1

***2. Do we have equal data completeness (% of companies) in treatment and control group




***3. do we similar coverage across sectors, firmsize 



