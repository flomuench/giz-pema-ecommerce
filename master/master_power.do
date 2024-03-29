***********************************************************************
* 			Descriptive Statistics in master file with different survey rounds*					  
***********************************************************************
*																	  
*	PURPOSE: Re-do power calculations with final outcome variables.					  
*																	  
*	OUTLINE: 	PART 1: Baseline and take-up
*				PART 2: Mid-line	  
*				PART 3: Endline 
*				PART 4: Intertemporal descriptive statistics															
*																	  
*	Author:  	Fabian Scheifele							    
*	ID variable: id_platforme		  					  
*	Requires:  	 ecommerce_data_final.dta

use "${master_intermediate}/ecommerce_master_final", clear
		
		* change directory for outputs
cd "${master_gdrive}/output/power"
***********************************************************************
* 	PART 1: Primary outcome 1: E-commerce adoption
***********************************************************************										  
	
	* create excel document
putexcel set power_e-commerce2, replace

	* define table title
putexcel A1 = "Power calculations", bold border(bottom) left
	
	* create top border for variable names
putexcel B1:E1 = "PH 1", border(top)
putexcel F1 = "PH 2", border(top)
putexcel G1:I1 = "PH 3", border(top)
putexcel J1:K1 = "SH", border(top)

	* define column headings
putexcel A2 = "", border(bottom) 
putexcel B2 = "E-commerce practices index", border(bottom) 
putexcel C2 = "Digital Marketing Practices Index (z-score)"
putexcel D2 = "Any E-commerce sales (binary)", border(bottom) 
putexcel E2 = "E-commerce sales (IHS trans.)", border(bottom) 
putexcel F2 = "Number of FB likes (IHS trans.)", border(bottom) 
putexcel G2 = "Export at all", border(bottom) 
putexcel H2 = "Export sales (IHS trans.)", border(bottom) 
putexcel I2 = "Countries exported", border(bottom) 
putexcel J2 = "E-commerce/Dig.Marketing Knowledge Index", border(bottom) 
putexcel K2 = "Domestic Revenue (IHS trans.)", border(bottom) 


*putexcel K2 = "Number of e-commerce channels"
*putexcel L2 = "Export preparation index"

* define first column
putexcel A3 = "A. Parameters from baseline data", bold left

*define row headings
putexcel A4 = "Baseline mean", 
putexcel A5 = "Baseline SD", 
putexcel A6 = "Residual SD", 
putexcel A7 = "autocorrelation between baseline and follow-up values", 
putexcel A8 = "B.Assumption on treatment effect and take-up",bold
putexcel A9 = "Treatment effect on treated", 
putexcel A10= "Take-up", 
putexcel A11= "Average treatment effect (take-up adjusted)", 
putexcel A12 = "as a percentage change", 
putexcel A13 = "C. Power of take-up adjusted treatment effect", bold left
putexcel A14 = "comparison of means", 
putexcel A15 = "after controll for strata", 
putexcel A16 = "Ancova 1-year before", 
putexcel A17 = "D. MDE at 80% power and 66% take up (compare with assumed ToT)", bold left
putexcel A18 = "comparison of means", 
putexcel A19 = "after controlling for strata", 
putexcel A20 = "Ancova (controlling for BL and strata)", 
putexcel A21 = "Notes:", bold
putexcel A22 = "Assuming a survey attrition of 10% at endline, reducing sample from 236 to 212 firms"
putexcel A23 = "MDE = minimum detectable effect size."
putexcel A24 = "Residual SD is standard deviation after controlling for strata fixed effects."
putexcel A25 = "Autocorrelation come from baseline survey held in Feb 2022."
putexcel A26 = "For index variables with mean of zero percentage change was omitted."

***********************************************************************
* 	PART 2:    estimate power 
***********************************************************************
***********************************************************************
* 	PART 2.1:     get all the relevant baseline parameters
***********************************************************************
capture program drop power
program define power /* opens a program called power */
	sum `1' if treatment == 0
	scalar `1'_blmean = r(mean)  
	scalar `1'_blsd = r(sd)
	putexcel `2'4 = `1'_blmean, hcenter nformat(number_d2)
	putexcel `2'5 = `1'_blsd, hcenter nformat(number_d2)
	regress `1' i.strata, vce(hc3)
	scalar `1'_ressd = sqrt(1 - e(r2))
	scalar `1'_ressd = `1'_blsd * `1'_ressd
	putexcel `2'6 = `1'_ressd, hcenter nformat(number_d2)
	putexcel `2'7 = 0.8, hcenter nformat(number_d2)
	putexcel `2'9 = `3', hcenter nformat(number_d2)
	putexcel `2'10 = 0.66, hcenter nformat(number_d2)
	putexcel `2'11 = 0.66*`3', hcenter nformat(number_d2)
	putexcel `2'12 = ((0.66*`3'/`1'_blmean)*100), hcenter nformat(number_d2)
	
end
*Assuming 15 pp increase for exporter status in 2023*
power exporter2020 G 0.15
*Assuming 10% increase in exports (10% increase is 0.095 in IHS units)
power ihs_exports H  0.095
*Assuming one additional market (on average) for those participating in training
power exp_pays_21 I 1
*assuming a 1/4 SD (0.672) as an effect on the index
power dig_presence_weightedz B 0.17

*an 15-percentage point increase in the share of companies with online sales to over 50%
power dig_vente D 0.15

*assuming a 1/4 SD (0.66) as an effect on the index
power knowledge J 0.165

*Assuming 10% increase in revenue
power ihs_w_dom_rev2020 K 0.095

*Assuming 20% increase in revenue
power ihs_w_facebook_likes F 0.18

*assuming 16 pp increase in dig_marketing (0.25 SD) after adjusting for take up
power dig_marketing_index C 0.16

*e-commerce sales, assuming 50% increase vis-a-vis control group
power ihs_w_compdrev E 0.5



*assuming 0.19 increase in average number of online channels
*power dig_presence_score K 0.19

*assuming 0.2 (0.33 SD) increase in export preparation activities
*power expprep L 0.2

*For IHS figure precentage change equals the mean difference, needs to be adjusted manually
putexcel H12=6.7, hcenter nformat(number_d2)
putexcel K12=11.0

*For z-score indice , percentage change does not make any sense, hence remove

putexcel J12=""
putexcel C12=""

***********************************************************************
* 	PART 2.2:  Calculating power (manual part, as sampsi does not take locals)
***********************************************************************
* we assume attrition = 0.1 (hence control group goes from 119 to 107, treatment group 117 to 105)
***********************************************************************
* 	PART 2.2.:     export at all
***********************************************************************
	* comparison of means
sampsi 0.76 0.86, n1(107) n2(105) sd1(0.43) sd2(0.43)
local power = r(power)
putexcel G14 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 0.76 0.86, n1(107) n2(105) sd1(0.29) sd2(0.29)
local power = r(power)
putexcel G15 = `power', hcenter nformat(number_d2)

	* Ancova 1 year Gefore
sampsi 0.76 0.86, n1(107) n2(105) sd1(0.29) sd2(0.29) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel G16 = `power', hcenter nformat(number_d2)

*MDE at 80% power
	* comparison of means
sampsi 0.76 0.93, n1(107) n2(105) sd1(0.43) sd2(0.43)
local power = r(power)
*dividing Gy 0.66 to get take-up adjusted effect
putexcel G18 = 0.257, hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 0.76 0.88, n1(107) n2(105) sd1(0.29) sd2(0.29)
local power = r(power)
*dividing Gy 0.66 to get take-up adjusted effect
putexcel G19 = 0.18, hcenter nformat(number_d2)

	* Ancova 1 year Gefore
sampsi 0.76 0.83, n1(107) n2(105) sd1(0.29) sd2(0.29) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel G20 = 0.106, hcenter nformat(number_d2)

***********************************************************************
* 	PART 2.3.:     IHS export sales
***********************************************************************
	* comparison of means
sampsi 10.04 10.103, n1(107) n2(105) sd1(6.24) sd2(6.24)
local power = r(power)
putexcel H14 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 10.04 10.103, n1(107) n2(105) sd1(3.28) sd2(3.28)
local power = r(power)
putexcel H15 = `power', hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 10.04 10.103, n1(107) n2(105) sd1(3.28) sd2(3.28) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel H16 = `power', hcenter nformat(number_d2)

*MDE at 80% power
	* comparison of means
sampsi 10.04 12.5, n1(107) n2(105) sd1(6.24) sd2(6.24)
local power = r(power)
putexcel H18 = 3.73, hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 10.04 11.3, n1(107) n2(105) sd1(3.28) sd2(3.28)
local power = r(power)
putexcel H19 = 1.91, hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 10.04 10.8, n1(107) n2(105) sd1(3.28) sd2(3.28) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel H20 = 1.15, hcenter nformat(number_d2)

***********************************************************************
* 	PART 2.3.:     Number of countries
***********************************************************************
	* comparison of means
sampsi 3.07 3.74, n1(107) n2(105) sd1(4.65) sd2(4.65)
local power = r(power)
putexcel I14 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 3.07 3.74, n1(107) n2(105) sd1(3.70) sd2(3.70)
local power = r(power)
putexcel I15 = `power', hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 3.07 3.74, n1(107) n2(105) sd1(3.70) sd2(3.70) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel I16 = `power', hcenter nformat(number_d2)

*MIE at 80% power
	* comparison of means
sampsi 3.07 4.9, n1(107) n2(105) sd1(4.65) sd2(4.65)
local power = r(power)
putexcel I18 = 2.77, hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 3.07 4.5, n1(107) n2(105) sd1(3.70) sd2(3.70)
local power = r(power)
putexcel I19 = 2.17, hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 3.07 3.93, n1(107) n2(105) sd1(3.70) sd2(3.70) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel I20 = 1.30, hcenter nformat(number_d2)

*Since we have 66% take-up it means that the average number of countries for the treated 
*needs to increase by 0.86/0.66=1.3 countries

***********************************************************************
* 	PART 2.4.:     E-commerce presence index(dig_presence_weightedz)
***********************************************************************
	* comparison of means
sampsi 0.18 0.29, n1(107) n2(105) sd1(0.61) sd2(0.61)
local power = r(power)
putexcel B14 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 0.18 0.29, n1(107) n2(105) sd1(0.45) sd2(0.45)
local power = r(power)
putexcel B15 = `power', hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 0.18 0.29, n1(107) n2(105) sd1(0.45) sd2(0.45) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel B16 = `power', hcenter nformat(number_d2)

*MDB at 80% power 
* comparison of means
sampsi 0.18 0.42, n1(107) n2(105) sd1(0.61) sd2(0.61)
local power = r(power)
putexcel B18 = 0.36, hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 0.18 0.36, n1(107) n2(105) sd1(0.45) sd2(0.45)
local power = r(power)
putexcel B19 = 0.27, hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 0.18 0.29, n1(107) n2(105) sd1(0.45) sd2(0.45) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel B20 = 0.17, hcenter nformat(number_d2)

***********************************************************************
* 	PART 2.5.:     Binary e-commerce sales variable (dig_vente)
***********************************************************************
	* comparison of means
sampsi 0.4 0.5, n1(107) n2(105) sd1(0.49) sd2(0.49)
local power = r(power)
putexcel D14 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 0.4 0.5, n1(107) n2(105) sd1(0.41) sd2(0.41)
local power = r(power)
putexcel D15 = `power', hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 0.4 0.5, n1(107) n2(105) sd1(0.41) sd2(0.41) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel D16 = `power', hcenter nformat(number_d2)

*MDE at 80%
* comparison of means
sampsi 0.4 0.59, n1(107) n2(105) sd1(0.49) sd2(0.49)
local power = r(power)
putexcel D18 = 0.29, hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 0.4 0.56, n1(107) n2(105) sd1(0.41) sd2(0.41)
local power = r(power)
putexcel D19 = 0.24, hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 0.4 0.5, n1(107) n2(105) sd1(0.41) sd2(0.41) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel D20 = 0.15, hcenter nformat(number_d2)

***********************************************************************
* 	PART 2.5.:     E-commerce knowledge (knowledge)
***********************************************************************
	* comparison of means
sampsi 0 0.11, n1(107) n2(105) sd1(0.69) sd2(0.69)
local power = r(power)
putexcel J14 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 0 0.11, n1(107) n2(105) sd1(0.52) sd2(0.52)
local power = r(power)
putexcel J15 = `power', hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 0 0.11, n1(107) n2(105) sd1(0.52) sd2(0.52) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel J16 = `power', hcenter nformat(number_d2)

*MDE at 80%power
	* comparison of means
sampsi 0 0.27, n1(107) n2(105) sd1(0.69) sd2(0.69)
local power = r(power)
putexcel J18 = 0.41, hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 0 0.2, n1(107) n2(105) sd1(0.52) sd2(0.52)
local power = r(power)
putexcel J19 = 0.3, hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 0 0.12, n1(107) n2(105) sd1(0.52) sd2(0.52) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel J20 = 0.18, hcenter nformat(number_d2)

***********************************************************************
* 	PART 2.5.:     Domestic revenue
***********************************************************************
	* comparison of means
sampsi 10.54 10.603, n1(107) n2(105) sd1(6.79) sd2(6.79)
local power = r(power)
putexcel K14 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 10.54 10.603, n1(107) n2(105) sd1(6.14) sd2(6.14)
local power = r(power)
putexcel K15 = `power', hcenter nformat(number_d2)


	* Ancova 1 year before
sampsi 10.54 10.603, n1(107) n2(105) sd1(6.14) sd2(6.14) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel K16 = `power', hcenter nformat(number_d2)

*MDE at 80%power
	* comparison of means
sampsi 10.54 13.2, n1(107) n2(105) sd1(6.79) sd2(6.79)
local power = r(power)
putexcel K18 = 4.03, hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 10.54 12.9, n1(107) n2(105) sd1(6.14) sd2(6.14)
local power = r(power)
putexcel K19 = 3.58, hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 10.54 12, n1(107) n2(105) sd1(6.14) sd2(6.14) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel K20 = 2.21, hcenter nformat(number_d2)

***********************************************************************
* 	PART 2.5.:     Facebook followers (IHS-transformed)
***********************************************************************
	* comparison of means
sampsi 8.33 8.45, n1(107) n2(105) sd1(2.62) sd2(2.62)
local power = r(power)
putexcel F14 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 8.33 8.45, n1(107) n2(105) sd1(2.38) sd2(2.38)
local power = r(power)
putexcel F15 = `power', hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 8.33 8.45, n1(107) n2(105) sd1(2.38) sd2(2.38) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel F16 = `power', hcenter nformat(number_d2)

*MDE at 80%power
	* comparison of means
sampsi 8.33 9.34, n1(107) n2(105) sd1(2.62) sd2(2.62)
local power = r(power)
putexcel F18 = 1.53, hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 8.33 9.25, n1(107) n2(105) sd1(2.38) sd2(2.38)
local power = r(power)
putexcel F19 = 1.39, hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 8.33 8.9, n1(107) n2(105) sd1(2.38) sd2(2.38) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel F20 = 0.86, hcenter nformat(number_d2)


***********************************************************************
* 	PART 2.6.:     Digital marketing practices Index
***********************************************************************
	* comparison of means
sampsi 0 0.11, n1(107) n2(105) sd1(0.6) sd2(0.6)
local power = r(power)
putexcel C14 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 0 0.11, n1(107) n2(105)  sd1(0.39) sd2(0.39)
local power = r(power)
putexcel C15 = `power', hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 0 0.11, n1(107) n2(105)  sd1(0.39) sd2(0.39) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel C16 = `power', hcenter nformat(number_d2)

*MDE at 80%power
	* comparison of means
sampsi 0 0.23, n1(107) n2(105) sd1(0.6) sd2(0.6)
local power = r(power)
putexcel C18 = 0.35, hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 0 0.15, n1(107) n2(105)  sd1(0.39) sd2(0.39)
local power = r(power)
putexcel C19 = 0.23, hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 0 0.09, n1(107) n2(105)  sd1(0.39) sd2(0.39) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel C20 = 0.136, hcenter nformat(number_d2)

***********************************************************************
* 	PART 2.6.:     E-commerce sales ihs-transformed(ihs_w_compdrev)
***********************************************************************
	* comparison of means
sampsi 3.43 3.93, n1(107) n2(105) sd1(5.24) sd2(5.24)
local power = r(power)
putexcel E14 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi  3.43 3.93, n1(107) n2(105)  sd1(4.20) sd2(4.20)
local power = r(power)
putexcel E15 = `power', hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 3.43 3.93, n1(107) n2(105)  sd1(4.20) sd2(4.20) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel E16 = `power', hcenter nformat(number_d2)

*MDE at 80%power
	* comparison of means
sampsi 3.43 5.5, n1(107) n2(105) sd1(5.24) sd2(5.24)
local power = r(power)
putexcel E18 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi  3.43 5.05, n1(107) n2(105)  sd1(4.20) sd2(4.20)
local power = r(power)
putexcel E19 = `power', hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 3.43 4.4, n1(107) n2(105)  sd1(4.20) sd2(4.20) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel E20 = `power', hcenter nformat(number_d2)


***********************************************************************
* 	PART 2.6.:     Number of e-commerce channels
***********************************************************************
/*	* comparison of means
sampsi 1.84 1.97, n1(107) n2(105) sd1(0.68) sd2(0.68)
local power = r(power)
putexcel K14 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 1.84 1.97, n1(107) n2(105) sd1(0.53) sd2(0.53)
local power = r(power)
putexcel K15 = `power', hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 1.84 1.97, n1(107) n2(105) sd1(0.53) sd2(0.53) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel K16 = `power', hcenter nformat(number_d2)

	* comparison of means
sampsi 1.84 2.1, n1(107) n2(105) sd1(0.68) sd2(0.68)
local power = r(power)
putexcel K18 = 0.39, hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 1.84 2.05, n1(107) n2(105) sd1(0.53) sd2(0.53)
local power = r(power)
putexcel K19 = 0.32, hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 1.84 1.97, n1(107) n2(105) sd1(0.53) sd2(0.53) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel K20 = 0.2, hcenter nformat(number_d2)
*/
***********************************************************************
* 	PART 2.7.:     Export preparation index 
***********************************************************************
/*sampsi 0 0.13, n1(107) n2(105) sd1(0.60) sd2(0.60)
local power = r(power)
putexcel L14 = `power', hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 0 0.13, n1(107) n2(105) sd1(0.52) sd2(0.52)
local power = r(power)
putexcel L15 = `power', hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 0 0.13, n1(107) n2(105) sd1(0.52) sd2(0.52) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel L16 = `power', hcenter nformat(number_d2)

	* comparison of means
sampsi 0 0.23, n1(107) n2(105) sd1(0.60) sd2(0.60)
local power = r(power)
*dividing by 0.66 to get the effect required for the treated
putexcel L18 = 0.35, hcenter nformat(number_d2)

	* after controlling for strata_final --> add
sampsi 0 0.2, n1(107) n2(105) sd1(0.52) sd2(0.52)
local power = r(power)
*dividing by 0.66 to get the effect required for the treated
putexcel L19 = 0.30, hcenter nformat(number_d2)

	* Ancova 1 year before
sampsi 0 0.12, n1(107) n2(105) sd1(0.52) sd2(0.52) pre(1) post(1) r1(0.8)
local power = r(power)
putexcel L20 = 0.18, hcenter nformat(number_d2)*/
