***********************************************************************
* 			second part baseline (google forms) import						
***********************************************************************
*																	   
*	PURPOSE: import the questionnaire Presence en ligne					  								  
*			  
*																	  
*	OUTLINE:														  
*	1)	import the questionnaire as Excel or CSV	
*	2) 	export raw data as dta											  
*	3)	remove websites and save the websites in separate file with id	
*	4)	save the answers as dta file in intermediate folder
*																 																      *
*	Author:   			Ayoub Chamakhi											  
*	ID variable: 		id_platforme  									  
*	Requires:			Webpresence answers.xlsx
*	Creates:			Webpresence_answers_intermediate	Webpresence_answers_raw.dta
*	Creates:			bl2_Idwebsites.xlsv					bl2_Idwebsites.dta				
		
***********************************************************************
* 	PART 1: import the answers from questionnaire as Excel				  										  *
***********************************************************************

import excel "${bl2_raw}/Webpresence answers.xlsx", firstrow clear

***********************************************************************
* 	PART 2: export raw data as dta				  										  *
***********************************************************************

save "${bl2_raw}/Webpresence_answers_raw", replace

***********************************************************************
* 	PART 3: remove websites and save it in separate CSV/DTA with id 			  						
***********************************************************************

preserve
drop Zeitstempel Quelestvotrenometprénom Lentreprisedisposetelledun LesiteWebindiquetilclairem Leproduitserviceestildécrit Ladescriptionduproduitservic Lesitecomportetilunesectio ///
 Lesiteprésentetildesnormes Lentreprisevendellesonprodu Danslecasducommerceinterent Estcequelesliensexternesfo Lesiteestilproposédansune Parmilespossibilitésdecontac Lecontenuestillisiblepare ///
 Lecontenusechargetilcorrec Pouvezvousacheteroucommander Existetildesliensversunma Siouiversquellesplacesdem U Lapageduréseausocialindique Lapageduréseausocialcomport Lapageduréseausocialcontien ///
 Lapageduréseausocialcontie Z Quandétaitladernierepublicat Quandétaitlavantdernierpubl Pourlequeldesréseauxsociaux Estcequelentreprisepossède QuelestlenombredeLikes Quelestlenombredabonnés ///
 Quelleestladatedecréationd Combiendeavislapagepossède Quelleestlamoyennedesavisa Lapagedisposetelledelopti AK Quelestlenombredepublicatio Quelestlenombredefollowers Leprofildelentreprisecontie ///
 Leprofildelentreprisefourni Parmilesinformationsdecontac Veuillezcollercidessousleli Veuillezcollerleliendelapa
 
rename Quelestlidentifiantdelapla Id
rename Veuillezcollerleliendusite Website
save "${bl2_intermediate}/bl2_IdWebsites", replace
export excel "${bl2_intermediate}/b12_Idwebsites", replace
restore
drop Veuillezcollerleliendusite

***********************************************************************
* 	PART 4: save the answers as dta file in intermediate folder 			  						
***********************************************************************

save "${bl2_intermediate}/Webpresence_answers_intermediate", replace
