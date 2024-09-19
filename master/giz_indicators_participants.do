***********************************************************************
* 			Descriptive Statistics in master file for endline survey  *					  
***********************************************************************

* Load data
use "${master_final}/ecommerce_master_final", clear
set graphics on		
cd "${master_gdrive}/output/giz_el_simplified"

* Subset data for participants only
keep if treatment==1 & take_up==1

* Start Word Document
putdocx clear
putdocx begin

* Title
putdocx paragraph, style(Title)
putdocx text ("GIZ-CEPEX: E-commerce and digital marketing: All participants (66)")

putdocx textblock begin
The following statistics are based on online and telephone responses to a baseline (before start of the activity) and endline (2-year after the project start) survey among all the 66  firms that took part in at least 3 out of 5 workshop and 1 digital activity (Web/Social Media).Note that a full stop (.) indicates that the question was not asked in a specific survey wave.Further note that results pertain to all among the 66 firms that responded to a specific question in the respective surveyround. This includes also firms that dropped-out late in the project.

putdocx textblock end

* Export preparation indicators
putdocx paragraph, style(Heading1)
putdocx text ("Export preparation - Sub-Sahara-Africa (SSA)")
putdocx textblock begin
The first table displays the number of firms among the 117 treatment group firms that engaged in one of the five intermediary export steps.
putdocx textblock end

* Label variables




* Create tables
dtable, by(surveyround,nototal) /// 
    factor(ssa_action1, statistics(fvfrequency fvproportion)) /// 
    factor(ssa_action2, statistics(fvfrequency fvproportion)) /// 
    factor(ssa_action3, statistics(fvfrequency fvproportion)) /// 
    factor(ssa_action4, statistics(fvfrequency fvproportion)) /// 
    factor(ssa_action5, statistics(fvfrequency fvproportion)) /// 
    factor(ssa_any, statistics(fvfrequency fvproportion)) /// 
    sformat("(%s)" fvproportion) /// 
    nformat(%9.0g  fvfrequency) /// 
    nformat(%9.2fc fvproportion)
* export(ssa.docx, replace)
putdocx collect

*All second surveyround
summarize ssa_any if surveyround==2, meanonly
local sum_ssa_ml = r(sum)
di `sum_ssa_ml'

*improvers third surveyround
summarize ssa_any_abs_growth if surveyround==3, meanonly
local sum_ssa_improved = r(sum) 
 di `sum_ssa_improved'
local sum_total = `sum_ssa_ml' + `sum_ssa_improved'

 
* Female second surveyround
gen sum_ssa_ml_female = (ssa_any == 1 & rg_gender_pdg == 1 & surveyround==2)
summarize sum_ssa_ml_female, meanonly
local sum_ssa_ml_female = r(sum)
di `sum_ssa_ml_female'

*improvers female  third surveyround
summarize ssa_any_abs_growth if surveyround==3  & rg_gender_pdg == 1, meanonly
local sum_ssa_improved_female = r(sum)
di `sum_ssa_improved_female'
local sum_female= `sum_ssa_ml_female' + `sum_ssa_improved_female'


putdocx paragraph

putdocx text ("How many out of the 66 participating firms report an improvement in the different categories?")
* Create tables
dtable, by(surveyround,nototal) /// 
    factor(ssa_action1_abs_growth, statistics(fvfrequency fvproportion)) /// 
    factor(ssa_action2_abs_growth, statistics(fvfrequency fvproportion)) /// 
    factor(ssa_action3_abs_growth, statistics(fvfrequency fvproportion)) /// 
    factor(ssa_action4_abs_growth, statistics(fvfrequency fvproportion)) /// 
    factor(ssa_action5_abs_growth, statistics(fvfrequency fvproportion)) /// 
	factor(ssa_any_abs_growth, statistics(fvfrequency fvproportion)) /// 
    sformat("(%s)" fvproportion) /// 
    nformat(%9.0g  fvfrequency) /// 
    nformat(%9.2fc fvproportion)
* export(ssa.docx, replace)
putdocx collect

putdocx paragraph

putdocx text ("Overall, `sum_total'  (`sum_female' female-led) out of the 69 firms that participated, report an improvement either at midline or endline survey (or in both, but no overlaps) in at least one of the 5 export practices measured and displayed in the table above")

***********************************************************************
* 	PART 3: KPIs (CA, CA exp, profit, employees)
***********************************************************************
putdocx paragraph, style(Heading1)
putdocx text ("Key Performance Indicators - Total sales, export sales, profits, & employees")
putdocx textblock begin
This section presents the AVERAGE growth rate in firms' key performance indicators from baseline (FY 2020) and endline (2023 or 2024). For the endline, in case a firm reported financial values for both 2023 and 2024, the larger of the two values was picked. 
The average annual PERCENT growth rate or percent change is calculated by subtracting the performance in period t from its value in period t-1, and dividing the result by the t-1 value. For example, the Total sales (% growth) value of 1.45435 is read as 145.435% increase in total sales compared to the baseline value. 
The average annual ABSOLUTE growth rate is simply calculated by subtracting performance during baseline (2020) from its endline value (2023 or 2024 which ever larger). For example, the value -2,305,268 is read as a twenty-five thousand Tunisian Dinar average decrease in total sales between baseline and endline. Whenever average ABSOLUTE growth (in TND) is negative and average RELATIVE growth (in%) is positive, it means that the largest firms had negative sales which reduces the absolute term. 
putdocx textblock end


* Generate tables for KPIs
dtable, by(surveyround,nototal) ///
    continuous(ca_rel_growth ca_abs_growth ///
               ca_exp_rel_growth ca_exp_abs_growth ///
               profit_rel_growth profit_abs_growth ///
               fte_rel_growth fte_abs_growth ///
               car_carempl_div1_rel_growth car_carempl_div1_abs_growth ///
               car_carempl_div2_rel_growth car_carempl_div2_abs_growth, statistics(mean))	   ///
    nformat(%9.0g mean)
*    export(kpis_growth.docx, replace)

putdocx collect

* Export indicators
putdocx paragraph, style(Heading1)
putdocx text ("Export Performance Indicators - Export sales, export countries, clients & orders")
putdocx textblock begin
This section presents the key export performance indicators. 
The variable "exported" is either "yes" or "no" and expresses the share of exporters All other numbers present the mean per surveyround across all among the 66 firms that responded to the specific question in the respective surveyround. Important the values are not the growth rate, hence for number of exports countries the absolute growth is 4.53-3= 1.53 more countries on average per firm or 51% increase. Share of exporters stayed the same. 
putdocx textblock end

* Label variables
lab var exported "Exported"
lab values exported yesno
lab var exp_pays "Number of export countries"

* Create tables for export indicators
dtable, by(surveyround,nototal) ///
	factor(exported, statistics(fvfrequency fvproportion)) ///
	continuous(exp_pays clients clients_b2c clients_b2b, statistics(mean)) 	///
	nformat(%9.2fc  mean fvproportion) ///
	nformat(%9.0g fvfrequency)
* export(export.docx, replace)

putdocx collect

* Save the Word document
putdocx save giz_indicators_participants, replace
