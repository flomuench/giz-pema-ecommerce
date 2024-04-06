***********************************************************************
* 			clean do file, endline ecommerce			 			  *					  
***********************************************************************
*																	  
*	PURPOSE: clean the surveys answers					  
*																	  
*	OUTLINE: 		 PART 1: Import the data
*					 PART 2: Removing whitespace & format string & lower case
*					 PART 3: Make all variables names lower case	
*					 PART 4: Label variables  
*					 PART 5: Labvel variables values
*					 PART 6: Save the changes made to the data						  
*	Author:  	 	 Kaïs Jomaa					    
*	ID variable: 	 id_plateforme		  					  
*	Requires:  		 el_intermediate.dta									  
*	Creates:    	 el_intermediate.dta

***********************************************************************
* 	PART 1:    Import the data
***********************************************************************

use "${el_intermediate}/el_intermediate", clear

***********************************************************************
* 	PART 2:    Removing whitespace & format string and date & lower case 
***********************************************************************

	*remove leading and trailing white space

{
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
replace `x' = stritrim(strtrim(`x'))
}
}

	*string
ds, has(type string) 
local strvars "`r(varlist)'"
format %-20s `strvars'
	
	*make all string lower case
foreach x of local strvars {
replace `x'= lower(`x')
}

	*fix date
format Date %td

*drop empty rows
drop if id_plateforme ==.

***********************************************************************
* 	PART 3: 	Make all variables names lower case		  			
***********************************************************************
rename *, lower
rename empl fte 
***********************************************************************
* 	PART 4: 	Label the variables		  			
***********************************************************************
* copier-coller pour les variables qui sont identiques à la baseline
* definer des nouvelles labels pour des nouvelles variables

lab var id_plateforme "Unique identifier of the company"
lab var firmname_change "New firm name"
lab var id_ident2 "Identification of the new person"
lab var repondant_midline "Respondent name"
lab var position_rep_midline "Respondent's position in the company"

**********L'entreprise*********** 
lab var product "Main product"
lab var product_new "New main product"
lab var inno_produit "Number good or service innovation"
lab var clients "Client type: B2B, B2C or both"

lab var fte "Number of employees"
lab var car_carempl_div1 "Number of femmes employees"
lab var car_carempl_div2 "Number of young employees (less than 36 yo)"
lab var car_carempl_div3 "Number of young employees (less than 24 yo)"
lab var car_carempl_div4 "Number of full-time employees"

************************************************
**********Digital Technology Adoption***********
************************************************


*****Ventes et service commercial*****
lab var dig_presence1 "Website presence"
lab var dig_presence2 "Social media presence"
lab var dig_presence3 "Marketplace presence"
lab var dig_presence4 "Face-to-face or by phone/email presence"

lab var dig_payment1 "Offline payment option"
lab var dig_payment2 "Possibility to pay/order on website"  
lab var dig_payment3 "Possibility to pay/order through a platform"

lab var dig_prix "Higher margins from online sales"
lab var dig_revenues_ecom "Online sales as % of total sales"
lab var dig_ payment_refus "Reasons for not adopting online payment"

lab var dig_presence2_sm1 "Instagram"
lab var dig_presence2_sm2 "Facebook"
lab var dig_presence2_sm3 "Twitter"
lab var dig_presence2_sm4 "Youtube"
lab var dig_presence2_sm5 "LinkedIn"
lab var dig_presence2_sm6 "Others"

lab var dig_presence3_plateform1 "Little Jneina "
lab var dig_presence3_plateform2 "Founa"
lab var dig_presence3_plateform3 "Made in Tunisia"
lab var dig_presence3_plateform4 "Jumia"
lab var dig_presence3_plateform5 "Amazon"
lab var dig_presence3_plateform6 "Ali baba"
lab var dig_presence3_plateform7 "Upwork"
lab var dig_presence3_plateform8 "Autres"

lab var web_use_contacts "Company contact details on website"
lab var web_use_catalogue "Cataloging goods and services on the website" 
lab var web_use_engagement "Study customer behavior on the website" 
lab var web_use_com  "Communicate with customers on the website"
lab var web_use_brand  "Promoting a brand image on the website"

lab var sm_use_contacts "Company contact details on social medias"
lab var sm_use_catalogue  "Cataloging goods and services on social medias" 
lab var sm_use_engagement "Study customer behavior on social medias" 
lab var sm_use_com  "Communicate with customers on social medias"
lab var sm_use_brand "Promoting a brand image on social medias"

lab var dig_miseajour1 "Website update frequency"
lab var dig_miseajour2 "Social medias update frequency"
lab var dig_miseajour3 "Marketplace update frequency"


*****Marketing et Communication*****
lab var mark_online1 "E-mailing & Newsletters"
lab var mark_online2 "SEO or SEA"
lab var mark_online3 "Free social media marketing"
lab var mark_online4 "Paid social media advertising"
lab var mark_online5 "Other marketing activities"

lab var dig_empl "Number of employees in charge of online activities"
lab var dig_invest "Investment in online marketing activities in 2023 and 2024"
lab var mark_invest "Investment in offline marketing activities in 2023 and 2024"

**************************************************
**********Digital Technology Perception***********
**************************************************
lab var investecom_benefit1 "Perception of digital marketing costs"
lab var investecom_benefit2 "Perception of digital marketing benefits"

lab var dig_barr1  "Absence/uncertainty of online demand"
lab var dig_barr2  "Lack of skilled staff"
lab var dig_barr3  "Inadequate infrastructure"
lab var dig_barr4  "Cost is too high"
lab var dig_barr5  "Restrictive government regulations"
lab var dig_barr6  "Resistance to change"
lab var dig_barr7  "Other"
***************************
**********Export***********
***************************
				* Export performance
label var export_1 "Direct export"
label var export_2 "Indirect export"
label var export_3 "No export"
				
				* reasons for not exporting
label var export_41 "Not profitable"
label var export_42 "Did not find clients abroad"
label var export_43 "Too complicated"
label var export_44 "Requires too much investment"
label var export_45 "Other"

label var exp_pays "Number of export countries"
label var cliens_b2c "Number of international orders"
label var cliens_b2b "Number of international companies"
label var exp_dig "Exporting through digital presence"
	
	* Export practices
label var exp_pra_foire "Participation in international exhibition/trade fairs"
label var exp_pra_sci "Find a business partner or international trading company"
label var exp_pra_rexp "Hiring a person in charge of commercial activities related to export"
label var exp_pra_plan "Maintain or develop an export plan"
label var exp_pra_norme "Product certification"
label var exp_pra_fin "Commitment of external funding for preliminary export costs"
label var exp_pra_vent "Investment in sales structure"
label var exp_pra_ach "Expression of interest by a potential foreign buyer"
	
***************************
**********Accounting*******
***************************
label var q29 "Tax identification number"

label var q29_nom "Accountant's name"
label var q29_tel "Accountant's phone number"
label var q29_mail "Accountant's email"

label var comp_ca2023 "Total turnover in 2023 in dt"
label var comp_ca2024 "Total turnover in 2024 in dt"

label var compexp_2023 "Export turnover in 2023 in dt"
label var compexp_2024 "Export turnover in 2024 in dt"

label var comp_benefice2023 "Company profit in 2023 in dt"
label var comp_benefice2024 "Company profit in 2024 in dt"

label var profit_2023_category "Company profit category in 2023 in dt"
label var profit_2024_category "Company profit category in 2024 in dt"

***************************
**********Program**********
***************************
*take_up program questions
label var dropout_why "Reasons for program withdrawal"
label var herber_refus "Reasons for not buying the web hosting domain"

***********************************************************************
* 	PART 5: 	Label the variables values	  			
***********************************************************************

local yesnovariables id_ident id_ident2 product dig_presence1 dig_presence2 dig_presence3 dig_presence4 dig_payment1 dig_payment2 dig_payment3 dig_prix //
web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand  //
mark_online1 mark_online2 mark_online3 mark_online4 mark_online5 dig_barr1 dig_barr2 dig_barr3 dig_barr4 dig_barr5 dig_barr6 dig_barr7 exp_dig //
exp_pra_foire exp_pra_sci exp_pra_rexp exp_pra_plan exp_pra_norme exp_pra_fin exp_pra_vent exp_pra_ach//   

label define yesno 1 "Yes" 0 "No" 2 "No"
foreach var of local yesnovariables {
	label values `var' yesno
}

*make value labels for scale questions (see questionnaire)
label define five_low_high 1 "Very low" 2 "Low" 3 "Medium" 4 "High" 5 "Very high" 
label values investecom_benefit1 investecom_benefit2 five_low_high


label define label_clients 1 "Exclusively to individuals" 2 "To other firms" 3 "To individuals and other firms"
label values clients label_clients

label define dig_fre 1"Never" 2 "Annually" 3 "Monthly" 4 "Weekly" 5 "More than one time per week"
label values dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_fre

***********************************************************************
* 	PART 6: 	Change format of variable  			
***********************************************************************
* Change format of variable
recast int fte car_carempl_div1 car_carempl_div2 car_carempl_div3 car_carempl_div4

***********************************************************************
* 	PART 7: Removing trail and leading spaces from string variables 			
***********************************************************************
ds, has(type string)
foreach x of varlist `r(varlist)' {
replace `x' = lower(strtrim(`x'))
}
***********************************************************************
* 	Part 8: Save the changes made to the data		  			
***********************************************************************
cd "$el_intermediate"
save "el_intermediate", replace

