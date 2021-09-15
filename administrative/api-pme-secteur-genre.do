clear all 
cd "C:\Users\fmunch\Google Drive\RCT PME Tunisiennes\4_Donnees_Sondages\Data\administrative\API"
use "API_flo_teo", replace
drop _freq
set scheme plotplain
set graphics on
cd "C:\Users\fmunch\Google Drive\Research_GIZ_Tunisia_exportpromotion\1. Intervention III – Consortia\data\administrative\api\output"
graph hbar (count) , ///
		over(Gender, label(labsize(vsmall))) ///
		over(secteur_nat, label(labsize(vsmall))) ///
		ytitle("nombre des entreprises") ///
		blabel(bar) ///
		title("{bf:Les PME tunisiennes selon secteur et genre}") ///
		subtitle("en 2020") ///
		note("Source: API et calculs des auteurs.  Droits d'auteurs: Florian Münch & Amira Bouziri.", size(vsmall)) ///
		caption("En total, il y a 3214 PME ayant un adresse email dont 415 avec gérante femme et 2799 avec gérant homme.", size(vsmall))
graph export "api-pme-secteur-genre.png", replace
