***********************************************************************
* 			e-commerce endline survey variable generation                    	
***********************************************************************
*																	    
*	PURPOSE: generate variables required for the monitoring of endline survey (no index creation)				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Generate summary variables of multiple answer questions	
*   2)		Generate variables for companies who answered on phone	  				  
* 	3) 		Drop useless variables	
* 	4) 		Change format type	
* 	5) 		generate normalized financial data (per employee)
* 	6) 		Create variable required for coherence test	 	
* 	6) 		Save the changes made to the data
																  															      
*	Author:  	Kaïs Jomaa		  
*	ID variable: 	id (example: f101)			  					  
*	Requires: el_intermediate.dta 	  								  
*	Creates:  el_final.dta			                          
*	
***********************************************************************
* 	PART 1:  Generate summary variables of multiple answer questions 			
***********************************************************************
use "${el_intermediate}/el_intermediate", clear																  

gen surveyround = 3
lab var surveyround "1-baseline 2-midline 3-endline"

* Generate variables for each social medias
gen dig_presence2_sm1 =0
replace dig_presence2_sm1 =1 if ustrregexm(dig_presence2_sm, "1") 

gen dig_presence2_sm2 =0
replace dig_presence2_sm2 =1 if ustrregexm(dig_presence2_sm, "2") 

gen dig_presence2_sm3 =0
replace dig_presence2_sm3 =1 if ustrregexm(dig_presence2_sm, "3") 

gen dig_presence2_sm4 =0
replace dig_presence2_sm4 =1 if ustrregexm(dig_presence2_sm, "4") 
  
gen dig_presence2_sm5 =0
replace dig_presence2_sm5 =1 if ustrregexm(dig_presence2_sm, "5") 
  
gen dig_presence2_sm6 =0
replace dig_presence2_sm6 =1 if ustrregexm(dig_presence2_sm, "6") 
 
drop dig_presence2_sm

lab var dig_presence2_sm1 "Instagram"
lab var dig_presence2_sm2 "Facebook"
lab var dig_presence2_sm3 "Twitter"
lab var dig_presence2_sm4 "Youtube"
lab var dig_presence2_sm5 "LinkedIn"
lab var dig_presence2_sm6 "Others"

rename autresأخرى dig_presence2_sm6_other
lab var dig_presence2_sm6_other "Others Social Medias"

* Generate variables for each maarketplace

gen dig_presence3_plateform1 =0
replace dig_presence3_plateform1 =1 if ustrregexm(dig_presence3_plateform, "1") 

gen dig_presence3_plateform2 =0
replace dig_presence3_plateform2 =1 if ustrregexm(dig_presence3_plateform, "2") 

gen dig_presence3_plateform3 =0
replace dig_presence3_plateform3 =1 if ustrregexm(dig_presence3_plateform, "3") 

gen dig_presence3_plateform4 =0
replace dig_presence3_plateform4 =1 if ustrregexm(dig_presence3_plateform, "4") 

gen dig_presence3_plateform5 =0
replace dig_presence3_plateform5 =1 if ustrregexm(dig_presence3_plateform, "5") 

gen dig_presence3_plateform6 =0
replace dig_presence3_plateform6 =1 if ustrregexm(dig_presence3_plateform, "6") 

gen dig_presence3_plateform7 =0
replace dig_presence3_plateform7 =1 if ustrregexm(dig_presence3_plateform, "7") 

gen dig_presence3_plateform8 =0
replace dig_presence3_plateform8 =1 if ustrregexm(dig_presence3_plateform, "8") 

drop dig_presence3_plateform

lab var dig_presence3_plateform1 "Little Jneina "
lab var dig_presence3_plateform2 "Founa"
lab var dig_presence3_plateform3 "Made in Tunisia"
lab var dig_presence3_plateform4 "Jumia"
lab var dig_presence3_plateform5 "Amazon"
lab var dig_presence3_plateform6 "Ali baba"
lab var dig_presence3_plateform7 "Upwork"
lab var dig_presence3_plateform8 "Autres"

rename y dig_presence3_plateform8_other
lab var dig_presence3_plateform8_other "Others Marketplaces"

*Exporting or not
gen export_1 =0
replace export_1 =1 if ustrregexm(export, "1") 

gen export_2 =0
replace export_2 =1 if ustrregexm(export, "2") 

gen export_3 =0
replace export_3 =1 if ustrregexm(export, "3") 

drop export

label var export_1 "Direct export"
label var export_2 "Indirect export"
label var export_3 "No export"
				
				* reasons for not exporting
gen export_41 =0
replace export_41 =1 if ustrregexm(export_4, "1") 

gen export_42 =0
replace export_42 =1 if ustrregexm(export_4, "2") 

gen export_43 =0
replace export_43 =1 if ustrregexm(export_4, "3") 

gen export_44 =0
replace export_44 =1 if ustrregexm(export_4, "4") 

gen export_45 =0
replace export_45 =1 if ustrregexm(export_4, "5") 

drop export_4

label var export_41 "Not profitable"
label var export_42 "Did not find clients abroad"
label var export_43 "Too complicated"
label var export_44 "Requires too much investment"
label var export_45 "Other"


***********************************************************************
* 	PART 2:  Generate variables for companies who answered on phone	
***********************************************************************
gen survey_phone = 0
lab var survey_phone "Comapnies who answered the survey on phone (with enumerators)" 
*replace survey_phone = 1 if id_plateforme == 95
label define Surveytype 1 "Phone" 0 "En ligne"

***********************************************************************
* 	PART 3:  Drop useless variables		
***********************************************************************

***********************************************************************
* 	PART 4:  Change format type	
***********************************************************************

***********************************************************************
* 	PART 5:  generate normalized financial data (per employee)
***********************************************************************

local varn fte dig_empl mark_invest dig_invest comp_ca2023 comp_ca2024 comp_exp2023 comp_exp2024 comp_benefice2023 comp_benefice2024
/*
foreach x of local varn { 
gen n`x' = .
replace n`x' = `x' if `x' < not_know
replace n`x' = not_know if `x' == not_know
replace n`x' = refused if `x' == refused
replace n`x' = check_again if `x' == check_again
replace n`x' = `x'/employes if n`x'!= not_know | n`x'!= refused | n`x'!= check_again
}
*/
***********************************************************************
* 	PART 6:  Generate export variable for 2023 & 2024 like baseline format
***********************************************************************
gen export2023 = 0
lab var export2023 "exports in 2023"
replace export2023 = 1 if export_3 == 0

gen export2024 = 0
lab var export2024 "exports in 2024"
replace export2024 = 1 if export_3 == 0

**********************************************************************
* 	PART 7:  save			
***********************************************************************
rename *, lower
save "${el_final}/el_final", replace
