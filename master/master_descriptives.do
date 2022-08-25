***********************************************************************
* 			Descriptive Statistics in master file with different survey rounds*					  
***********************************************************************
*																	  
*	PURPOSE: Understand the structure of the data from the different surveyr.					  
*																	  
*	OUTLINE: 	PART 1: Baseline and take-up
*				PART 2: Mid-line	  
*				PART 3: Endline 
*				PART 4: Intertemporal descriptive statistics															
*																	  
*	Author:  	Fabian Scheifele							    
*	ID variable: id_platforme		  					  
*	Requires:  	 ecommerce_data_final.dta

										  
***********************************************************************
* 	PART 1: Baseline and take-up statistics
***********************************************************************
use "${master_intermediate}/ecommerce_master_inter", clear
		
		* change directory to regis folder for merge with regis_final
cd "${master_gdrive}/output"

*Check whether balance table changed with new z-score calculation
iebaltab fte compexp_2020 comp_ca2020 exp_pays_avg export_status dig_revenues_ecom comp_benefice2020 knowledge digtalvars expoutcomes expprep, grpvar(treatment) ftest save(baltab_baseline) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)

			 
*correlation matrix of selected variables
correlate compexp_2020 comp_ca2020 exp_pays_avg export_status dig_revenues_ecom comp_benefice2020 knowledge digtalvars expoutcomes expprep

*What drives participation
logit take_up i.groupe_factor sector subsector fte compexp_2020 comp_ca2020 exp_pays_avg export_status dig_revenues_ecom comp_benefice2020 knowledge digtalvars expoutcomes expprep if treatment==1
logit take_up knowledge if treatment==1
* Scatter plot
graph twoway (lfitci take_up knowledge) (scatter take_up knowledge) if treatment ==1

*Frequency tables by subsector
tab take_up subsector if treatment==1
*OBSERVATION: 11 out of the 38 companies that did not show up for at least 3 trainings are from agriculture. 



***********************************************************************
*** PDF with graphs  			
***********************************************************************
	* create word document
putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("E-commerce: survey progress, firm characteristics"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak


putpdf paragraph, halign(center) 
putpdf text ("E-commerce training: Z scores"), bold linebreak

	* Knowledge of digital Z-scores
	
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

	* Digital Presence
graph hbar (count),  over(dig_presence1) blabel (bar) ///
	title("Number of firms with a website")
graph export dig_presence1.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_presence1.png
putpdf pagebreak

graph hbar (count),  over(dig_presence2) blabel (bar) ///
	title("No. of firms with a social media account")
graph export dig_presence2.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_presence2.png
putpdf pagebreak

graph hbar (count),  over(dig_presence3) blabel (bar) ///
	title("Number of firms present on an online marketplace")
graph export dig_presence3.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_presence3.png
putpdf pagebreak

graph hbar (sum)dig_presence3_ex1 dig_presence3_ex2 dig_presence3_ex3 dig_presence3_ex4 dig_presence3_ex5 dig_presence3_ex6 dig_presence3_ex7 dig_presence3_ex8 ,blabel (bar) ///
legend(label(1 "Little Jneina") label(2 "El Fabrica") label(3 "Savana") label(4 "Jumia") label(5 "Amazon") label(6 "Alibaba") label(7 "Etsy") label(8 "Other")) title("Platforms used at baseline")
graph export platforms_used.png, replace
putpdf paragraph, halign(center) 
putpdf image platforms_used.png
putpdf pagebreak

graph hbar (mean) dig_description1 dig_description2 dig_description3 ///
	dig_miseajour1 dig_miseajour2 dig_miseajour3, blabel (bar) ///
legend(pos(9) cols(1) label(1 "1:Website desc.") label(2 "Social media desc.") label(3 "Platform desc.") label(4 "Website updating") label(5 "Social media updating") label(6 "Platform updating")) ///
title("Description and updating of channel") subtitle ("1= product and firm description, 0.5 product or firm desc. 0.75=weekly update, 0.5=monthly, 0.25=annually")
graph export description_updates.png, replace
putpdf paragraph, halign(center) 
putpdf image description_updates.png
putpdf pagebreak


graph hbar (count), over(dig_payment1) blabel (bar) ///
	title("Website: paying and ordering online") ///
	subtitle("1=paying and ordering, 0.5=ordering only")
graph export dig_payment1.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_payment1.png
putpdf pagebreak

graph hbar (count), over(dig_payment2) blabel (bar) ///
 title("Social Media: paying and ordering online") ///
 subtitle("1=paying and ordering, 0.5=ordering only")
graph export dig_payment2.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_payment2.png
putpdf pagebreak

graph hbar (count), over(dig_payment3) blabel (bar) ///
title("Platform: paying and ordering online") subtitle("1=paying and ordering, 0.5=ordering only")
graph export dig_payment3.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_payment3.png
putpdf pagebreak

*Digital Marketing
graph hbar (sum) dig_marketing_num19_autre dig_marketing_num19_blg ///
 dig_marketing_num19_mail dig_marketing_num19_prtn ///
 dig_marketing_num19_pub dig_marketing_num19_sea dig_marketing_num19_seo ///
 dig_marketing_num19_socm, blabel (bar) ///
legend(pos(9) cols(1) label(1 "1: Other") label(2 "2:Blog") label(3 "3: Mail") label(4 "4: Partnership w/ firm") label(5 "5:Ads") ///
label(6 "6: SEA")label(7 "7: SEO") label(8 "8: Social Media")) ///
title("Digital Marketing Activities, no. of firms")


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


*Scatter plot comparing exports and Chiffre d'affaire (0,44 correlation there are 5 firms with high CA and little or no exports)
corr compexp_2020 comp_ca2020
local corr : di %4.3f r(rho)
twoway scatter compexp_2020 comp_ca2020  || lfit compexp_2020 comp_ca2020, ytitle("Exports in TND") xtitle("Revenue in TND") subtitle(correlation `corr')
graph export raw_exp_ca.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_exp_ca.png
putpdf pagebreak
correlate compexp_2020 comp_ca2020 knowledge digtalvars  

*Scatter plot comparing knowledge and digitalisation index
corr knowledge digtalvars
local corr : di %4.3f r(rho)
twoway scatter knowledge digtalvars  || lfit knowledge digtalvars, ytitle("Knowledge index raw") xtitle("Digitilisation Index raw") subtitle(correlation `corr')
graph export raw_knowledge_digital.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_knowledge_digital.png
putpdf pagebreak

*Scatter plot exports and employees
corr compexp_2020 fte
local corr : di %4.3f r(rho)
twoway scatter compexp_2020 fte  || lfit compexp_2020 fte, ytitle("Exports") xtitle("Number of employes") subtitle(correlation `corr')
graph export raw_exp_fte.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_exp_fte.png
putpdf pagebreak

*Scatter plot revenues and employees
corr comp_ca2020 fte
local corr : di %4.3f r(rho)
twoway scatter comp_ca2020 fte  || lfit comp_ca2020 fte, ytitle("Total Revenues") xtitle("Number of employes") subtitle(correlation `corr')
graph export raw_ca_fte.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_ca_fte.png
putpdf pagebreak


	
***********************************************************************
* 	PART 4:  save pdf
***********************************************************************

putpdf save "baseline_statistics", replace

