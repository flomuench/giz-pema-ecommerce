***********************************************************************
* 			sampling email experiment cgenerate								  		  
***********************************************************************
*																	   
*	PURPOSE: 						  								  
*																	  
*																	  
*	OUTLINE:														  
*	1)		generate email experiment id														  
*	2)		create factor variables from categorical string variables
*	3)		create dummy variables for each category of factor variables														  
*																	 																      *
*	Author:  	Florian													  
*	ID variable: 	none			  									  
*	Requires:		giz_contact_list_inter.dta
*	Creates:		giz_contact_list_inter.dta					  
*																	  
***********************************************************************
* 	PART START: define the settings as necessary 				  										  *
***********************************************************************
use "${samp_intermediate}/giz_contact_list_inter", clear



***********************************************************************
* 	PART 1: generate an id			  										  
***********************************************************************
	* randomly order firms
		* seed set in master file number generated on random.org 
sort firmname, stable
gen rand = runiform()
sort rand, stable
	* generate a new id for the email experiment
gen id_email = _n

***********************************************************************
* 	PART 2: create factor variables from categorical string variables				  										  
***********************************************************************
levelsof sector
label define sector_name 1 "Autres industries extractives" ///
	2 "Autres industries manufacturières" ///
	3 "Cokefaction, raffinage, industries nucléaires" ///
	4 "Fabrication d'autres produits non métalliques" ///
	5 "Fabrication d'equipements électriques et électroniques" ///
	6 "Fabrication de machines et équipements" ///
	7 "Fabrication de matériel de transport" ///
	8 "Industrie chimique" ///
	9 "Industrie du caoutchouc et des plastiques" ///
	10 "Industrie du papier et du carton, édition et imprimerie" ///
	11 "Industries agricoles et alimentaires" ///
	12 "Industries du cuir et de la chaussure" ///
	13 "Industries textiles et habillement" ///
	14 "Métallurgie et travail des métaux" ///
	15 "Travail du bois et fabrication d'articles en bois"

	* sector
tempvar Sector
encode sector, gen(`Sector') label(sector_name) noextend
drop sector
rename `Sector' sector


	* gender
label define sex 2 "unknown" 1 "female" 0 "male"
tempvar Gender
encode gender, gen(`Gender') label(sex) noextend
drop gender
rename `Gender' gender

	* governorate
levelsof governorate
label define governorat 1 "Ariana" ///
	2 "Beja" 3 "Ben Arous"  4 "Bizerte" 5 "Gabes" 6 "Gafsa" ///
	7 "Jendouba" 8 "Kairouan" 9 "Kasserine" 10 "Kebili" ///
	11 "Le Kef" 12 "Mahdia" 13 "Manouba" 14 "Medenine" 15 "Monastir" ///
	16 "Nabeul" 17 "Sfax" 18 "Sidi Bouzid" 19 "Siliana" 20 "Sousse" ///
	21 "Tataouine" 22 "Tunis" 23 "Zaghouan"
tempvar Governorate
encode governorate, gen(`Governorate') label(governorat) noextend
drop governorate
rename `Governorate' governorate

	* export status
label def total_export 1 "totalement exportatrice" 0 "non totalement exportatrice"
tempvar Export
encode export, gen(`Export') label(total_export) noextend
drop export
rename `Export' export
***********************************************************************
* 	PART 3: create dummy variables for each category of factor variables				  										  
***********************************************************************
foreach x of varlist gender export sector governorate {
tab `x', gen(`x')
}

***********************************************************************
* 	PART 4: gen firm size variable				  										  
***********************************************************************
gen size = .
replace size = 1 if fte <= 30
replace size = 2 if fte > 30 & fte <= 100
replace size = 3 if fte > 100 & fte <= 240
replace size = 4 if fte > 240 & fte < .

lab def size_categories 1 "small" 2 "medium" 3 "large" 4 "big"
lab values size size_categories

tab size, gen(Size)

***********************************************************************
* 	PART 5: gen firm contact origin dummy				  										  
***********************************************************************
tab origin, gen(Origin)

***********************************************************************
* 	PART END: save the dta file				  						
***********************************************************************
save "giz_contact_list_inter", replace
