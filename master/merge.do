***********************************************************************
* 			E-commerce - master merge									  
***********************************************************************
*																	  
*	PURPOSE: make all data work reproducible, merge & analysis survey 
*            & pii data related to ecommerce program Tunisia
*  
*	OUTLINE: 	PART 1:   
*				PART 2: 	  
*				PART 3:               
*																	  
*																	  
*	Author:  						    
*	ID variable: 	id_plateforme			  					  
*	Requires: ecommerce_bl_pii.dta	ecommerce_regis_pii.dta										  
*	Creates:  ${master_pii}/ecommerce_master_contact.dta			                                  
***********************************************************************
* 	PART 1: merge to create master data set (pii)
***********************************************************************
	* merge baseline data with registration pii
use "${bl_intermediate}/ecommerce_bl_pii", clear
		
		* change directory to regis folder for merge with regis_final
cd "$regis_final"

		* merge 1:1 based on project id_plateforme
merge 1:1 id_plateforme using ecommerce_regis_pii
drop _merge

    * create panel ID
gen survey_round=1

***********************************************************************
* 	PART 2: save as ecommerce_contact_database
***********************************************************************
save "${master_pii}/ecommerce_master_contact", replace

***********************************************************************
* 	PART 3: append to create master data set (pii)
***********************************************************************

/*
	* append registration +  baseline data with midline
cd "$midline_final"
merge 1:1 id using ml_final_pii
drop _merge


	* append with endline
cd "$endline_final"
merge 1:1 id using el_final_pii
drop _merge

*/
***********************************************************************
* 	PART 4: integrate and replace contact updates
***********************************************************************

* import Update_file:
* Note: here should the Update_file.xlsx be downloaded from teams, renamed and uploaded again in 6-master

clear
import excel "${master_pii}/Update_file.xlsx", sheet("update_entreprises") firstrow clear
duplicates report
duplicates drop
drop W-AU treatment firmname region sector subsector entr_bien_service entr_produit1 siteweb media Update

rename M firmname2
rename P emailrep2
rename R telrep2

reshape wide emailrep telrep firmname2 nom_rep position_rep emailrep2 emailpdg telrep2 telpdg adresse, i(id_plateforme) j(surveyround, string)

merge 1:1 id_plateforme using  "${master_pii}/ecommerce_master_contact" 
drop _merge
*drop session1 session2 session3 session4


*UPDATE MATRICULE FISCALE WHERE NECESSARY
	*making all matricule_fiscale uppercase
replace matricule_fiscale = upper(matricule_fiscale)

	*correcting entries
replace matricule_fiscale = "0009951F" if id_plateforme == 443
replace matricule_fiscale = "1230487A" if id_plateforme == 511
replace matricule_fiscale = "0002495X" if id_plateforme == 724
replace matricule_fiscale = "0752330Y" if id_plateforme == 769
replace matricule_fiscale = "0383708H" if id_plateforme == 810
replace matricule_fiscale = "0557321F" if id_plateforme == 78
replace matricule_fiscale = "0977263A" if id_plateforme == 82
replace matricule_fiscale = "0620862R" if id_plateforme == 122
replace matricule_fiscale = "0916623S" if id_plateforme == 144
replace matricule_fiscale = "0411643S" if id_plateforme == 153
replace matricule_fiscale = "0950448R" if id_plateforme == 183
replace matricule_fiscale = "0418325L" if id_plateforme == 237
replace matricule_fiscale = "0005540X" if id_plateforme == 240
replace matricule_fiscale = "0426073G" if id_plateforme == 244
replace matricule_fiscale = "0598608V" if id_plateforme == 416
replace matricule_fiscale = "0510043A" if id_plateforme == 466
replace matricule_fiscale = "0945413W" if id_plateforme == 489
replace matricule_fiscale = "1066365" if id_plateforme == 508
replace matricule_fiscale = "1776211C" if id_plateforme == 519
replace matricule_fiscale = "0840123K" if id_plateforme == 521
replace matricule_fiscale = "0945162W" if id_plateforme == 568
replace matricule_fiscale = "0933473V" if id_plateforme == 587
replace matricule_fiscale = "1618296V" if id_plateforme == 643
replace matricule_fiscale = "0447064W" if id_plateforme == 644
replace matricule_fiscale = "1261600C" if id_plateforme == 698
replace matricule_fiscale = "0910604N" if id_plateforme == 714
replace matricule_fiscale = "0849850A" if id_plateforme == 747
replace matricule_fiscale = "0035648A" if id_plateforme == 764
replace matricule_fiscale = "0341549F" if id_plateforme == 767
replace matricule_fiscale = "0011580T" if id_plateforme == 782
replace matricule_fiscale = "0036963N" if id_plateforme == 791
replace matricule_fiscale = "1434685K" if id_plateforme == 800
replace matricule_fiscale = "0006013G" if id_plateforme == 820	
replace matricule_fiscale = "0719484A" if id_plateforme == 833
replace matricule_fiscale = "0736255L" if id_plateforme == 861
replace matricule_fiscale = "0010690V" if id_plateforme == 873
replace matricule_fiscale = "1585667W" if id_plateforme == 890
replace matricule_fiscale = "0036115D" if id_plateforme == 899
replace matricule_fiscale = "0736406H" if id_plateforme == 909
replace matricule_fiscale = "0708451F" if id_plateforme == 910
replace matricule_fiscale = "0598608V" if id_plateforme == 416
replace matricule_fiscale = "1230487A" if id_plateforme == 511
replace matricule_fiscale = "0496192B/ 0749702G" if id_plateforme == 765
	
*missing matricule
gen matricule_missing = 0  
replace matricule_missing = 1 if id_plateforme == 77 
replace matricule_missing = 1 if id_plateforme == 381  
replace matricule_missing = 1 if id_plateforme == 827 
replace matricule_missing = 1 if id_plateforme == 841 
replace matricule_missing = 1 if id_plateforme == 956
 
*create dummy for physical matricule fiscale
gen matricule_physique = 0
replace matricule_physique = 1 if id_plateforme == 427
replace matricule_physique = 1 if id_plateforme == 114 
replace matricule_physique = 1 if id_plateforme == 206
replace matricule_physique = 1 if id_plateforme == 505
replace matricule_physique = 1 if id_plateforme == 620
replace matricule_physique = 1 if id_plateforme == 642
replace matricule_physique = 1 if id_plateforme == 742
replace matricule_physique = 1 if id_plateforme == 752
replace matricule_physique = 1 if id_plateforme == 763
replace matricule_physique = 1 if id_plateforme == 927
replace matricule_physique = 1 if id_plateforme == 931
replace matricule_physique = 1 if id_plateforme == 927


*replace
replace matricule_fiscale = "1591619A" if id_plateforme == 427
replace matricule_fiscale = "1211885E" if id_plateforme == 114
replace matricule_fiscale = "0496140N" if id_plateforme == 206
replace matricule_fiscale = "1172183K" if id_plateforme == 505
replace matricule_fiscale = "1577031R" if id_plateforme == 620
replace matricule_fiscale = "1109532D" if id_plateforme == 642
replace matricule_fiscale = "1407099T" if id_plateforme == 742
replace matricule_fiscale = "1553223V" if id_plateforme == 752
replace matricule_fiscale = "1575123L" if id_plateforme == 763
replace matricule_fiscale = "1299421C" if id_plateforme == 927
replace matricule_fiscale = "1473584Y" if id_plateforme == 931
replace matricule_fiscale = "1299421C" if id_plateforme == 927

*additional changes with help of midline
replace matricule_fiscale = "1172183K" if id_plateforme == 505


save "${master_pii}/ecommerce_master_contact", replace

*merge participation data to contact master
clear 
import excel "${master_pii}/suivi_ecommerce.xlsx", sheet("Suivi_formation") firstrow clear
keep id_plateforme groupe firmname region nom_rep emailrep telrep module1 module2 module3 module4 module5 present absent
drop if id_plateforme== ""
drop if id_plateforme== "id_plateforme"
destring id_plateforme,replace
rename firmname firmname2

merge 1:1 id_plateforme using "${master_pii}/ecommerce_master_contact"
drop _merge


*export excel for el amouri
*considered treated once attended at least 3
gen treated=0
replace treated=1 if present>2 & present<.

gen status= "groupe control" 
replace status= "participant" if present>0 & present<.
replace status= "no show" if present==0

*change firmname where applicable
replace firmname2=firmname if id_plateforme==599
replace firmname=firmname2 if treatment==1
replace firmname = "bizerta agri industry / oilyssa" if id_plateforme==354
replace firmname = "3P Perfection, Prix, Propreté" if id_plateforme==144
replace firmname = "3d wave" if id_plateforme==392

*Adding FIRM NAMES to those that did not provide in the baseline 
replace firmname = "SOUTH MEDITERRANEAN UNIVERSITY" if id_plateforme == 795
replace firmname = "AVIATION TRAINING CENTER OF TUNISIA SA" if id_plateforme == 95
replace firmname = "ECOMEVO" if id_plateforme == 172
replace firmname = "Entreprise Bochra" if id_plateforme == 332
replace firmname = "TPAD" if id_plateforme == 572
replace firmname = "HOLYA INTERIOS" if id_plateforme == 708
replace firmname = "URBA TECH" if id_plateforme == 890
replace firmname = "Etamial" if id_plateforme == 642
replace firmname = "ENTREPOTS FRIGORIFIQUES DU CENTRE" if id_plateforme == 416

drop firmname2* 

*replace where representative changed
replace nom_rep=rg_nom_rep if treatment==0
replace nom_rep= "Abdelkarim Mokhtar" if id_plateforme==107
replace nom_rep= "Ikbel ben mbarouk" if id_plateforme==443
replace nom_rep= "sondes sridi" if id_plateforme==715

*telephone numbers
replace telrep=rg_telrep if treatment==0 
/*replace telrep=telrep+"/"+telrepsession1+"/"+ telrep2session1 +"/" ///
 + telrepsession2 +"/"+ telrep2session2 +"/" + telrepsession3 +"/" ///
 + telrep2session3 +"/"+ telrepsession4 +"/"+telrep2session4

drop telrepsession1 telrep2session1 telrepsession2 ///
 telrep2session2 telrepsession3 telrep2session3 telrepsession4 telrep2session4
 
drop telpdgsession1 telpdgsession2 telpdgsession3 telpdgsession4 rg_telrep
*/
replace emailrep = rg_emailrep if treatment==0
drop emailrepsession1 emailrep2session1 emailrepsession2 emailrep2session2 emailrepsession3 emailrep2session3 emailrepsession4 emailrep2session4
drop emailpdgsession1 emailpdgsession2 emailpdgsession3 emailpdgsession4
drop rg_emailrep 
drop ident_email*
drop if treatment==.

*Change nom_rep where another person filled out the baseline 
replace nom_rep = id_base_repondent if id_plateforme == 108 | id_plateforme == 122 | id_plateforme == 185 | id_plateforme == 195 ///
 | id_plateforme == 254  | id_plateforme == 521 


gen bl_respondent_diff =0 
replace bl_respondent_diff = 1 if id_plateforme == 108 | id_plateforme == 122 | id_plateforme == 185 | id_plateforme == 195 ///
 | id_plateforme == 254  | id_plateforme == 521 | id_plateforme == 511 | id_plateforme == 628| id_plateforme == 586
 

lab var bl_respondent_diff "Baseline respondent different than person from registration"
lab var id_base_respondent "Name of person that filled out baseline if different from rg_nom_rep"
lab var rg_nom_rep "Name of representative at registration"
lab var nom_rep "Name of firm's participant or representative (for control)" 
lab var emailrep "Email of firm's participant or representative (for control)" 
lab var rg_email2 "alternative Email of firm's representative/participant" 
lab var rg_emailpdg "email of CEO"

*additional name variables dropped, as nom_rep was changed were applicable
drop nom_repsession*
   
replace telrep = ustrregexra( telrep,"//////","")   
replace telrep = ustrregexra( telrep,"//","")   
replace telrep = ustrregexra( telrep," ","")
replace telrep = ustrregexra( telrep,"-888","")

*clean email adress line to have 1 email adress per column
replace emailrep = "contact@siele.com.tn" if id_plateforme==105
replace rg_email2 = "sieletn@gmail.com" if id_plateforme==105

replace emailrep = "sales@entrust-trade.com" if id_plateforme==107
replace rg_email2 = "abdelkarim.mokhtar@gmail.com" if id_plateforme==107

replace emailrep = "commercial@generaleindustrie.com" if id_plateforme==231
replace rg_email2 = "youss2009@yahoo.fr" if id_plateforme==107

replace emailrep = "mehdi.elarbi@leplus.tn" if id_plateforme==275
replace rg_email2 = "salimchaabouni@gmail.com" if id_plateforme==275

replace emailrep = "contact@cidattes.tn" if id_plateforme==345
replace rg_email2 = " moez.abid2@gmail.com" if id_plateforme==345

replace emailrep = "melken.kosksi@varat-tunisie.com" if id_plateforme==440
replace rg_email2 = "d.marketing@varat- tunisie.com" if id_plateforme==440

replace emailrep = "imene.agili@scapcb.com" if id_plateforme==443
replace rg_email2 = "ikbel.benmabrouk@scapcb.com" if id_plateforme==443

replace emailrep = "info@ecovillage.com.tn" if id_plateforme==493
replace rg_email2 = "oumeima.ferjaoui@gmail.com" if id_plateforme==493

replace emailrep = "bhwalid.centrax@topnet.tn" if id_plateforme==715
replace rg_email2 = "sondes.sridi@gmail.com" if id_plateforme==715

replace emailrep = "eddar.lamedina@gmail.com" if id_plateforme==810
replace rg_email2 = "dali2808@gmail.com" if id_plateforme==810

replace emailrep = "city.design.13@gmail.com" if id_plateforme==890
replace rg_email2 = "mohamedaliragoubi@yahoo.fr" if id_plateforme==890

replace emailrep = "nadiayaichexpert@gmail.com" if id_plateforme==140
replace rg_email2 = "rania-inj@outlook.com" if id_plateforme==140

replace emailrep = "contact@alpha-engineering.com.tn" if id_plateforme==185
replace rg_email2 = "o.elljmi@alpha-engineering.com.tn" if id_plateforme==185

replace emailrep = "issam@skills-net.info" if id_plateforme==526
replace rg_email2 = "molk@skills-net.info" if id_plateforme==526

replace emailrep = "zaidiwided4@gmail.com" if id_plateforme==642

replace emailrep = "ilyes.bhy@gmail.com" if id_plateforme==670

replace emailrep = "nagara.nourelhouda@gmail.com" if id_plateforme==706

replace emailrep = "community@i3c.com.tn" if id_plateforme==732

replace emailrep = "haithem.garali@tti-elecsa.tn" if id_plateforme==761

replace emailrep = "dhouibnabil@gmail.com" if id_plateforme==791

replace emailrep = "commercial@paf.com.tn" if id_plateforme==820

replace emailrep = "meriam.tarmiz@africhrome.com" if id_plateforme==873

replace rg_email2 = "commercial@graphika.tn" if id_plateforme==136

*@AYOUB: merge your file with websites and social media links of the companies BELOW,call it site_web facebook instagram linkedin etc, 
*then drop rg_siteweb rg_media because no longer needed


*excel for CEPEX
export excel id_plateforme matricule_fiscale firmname matricule_missing ///
 using "${master_pii}/matricule_fiscale_ecommerce_cepex", firstrow(var) sheetreplace

save "${master_pii}/ecommerce_master_contact", replace

***********************************************************************
* 	PART 5: merge to create analysis data set
***********************************************************************
		* change directory to master folder for merge with regis + baseline (final)
cd "$master_raw"

	* merge registration with baseline data

clear 

use "${regis_final}/regis_final", clear
*rename email treatment indicator to avoid replacement
rename treatment treatment_email

merge 1:1 id_plateforme using "${bl_final}/bl_final"
drop commentaires_ElAmouri
keep if _merge==3 /* companies that were eligible and answered on the registration + baseline surveys */
drop _merge

*generate surveyround variable
gen surveyround = 1
lab var surveyround "1-baseline 2-midline 3-endline"

    * save as ecommerce_database

save "${master_raw}/ecommerce_database_raw", replace

merge 1:1 id_plateforme using "${bl2_final}/Webpresence_answers_final"
keep if _merge==3
drop _merge

*drop index and other variables can
drop ihs_exports w_compexp
drop ihs_ca w_compca
drop ihs_digrevenue w_compdrev
drop knowledge digtalvars expprep expoutcomes 

rename car_carempl_dive2 car_carempl_div2
lab var car_carempl_div2 "nombre de jeunes dans l'entreprise"
save "${master_raw}/ecommerce_database_raw", replace

*create contact database with dig_presence for survey institut
preserve
merge 1:1 id_plateforme using "${master_pii}/ecommerce_master_contact"

export excel id_plateforme firmname nom_rep treatment status ///
emailrep rg_email2 rg_emailpdg telrep tel_sup1 tel_sup2 rg_telpdg rg_telephone2 ///
dig_presence1 dig_presence2 dig_presence3 matricule_physique matricule_missing ///
matricule_fiscale using "${master_pii}/midline_contactlist", ///
firstrow(var) sheetreplace

restore


***********************************************************************
* 	PART 7: merge with participation data
***********************************************************************

*merge participation file to have take up data also in analysis file
clear 
use "${master_raw}/ecommerce_database_raw", clear
preserve
	import excel "${master_pii}/suivi_ecommerce.xlsx", sheet("Suivi_formation") firstrow clear
	keep id_plateforme groupe module1 module2 module3 module4 module5 present absent
	drop if id_plateforme== ""
	drop if id_plateforme== "id_plateforme"
	destring id_plateforme,replace
	sort id_plateforme, stable
	save "${master_pii}/suivi_ecommerce.dta",replace
restore

merge 1:1 id_plateforme using "${master_pii}/suivi_ecommerce"
drop _merge


***********************************************************************
* 	PART 6: append to create analysis data set
***********************************************************************

	* append registration +  baseline data with midline

append using "${ml_final}/ml_final"
sort id_plateforme, stable
drop survey_type survey

	* append with endline
/*cd "$endline_final"
append using el_final
*/
    * save as ecommerce_database
*deidentify
/*drop Ufirmname dup_firmname firmname_change tel_sup1 tel_sup2 tel_supl1 tel_supl2 email ///
id_email email Uemail treatment_email dup_id_email dup_emailpdg ident_email_1 ident_email_2 info_compt2
*/
sort id_plateforme, stable
order id_plateforme 
save "${master_raw}/ecommerce_database_raw", replace

/*export excel id_plateforme entr_produit1 ///
 using "${master_pii}/cepex_produits", firstrow(var) sheetreplace
