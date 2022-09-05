***********************************************************************
* 			generate do file, second part baseline e-commerce				  
***********************************************************************
*																	  
*	PURPOSE: generate new variables in the questionnaire answers intermediate data								  
*																	  
*	OUTLINE: 	PART 1: Import the data	  
*				PART 2: Generate date	  
*				PART 3: Generate multiple-choice questions
*				PART 4: Generate date difference facebook posts
*				PART 5: Re-scale multi-level variable to max. of 1	
*				PART 6: Save the data
*                         											  
*																	  
*	Author:  			Ayoub Chamakhi & Fabian Scheifele					    
*	ID variable: 		id_platforme  					  
*	Requires:  	  		Webpresence_answers_intermediate.dta									  
*	Creates:  			Webpresence_answers_final.dta
***********************************************************************
* 	PART 1: Import the data
***********************************************************************

use "${bl2_intermediate}/Webpresence_answers_intermediate", clear

***********************************************************************
* 	PART 2: Generate date		  			
***********************************************************************

gen social_last_formated = date(social_last_publication, "MDY")
format social_last_formated %td
lab var social_last_formated "formated date of last social media post"

***********************************************************************
* 	PART 3: Generate multiple-choice questions		  			
***********************************************************************

	*social media accounts score
gen linkedin = regexm(social_others, "linkedin")
lab var linkedin "dummy variable for linkedin"

gen youtube = regexm(social_others, "youtube")
lab var youtube "dummy variable for youtube"

gen twitter = regexm(social_others, "twitter")
lab var twitter "dummy variable for twitter"

gen instagram = regexm(social_others, "instagram")
lab var instagram "dummy variable for instagram"

g social_score = 0
replace social_score = social_score + 0.25 if linkedin == 1
replace social_score = social_score + 0.25 if youtube == 1
replace social_score = social_score + 0.25 if twitter == 1
replace social_score = social_score + 0.25 if instagram == 1
lab var social_score "existing social media accounts score (from 0 to 1 by interval of 0.25)"

	*web means of contact score
gen web_email = regexm(web_contact, "formulaire de contact/email")
lab var web_email "dummy variable for web email"

gen web_phone = regex(web_contact, "téléphone")
lab var web_phone "dummy variable for web phone"

gen web_address = regex(web_contact, "adresse")
lab var web_address "dummy variable for web address"

g web_contact_score = 0
replace web_contact_score = web_contact_score + 0.33 if web_email == 1
replace web_contact_score = web_contact_score + 0.33 if web_phone == 1
replace web_contact_score = web_contact_score + 0.34 if web_address == 1
lab var web_contact_score "mentioned contact on web score (from 0 to 1 by interval of 0.33)"


	*social media means of contact score
gen social_whatsapp = regex(social_contact, "whatsapp")	
lab var social_whatsapp "dummy variable for whatsapp on social"

gen social_email = regex(social_contact, "formulaire de contact/email")	
lab var social_email "dummy variable for social email"

gen social_phone = regex(social_contact, "téléphone")	
lab var social_phone "dummy variable for phone on social"

gen social_address = regex(social_contact, "adresse")
lab var social_address "dummy variable for address on social"

g social_contact_score = 0
replace social_contact_score = social_contact_score + 0.25 if social_whatsapp == 1
replace social_contact_score = social_contact_score + 0.25 if social_email == 1
replace social_contact_score = social_contact_score + 0.25 if social_phone == 1
replace social_contact_score = social_contact_score + 0.25 if social_address == 1
lab var social_contact_score "mentioned contact on social media score (from 0 to 1 by 0.25)"

	*instagram means of contact score
gen insta_email = regex(insta_contact, "e mail")
lab var insta_email "duammy variable for email on instagram"

gen insta_address = regex(insta_contact, "adresse")
lab var insta_address "dummay variable for adresse on instagram"

gen insta_phone = regex(insta_contact, "téléphone")
lab var insta_phone "dummay variable for phone on instagram"

gen insta_web = regex(insta_contact, "web site")
lab var insta_web "dummay variable for phone on instagram"

gen insta_facebook = regex(insta_contact, "facebook")
lab var insta_facebook "dummay variable for facebook on instagram"

gen insta_whatsapp = regex(insta_contact, "whatsapp")
lab var insta_whatsapp "dummay variable for whatsapp on instagram"

g insta_score = 0
replace insta_score = insta_score + 0.16 if insta_email == 1
replace insta_score = insta_score + 0.16 if insta_address == 1
replace insta_score = insta_score + 0.16 if insta_phone == 1
replace insta_score = insta_score + 0.16 if insta_web == 1
replace insta_score = insta_score + 0.16 if insta_facebook == 1
replace insta_score = insta_score + 0.16 if insta_whatsapp == 1
lab var insta_score "mentioned contacts on instagram score (from 0 to 1 by 0.16)"

	*create facebook age
gen facebook_creation_formated = date(facebook_creation, "MDY")
format facebook_creation_formated %td
lab var facebook_creation_formated "formated date of facebook creation day"

gen facebook_age = round((td(05sep2022)-facebook_creation_formated)/365.25,1)
lab var facebook_age "age of facebook account"

***********************************************************************
* 	PART 4: Generate date difference facebook posts		  			
***********************************************************************

gen datediff = social_last_formated - social_beforelast_publication	
lab var datediff "difference between last two facebook publications in days"

gen posting_rate= 1/datediff
lab var posting_rate "1/days between two last posts"

***********************************************************************
* 	PART 5: Re-scale multi-level variable to max. of 1		  			
***********************************************************************
* in case you have a variable that has several levels re-scale such that highest level is 1. 
*e.g. if so far you have 0, 1 ,2, 3 re-scale to 0,0.33, 0.66 and 1


***********************************************************************
* 	PART 6: 	Save the data
***********************************************************************

save "${bl2_final}/Webpresence_answers_final", replace


*hbar (Count), over(binary_var1)
