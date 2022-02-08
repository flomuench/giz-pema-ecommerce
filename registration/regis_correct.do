***********************************************************************
* 			registration corrections									  	  
***********************************************************************
*																	    
*	PURPOSE: correct all incoherent responses				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Define non-response categories 			  				  
* 	2) 		correct unique identifier - matricule fiscal
*	3)   	Replace string with numeric values						  
*	4)  	Convert string to numerical variaregises	  				  
*	5)  	Convert proregisematic values for open-ended questions		  
*	6)  	Traduction reponses en arabe au francais				  
*   7)      Rename and homogenize the observed values                   
*	8)		Import categorisation for opend ended QI questions
*	9)		Remove duplicates
*
*																	  															      
*	Author:  	Florian Muench & Kais Jomaa							  
*	ID variaregise: 	id (example: f101)			  					  
*	Requires: regis_inter.dta 	  								  
*	Creates:  regis_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  Define non-response categories  			
***********************************************************************
use "${regis_intermediate}/regis_inter", clear

{
	* replace "-" with missing value
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
		replace `x' = "" if `x' == "-"
	}
	



local not_know    = -777
local refused     = -999
local check_again = -888

	* replace, gen, label
	
*/
}

***********************************************************************
* 	PART 2: use regular expressions to correct variables 		  			
***********************************************************************

	* idea: use regular expression to create a dummy = 1 for all responses
		* with correct fiscal number that fulfill 7 digit, 1 character condition
gen id_admin_correct = ustrregexm(id_admin, "([0-9]){6,7}[a-z]")
order id_admin_correct, a(id_admin)
*replace id_admin_corrige = `check_again' if id_admin_correct == 1
lab def correct 1 "correct" 0 "incorrect"
lab val id_admin_correct correct

*browse identifiant*
    * Correct Nom et prénom du/de la participant.e à l’activité
{
replace rg_nom_rep = ustrregexra( rg_nom_rep ,"mr ","")
replace rg_nom_rep = "`check_again'" if rg_nom_rep == "Études géomatiques."
replace rg_nom_rep = "`check_again'" if rg_nom_rep == "tunisie"
replace rg_nom_rep = "`check_again'" if rg_nom_rep == "société internet soft erp"
replace rg_nom_rep = "`check_again'" if rg_nom_rep == "medianet"
replace rg_nom_rep = "salhi elhem" if rg_nom_rep == "inspiration design salhi elhem"
replace rg_nom_rep = "`check_again'" if rg_nom_rep == "bilel"
replace rg_nom_rep = "`check_again'" if rg_nom_rep == "haddad"
replace rg_nom_rep = "aymen bahri" if rg_nom_rep == "أيمن البحري"
}
    * correct code de la douane
{
replace rg_codedouane = ustrregexra( rg_codedouane ," ","")
replace rg_codedouane = "0555082b" if rg_codedouane == "0555082b/a/m/000"
replace rg_codedouane = "1721444v" if rg_codedouane == "000ma1721444/v"
replace rg_codedouane = "1149015h" if rg_codedouane == "1149015/h000"
replace rg_codedouane = ustrregexra( rg_codedouane ,"/","")
replace rg_codedouane = "`check_again'" if rg_codedouane == "d"
replace rg_codedouane = "`check_again'" if rg_codedouane == "n"
replace rg_codedouane = "`check_again'" if rg_codedouane == "n2ant"
replace rg_codedouane = "`check_again'" if rg_codedouane == "na"
replace rg_codedouane = "`refused'" if rg_codedouane == "non"
replace rg_codedouane = "`check_again'" if rg_codedouane == "pasencore"
replace rg_codedouane = "`check_again'" if rg_codedouane == "0"
replace rg_codedouane = "`check_again'" if rg_codedouane == "......"
replace rg_codedouane = "`check_again'" if rg_codedouane == "."
replace rg_codedouane = "`check_again'" if rg_codedouane == "620.004w"
*We a have a duplicate for the same code de douane 220711z ; count if rg_codedouane == "220711z" returns 2
}
    * correction de la variable autres
{
replace autres = "conseil" if ustrregexm( autres ,"conseil")== 1
replace autres = "consulting" if ustrregexm( autres ,"consulting")== 1
replace autres = "services informatiques" if ustrregexm( autres ,"informatique")== 1
replace autres = "communication" if ustrregexm( autres ,"communication")== 1
replace autres = "marketing digital" if ustrregexm( autres ,"marketing digital")== 1
replace autres = "bureau d'études" if ustrregexm( autres ,"bureau d'études")== 1
replace autres = "design" if ustrregexm( autres ,"design")== 1
}
****** pas encore terminée

	* correct telephone numbers with regular expressions
		* representative
replace rg_telrep = ustrregexra(rg_telrep, "^216", "")
replace rg_telrep = ustrregexra( rg_telrep,"[a-z]","")
replace rg_telrep = ustrregexra( rg_telrep," ","")
replace rg_telrep = ustrregexra( rg_telrep,"00216","")
replace rg_telrep = "29939431" if rg_telrep == "+21629939431"
replace rg_telrep = "22161622" if rg_telrep == "(+216)22161622"

*Check all phone numbers having more or less than 8 digits
replace rg_telrep = "`check_again'" if strlen( rg_telrep ) != 8


*****Correct the website ******
{
replace rg_siteweb = ustrregexra(rg_siteweb ,"https://","")
replace rg_siteweb = ustrregexra(rg_siteweb ,"http://","")
replace rg_siteweb = ustrregexra(rg_siteweb ,"/","")


replace rg_siteweb = "`check_again'" if rg_siteweb == "je n ai pas encore"
replace rg_siteweb = "`check_again'" if rg_siteweb == "coming soon"
replace rg_siteweb = "`check_again'" if rg_siteweb == "kebili"
replace rg_siteweb = "`check_again'" if rg_siteweb == "bni khalled nabeul"
replace rg_siteweb = "`check_again'" if rg_siteweb == "zone industruelle 2 bouarada siliana"
replace rg_siteweb = "`check_again'" if rg_siteweb == "zone industrielle la poudriere 1 rue du 13 aout 3002 sfax tunisie"
replace rg_siteweb = "`check_again'" if rg_siteweb == "médenine"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www@ttls.tn"
replace rg_siteweb = "`check_again'" if rg_siteweb == "tunis"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www@ttls.tn"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.vibestrip@gmail.com"
replace rg_siteweb = "`check_again'" if rg_siteweb == "en cours"
replace rg_siteweb = "`check_again'" if rg_siteweb == "pema"
replace rg_siteweb = "`check_again'" if rg_siteweb == "non"
replace rg_siteweb = "`check_again'" if rg_siteweb == "nabeul"
replace rg_siteweb = "`check_again'" if rg_siteweb == "pas de site"
replace rg_siteweb = "`check_again'" if rg_siteweb == "11 bis rue ali ben khalifa el menzah 9a tunis"
replace rg_siteweb = "`check_again'" if rg_siteweb == "none"
replace rg_siteweb = "`check_again'" if rg_siteweb == "tunis"
replace rg_siteweb = "`check_again'" if rg_siteweb == "km5 rte de raoued 2083 ariana"
replace rg_siteweb = "`check_again'" if rg_siteweb == "engineering & machining precision, rue jawdet elhayet,113,2036 chotrana1, ariana"
replace rg_siteweb = "`check_again'" if rg_siteweb == "ol"
replace rg_siteweb = "`check_again'" if rg_siteweb == "sotudex"
replace rg_siteweb = "`check_again'" if rg_siteweb == "55 av al maghreb ala arabi hazoua 2223 tozeur 2200"
replace rg_siteweb = "`check_again'" if rg_siteweb == "...."
replace rg_siteweb = "`check_again'" if rg_siteweb == "contact@portyasmine.com.tn"
replace rg_siteweb = "`check_again'" if rg_siteweb == "en cours de préparation"
replace rg_siteweb = "`check_again'" if rg_siteweb == "gda assalna"
replace rg_siteweb = "`check_again'" if rg_siteweb == "rue ennasria, immeuble tej, bloc b , 5ème étage, bureau n°4"
replace rg_siteweb = "`check_again'" if rg_siteweb == "dengry 619.com (site en cours de réalisation)"
replace rg_siteweb = "`check_again'" if rg_siteweb == "port yasmine hammamet"
replace rg_siteweb = "`check_again'" if rg_siteweb == "fb.comdhm.sarl - linkedin.comcompanydhm"
replace rg_siteweb = "`check_again'" if rg_siteweb == "zone industrielle poudrière 2"
replace rg_siteweb = "`check_again'" if rg_siteweb == "gda assalna"
replace rg_siteweb = "`check_again'" if rg_siteweb == "gdfhms@hotmail.com"
replace rg_siteweb = "`check_again'" if rg_siteweb == "rte de gabes km 2.5 zi sidi salem sfax"
replace rg_siteweb = "`check_again'" if rg_siteweb == "gda assalna"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.sweetbroderie@gmail.com"
replace rg_siteweb = "`check_again'" if rg_siteweb == "app 0.3,res tej ezzahra,rue fattouma bourguiba, la soukra"
replace rg_siteweb = "`check_again'" if rg_siteweb == "med'in outlook, app 03,res tej ezzahra,la soukra,ariena"
replace rg_siteweb = "`check_again'" if rg_siteweb == "le site webe est en cours de constriction"
replace rg_siteweb = "`check_again'" if rg_siteweb == "entreprise bourbeh"
replace rg_siteweb = "`check_again'" if rg_siteweb == "soccomi"
replace rg_siteweb = "`check_again'" if rg_siteweb == "en cours"
replace rg_siteweb = "`check_again'" if rg_siteweb == "sodaq"
replace rg_siteweb = "`check_again'" if rg_siteweb == "ste.tnfrentreprisehuilerie-el-yousser"
replace rg_siteweb = "`check_again'" if rg_siteweb == "en cour"
replace rg_siteweb = "`check_again'" if rg_siteweb == "artizana mechy production"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.youtube.comwatch?v=duwgz6munuu"
replace rg_siteweb = "`check_again'" if rg_siteweb == "résidence les jasmins , 21 , avenue des etats unis , belvédère 1002 tunis , tunisie"
replace rg_siteweb = "`check_again'" if rg_siteweb == "hagguiadel07@gmail.com"
replace rg_siteweb = "`check_again'" if rg_siteweb == "texpro-corp"
replace rg_siteweb = "`check_again'" if rg_siteweb == "sfax"
replace rg_siteweb = "`check_again'" if rg_siteweb == "tunisie gafsa"
replace rg_siteweb = "`check_again'" if rg_siteweb == "rue malek ibn anes 8030 grombalia"
replace rg_siteweb = "`check_again'" if rg_siteweb == "texpro"
replace rg_siteweb = "`check_again'" if rg_siteweb == "haffouz"
replace rg_siteweb = "`check_again'" if rg_siteweb == "al"
replace rg_siteweb = "`check_again'" if rg_siteweb == "b02 residence el jine 2046 sidi daoued"
replace rg_siteweb = "`check_again'" if rg_siteweb == "al"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.facebook.comquincaillerie.benabdallah.31"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.facebook.comrafiahandmade"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.facebook.comblastycoworking"
replace rg_siteweb = "`check_again'" if rg_siteweb == "sté cerealis, les berges du lac1, tunis"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.facebook.compagescategorycomputer-companychaniour-informatique-solution-tataouine-105490917973601"
replace rg_siteweb = "`check_again'" if rg_siteweb == "en cours de création"
replace rg_siteweb = "`check_again'" if rg_siteweb == "_"
replace rg_siteweb = "`check_again'" if rg_siteweb == "ariana"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.facebook.comdoukali.formation.continue"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.facebook.comelite.academy.mhamedia?ref=pages_you_manage"
replace rg_siteweb = "`check_again'" if rg_siteweb == "adsopafi@topnet.tn"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.facebook.combodylove-cosmetics-104607768332102"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.facebook.comfikradesign.tn"
replace rg_siteweb = "`check_again'" if rg_siteweb == "en cours de réalisation"
replace rg_siteweb = "`check_again'" if rg_siteweb == "borj cedria"
replace rg_siteweb = "`check_again'" if rg_siteweb == "gouvernerat medenine ,sidi makhloof"
replace rg_siteweb = "`check_again'" if rg_siteweb == "manouba"
replace rg_siteweb = "`check_again'" if rg_siteweb == "jendouba"
replace rg_siteweb = "`check_again'" if rg_siteweb == "en cours de développement"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.facebook.comol%c3%a9a-amiri-113583540352584"
replace rg_siteweb = "`check_again'" if rg_siteweb == "pas"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.facebook.comcactuskairouanais"
replace rg_siteweb = "`check_again'" if rg_siteweb == "l.facebook.coml.php?u=https%3a%2f%2fwww.jumia.com.tn%2fagromatica%2f%3ffbclid%3diwar1trbpqs4ajjcqr8re4htjxkykjakyl0d10sih1pjn8sde67vkst1r4su8&h=at1hy0i_qjalwn49kmsniwfliwwqzmvu1mrjolztgqmt7ah1m4kp0a6w7octqdwgljpbfcbiqobikxfyh9-iupnouloifuckr8pwoldmm7re0ev5txmfrneasxwy608gsw3cpw"
replace rg_siteweb = "`check_again'" if rg_siteweb == "neferis@neferis.com"
replace rg_siteweb = "`check_again'" if rg_siteweb == "www.facebook.comprofile.php?id=100063505572661"
replace rg_siteweb = "`check_again'" if rg_siteweb == "nezzeddine@steg.com.tn"
replace rg_siteweb = "`check_again'" if rg_siteweb == "abssfaxexport@gmail.com"
replace rg_siteweb = "`check_again'" if rg_siteweb == "av al maghreb el arabi hazoua"
replace rg_siteweb = "`check_again'" if rg_siteweb == "pas encore"
replace rg_siteweb = "`check_again'" if rg_siteweb == "kébili"

}

****Correct the social network ******
{
replace rg_media = ustrregexra(rg_media ,"https://","")
replace rg_media = ustrregexra(rg_media ,"http://","")
replace rg_media = "`check_again'" if rg_media == "route sidi-bouzid .km 5 maknassy nord 9140"
replace rg_media = "`check_again'" if rg_media == "1 rue turkana, imb prince du lac, n°1, lac 1, 1053 tunis"
replace rg_media = "`check_again'" if rg_media == "polygom.com.tn"
replace rg_media = "`check_again'" if rg_media == "www.gil-swimwear.com"
replace rg_media = "`check_again'" if rg_media == "www.generaleindustrie.com"
replace rg_media = "`check_again'" if rg_media == "polygom.com.tn"
replace rg_media = "`check_again'" if rg_media == "laperlaoliveoil.com"
replace rg_media = "`check_again'" if rg_media == "12, rue du caire nabeul 8000"
replace rg_media = "`check_again'" if rg_media == "sarl"
replace rg_media = "`check_again'" if rg_media == "www.tpadoffice.com"
replace rg_media = "`check_again'" if rg_media == "58 rue de martyrs sidi bouzid 9100"
replace rg_media = "`check_again'" if rg_media == "société anonyme"
replace rg_media = "`check_again'" if rg_media == "معصرة الهاشمي قوادرية البيولوجية"
replace rg_media = "`check_again'" if rg_media == "39, avenue de japon, immeuble safsaf, bloc a 3 eme etage a-3.1, montplaisir tunis."
replace rg_media = "`check_again'" if rg_media == "jerba"
replace rg_media = "`check_again'" if rg_media == "www.groupebismuth.com"
replace rg_media = "`check_again'" if rg_media == "sfax"
replace rg_media = "`check_again'" if rg_media == "rue du safran, cité loulija, ezzahra, ben aous"
replace rg_media = "`check_again'" if rg_media == "lot n°11 rue de nabeul zone industrielle el mghira ii, fouchena, ben arous"
replace rg_media = "`check_again'" if rg_media == "ecole ennajeh, centre de formation ennajeh monastir"
replace rg_media = "`check_again'" if rg_media == "agencement, fabrication de meuble et ameublement"
replace rg_media = "`check_again'" if rg_media == "moknine route manzel fersi km 2"
replace rg_media = "`check_again'" if rg_media == "sfax"
replace rg_media = "`check_again'" if rg_media == "sfax"
replace rg_media = "`check_again'" if rg_media == "sfax"
}
*****Correct the firm name ******
{

replace firmname = "`check_again'" if firmname == "06 rue khalil materane cité ettadhamen"
replace firmname = "`check_again'" if firmname == "32, avenue habib bourguiba-bureau 3-4 nouvelle ariana 2080 tunisie"
replace firmname = "`check_again'" if firmname == "lif africa à pour objectif de développer le marché de l’emploi en afrique dans ses différentes succursales"
replace firmname = "`check_again'" if firmname == "sarl"
replace firmname = "`check_again'" if firmname == "sa"
replace firmname = "`check_again'" if firmname == "suarl"
replace firmname = "`check_again'" if firmname == "zi jebel el ouest bp n°36-1111-zaghouan- tunisie"
replace firmname = "`check_again'" if firmname == "مخازن التبريد بالوسط"
replace firmname = "`check_again'" if firmname == "suarl"
replace firmname = "`check_again'" if firmname == "rue med negra kairouan"
replace firmname = "`check_again'" if firmname == "société anonyme"
replace firmname = "`check_again'" if firmname == "16558554/m/a/m/000"
replace firmname = "`check_again'" if firmname == "_"
replace firmname = "`check_again'" if firmname == "association"
replace firmname = "`check_again'" if firmname == "industrielle"
replace firmname = "`check_again'" if firmname == "rue med negra kairouan"

}

* variable: Téléphonedudelagérante
replace rg_telpdg = ustrregexra( rg_telpdg, "^[\+]216", "")
replace rg_telpdg = ustrregexra( rg_telpdg, "^216", "")
replace rg_telpdg = subinstr(rg_telpdg, " ", "", .)
replace rg_telpdg = ustrregexra( rg_telpdg,"[a-z]","")
replace rg_telpdg = ustrregexra( rg_telpdg,"00216","")
replace rg_telpdg = "98412425" if rg_telpdg == "+21698412425"
replace rg_telpdg = "`check_again'" if rg_telpdg == "nasralichakroun"


* variable: Qualité/fonction
{
replace rg_position_rep = ustrlower(rg_position_rep)
replace rg_position_rep = "account manager" if rg_position_rep == "acount manager"
replace rg_position_rep = "business development manager" if rg_position_rep == "business développement manager"
replace rg_position_rep = "gérant" if rg_position_rep == "gerant"
replace rg_position_rep = "gérante" if rg_position_rep == "gerante"
replace rg_position_rep = "gérant" if rg_position_rep == "gerant"
replace rg_position_rep = "responsable commercial" if rg_position_rep == "res commercial"
replace rg_position_rep = "responsable financier" if rg_position_rep == "resp.financier"
replace rg_position_rep = "responsable commercial" if rg_position_rep == "responsables commercials"
replace rg_position_rep = "financière" if rg_position_rep == "financiere"
replace rg_position_rep = "gestionnaire des opérations" if rg_position_rep == "gestionnaire des operations"
replace rg_position_rep = "directeur technique" if rg_position_rep == "directeur techique"
replace rg_position_rep = "coo" if rg_position_rep == "c.o.o"
}

* variable: Matricule CNSS
{
replace rg_matricule = ustrregexra(rg_matricule, "[ ]", "")
replace rg_matricule = ustrregexra(rg_matricule, "[/]", "-")
replace rg_matricule = ustrregexra(rg_matricule, "[_]", "-")

* Format CNSS Number:
gen t1 = ustrregexs(0) if ustrregexm(rg_matricule, "\d{8}")
gen t2 = ustrregexs(0) if ustrregexm(t1, "[0-9][0-9][0-9][0-9][0-9][0-9]")
gen t3 = ustrregexs(0) if ustrregexm(t1, "[0-9][0-9]`") 
gen t4 = t2 + "-" + t3
replace t4 = ustrregexra(t4, "[-]", "") if length(t4)==1
replace rg_matricule = t4 if length(rg_matricule)==8
drop t1 t2 t3 t4 

* Format CNRPS Number:

gen t1 = ustrregexs(0) if ustrregexm(rg_matricule, "\d{10}")
gen t2 = ustrregexs(0) if ustrregexm(t1, "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]")
gen t3 = ustrregexs(0) if ustrregexm(t1, "[0-9][0-9]`") 
gen t4 = t2 + "-" + t3
replace t4 = ustrregexra(t4, "[-]", "") if length(t4)==1
replace rg_matricule = t4 if length(rg_matricule)==10

drop t1 t2 t3 t4 

replace rg_matricule  = "`check_again'" if rg_matricule == "02877-62"
replace rg_matricule  = "`check_again'" if rg_matricule == "1342aam000"
replace rg_matricule  = "`check_again'" if rg_matricule == "17"
replace rg_matricule  = "`check_again'" if rg_matricule == "1548345"
replace rg_matricule  = "`check_again'" if rg_matricule == "276297"
replace rg_matricule  = "`check_again'" if rg_matricule == "2828-50"
replace rg_matricule  = "`check_again'" if rg_matricule == "3212417"
replace rg_matricule  = "`check_again'" if rg_matricule == "405216"
replace rg_matricule  = "`check_again'" if rg_matricule == "5524552"
replace rg_matricule  = "`check_again'" if rg_matricule == "5643390"
replace rg_matricule  = "`check_again'" if rg_matricule == "01755t"
replace rg_matricule  = "`check_again'" if rg_matricule == "7260852"


/*
replace rg_matricule = "`check_again'" if length(rg_matricule) >= 12 | length(rg_matricule) <= 7
*/

}
***********************************************************************
* 	PART 3:  Replace string with numeric values		  			
***********************************************************************
{
*** cleaning capital social ***
replace rg_capital = ustrregexra( rg_capital,",","")
replace rg_capital = ustrregexra( rg_capital," ","")
replace rg_capital = ustrregexra( rg_capital,"dinars","")
replace rg_capital = ustrregexra( rg_capital,"dt","")
replace rg_capital = ustrregexra( rg_capital,"millions","000")
replace rg_capital = ustrregexra( rg_capital,"mill","000")
replace rg_capital = ustrregexra( rg_capital,"tnd","")
replace rg_capital = "10000" if rg_capital == "10.000"
replace rg_capital = "1797000" if rg_capital == "1.797.000"
replace rg_capital = "50000" if rg_capital == "50.000"
replace rg_capital = ustrregexra( rg_capital,"e","")
replace rg_capital = ustrregexra( rg_capital,"m","")
replace rg_capital = "30000" if rg_capital == "30000n"

replace rg_capital = ustrregexra( rg_capital,"000","") if strlen( rg_capital) >= 9
replace rg_capital = "`check_again'" if strlen( rg_capital) == 1
replace rg_capital = "`check_again'" if strlen( rg_capital) == 2


replace rg_capital = "`check_again'" if rg_capital == "tunis"

*Test logical values*

* In Tunisia, SCA and SA must have a minimum of 5000 TND of capital social

*All values having a too small capital social (less than 100)
replace rg_capital = "`check_again'" if rg_capital == "0"
replace rg_capital = "`check_again'" if rg_capital == "o"
destring rg_capital, replace




}
***********************************************************************
* 	PART 4:  Convert string to numerical variaregises	  			
***********************************************************************
local destrvar "rg_fte rg_fte_femmes id_plateforme"
foreach x of local destrvar { 
destring `x', replace
}


***********************************************************************
* 	PART 5:  Convert problematic values for open-ended questions  			
***********************************************************************
{

	* Sectionname
*replace q04 ="Hors sujet" if q04 == "OUI" 

*Correction nom du representant
replace rg_nom_rep="`check_again'" if rg_nom_rep == "Études géomatiques." 

 
}

***********************************************************************
* 	PART 6:  Traduction reponses en arabe au francais		  			
***********************************************************************
{
* Sectionname
/*
replace q05="directeur des ventes"  if q05=="مدير المبيعات" 
*/

}

***********************************************************************
* 	PART 7: 	Rename and homogenize the observed values		  			
***********************************************************************
{
	* Sectionname
*replace regis_unite = "pièce"  if regis_unite=="par piece"
*replace regis_unite = "pièce"  if regis_unite=="Pièce" 

}


***********************************************************************
* 	PART 8:  Import categorisation for opend ended QI questions
***********************************************************************
{
/*
	* the manually handed categories are in the folder data/AQE/surveys/midline/categorisation/copies
			* q42, q15c5, q18m5, q10n5, q10r5, q21example
local categories "argument-vente source-informations-conformité source-informations-metrologie source-normes source-reglements-techniques verification-intrants-fournisseurs"
foreach x of local categories {
	preserve

	cd "`regis_categorisation"
	
	import excel "`{regis_categorisation}/Copie de categories-`x'.xlsx", firstrow clear
	
	duplicates drop id, force

	cd "`regis_intermediate"

	save "`x'", replace

	restore

	merge 1:1 id using `x'
	
	save, replace

	drop if _merge == 2 /* drops all non matched rows from coded categories */
	
	drop _merge
	}
	* format variables

format %-25s q42 q42c q15c5 q18m5 q10n5 q10r5 q21example q15c5c q18m5c q10n5c q10r5c q21examplec

	* visualise the categorical variables
			* argument de vente
codebook q42c /* suggère qu'il y a 94 valeurs uniques doit etre changé */
graph hbar (count), over(q42c, lab(labs(tiny)))
			* organisme de certification
graph hbar (count), over(q15c5c, lab(labs(tiny)))
graph hbar (count), over(q10n5c, lab(labs(tiny)))


	* label variable categories
lab var q42f "(in-) formel argument de vente"
*/
}


***********************************************************************
* 	PART 9:  Identify duplicates (for removal see regis_generate)
***********************************************************************
	* formating the variables for whcih we check duplicates
format firmname rg_emailrep rg_emailpdg %-35s
format id_plateforme %9.0g
sort firmname
	
	* id_plateform
duplicates report id_plateform

	* email
duplicates report rg_emailrep
duplicates report rg_emailpdg
duplicates tag rg_emailpdg, gen(dup_emailpdg)

	* firmname	
duplicates report firmname
duplicates tag firmname, gen(dup_firmname)


***********************************************************************
* 	PART 10:  autres / miscallaneous adjustments
***********************************************************************
	* correct the response categories for moyen de communication
replace moyen_com = "site institution gouvernmentale" if moyen_com == "site web d'une autre institution gouvernementale" 
replace moyen_com = "bulletin d'information giz" if moyen_com == "bulletin d'information de la giz"

	* correct wrong response categories for subsectors
replace subsector = "industries chimiques" if subsector == "industrie chimique"

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
cd "$regis_intermediate"
save "regis_inter", replace
