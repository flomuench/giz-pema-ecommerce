**********************************************************************
* 			clean do file, second part baseline e-commerce			  *					  
***********************************************************************
*																	  
*	PURPOSE: clean the questionnaire answers intermediate data						  
*																	  
*	OUTLINE: 		 PART 1: Import the data
*					 PART 2: Removing whitespace & format string & lower case
*					 PART 3: Turn binary questions numerical
*					 PART 4: Drop variables	  
*					 PART 5: Rename variables
*					 PART 6: Label variables 
*				 	 PART 7: Label the variables values        											
*					 PART 8: Save the data
*					 								  
*	Author:  	 	 Ayoub Chamakhi					    
*	ID variable: 	 id_platform		  					  
*	Requires:  		 Webpresence_answers_intermediate.dta								  
*	Creates:    	 Webpresence_answers_intermediate.dta

***********************************************************************
* 	PART 1:    Import the data
***********************************************************************

use "${bl2_intermediate}/Webpresence_answers_intermediate", clear

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
format Zeitstempel Quandétaitlavantdernierpubl %td

***********************************************************************
* 	PART 3: Drop variables    
***********************************************************************

drop Quelestvotrenometprénom

***********************************************************************
* 	PART 4: Rename variables   
***********************************************************************

rename Zeitstempel submission_date
rename Quelestlidentifiantdelapla id_platform
rename Lentreprisedisposetelledun entreprise_web
rename LesiteWebindiquetilclairem web_logoname
rename Leproduitserviceestildécrit web_product
rename Ladescriptionduproduitservic web_multimedia
rename Lesitecomportetilunesectio web_aboutus
rename Lesiteprésentetildesnormes web_norms
rename Lentreprisevendellesonprodu entreprise_models
rename Danslecasducommerceinterent entreprise_partners
rename Estcequelesliensexternesfo web_externals
rename Lesiteestilproposédansune web_languages
rename Parmilespossibilitésdecontac web_contact
rename Lecontenuestillisiblepare web_coherent
rename Lecontenusechargetilcorrec web_quality
rename Pouvezvousacheteroucommander web_purchase
rename Existetildesliensversunma web_external_purchase
rename Siouiversquellesplacesdem web_external_names
rename U entreprise_social
rename Lapageduréseausocialindique social_logoname
rename Lapageduréseausocialcomport social_external_website
rename Lapageduréseausocialcontien social_photos
rename Lapageduréseausocialcontie social_description
rename Z social_contact
rename Quandétaitladernierepublicat social_last_publication
rename Quandétaitlavantdernierpubl social_beforelast_publication
rename Pourlequeldesréseauxsociaux social_others
rename Estcequelentreprisepossède social_facebook
rename QuelestlenombredeLikes facebook_likes
rename Quelestlenombredabonnés facebook_subs
rename Quelleestladatedecréationd facebook_creation
rename Combiendeavislapagepossède facebook_reviews
rename Quelleestlamoyennedesavisa facebook_reviews_avg
rename Lapagedisposetelledelopti facebook_shop
rename AK social_insta
rename Quelestlenombredepublicatio insta_publications
rename Quelestlenombredefollowers insta_subs
rename Leprofildelentreprisecontie insta_description
rename Leprofildelentreprisefourni insta_externals
rename Parmilesinformationsdecontac insta_contact
rename Veuillezcollercidessousleli socials_link
rename Veuillezcollerleliendelapa facebook_link

***********************************************************************
* 	PART 5: Label variables   
***********************************************************************

lab var submission_date "questionnaire submission date"
lab var id "entreprise id"
lab var entreprise_web "existance of a website"
lab var web_logoname "logo and name in website"
lab var web_product "product description in website"
lab var web_multimedia "product accompanied by multimedia"
lab var web_aboutus "about us section in website"
lab var web_norms "quality norms in website"
lab var entreprise_models "entreprise marketing model"
lab var entreprise_partners "entreprise partners in website"
lab var web_externals "functioning external website links"
lab var web_languages "existance of multi languages in website"
lab var web_contact "possibilities of contact in website"
lab var web_coherent "readability of the website"
lab var web_quality "quality of the website"
lab var web_purchase "purchasing possibility via website"
lab var web_external_purchase "purchasing possbility via third party"
lab var web_external_names "names of third party sellers"
lab var entreprise_social "existance of social media"
lab var social_logoname "logo and name in social media"
lab var social_external_website "link to website in social media"
lab var social_photos "photos in social media"
lab var social_description "entreprise decription in social media"
lab var social_contact "contact ways in social media"
lab var social_last_publication "date of last social media post"
lab var social_beforelast_publication "date of before last social media post"
lab var social_others "existnace of other social media accounts"
lab var social_facebook "existance of a facebook account"
lab var facebook_likes "numbers of facebook likes"
lab var facebook_subs "numbers of facebook followers"
lab var facebook_creation "creation date of facebook page"
lab var facebook_reviews "numbers of facebook page reviews"
lab var facebook_reviews_avg "average of facebook page reviews"
lab var facebook_shop "existance of facebook shop"
lab var social_insta "existance of instagram account"
lab var insta_publications "numbers of instagram posts"
lab var insta_subs "numbers of instagram followers"
lab var insta_description "entreprise description in instagram page"
lab var insta_externals "link to website in instagram description"
lab var insta_contact "contact ways in instagram description"
lab var socials_link "link to social media account"
lab var facebook_link "link to facebook account"

***********************************************************************
* 	PART 6: 	Label the variables values	  			
***********************************************************************

	*label simple yesnos
local yesnovariables entreprise_web web_product web_multimedia web_aboutus web_norms web_languages web_coherent web_external_purchase ///
entreprise_social social_external_website social_photos social_description social_facebook facebook_shop social_insta insta_description insta_externals

	*destring yesnos variables
destring `yesnovariables', replace
format `yesnovariables' %-9.0fc

label define yesno 1 "Yes" 0 "No"

foreach var of local yesnovariables {
	label values `var' yesno 
}

	*label logoname
local logoname web_logoname social_logoname

	*destring logoname variables
destring `logoname', replace
format `logoname' %-9.0fc

label define logo 2 "name and logo" 1 "name or logo" 0 "neither"

foreach var of local logoname {
	label values `var' logo 
}

	*label entreprise models
destring entreprise_models, replace
format entreprise_models %-9.0fc

label define models  2 "entreprise sells to customers and businesses" 1 "entreprise sells to customers or businesses"
label value entreprise_models models 

	*label entreprise partners
destring entreprise_partners, replace
format entreprise_partners %-9.0fc

label define partners 2 "shows partners on website" 1 "sells only to customers (no b2b)" 0 "does not show partners"
label value entreprise_partners partners

	*label web externals
destring web_externals, replace
format web_externals %-9.0fc

label define externals 2 "all external links are working" 1 "some external links work" 0 "no external link or not working ones"
label value web_externals externals

	*label web quality
destring web_quality, replace
format web_quality %-9.0fc

label define quality 2 "contnet loads correctly" 1 "some content is lagging" 0 "website is full of bugs"
label value web_quality quality

	*label web purchase
destring web_purchase, replace
format web_purchase %-9.0fc

label define purchase 2 "can order and purchase" 1 "can only order" 0 "neither order nor purchase"
label value web_purchase purchase

***********************************************************************
* 	PART 7: 	Save the data	  			
***********************************************************************

save "${bl2_intermediate}/Webpresence_answers_intermediate", replace
