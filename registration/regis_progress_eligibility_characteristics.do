***********************************************************************
* 			registration progress, eligibility, firm characteristics
***********************************************************************
*																	   
*	PURPOSE: 		check whether string answer to open questions are 														 
*					logical
*	OUTLINE:														  
*	1)				progress		  		  			
*	2)  			eligibility					 
*	3)  			characteristics							  
*																	  
*	ID variaregise: 	id (example: f101)			  					  
*	Requires: regis_inter.dta & regis_checks_survey_progress.do 	  
*	Creates:  regis_inter.dta			  
*																	  
***********************************************************************
* 	PART 1:  set environment + create pdf file for export		  			
***********************************************************************
	* import file
use "${regis_intermediate}/regis_inter", clear

	* set directory to checks folder
cd "$regis_progress"

	* create word document
putpdf begin 
putpdf paragraph
putpdf text ("E-commerce training: registration progress, elibility, firm characteristics"), bold 


***********************************************************************
* 	PART 2:  Registration progress		  			
***********************************************************************

	* total number of firms registered
graph bar (count) id_plateforme, blabel(total) ///
	title("Number of registered firms") note("Date: `c(current_date)'") ///
	ytitle("nombre d'enregistrement")
graph export responserate.png, replace
putpdf paragraph, halign(center)
putpdf image responserate.png
putpdf pagebreak


	* nombre d'enregistremnet par jour 
	
	
	* communication channels
graph bar (count), over(moyen_com, sort(1) lab(labsize(tiny))) blabel(total) ///
	title("Enregistrement selon les moyens de communication") ///
	ytitle("nombre d'enregistrement") 
graph export moyen_com.png, replace
putpdf paragraph, halign(center) 
putpdf image moyen_com.png
putpdf pagebreak

	* taille des entreprises selon chaines de com
graph box rg_fte, over(moyen_com, sort(1) lab(labsize(tiny))) blabel(total) ///
	title("Nombre des employés des entreprises selon moyen de communication") ///
	ytitle("Nombre des employés")


***********************************************************************
* 	PART 3:  Eligibility		  			
***********************************************************************

	* identifiant unique correct (oui ou non)
graph bar (count), over(id_admin_correct) blabel(total) ///
	title("Identifiant unique/matricule fiscal format correct") ///
	ytitle("nombre d'enregistrement")
graph export identifiant_correct.png, replace
putpdf paragraph, halign(center) 
putpdf image identifiant_correct.png
putpdf pagebreak
	
	* onshore vs. offshore
graph bar (count), over(rg_resident) blabel(total) ///
	title("Entreprises résidantes vs. non-résidantes") ///
	ytitle("nombre d'enregistrement")
graph export resident.png, replace
putpdf paragraph, halign(center) 
putpdf image resident.png
putpdf pagebreak
	
	* nombre des employés
histogram rg_fte, frequency addl ///
	title("Nombre des employés") ///
	subtitle("Toutes les entreprises enregistrées") ///
	xlabel(0(20)600,  labsize(tiny) format(%20.0fc)) ///
	bin(30) ///
	xline(6) xline(200) ///
	note("Les deux lignes réprésentent le min. et max. selon les critères d'éligibilité.", size(vsmall)) ///
	name(fte_full)
	
histogram rg_fte if rg_fte <= 200, frequency addl ///
	title("Nombre des employés") ///
	subtitle("Entreprises ayantes <= 200 employés") ///
	xlabel(0(5)200,  labsize(tiny) format(%20.0fc)) ///
	bin(30) ///
	xline(6) xline(200) ///
	note("Les deux lignes réprésentent le min. et max. selon les critères d'éligibilité.", size(vsmall)) ///
	name(fte_200)
	
gr combine fte_full fte_200
graph export fte.png, replace
putpdf paragraph, halign(center) 
putpdf image fte.png
putpdf pagebreak
	
	* export 
		* produit exportable = rg_produitexp
		* intention d'exporter = rg_intention
		* opération d'export = rg_oper_exp
local exportquestions "rg_produitexp rg_intention rg_oper_exp rg_expstatus"
foreach x of local exportquestions {
quietly graph bar (count), over(`x') blabel(total) ///
	ytitle("nombre d'enregistrement") name(`x', replace)
}
gr combine `exportquestions', ///
	title("{bf:Questions export}") ///
	subtitle("{it: Produit exportable (haute gauche), Intention d'exporter (haute droite), Operation d'export (bas gauche) et Régime export (bas droite)}", size(vsmall))
gr export export.png, replace
putpdf paragraph, halign(center) 
putpdf image export.png
putpdf pagebreak

	* age
stripplot rg_age, jitter(4) vertical yline(2, lcolor(red)) ///
	ytitle("Age de l'entreprise") ///
	name(age_strip)
histogram rg_age if rg_age >= 0, frequency addl ///
	ytitle("Age de l'entreprise") ///
	xlabel(0(2)80,  labsize(tiny) format(%20.0fc)) ///
	bin(40) ///
	xline(2, lcolor(red)) ///
	color(%30) ///
	name(age_hist)	
gr combine age_strip age_hist, title("Age des entreprises") ///
	note("La ligne rouge répresente la valeur minimale pour être éligible.", size(vsmall))
graph export age.png, replace
putpdf paragraph, halign(center) 
putpdf image age.png
putpdf pagebreak

	* online presence
graph bar (count), over(presence_enligne) blabel(total) ///
	title("Présence enligne") ///
	ytitle("nombre d'enregistrement")
graph export presence_enligne.png, replace
putpdf paragraph, halign(center) 
putpdf image presence_enligne.png
putpdf pagebreak
	
	* eligibility
graph bar (count), over(eligible) blabel(total) ///
	title("Entreprises eligibles") ///
	ytitle("nombre d'enregistrement") ///
	note(`"Chaque entreprise est éligible qui a fourni un matricul fiscal correct, a >= 6 & < 200 employés, une produit exportable, "' `"l'intention d'exporter, >= 1 opération d'export, existe pour >= 2 ans et est résidente tunisienne."', size(vsmall) color(red))
graph export eligibles.png, replace
putpdf paragraph, halign(center) 
putpdf image eligibles.png
putpdf pagebreak


***********************************************************************
* 	PART 4:  Characteristics
***********************************************************************


	* position du répresentant --> hbar
	
	* répresentation en ligne: ont un site web ou pas; ont un profil media ou pas
		* bar chart avec qutre bars et une légende; over(rg_siteweb) over(rg_media)
		
	* statut legal
	
	* nombre employés féminins rélatif à employés masculins
*graph bar rg_fte rg_fte_femmes
	
	* 
	
***********************************************************************
* 	PART 5:  save pdf
***********************************************************************
	* change directory to progress folder
cd "$regis_progress"
	* pdf
putpdf save "progress-eligibility-characteristics", replace
