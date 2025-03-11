***********************************************************************
* 			E-commerce - master merge									  
***********************************************************************
*																	  
*	PURPOSE: make all data work reproducible, merge & analysis survey 
*            & pii data related to ecommerce program Tunisia
*  
*	OUTLINE: 	PART 1:   
*				PART 2: 	  
*				PART 3:               
*																	  
*																	  
*	Author:  						    
*	ID variable: 	id_plateforme			  					  
*	Requires: 
		* Bl: regis_final, bl_final, Webpresence_answers_final
		* ML: 
		* EL: 
*	Creates:  ${master_pii}/ecommerce_master_contact.dta			                                  
***********************************************************************
* 	PART 1: merge to registration & baseline to ecommerce_database_raw
***********************************************************************
{
	* import registration data (Nrows = 272)
use "${regis_final}/regis_final", clear

	*rename for consistency: email experiment treatment
rename treatment treatment_email

merge 1:1 id_plateforme using "${bl_final}/bl_final"

/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                            36
        from master                        36  (_merge==1)
        from using                          0  (_merge==2)

    Matched                               236  (_merge==3)
    -----------------------------------------
*/
keep if _merge==3 /* companies that were eligible and answered on the registration + baseline surveys */
drop _merge

	* drop bl_refus (FM review 03.07.25; unclear why coded this way, manually identified 3 non respondents)
order id_plateforme surveyround, first
drop bl_refus
gen attrited = 0, a(surveyround)
	replace attrited = 1 if inlist(id_plateforme, 729, 818, 821)


    * save 
save "${master_raw}/ecommerce_master_raw", replace

}

***********************************************************************
* 	PART 2: append midline and endline to create panel data set
***********************************************************************
{
	*assure variables are lower case
rename *, lower
	* append bl & ml
append using "${ml_final}/ml_final"
order id_plateforme surveyround attrited, first
sort id_plateforme surveyround, stable

	* revoir la coherence des noms des variables?
		* phone/online response varnames in bl != ml
replace survey_type = "online" if survey_phone == 0 & surveyround == 2
replace survey_type = "phone" if survey_phone == 1 & surveyround == 2
drop survey_phone
		* drop old dup variable
drop dup
	
	* gen refus variable
duplicates tag id_plateforme, gen(dup)
order dup, a(attrited)
gen temp_attrited = (dup < 1), a(dup)
drop dup

	* declare panel data & fill up missing observations
xtset id_plateforme surveyround, delta(1)
		* check: 441 rows before
tsfill, full
		* check: 472 ros after (2*236)

egen ml_attrited = min(temp_attrited), by(id_plateforme)
order ml_attrited, a(temp_attrited)
bys id_plateforme (surveyround):  replace attrited = ml_attrited if surveyround == 2
drop temp_attrited ml_attrited
	
	
	* append with endline
append using "${el_final}/el_final" // , force

	* declare panel data & fill up missing observations
xtset id_plateforme surveyround, delta(1)
		* check: 605 rows before
		
		* temp variable to count obs per firm & identify added lines (attriters)
gen one = 1, a(attrited)

tsfill, full
		* check: 708 ros after (3*236)

egen temp_responses = sum(one), by(id_plateforme)
order temp_responses, a(attrited)
replace attrited = 0 if temp_responses == 3 & surveyround == 3
replace attrited = 1 if temp_responses == 2 & surveyround == 3

/* manual review 07.03.25 FM suggests variable attrited now correct. 
The following cases have only partial endline responses (attrited = 0 at EL):
253, 259, 386,  451, 706, 841
*/

    * save
sort id_plateforme surveyround, stable
order id_plateforme surveyround treatment attrited, first
save "${master_raw}/ecommerce_master_raw.dta", replace
}

***********************************************************************
* 	PART 3: merge with participation data
***********************************************************************
{
preserve
	import excel "${master_pii}/take_up_ecommerce.xlsx", firstrow clear
	drop firmname
	drop if id_plateforme==.
	destring id_plateforme,replace
	sort id_plateforme, stable
	save "${master_pii}/take_up_ecommerce.dta",replace
restore

merge m:1 id_plateforme using "${master_pii}/take_up_ecommerce",force
/* Should show 2*117 = 234 merged (those in treatment)
    Result                      Number of obs
    -----------------------------------------
    Not matched                           238
        from master                       238  (_merge==1)
        from using                          0  (_merge==2)

    Matched                               234  (_merge==3)
    -----------------------------------------
*/

label var take_up_for_per "Percentage of presence in workshops"
label var take_up_for "Presence for at least 3 on 5 workshops"
label var take_up_for1 "Presence in the 1 workshop"
label var take_up_for2 "Presence in the 2 workshop"
label var take_up_for3 "Presence in the 3 workshop"
label var take_up_for4 "Presence in the 4 workshop"
label var take_up_for5 "Presence in the 5 workshop"
label var take_up_std "Participation in student consulting"
label var take_up_seo "Participation in seo activity"
label var take_up_smo "Participation in social media organic activity"
label var take_up_smads "Participation in social media advertising workshop"
label var take_up_website "Participation in website development activity"
label var take_up_heber "Purchase of website access"

drop _merge
}



***********************************************************************
* 	PART 3: merge with manual scoring of website/social media accounts at baseline & endline
***********************************************************************
preserve
import excel using "${bl2_raw}/Webpresence answers_bl_el.xlsx", firstrow clear

    * save 
save "${master_raw}/ecommerce_master_raw", replace

	* add the information collected by hand at baseline about firms websites and social media accounts
merge 1:1 id_plateforme using "${bl2_final}/Webpresence_answers_final"
/*
    Result                      Number of obs
    -----------------------------------------
    Not matched                             0
    Matched                               236  (_merge==3)
    -----------------------------------------
*/
keep if _merge==3
drop _merge


***********************************************************************
* 	PART 4: save finale analysis data set as raw
***********************************************************************
save "${master_raw}/ecommerce_master_raw.dta", replace
