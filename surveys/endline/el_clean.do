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
*format Date %td

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
*lab var firmname "Firm name"
*lab var id_ident "Name of the representant"
*lab var id_ident_el "Identification of the new person"
*lab var ident_repondent_position "Respondent's position in the company"

**********L'entreprise*********** 
lab var product "Main product"
lab var product_new "New main product"
lab var inno_produit "Number good or service innovation"
lab var clients "Client type: B2B, B2C or both"

lab var fte "Number of employees"
lab var car_carempl_div1 "Number of femmes employees"
lab var car_carempl_div2 "Number of young employees (less than 36 yo)"
lab var car_carempl_div3 "Number of young employees (less than 24 yo)"

************************************************
**********Digital Technology Adoption***********
************************************************


*****Ventes et service commercial*****
lab var dig_presence1 "Website presence"
lab var dig_presence2 "Social media presence"
lab var dig_presence3 "Marketplace presence"
lab var dig_presence4 "Face-to-face or by phone/email presence"

lab var dig_miseajour1 "Website update frequency"
lab var dig_miseajour2 "Social medias update frequency"
lab var dig_miseajour3 "Marketplace update frequency"

lab var dig_payment1 "Offline payment option"
lab var dig_payment2 "Possibility to pay/order on website"  
lab var dig_payment3 "Possibility to pay/order through a platform"

lab var dig_payment_refus "Reasons for not adopting online payment"

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



*****Marketing et Communication*****
lab var mark_online1 "E-mailing & Newsletters"
lab var mark_online2 "SEO or SEA"
lab var mark_online3 "Free social media marketing"
lab var mark_online4 "Paid social media advertising"
lab var mark_online5 "Other marketing activities"

lab var dig_prix "Higher margins from online sales"
lab var dig_revenues_ecom "Online sales as % of total sales"


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

label var exp_pays "Number of export countries"
label var clients_b2c "Number of international orders"
label var clients_b2b "Number of international companies"
label var exp_dig "Exporting through digital presence"
	
	* Export practices
label var exp_pra_foire "Participation in international exhibition/trade fairs"
label var exp_pra_ach "Expression of interest by a potential foreign buyer"
label var exp_pra_sci "Find a business partner or international trading company"
label var exp_pra_norme "Product certification"
label var exp_pra_vent "Investment in sales structure"

***************************
**********Accounting*******
***************************
label var q29 "Tax identification number"

*label var q29_nom "Accountant's name"
*label var q29_tel "Accountant's phone number"
*label var q29_mail "Accountant's email"

label var comp_ca2023 "Total turnover in 2023 in dt"
label var comp_ca2024 "Total turnover in 2024 in dt"

label var compexp_2023 "Export turnover in 2023 in dt"
label var compexp_2024 "Export turnover in 2024 in dt"

label var profit_2023_category "Profit/Loss in 2023 in dt"
label var profit_2024_category "Profit/Loss in 2024 in dt"

label var comp_benefice2023 "Company profit in 2023 in dt"
label var comp_benefice2024 "Company profit in 2024 in dt"


label var profit_2023_category_perte "Company loss category in 2023 in dt"
label var profit_2023_category_gain "Company loss category in 2023 in dt"

label var profit_2024_category_perte "Company loss category in 2024 in dt"
label var profit_2024_category_gain "Company loss category in 2024 in dt"
***************************
**********Program**********
***************************
*take_up program questions
label var activite1 "Classroom Training"
label var activite2 "Student deployment"
label var activite3 "Experts deployment for website"
label var activite4 "Experts deployment for social medias"
label var dropout_why "Reasons for program withdrawal"
label var herber_refus "Reasons for not buying the web hosting domain"

***********************************************************************
* 	PART 5: 	Label the variables values	  			
***********************************************************************

local yesnovariables product dig_presence1 dig_presence2 dig_presence3 dig_presence4 dig_payment1 dig_payment2 dig_payment3 dig_prix web_use_contacts web_use_catalogue web_use_engagement web_use_com web_use_brand sm_use_contacts sm_use_catalogue sm_use_engagement sm_use_com sm_use_brand mark_online1 mark_online2 mark_online3 mark_online4 mark_online5 dig_barr1 dig_barr2 dig_barr3 dig_barr4 dig_barr5 dig_barr6 dig_barr7 exp_dig exp_pra_foire exp_pra_sci exp_pra_norme exp_pra_vent exp_pra_ach   

label define yesno 1 "Yes" 0 "No" 2 "No"
foreach var of local yesnovariables {
	label values `var' yesno
}

*make value labels for scale questions (see questionnaire)
label define seven_low_high 1 "Very low" 2 "Low" 3 "Slightly low" 4 "Medium" 5 "Slightly High"  6 "High" 7 "Very high" 
label values investecom_benefit1 investecom_benefit2 seven_low_high 

label define importance 1 "Not at all important" 2 "Not important" 3 "Slightly important" 4 "Neutral" 5 "Slightly Important" 6 "Important" 7 "Very important"
label values activite1 activite2 activite3 activite4 importance

label define label_clients 1 "Exclusively to individuals" 2 "To other firms" 3 "To individuals and other firms"
label values clients label_clients

label define dig_fre 1"Never" 2 "Annually" 3 "Monthly" 4 "Weekly" 5 "More than one time per week"
label values dig_miseajour1 dig_miseajour2 dig_miseajour3 dig_fre

label define profit_loss 0 "A loss" 1 "A profit"
label values profit_2023_category profit_2024_category profit_loss

***********************************************************************
* 	PART 6: 	Change format of variable  			
***********************************************************************
* Change format of variable
recast int fte car_carempl_div1 car_carempl_div2 car_carempl_div3 

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

