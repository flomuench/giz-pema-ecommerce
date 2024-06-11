***********************************************************************
*				ecommerce: Heterogeneity Analysis - Endline
***********************************************************************
*																	   
*	PURPOSE: 
* 
*	OUTLINE:
*	0)		Set the stage
*	1)		Sectoral heterogeneity
*	2)		Product/Service heterogeneity
*	3)		B2B/B2C heterogeneity
*	4)		Size Heterogeneity
*																
*	Author: Ayoub Chamakhi 				         													      
*	id_plateforme variable: id_plateforme			  			
*	Requires:				ecommerce_master_final.dta 	   								
*	Creates:				regression tables & coefplots		   					
*
***********************************************************************
* 	PART 0.1: 	set the stage - import data	  
***********************************************************************

use "${master_final}/ecommerce_master_final", clear
		
		* change directory
cd "${master_gdrive}/output/endline_regressions"

	* xtset data to enable use of lag operator for inclusion of baseline value of Y
xtset id_plateforme surveyround

*enable colors
set scheme s1color

***********************************************************************
* 	PART 0.2:  set the stage - 	write program for Anderson sharpened q-values
***********************************************************************
{
	* source 1:https://blogs.worldbank.org/impactevaluations/updated-overview-multiple-hypothesis-testing-commands-stata
	* source 2: are.berkeley.edu/~mlanderson/downloads/fdr_sharpened_qvalues.do.zip
	* source 3: https://are.berkeley.edu/~mlanderson/pdf/Anderson%202008a.pdf
capture program drop qvalues
program qvalues 
	* settings
		version 10
		syntax varlist(max=1 numeric) // where varlist is a variable containing all the `varlist'
		* Collect N of p-values
			quietly sum `varlist'
			local totalpvals = r(N)

		* Sort the p-values in ascending order and generate a variable that codes each p-value's rank
			quietly gen int original_sorting_order = _n
			quietly sort `varlist'
			quietly gen int rank = _n if `varlist'~=.

		* Set the initial counter to 1 
			local qval = 1

		* Generate the variable that will contain the BKY (2006) sharpened q-values
			gen bky06_qval = 1 if `varlist'~=.

		* Set up a loop that begins by checking which hypotheses are rejected at q = 1.000, then checks which hypotheses are rejected at q = 0.999, then checks which hypotheses are rejected at q = 0.998, etc.  The loop ends by checking which hypotheses are rejected at q = 0.001.
			while `qval' > 0 {
			* First Stage
				local qval_adj = `qval'/(1+`qval') 					
				gen fdr_temp1 = `qval_adj'*rank/`totalpvals'
				gen reject_temp1 = (fdr_temp1>=`varlist') if `varlist'~=.
				gen reject_rank1 = reject_temp1*rank
				egen total_rejected1 = max(reject_rank1)
			* Second Stage
				local qval_2st = `qval_adj'*(`totalpvals'/(`totalpvals'-total_rejected1[1]))
				gen fdr_temp2 = `qval_2st'*rank/`totalpvals'
				gen reject_temp2 = (fdr_temp2>=`varlist') if `varlist'~=.
				gen reject_rank2 = reject_temp2*rank
				egen total_rejected2 = max(reject_rank2)

			* A p-value has been rejected at level q if its rank is less than or equal to the rank of the max p-value that meets the above condition
				replace bky06_qval = `qval' if rank <= total_rejected2 & rank~=.
			* Reduce q by 0.001 and repeat loop
				drop fdr_temp* reject_temp* reject_rank* total_rejected*
				local qval = `qval' - .001
			}
			

		quietly sort original_sorting_order

		display "Code has completed."
		display "Benjamini Krieger Yekutieli (2006) sharpened q-vals are in variable 'bky06_qval'"
		display	"Sorting order is the same as the original vector of p-values"
	version 16
	
	end  

}

***********************************************************************
* 	PART 0.3:  set the stage - 	write program for Romano-Wolf fw errors
***********************************************************************
{
*for 4 conditions & 9 vars
{
capture program drop wolf4
program wolf4
	args ind1 ind2 var1 var2 var3 var4 var5 var6 var7 var8 var9 cond1 cond2 cond3 cond4 surveyround name
	version 16
rwolf2 ///
		(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata_final if `16' & `12', cluster(id_plateforme)) ///
		(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata_final (take_up = treatment) if `16' & `12', cluster(id_plateforme)) ///
		(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata_final if `16' & `12', cluster(id_plateforme)) ///
		(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata_final (take_up = treatment) if `16' & `12', cluster(id_plateforme)) ///
		(reg `5' treatment `5'_y0 i.missing_bl_`5' i.strata_final if `16' & `12', cluster(id_plateforme)) ///
		(ivreg2 `5' `5'_y0 i.missing_bl_`5' i.strata_final (take_up = treatment) if `16' & `12', cluster(id_plateforme)) ///
		(reg `6' treatment `6'_y0 i.missing_bl_`6' i.strata_final if `16' & `12', cluster(id_plateforme)) ///
		(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata_final (take_up = treatment) if `16' & `12', cluster(id_plateforme)) ///
		(reg `7' treatment `7'_y0 i.missing_bl_`7' i.strata_final if `16' & `12', cluster(id_plateforme)) ///
		(ivreg2 `7' `7'_y0 i.missing_bl_`7' i.strata_final (take_up = treatment) if `16' & `12', cluster(id_plateforme)) ///
		(reg `8' treatment `8'_y0 i.missing_bl_`8' i.strata_final if `16' & `12', cluster(id_plateforme)) ///
		(ivreg2 `8' `8'_y0 i.missing_bl_`8' i.strata_final (take_up = treatment) if `16' & `12', cluster(id_plateforme)) ///
		(reg `9' treatment `9'_y0 i.missing_bl_`9' i.strata_final if `16' & `12', cluster(id_plateforme)) ///
		(ivreg2 `9' `9'_y0 i.missing_bl_`9' i.strata_final (take_up = treatment) if `16' & `12', cluster(id_plateforme)) ///
		(reg `10' treatment `10'_y0 i.missing_bl_`10' i.strata_final if `16' & `12', cluster(id_plateforme)) ///
		(ivreg2 `10' `10'_y0 i.missing_bl_`10' i.strata_final (take_up = treatment) if `16' & `12', cluster(id_plateforme)) ///
		(reg `11' treatment `11'_y0 i.missing_bl_`11' i.strata_final if `16' & `12', cluster(id_plateforme)) ///
		(ivreg2 `11' `11'_y0 i.missing_bl_`11' i.strata_final (take_up = treatment) if `16' & `12', cluster(id_plateforme)) ///
		(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata_final if `16' & `13', cluster(id_plateforme)) ///
		(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata_final (take_up = treatment) if `16' & `13', cluster(id_plateforme)) ///
		(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata_final if `16' & `13', cluster(id_plateforme)) ///
		(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata_final (take_up = treatment) if `16' & `13', cluster(id_plateforme)) ///
		(reg `5' treatment `5'_y0 i.missing_bl_`5' i.strata_final if `16' & `13', cluster(id_plateforme)) ///
		(ivreg2 `5' `5'_y0 i.missing_bl_`5' i.strata_final (take_up = treatment) if `16' & `13', cluster(id_plateforme)) ///
		(reg `6' treatment `6'_y0 i.missing_bl_`6' i.strata_final if `16' & `13', cluster(id_plateforme)) ///
		(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata_final (take_up = treatment) if `16' & `13', cluster(id_plateforme)) ///
		(reg `7' treatment `7'_y0 i.missing_bl_`7' i.strata_final if `16' & `13', cluster(id_plateforme)) ///
		(ivreg2 `7' `7'_y0 i.missing_bl_`7' i.strata_final (take_up = treatment) if `16' & `13', cluster(id_plateforme)) ///
		(reg `8' treatment `8'_y0 i.missing_bl_`8' i.strata_final if `16' & `13', cluster(id_plateforme)) ///
		(ivreg2 `8' `8'_y0 i.missing_bl_`8' i.strata_final (take_up = treatment) if `16' & `13', cluster(id_plateforme)) ///
		(reg `9' treatment `9'_y0 i.missing_bl_`9' i.strata_final if `16' & `13', cluster(id_plateforme)) ///
		(ivreg2 `9' `9'_y0 i.missing_bl_`9' i.strata_final (take_up = treatment) if `16' & `13', cluster(id_plateforme)) ///
		(reg `10' treatment `10'_y0 i.missing_bl_`10' i.strata_final if `16' & `13', cluster(id_plateforme)) ///
		(ivreg2 `10' `10'_y0 i.missing_bl_`10' i.strata_final (take_up = treatment) if `16' & `13', cluster(id_plateforme)) ///
		(reg `11' treatment `11'_y0 i.missing_bl_`11' i.strata_final if `16' & `13', cluster(id_plateforme)) ///
		(ivreg2 `11' `11'_y0 i.missing_bl_`11' i.strata_final (take_up = treatment) if `16' & `13', cluster(id_plateforme)) ///
		(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata_final if `16' & `14', cluster(id_plateforme)) ///
		(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata_final (take_up = treatment) if `16' & `14', cluster(id_plateforme)) ///
		(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata_final if `16' & `14', cluster(id_plateforme)) ///
		(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata_final (take_up = treatment) if `16' & `14', cluster(id_plateforme)) ///
		(reg `5' treatment `5'_y0 i.missing_bl_`5' i.strata_final if `16' & `14', cluster(id_plateforme)) ///
		(ivreg2 `5' `5'_y0 i.missing_bl_`5' i.strata_final (take_up = treatment) if `16' & `14', cluster(id_plateforme)) ///
		(reg `6' treatment `6'_y0 i.missing_bl_`6' i.strata_final if `16' & `14', cluster(id_plateforme)) ///
		(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata_final (take_up = treatment) if `16' & `14', cluster(id_plateforme)) ///
		(reg `7' treatment `7'_y0 i.missing_bl_`7' i.strata_final if `16' & `14', cluster(id_plateforme)) ///
		(ivreg2 `7' `7'_y0 i.missing_bl_`7' i.strata_final (take_up = treatment) if `16' & `14', cluster(id_plateforme)) ///
		(reg `8' treatment `8'_y0 i.missing_bl_`8' i.strata_final if `16' & `14', cluster(id_plateforme)) ///
		(ivreg2 `8' `8'_y0 i.missing_bl_`8' i.strata_final (take_up = treatment) if `16' & `14', cluster(id_plateforme)) ///
		(reg `9' treatment `9'_y0 i.missing_bl_`9' i.strata_final if `16' & `14', cluster(id_plateforme)) ///
		(ivreg2 `9' `9'_y0 i.missing_bl_`9' i.strata_final (take_up = treatment) if `16' & `14', cluster(id_plateforme)) ///
		(reg `10' treatment `10'_y0 i.missing_bl_`10' i.strata_final if `16' & `14', cluster(id_plateforme)) ///
		(ivreg2 `10' `10'_y0 i.missing_bl_`10' i.strata_final (take_up = treatment) if `16' & `14', cluster(id_plateforme)) ///
		(reg `11' treatment `11'_y0 i.missing_bl_`11' i.strata_final if `16' & `14', cluster(id_plateforme)) ///
		(ivreg2 `11' `11'_y0 i.missing_bl_`11' i.strata_final (take_up = treatment) if `16' & `14', cluster(id_plateforme)) ///
		(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata_final if `16' & `15', cluster(id_plateforme)) ///
		(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata_final (take_up = treatment) if `16' & `15', cluster(id_plateforme)) ///
		(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata_final if `16' & `15', cluster(id_plateforme)) ///
		(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata_final (take_up = treatment) if `16' & `15', cluster(id_plateforme)) ///
		(reg `5' treatment `5'_y0 i.missing_bl_`5' i.strata_final if `16' & `15', cluster(id_plateforme)) ///
		(ivreg2 `5' `5'_y0 i.missing_bl_`5' i.strata_final (take_up = treatment) if `16' & `15', cluster(id_plateforme)) ///
		(reg `6' treatment `6'_y0 i.missing_bl_`6' i.strata_final if `16' & `15', cluster(id_plateforme)) ///
		(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata_final (take_up = treatment) if `16' & `15', cluster(id_plateforme)) ///
		(reg `7' treatment `7'_y0 i.missing_bl_`7' i.strata_final if `16' & `15', cluster(id_plateforme)) ///
		(ivreg2 `7' `7'_y0 i.missing_bl_`7' i.strata_final (take_up = treatment) if `16' & `15', cluster(id_plateforme)) ///
		(reg `8' treatment `8'_y0 i.missing_bl_`8' i.strata_final if `16' & `15', cluster(id_plateforme)) ///
		(ivreg2 `8' `8'_y0 i.missing_bl_`8' i.strata_final (take_up = treatment) if `16' & `15', cluster(id_plateforme)) ///
		(reg `9' treatment `9'_y0 i.missing_bl_`9' i.strata_final if `16' & `15', cluster(id_plateforme)) ///
		(ivreg2 `9' `9'_y0 i.missing_bl_`9' i.strata_final (take_up = treatment) if `16' & `15', cluster(id_plateforme)) ///
		(reg `10' treatment `10'_y0 i.missing_bl_`10' i.strata_final if `16' & `15', cluster(id_plateforme)) ///
		(ivreg2 `10' `10'_y0 i.missing_bl_`10' i.strata_final (take_up = treatment) if `16' & `15', cluster(id_plateforme)) ///
		(reg `11' treatment `11'_y0 i.missing_bl_`11' i.strata_final if `16' & `15', cluster(id_plateforme)) ///
		(ivreg2 `11' `11'_y0 i.missing_bl_`11' i.strata_final (take_up = treatment) if `16' & `15', cluster(id_plateforme)), ///
	indepvars(`1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2') ///
	seed(110723) reps(999) usevalid strata(strata_final)

			* save rw-p-values in a seperate table for manual insertion in latex document
esttab e(RW) using "${master_regressiontables}/midline/`17'", replace
	
end
}

*for 3 conditions & 9 vars
{
capture program drop wolf3
program wolf3
	args ind1 ind2 var1 var2 var3 var4 var5 var6 var7 var8 var9 cond1 cond2 cond3 surveyround name
	version 16
rwolf2 ///
		(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata_final if `15' & `12', cluster(id_plateforme)) ///
		(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata_final (take_up = treatment) if `15' & `12', cluster(id_plateforme)) ///
		(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata_final if `15' & `12', cluster(id_plateforme)) ///
		(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata_final (take_up = treatment) if `15' & `12', cluster(id_plateforme)) ///
		(reg `5' treatment `5'_y0 i.missing_bl_`5' i.strata_final if `15' & `12', cluster(id_plateforme)) ///
		(ivreg2 `5' `5'_y0 i.missing_bl_`5' i.strata_final (take_up = treatment) if `15' & `12', cluster(id_plateforme)) ///
		(reg `6' treatment `6'_y0 i.missing_bl_`6' i.strata_final if `15' & `12', cluster(id_plateforme)) ///
		(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata_final (take_up = treatment) if `15' & `12', cluster(id_plateforme)) ///
		(reg `7' treatment `7'_y0 i.missing_bl_`7' i.strata_final if `15' & `12', cluster(id_plateforme)) ///
		(ivreg2 `7' `7'_y0 i.missing_bl_`7' i.strata_final (take_up = treatment) if `15' & `12', cluster(id_plateforme)) ///
		(reg `8' treatment `8'_y0 i.missing_bl_`8' i.strata_final if `15' & `12', cluster(id_plateforme)) ///
		(ivreg2 `8' `8'_y0 i.missing_bl_`8' i.strata_final (take_up = treatment) if `15' & `12', cluster(id_plateforme)) ///
		(reg `9' treatment `9'_y0 i.missing_bl_`9' i.strata_final if `15' & `12', cluster(id_plateforme)) ///
		(ivreg2 `9' `9'_y0 i.missing_bl_`9' i.strata_final (take_up = treatment) if `15' & `12', cluster(id_plateforme)) ///
		(reg `10' treatment `10'_y0 i.missing_bl_`10' i.strata_final if `15' & `12', cluster(id_plateforme)) ///
		(ivreg2 `10' `10'_y0 i.missing_bl_`10' i.strata_final (take_up = treatment) if `15' & `12', cluster(id_plateforme)) ///
		(reg `11' treatment `11'_y0 i.missing_bl_`11' i.strata_final if `15' & `12', cluster(id_plateforme)) ///
		(ivreg2 `11' `11'_y0 i.missing_bl_`11' i.strata_final (take_up = treatment) if `15' & `12', cluster(id_plateforme)) ///
		(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata_final if `15' & `13', cluster(id_plateforme)) ///
		(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata_final (take_up = treatment) if `15' & `13', cluster(id_plateforme)) ///
		(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata_final if `15' & `13', cluster(id_plateforme)) ///
		(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata_final (take_up = treatment) if `15' & `13', cluster(id_plateforme)) ///
		(reg `5' treatment `5'_y0 i.missing_bl_`5' i.strata_final if `15' & `13', cluster(id_plateforme)) ///
		(ivreg2 `5' `5'_y0 i.missing_bl_`5' i.strata_final (take_up = treatment) if `15' & `13', cluster(id_plateforme)) ///
		(reg `6' treatment `6'_y0 i.missing_bl_`6' i.strata_final if `15' & `13', cluster(id_plateforme)) ///
		(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata_final (take_up = treatment) if `15' & `13', cluster(id_plateforme)) ///
		(reg `7' treatment `7'_y0 i.missing_bl_`7' i.strata_final if `15' & `13', cluster(id_plateforme)) ///
		(ivreg2 `7' `7'_y0 i.missing_bl_`7' i.strata_final (take_up = treatment) if `15' & `13', cluster(id_plateforme)) ///
		(reg `8' treatment `8'_y0 i.missing_bl_`8' i.strata_final if `15' & `13', cluster(id_plateforme)) ///
		(ivreg2 `8' `8'_y0 i.missing_bl_`8' i.strata_final (take_up = treatment) if `15' & `13', cluster(id_plateforme)) ///
		(reg `9' treatment `9'_y0 i.missing_bl_`9' i.strata_final if `15' & `13', cluster(id_plateforme)) ///
		(ivreg2 `9' `9'_y0 i.missing_bl_`9' i.strata_final (take_up = treatment) if `15' & `13', cluster(id_plateforme)) ///
		(reg `10' treatment `10'_y0 i.missing_bl_`10' i.strata_final if `15' & `13', cluster(id_plateforme)) ///
		(ivreg2 `10' `10'_y0 i.missing_bl_`10' i.strata_final (take_up = treatment) if `15' & `13', cluster(id_plateforme)) ///
		(reg `11' treatment `11'_y0 i.missing_bl_`11' i.strata_final if `15' & `13', cluster(id_plateforme)) ///
		(ivreg2 `11' `11'_y0 i.missing_bl_`11' i.strata_final (take_up = treatment) if `15' & `13', cluster(id_plateforme)) ///
		(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata_final if `15' & `14', cluster(id_plateforme)) ///
		(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata_final (take_up = treatment) if `15' & `14', cluster(id_plateforme)) ///
		(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata_final if `15' & `14', cluster(id_plateforme)) ///
		(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata_final (take_up = treatment) if `15' & `14', cluster(id_plateforme)) ///
		(reg `5' treatment `5'_y0 i.missing_bl_`5' i.strata_final if `15' & `14', cluster(id_plateforme)) ///
		(ivreg2 `5' `5'_y0 i.missing_bl_`5' i.strata_final (take_up = treatment) if `15' & `14', cluster(id_plateforme)) ///
		(reg `6' treatment `6'_y0 i.missing_bl_`6' i.strata_final if `15' & `14', cluster(id_plateforme)) ///
		(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata_final (take_up = treatment) if `15' & `14', cluster(id_plateforme)) ///
		(reg `7' treatment `7'_y0 i.missing_bl_`7' i.strata_final if `15' & `14', cluster(id_plateforme)) ///
		(ivreg2 `7' `7'_y0 i.missing_bl_`7' i.strata_final (take_up = treatment) if `15' & `14', cluster(id_plateforme)) ///
		(reg `8' treatment `8'_y0 i.missing_bl_`8' i.strata_final if `15' & `14', cluster(id_plateforme)) ///
		(ivreg2 `8' `8'_y0 i.missing_bl_`8' i.strata_final (take_up = treatment) if `15' & `14', cluster(id_plateforme)) ///
		(reg `9' treatment `9'_y0 i.missing_bl_`9' i.strata_final if `15' & `14', cluster(id_plateforme)) ///
		(ivreg2 `9' `9'_y0 i.missing_bl_`9' i.strata_final (take_up = treatment) if `15' & `14', cluster(id_plateforme)) ///
		(reg `10' treatment `10'_y0 i.missing_bl_`10' i.strata_final if `15' & `14', cluster(id_plateforme)) ///
		(ivreg2 `10' `10'_y0 i.missing_bl_`10' i.strata_final (take_up = treatment) if `15' & `14', cluster(id_plateforme)) ///
		(reg `11' treatment `11'_y0 i.missing_bl_`11' i.strata_final if `15' & `14', cluster(id_plateforme)) ///
		(ivreg2 `11' `11'_y0 i.missing_bl_`11' i.strata_final (take_up = treatment) if `15' & `14', cluster(id_plateforme)), ///
	indepvars(`1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2') ///
	seed(110723) reps(999) usevalid strata(strata_final)

			* save rw-p-values in a seperate table for manual insertion in latex document
esttab e(RW) using "${master_regressiontables}/midline/`16'", replace
	
end
}

*for 2 conditions & 9 vars
{
capture program drop wolf2
program wolf2
	args ind1 ind2 var1 var2 var3 var4 var5 var6 var7 var8 var9 cond1 cond2 surveyround name
	version 16
rwolf2 ///
		(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata_final if `14' & `12', cluster(id_plateforme)) ///
		(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata_final (take_up = treatment) if `14' & `12', cluster(id_plateforme)) ///
		(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata_final if `14' & `12', cluster(id_plateforme)) ///
		(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata_final (take_up = treatment) if `14' & `12', cluster(id_plateforme)) ///
		(reg `5' treatment `5'_y0 i.missing_bl_`5' i.strata_final if `14' & `12', cluster(id_plateforme)) ///
		(ivreg2 `5' `5'_y0 i.missing_bl_`5' i.strata_final (take_up = treatment) if `14' & `12', cluster(id_plateforme)) ///
		(reg `6' treatment `6'_y0 i.missing_bl_`6' i.strata_final if `14' & `12', cluster(id_plateforme)) ///
		(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata_final (take_up = treatment) if `14' & `12', cluster(id_plateforme)) ///
		(reg `7' treatment `7'_y0 i.missing_bl_`7' i.strata_final if `14' & `12', cluster(id_plateforme)) ///
		(ivreg2 `7' `7'_y0 i.missing_bl_`7' i.strata_final (take_up = treatment) if `14' & `12', cluster(id_plateforme)) ///
		(reg `8' treatment `8'_y0 i.missing_bl_`8' i.strata_final if `14' & `12', cluster(id_plateforme)) ///
		(ivreg2 `8' `8'_y0 i.missing_bl_`8' i.strata_final (take_up = treatment) if `14' & `12', cluster(id_plateforme)) ///
		(reg `9' treatment `9'_y0 i.missing_bl_`9' i.strata_final if `14' & `12', cluster(id_plateforme)) ///
		(ivreg2 `9' `9'_y0 i.missing_bl_`9' i.strata_final (take_up = treatment) if `14' & `12', cluster(id_plateforme)) ///
		(reg `10' treatment `10'_y0 i.missing_bl_`10' i.strata_final if `14' & `12', cluster(id_plateforme)) ///
		(ivreg2 `10' `10'_y0 i.missing_bl_`10' i.strata_final (take_up = treatment) if `14' & `12', cluster(id_plateforme)) ///
		(reg `11' treatment `11'_y0 i.missing_bl_`11' i.strata_final if `14' & `12', cluster(id_plateforme)) ///
		(ivreg2 `11' `11'_y0 i.missing_bl_`11' i.strata_final (take_up = treatment) if `14' & `12', cluster(id_plateforme)) ///
		(reg `3' treatment `3'_y0 i.missing_bl_`3' i.strata_final if `14' & `13', cluster(id_plateforme)) ///
		(ivreg2 `3' `3'_y0 i.missing_bl_`3' i.strata_final (take_up = treatment) if `14' & `13', cluster(id_plateforme)) ///
		(reg `4' treatment `4'_y0 i.missing_bl_`4' i.strata_final if `14' & `13', cluster(id_plateforme)) ///
		(ivreg2 `4' `4'_y0 i.missing_bl_`4' i.strata_final (take_up = treatment) if `14' & `13', cluster(id_plateforme)) ///
		(reg `5' treatment `5'_y0 i.missing_bl_`5' i.strata_final if `14' & `13', cluster(id_plateforme)) ///
		(ivreg2 `5' `5'_y0 i.missing_bl_`5' i.strata_final (take_up = treatment) if `14' & `13', cluster(id_plateforme)) ///
		(reg `6' treatment `6'_y0 i.missing_bl_`6' i.strata_final if `14' & `13', cluster(id_plateforme)) ///
		(ivreg2 `6' `6'_y0 i.missing_bl_`6' i.strata_final (take_up = treatment) if `14' & `13', cluster(id_plateforme)) ///
		(reg `7' treatment `7'_y0 i.missing_bl_`7' i.strata_final if `14' & `13', cluster(id_plateforme)) ///
		(ivreg2 `7' `7'_y0 i.missing_bl_`7' i.strata_final (take_up = treatment) if `14' & `13', cluster(id_plateforme)) ///
		(reg `8' treatment `8'_y0 i.missing_bl_`8' i.strata_final if `14' & `13', cluster(id_plateforme)) ///
		(ivreg2 `8' `8'_y0 i.missing_bl_`8' i.strata_final (take_up = treatment) if `14' & `13', cluster(id_plateforme)) ///
		(reg `9' treatment `9'_y0 i.missing_bl_`9' i.strata_final if `14' & `13', cluster(id_plateforme)) ///
		(ivreg2 `9' `9'_y0 i.missing_bl_`9' i.strata_final (take_up = treatment) if `14' & `13', cluster(id_plateforme)) ///
		(reg `10' treatment `10'_y0 i.missing_bl_`10' i.strata_final if `14' & `13', cluster(id_plateforme)) ///
		(ivreg2 `10' `10'_y0 i.missing_bl_`10' i.strata_final (take_up = treatment) if `14' & `13', cluster(id_plateforme)) ///
		(reg `11' treatment `11'_y0 i.missing_bl_`11' i.strata_final if `14' & `13', cluster(id_plateforme)) ///
		(ivreg2 `11' `11'_y0 i.missing_bl_`11' i.strata_final (take_up = treatment) if `14' & `13', cluster(id_plateforme)), ///
	indepvars(`1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2', `1', `2') ///
	seed(110724) reps(999) usevalid strata(strata_final)

			* save rw-p-values in a seperate table for manual insertion in latex document
esttab e(RW) using "${master_regressiontables}/midline/`14'", replace
	
end
}
}
***********************************************************************
* 	PART 0.2:  set the stage - 	generate YO + missing baseline dummies
***********************************************************************

{
local ys ///
	dsi dmi dtp dtai eri epi bpi ihs_digrev_99 ihs_ca99_2023 comp_ca2024 ihs_profit99_2023 ihs_profit99_2024 ihs_fte_99 dig_empl car_carempl_div1 car_carempl_div3 ihs_mark_invest_99 ///
	 export_1 exp_pays clients_b2c clients_b2b ihs_ca99_2024 ihs_dig_invest_99
foreach var of local ys {
		* generate YO
	bys id_plateforme (surveyround): gen `var'_first = `var'[_n == 1]		 // filter out baseline value
	egen `var'_y0 = min(`var'_first), by(id_plateforme)					 // create variable = bl value for all three surveyrounds by id_plateforme
	replace `var'_y0 = 0 if inlist(`var'_y0, ., -777, -888, -999)		// replace this variable = zero if missing
	drop `var'_first													// clean up
	lab var `var'_y0 "Y0 `var'"
		* generate missing baseline dummy
	gen miss_bl_`var' = 0 if surveyround == 1											// gen dummy for baseline
	replace miss_bl_`var' = 1 if surveyround == 1 & inlist(`var',., -777, -888, -999)	// replace dummy 1 if variable missing at bl
	egen missing_bl_`var' = min(miss_bl_`var'), by(id_plateforme)									// expand dummy to ml, el
	lab var missing_bl_`var' "YO missing, `var'"
	drop miss_bl_`var'
	}
}

***********************************************************************
* 	PART 1: Sectoral heterogeneity
***********************************************************************
// RWOLF  -- NUMBER OF VARS.
// need to set sectors.

***********************************************************************
* 	PART 2: Product/Service heterogeneity
***********************************************************************
{
{
local outcome "dtai"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "dsi"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital sales index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Sales Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}


{
local outcome "dmi"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital marketing index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "epi"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export perception index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Export Perception Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "dtp"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology perception index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Perception") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "eri"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export readiness index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Export Readiness Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "bpi"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on business performance index by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Business Performance Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "ihs_digrev_99"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "ihs_profit99_2023"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on profit 2023 by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Profit 2023") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "ihs_profit99_2024"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on profit 2024 by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Profit 2024") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "ihs_ca99_2023"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover 2023 by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Turnover 2023") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "ihs_ca99_2024"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover 2024 by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Turnover 2024") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}



{
local outcome "ihs_dig_invest_99"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital investment by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Investment") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}

{
local outcome "dig_empl"
local conditions "inlist(sector,1,2,3,4) !inlist(sector,1,2,3,4)"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital employees by product/service} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_sector1_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Product" "Service", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Product (ITT)"' `outcome'_p2 = `"Product (TOT)"' `outcome'_s1 = `"Service (ITT)"' `outcome'_s2 = `"Service (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Employees") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_sector1_`outcome', replace)
gr export el_het_sector1_`outcome'.png, replace

}
}
***********************************************************************
* 	PART 3: B2C vs. B2B Heterogeneity (entreprise_models)
***********************************************************************
/* NOT ENOUGH SAMPLE SIZE FOR CLIENTS==1
{
{
local outcome "dtai"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dsi"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital sales index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Sales Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dmi"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital marketing index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dtp"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology perception by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Perception") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "eri"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export readiness index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Export Readiness Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "bpi"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on business performance index by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Business Performance Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dig_empl"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export digital employees by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Employees") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dig_revenues_ecom"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "ihs_dig_invest_99"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital investment by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital investment") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "ihs_ca99_2023"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover 2023 by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Turnover 2023") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "ihs_ca99_2024"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover 2024 by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Turnover 2024") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "ihs_profit99_2023"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on profit 2023 by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Profit 2023") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "ihs_profit99_2023"
local conditions "clients==1 clients==2 clients==3"
local groups "c b cb"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on profit 2024 by business model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{8}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_c1 `outcome'_c2 `outcome'_b1 `outcome'_b2 `outcome'_cb1 `outcome'_cb2 
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2C" "B2B" "B2C and B2B", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_c1, pstyle(p1)) (`outcome'_c2, pstyle(p1)) ///
	(`outcome'_b1, pstyle(p2)) (`outcome'_b2, pstyle(p2)) ///
	(`outcome'_cb1, pstyle(p3)) (`outcome'_cb2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_o1 = `"B2C (ITT)"' `outcome'_o2 = `"B2C (TOT)"' `outcome'_b1 = `"B2B (ITT)"' `outcome'_b2 = `"B2B (TOT)"' `outcome'_cb1 = `"B2C & B2B (ITT)"' `outcome'_cb2 = `"B2C & B2B(TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Profit 2024") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}
}
*/
***********************************************************************
* 	PART 4: Size heterogeneity
***********************************************************************
{
*create bl size variable
gen el_size = .

replace el_size = 1 if fte <= 10
replace el_size = 2 if fte > 10 & fte <= 40
replace el_size = 3 if fte > 40

{
local outcome "dtai"
local conditions "el_size==1 el_size==2  el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace


}

{
local outcome "dsi"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital sales index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Sales Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "dmi"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital marketing index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "epi"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export perception index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Export Perception Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "dtp"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology perception by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Perception") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "eri"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export readiness index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Export Readiness Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "bpi"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on business performance index by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Business Performance Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "dig_empl"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital employees by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Employees") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "ihs_digrev_99"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "ihs_dig_invest_99"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digita investment by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Investment") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "ihs_ca99_2023"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover 2023 by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Turnover 2023") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "ihs_ca99_2024"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover 2024 by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Turnover 2024") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "ihs_profit99_2023"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on profit 2023 by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Profit 2023") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}

{
local outcome "ihs_profit99_2024"
local conditions "el_size==1 el_size==2 el_size==3"
local groups "s m l"
foreach cond of local conditions {
		gettoken group groups : groups
			eststo `outcome'_`group'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`group'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2  
esttab `regressions' using "rt_hetero_size_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on profit 2024 by size} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_s1 `outcome'_s2 `outcome'_m1 `outcome'_m2 `outcome'_l1 `outcome'_l2
		esttab `regressions' using "rt_hetero_size_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Small" "Medium" "Large", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_s1, pstyle(p1)) (`outcome'_s2, pstyle(p1)) ///
	(`outcome'_m1, pstyle(p2)) (`outcome'_m2, pstyle(p2)) ///
	(`outcome'_l1, pstyle(p3)) (`outcome'_l2, pstyle(p3)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_s1 = `"Small (ITT)"' `outcome'_s2 = `"Small (TOT)"' `outcome'_m1 = `"Medium (ITT)"' `outcome'_m2 = `"Medium (TOT)"' `outcome'_l1 = `"Large (ITT)"' `outcome'_l2 = `"Large (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Profit 2024") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_size_`outcome', replace)
gr export el_het_size_`outcome'.png, replace

}
}

***********************************************************************
* 	PART 5: B2C vs. B2B Heterogeneity (B2B vs B2B & B2C)
***********************************************************************
{
{
local outcome "dtai"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology index by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dsi"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital sales index by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Sales Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}


{
local outcome "dmi"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital marketing index by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "epi"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export perception index by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Export Perception Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dtp"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology perception index by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Perception") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "eri"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export readiness index by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Export Readiness Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "bpi"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on business performance index by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Business Performance Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "ihs_digrev_99"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "ihs_profit99_2023"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on profit 2023 by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Profit 2023") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "ihs_profit99_2024"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on profit 2024 by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Profit 2024") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "ihs_ca99_2023"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover 2023 by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Turnover 2023") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "ihs_ca99_2024"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover 2024 by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Turnover 2024") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}



{
local outcome "ihs_dig_invest_99"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital investment by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Investment") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}

{
local outcome "dig_empl"
local conditions "clients==2 clients==3"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_model_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital employees by entreprise model} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_model_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("B2B" "B2B & B2C", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"B2B (ITT)"' `outcome'_p2 = `"B2B (TOT)"' `outcome'_s1 = `"B2B & B2C (ITT)"' `outcome'_s2 = `"B2B & B2C (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Employees") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_model_`outcome', replace)
gr export el_het_model_`outcome'.png, replace

}
}

***********************************************************************
* 	PART 5: Per higher margin of online sales
***********************************************************************
{
{
local outcome "dtai"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology index by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}

{
local outcome "dsi"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital sales index by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Sales Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}


{
local outcome "dmi"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital marketing index by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Marketing Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}

{
local outcome "epi"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export perception index by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Export Perception Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}

{
local outcome "dtp"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital technology perception index by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Technology Perception") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}

{
local outcome "eri"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on export readiness index by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Export Readiness Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}

{
local outcome "bpi"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on business performance index by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Business Performance Index") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}

{
local outcome "ihs_digrev_99"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital revenue by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Revenue") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}

{
local outcome "ihs_profit99_2023"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on profit 2023 by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Profit 2023") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}

{
local outcome "ihs_profit99_2024"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on profit 2024 by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Profit 2024") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}

{
local outcome "ihs_ca99_2023"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover 2023 by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Turnover 2023") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}

{
local outcome "ihs_ca99_2024"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on turnover 2024 by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Turnover 2024") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}



{
local outcome "ihs_dig_invest_99"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital investment by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Investment") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}

{
local outcome "dig_empl"
local conditions "dig_margins==0 dig_margins==1"
local sectors "p s"
foreach cond of local conditions {
		gettoken sector sectors : sectors
			eststo `outcome'_`sector'1: reg `outcome' i.treatment c.`outcome'_y0 i.missing_bl_`outcome' i.strata if `cond' & surveyround==3, cluster(id_plateforme)
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,2]

			* ATT, IV		
			eststo `outcome'_`sector'2: ivreg2 `outcome' c.`outcome'_y0 i.missing_bl_`outcome' i.strata (take_up = i.treatment) if `cond' & surveyround==3, cluster(id_plateforme) first
			estadd local bl_control "Yes"
			estadd local strata "Yes"
			matrix b = r(table)			// access p-values for mht
			scalar `outcome'p1 = b[4,1]
			
			* calculate control group mean
				* take mean at endline to control for time trends
sum `outcome' if treatment == 0 & surveyround == 3 & `cond'
estadd scalar control_mean = r(mean)
estadd scalar control_sd = r(sd)
}


	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
esttab `regressions' using "rt_hetero_margin_`outcome'.tex", replace ///
				prehead("\begin{table}[!h] \centering \\ \caption{Treatment effect on digital employees by digital margin} \\ \begin{adjustbox}{width=\columnwidth,center} \\ \begin{tabular}{l*{5}{c}} \hline\hline") ///
				posthead("\hline \\ \multicolumn{3}{c}{\textbf{Panel A: Intention-to-treat (ITT)}} \\\\[-1ex]") ///
				fragment ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				mlabels(, depvars) /// use dep vars labels as model title
				star(* 0.1 ** 0.05 *** 0.01) ///
				nobaselevels ///
				label 		/// specifies EVs have label
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				collabels(none) ///	do not use statistics names below models
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				noobs
				
				* Bottom panel: ITT
	local regressions `outcome'_p1 `outcome'_p2 `outcome'_s1 `outcome'_s2
		esttab `regressions' using "rt_hetero_margin_`outcome'.tex", append ///
				fragment ///
				posthead("\hline \\ \multicolumn{7}{c}{\textbf{Panel B: Treatment Effect on the Treated (TOT)}} \\\\[-1ex]") ///
				cells(b(star fmt(3)) se(par fmt(3)) p(fmt(3)) rw) ///
				stats(control_mean control_sd N strata bl_control, fmt(%9.2fc %9.2fc %9.0g) labels("Control group mean" "Control group SD" "Observations" "Strata controls" "Y0 controls")) ///
				drop(_cons *.strata ?.missing_bl_* *_y0) ///
				star(* 0.1 ** 0.05 *** 0.01) ///
				mgroups("Higher margin" "Not higher margin", ///
				pattern(1 1 1)) ///
				mlabels(none) nonumbers ///		do not use varnames as model titles
				collabels(none) ///	do not use statistics names below models
				nobaselevels ///
				label 		/// specifies EVs have label
				prefoot("\hline") ///
				postfoot("\hline\hline\hline \\ \multicolumn{3}{@{}p{\textwidth}@{}}{ \footnotesize \parbox{\linewidth}{% Notes: Each specification includes controls for randomization strata, baseline outcome, and a missing baseline dummy. QI perception is a z-score indices calculated following Kling et al. (2007). Small corresponds to firms with less or 10 employees, medium more than 10 and less or 40 employees, and large to more than 40 at baseline. Panel A reports ANCOVA estimates as defined in Mckenzie and Bruhn (2011). Panel B documents IV estimates, instrumenting take-up with treatment assignment. Clustered standard errors by firms in parentheses. \sym{***} \(p<0.01\), \sym{**} \(p<0.05\), \sym{*} \(p<0.1\) denote the significance level. P-values and adjusted p-values for multiple hypotheses testing using the Romano-Wolf correction procedure (Clarke et al., 2020) with 999 bootstrap replications are reported below the standard errors.% \\ }} \\ \end{tabular} \\ \end{adjustbox} \\ \end{table}") // when inserting table in overleaf/latex, requires adding space after %
				
			* coefplot
coefplot ///
	(`outcome'_p1, pstyle(p1)) (`outcome'_p2, pstyle(p1)) ///
	(`outcome'_s1, pstyle(p2)) (`outcome'_s2, pstyle(p2)), ///
	keep(*treatment take_up) drop(_cons) xline(0) ///
		asequation /// name of model is used
		swapnames /// swaps coeff & equation names after collecting result
		levels(95) /// 95th percentile is null-effect, although tight
		eqrename(`outcome'_p1 = `"Higher margin (ITT)"' `outcome'_p2 = `"Higher margin (TOT)"' `outcome'_s1 = `"Not higher margin (ITT)"' `outcome'_s2 = `"Not higher margin (TOT)"') ///
		ytitle("", size(medium)) ///
		xtitle("Digital Employees") ///
		leg(off) xsize(4.5) /// xsize controls aspect ratio, makes graph wider & reduces its height
		note("Confidence interval at the 95th percentile.", span size(small)) /// 95th only holds for lare firms
		name(el_het_margin_`outcome', replace)
gr export el_het_margin_`outcome'.png, replace

}
}
