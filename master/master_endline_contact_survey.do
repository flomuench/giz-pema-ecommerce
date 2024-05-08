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
    not matched                           110
        from master                       110  (_merge==1)
        from using                          0  (_merge==2)

    matched                               117  (_merge==3)
    -----------------------------------------
*/

generate take_up=1
replace take_up=0 if take_up_for == 0
replace take_up=0 if take_up_std == 0
replace take_up=0 if take_up_seo == 0 & take_up_smo == 0 & take_up_website ==0
label var take_up "Take up in the activities"
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
*PART 4.1: Import pii information
***********************************************************************
preserve
import excel "${master_pii}/midline_contactlist.xls", firstrow clear 
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
drop if _merge==2
drop dig_presence1 dig_presence2 dig_presence3 
drop _merge
rename rg_emailpdg email_pdg 
order id_plateforme matricule_fiscale matricule_missing firmname status nom_rep entr_produit1 entr_produit2 entr_produit3 entr_histoire telrep tel_sup1 tel_sup2 rg_telpdg rg_telephone2 email_pdg emailrep rg_email2 take_up take_up_for take_up_std take_up_seo take_up_smo take_up_smads take_up_website take_up_heber link_web link_facebook link_instagram link_twitter link_linkedin link_youtube

***********************************************************************
*PART 4.2: Import updated pii information
***********************************************************************
preserve
import excel "${master_pii}/Etat Entreprise PEMA Final.xlsx", firstrow clear 
	drop if id_plateforme==.
	destring id_plateforme,replace
save "${master_pii}/Etat_Entreprise_PEMA_Final.dta",replace
restore
merge 1:1 id_plateforme using "${master_pii}/Etat_Entreprise_PEMA_Final", force
/* 
    Result                           # of obs.
    -----------------------------------------
    not matched                            162
        from master                        162  (_merge==1)
        from using                         0  (_merge==2)

    matched                               74  (_merge==3)
    -----------------------------------------
*/
drop Audit Structure Maquette Contenu Développementdusite Finaliséà100 Motifdarrêt SocialMedia FormationSocialADS RéférenementNaturel R IntégrationSEO2empassage _merge

***********************************************************************
*PART 4.2: Import midline pii information
***********************************************************************
preserve
use "${master_raw}/ml_contacts.dta", clear 
	drop if id_plateforme==.
	destring id_plateforme,replace
save "${master_pii}/ml_contacts.dta",replace
restore
merge 1:1 id_plateforme using "${master_pii}/ml_contacts.dta", force
/* 
    Result                           # of obs.
    -----------------------------------------
    not matched                            31
        from master                        31  (_merge==1)
        from using                          0  (_merge==2)

    matched                               205  (_merge==3)
    -----------------------------------------
*/
replace firmname= firmname_change  if firmname_change!=""
drop firmname_change
drop Position_rep_midline

rename nom_rep nom_rg
gen nom=""
replace nom = Nom if treatment == "Treatment"
replace nom = nom_rg if nom ==""
drop Nom

rename tel_supl1 tel1_ml
rename tel_supl2 tel2_ml
rename tel_sup1 tel1_bl
rename tel_sup2 tel2_bl

order id_plateforme matricule_fiscale matricule_missing firmname status nom nom_rg repondant_midline entr_produit1 entr_produit2 entr_produit3 entr_histoire téléphone telrep tel1_ml tel2_ml tel1_bl tel2_bl rg_telpdg rg_telephone2 email_pdg emailrep emailreprésentante rg_email2 take_up take_up_for take_up_std take_up_seo take_up_smo take_up_smads take_up_website take_up_heber link_web link_facebook link_instagram link_twitter link_linkedin link_youtube

***********************************************************************
*PART 5: Correct some names and values
***********************************************************************
replace status="participant" if status=="no show"

replace entr_produit1= "aliments composés pour toutes espèces (volailles, ruminants, lapin, cheval..)" if id_plateforme == 436
replace entr_produit2= "prémix" if id_plateforme == 436
replace entr_produit3= "matières premières tels que soja extrudé (fullfat) et tourteau de soja express" if id_plateforme == 436

replace entr_produit1= "cuisines / pose" if id_plateforme == 521
replace entr_produit2= "dressings / pose" if id_plateforme == 521
replace entr_produit3= "meubde salde bain / pose" if id_plateforme == 521
				
replace entr_produit1= "conseil en stratégie, organisation et financiers" if id_plateforme == 623
replace entr_produit2= "assistance it" if id_plateforme == 623
replace entr_produit3= "outsourcing, audit financier et assistance comptable, fiscaet juridique" if id_plateforme == 623

replace entr_produit2= "legume" if id_plateforme == 644
replace entr_produit3= "dattes" if id_plateforme == 644
	
replace entr_produit2= "audit" if id_plateforme == 803
replace entr_produit3= "etuet conseils" if id_plateforme == 803

replace entr_produit1= "skit solaire connecté réseau,site isolé et pompage solaire" if id_plateforme == 108

replace entr_produit1= "carreaux céramique" if id_plateforme == 875 
replace entr_produit2= "grès" if id_plateforme == 875 
replace entr_produit3= "sanitaires et robinetteries" if id_plateforme == 875 

replace entr_produit1 = "jeans"  if entr_produit1=="djaen"
replace entr_produit1 = "crevettes"  if entr_produit1=="creveutte"
replace entr_produit1 = "tapis"  if entr_produit1=="tapies"
replace entr_produit1 = "huide romarain"  if entr_produit1=="huide romaraine"
replace entr_produit1 = "outillage aéronautique"  if entr_produit1=="auquillage aeronothaique"
replace entr_produit1 = "charcuterie"  if entr_produit1=="charcxuterie"
replace entr_produit1 = "carreaux de marbre"  if entr_produit1=="caro de marbre"
replace entr_produit1 = "produits en fibre végétale (cofain;chapeux;sac)"  if entr_produit1=="produits en fibre végita(cofain;chapeux;sac)"
replace entr_produit1 = "céramique"  if entr_produit1=="ciramic"
replace entr_produit1 = "tuiles"  if entr_produit1=="9armoud"
replace entr_produit1 = "dattes"  if entr_produit1=="tmar"
replace entr_produit1 = "maillots de bain"  if entr_produit1=="mayo de bain"

replace entr_produit1 = "Farine à la tomate" if entr_produit1 == "فارينة طماطم"
replace entr_produit2 = "Farine aux oignons" if entr_produit2 == "فارينة بصل"
replace entr_produit3 = "farine à l'ail" if entr_produit3 == "فارينة ثوم"
replace entr_produit1 = "matériel éléctrique" if entr_produit1 == "المواد الكهربائية"
replace entr_produit2 = "matériaux de construction" if entr_produit2 == "مواد البناء"
replace entr_produit3 = "produits agro-alimentaires" if entr_produit3 == "الصناعات الغذائية"


replace entr_histoire = "International Trading and Consulting Company est une société entièrement exportatrice créée en 2006, caractérisée par une vaste expérience dans le domaine du commerce international et sa mission principale est d'améliorer l'activité des clients en fournissant la meilleure valeur pour leurs investissements dans le monde." if entr_histoire == "الشركة الدولية للتجارة والاستشارة هي شركة مصدرة بالكامل تأسست سنة 2006, تتميز بخبرة واسعة في مجال التجارة الدولية وتتمثل مهمتها الأساسية في تعزيز أعمال العملاء من خلال تقديم أفضل قيمة لاستثماراتهم في العالم، كما تقدم الشركة خدمات استشارية تمحور بالاساس حول طرق تقليل تكاليف الشراء والنقل وتسهيل عمل الحرفاء."
replace entr_histoire = "L'entreprise a débuté en tant que personne physique en 2002. montage d'entreprise ; c pas évident de status physique ; donc l'entreprise existe sur terrain et exporte vers l'europe depuis 2007 (ca fait 15 ans), danden et medina arbi tounes" if entr_histoire == "bdet en personne physique en 2002; montage d'entreprise ; c pas evident de status physique ; mawjouda men 2007 walet mawjouda sur terain et exporté vers l'europe , ca fait 15 ans ; danden et medina arbi tounes" 
replace entr_histoire = "l'entreprise continue d'exister car mon père était le PDG et il travaille le marbre. l'entreprise a été fondée en 2011. l'extraction et la transformation du marbre et la production ont débuté en juillet 2014" if entr_histoire == "charika tawasol 5ter weled il gérant ken marbre . t2aseset en 2011  lextraction et la trasformation du marbre imporoduction en juillet 2014 ." 
replace entr_histoire = "commerce internationnal 2017 (des dattes naturelles , condiciones )en 2019 (nous avons ouvert une fabrication) 2020 (a obtenu un certificat (Halal)" if entr_histoire == "commerce internationnal 2017 (des dattes naturele , condecionnes )en 2019 ( 3malna ma3mel ) 2020(5dhina chhada (7alel)" 
replace entr_histoire = "l'entreprise était locale et maintenant nous exportons, puis nous avons ouvert l'entreprise de Kantaoui fashion et la première entreprise a été fondée en 2001" if entr_histoire == "kenet local w tawa walet a l'export w ba3d halina socité kantaoui fashion w charika loula bdet 2001" 
replace entr_histoire = "l'entreprise a été construite sur l'idée de l'art et de l'artisanat en général. la PDG a fait une formation en italie et en grèce et elle a apporté l'idée en tunisie" if entr_histoire == "kenet mabniya 3la fekret l fan w lartisana 3amatan ; elle a fait un formation a l'italie w mchet l grec w jebetha ltounes" 
replace entr_histoire = "Fondée en 2016, dans le domaine de la couture." if entr_histoire == "men 2016 majel 5iyata finition  tenus de traville"

replace matricule_missing=1 if matricule_fiscale=="CENTRAX"
replace matricule_missing=1 if matricule_fiscale=="931877D"
replace matricule_missing=1 if matricule_fiscale=="655112G"
replace matricule_missing=1 if matricule_fiscale=="615241H"
replace matricule_missing=1 if matricule_fiscale=="1554011/"
replace matricule_missing=1 if matricule_fiscale=="1066365"
replace matricule_missing=1 if matricule_fiscale=="1234568G"
replace matricule_missing=1 if matricule_fiscale=="1766520B"

replace firmname= "Aviation Training Center of Tunsia SA" if id_plateforme==95
replace firmname= "STE Ecomevo" if id_plateforme==172
replace firmname= "Al-Bushra Co‎" if id_plateforme==332
replace firmname= "Tipad LLC‎" if id_plateforme==572
replace firmname= "STE Holya Interios" if id_plateforme==708
replace firmname= "Mediterranean School Of Business" if id_plateforme==795
replace firmname = "URBA TECH" if id_plateforme == 890
replace firmname = "Etamial" if id_plateforme == 642
replace firmname = "ENTREPOTS FRIGORIFIQUES DU CENTRE" if id_plateforme == 416
replace firmname = "tpad ( technical and practical assistance to development)" if id_plateforme == 572
replace firmname = "central cold stores / مخازن التبريد بالوسط" if id_plateforme == 642

replace take_up=0 if status=="groupe control"
drop matricule_physique


***********************************************************************
*PART 5: Export the final excel
***********************************************************************
export excel "${master_pii}/endline_contactlist.xlsx", firstrow(variables) replace
