***********************************************************************
* 			e-commerce endline survey corrections                    	
***********************************************************************
*																	    
*	PURPOSE: correct all incoherent responses				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Define non-response categories 		
*   2)		Identify and remove duplicates  	  				  
* 	3) 		Automatic corrections
*	4)   	Manual corrections					  
*	5)  	Destring variables that should be numeric	  				  
*	6)  	Save the changes made to the data		  
*																  															      
*	Author:  	Kaïs Jomaa 							  
*	ID variable: 	id (example: f101)			  					  
*	Requires: el_intermediate.dta  								  
*	Creates:  el_intermediate.dta			                          
*	
																  
***********************************************************************
* 	PART 1:  Define non-response categories  			
***********************************************************************
use "${el_intermediate}/el_intermediate", clear

{
	* replace "-" with missing value
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
		replace `x' = "" if `x' == "-"
	}
	
scalar not_know    = 999
scalar refused     = 888
scalar not_answered     = 1234

local not_know    = 999
local refused     = 888
local not_answered     = 1234

	* replace, gen, label

}

***********************************************************************
* 	PART 2:  Identify and remove duplicates 
***********************************************************************
/*sort id_plateforme date, stable
quietly by id_plateforme date:  gen dup = cond(_N==1,0,_n)
drop if dup>1
*/
/*duplicates report id_plateforme heuredébut
duplicates tag id_plateforme heuredébut, gen(dup)
drop if dup>1
*/

*Individual duplicate drops (where heure debut is not the same). If the re-shape
*command in bl_test gives an error it is because there are remaining duplicates,
*please check them individually and drop (actually el-amouri is supposed to that)

*restore original order
*sort date heure, stable
***********************************************************************
* 	PART 3:  Automatic corrections
***********************************************************************
*2.1 Remove commas, dots, dt and dinar Turn zero, zéro into 0 for all numeric vars
 
local numvars dig_revenues_ecom comp_ca2023 comp_ca2024 compexp_2023 compexp_2024 comp_benefice2023 comp_benefice2024 dig_invest mark_invest dig_empl
* we may add these variables to check if they changed to string variables: ca_exp2018_cor  ca_exp2019_cor ca_exp2020_cor ca_2018_cor 
*replace dig_revenues_ecom = "700000" if dig_revenues_ecom == "SEPT CENT MILLE DINARS"

/*
foreach var of local numvars {
replace `var' = ustrregexra( `var',"dinars","")
replace `var' = ustrregexra( `var',"dinar","")
*replace `var' = ustrregexra( `var',"milles","000")
*replace `var' = ustrregexra( `var',"mille","000")
*replace `var' = ustrregexra( `var',"million","000")
*replace `var' = ustrregexra( `var',"dt","")
*replace `var' = ustrregexra( `var',"k","000")
replace `var' = ustrregexra( `var',"dt","")
replace `var' = ustrregexra( `var',"tnd","")
replace `var' = ustrregexra( `var',"TND","")
*replace `var' = ustrregexra( `var',"zéro","0")
*replace `var' = ustrregexra( `var',"zero","0")
replace `var' = ustrregexra( `var'," ","")
*replace `var' = ustrregexra( `var',"un","1")
*replace `var' = ustrregexra( `var',"deux","2")
*replace `var' = ustrregexra( `var',"trois","3")
*replace `var' = ustrregexra( `var',"quatre","4")
*replace `var' = ustrregexra( `var',"cinq","5")
*replace `var' = ustrregexra( `var',"six","6")
*replace `var' = ustrregexra( `var',"sept","7")
*replace `var' = ustrregexra( `var',"huit","8")
*replace `var' = ustrregexra( `var',"neuf","9")
*replace `var' = ustrregexra( `var',"dix","10")
*replace `var' = ustrregexra( `var',"cent","00")
*replace `var' = ustrregexra( `var',"O","0")
*replace `var' = ustrregexra( `var',"o","0")
replace `var' = ustrregexra( `var',"دينار تونسي","")
replace `var' = ustrregexra( `var',"دينار","")
replace `var' = ustrregexra( `var',"تونسي","")
replace `var' = ustrregexra( `var',"د","")
replace `var' = ustrregexra( `var',"d","")
replace `var' = ustrregexra( `var',"na","")
replace `var' = ustrregexra( `var',"r","")
*replace `var' = ustrregexra( `var',"m","000")
*replace `var' = ustrregexra( `var',"مليون","000")
*replace `var' = "1000" if `var' == "000"
replace `var' = subinstr(`var', ".", "",.)
replace `var' = subinstr(`var', ",", ".",.)
replace `var' = "`not_know'" if `var' =="je ne sais pas"
replace `var' = "`not_know'" if `var' =="لا أعرف"
replace `var' = "`not_know'" if `var' =="jenesaispas"
}
replace dig_revenues_ecom = "not_know" if dig_revenues_ecom == "jenesaispas"

*put zero digital revenues for firms that do not have any digital revenues
replace dig_revenues_ecom = "0" if dig_vente == 0
*/


***********************************************************************
* 	PART 4:  Manual corrections
***********************************************************************
replace comp_benefice2024 = "30000000" if id_plateforme == 237 // IT LOOKS WRONG, WILL RETURN IN CORRECTION FILE
replace comp_benefice2023 = "782720" if comp_benefice2023 == "782 720"

replace comp_benefice2023 = "888" if comp_benefice2023 == "refus"
replace comp_benefice2024 = "888" if comp_benefice2024 == "refus"

***********************************************************************
* 	PART 5:  destring variables that should be numeric
***********************************************************************
local numvars dig_revenues_ecom comp_ca2023 comp_ca2024 compexp_2023 compexp_2024 comp_benefice2023 comp_benefice2024 dig_invest mark_invest dig_empl
foreach var of local numvars {
destring `var', replace
recast int `var'
}

***********************************************************************
* 	PART 6:  translation of open-ended questions
***********************************************************************
*dig_payment_refus
replace dig_payment_refus="ils ne sont pas assez développé et ne sont pas encore arrivés à cette étape" if dig_payment_refus=="matawerouch w maweslouch ll etape edhika"
replace dig_payment_refus="ils n'ont pas de site d'e-commerce" if dig_payment_refus=="maandekch site e-commerce"
replace dig_payment_refus="le produit est très couteux, il n'est pas fait pour le paiement sur internet" if dig_payment_refus=="produit tetkalef bercha moch mt3 payement sur internet"
replace dig_payment_refus="le client n'a pas confiance dans le paiement en ligne" if dig_payment_refus=="client m3ndhomech thi9a fi lkhlass ala internet"
replace dig_payment_refus="ils n'ont pas encore accordé suffisament de temps pour cette problématique" if dig_payment_refus=="mezelou makhasesouch wa9et lelhaja hethy"
replace dig_payment_refus="c'est la nature des produits qui ne le permet pas" if dig_payment_refus=="nature des produit heya aly tohkom"
replace dig_payment_refus="nous n'avons pas paypal, nous devons chercher des moyens pour être payer mais il n'y a pas comment" if dig_payment_refus=="ma3andkomch paypal , lezem tlawej kifeh to5less mochkla kifeh bech to5less "
replace dig_payment_refus="" if dig_payment_refus=="kkk"
replace dig_payment_refus="aucune raison, ils travaillent avec les virements bancaires et doivent avoir des documents justificatifs car ils travaillent avec les devises étrangères" if dig_payment_refus=="aucun raison yekhdmou m3a banque les virementes lezem andhom des justification khater yekhdmou b devise"
replace dig_payment_refus="ils sont B2B" if dig_payment_refus=="ahna be to be"
replace dig_payment_refus="il n'y a pas d'initiative et on n'est pas encouragé à adopter le paiement en ligne" if dig_payment_refus=="mafmach tachji3at o ahna mabedrnech o mafamech chkoun chajaana"
replace dig_payment_refus="c'est un problème de temps, on a pas trouvé de temps" if dig_payment_refus=="hkeyt waqt maanech waqt"
replace dig_payment_refus="nous payons sur Internet" if dig_payment_refus=="nkhalsou aal internet"
replace dig_payment_refus="car nouus ne vendons par aux particuliers mais seulement à des entreprises" if dig_payment_refus=="khater manbi3ouch lil particullier / nbi3ou ken l societe"
replace dig_payment_refus="le produit n'a pas besoin d'être payé en ligne" if dig_payment_refus=="mayestha9ech produit bech tserlou en ligne"
replace dig_payment_refus="un peu de peur sur la confidentialité des paiements/ manque de moyens" if dig_payment_refus=="chwy khouf mel secerte mel paiment / no9ss les moyen"
replace dig_payment_refus="on ne vend pas en Tunisie; notre marque exporte et n'est pas intéressé par la vente en ligne en Tunisie" if dig_payment_refus=="manbi3ouch f tunis ; la marque mteena export o manech interssé bel vente en ligne f tnis"
replace dig_payment_refus="l'occassion ne s'est pas encore présentée" if dig_payment_refus=="mejetech forsa"
replace dig_payment_refus="nous travaillons dans le marché du gros et dans le marché du détail" if dig_payment_refus=="tekhdmo en gros mech details"
replace dig_payment_refus="il n'y a pas de raison" if dig_payment_refus=="mefamech sbab"
replace dig_payment_refus="je n'y ai pas pensé" if dig_payment_refus=="mekhamemtouch fih"
replace dig_payment_refus="la stratégie fonctionne avec les sociétés B2B" if dig_payment_refus=="strategie mchet maa les sociétés btob"
replace dig_payment_refus="ils ne souhaitent payer que si la marchandise arrive" if dig_payment_refus=="yhebou ykhalsou k tousel sel3a"
replace dig_payment_refus="il faut toujours un virement bancaise quand on vend" if dig_payment_refus=="lezem dima fama virment bancaire k ybi3ou"
replace dig_payment_refus="parce que ils vendent en gros et ils vendent des produits personnalisés donc les clients viennent pour voir les produits sur place" if dig_payment_refus=="khater ybi3ou en greaux w ybi3ou des produits personnalisés danc yjiw les clients ychoufou les produits sur place"
replace dig_payment_refus="la nature de notre produit et on n'a pas d'e-commerce" if dig_payment_refus=="nature de la produit mte3na w manech e commerce a7na"
replace dig_payment_refus="parce que nous n'avons pas de produit prêt pour tout le monde; l'appel d'offre et le prix ne sont pas fixes par rapport l'expertise" if dig_payment_refus=="khater ma3anech produit hadher l ness kol enti w appel doffre w prix mahomch fixe par rapport ll expirtisse"
replace dig_payment_refus="parce que nous n'avons pas de services standards; les services dépendent de la nature du client" if dig_payment_refus=="3la 5ater ma3andnech des services standards parceque des services marbout bi naw3iet clients"
replace dig_payment_refus="parce que la loi interdit de vendre à n'importe qui; il faut passer un bon de commande et être une société qui peut acheter les médicaments" if dig_payment_refus=="5ater 9anoun yamna3 bech nbi3 l n'importe qui 5ater lezem ykoun mowaza3 lil dwe w t3adili bon de commande"
replace dig_payment_refus="Pour bientôt, si on se développe encore plus nous pourrons permettre le paiement sur Internet" if dig_payment_refus=="nchlh bientot ntawro akther nwalo n5alsso 3al internet"
replace dig_payment_refus="je n'ai pas une idée précise, c'est un problème dans le site" if dig_payment_refus=="ma3andich fekra probléme dans le site"
replace dig_payment_refus="Ceux avec qui nous traitons n'ont pas de paiement électronique" if dig_payment_refus=="الي نتعامل معاهم معندهمش خلاص الكتروني"
replace dig_payment_refus="nous n'avons pas une personne reponsable et nous ne considérons pas la possibilité" if dig_payment_refus=="ma anech chkoun lehi w famech chkoun ykhamem feha"
replace dig_payment_refus="on en a pas besoin" if dig_payment_refus=="ma jatech necessite"
replace dig_payment_refus="je n'ai pas essayé, l'occassion ne s'est pas présenté pour développer ces formules" if dig_payment_refus=="ma jarabtouch , ma jatech l'occasion pour developper ces formules"
replace dig_payment_refus="on ne vend pas de produits sur Internet" if dig_payment_refus=="pas des produits yetbaoo aal internet"
replace dig_payment_refus="les clients ont des méthodes de paiement specifiques" if dig_payment_refus=="les clients andhom methode de paiements mouayna"

*mark_online5_other
replace mark_online5_other="la participation aux foires nationales et de travail" if mark_online5_other=="moucherka fl ma3aredh el 3alameya w dowaleya"


*dig_barr7_other
replace dig_barr7_other="la chienne, par exemple nessma" if dig_barr7_other=="el9alba par ex nessma"
replace dig_barr7_other="le pouvoir d'achat, il y a une crise" if dig_barr7_other=="le pouvoir dachat fama crisse"
replace dig_barr7_other="le paiement en ligne en devise n'est pas disponible à tunis" if dig_barr7_other=="paiement en ligne en devise moch mawjouda fi tunis"

*export_45_other
replace export_45_other="il n'y a pas de demande" if export_45_other=="mafamech demande"

*dropout_why
replace dropout_why="" if treatment==0
replace dropout_why="Mr. Sahbi était la personne qui a participé aux formations puis il a quitté l'entreprise. Il a été remplacé par Mr. Mounir, qui ne comprend même pas pourquoi il a été contacté." if dropout_why=="mr sahbi howa li cherek w baad khraj chad fi blastou mr mounir w awel mara nkalmouh mayaarech aleh"
replace dropout_why="la nature du produit n'est pas compatible avec le programme" if dropout_why== "nature de produit maytmachech m3a lbarnemj"
replace dropout_why="à cause de problème de disponibilité" if dropout_why== "ala khater disponibilté mteei"
replace dropout_why="la personne qui était en charge d'assister aux activités du projet a quitté l'entreprise" if dropout_why== "kent maana bnaya o khjarjt ken lehya"
replace dropout_why="manque de ressources humaines / nous n'avons pas d'employés qui s'occupe du marketing" if dropout_why== "manque de ressources humaines /mehadedech chkoun bech yetlhe bel marketing"
replace dropout_why="je ne suis pas satisfait: une personne vient et vole tes idées, ensuite il sous-traite le travail" if dropout_why== "manich satisfait mafemech mesde9iya yji wehed yesre9lek afkarek w ymawlou wehed ekher bech yekhdemha tete3ta bel wjouh" 
replace dropout_why="beaucoup trop de temps, projet en ligne et je suis occupé au bureau" if dropout_why== "barcha wakt w projet en ligne w howa yabda lehy f bureau meynajemch"
replace dropout_why="j'étais occupé et ils ne répondaient pas au mail" if dropout_why== "telhyt w mejwehech mail"
replace dropout_why="elle ne sait pas celle qui a participé au programme a quitté l'entreprise mais s'il y a possibilité de revenir au programme, elle le souhaiterait" if dropout_why== "heya metaarech khater li hadhret f programme kharjet aandha barcha mel ese ama katly fama posibilité tarjaa lel programme alech le"
replace dropout_why="parce qu'ils avaient un autre travail en parallèle et par conséquent, un manque de temps" if dropout_why== "khater jethom khedma okhra en parallele danc manque de temps"
replace dropout_why= "ils ne m'ont pas appellé, je crois ne pas me souvenir" if dropout_why== "ma3aytoulich jemla yodhherli manetfakerch"
replace dropout_why= "parce que j'ai demander à la giz pour adapter aux besoins pharmacetique parce je ne peux pas vendre en ligne" if dropout_why== "parce que j'ai demander au giz pour adapter aux besoins pharmacetique parce najamch nbi3 en ligne" 
replace dropout_why= "le problème de la manière avec laquelle la GIZ traite avec nous: elle nous a ignoré presque pour 2 ans" if dropout_why== "mochkla mi giz kifeh yetsarfo comme si tafewna 3andna 2 ans presque ."

*herber_refus
replace herber_refus="" if treatment==0
replace herber_refus="ils ont déjà un site web" if herber_refus=="deja andhom site web"
replace herber_refus="j'ai un domaine d'hébergement" if herber_refus=="3andi domaine d'hébergement"
replace herber_refus="je suis entrain de l'essayer et je n'ai terminé avec l'essai" if herber_refus=="mezlt en cours dece o mezelt makamltch lessai"
replace herber_refus="c'est un problème de manque de temps" if herber_refus=="hkeyt waqt"
replace herber_refus="j'ai achété un domaine d'hebergement" if herber_refus=="chre maw9a3"
replace herber_refus="okay" if herber_refus=="k"
replace herber_refus="j'ai achété" if herber_refus=="chrit"
replace herber_refus="j'ai achété et j'ai tout" if herber_refus=="chrit w aandi kol chy"
replace herber_refus="elle ne sait pas" if herber_refus=="ma taarech"
replace herber_refus="la marque prada a fait une réclamation contre le nom de la marque" if herber_refus=="la marque prada taati eetiradh aal esem el marque"
replace herber_refus="j'ai peur l'argent soit volé" if herber_refus=="khayef la flouso tetsrek"

***********************************************************************
* 	PART 7:  fiche de correction fixes
***********************************************************************
	*id_plateforme 58
replace comp_ca2024 = 3600000 if id_plateforme == 58 
replace compexp_2024 = 3500000 if id_plateforme == 58 

replace comp_ca2023 = 5000000 if id_plateforme == 58 
replace compexp_2023 = 4800000 if id_plateforme == 58 

	*id_plateforme 78
replace comp_ca2024 = 8780000 if id_plateforme == 78 
replace compexp_2024 = 2950000 if id_plateforme == 78 

replace comp_ca2023 = 7380000 if id_plateforme == 78 
 
	*id_plateforme 95
replace mark_invest = 0 if id_plateforme == 95
replace mark_online2 = 0  if id_plateforme == 95
 
	*id_plateforme 105
replace dig_empl = 1 if id_plateforme == 105
replace mark_online2 = 1  if id_plateforme == 105
replace comp_ca2023 = 8801585 if id_plateforme == 105
replace comp_ca2024 = 4061782 if id_plateforme == 105
replace compexp_2024 = 3063517 if id_plateforme == 105 

	*id_plateforme 148
replace comp_ca2023 = 5000000 if id_plateforme == 148
replace comp_ca2024 = 1800000 if id_plateforme == 148
replace dig_invest = 68000 if id_plateforme == 148
replace mark_invest = 500000 if id_plateforme == 148

	*id_plateforme 271
replace comp_benefice2024 = 1600000  if id_plateforme == 271
replace comp_benefice2023 =  1800000  if id_plateforme == 271 
replace comp_ca2024 = 7000000 if id_plateforme == 271
replace comp_ca2023 = 23000000 if id_plateforme == 271
replace compexp_2023 = 19000000 if id_plateforme == 271 
replace compexp_2024 = 5900000 if id_plateforme == 271 
replace fte = 201 if id_plateforme == 271

	*id_plateforme 373 // Refuses to give comptability
local compta_vars "comp_ca2023 comp_ca2024 compexp_2023 compexp_2024 comp_benefice2023 comp_benefice2024 mark_invest dig_invest"

foreach var of local compta_vars {
	replace `var' = 888 if id_plateforme == 373 
}

*id_plateforme 392
replace comp_benefice2024 = 47180  if id_plateforme == 392 // EURO TO TND : 3.37 
replace comp_benefice2023 = 53920  if id_plateforme == 392 // EURO TO TND : 3.37 

*id_plateforme 405
replace comp_ca2023 = 12000000 if id_plateforme == 405
replace compexp_2023  = 12000000 if id_plateforme == 405
replace comp_ca2024 = 6000000 if id_plateforme == 405
replace compexp_2024 = 6000000 if id_plateforme ==  405

*id_plateforme 527
replace compexp_2023= 400000 if id_plateforme == 527
replace comp_ca2023= 700000 if id_plateforme == 527
replace comp_ca2024= 467000 if id_plateforme == 527
replace comp_benefice2023= 50000 if id_plateforme == 527
replace comp_benefice2024= 60000 if id_plateforme == 527

*id_plateforme 695
replace comp_ca2023= 3748173  if id_plateforme == 695

*id_plateforme 899
replace comp_ca2024 = 5000000 if id_plateforme == 695
replace compexp_2024 = 4500000 if id_plateforme == 695  
replace comp_ca2023 = 8000000 if id_plateforme == 695 
replace compexp_2023= 7000000 if id_plateforme == 695 

*id_plateforme 959
replace dig_invest =0 if id_plateforme == 959 
replace mark_online4 = 0 if id_plateforme == 959 

	*id_plateforme 841
replace comp_ca2024 = 999 if id_plateforme == 841 
replace compexp_2024 = 999 if id_plateforme == 841 

	*id_plateforme 773
replace comp_ca2023 = 1200000 if id_plateforme == 773 

	*id_plateforme 483
replace dig_invest = 2000 if id_plateforme == 483 

	*id_plateforme 735
replace comp_ca2023 = 800000 if id_plateforme == 735 

	*id_plateforme 716
replace comp_ca2023 = 424000 if id_plateforme == 716 
replace comp_ca2024 = 550000 if id_plateforme == 716 
replace compexp_2023 = 63600 if id_plateforme == 716 
replace compexp_2024 = 82500 if id_plateforme == 716 

	*id_plateforme 827 // Refuses to give comptability
local compta_vars "comp_ca2023 comp_ca2024 compexp_2023 compexp_2024 comp_benefice2023 comp_benefice2024 mark_invest dig_invest"

foreach var of local compta_vars {
	replace `var' = 888 if id_plateforme == 827 
}

	*id_plateforme 381
replace comp_ca2023 = 11000 if id_plateforme == 381 
replace comp_ca2024 = 15000 if id_plateforme == 381 
replace compexp_2023 = 2000 if id_plateforme == 381 
replace compexp_2024 = 5000 if id_plateforme == 381 
replace comp_benefice2023 = 2000 if id_plateforme == 381 
replace comp_benefice2024 = 4000 if id_plateforme == 381 

	*id_plateforme 457
replace dig_invest = 135 if id_plateforme == 457  // EURO TO TND : 3.37 

	*id_plateforme 237
replace comp_ca2023 = 16000000 if id_plateforme == 237 
replace comp_ca2024 = 5046270 if id_plateforme == 237 
replace comp_benefice2023 = 0 if id_plateforme == 237 
replace comp_benefice2024 = 30000 if id_plateforme == 237 
replace mark_invest = 25000 if id_plateforme == 237  
replace dig_invest = 3000 if id_plateforme == 237 

	*id_plateforme 541
replace comp_ca2023 = 50000 if id_plateforme == 541 
replace comp_ca2024 = 10000 if id_plateforme == 541 
replace comp_benefice2023 = 20000 if id_plateforme == 541 
replace comp_benefice2024 = 20000 if id_plateforme == 541 

	*id_plateforme 231
replace comp_ca2023 = 1400000 if id_plateforme == 231 
replace compexp_2023 = 300000 if id_plateforme == 231 
replace comp_ca2024 = 600000 if id_plateforme == 231 
replace compexp_2024 = 100000 if id_plateforme == 231 
replace comp_benefice2023 = 140000 if id_plateforme == 231 
replace comp_benefice2024 = 126000 if id_plateforme == 231 

	*id_plateforme 925
replace comp_benefice2023 = 999 if id_plateforme == 925 
replace comp_benefice2024 = 999 if id_plateforme == 925 

	*id_plateforme 478
replace comp_ca2023 = 2700000 if id_plateforme == 478 
replace compexp_2023 = 120000 if id_plateforme == 478 

	*id_plateforme 466
replace comp_ca2023 = 12000000 if id_plateforme == 466 

	*id_plateforme 810 // Refuses to give comptability
foreach var of local compta_vars {
	replace `var' = 888 if id_plateforme == 810 
}

	*id_plateforme 323
replace comp_ca2024 = 2900000 if id_plateforme == 323 

	*id_plateforme 543
replace compexp_2023 = 888 if id_plateforme == 543 
replace compexp_2024 = 888 if id_plateforme == 543 

	*id_plateforme 597
replace comp_benefice2023 = 150000 if id_plateforme == 597 
replace comp_benefice2024 = 170000 if id_plateforme == 597 

	*id_plateforme 527
replace compexp_2023 = 400000 if id_plateforme == 527 
replace comp_ca2023 = 700000 if id_plateforme == 527 
replace comp_ca2024 = 467000 if id_plateforme == 527 
replace comp_benefice2023 = 700000 if id_plateforme == 527 
replace comp_benefice2024 = 720000 if id_plateforme == 527  

	*id_plateforme 655
replace compexp_2024 = 6500000 if id_plateforme == 655 

	*id_plateforme 337
replace comp_ca2024 = 10500000 if id_plateforme == 337 

	*id_plateforme 488
replace mark_invest = 25000 if id_plateforme == 488 

	*id_plateforme 453
replace comp_ca2024 = 1500000 if id_plateforme == 453 
replace compexp_2024 = 1020000 if id_plateforme == 453 
replace comp_benefice2023 = 100000 if id_plateforme == 453 

	*id_plateforme 765
replace comp_ca2024 = 999 if id_plateforme == 765 

	*id_plateforme 259
replace dig_invest = 0 if id_plateforme == 259 
replace mark_invest = 750000 if id_plateforme == 259 
replace comp_ca2023 = 1800000 if id_plateforme == 259 
replace comp_ca2024 = 1800000 if id_plateforme == 259 

	*id_plateforme 489
replace mark_invest = 58961 if id_plateforme == 489 //entre 15000euros et 20000 = 17500 * 3.37 Tunisian Dinar
	
	*id_plateforme 679
replace comp_ca2023 = 1650000 if id_plateforme == 679 

	*id_plateforme 511
replace mark_invest = 1500000 if id_plateforme == 511 
replace comp_benefice2023 = -180000 if id_plateforme == 511 
replace comp_ca2023 = 1082864 if id_plateforme == 511 
replace compexp_2023 = 1082864 if id_plateforme == 511  // TOTALY EXPORTING.
replace comp_benefice2023 = 18000000 if id_plateforme == 511 

	*id_plateforme 547
replace comp_ca2023 = 400000 if id_plateforme == 547 
replace compexp_2023 = 50000 if id_plateforme == 547 
replace comp_ca2024 = 250000 if id_plateforme == 547 
replace compexp_2024 = 10000 if id_plateforme == 547 
replace comp_benefice2023 = 30000 if id_plateforme == 547 
replace comp_benefice2024 = 5000 if id_plateforme == 547 
	
	*id_plateforme 398
replace fte = 1000 if id_plateforme == 398 
replace fte_femmes = 800 if id_plateforme == 398 
replace car_carempl_div2 = 500 if id_plateforme == 398 
replace car_carempl_div3 = 200 if id_plateforme == 398 

	*id_plateforme 670
replace comp_benefice2024 = -20000 if id_plateforme == 670 
replace comp_benefice2023 = -50000 if id_plateforme == 670 
replace comp_ca2023 = 500000 if id_plateforme == 670 
replace comp_ca2024 = 200000 if id_plateforme == 670 


	*id_plateforme 443
replace comp_benefice2023 = 2000000 if id_plateforme == 443 
replace comp_benefice2024 = 3000000 if id_plateforme == 443 
replace comp_ca2023 = 40000000 if id_plateforme == 443  
replace comp_ca2024 = 48000000 if id_plateforme == 443  
replace compexp_2023 = 26000000 if id_plateforme == 443  
replace compexp_2024 = 3000000 if id_plateforme == 443  

***********************************************************************
* 	Part 7: Save the changes made to the data		  			
***********************************************************************
cd "$el_intermediate"
save "el_intermediate", replace

