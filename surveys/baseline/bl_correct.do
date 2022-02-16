***********************************************************************
* 			e-commerce baseline survey corrections                    *	
***********************************************************************
*																	    
*	PURPOSE: correct all incoherent responses				  							  
*																	  
*																	  
*	OUTLINE:														  
*	1)		Define non-response categories 		
*   2)		Manually fix wrong answers 	  				  
* 	3) 		Use regular expressions to correct variables
*	4)   	Replace string with numeric values						  
*	5)  	Convert string to numerical variaregises	  				  
*	6)  	Convert problematic values for open-ended questions		  
*	7)  	Traduction reponses en arabe au francais				  
*   8)      Rename and homogenize the observed values                   
*	9)		Import categorisation for opend ended QI questions
*	10)		Remove duplicates
*
*																	  															      
*	Author:  	Teo Firpo & Kais Jomaa							  
*	ID variaregise: 	id (example: f101)			  					  
*	Requires: bl_inter.dta 	  								  
*	Creates:  bl_inter.dta			                          
*																	  
***********************************************************************
* 	PART 1:  Define non-response categories  			
***********************************************************************
use "${bl_intermediate}/bl_inter", clear

{
	* replace "-" with missing value
ds, has(type string) 
local strvars "`r(varlist)'"
foreach x of local strvars {
		replace `x' = "" if `x' == "-"
	}
	
scalar not_know    = -999
scalar refused     = -888
scalar check_again = -777

local not_know    = -999
local refused     = -888
local check_again = -777

	* replace, gen, label
gen needs_check = 0
gen questions_needing_checks = ""
gen commentsmsb = ""
*/
}

***********************************************************************
* 	PART 2:  Manually fix wrong answers
***********************************************************************

{
* Needs check
//replace needs_check = 1 if id_plateforme = 572== "a"
//replace needs_check = 1 if id_plateforme = 572 == "aa"

*replace needs_check = 1 if comp_benefice2020 == "§§"
*replace needs_check = 1 if comp_benefice2020 == "na"
*replace needs_check = 1 if exp_pays_21 ==200
*replace needs_check = 1 if compexp_2020== "248000dt 2018 et 124000dt 2019"
*replace needs_check = 1 if dig_revenues_ecom== "non établi. ds les 30% environ"


//replace needs_check = 1 if comp_benefice2020 == "§§"
//replace needs_check = 1 if comp_benefice2020 == "na"
//replace needs_check = 1 if exp_pays_21 ==200


* Questions needing check
* replace questions_needing_check = "investcom_2021/investcom_futur" if id_plateforme==572
*replace questions_needing_check = "exp_pays_21" if id_plateforme==757
*replace questions_needing_check = "comp_benefice2020" if id_plateforme==592
*replace needs_check = 1 if id_plateforme == 592
*replace questions_needing_check = "compexp_2020/comp_ca2020/comp_benefice2020" if id_plateforme==365
*replace questions_needing_check = "dig_revenues_ecom" if id_plateforme==375


*Corrections that were undertaken but where comments remained in fiche de correction are starred out here*

*replace questions_needing_check = "comp_benefice2020" if id_plateforme == 89
*replace needs_check = 1 if id_plateforme == 89


/* CORRECTIONS TO BE MADE
for id_plateforme == 108, compexp_2020 ==0, comp_ca2020 == 6500 , dig_revenues_ecom== 0, comp_benefice2020== 1000, exp_afrique_principal == "Sénegal",
for id_plateforme == 126 investcom_2021== 1000
for id_plateforme ==136, exp_afrique_principal =="Cameroun"
for id_plateforme == 254, comp_benefice2020= 150000
for id_plateforme == 261, compexp_2020 = 2557611, comp_ca2020== 2649558, comp_benefice2020==421336
for id_plateforme == 405, comp_benefice2020= 1200000
for id_plateformeforme == 493, compexp_2020= 0
for id_plateforme== 542 compexp_2020=800000, comp_ca2020==10000000, dig_revenues_ecom== 20000 comp_benefice2020== 500000
for id_plateforme == 592,  exp_afrique_principal ==" Cameroun"
for id_plateforme ==623 , id_base_respondent= "Rana Baabaa"
for id_plateforme ==632 , compexp_2020=0, comp_ca2020 ==120000, comp_benefice2020==600
for id_plateforme ==800, investcom_2021 ==1000
fpr id_plateforme== 841, comp_benefice2020== 45000
for id_plateforme == 931, comp_benefice2020 = 3000
*/


replace questions_needing_check = "expprep_norme2/exp_afrique_principal" if id_plateforme == 108
replace needs_check = 1 if id_plateforme == 108
replace questions_needing_check = "exp_afrique_principal" if id_plateforme == 136
replace needs_check = 1 if id_plateforme == 136
*replace questions_needing_check = "comp_benefice2020" if id_plateforme == 148
*replace needs_check = 1 if id_plateforme == 148
*replace questions_needing_check = "exp_afrique_principal" if id_plateforme == 151
*replace needs_check = 1 if id_plateforme == 151
replace questions_needing_check = "comp_benefice2020" if id_plateforme == 254
replace needs_check = 1 if id_plateforme == 254
replace questions_needing_check = "dig_revenues_ecom/comp_benefice2020" if id_plateforme == 365
replace needs_check = 1 if id_plateforme == 365
*replace questions_needing_check = "comp_benefice2020" if id_plateforme == 377
*replace needs_check = 1 if id_plateforme == 377
replace questions_needing_check = "investcom_2021/investcom_futur" if id_plateforme == 387
replace needs_check = 1 if id_plateforme == 387
*replace questions_needing_check = "comp_benefice2020/dig_revenues_ecom" if id_plateforme == 392
*replace needs_check = 1 if id_plateforme == 392
replace questions_needing_check = "investcom_2021" if id_plateforme == 427
replace needs_check = 1 if id_plateforme == 427
replace questions_needing_check = "exp_pays_21" if id_plateforme == 443
replace needs_check = 1 if id_plateforme == 443
*replace questions_needing_check = "comp_benefice2020" if id_plateforme == 457
*replace needs_check = 1 if id_plateforme == 457
replace questions_needing_check = "duplicate" if id_plateforme==526
replace needs_check = 1 if id_plateforme == 526
replace questions_needing_check = "duplicate" if id_plateforme==545
replace needs_check = 1 if id_plateforme == 545
replace questions_needing_check = "investcom_2021/investcom_futur" if id_plateforme==572
replace needs_check = 1 if id_plateforme == 572
replace questions_needing_check = "exp_afrique_principal" if id_plateforme==592
replace needs_check = 1 if id_plateforme == 592
replace questions_needing_check = "id_base_respondent" if id_plateforme == 623
replace needs_check = 1 if id_plateforme == 623
replace questions_needing_check = "exp_pays_21" if id_plateforme == 628
replace needs_check = 1 if id_plateforme == 628
*replace questions_needing_check = "exp_afrique_principal" if id_plateforme == 668
*replace needs_check = 1 if id_plateforme == 668
replace questions_needing_check = "tel_sup2" if id_plateforme == 695
replace needs_check = 1 if id_plateforme == 695
replace questions_needing_check = "comp_benefice2020" if id_plateforme == 698
replace needs_check = 1 if id_plateforme == 698
replace questions_needing_check = "exp_afrique_principal" if id_plateforme == 761
replace needs_check = 1 if id_plateforme == 761
replace questions_needing_check = "comp_benefice2020" if id_plateforme == 841
replace needs_check = 1 if id_plateforme == 841
*/


*Identify unrealistic outliers and flag them as needs_check*
replace needs_check = 1 if id_plateforme==767
replace questions_needing_checks = questions_needing_checks +  " | benefice trop elevé pour une entreprise avec 8 employées" if id_plateforme==767


replace compexp_2020 = "0" if id_plateforme==59
replace comp_ca2020 = "0" if id_plateforme==59
replace comp_benefice2020 = "0" if id_plateforme==59
replace dig_revenues_ecom = "0" if id_plateforme==59
replace needs_check = 0 if id_plateforme==59 // L'entreprise avait arrêté son activité en 2020'entreprise avait arrêté son activité en 2020*


replace compexp_2020 = "3346308" if id_plateforme==	70
replace comp_ca2020 = "7267643" if id_plateforme==70
replace investcom_2021 = "8000" if id_plateforme==70
replace needs_check = 0 if id_plateforme==70

replace compexp_2020 = "4266882" if id_plateforme==	78
replace comp_ca2020 = "5006036" if id_plateforme==78
replace dig_revenues_ecom = "93381" if id_plateforme==78
replace comp_benefice2020 = "74652" if id_plateforme==78
replace investcom_2021 = "8700" if id_plateforme==78
replace needs_check = 0 if id_plateforme==78

replace exp_pays_avant21 = 0 if id_plateforme==	80
replace needs_check = 0 if id_plateforme==80

replace compexp_2020 = "73461" if id_plateforme== 85
replace comp_ca2020 = "85361" if id_plateforme==85
replace comp_benefice2020 = "22125" if id_plateforme==85
replace dig_revenues_ecom = "73461" if id_plateforme==85
replace investcom_2021 = "88000" if id_plateforme==85
replace needs_check = 0 if id_plateforme==85

replace compexp_2020 = "3300000" if id_plateforme==	82
replace comp_ca2020 = "6143000" if id_plateforme==82
replace comp_benefice2020 = "0" if id_plateforme==82
replace dig_revenues_ecom = "0" if id_plateforme==82
replace investcom_2021 = "0" if id_plateforme==82
replace needs_check = 0 if id_plateforme==82

replace compexp_2020 = "80000" if id_plateforme==	89
replace comp_ca2020 = "137000" if id_plateforme==89
replace comp_benefice2020 = "10000" if id_plateforme==89
replace needs_check = 0 if id_plateforme==89

replace compexp_2020 = "8000000" if id_plateforme==91
replace comp_ca2020 = "8000000" if id_plateforme==91
replace investcom_2021 = "0" if id_plateforme==91
replace needs_check = 0 if id_plateforme==91

replace compexp_2020 = "544225" if id_plateforme==95
replace comp_ca2020 = "3049447" if id_plateforme==95
replace comp_benefice2020 = "0" if id_plateforme==95
replace needs_check = 0 if id_plateforme==95

replace compexp_2020 = "215000" if id_plateforme==148
replace comp_ca2020 = "3200000" if id_plateforme==148
replace dig_revenues_ecom = "0" if id_plateforme==148
replace comp_benefice2020 = "-64955" if id_plateforme==148
replace needs_check = 0 if id_plateforme==148

replace exp_pays_avant21 = 0 if id_plateforme==122
replace needs_check = 0 if id_plateforme==122

replace exp_pays_avant21 = -999 if exp_pays_avant21==330


replace exp_pays_avant21 = 0 if id_plateforme==126
replace needs_check = 0 if id_plateforme==126

replace exp_afrique_principal = "cameroun" if id_plateforme==136
replace needs_check = 0 if id_plateforme==136

replace exp_pays_avant21 = 0 if id_plateforme==144
replace needs_check = 0 if id_plateforme==144

replace compexp_2020 = "30000" if id_plateforme==146
replace comp_ca2020 = "30000" if id_plateforme==146
replace investcom_2021 = "0" if id_plateforme==146
replace needs_check = 0 if id_plateforme==146

replace exp_afrique = 0 if id_plateforme==151
replace needs_check = 0 if id_plateforme==151

replace compexp_2020 = "1500" if id_plateforme==165
replace comp_ca2020 = "1500" if id_plateforme==165
replace investcom_2021 = "500" if id_plateforme==165
replace needs_check = 0 if id_plateforme==165

replace exp_pays_avant21 = 0 if id_plateforme==166
replace needs_check = 0 if id_plateforme==166

replace comp_benefice2020 = "-8120" if id_plateforme==172
replace dig_revenues_ecom = "8500" if id_plateforme==172
replace needs_check = 0 if id_plateforme==172

replace compexp_2020 = "120000" if id_plateforme==183
replace comp_ca2020 = "600000" if id_plateforme==183
replace comp_benefice2020 = "0" if id_plateforme==183
replace dig_revenues_ecom = "0" if id_plateforme==183
replace investcom_2021 = "0" if id_plateforme==183
replace needs_check = 0 if id_plateforme==183

replace compexp_2020 = "2393000" if id_plateforme==201
replace comp_ca2020 = "2393000" if id_plateforme==201
replace comp_benefice2020 = "263000" if id_plateforme==201
replace dig_revenues_ecom = "0" if id_plateforme==201
replace needs_check = 0 if id_plateforme==201

replace compexp_2020 = "142500" if id_plateforme==204
replace comp_ca2020 = "1222221" if id_plateforme==204
replace needs_check = 0 if id_plateforme==204

replace compexp_2020 = "0" if id_plateforme==209
replace comp_ca2020 = "750000" if id_plateforme==209
replace investcom_2021 = "0" if id_plateforme==209
replace comp_benefice2020 = "500000" if id_plateforme==209
replace needs_check = 0 if id_plateforme==209

replace compexp_2020 = "426552" if id_plateforme==212
replace comp_ca2020 = "426552" if id_plateforme==212
replace investcom_2021 = "0" if id_plateforme==212
replace dig_revenues_ecom = "5000" if id_plateforme==212
replace comp_benefice2020 = "38350" if id_plateforme==212
replace needs_check = 0 if id_plateforme==212

replace exp_pays_avant21 = 0 if id_plateforme==213
replace needs_check = 0 if id_plateforme==213

replace exp_pays_avant21 = 0 if id_plateforme==231
replace needs_check = 0 if id_plateforme==231

replace comp_ca2020 = "14000000" if id_plateforme==237
replace comp_benefice2020 = "1680000" if id_plateforme==237
replace needs_check = 0 if id_plateforme==237

replace compexp_2020 = "3240000" if id_plateforme==240
replace comp_ca2020 = "28400000" if id_plateforme==240
replace investcom_2021 = "10000" if id_plateforme==240
replace needs_check = 0 if id_plateforme==240

replace compexp_2020 = "100000" if id_plateforme==244
replace comp_ca2020 = "2000000" if id_plateforme==244
replace comp_benefice2020 = "380000" if id_plateforme==244
replace needs_check = 0 if id_plateforme==244

replace investcom_2021 = "-888" if id_plateforme==248
replace needs_check = 0 if id_plateforme==248

replace exp_pays_avant21 = 0 if id_plateforme==253
replace needs_check = 0 if id_plateforme==253

replace compexp_2020 = "300000" if id_plateforme==254
replace comp_ca2020 = "1500000" if id_plateforme==254
replace comp_benefice2020 = "150000" if id_plateforme==254
replace dig_revenues_ecom = "80000" if id_plateforme==254
replace needs_check = 0 if id_plateforme==254

replace compexp_2020 = "2653685" if id_plateforme==255
replace comp_ca2020 = "2967655" if id_plateforme==255
replace comp_benefice2020 = "161659" if id_plateforme==255
replace dig_revenues_ecom = "0" if id_plateforme==255
replace needs_check = 0 if id_plateforme==255

replace exp_pays_avant21 = 0 if id_plateforme==259
replace needs_check = 0 if id_plateforme==259

replace compexp_2020 = "2557611" if id_plateforme==261
replace comp_ca2020 = "2649558" if id_plateforme==261
replace needs_check = 0 if id_plateforme==261

replace compexp_2020 = "400000" if id_plateforme==264
replace comp_ca2020 = "400000" if id_plateforme==264
replace needs_check = 0 if id_plateforme==264

replace compexp_2020 = "223000" if id_plateforme==265
replace comp_ca2020 = "1138000" if id_plateforme==265
replace needs_check = 0 if id_plateforme==265

replace compexp_2020 = "395220" if id_plateforme==270
replace comp_ca2020 = "749476" if id_plateforme==270
replace comp_benefice2020 = "574709" if id_plateforme==270
replace needs_check = 0 if id_plateforme==270

replace exp_pays_avant21 = 0 if id_plateforme==271
replace needs_check = 0 if id_plateforme==271

replace compexp_2020 = "6900" if id_plateforme==275
replace comp_ca2020 = "22500" if id_plateforme==275
replace comp_benefice2020 = "5485" if id_plateforme==275
replace dig_revenues_ecom = "0" if id_plateforme==275
replace needs_check = 0 if id_plateforme==275

replace exp_pays_avant21 = 0 if id_plateforme==290
replace needs_check = 0 if id_plateforme==290

replace compexp_2020 = "58000" if id_plateforme==303
replace comp_ca2020 = "222800" if id_plateforme==303
replace comp_benefice2020 = "67000" if id_plateforme==303
replace needs_check = 0 if id_plateforme==303


replace compexp_2020 = "343450" if id_plateforme==311
replace comp_ca2020 = "6794825" if id_plateforme==311
replace comp_benefice2020 = "1880223" if id_plateforme==311
replace dig_revenues_ecom = "0" if id_plateforme==311
replace needs_check = 0 if id_plateforme==311

replace compexp_2020 = "305000" if id_plateforme==323
replace comp_ca2020 = "7752000" if id_plateforme==323
replace comp_benefice2020 = "304000" if id_plateforme==323
replace needs_check = 0 if id_plateforme==323


replace exp_pays_21 = "0" if id_plateforme==332

replace compexp_2020 = "2300000" if id_plateforme==324
replace comp_ca2020 = "12300000" if id_plateforme==324
replace comp_benefice2020 = "-723000" if id_plateforme==324
replace dig_revenues_ecom = "0" if id_plateforme==324
replace needs_check = 0 if id_plateforme==324


replace needs_check = 0 if id_plateforme==332

replace compexp_2020 = "0" if id_plateforme==337
replace comp_ca2020 = "5130000" if id_plateforme==337
replace dig_revenues_ecom = "0" if id_plateforme==337
replace comp_benefice2020 = "44124" if id_plateforme==337
replace needs_check = 0 if id_plateforme==337

replace exp_pays_21 = "0" if id_plateforme==345
replace needs_check = 0 if id_plateforme==345

replace compexp_2020 = "347000" if id_plateforme==346
replace comp_ca2020 = "3440000" if id_plateforme==346
replace dig_revenues_ecom = "0" if id_plateforme==346
replace comp_benefice2020 = "97500" if id_plateforme==346
replace investcom_futur = "-999" if id_plateforme==346
replace needs_check = 0 if id_plateforme==346

replace compexp_2020 = "425339" if id_plateforme==352
replace comp_ca2020 = "3260763" if id_plateforme==352
replace comp_benefice2020 = "333963" if id_plateforme==352
replace needs_check = 0 if id_plateforme==352

replace compexp_2020 = "1585000" if id_plateforme==354
replace comp_ca2020 = "1585000" if id_plateforme==354
replace comp_benefice2020 = "250000" if id_plateforme==354
replace needs_check = 0 if id_plateforme==354

replace compexp_2020 = "0" if id_plateforme==365
replace comp_ca2020 = "0" if id_plateforme==365
replace comp_benefice2020 = "0" if id_plateforme==365
replace dig_revenues_ecom = "0" if id_plateforme==365
replace needs_check = 0 if id_plateforme==365 ///L'entreprise n'a pas eu d'activité en 2020 a cause de la pandémie (0)

replace compexp_2020 = "1332626" if id_plateforme==369
replace comp_ca2020 = "1332626" if id_plateforme==369
replace comp_benefice2020 = "150000" if id_plateforme==369
replace needs_check = 0 if id_plateforme==369

replace compexp_2020 = "7900000" if id_plateforme==377
replace comp_ca2020 = "7900000" if id_plateforme==377
replace comp_benefice2020 = "191000" if id_plateforme==377
replace needs_check = 0 if id_plateforme==377

replace compexp_2020 = "0" if id_plateforme==381
replace comp_ca2020 = "9300" if id_plateforme==381
replace needs_check = 0 if id_plateforme==381

replace comp_benefice2020 = "`refused'" if id_plateforme==386
replace investcom_futur = "-999" if id_plateforme==386
replace dig_revenues_ecom = "`refused'" if id_plateforme==386
replace exp_pays_avant21 = 0 if id_plateforme==386
replace needs_check = 0 if id_plateforme==386

replace comp_benefice2020 = "86140" if id_plateforme==387
replace compexp_2020 = "2823992" if id_plateforme==387
replace comp_ca2020 = "7087224" if id_plateforme==387
replace needs_check = 0 if id_plateforme==387

replace exp_pays_avant21 = 0 if id_plateforme==398
replace needs_check = 0 if id_plateforme==398

replace compexp_2020 = "120000" if id_plateforme==360
replace comp_ca2020 = "120000" if id_plateforme==360
replace comp_benefice2020 = "35000" if id_plateforme==360
replace needs_check = 0 if id_plateforme==360

replace compexp_2020 = "245875" if id_plateforme==366
replace comp_ca2020 = "1211944" if id_plateforme==366
replace comp_benefice2020 = "83457" if id_plateforme==366
replace dig_revenues_ecom = "11352" if id_plateforme==366
replace needs_check = 0 if id_plateforme==366

replace compexp_2020 = "1888000" if id_plateforme==373
replace comp_ca2020 = "1888000" if id_plateforme==373
replace comp_benefice2020 = "300000" if id_plateforme==373
replace needs_check = 0 if id_plateforme==373

replace compexp_2020 = "22814" if id_plateforme==375
replace comp_ca2020 = "74161" if id_plateforme==375
replace comp_benefice2020 = "8337" if id_plateforme==375
replace needs_check = 0 if id_plateforme==375

replace compexp_2020 = "23361" if id_plateforme==392
replace comp_ca2020 = "166656" if id_plateforme==392
replace comp_benefice2020 = "143295" if id_plateforme==392
replace dig_revenues_ecom = "0" if id_plateforme==392
replace investcom_2021 = "310" if id_plateforme==392
replace needs_check = 0 if id_plateforme==392

replace compexp_2020 = "416538" if id_plateforme==394
replace comp_ca2020 = "416538" if id_plateforme==394
replace needs_check = 0 if id_plateforme==394

replace exp_pays_avant21 = 0 if id_plateforme==405
replace needs_check = 0 if id_plateforme==405

replace exp_pays_avant21 = 0 if id_plateforme==406
replace needs_check = 0 if id_plateforme==406

replace exp_pays_avant21 = 0 if id_plateforme==409
replace needs_check = 0 if id_plateforme==409

replace exp_pays_21 = "0" if id_plateforme==416
replace needs_check = 0 if id_plateforme==416

replace exp_pays_avant21 = 0 if id_plateforme==438
replace needs_check = 0 if id_plateforme==438

replace compexp_2020 = "60000" if id_plateforme==424
replace comp_ca2020 = "60000" if id_plateforme==424
replace needs_check = 0 if id_plateforme==424

replace compexp_2020 = "1500000" if id_plateforme==440
replace comp_ca2020 = "5280000" if id_plateforme==440
replace comp_benefice2020 = "-999" if id_plateforme==440
replace dig_revenues_ecom = "0" if id_plateforme==440
replace needs_check = 0 if id_plateforme==440

replace exp_pays_avant21 = not_know if id_plateforme==443
replace needs_check = 0 if id_plateforme==443

replace compexp_2020 = "700000" if id_plateforme==451
replace comp_ca2020 = "34000000" if id_plateforme==451
replace comp_benefice2020 = "`refused'" if id_plateforme==451
replace needs_check = 0 if id_plateforme==451

replace exp_pays_avant21 = 0 if id_plateforme==453
replace needs_check = 0 if id_plateforme==453

replace compexp_2020 = "3218000" if id_plateforme==457
replace comp_ca2020 = "15200000" if id_plateforme==457
replace comp_benefice2020 = "1000000" if id_plateforme==457
replace dig_revenues_ecom = "0" if id_plateforme==457
replace needs_check = 0 if id_plateforme==457

replace compexp_2020 = "-888" if id_plateforme==477
replace comp_ca2020 = "-888" if id_plateforme==477
replace needs_check = 0 if id_plateforme==477

replace compexp_2020 = "300000" if id_plateforme==488
replace comp_ca2020 = "4754005" if id_plateforme==488
replace dig_revenues_ecom = "0" if id_plateforme==488
replace needs_check = 0 if id_plateforme==488

replace compexp_2020 = "18419000" if id_plateforme==489
replace comp_ca2020 = "135429000" if id_plateforme==489
replace dig_revenues_ecom = "0" if id_plateforme==489
replace comp_benefice2020 = "`not_know'" if id_plateforme==489
replace needs_check = 0 if id_plateforme==489


replace exp_pays_21 = "0" if id_plateforme==505
replace investcom_2021 = "-999" if id_plateforme==505

replace compexp_2020 = "0" if id_plateforme==493
replace comp_ca2020 = "4800000" if id_plateforme==493
replace needs_check = 0 if id_plateforme==493


replace needs_check = 0 if id_plateforme==505

replace compexp_2020 = "40000" if id_plateforme==526
replace comp_ca2020 = "140000" if id_plateforme==526
replace comp_benefice2020 = "`refused'" if id_plateforme==526
replace dig_revenues_ecom = "35000" if id_plateforme==526
replace needs_check = 0 if id_plateforme==526

replace exp_pays_21 = "0" if id_plateforme==541
replace needs_check = 0 if id_plateforme==541

replace compexp_2020 = "1000" if id_plateforme==542
replace comp_ca2020 = "15000" if id_plateforme==542
replace needs_check = 0 if id_plateforme==542

replace compexp_2020 = "9340364" if id_plateforme==545
replace comp_ca2020 = "9340964" if id_plateforme==545
replace dig_revenues_ecom = "0" if id_plateforme==545
replace comp_benefice2020 = "0" if id_plateforme==545
replace exp_pays_principal_avant21="France" if id_plateforme==545
replace needs_check = 0 if id_plateforme==545

replace compexp_2020 = "1500000" if id_plateforme==549
replace comp_ca2020 = "1500000" if id_plateforme==549
replace needs_check = 0 if id_plateforme==549

replace compexp_2020 = "794596" if id_plateforme==572
replace comp_ca2020 = "993245" if id_plateforme==572
replace needs_check = 0 if id_plateforme==572

replace compexp_2020 = "0" if id_plateforme==568
replace comp_ca2020 = "503193" if id_plateforme==568
replace dig_revenues_ecom = "75961" if id_plateforme==568
replace comp_benefice2020 = "-999" if id_plateforme==568
replace needs_check = 0 if id_plateforme==568

replace compexp_2020 = "20000" if id_plateforme==576
replace comp_ca2020 = "600000" if id_plateforme==576
replace dig_revenues_ecom = "0" if id_plateforme==576
replace comp_benefice2020 = "120000" if id_plateforme==576
replace needs_check = 0 if id_plateforme==576

replace compexp_2020 = "750000" if id_plateforme==581
replace comp_ca2020 = "750000" if id_plateforme==581
replace dig_revenues_ecom = "0" if id_plateforme==581
replace comp_benefice2020 = "75000" if id_plateforme==581
replace needs_check = 0 if id_plateforme==581

replace compexp_2020 = "500000" if id_plateforme==587
replace comp_ca2020 = "600000" if id_plateforme==587
replace dig_revenues_ecom = "6000" if id_plateforme==587
replace comp_benefice2020 = "24000" if id_plateforme==587
replace needs_check = 0 if id_plateforme==587

replace exp_afrique_principal="Burkina Faso" if id_plateforme==592
replace needs_check = 0 if id_plateforme==592

replace compexp_2020 = "3800000" if id_plateforme==595
replace comp_ca2020 = "3800000" if id_plateforme==595
replace dig_revenues_ecom = "0" if id_plateforme==595
replace comp_benefice2020 = "0" if id_plateforme==595
replace needs_check = 0 if id_plateforme==595

replace compexp_2020 = "4800000" if id_plateforme==597
replace comp_ca2020 = "4800000" if id_plateforme==597
replace dig_revenues_ecom = "0" if id_plateforme==597
replace comp_benefice2020 = "87000" if id_plateforme==597
replace needs_check = 0 if id_plateforme==597

replace compexp_2020 = "4800000" if id_plateforme==598
replace comp_ca2020 = "4800000" if id_plateforme==598
replace dig_revenues_ecom = "0" if id_plateforme==598
replace comp_benefice2020 = "231638" if id_plateforme==598
replace needs_check = 0 if id_plateforme==598

replace compexp_2020 = "150000" if id_plateforme==600
replace comp_ca2020 = "1800000" if id_plateforme==600
replace dig_revenues_ecom = "8000" if id_plateforme==600
replace comp_benefice2020 = "-180000" if id_plateforme==600
replace needs_check = 0 if id_plateforme==600

replace compexp_2020 = "1800000" if id_plateforme==604
replace comp_ca2020 = "4500000" if id_plateforme==604
replace dig_revenues_ecom = "0" if id_plateforme==604
replace comp_benefice2020 = "-500000" if id_plateforme==604
replace needs_check = 0 if id_plateforme==604

replace compexp_2020 = "0" if id_plateforme==617
replace comp_ca2020 = "250000" if id_plateforme==617
replace needs_check = 0 if id_plateforme==617

replace compexp_2020 = "0" if id_plateforme==620
replace comp_ca2020 = "400000" if id_plateforme==620
replace dig_revenues_ecom = "100000" if id_plateforme==620
replace comp_benefice2020 = "200000" if id_plateforme==620
replace needs_check = 0 if id_plateforme==620

replace id_base_respondent = "Rana BaaBaa " if id_plateforme==623
replace needs_check = 0 if id_plateforme==623

replace exp_pays_21 = "-999" if id_plateforme==628
replace compexp_2020 = "1150000" if id_plateforme==628
replace comp_ca2020 = "1280000" if id_plateforme==628
replace dig_revenues_ecom = "0" if id_plateforme==628
replace comp_benefice2020 = "-999" if id_plateforme==628 
replace needs_check = 0 if id_plateforme==628

replace compexp_2020 = "12000000" if id_plateforme==630
replace comp_ca2020 = "12000000" if id_plateforme==630
replace dig_revenues_ecom = "0" if id_plateforme==630
replace comp_benefice2020 = "400000" if id_plateforme==630
replace needs_check = 0 if id_plateforme==630

replace comp_ca2020 = "120000" if id_plateforme==632
replace needs_check = 0 if id_plateforme==632

replace compexp_2020 = "0" if id_plateforme==635
replace comp_ca2020 = "75000" if id_plateforme==635
replace dig_revenues_ecom = "0" if id_plateforme==635
replace comp_benefice2020 = "50000" if id_plateforme==635
replace needs_check = 0 if id_plateforme==635

replace investcom_futur = "30000" if id_plateforme==637
replace needs_check = 0 if id_plateforme==637

replace compexp_2020 = "50000" if id_plateforme==643
replace comp_ca2020 = "120000" if id_plateforme==643
replace dig_revenues_ecom = "0" if id_plateforme==643
replace comp_benefice2020 = "100" if id_plateforme==643 
replace needs_check = 0 if id_plateforme==643

replace compexp_2020 = "0" if id_plateforme==650
replace comp_ca2020 = "2409519" if id_plateforme==650
replace dig_revenues_ecom = "0" if id_plateforme==650
replace comp_benefice2020 = "49623" if id_plateforme==650
replace needs_check = 0 if id_plateforme==650

replace compexp_2020 = "1528881" if id_plateforme==655
replace comp_ca2020 = "7656478" if id_plateforme==655
replace dig_revenues_ecom = "0" if id_plateforme==655
replace comp_benefice2020 = "-1935354" if id_plateforme==655
replace needs_check = 0 if id_plateforme==655

replace compexp_2020 = "0" if id_plateforme==657
replace comp_ca2020 = "1183683" if id_plateforme==657
replace needs_check = 0 if id_plateforme==657

replace compexp_2020 = "150000" if id_plateforme==670
replace comp_ca2020 = "500000" if id_plateforme==670
replace needs_check = 0 if id_plateforme==670

replace exp_afrique_principal = "sénégal" if id_plateforme==668
replace comp_ca2020 = "50000" if id_plateforme==668
replace dig_revenues_ecom = "50000" if id_plateforme==668
replace comp_benefice2020 = "0" if id_plateforme==668
replace needs_check = 0 if id_plateforme==668

replace tel_sup2 = "99667598" if id_plateforme==695
replace needs_check = 0 if id_plateforme==695

replace comp_ca2020 = "6500000" if id_plateforme==681
replace compexp_2020 = "400000" if id_plateforme==681
replace dig_revenues_ecom = "0" if id_plateforme==681
replace comp_benefice2020 = "1200000" if id_plateforme==681
replace needs_check = 0 if id_plateforme==681

replace comp_ca2020 = "15000000" if id_plateforme==689
replace compexp_2020 = "12000000" if id_plateforme==689
replace dig_revenues_ecom = "0" if id_plateforme==689
replace comp_benefice2020 = "400000" if id_plateforme==689
replace investcom_2021 = "150000" if id_plateforme==689
replace investcom_futur = "150000" if id_plateforme==689
replace needs_check = 0 if id_plateforme==689

replace comp_ca2020 = "370000" if id_plateforme==698
replace compexp_2020 = "0" if id_plateforme==698
replace dig_revenues_ecom = "0" if id_plateforme==698
replace comp_benefice2020 = "-30000" if id_plateforme==698
replace needs_check = 0 if id_plateforme==698

replace compexp_2020 = "97762" if id_plateforme==700
replace comp_ca2020 = "202912" if id_plateforme==700
replace needs_check = 0 if id_plateforme==700

replace compexp_2020 = "312000" if id_plateforme==706
replace comp_ca2020 = "312000" if id_plateforme==706
replace comp_benefice2020 = "80332" if id_plateforme==706
replace needs_check = 0 if id_plateforme==706

replace compexp_2020 = "30000" if id_plateforme==708
replace comp_ca2020 = "100000" if id_plateforme==708
replace dig_revenues_ecom = "20000" if id_plateforme==708
replace comp_benefice2020 = "15000" if id_plateforme==708
replace needs_check = 0 if id_plateforme==708

replace comp_ca2020 = "40000" if id_plateforme==712
replace compexp_2020 = "0" if id_plateforme==712
replace dig_revenues_ecom = "30000" if id_plateforme==712
replace comp_benefice2020 = "30000" if id_plateforme==712
replace needs_check = 0 if id_plateforme==712

replace comp_ca2020 = "`refused'" if id_plateforme==714
replace compexp_2020 = "`refused'" if id_plateforme==714
replace dig_revenues_ecom = "`refused'" if id_plateforme==714
replace comp_benefice2020 = "`refused'" if id_plateforme==714
replace needs_check = 0 if id_plateforme==714

replace comp_ca2020 = "600000" if id_plateforme==715
replace compexp_2020 = "180000" if id_plateforme==715
replace dig_revenues_ecom = "0" if id_plateforme==715
replace comp_benefice2020 = "80000" if id_plateforme==715
replace needs_check = 0 if id_plateforme==715

replace comp_ca2020 = "16000000" if id_plateforme==724
replace compexp_2020 = "10331000" if id_plateforme==724
replace dig_revenues_ecom = "900000" if id_plateforme==724
replace comp_benefice2020 = "150000" if id_plateforme==724
replace needs_check = 0 if id_plateforme==724

replace compexp_2020 = "0" if id_plateforme==730
replace comp_ca2020 = "119630" if id_plateforme==730
replace comp_benefice2020 = "-40244" if id_plateforme==730
replace needs_check = 0 if id_plateforme==730

replace compexp_2020 = "27776029" if id_plateforme==732
replace comp_ca2020 = "27776029" if id_plateforme==732
replace dig_revenues_ecom = "8332809" if id_plateforme==732
replace comp_benefice2020 = "941336" if id_plateforme==732
replace needs_check = 0 if id_plateforme==732

replace comp_benefice2020 = " -999" if id_plateforme==735
replace exp_pays_21 = "0" if id_plateforme==735
replace needs_check = 0 if id_plateforme==735

replace compexp_2020 = "1770000" if id_plateforme==736
replace comp_ca2020 = "15016430" if id_plateforme==736
replace comp_benefice2020 = " -999" if id_plateforme==736
replace needs_check = 0 if id_plateforme==736

replace compexp_2020 = "2380000" if id_plateforme==739
replace comp_ca2020 = "16000000" if id_plateforme==739
replace comp_benefice2020 = "0" if id_plateforme==739
replace needs_check = 0 if id_plateforme==739

replace exp_pays_21 = "0" if id_plateforme==742
replace needs_check = 0 if id_plateforme==742

replace comp_ca2020 = "117624" if id_plateforme==764
replace compexp_2020 ="175062" if id_plateforme==764
replace dig_revenues_ecom = "0" if id_plateforme==764
replace comp_benefice2020 = "13000" if id_plateforme==764
replace needs_check = 0 if id_plateforme==764

replace exp_pays_21 = "-999" if exp_pays_21=="330"
replace needs_check = 0 if id_plateforme==628
replace needs_check = 0 if id_plateforme==443

replace exp_pays_21 = "-999" if exp_pays_21=="200"

replace compexp_2020 = "1300" if id_plateforme==743
replace comp_ca2020 = "80000" if id_plateforme==743
replace needs_check = 0 if id_plateforme==743

replace exp_afrique = 0 if id_plateforme==761
replace needs_check = 0 if id_plateforme==761

replace compexp_2020 = "0" if id_plateforme==763
replace investcom_2021 = "300" if id_plateforme==763
replace comp_ca2020 = "1700" if id_plateforme==763
replace comp_benefice2020 = "1100" if id_plateforme==763
replace needs_check = 0 if id_plateforme==763

replace exp_pays_21 = "0" if id_plateforme==769
replace investcom_2021 = "0" if id_plateforme==769
replace needs_check = 0 if id_plateforme==769

replace compexp_2020 = "0" if id_plateforme==773

replace investcom_2021 ="0" if id_plateforme==773

replace comp_ca2020 = "800000" if id_plateforme==773
replace comp_benefice2020 = "40000" if id_plateforme==773
replace needs_check = 0 if id_plateforme==773

replace compexp_2020 = "268072" if id_plateforme==782
replace comp_ca2020 = "913302" if id_plateforme==782
replace comp_benefice2020 = "62136" if id_plateforme==782
replace dig_revenues_ecom = "0" if id_plateforme==782
replace needs_check = 0 if id_plateforme==782

replace compexp_2020 = "49000" if id_plateforme==805
replace comp_ca2020 = "655000" if id_plateforme==805
replace dig_revenues_ecom = "8000" if id_plateforme==805
replace comp_benefice2020 = "-123000" if id_plateforme==805
replace investcom_2021 ="10000" if id_plateforme==805
replace needs_check = 0 if id_plateforme==805 

replace compexp_2020 = "30000" if id_plateforme==810
replace comp_ca2020 = "100000" if id_plateforme==810
replace dig_revenues_ecom = "30000" if id_plateforme==810
replace comp_benefice2020 = "35000" if id_plateforme==810
replace needs_check = 0 if id_plateforme==810 

replace compexp_2020 = "50000000" if id_plateforme==820
replace comp_ca2020 = "70000000" if id_plateforme==820
replace dig_revenues_ecom = "0" if id_plateforme==820
replace comp_benefice2020 = "`refused'" if id_plateforme==820
replace needs_check = 0 if id_plateforme==820 

replace compexp_2020 = "`refused'" if id_plateforme==827
replace comp_ca2020 = "`refused'" if id_plateforme==827
replace dig_revenues_ecom = "`refused'" if id_plateforme==827
replace comp_benefice2020 = "`refused'" if id_plateforme==827
replace needs_check = 0 if id_plateforme==827 //Refuse de donner toutes les réponses comptabilité

replace survey_type = "online" if id_plateforme==831

replace compexp_2020 = "250000" if id_plateforme==841
replace comp_ca2020 = "250000" if id_plateforme==841
replace dig_revenues_ecom = "0" if id_plateforme==841
replace comp_benefice2020 = "45000" if id_plateforme==841
replace needs_check = 0 if id_plateforme==841

replace compexp_2020 = "15000" if id_plateforme==876
replace comp_ca2020 = "38000" if id_plateforme==876
replace dig_revenues_ecom = "0" if id_plateforme==876
replace investcom_2021 = "8000" if id_plateforme==876
replace needs_check = 0 if id_plateforme==876

replace compexp_2020 = "2500000" if id_plateforme==899
replace comp_ca2020 = "7000000" if id_plateforme==899
replace dig_revenues_ecom = "0" if id_plateforme==899
replace needs_check = 0 if id_plateforme==899

replace compexp_2020 = "47740" if id_plateforme==925
replace comp_ca2020 = "158015" if id_plateforme==925
replace dig_revenues_ecom = "0" if id_plateforme==925
replace comp_benefice2020 = "15922" if id_plateforme==925
replace needs_check = 0 if id_plateforme==925

replace investcom_2021 = "-999" if id_plateforme==926
replace needs_check = 0 if id_plateforme==926

replace compexp_2020 = "0" if id_plateforme==931
replace comp_ca2020 = "3000" if id_plateforme==931
replace dig_revenues_ecom = "0" if id_plateforme==931
replace comp_benefice2020 = "0" if id_plateforme==931
replace needs_check = 0 if id_plateforme==931

replace compexp_2020 = "5000" if id_plateforme==953
replace comp_ca2020 = "45000" if id_plateforme==953
replace dig_revenues_ecom = "0" if id_plateforme==953
replace comp_benefice2020 = "-33000" if id_plateforme==953
replace needs_check = 0 if id_plateforme==953

replace compexp_2020 = "150000" if id_plateforme==959
replace comp_ca2020 = "1000000" if id_plateforme==959
replace dig_revenues_ecom = "0" if id_plateforme==959
replace comp_benefice2020 = "0" if id_plateforme==959
replace needs_check = 0 if id_plateforme==959


replace compexp_2020 = "350000" if id_plateforme==962
replace comp_ca2020 = "1500000" if id_plateforme==962
replace dig_revenues_ecom = "0" if id_plateforme==962
replace comp_benefice2020 = "150000" if id_plateforme==962
replace needs_check = 0 if id_plateforme==962







}
***********************************************************************
* 	PART 3: use regular expressions to correct variables 		  			
***********************************************************************
/* for reference and guidance, regularly these commands are used in this section
gen XXX = ustrregexra(XXX, "^216", "")
gen id_adminrect = ustrregexm(id_admin, "([0-9]){6,7}[a-z]")

*replace id_adminrige = $check_again if id_adminrect == 1
lab def correct 1 "correct" 0 "incorrect"
lab val id_adminrect correct

*/

* Correction des variables investissement
*replace investcom_2021 = ustrregexra( investcom_2021,"k","000")
//replace investcom_futur = ustrregexra( investcom_futur,"dinars","")
//replace investcom_futur = ustrregexra( investcom_futur,"dt","")
//replace investcom_futur = ustrregexra( investcom_futur,"k","000")

* Enlever tout les déterminants du nom des produits
{
replace entr_produit1 = ustrregexra( entr_produit1 ,"la ","")
replace entr_produit1 = ustrregexra( entr_produit1 ,"le ","")
replace entr_produit1 = ustrregexra( entr_produit1 ,"les ","")
replace entr_produit1 = ustrregexra( entr_produit1 ,"un ","")
replace entr_produit1 = ustrregexra( entr_produit1 ,"une ","")
replace entr_produit1 = ustrregexra( entr_produit1 ,"des ","")

replace entr_produit2 = ustrregexra( entr_produit2 ,"la ","")
replace entr_produit2 = ustrregexra( entr_produit2 ,"le ","")
replace entr_produit2 = ustrregexra( entr_produit2 ,"les ","")
replace entr_produit2 = ustrregexra( entr_produit2 ,"un ","")
replace entr_produit2 = ustrregexra( entr_produit2 ,"une ","")
replace entr_produit2 = ustrregexra( entr_produit2 ,"des ","")

replace entr_produit3 = ustrregexra( entr_produit3 ,"la ","")
replace entr_produit3 = ustrregexra( entr_produit3 ,"le ","")
replace entr_produit3 = ustrregexra( entr_produit3 ,"les ","")
replace entr_produit3 = ustrregexra( entr_produit3 ,"un ","")
replace entr_produit3 = ustrregexra( entr_produit3 ,"une ","")
replace entr_produit3 = ustrregexra( entr_produit3 ,"des ","")

replace id_base_repondent = ustrregexra( id_base_repondent ,"mme ","")

replace investcom_futur = ustrregexra( investcom_futur ," dinars","")


}

* Remplacer tout les points par des virgules & Enlever les virgules au niveau des numéros de téléphone



***********************************************************************
* 	PART 4:  Replace string with numeric values		  			
***********************************************************************
{
*Remplacer les textes de la variable investcom_2021
replace investcom_2021 = "100000" if investcom_2021== "100000dt"
replace investcom_2021 = "18000" if investcom_2021== "huit mille dinars"
replace investcom_2021 = "0" if investcom_2021== "zéro"
replace investcom_2021 = "7628248" if investcom_2021== "7628248,000 dt"
replace investcom_2021 = "1000" if investcom_2021== "moins que 1000dt"
replace investcom_2021 = "0" if investcom_2021 == "zero"
replace investcom_2021 = "10000" if investcom_2021 == "10 000"
replace investcom_2021 = "9000" if investcom_2021 == "9000 (neuf mille dinars)"
replace investcom_2021 = "2500" if investcom_2021 == "2 500,000"
replace investcom_2021 = "100000" if investcom_2021 == "100kdt"
replace investcom_2021 = "100000" if investcom_2021 == "a"
replace investcom_2021 = "3500000" if investcom_2021 == "3 500,000"
replace investcom_2021 = "40000" if investcom_2021 == "quarante milles dinars"
replace investcom_2021 = "30000" if investcom_2021 == "trente milles dinars"
replace investcom_2021 = "3000" if investcom_2021 == "trois mille dinars 3000"

replace investcom_2021 = "`refused'" if investcom_2021 == "-888"
replace investcom_2021 = "`not_know'" if investcom_2021 == "-999"
replace investcom_2021 = "`not_know'" if investcom_2021 == "لا اعرف"



*Remplacer les textes de la variable investcom_futur

replace investcom_futur = "20000" if investcom_futur == "vingt mille"
replace investcom_futur = "7000" if investcom_futur == "sept milles (7000dt)"
replace investcom_futur = "20000" if investcom_futur == "20 000"
replace investcom_futur = "20000" if investcom_futur == "20000 "
replace investcom_futur = "15000" if investcom_futur == "15000 (quinze mille)"
replace investcom_futur = "3500" if investcom_futur == "3 500,000"
replace investcom_futur = "5500" if investcom_futur == "5 500,000"
replace investcom_futur = "10000" if investcom_futur == "dix milles"
replace investcom_futur = "20000" if investcom_futur == "vingt mille dinars"
replace investcom_futur = "30000" if investcom_futur == "trente mille"
replace investcom_futur = "5000" if investcom_futur == "cinq mille 5000"

replace investcom_futur = "10000" if investcom_futur == "dix milles"
replace investcom_futur = "100000" if investcom_futur == "100kdt"
replace investcom_futur = "15000" if investcom_futur == "10 000 à 20 000"
replace investcom_futur = "12500" if investcom_futur == "entre 10000 à 15000"

replace investcom_futur = "10000" if investcom_futur == "10 000"
replace investcom_futur = "120000" if investcom_futur == "cent vingt milles"

replace investcom_futur = "`check_again'" if investcom_futur == "aa"
replace investcom_futur = "`refused'" if investcom_futur == "-888"
replace investcom_futur = "`not_know'" if investcom_futur == "-999"
replace investcom_futur = "`not_know'" if investcom_futur == "je sais pas encore"
replace investcom_futur = "`not_know'" if investcom_futur == "ne sais pas"

replace investcom_futur = "20000" if investcom_futur == "20000 dinars"
replace investcom_futur = "7000" if investcom_futur == "sept milles dinars (7000dt)"
replace investcom_futur = "15000" if investcom_futur == "15000 (quinze mille dinars)"
replace investcom_futur = "3000" if investcom_futur == "trente mille dinars"
replace investcom_futur = "3000" if investcom_futur == "cinq mille dinars 5000"
replace investcom_futur = "120000" if investcom_futur == "cent vingt milles dinars"

replace investcom_futur = "120000" if investcom_futur == "cent vingt milles"


*Correction de la variable compexp_2020
replace compexp_2020 = "794596" if compexp_2020== "794 596.000"
replace compexp_2020 = "110000" if compexp_2020== "110 000"
replace compexp_2020 = "7628248" if compexp_2020== "7628248000"
replace compexp_2020 = "1566010" if compexp_2020== "1.566.010"
replace compexp_2020 = "40000" if compexp_2020 == "40.000 quarante mille dinars"
replace compexp_2020= "3609000" if compexp_2020== "3609000dt"
replace compexp_2020= "0" if compexp_2020== "248000dt 2018 et 124000dt 2019"
replace compexp_2020= "1200000" if compexp_2020== "1 200 000"
replace compexp_2020= "`not_know'" if compexp_2020== "je ne sais pas"
replace compexp_2020= "8000000" if compexp_2020== "8 000 000"
replace compexp_2020= "263605" if compexp_2020== "263 605"
replace compexp_2020= "201801" if compexp_2020== "201 801"
replace compexp_2020= "700000" if compexp_2020== "700 000"
replace compexp_2020= "2599419" if id_plateforme == 757


*Correction de la variable comp_ca2020
replace comp_ca2020 = "993245" if comp_ca2020== "993 245,000"
replace comp_ca2020 = "304379" if comp_ca2020== "304 379"
replace comp_ca2020 = "10000000" if comp_ca2020== "10 000 000"
replace comp_ca2020 = "7628248" if comp_ca2020== "7628248000"
replace comp_ca2020 = "3039336" if comp_ca2020== "3 039 336"
replace comp_ca2020 = "5351160" if comp_ca2020== "5.351.160"
replace comp_ca2020 = "6987385,476" if comp_ca2020== "6987385.476"
replace comp_ca2020 = "6987385" if comp_ca2020 == "6987385,476"
replace comp_ca2020 = "800000" if comp_ca2020 == "800.000 huit cent mille dinars"
replace comp_ca2020 = "235000" if comp_ca2020 == "235 000"
replace comp_ca2020= "0" if comp_ca2020== "248000dt 2018 et 124000dt 2019"
replace comp_ca2020 = "1000000" if comp_ca2020== "1 000 000"
replace comp_ca2020= "15959988" if id_plateforme == 757



replace comp_ca2020 = "1183683" if comp_ca2020 == "1183683.477"
replace comp_ca2020 = "15231000" if comp_ca2020 == "15231000dt"
replace comp_ca2020 = "28727" if comp_ca2020 == "28 726.833"
replace comp_ca2020 = "500000" if comp_ca2020 == "500 (cinq cent mille dinars)"
replace comp_ca2020 = "977097" if comp_ca2020 == "977 097"
replace comp_ca2020 = "1880000" if comp_ca2020 == "1 880 000"
replace comp_ca2020= "`not_know'" if comp_ca2020== "je ne sais pas"
replace comp_ca2020= "8000000" if comp_ca2020== "8 000 000"
replace comp_ca2020= "2343425" if comp_ca2020== "2 343 425"


*Correction de la variable dig_revenues_ecom
replace dig_revenues_ecom = "20000" if dig_revenues_ecom== "20 000"
replace dig_revenues_ecom = "200000" if dig_revenues_ecom== "200 000"

replace dig_revenues_ecom = "11131" if dig_revenues_ecom== "11 131"
replace dig_revenues_ecom = "0" if dig_revenues_ecom == "zeo"
replace dig_revenues_ecom = "0.70" if dig_revenues_ecom == "70% de ca totale"
replace dig_revenues_ecom = "0.30" if dig_revenues_ecom == "non établi. ds les 30% environ"

replace dig_revenues_ecom = "`check_again'" if dig_revenues_ecom == "0 dt en 2019"

replace dig_revenues_ecom = "`refused'" if dig_revenues_ecom == "-888"
replace dig_revenues_ecom = "`not_know'" if dig_revenues_ecom == "-999"
replace dig_revenues_ecom = "`not_know'" if dig_revenues_ecom == "je ne sais pas"

replace dig_revenues_ecom = "`not_know'" if dig_revenues_ecom == "je ne sais pas"

replace investcom_futur = "" if investcom_futur == ".."


* Correction de la variable comp_benefice2020
replace comp_benefice2020 = "337892" if comp_benefice2020== "337 892"
replace comp_benefice2020 = "317887,923" if comp_benefice2020== "317 887,923"
replace comp_benefice2020 = "28929" if comp_benefice2020== "28 929"
replace comp_benefice2020 = "191805" if comp_benefice2020== "191805000"
replace comp_benefice2020 = "317888" if comp_benefice2020 == "317887,923"
replace comp_benefice2020 = "41000" if comp_benefice2020 == "41 000"
replace comp_benefice2020 =  "46000" if comp_benefice2020 == "46000 quarante six mille dinar"


replace comp_benefice2020 = "`check_again'" if comp_benefice2020 == "18000 dt en 2019"
replace comp_benefice2020 = "`check_again'" if comp_benefice2020 == "30% men chiffre d'affaire"
replace comp_benefice2020 = "`not_know'" if comp_benefice2020 == "je ne sais pas"
replace comp_benefice2020 = "`check_again'" if comp_benefice2020 == "na"
replace comp_benefice2020 = "337892" if comp_benefice2020 == "337 892"
replace comp_benefice2020 = "-114131" if comp_benefice2020 == "-114 131"
replace comp_benefice2020 = "293050" if comp_benefice2020 == "293 050"
replace comp_benefice2020 = "46000" if comp_benefice2020 == "46000 quarante six mille dinar"
replace comp_benefice2020 = "41000" if comp_benefice2020 == "41 000"
replace comp_benefice2020 = "`check_again'" if comp_benefice2020 == "§§"
replace comp_benefice2020 = "28929" if comp_benefice2020 == "28 929"
replace comp_benefice2020 = "317887.923" if comp_benefice2020 == "317 887,923"
replace comp_benefice2020 = "0.2" if comp_benefice2020 == "20pou cent"
replace comp_benefice2020 = "550000" if comp_benefice2020== "550 000"
replace comp_benefice2020 = "0.3" if comp_benefice2020 == "30% men chiffre d'affaire"
replace comp_benefice2020 = "78000" if comp_benefice2020 == "78 000"
replace comp_benefice2020 = "120000" if comp_benefice2020 == "120 000"
replace comp_benefice2020 = "10000" if comp_benefice2020 == "10 000"
replace comp_benefice2020= "2059805" if id_plateforme == 757


replace comp_benefice2020 = "`refused'" if comp_benefice2020 == "-888"
replace comp_benefice2020 = "`not_know'" if comp_benefice2020 == "-999"
replace comp_benefice2020 = "`not_know'" if comp_benefice2020 == "je ne sais pas"


*Correction de la variable car_carempl_div
replace car_carempl_div1 = "`not_know'" if car_carempl_div1 == "?"
replace car_carempl_dive2 = "`not_know'" if car_carempl_dive2 == "?"
replace car_carempl_div3 = "`not_know'" if car_carempl_div3 == "?"

* exp_pays_21

replace exp_pays_21 = "-999" if exp_pays_21=="?"


}

***********************************************************************
* 	PART 5:  Convert string to numerical variabales	  			
***********************************************************************
* local destrvar XX
*foreach x of local destrvar { 
*destring `x', replace
local destrvar investcom_futur investcom_2021 dig_revenues_ecom comp_benefice2020 car_carempl_div1 car_carempl_dive2 car_carempl_div3 compexp_2020 comp_ca2020 exp_pays_21
foreach x of local destrvar {
destring `x', replace
format `x' %25.0fc
}

***********************************************************************
* 	PART 6:  Convert problematic values for open-ended questions  			
***********************************************************************
{

	* Sectionname
*replace q04 ="Hors sujet" if q04 == "OUI" 

*Correction nom du representant
*gen rg_nom_repr= rg_nom_rep            
*replace rg_nom_repr="$check_again" if rg_nom_rep == "Études géomatiques." 

* Correction de la variable investcom_2021
*replace investcom_2021 = "`check_again'" if investcom_2021== "a"
*replace investcom_2021 = "30000" if investcom_2021== "trente milles dinars"


* correction de lavariable comp_benefice2020



* Correction de la variable investcom_futur
//replace investcom_futur = "`check_again'" if investcom_futur== "aa"

 
}


***********************************************************************
* 	PART 7:  Traduction reponses en arabe au francais		  			
***********************************************************************
{
*Traduction des produits principaux de l'entreprise
replace entr_produit1 = "Farine à la tomate" if entr_produit1 == "فارينة طماطم"
replace entr_produit2 = "Farine aux oignons" if entr_produit2 == "فارينة بصل"
replace entr_produit3 = "farine à l'ail" if entr_produit3 == "فارينة ثوم"
replace entr_produit1 = "matériel éléctrique" if entr_produit1 == "المواد الكهربائية"
replace entr_produit2 = "matériaux de construction" if entr_produit2 == "مواد البناء"
replace entr_produit3 = "produits agro-alimentaires" if entr_produit3 == "الصناعات الغذائية"


*Traduction histoire de l'entreprise
replace entr_histoire = "International Trading and Consulting Company est une société entièrement exportatrice créée en 2006, caractérisée par une vaste expérience dans le domaine du commerce international et sa mission principale est d'améliorer l'activité des clients en fournissant la meilleure valeur pour leurs investissements dans le monde." if entr_histoire == "الشركة الدولية للتجارة والاستشارة هي شركة مصدرة بالكامل تأسست سنة 2006, تتميز بخبرة واسعة في مجال التجارة الدولية وتتمثل مهمتها الأساسية في تعزيز أعمال العملاء من خلال تقديم أفضل قيمة لاستثماراتهم في العالم، كما تقدم الشركة خدمات استشارية تمحور بالاساس حول طرق تقليل تكاليف الشراء والنقل وتسهيل عمل الحرفاء."
replace entr_histoire = "L'entreprise a débuté en tant que personne physique en 2002. montage d'entreprise ; c pas évident de status physique ; donc l'entreprise existe sur terrain et exporte vers l'europe depuis 2007 (ca fait 15 ans), danden et medina arbi tounes" if entr_histoire == "bdet en personne physique en 2002; montage d'entreprise ; c pas evident de status physique ; mawjouda men 2007 walet mawjouda sur terain et exporté vers l'europe , ca fait 15 ans ; danden et medina arbi tounes" 
replace entr_histoire = "l'entreprise continue d'exister car mon père était le PDG et il travaille le marbre. l'entreprise a été fondée en 2011. l'extraction et la transformation du marbre et la production ont débuté en juillet 2014" if entr_histoire == "charika tawasol 5ter weled il gérant ken marbre . t2aseset en 2011  lextraction et la trasformation du marbre imporoduction en juillet 2014 ." 
replace entr_histoire = "commerce internationnal 2017 (des dattes naturelles , condiciones )en 2019 (nous avons ouvert une fabrication) 2020 (a obtenu un certificat (Halal)" if entr_histoire == "commerce internationnal 2017 (des dattes naturele , condecionnes )en 2019 ( 3malna ma3mel ) 2020(5dhina chhada (7alel)" 
replace entr_histoire = "l'entreprise était locale et maintenant nous exportons, puis nous avons ouvert l'entreprise de Kantaoui fashion et la première entreprise a été fondée en 2001" if entr_histoire == "kenet local w tawa walet a l'export w ba3d halina socité kantaoui fashion w charika loula bdet 2001" 
replace entr_histoire = "l'entreprise a été construite sur l'idée de l'art et de l'artisanat en général. la PDG a fait une formation en italie et en grèce et elle a apporté l'idée en tunisie" if entr_histoire == "kenet mabniya 3la fekret l fan w lartisana 3amatan ; elle a fait un formation a l'italie w mchet l grec w jebetha ltounes" 
replace entr_histoire = "Fondée en 2016, dans le domaine de la couture." if entr_histoire == "men 2016 majel 5iyata finition  tenus de traville"

*Traduction des produits exportés en 2021
replace exp_produit_services21 = "farine" if exp_produit_services21 == "فارينة"
replace exp_produit_services21 = "Matériel électrique" if exp_produit_services21 == "مواد كهربائية"
replace exp_produit_services21 = "Chapelet de prière à l'ambre" if exp_produit_services21 == "سبحة العنبر"

*Traduction attente du projet
replace car_attend1 = "Apprendre de nouvelles méthodes en améliorant notre présence en ligne"  if car_attend1 == "تعلم أساليب جديدة من خلال و تعزيز الحضور على الإنترنت"
replace car_attend2 = "Corriger certains concepts mal utilisés et apprendre de nouvelles techniques"  if car_attend2 == "تصحيح بعض المفاهيم التي لم يقع استعمالها بشكل صحيح، وتعلم تقنيات جديدة"
replace car_attend3 = "Ouvrir de nouveaux horizons"  if car_attend3 == "فتح أفق جديدة"

*Traduction avantage commerce éléctronique 1
replace investcom_benefit3_1 = "Expansion vers de nouveaux marchés" if investcom_benefit3_1 == "فتح أسواق جديدة"
replace investcom_benefit3_1 = "augmenter notre réseau"  if investcom_benefit3_1 == "nkabrou reseaux mte3na"
replace investcom_benefit3_1 = "plus de visibilité"  if investcom_benefit3_1 == "visibilté akther"
replace investcom_benefit3_1 = "approfondir mes connaissances en marketing digital"  if investcom_benefit3_1 == "nwali na3ref nsawe9 akther il service mte3i fil internet digitale"
replace investcom_benefit3_1 = "extension de terrain pour de nouveaux clients"  if investcom_benefit3_1 == "nwas3ou lmajel lil clionet jdod"
replace investcom_benefit3_1 = "trouver des clients à l'étranger"  if investcom_benefit3_1 == "tal9a des clients a l'etranger"
replace investcom_benefit3_1 = "faire du marketing pour le produit"  if investcom_benefit3_1 == "taswi9 il produit"
replace investcom_benefit3_1 = "gagner plus de clients"  if investcom_benefit3_1 == "tekseb akther des clients"

*Traduction avantage commerce éléctronique 2
replace investcom_benefit3_2 = "Renforcer la position de l'entreprise dans le monde et créer des liens de confiance avec les clients" if investcom_benefit3_2 == "تعزيز مكانة الشركة حول العالم وخلق روابط للثقة في علاقتها مع الحرفاء"
replace investcom_benefit3_2 = "moins de frais" if investcom_benefit3_2 == "a9al cout"
replace investcom_benefit3_2 = "plus de clients" if investcom_benefit3_2 == "akther clionet"
replace investcom_benefit3_2 = "gagner plus de clients" if investcom_benefit3_2 == "nesta9tbou plusieurs clients"
replace investcom_benefit3_2 = "augmenter les ventes" if investcom_benefit3_2 == "présence bech tousel tbi3 akther"
replace investcom_benefit3_2 = "Comment trouver un vrai acheteur" if investcom_benefit3_2 == "كيف اجد المشتري الحقيقي"

*Traduction avantage commerce électronique 3
replace investcom_benefit3_3 = "Améliorer la notoriété de la marque de l'entreprise" if investcom_benefit3_3 == "تعزيز الوعي بالعلامة التجارية للشركة"
replace investcom_benefit3_3 = "le produit sera plus connu" if investcom_benefit3_3 == "les produits yet3raf akther"
replace investcom_benefit3_3 = "augmentation de chiffre d'affaire" if investcom_benefit3_3 == "ogmantaion de chiffre d'affaire"
replace investcom_benefit3_3 = "améliorer l'image de la marque" if investcom_benefit3_3 == "t7aseen f image de marque"
}


***********************************************************************
* 	PART 8: 	Rename and homogenize the observed values		  			
***********************************************************************
{
	* Sectionname
*replace bl_unite = "pièce"  if bl_unite=="par piece"
*replace bl_unite = "pièce"  if bl_unite=="Pièce" 
replace id_base_repondent= "Emna Cheikhrouhou" if id_base_repondent == "emna chi5 rouho"
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

}


***********************************************************************
* 	PART 9:  Import categorisation for opend ended QI questions
***********************************************************************

***********************************************************************
* 	PART 11:  Identify and remove duplicates 
***********************************************************************

* Dropping duplicates:
drop if id_plateforme == 58 & heure == "09h51`38``"
drop if id_plateforme == 63 & heure == "17h32`56``"
drop if id_plateforme == 63 & heure == "10h50`30``"
drop if id_plateforme == 77 & heure == "08h27`13``"
drop if id_plateforme == 78 & heure == "15h56`49``"
drop if id_plateforme == 78 & heure == "11h55`23``"
drop if id_plateforme == 78 & heure == "11h28`28``"
drop if id_plateforme == 78 & heure == "11h25`01``"
drop if id_plateforme == 105 & heure == "15h50`43``"
drop if id_plateforme == 108 & heure == "15h29`12``"
drop if id_plateforme == 108 & heure == "23h09`09``" 
drop if id_plateforme == 114 & heure == "18h34`17``"
drop if id_plateforme == 126 & heure == "14h55`09``"
replace exp_pays_21 =6 if  id_plateforme == 129 & heure == "14h27`18``"
replace investcom_2021 =15000 if  id_plateforme == 129 & heure == "14h27`18``"
drop if id_plateforme == 129 & heure == "14h15`10``"
drop if id_plateforme == 140 & heure == "18h17`02``"
drop if id_plateforme == 166 & heure == "19h43`11``"
drop if id_plateforme == 180 & heure == "14h25`37``"
drop if id_plateforme == 195 & heure == "10h09`54``"
drop if id_plateforme == 206 & heure == "11h08`43``"
drop if id_plateforme == 206 & heure == "08h55`51``"
drop if id_plateforme == 213 & heure == "08h43`15``"
drop if id_plateforme == 271 & heure == "14h34`28``"
drop if id_plateforme == 313 & heure == "15h24`44``"
drop if id_plateforme == 324 & heure == "08h46`17``"

replace comp_benefice2020 = -720000 if id_plateforme == 324
replace dig_revenues_ecom = 1200000 if id_plateforme == 324
replace entr_bien_service= 	3 if id_plateforme == 324
drop if id_plateforme == 324 & heure == "14h38`49``"
drop if id_plateforme == 324 & heure == "12h54`53``"
drop if id_plateforme == 324 & heure == "15h32`04``"


drop if id_plateforme == 351 & heure == "10h43`21``"
drop if id_plateforme == 351 & heure == "16h28`08``"
drop if id_plateforme == 369 & heure == "11h42`59``"
drop if id_plateforme == 360 & heure == "20h07`59``"
drop if id_plateforme == 410 & heure == "10h16`57``"
drop if id_plateforme == 436 & heure == "16h56`32``"
drop if id_plateforme == 457 & heure == "13h06`26``"
drop if id_plateforme == 457 & heure == "11h08`09``"
drop if id_plateforme == 457 & heure == "08h22`05``"
drop if id_plateforme == 457 & heure == "15h38`43``"


replace dig_marketing_respons= 2 if id_plateforme == 478
replace dig_service_responsable= 2 if id_plateforme == 478
replace investcom_2021= 3000 if id_plateforme == 478
replace expprep_norme= 1 if id_plateforme == 478
replace expprep_norme2= "iso 90010 en 2006 et 2008" if id_plateforme == 478
replace exp_pays_21= 5 if id_plateforme == 478
replace comp_benefice2020= -200000 if id_plateforme == 478
replace car_soutien_gouvern= 1 if id_plateforme == 478
replace car_pdg_age= 53 if id_plateforme == 478
replace car_carempl_div1= 35 if id_plateforme == 478
replace car_carempl_dive2= 10 if id_plateforme == 478
replace car_carempl_div3= 0 if id_plateforme == 478
drop if id_plateforme == 478 & heure == "11h36`38``"


drop if id_plateforme == 488 & heure == "13h35`09``"
drop if id_plateforme == 521 & heure == "15h41`40``"
drop if id_plateforme == 526 & heure == "08h55`51``"
drop if id_plateforme == 526 & heure == "19h24`33``"
drop if id_plateforme == 526 & heure == "19h45`13``"
drop if id_plateforme == 527 & heure == "11h30`18``"
drop if id_plateforme == 541 & heure == "16h40`39``"
drop if id_plateforme == 542 & heure == "15h37`59``"
drop if id_plateforme == 545 & heure == "15h54`12``"
drop if id_plateforme == 545 & heure == "10h10`49``"
drop if id_plateforme == 572 & heure == "16h19`02``"
drop if id_plateforme == 576 & heure == "11h49`52``"
drop if id_plateforme == 602 & heure == "14h08`28``"
drop if id_plateforme == 623 & heure == "16h23`38``"
drop if id_plateforme == 629 & heure == "15h28`26``"
drop if id_plateforme == 644 & heure == "13h15`19``"
drop if id_plateforme == 646 & heure == "16h08`01``"
drop if id_plateforme == 646 & heure == "16h28`14``"
drop if id_plateforme == 655 & heure == "10h20`08``"
drop if id_plateforme == 679 & heure == "18h28`53``"
drop if id_plateforme == 679 & heure == "13h32`54``"
drop if id_plateforme == 679 & heure == "19h01`55``"
drop if id_plateforme == 698 & heure == "13h00`32``"
drop if id_plateforme == 706 & heure == "14h23`08``"
drop if id_plateforme == 710 & heure == "19h10`37``"
drop if id_plateforme == 716 & heure == "17h02`40``"
drop if id_plateforme == 716 & heure == "11h22`15``"
drop if id_plateforme == 732 & heure == "16h55`41``"
drop if id_plateforme == 739 & heure == "15h36`45``"
drop if id_plateforme == 739 & heure == "11h27`59``"
drop if id_plateforme == 752 & heure == "20h33`22``"
drop if id_plateforme == 757 & heure == "16h29`40``"
drop if id_plateforme == 764 & heure == "11h13`42``"
drop if id_plateforme == 764 & heure == "11h10`00``"
drop if id_plateforme == 765 & heure == "11h01`13``"
drop if id_plateforme == 767 & heure == "11h00`11``"
replace investcom_2021 = 0 if id_plateforme == 782 & heure == "09h36`22``"
drop if id_plateforme == 782 & heure == "14h31`55``"
drop if id_plateforme == 782 & heure == "13h59`59``"
drop if id_plateforme == 791 & heure == "13h40`07``"
drop if id_plateforme == 791 & heure == "13h40`16``"
drop if id_plateforme == 800 & heure == "15h38`00``"
drop if id_plateforme == 803 & heure == "08h32`50``"
drop if id_plateforme == 831 & heure == "15h45`46``"
drop if id_plateforme == 859 & heure == "11h17`13``"

replace dig_service_responsable= 2 if id_plateforme == 800
replace investcom_2021= -999 if id_plateforme == 800
replace expprep_responsable= 1 if id_plateforme == 800
replace exp_pays_21= 3 if id_plateforme == 800
replace info_neces= 1 if id_plateforme == 800
replace compexp_2020= 0 if id_plateforme == 800
replace comp_ca2020= 90000 if id_plateforme == 800
replace dig_revenues_ecom= 90000 if id_plateforme == 800
replace comp_benefice2020= -5000 if id_plateforme == 800
replace car_carempl_div1= 9 if id_plateforme == 800
replace car_carempl_dive2= 2 if id_plateforme == 800
replace car_carempl_div3 = 0 if id_plateforme == 800
drop if id_plateforme == 800 & heure == "14h48`52``"


replace entr_bien_service= 2 if id_plateforme == 875 & heure == "11h08`29``"
replace entr_produit1= "carreaux céramique" if id_plateforme == 875 & heure == "11h08`29``"
replace entr_produit2= "grès" if id_plateforme == 875 & heure == "11h08`29``"
replace entr_produit3= "sanitaires et robinetteries" if id_plateforme == 875 & heure == "11h08`29``"
replace investcom_futur= 10000 if id_plateforme == 875 & heure == "11h08`29``"
replace investcom_benefit3_2= "une notoriété a l'échelle international" if id_plateforme == 875 & heure == "11h08`29``"
replace expprep_cible= 1 if id_plateforme == 875 & heure == "11h08`29``"
replace exp_produit_services21= "faience, carreau céramique" if id_plateforme == 875 & heure == "11h08`29``"
drop if id_plateforme == 875 & heure == "16h15`31``"


drop if id_plateforme == 896 & heure == "11h34`10``"
drop if id_plateforme == 898 & heure == "10h16`02``"
drop if id_plateforme == 911 & heure == "12h15`01``"
drop if id_plateforme == 916 & heure == "18h16`52``"
drop if id_plateforme == 931 & heure == "21h11`06``"
drop if id_plateforme == 953 & heure == "19h03`17``"



drop if id_plateforme == 941 & heure == "16h09`19``"
drop if id_plateforme == 941 & heure == "15h56`54``"
drop if id_plateforme == 961 & heure == "10h17`41``"


	* Drop firms that did not want to participate in the intervention
	* (According to the survey institute)
drop if id_plateforme == 414
drop if id_plateforme == 548
drop if id_plateforme == 734
drop if id_plateforme == 887

	* Drop obs that was not a firm (According to the survey institute):

drop if id_plateforme == 813
	

* Correcting the second duplicates:

replace id_base_repondent= "sana farjallah" if id_plateforme == 108
replace entr_produit1= "skit solaire connecté réseau,site isolé et pompage solaire" if id_plateforme == 108
replace i= "africa@growatt.pro" if id_plateforme == 108


replace dig_revenues_ecom= 20000 if id_plateforme == 140
replace perc_ident= 2 if id_plateforme == 140
replace perc_video= 2 if id_plateforme == 140

replace expprep_norme2= "toutes les certifs de hp" if id_plateforme == 206
replace exp_avant21_2= "logiciels & services" if id_plateforme == 206
replace exp_pays_avant21= 1 if id_plateforme == 206
replace exp_pays_principal_avant21= "libye" if id_plateforme == 206

//replace orienter_= 6 if id_plateforme == 195
replace id_nouveau_personne= 2 if id_plateforme == 195
replace id_base_repondent= "anis kadech" if id_plateforme == 195
replace id_repondent_position= 2 if id_plateforme == 195

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
		
replace compexp_2020= 660000 if id_plateforme == 898
replace comp_ca2020= 800000 if id_plateforme == 898
replace car_carempl_div1= 16 if id_plateforme == 898
replace car_carempl_dive2= 5 if id_plateforme == 898
replace car_carempl_div3= 0 if id_plateforme == 898		

replace car_carempl_div1 = 1 if id_plateforme==360
replace car_carempl_dive2 = 2 if id_plateforme==360
replace car_carempl_div3 = 0 if id_plateforme==360
replace exp_pays_21 = 1 if id_plateforme==360

replace car_carempl_div1 = 50 if id_plateforme==369
replace car_carempl_dive2 = 20 if id_plateforme==369
replace car_carempl_div3 = 0 if id_plateforme==369
replace exp_pays_21 = 4 if id_plateforme==369

 	  	

	* Check remaining duplicates (after manual corrections above)
	
bysort id_plateforme:  gen dup = cond(_N==1,0,_n)	

	* Check which observations are more complete
	
ds, has(type numeric)
local all_nums `r(varlist)'

egen sum_allvars = rowtotal(`all_nums')

	* Drop duplicates that are less complete

bysort id_plateforme: egen max_length = max(sum_allvars)

	* Tag as dup 4 shorter answers, check them and drop them
replace dup = 4 if dup>0 & sum_allvars<max_length

drop if id_plateforme == 70 & dup == 4
drop if id_plateforme == 82 & dup == 4
drop if id_plateforme == 91 & dup == 4
drop if id_plateforme == 95 & dup == 4
drop if id_plateforme == 105 & dup == 4 & car_carempl_div1 == .
drop if id_plateforme == 136 & dup == 4
drop if id_plateforme == 140 & dup == 4
drop if id_plateforme == 146 & dup == 4
drop if id_plateforme == 148 & dup == 4
drop if id_plateforme == 151 & dup == 4
drop if id_plateforme == 183 & dup == 4
drop if id_plateforme == 212 & dup == 4
drop if id_plateforme == 216 & dup == 4
drop if id_plateforme == 240 & dup == 4
drop if id_plateforme == 248 & dup == 2
drop if id_plateforme == 261 & dup == 4
drop if id_plateforme == 264 & dup == 4

drop if id_plateforme == 265 & dup == 4
drop if id_plateforme == 270 & dup == 4
drop if id_plateforme == 275 & dup == 2
drop if id_plateforme == 303 & dup == 4
drop if id_plateforme == 311 & dup == 4
drop if id_plateforme == 323 & dup == 4
// check the following two
drop if id_plateforme == 324 & dup == 4 & acceptezvousdevalidervosré!=1
drop if id_plateforme == 324 & dup == 4 & survey_type!="online"
drop if id_plateforme == 337 & dup == 2
drop if id_plateforme == 352 & dup == 4
drop if id_plateforme == 354 & dup == 2
drop if id_plateforme == 365 & dup == 4
drop if id_plateforme == 366 & dup == 4
drop if id_plateforme == 373 & dup == 4
drop if id_plateforme == 375 & dup == 4
drop if id_plateforme == 377 & dup == 4
drop if id_plateforme == 381 & dup == 4
drop if id_plateforme == 424 & dup == 4
drop if id_plateforme == 440 & dup == 4
drop if id_plateforme == 457 & dup == 4
drop if id_plateforme == 477 & dup == 4
drop if id_plateforme == 488 & dup == 4
drop if id_plateforme == 493 & dup == 4
drop if id_plateforme == 526 & dup == 4
drop if id_plateforme == 541 & dup == 4
// check the next two
drop if id_plateforme == 542 & dup == 4 & attest!=1
drop if id_plateforme == 542 & dup == 4 & survey_type!="phone"
drop if id_plateforme == 543 & dup == 4
drop if id_plateforme == 549 & dup == 4
drop if id_plateforme == 568 & dup == 4
drop if id_plateforme == 572 & dup == 4
drop if id_plateforme == 576 & dup == 4
drop if id_plateforme == 581 & dup == 4
drop if id_plateforme == 592 & dup == 4
drop if id_plateforme == 604 & dup == 4
drop if id_plateforme == 617 & dup == 4
drop if id_plateforme == 632 & dup == 4
drop if id_plateforme == 542 & dup == 4
drop if id_plateforme == 546 & dup == 4
drop if id_plateforme == 650 & dup == 4
drop if id_plateforme == 657 & dup == 4
drop if id_plateforme == 670 & dup == 4
drop if id_plateforme == 679 & dup == 4
drop if id_plateforme == 695 & dup == 4
drop if id_plateforme == 698 & dup == 4
drop if id_plateforme == 700 & dup == 4
drop if id_plateforme == 715 & dup == 2
drop if id_plateforme == 730 & dup == 4
drop if id_plateforme == 732 & dup == 4
drop if id_plateforme == 739 & dup == 4
drop if id_plateforme == 761 & dup == 4
drop if id_plateforme == 763 & dup == 4
drop if id_plateforme == 773 & dup == 4
drop if id_plateforme == 805 & dup == 4
drop if id_plateforme == 820 & dup == 4
drop if id_plateforme == 846 & dup == 4
drop if id_plateforme == 876 & dup == 4
drop if id_plateforme == 887 & dup == 4
drop if id_plateforme == 899 & dup == 4
drop if id_plateforme == 959 & dup == 4
drop if id_plateforme == 165 & dup == 1
drop if id_plateforme == 209 & dup == 2
drop if id_plateforme == 213 & dup == 4
drop if id_plateforme == 360 & dup == 2
drop if id_plateforme == 369 & dup == 1
drop if id_plateforme == 598 & dup == 1
drop if id_plateforme == 612 & dup == 1
drop if id_plateforme == 642 & dup == 4
drop if id_plateforme == 646 & dup == 4



*check again duplicate id_plateforme= 800 & 108 & 324

drop if id_plateforme == 58 & dup ==4
drop if id_plateforme == 63 & dup ==4
// check next (missing answers in dropped)
drop if id_plateforme == 78 & dup ==4 & comp_ca2020==.
drop if id_plateforme == 85 & dup ==4
// double check
drop if id_plateforme == 114 & dup ==1
drop if id_plateforme == 166 & dup ==4
drop if id_plateforme == 195 & dup ==4
// check next (missing answers in dropped)
drop if id_plateforme == 206 & dup ==4
drop if id_plateforme == 271 & dup ==4
drop if id_plateforme == 313 & dup ==4
drop if id_plateforme == 394 & dup ==4
drop if id_plateforme == 405 & dup ==4
// check next (missing answers in dropped)
drop if id_plateforme == 436 & dup ==4
drop if id_plateforme == 447 & dup ==4
drop if id_plateforme == 508 & dup ==4
drop if id_plateforme == 521 & dup ==4
drop if id_plateforme == 527 & dup ==4
// check next (missing answers in dropped)
drop if id_plateforme == 545 & dup ==4
drop if id_plateforme == 565 & dup ==4

drop if id_plateforme == 586 & dup ==4
drop if id_plateforme == 602 & dup ==4
drop if id_plateforme == 623 & dup ==4
drop if id_plateforme == 629 & dup ==4
drop if id_plateforme == 644 & dup ==4
drop if id_plateforme == 710 & dup ==4
drop if id_plateforme == 716 & dup ==4
drop if id_plateforme == 736 & dup ==4
drop if id_plateforme == 747 & dup ==4
drop if id_plateforme == 757 & dup ==4
drop if id_plateforme == 765 & dup ==4
drop if id_plateforme == 767 & dup ==4
drop if id_plateforme == 782 & dup ==1
drop if id_plateforme == 791 & dup ==4
drop if id_plateforme == 803 & dup ==4
drop if id_plateforme == 831 & dup ==4
drop if id_plateforme == 873 & dup ==4
drop if id_plateforme == 896 & dup ==4
drop if id_plateforme == 911 & dup ==4
drop if id_plateforme == 916 & dup ==4
// check next two
drop if id_plateforme == 961 & dup ==4



	* Drop useless variables

	
drop dup sum_allvars max_length

	
***********************************************************************
* 	PART 11:  autres / miscellaneous adjustments
***********************************************************************
	* correct the response categories for moyen de communication
*replace moyen_com = "site institution gouvernmentale" if moyen_com == "site web d'une autre institution gouvernementale" 
*replace moyen_com = "bulletin d'information giz" if moyen_com == "bulletin d'information de la giz"

	* correct wrong response categories for subsectors
*replace subsector = "industries chimiques" if subsector == "industrie chimique"

***********************************************************************
* 	Save the changes made to the data		  			
***********************************************************************
cd "$bl_intermediate"
save "bl_inter", replace
