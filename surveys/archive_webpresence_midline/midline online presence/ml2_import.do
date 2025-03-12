***********************************************************************
* 			second part midline (google forms) import						
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
*																 																      
*	Author:   			Ayoub Chamakhi										  
*	ID variable: 		id_platforme  									  
*	Requires:			ml_Webpresence answers.xlsx
*	Creates:			ml_Webpresence_answers_intermediate	ml_Webpresence_answers_raw.dta
*	Creates:			ml2_Idwebsites.xlsv					ml2_Idwebsites.dta				
		
***********************************************************************
* 	PART 1: import the answers from questionnaire as Excel			  *
***********************************************************************

import excel "${ml2_raw}/ml_Webpresence answers.xlsx", firstrow clear

***********************************************************************
* 	PART 2: export raw data as dta				  					  *
***********************************************************************

save "${ml2_raw}/ml_Webpresence_answers_raw", replace

***********************************************************************
* 	PART 3: remove websites and save it in separate CSV/DTA with id 			  						
***********************************************************************

preserve
drop Timestamp Lentreprisedisposetelledun LesiteWebindiquetilclairem LeproduitserviceestildÃcri ///
 Ladescriptionduproduitservic Lesitecomportetilunesectio LesiteprÃsentetildesnorme ///
Lentreprisevendellesonprodu Danslecasducommerceinterent Estcequelesliensexternesfo LesiteestilproposÃdansune ///
ParmilespossibilitÃsdeconta Lecontenuestillisiblepare Lecontenusechargetilcorrec Pouvezvousacheteroucommander ///
Existetildesliensversunma Siouiversquellesplacesdem T Veuillezcollercidessousleli LapagedurÃseausocialindiqu ///
LapagedurÃseausocialcompor LapagedurÃseausocialcontie LapagedurÃseausocialconti Z QuandÃtaitladernierepublica ///
QuandÃtaitlavantdernierpub PourlequeldesrÃseauxsociaux EstcequelentreprisepossÃde Veuillezcollerleliendelapa ///
QuelestlenombredeLikes QuelestlenombredabonnÃs QuelleestladatedecrÃation CombiendeavislapagepossÃde Quelleestlamoyennedesavisa ///
Lapagedisposetelledelopti AL Quelestlenombredepublicatio Quelestlenombredefollowers Leprofildelentreprisecontie ///
Leprofildelentreprisefourni Parmilesinformationsdecontac AR
 
rename Quelestlidentifiantdelapla id_platforme
rename Veuillezcollerleliendusite Website
save "${ml2_intermediate}/ml2_IdWebsites", replace
export excel "${ml2_intermediate}/ml2_Idwebsites", replace
restore
drop Veuillezcollerleliendusite

***********************************************************************
* 	PART 4: save the answers as dta file in intermediate folder 			  						
***********************************************************************

save "${ml2_intermediate}/ml_Webpresence_answers_intermediate", replace
