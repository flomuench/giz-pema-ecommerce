***********************************************************************
* 			baseline e-commerce experiment import					  *
***********************************************************************
*																	   
*	PURPOSE: import the baseline survey data provided by the survey 
*   institute
*																	  
*	OUTLINE:														  
*	1)	import contact list as Excel or CSV														  
*	2)	save the contact list as dta file in intermediate folder
*																	 																      *
*	Author: Teo Firpo  														  

*	ID variable: id_plateforme			  									  
*	Requires: bl_raw.xlsx	
*	Creates: bl_raw.dta							  
*																	  
***********************************************************************
* 	PART 1: import the list of surveyed firms as Excel				  										  *
***********************************************************************
/* --------------------------------------------------------------------
	PART 1.1: Import raw data of online survey
----------------------------------------------------------------------*/		

cd "$bl_raw"
import excel "${bl_raw}/bl_raw.xlsx", sheet("Feuil1") firstrow clear

tostring *, replace

gen survey_type = "online"

rename BP exp_avant21_2
rename BT exp_pays_principal2

rename Jattestequetouteslesinform attest
rename DA attest2

save "temp_bl_raw", replace

/* --------------------------------------------------------------------
	PART 1.2: Import raw data from CATI survey
----------------------------------------------------------------------*/		

import excel "${bl_raw}/bl_raw_cati.xlsx", sheet("Feuil1") firstrow clear

tostring *, replace

drop if Id_plateforme=="."

drop Acceptezvousenregistrement orienter_

gen survey_type = "phone"

rename BR exp_avant21_2
rename BV exp_pays_principal2

rename Jattestequetouteslesinform attest
rename DC attest2

append using temp_bl_raw, force


***********************************************************************
* 	PART 2:  create + save bl_pii file	  			
***********************************************************************
	* put all pii variables into a local
local pii Id_plateforme Nomdelapersonne Nomdelentreprise Merciderenseignerlenomcorr Adresseéléctronique Qsinonident K id_ident2 Commentvousappelezvous id_nouveau_personne id_base_repondent id_repondent_position tel_sup1 tel_sup2 I

	* save as stata master data
preserve
keep `pii'

    * rename Id_plateforme to merge it to pii regis
rename Id_plateforme id_plateforme
		
save "ecommerce_bl_pii", replace
restore

	* export the pii data as new ecommerce_master_data 
export excel `pii' using ecommerce_bl_pii, firstrow(var) replace

***********************************************************************
* 	PART 3:  save a de-identified final analysis file	
***********************************************************************
	* change directory to final folder
cd "$bl_final"

	* drop all pii
drop `pii'

***********************************************************************
* 	PART 4: re-importing raw data 						
***********************************************************************

cd "$bl_raw"
save "bl_raw", replace


