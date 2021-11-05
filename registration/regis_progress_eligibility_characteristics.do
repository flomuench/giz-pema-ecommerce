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
putdocx begin 
putdocx paragraph
putdocx text ("E-commerce training: registration progress, elibility, firm characteristics"), bold 


***********************************************************************
* 	PART 2:  Registration progress		  			
***********************************************************************

	* total number of firms registered
graph bar (count) id_plateforme, blabel(total) ///
	title("Number of registered firms") note("Date: `c(current_date)'") ///
graph export responserate.png, replace
putpdf paragraph, halign(center)
putpdf image responserate.png
putpdf pagebreak

	* total number of firms registered
graph bar (count) id_plateforme, blabel(total) ///
	title("Number of registered firms") note("Date: `c(current_date)'") ///
graph export responserate.png, replace
putpdf paragraph, halign(center)
putpdf image responserate.png
putpdf pagebreak


	* nombre d'enregistremnet par jour 

***********************************************************************
* 	PART 3:  Eligibility		  			
***********************************************************************

	* identifiant unique correct (oui ou non)
graph bar (count), over(identifiant_correct) blabel(total) ///
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
putpdf paragraph, halign(center) 
putpdf image export.png
putpdf pagebreak
	
	* éligible vs. not éligible
gen eligible = (identifiant_correct == 1 & rg_resident == 1 & rg_fte > 6 & rg_fte <= 199 & rg_produitexp == 1 & rg_intention == 1 & rg_oper_exp == 1)

graph bar (count), over(eligible) blabel(total) ///
	title("Entreprises eligibles") ///
	ytitle("nombre d'enregistrement")
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
graph bar rg_fte rg_fte_femmes
	
	* 
	
	