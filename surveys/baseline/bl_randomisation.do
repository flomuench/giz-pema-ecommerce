***********************************************************************
* 			E-commerce experiment randomisation								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)	 set seed + sort by id_plateforme													  
*	2)	 random allocation
*	3)	 balance table
*	4) 	 generate Excel sheets by treatment status
*																 	 *
*	Author:  	Teo Firpo & Florian Münch													  
*	ID variable: 	id_plateforme			  									  
*	Requires:		bl_final.dta
*	Creates:		bl_final.dta					  
*																	  
***********************************************************************
* 	PART Start: Import the data + set the seed				  		  *
***********************************************************************

	* import data
use "${bl_final}/bl_final", clear

	* change directory to visualisations
cd "$bl_output/randomisation"

	* continue word export
putdocx clear
putdocx begin
putdocx paragraph, halign(center) 
putdocx text ("Results of randomisation"), bold linebreak

***********************************************************************
* 	PART 1: Sort the data
***********************************************************************

	* Set a seed for today

set seed 17022022

	* Sort 
sort id_plateforme, stable


***********************************************************************
* 	PART 2: Randomise
***********************************************************************

	* random allocation, with seed generated random number on random.org between 1 million & 1 billion
randtreat, gen(treatment) strata(strata) misfits(strata) setseed(905661364)

	* label treatment assignment status
lab def treat_status 0 "Control" 1 "Treatment" 
lab values treatment treat_status
tab treatment, missing

	* visualising treatment status by strata
graph hbar (count), over(treatment, lab(labs(tiny))) over(strata, lab(labs(small))) ///
	title("Firms by trial arm within each strata") ///
	blabel(bar, format(%4.0f) size(tiny)) ///
	ylabel(, labsize(minuscule) format(%-100s))
	graph export firms_per_treatmentgroup_strata.png, replace
	putdocx paragraph, halign(center)
	putdocx image firms_per_treatmentgroup_strata.png, width(4)
	
	
***********************************************************************
* 	PART 3: Balance checks
***********************************************************************
		
		* balance for continuous and few units categorical variables
iebaltab fte compexp_2020 comp_ca2020 exp_pays_avg rg_oper_exp dig_revenues_ecom comp_benefice2020 knowledge digtalvars expoutcomes expprep, grpvar(treatment) save(baltab_email_experiment) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
		
		* visualizing balance for categorical variables with multiple categories
graph hbar (count), over(treatment, lab(labs(tiny))) over(sector, lab(labs(vsmall))) ///
	title("Balance across sectors") ///
	blabel(bar, format(%4.0f) size(tiny)) ///
	ylabel(, labsize(minuscule) format(%-100s))
	graph export balance_sectors.png, replace
	putdocx paragraph, halign(center)
	putdocx image balance_sectors.png, width(4)	
		

***********************************************************************
* 	PART 4: Export excel spreadsheet
***********************************************************************			 		
*We have two options here: 1) rename the variables so that the consultant understands them
*2) Send the consultant the codebook and then he can make sense of the variables himself*
* I added a bunch of variables about the firms knowledge and digital presence in case the consultant want to group by ability*
local ecommercelist treatment id_plateforme sector subsector fte car_pdg_age entr_bien_service entr_produit1 ///
entr_produit2 entr_produit3 car_attend1 car_attend2 car_attend3 investcom_benefit3_1 investcom_benefit3_2 investcom_benefit3_3 ///
raw_knowledge raw_digtalvars dig_presence_score dig_marketing_score dig_presence1 dig_presence2 dig_presence3

export excel `ecommercelist' using "ecommerce_listfinale" if treatment==1, sheet("Groupe participants") sheetreplace firstrow(var) 
export excel `ecommercelist' using "ecommerce_listfinale" if treatment==0, sheet("Groupe control") sheetreplace firstrow(var) 

	* save word document with visualisations
putdocx save results_randomisation.docx, replace

	* save dta file with treatments and strata

cd "$bl_final"

save "bl_final", replace












