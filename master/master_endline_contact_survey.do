***********************************************************************
* 			Export database for endline								  *
***********************************************************************
*	PURPOSE: Correct and update contact-information of participants
*																	  
*	OUTLINE: 	PART 1: Import analysis data
*				PART 2: Import take_up data	  
*				PART 3: Import digital presence information 
*				PART 4: Import pii information
*				PART 5:	Export the final excel
*	Author:  	Florian Münch & Kaïs Jomaa							    
*	ID variable: id_platforme		  					  
*	Requires: ecommerce_master_final.dta, take_up_ecommerce.xlsx 
*			  web_information.xlsx, midline_contactlist
*	Creates:endline_contactlist.xlsx		

***********************************************************************
*PART 1: Import analysis data
***********************************************************************
	* analysis data
use "${master_final}/ecommerce_master_final", clear
keep id_plateforme entr_produit1 entr_produit2 entr_produit3 entr_histoire
sort id_plateforme
quietly by id_plateforme:  gen dup = cond(_N==1,0,_n)
drop if dup>1
drop dup

***********************************************************************
*PART 2: Import take_up data
***********************************************************************
preserve
	import excel "${master_pii}/take_up_ecommerce.xlsx", firstrow clear
	drop firmname
	drop if id_plateforme==.
	destring id_plateforme,replace
	sort id_plateforme, stable
	save "${master_pii}/take_up_ecommerce.dta",replace
restore

merge m:1 id_plateforme using "${master_pii}/take_up_ecommerce",force
/* 

    Result                           # of obs.
    -----------------------------------------
    not matched                           168
        from master                       168  (_merge==1)
        from using                          0  (_merge==2)

    matched                               224  (_merge==3)
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
drop take_up_for1 take_up_for2 take_up_for3 take_up_for4 take_up_for5 take_up_for_per


***********************************************************************
*PART 3: Import digital presence information
***********************************************************************
preserve
	import excel "${master_pii}/web_information.xlsx", sheet("all") firstrow clear 
	drop if id_plateforme==.
	destring id_plateforme,replace
	save "${master_pii}/web_information.dta",replace
restore
merge 1:1 id_plateforme using "${master_pii}/web_information", force
/* 

    Result                           # of obs.
    -----------------------------------------
    not matched                             9
        from master                         0  (_merge==1)
        from using                          9  (_merge==2)

    matched                               227  (_merge==3)
    -----------------------------------------
*/
drop _merge

***********************************************************************
*PART 4: Import pii information
***********************************************************************
preserve
import excel "${master_pii}/midline_contactlist.xlsx", firstrow clear 
	drop if id_plateforme==.
	destring id_plateforme,replace
save "${master_pii}/midline_contactlist.dta",replace
restore
merge 1:1 id_plateforme using "${master_pii}/midline_contactlist", force
/* 
    Result                           # of obs.
    -----------------------------------------
    not matched                            36
        from master                         0  (_merge==1)
        from using                         36  (_merge==2)

    matched                               236  (_merge==3)
    -----------------------------------------
*/
drop dig_presence1 dig_presence2 dig_presence3 
drop _merge

***********************************************************************
*PART 5: Export the final excel
***********************************************************************
export excel "${master_pii}/endline_contactlist.xlsx", firstrow(variables) replace
