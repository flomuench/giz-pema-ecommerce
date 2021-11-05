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
	
	* onshore vs. offshore
	
	* nombre des employés
	
	* produit exportable
	
	* intention d'exporter
	
	* opération d'export
	
	* éligible vs. not éligible
	


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
	
	