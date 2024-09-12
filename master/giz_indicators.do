***********************************************************************
* 			Descriptive Statistics in master file for endline survey  *					  
***********************************************************************

* Load data
use "${master_final}/ecommerce_master_final", clear
set graphics on		
cd "${master_gdrive}/output/giz_el_simplified"

* Subset data for participants only
keep if take_up==1 & treatment==1

* Start Word Document
putdocx clear
putdocx begin

* Title
putdocx paragraph, style(Title)
putdocx text ("GIZ-CEPEX: E-commerce and digital marketing")

putdocx textblock begin
The following statistics are based on online and telephone responses to a baseline (before start of the activity), midline (1-year after the project start and after Phase 1 & (5-day workshop and student assistant)) and endline (2-year after the project start) survey among all the 66  firms that took part in at least 3 out of 5 workshop and 1 digital activity (Web/Social Media).
Note that a full stop (.) indicates that the question was not asked in a specific survey wave.
Further note that results pertain to all among the 66 firms that responded to a specific question in the respective surveyround. This includes also firms that dropped-out during the project.
putdocx textblock end

* Export preparation indicators
putdocx paragraph, style(Heading1)
putdocx text ("Export preparation - Sub-Sahara-Africa (SSA)")
putdocx textblock begin
The first table displays the number of firms among the 66 participants that engaged in one of the five intermediary export steps.
putdocx textblock end

* Label variables
lab var ssa_action1 "Buyer expression of interest"
lab var ssa_action2 "Identification commercial partner"
lab var ssa_action3 "External export finance"
lab var ssa_action4 "Investment in sales structure abroad"
lab var ssa_action5 "Digital transaction system"

* Generate 'any export action' variable
egen ssa_any = rowmax(ssa_action1 ssa_action2 ssa_action3 ssa_action4 ssa_action5)
lab var ssa_any "Any of the above"
lab values ssa_any yesno

* Create tables
dtable, by(surveyround, nototal) ///
	factor(ssa_action1, statistics(fvfrequency fvproportion)) ///
	factor(ssa_action2, statistics(fvfrequency fvproportion)) ///
	factor(ssa_action3, statistics(fvfrequency fvproportion)) ///
	factor(ssa_action4, statistics(fvfrequency fvproportion)) ///
	factor(ssa_action5, statistics(fvfrequency fvproportion)) ///
	factor(ssa_any, statistics(fvfrequency fvproportion)) ///
	sformat("(%s)" fvproportion) ///
	nformat(%9.0g  fvfrequency) ///
	nformat(%9.2fc fvproportion)

***********************************************************************
* 	PART 3: KPIs (CA, CA exp, profit, employees)
***********************************************************************
putdocx paragraph, style(Heading1)
putdocx text ("Key Performance Indicators - Total sales, export sales, profits, & employees")
putdocx textblock begin
This section presents the AVERAGE annual growth rate in firms' key performance indicators. 
The average annual PERCENT growth rate or percent change is calculated by subtracting the performance in period t from its value in period t-1, and dividing the result by the t-1 value. For example, the total sales value 1.186 is read as 118.6% increase in total sales. 
The average annual ABSOLUTE growth rate is simply calculated by subtracting performance in period t from its pre-period. For example, the value 25,033.208 is read as a twenty-five thousand Tunisian Dinar average increase in total sales between midline and endline.
putdocx textblock end

* Label variables
lab var ca_rel_growth "Total sales (% growth)"
lab var ca_abs_growth "Total sales (abs. growth)"
lab var ca_exp_rel_growth "Export sales (% growth)"
lab var ca_exp_abs_growth "Export sales (abs. growth)"
lab var profit_rel_growth "Profits (% growth)"
lab var profit_abs_growth "Profits (abs. growth)"
lab var employes_rel_growth "Employees (% growth)"
lab var employes_abs_growth "Employees (abs. growth)"
lab var car_empl1_rel_growth "Female Employees (% growth)"
lab var car_empl1_abs_growth "Female Employees (abs. growth)"
lab var car_empl2_rel_growth "Young Employees (% growth)"
lab var car_empl2_abs_growth "Young Employees (abs. growth)"

* Generate tables for KPIs
dtable, by(surveyround, nototal) ///
    continuous(ca_rel_growth ca_abs_growth ///
               ca_exp_rel_growth ca_exp_abs_growth ///
               profit_rel_growth profit_abs_growth ///
               employes_rel_growth employes_abs_growth ///
               car_empl1_rel_growth car_empl1_abs_growth ///
               car_empl2_rel_growth car_empl2_abs_growth, statistics(mean))	   ///
    nformat(%9.0g mean)
*    export(kpis_growth.docx, replace)

putdocx collect

* Export indicators
putdocx paragraph, style(Heading1)
putdocx text ("Export Performance Indicators - Export sales, export countries, clients & orders")
putdocx textblock begin
This section presents the key export performance indicators. 
The variable "exported" is either "yes" or "no". All other numbers present the mean across all among the 66 firms that responded to the specific question in the respective surveyround.
putdocx textblock end

* Label variables
lab var exported "Exported"
lab values exported yesno
lab var exp_pays "Number of export countries"

* Create tables for export indicators
dtable, by(surveyround, nototal) ///
	factor(exported, statistics(fvfrequency fvproportion)) ///
	continuous(exp_pays exp_pays_ssa clients clients_ssa clients_ssa_commandes, statistics(mean)) 	///
	nformat(%9.2fc  mean fvproportion) ///
	nformat(%9.0g fvfrequency)
* export(export.docx, replace)

putdocx collect

* Save the Word document
putdocx save giz_indicators, replace
