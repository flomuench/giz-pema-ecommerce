***********************************************************************
* 			Descriptive Statistics in master file with different survey rounds*					  
***********************************************************************
*																	  
*	PURPOSE: Understand the structure of the data from the different surveyr.					  
*																	  
*	OUTLINE: 	PART 1: Baseline and take-up
*				PART 2: Mid-line	  
*				PART 3: Endline 
*				PART 4: Intertemporal descriptive statistics															
*																	  
*	Author:  	Fabian Scheifele & Kaïs Jomaa							    
*	ID variable: id_platforme		  					  
*	Requires:  	 ecommerce_data_final.dta

										  
***********************************************************************
* 	PART 1: Baseline and take-up statistics
***********************************************************************
use "${master_final}/ecommerce_master_final", clear
		
		* change directory to regis folder for merge with regis_final
cd "${master_gdrive}/output"

*Check whether balance table changed with new z-score calculation
iebaltab fte ihs_exports95 ihs_revenue95 ihs_w95_dig_rev20 ihs_profits compexp_2020 comp_ca2020 exp_pays_avg exporter2020 dig_revenues_ecom ///
comp_benefice2020 knowledge dig_presence_weightedz webindexz social_media_indexz platform_indexz dig_marketing_index facebook_likes ///
  expprep if surveyround==1, grpvar(treatment) ftest save(baltab_baseline) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
	*latex file		 
iebaltab fte ihs_exports95 ihs_revenue95 ihs_w95_dig_rev20 ihs_profits compexp_2020 comp_ca2020 exp_pays_avg exporter2020 dig_revenues_ecom ///
comp_benefice2020 knowledge dig_presence_weightedz webindexz social_media_indexz platform_indexz dig_marketing_index facebook_likes ///
  expprep  if surveyround==1, grpvar(treatment) ftest savetex(baltab_baseline) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev notecombine ///
			 format(%12.2fc)
			 
*correlation matrix of selected variables
correlate compexp_2020 comp_ca2020 exp_pays_avg exporter2020 dig_revenues_ecom comp_benefice2020 knowledge  expprep

*What drives participation
logit take_up i.groupe_factor agri artisanat commerce_int industrie service tic fte ihs_exports95 ihs_revenue95 exp_pays_avg exporter2020 dig_revenues_ecom comp_benefice2020 knowledge  expprep if treatment==1
logit take_up knowledge if treatment==1
* Scatter plot
graph twoway (lfitci take_up knowledge) (scatter take_up knowledge) if treatment ==1

*Frequency tables by subsector
tab take_up subsector if treatment==1
*OBSERVATION: 11 out of the 38 companies that did not show up for at least 3 trainings are from agriculture. 

***********************************************************************
* 	PART 2: Midline Attrition- balance checks
***********************************************************************
	*re-do baseline balance table for midline responders		 
reg treatment fte ihs_exports95 ihs_revenue95 ihs_w95_dig_rev20 ihs_profits exp_pays_avg exporter2020  ///
 knowledge_index dig_presence_weightedz dig_marketing_index facebook_likes ///
  expprep if surveyround==1 & ml_attrit==0 
  
iebaltab fte ihs_exports95 ihs_revenue95 ihs_w95_dig_rev20 ihs_profits exp_pays_avg exporter2020  ///
 knowledge_index dig_presence_weightedz dig_marketing_index facebook_likes ///
  expprep  if surveyround==1 & ml_attrit==0 , grpvar(treatment) savetex(baltab_midline_compliers) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev ///
			 format(%12.2fc) tblnote("Robust standard errors in parentheses." "P-value of joint orthogonality: 0.97") 
			 
  
  *re-do baseline balance table for midline attriters
  reg treatment fte ihs_exports95 ihs_revenue95 ihs_w95_dig_rev20 ihs_profits exp_pays_avg exporter2020  ///
 knowledge_index dig_presence_weightedz dig_marketing_index facebook_likes ///
  expprep if surveyround==1 & ml_attrit==1
  
iebaltab fte ihs_exports95 ihs_revenue95 ihs_w95_dig_rev20 ihs_profits exp_pays_avg exporter2020  ///
 knowledge_index dig_presence_weightedz dig_marketing_index facebook_likes ///
  expprep  if surveyround==1 & ml_attrit==1 , grpvar(treatment) savetex(baltab_midline_compliers) replace ///
			 vce(robust) pttest rowvarlabels balmiss(mean) onerow stdev ///
			 format(%12.2fc) tblnote("Robust standard errors in parentheses." "P-value of joint orthogonality: 0.95") 
			 

 ***********************************************************************
* 	PART 3: Outlier checks
*********************************************************************** 
winsor dom_rev2020, gen(w95_dom_rev2020) p(0.05) highonly 
winsor dom_rev2020, gen(w97_dom_rev2020) p(0.03) highonly 
stripplot w_dom_rev2020 dom_rev2020 w95_dom_rev2020 w97_dom_rev2020
graph export dom_rev2020_outlier.png, replace

* Histogram for Domestic Revenues winsorized 95
twoway (hist w_dom_rev2020, frac lcolor(gs12) fcolor(gs12)) ///
(hist w95_dom_rev2020, frac fcolor(none) lcolor(red)), ///
legend(off) xtitle("Domestic Revenues 99th (red: Domestic Revenues winsorized 95)") 

*Stripplot for export accounting values
stripplot compexp_2020  w99_compexp w97_compexp w95_compexp
graph export compexp_2020_outlier.png, replace

* Histogram for Export Revenues winsorized 95
twoway (hist w99_compexp, frac lcolor(gs12) fcolor(gs12)) ///
(hist w95_compexp, frac fcolor(none) lcolor(red)), ///
legend(off) xtitle("Export Revenues 99 (red: Export Revenues winsorized 95)")  
graph export compexp_2020_hist.png, replace

* Histogram for IHS export 95
twoway (hist ihs_exports99, frac lcolor(gs12) fcolor(gs12)) ///
(hist ihs_exports95, frac fcolor(none) lcolor(red)), ///
legend(off) xtitle("IHS export 99 (red: IHS export 95)")  
graph export ihs_exports95_hist.png, replace

*Stripplot for accounting values
stripplot comp_ca2020  w99_comp_ca2020 w97_comp_ca2020 w95_comp_ca2020
graph export comp_ca2020_outlier.png, replace

* Histogram for Total Revenues winsorized 95
twoway (hist w99_comp_ca2020, frac lcolor(gs12) fcolor(gs12)) ///
(hist w95_comp_ca2020, frac fcolor(none) lcolor(red)), ///
legend(off) xtitle("Total Revenues 99 (red: Total Revenues winsorized 95)")  
graph export comp_ca2020_hist.png, replace

* Histogram for IHS revenue 95
twoway (hist ihs_revenue99, frac lcolor(gs12) fcolor(gs12)) ///
(hist ihs_revenue95, frac fcolor(none) lcolor(red)), ///
legend(off) xtitle("IHS revenue 99 (red: IHS revenue 95)")  
graph export ihs_revenue_hist.png, replace
 
*Stripplot for digital revenues
stripplot dig_revenues_ecom w99_dig_rev20 w97_dig_rev20 w95_dig_rev20
graph export dig_revenue_strip.png, replace

* Histogram for Dig Revenues winsorized 95
twoway (hist w99_dig_rev20, frac lcolor(gs12) fcolor(gs12)) ///
(hist w95_dig_rev20, frac fcolor(none) lcolor(red)), ///
legend(off) xtitle("Dig Revenues 99 (red: Dig Revenues winsorized 95)")  
graph export digrev2020_hist.png, replace

* Histogram for IHS dig revenue 95
twoway (hist ihs_w99_dig_rev20, frac lcolor(gs12) fcolor(gs12)) ///
(hist ihs_w95_dig_rev20, frac fcolor(none) lcolor(red)), ///
legend(off) xtitle("IHS dig revenue 99 (red: IHS dig revenue 95)")  
graph export ihs_digrevenue_hist.png, replace
 
***********************************************************************
*** PDF with graphs  			
***********************************************************************
	* create word document
putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("E-commerce: Baseline Statistics and firm characteristics"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak


putpdf paragraph, halign(center) 


* B2B vs. B2C
graph hbar (count), over(entreprise_model) blabel(total)
graph export b2b.png, replace
putpdf paragraph, halign(center) 
putpdf image b2b.png
putpdf pagebreak
	* Knowledge of digital Z-scores
	
hist knowledge, ///
	title("Zscores of knowledge of digitalisation scores") ///
	xtitle("Zscores")
graph export knowledge_zscores.png, replace
putpdf paragraph, halign(center) 
putpdf image knowledge_zscores.png
putpdf pagebreak

	* For comparison, the 'share' index: 
hist raw_knowledge, ///
	title("Total points on knowledge questions ") ///
	xtitle("Points")
graph export raw_knowledge.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_knowledge.png
putpdf pagebreak


	* Digital Presence
graph hbar (count),  over(dig_presence1) blabel (bar) ///
	title("Number of firms with a website")
graph export dig_presence1.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_presence1.png
putpdf pagebreak

*Number of firms with a social media account
graph hbar (count),  over(dig_presence2) blabel (bar) ///
	title("No. of firms with a social media account")
graph export dig_presence2.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_presence2.png
putpdf pagebreak

*Number of firms present on an online marketplace
graph hbar (count),  over(dig_presence3) blabel (bar) ///
	title("Number of firms present on an online marketplace")
graph export dig_presence3.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_presence3.png
putpdf pagebreak

*Platforms used at baseline
graph hbar (sum)dig_presence3_ex1 dig_presence3_ex2 dig_presence3_ex3 dig_presence3_ex4 dig_presence3_ex5 dig_presence3_ex6 dig_presence3_ex7 dig_presence3_ex8 ,blabel (bar) ///
legend(label(1 "Little Jneina") label(2 "El Fabrica") label(3 "Savana") label(4 "Jumia") label(5 "Amazon") label(6 "Alibaba") label(7 "Etsy") label(8 "Other")) title("Platforms used at baseline")
graph export platforms_used.png, replace
putpdf paragraph, halign(center) 
putpdf image platforms_used.png
putpdf pagebreak

*Description and updating of channel
graph hbar (mean) dig_description1 dig_description2 dig_description3 ///
	dig_miseajour1 dig_miseajour2 dig_miseajour3, blabel (bar) ///
legend(pos(9) cols(1) label(1 "1:Website desc.") label(2 "Social media desc.") label(3 "Platform desc.") label(4 "Website updating") label(5 "Social media updating") label(6 "Platform updating")) ///
title("Description and updating of channel") subtitle ("1= product and firm description, 0.5 product or firm desc. 0.75=weekly update, 0.5=monthly, 0.25=annually", size(vsmall))
graph export description_updates.png, replace
putpdf paragraph, halign(center) 
putpdf image description_updates.png
putpdf pagebreak

*Website: paying and ordering online
graph hbar (count), over(dig_payment1) blabel (bar) ///
	title("Website: paying and ordering online") ///
	subtitle("1=paying and ordering, 0.5=ordering only")
graph export dig_payment1.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_payment1.png
putpdf pagebreak

*Social Media: paying and ordering online
graph hbar (count), over(dig_payment2) blabel (bar) ///
 title("Social Media: paying and ordering online") ///
 subtitle("1=paying and ordering, 0.5=ordering only")
graph export dig_payment2.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_payment2.png
putpdf pagebreak

*Platform: paying and ordering online
graph hbar (count), over(dig_payment3) blabel (bar) ///
title("Platform: paying and ordering online") subtitle("1=paying and ordering, 0.5=ordering only")
graph export dig_payment3.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_payment3.png
putpdf pagebreak

*Histogram of the weighted z-score: Online presence
hist dig_presence_weightedz, ///
title("Weighted z-score: Online presence") 
graph export dig_presence_weightedz.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_presence_weightedz.png
putpdf pagebreak

*Histogram of the z-score: Web presence
hist webindexz, ///
title("z-score: Web presence") 
graph export webindexz.png, replace
putpdf paragraph, halign(center) 
putpdf image webindexz.png
putpdf pagebreak

*Histogram of the share of web presence
hist web_share, ///
title("Share of Web presence") 
graph export web_share.png, replace
putpdf paragraph, halign(center) 
putpdf image web_share.png
putpdf pagebreak

*Histogram of the z-score: Social media presence
hist social_media_indexz, ///
title("z-score: Social media presence") 
graph export social_media_indexz.png, replace
putpdf paragraph, halign(center) 
putpdf image social_media_indexz.png
putpdf pagebreak

*Histogram of the share of social media presence
hist social_m_share, ///
title("Share of Social media presence") 
graph export social_m_share.png, replace
putpdf paragraph, halign(center) 
putpdf image social_m_share.png
putpdf pagebreak

*Histogram of the z-score: Platform presence
hist platform_indexz, ///
title("z-score: Platform presence") 
graph export platform_indexz.png, replace
putpdf paragraph, halign(center) 
putpdf image platform_indexz.png
putpdf pagebreak

hist platform_share, ///
title("z-score: Platform presence") 
graph export platform_share.png, replace
putpdf paragraph, halign(center) 
putpdf image platform_share.png
putpdf pagebreak

*Number of companies that have sold online in 2021
graph hbar (count), over(dig_vente) blabel(total) ///
title("Number of companies that have sold online in 2021")
graph export dig_vente.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_vente.png
putpdf pagebreak

*Digital Marketing
graph hbar (sum) dig_marketing_num19_autre dig_marketing_num19_blg ///
 dig_marketing_num19_mail dig_marketing_num19_prtn ///
 dig_marketing_num19_pub dig_marketing_num19_sea dig_marketing_num19_seo ///
 dig_marketing_num19_socm, blabel (bar) ///
legend(pos(9) cols(1) label(1 "1: Other") label(2 "2:Blog") label(3 "3: Mail") label(4 "4: Partnership w/ firm") label(5 "5:Ads") ///
label(6 "6: SEA")label(7 "7: SEO") label(8 "8: Social Media")) ///
title("Digital Marketing Activities, no. of firms")

graph hbar (count) , over(dig_marketing_respons_bin) blabel (bar) ///
legend(pos(6) cols(1) label(1 "1: Yes") label(2 "2:No"))  ///
title("Does the company have a digital marketing employee?")

graph hbar (count) , over(dig_service_responsable_bin) blabel (bar) ///
legend(pos(6) cols(1) label(1 "1: Yes") label(2 "2:No"))  ///
title("Does the company have someone that manages online orders?")

hist dig_marketing_index, ///
	title("Average of Z-scores: Digital marketing practices") ///
	xtitle("Zscores")
graph export dig_marketing_index.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_marketing_index.png
putpdf pagebreak

	* For comparison, the shares: 
hist dig_marketing_share, ///
	title("Share of digital marketing practices") ///
	xtitle("Sum")
graph export dig_marketing_share.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_marketing_share.png
putpdf pagebreak

	* Export preparation Z-scores
hist expprep, ///
	title("Zscores of export preparation questions") ///
	xtitle("Zscores")
graph export expprep_zscores.png, replace
putpdf paragraph, halign(center) 
putpdf image expprep_zscores.png
putpdf pagebreak
	
	* For comparison, the 'raw' index:
hist raw_expprep, ///
	title("Raw sum of all export preparation questions") ///
	xtitle("Sum")
graph export raw_expprep.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_expprep.png
putpdf pagebreak


*Scatter plot comparing exports and Chiffre d'affaire (0,44 correlation there are 5 firms with high CA and little or no exports)
corr compexp_2020 comp_ca2020
local corr : di %4.3f r(rho)
twoway scatter compexp_2020 comp_ca2020  || lfit compexp_2020 comp_ca2020, ytitle("Exports in TND") xtitle("Revenue in TND") subtitle(correlation `corr')
graph export raw_exp_ca.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_exp_ca.png
putpdf pagebreak
correlate compexp_2020 comp_ca2020 knowledge   

*Scatter plot comparing knowledge and digitalisation index
corr knowledge 
local corr : di %4.3f r(rho)
twoway scatter knowledge dig_presence_weightedz  || lfit knowledge dig_presence_weightedz , ytitle("Knowledge index raw") xtitle("Digitilisation Index raw") subtitle(correlation `corr')
graph export raw_knowledge_digital.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_knowledge_digital.png
putpdf pagebreak

*Scatter plot exports and employees
corr compexp_2020 fte
local corr : di %4.3f r(rho)
twoway scatter compexp_2020 fte  || lfit compexp_2020 fte, ytitle("Exports") xtitle("Number of employes") subtitle(correlation `corr')
graph export raw_exp_fte.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_exp_fte.png
putpdf pagebreak

*Scatter plot revenues and employees
corr comp_ca2020 fte
local corr : di %4.3f r(rho)
twoway scatter comp_ca2020 fte  || lfit comp_ca2020 fte, ytitle("Total Revenues") xtitle("Number of employes") subtitle(correlation `corr')
graph export raw_ca_fte.png, replace
putpdf paragraph, halign(center) 
putpdf image raw_ca_fte.png
putpdf pagebreak

***********************************************************************
* 	PART 3:  Who are the digitally advanced firms? 
***********************************************************************
* Number of firms by sectors & subsectors
graph hbar (count), over(subsector, sort(1) descending label(labs(vsmall))) blabel(bar) ///
 title("Number of firms by subsector")
graph export count_subsector.png, replace
graph hbar (count), over(sector, sort(1) descending label(labs(vsmall))) blabel(bar) ///
 title("Number of firms by sector")
graph export count_sector.png, replace
putpdf paragraph, halign(center) 
putpdf image count_subsector.png
putpdf paragraph, halign(center) 
putpdf image count_sector.png
putpdf pagebreak

*Z-score & share of online presence (web, social media, plateform)
graph hbar dig_presence_weightedz, over(sector) blabel (bar) ///
	title("Weighted Z-score index of online presence") 
graph export dig_presence_weightedz_sector.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_presence_weightedz_sector.png
putpdf pagebreak

graph hbar dig_presence_weightedz, over(subsector) blabel (bar) ///
	title("Weighted Z-score index of online presence") ///
	subtitle("Subsectors")
graph export dig_presence_weightedz_sector.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_presence_weightedz_sector.png
putpdf pagebreak

graph hbar webindexz, over(sector) blabel (bar) ///
	title("Z-score index of web presence") 
graph export webindexz_sector.png, replace
putpdf paragraph, halign(center) 
putpdf image webindexz_sector.png
putpdf pagebreak

graph hbar web_share, over(sector) blabel (bar) ///
	title("Web presence score in %") 
graph export web_share_sector.png, replace
putpdf paragraph, halign(center) 
putpdf image web_share_sector.png
putpdf pagebreak

graph hbar social_media_indexz, over(sector) blabel (bar) ///
	title("Z-score index of social media presence") 
graph export social_media_indexz_sector.png, replace
putpdf paragraph, halign(center) 
putpdf image webindexz_sector.png
putpdf pagebreak

graph hbar social_m_share, over(sector) blabel (bar) ///
	title("Social media score in %") 
graph export web_share_sector.png, replace
putpdf paragraph, halign(center) 
putpdf image web_share_sector.png
putpdf pagebreak

graph hbar platform_indexz, over(sector) blabel (bar) ///
	title("Z-score index of platform presence") 
graph export platform_indexz_sector.png, replace
putpdf paragraph, halign(center) 
putpdf image platform_indexz_sector.png
putpdf pagebreak

graph hbar platform_share, over(sector) blabel (bar) ///
	title("Platform presence score in %") 
graph export platform_share_sector.png, replace
putpdf paragraph, halign(center) 
putpdf image platform_share_sector.png
putpdf pagebreak

* Descriptive statistics on export preparation
graph hbar (count), over(expprep_cible) blabel(bar) ///
	title("Number of firms that have done (1) or plan(0.5) an export market analysis", size(small))
graph export expprep_cible.png, replace
putpdf paragraph, halign(center) 
putpdf image expprep_cible.png
putpdf pagebreak

graph hbar (count), over(expprep_norme) blabel(bar) ///
	title("Number of firms that have a quality certificate", size(small))
graph export expprep_norme.png, replace
putpdf paragraph, halign(center) 
putpdf image expprep_norme.png
putpdf pagebreak

graph hbar (count), over(expprep_demande) blabel(bar) ///
	title("Number of firms that can meet extra demand", size(small))
graph export expprep_demande.png, replace
putpdf paragraph, halign(center) 
putpdf image expprep_demande.png
putpdf pagebreak

graph hbar (count), over(expprep_responsable_bin) blabel(bar) ///
	title("Number of firms with export employee", size(small))
graph export expprep_responsable_bin.png, replace
putpdf paragraph, halign(center) 
putpdf image expprep_responsable_bin.png
putpdf pagebreak

stripplot expprep_responsable if expprep_responsable<50 , ///
	title("Distribution of export employees numbers", size(small))
graph export exprep_responsable_hist.png, replace
putpdf paragraph, halign(center) 
putpdf image exprep_responsable_hist.png
putpdf pagebreak

hist expprep
graph export expprep.png, replace
putpdf paragraph, halign(center) 
putpdf image expprep.png
putpdf pagebreak

putpdf save "baseline_statistics", replace

***********************************************************************
* 	PART 4:  Mdiline statistics vs. Baseline
***********************************************************************

	* create word document
putpdf clear
putpdf begin 
putpdf paragraph
putpdf text ("E-commerce: Midline Statistics"), bold linebreak
putpdf text ("Date: `c(current_date)'"), bold linebreak
putpdf paragraph, halign(center) 


	* Digital Presence
graph bar (count) dig_presence1 if dig_presence1== 0.33 , over(treatment, label(labs(small))) over(surveyround, label(labs(vsmall))) ///
	title("Number of firms with a website") ///
	blabel(total, format(%9.2fc)) ///
	ytitle("Nombre d'entreprise") 
gr export dig_presence1_ml.png, replace

graph bar (count) if dig_presence2== 0.33, over(treatment, label(labs(small))) over(surveyround, label(labs(vsmall))) ///
	title("Number of firms with a social media account") ///
	blabel(total, format(%9.2fc)) ///
	ytitle("Nombre d'entreprise")
gr export dig_presence2_ml.png, replace

graph bar (count) if dig_presence3== 0.33, over(treatment, label(labs(small))) over(surveyround, label(labs(vsmall))) ///
	title("Number of firms present on an online marketplace") ///
	blabel(total, format(%9.2fc)) ///
	ytitle("Nombre d'entreprise")
gr export dig_presence3_ml.png, replace

graph hbar web_share, over(treatment, label(labs(small))) over(surveyround, label(labs(small))) blabel (bar) ///
	title("Web presence score in %") 
graph export web_share_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image web_share_ml.png
putpdf pagebreak

graph hbar social_m_share, over(treatment, label(labs(small))) over(surveyround, label(labs(small))) blabel (bar) ///
	title("Social media score in %") 
graph export web_share_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image web_share_ml.png
putpdf pagebreak

graph hbar platform_share, over(treatment, label(labs(small))) over(surveyround, label(labs(small))) blabel (bar) ///
	title("Platform presence score in %") 
graph export platform_share_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image platform_share_ml.png
putpdf pagebreak

*Digital Description
graph bar (mean) dig_description1 dig_description2 dig_description3 ///
	, over(treatment, label(labs(small))) over(surveyround, label(labs(vsmall))) blabel (bar) ///
legend(pos(9) cols(1) label(1 "Website desc.") label(2 "Social media desc.") label(3 "Platform desc.")) ///
title("Description of channel") subtitle ("1 =more than once a week, 0.75 =weekly update, 0.5 =monthly, 0.25 =annually", size(vsmall))
graph export description_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image description_ml.png
putpdf pagebreak


graph bar (mean) dig_miseajour1 dig_miseajour2 dig_miseajour3 ///
	, over(treatment, label(labs(small))) over(surveyround, label(labs(vsmall))) blabel (bar) ///
legend(pos(9) cols(1) label(1 "Website updating") label(2 "Social media updating") label(3 "Platform updating")) ///
title("Updating of channel") subtitle ("1 =more than once a week, 0.75 =weekly update, 0.5 =monthly, 0.25 =annually", size(vsmall))
graph export updating_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image updating_ml.png
putpdf pagebreak

*Digital Payment
graph hbar (count), over(dig_payment1) over(treatment, label(labs(small))) over(surveyround, label(labs(vsmall))) blabel (bar) ///
	title("Website: paying and ordering online") ///
	subtitle("1=paying and ordering, 0.5=ordering only, 0 =None", size(vsmall))
graph export dig_payment1_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_payment1_ml.png
putpdf pagebreak

graph hbar (count), over(dig_payment2) over(treatment, label(labs(small))) over(surveyround, label(labs(vsmall))) blabel (bar) ///
	title("Social media: paying and ordering online") ///
	subtitle("1=paying and ordering, 0.5=ordering only, 0 =None", size(vsmall))
graph export dig_payment2_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_payment2_ml.png
putpdf pagebreak

graph hbar (count), over(dig_payment3) over(treatment, label(labs(small))) over(surveyround, label(labs(vsmall))) blabel (bar) ///
	title("Marketplace: paying and ordering online") ///
	subtitle("1=paying and ordering, 0.5=ordering only, 0 =None", size(vsmall))
graph export dig_payment3_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_payment3_ml.png
putpdf pagebreak


graph hbar (count), over(dig_vente) over(treatment, label(labs(small))) over(surveyround, label(labs(vsmall))) blabel (bar) ///
	title("Number of companies that have sold their product/ service online") ///
	subtitle("0 =Sold nothing online, 1 =Sold product/ service online", size(vsmall))
graph export dig_vente_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_vente_ml.png
putpdf pagebreak


     * variable dig_revenues_ecom:
stripplot dig_revenues_ecom, by(treatment) jitter(4) vertical yline(1000, lcolor(red)) ///
ytitle("Midline: Digital revenues") ///
name(dig_revenues_ecom_ml, replace)
gr export dig_revenues_ecom_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_revenues_ecom_ml.png
putpdf pagebreak 
	
	
*Digital Marketing
graph bar (count) , over(dig_marketing_respons_bin)  over(treatment, label(labs(small))) over(surveyround, label(labs(small))) blabel (bar) ///
legend(pos(6) cols(1) label(1 "1: Yes") label(2 "2:No"))  ///
title("Does the company have a digital marketing employee?") 
graph export dig_marketing_respons_bin_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_marketing_respons_bin_ml.png
putpdf pagebreak

graph hbar (count) , over(dig_service_responsable_bin) over(treatment, label(labs(small))) over(surveyround, label(labs(small))) blabel (bar) ///
legend(pos(6) cols(1) label(1 "1: Yes") label(2 "2:No"))  ///
title("Does the company have someone that manages online orders?")
graph export dig_service_responsable_bin_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_service_responsable_bin_ml.png
putpdf pagebreak


*ssa_action practices

graph bar (count) , over(ssa_action1) over(treatment, label(labs(small))) blabel (bar) ///
title("Midline: Expression of interest by a potential buyer in Sub-Saharan Africa country")
graph export ssa_action1.png, replace
putpdf paragraph, halign(center) 
putpdf image ssa_action1.png
putpdf pagebreak

graph bar (count) , over(ssa_action2) over(treatment, label(labs(small))) blabel (bar) ///
title("Midline: Identification of a business partner in Sub-Saharan Africa country")
graph export ssa_action2.png, replace
putpdf paragraph, halign(center) 
putpdf image ssa_action2.png
putpdf pagebreak

graph bar (count) , over(ssa_action3) over(treatment, label(labs(small))) blabel (bar) ///
title("Midline: Commitment of external financing for preliminary export costs")
graph export ssa_action3.png, replace
putpdf paragraph, halign(center) 
putpdf image ssa_action3.png
putpdf pagebreak

graph bar (count) , over(ssa_action4) over(treatment, label(labs(small))) blabel (bar) ///
title("Midline: Investment in sales structure in a target market in Sub-Saharan Africa")
graph export ssa_action4.png, replace
putpdf paragraph, halign(center) 
putpdf image ssa_action4.png
putpdf pagebreak

graph bar (count) , over(ssa_action5) over(treatment, label(labs(small))) blabel (bar) ///
title("Midline: Introduction of a trade facilitation system, digital innovation")
graph export ssa_action5.png, replace
putpdf paragraph, halign(center) 
putpdf image ssa_action5.png
putpdf pagebreak

* Number of employees in the midline
    * variable employees
stripplot fte if surveyround == 2, by(treatment) jitter(4) vertical yline(22, lcolor(red)) ///
		ytitle("Midline: Number of employees") ///
		name(fte, replace)
    gr export empl_ml.png, replace
	putpdf paragraph, halign(center) 
	putpdf image empl_ml.png
	putpdf pagebreak
	
stripplot car_carempl_div1  if surveyround == 2, by(treatment) jitter(4) vertical yline(9, lcolor(red)) ///
		ytitle("Midline: Number of female employees") ///
		name(fte, replace)
    gr export fem_empl_ml.png, replace
	putpdf paragraph, halign(center) 
	putpdf image fem_empl_ml.png
	putpdf pagebreak

stripplot car_carempl_div2  if surveyround == 2, by(treatment) jitter(4) vertical yline(5, lcolor(red)) ///
		ytitle("Midline: Number of young employees") ///
		name(fte, replace)
    gr export you_empl_ml.png, replace
	putpdf paragraph, halign(center) 
	putpdf image you_empl_ml.png
	putpdf pagebreak
	
stripplot car_carempl_div3  if surveyround == 2, by(treatment) jitter(4) vertical yline(2, lcolor(red)) ///
		ytitle("Midline: Number of part time employees") ///
		name(fte, replace)
    gr export pt_empl_ml.png, replace
	putpdf paragraph, halign(center) 
	putpdf image pt_empl_ml.png
	putpdf pagebreak	
	
stripplot car_carempl_div4  if surveyround == 2, by(treatment) jitter(4) vertical yline(3, lcolor(red)) ///
		ytitle("Midline: Number of part foreign employees") ///
		name(fte, replace)
    gr export fg_empl_ml.png, replace
	putpdf paragraph, halign(center) 
	putpdf image fg_empl_ml.png
	putpdf pagebreak	
	
stripplot car_carempl_div5  if surveyround == 2, by(treatment) jitter(4) vertical yline(2, lcolor(red)) ///
		ytitle("Midline: Number of part expatriate employees") ///
		name(fte, replace)
    gr export expt_empl_ml.png, replace
	putpdf paragraph, halign(center) 
	putpdf image expt_empl_ml.png
	putpdf pagebreak	
		
	
putpdf save "midline_statistics", replace
***********************************************************************
* 	PART 4:  Mdiline Indexes
***********************************************************************

putpdf clear
putpdf begin 
putpdf paragraph

putpdf text ("E-commerce: Midline Indexes"), bold linebreak

putpdf text ("Date: `c(current_date)'"), bold linebreak


putpdf paragraph, halign(center) 

* Midline Knowledge Index
gr tw ///
	(kdensity knowledge_index if treatment == 1 & take_up == 1 & surveyround == 2, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram knowledge_index if treatment == 1 & take_up == 1 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity knowledge_index if treatment == 1 & take_up == 0 & surveyround == 2, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram knowledge_index if treatment == 1 & take_up == 0 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity knowledge_index if treatment == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram knowledge_index if treatment == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Midline Distribution of Knowledge Index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Knowledge index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated (N=77 firms)" ///
                     2 "Treatment group, absent (N=40 firms)" ///
					 3 "Control group (N=119 firms)") ///
               c(1) pos(6) ring(6)) ///
	name(knowledge_index, replace)
graph export knowledge_index.png, replace
putpdf paragraph, halign(center) 
putpdf image knowledge_index.png
putpdf pagebreak

* Midline Digital Marketing index
gr tw ///
	(kdensity dig_marketing_index if treatment == 1 & take_up == 1 & surveyround == 2, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dig_marketing_index if treatment == 1 & take_up == 1 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dig_marketing_index if treatment == 1 & take_up == 0 & surveyround == 2, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram dig_marketing_index if treatment == 1 & take_up == 0 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity dig_marketing_index if treatment == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dig_marketing_index if treatment == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Midline Distribution of Digital Marketing Index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Digital Marketing Index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated (N=77 firms)" ///
                     2 "Treatment group, absent (N=40 firms)" ///
					 3 "Control group (N=119 firms)") ///
               c(1) pos(6) ring(6)) ///
	name(dig_marketing_index_ml, replace)
graph export dig_marketing_index_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_marketing_index_ml.png
putpdf pagebreak

* Midline Perception index
gr tw ///
	(kdensity perception_index_ml if treatment == 1 & take_up == 1 & surveyround == 2, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram perception_index_ml if treatment == 1 & take_up == 1 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity perception_index_ml if treatment == 1 & take_up == 0 & surveyround == 2, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram perception_index_ml if treatment == 1 & take_up == 0 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity perception_index_ml if treatment == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram perception_index_ml if treatment == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Midline Distribution of Digital Marketing Perception Index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Digital Marketing Perception Index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated (N=77 firms)" ///
                     2 "Treatment group, absent (N=40 firms)" ///
					 3 "Control group (N=119 firms)") ///
               c(1) pos(6) ring(6)) ///
	name(perception_index_ml, replace)
graph export perception_index_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image perception_index_ml.png
putpdf pagebreak

* Midline Digital Presence index
gr tw ///
	(kdensity dig_presence_index if treatment == 1 & take_up == 1 & surveyround == 2, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dig_presence_index if treatment == 1 & take_up == 1 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dig_presence_index if treatment == 1 & take_up == 0 & surveyround == 2, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram dig_presence_index if treatment == 1 & take_up == 0 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity dig_presence_index if treatment == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dig_presence_index if treatment == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Midline Distribution of Digital Presence Index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Digital Presence Index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated (N=77 firms)" ///
                     2 "Treatment group, absent (N=40 firms)" ///
					 3 "Control group (N=119 firms)") ///
               c(1) pos(6) ring(6)) ///
	name(dig_presence_index, replace)
graph export dig_presence_index.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_presence_index.png
putpdf pagebreak


gr tw ///
	(kdensity dig_presence_weightedz if treatment == 1 & take_up == 1 & surveyround == 2, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram dig_presence_weightedz if treatment == 1 & take_up == 1 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity dig_presence_weightedz if treatment == 1 & take_up == 0 & surveyround == 2, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram dig_presence_weightedz if treatment == 1 & take_up == 0 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity dig_presence_weightedz if treatment == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram dig_presence_weightedz if treatment == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Midline Weighted e-commerce presence}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Weighted e-commerce presence index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(vsmall) ///
               order(1 "Treatment group, participated (N=77 firms)" ///
                     2 "Treatment group, absent (N=40 firms)" ///
					 3 "Control group (N=119 firms)") ///
               c(1) pos(6) ring(6)) ///
	name(dig_presence_weightedz_ml, replace)
graph export dig_presence_weightedz_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image dig_presence_weightedz_ml.png
putpdf pagebreak

* Midline Web index
gr tw ///
	(kdensity webindexz if treatment == 1 & take_up == 1 & surveyround == 2, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram webindexz if treatment == 1 & take_up == 1 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity webindexz if treatment == 1 & take_up == 0 & surveyround == 2, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram webindexz if treatment == 1 & take_up == 0 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity webindexz if treatment == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram webindexz if treatment == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Midline Web Presence index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Web Presence index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated (N=77 firms)" ///
                     2 "Treatment group, absent (N=40 firms)" ///
					 3 "Control group (N=119 firms)") ///
               c(1) pos(6) ring(6)) ///
	name(webindexz_ml, replace)
graph export webindexz_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image webindexz_ml.png
putpdf pagebreak

* Midline Social media index
gr tw ///
	(kdensity social_media_indexz if treatment == 1 & take_up == 1 & surveyround == 2, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram social_media_indexz if treatment == 1 & take_up == 1 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity social_media_indexz if treatment == 1 & take_up == 0 & surveyround == 2, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram social_media_indexz if treatment == 1 & take_up == 0 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity social_media_indexz if treatment == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram social_media_indexz if treatment == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Midline Social Media index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Social Media index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated (N=77 firms)" ///
                     2 "Treatment group, absent (N=40 firms)" ///
					 3 "Control group (N=119 firms)") ///
               c(1) pos(6) ring(6)) ///
	name(social_media_indexz_ml, replace)
graph export social_media_indexz_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image social_media_indexz_ml.png
putpdf pagebreak

* Midline Platform index
gr tw ///
	(kdensity platform_indexz if treatment == 1 & take_up == 1 & surveyround == 2, lp(l) lc(maroon) yaxis(2) bw(0.4)) ///
	(histogram platform_indexz if treatment == 1 & take_up == 1 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(maroon)) ///
	(kdensity platform_indexz if treatment == 1 & take_up == 0 & surveyround == 2, lp(l) lc(green) yaxis(2) bw(0.4)) ///
	(histogram platform_indexz if treatment == 1 & take_up == 0 & surveyround == 2, freq w(.1) recast(scatter) msize(small) mc(green)) ///
	(kdensity platform_indexz if treatment == 0, lp(l) lc(navy) yaxis(2) bw(0.4)) ///
	(histogram platform_indexz if treatment == 0, freq w(.1) recast(scatter) msize(small) mc(navy)) ///
	, ///
	title("{bf:Midline Plateform index}") ///
	subtitle("{it:Index calculated based on z-score method}") ///
	xtitle("Plateform index") ///
	ytitle("Number of observations", axis(1)) ///
	ytitle("Densitiy", axis(2)) ///
	legend(rows(3) symxsize(small) ///
               order(1 "Treatment group, participated (N=77 firms)" ///
                     2 "Treatment group, absent (N=40 firms)" ///
					 3 "Control group (N=119 firms)") ///
               c(1) pos(6) ring(6)) ///
	name(platform_indexz_ml, replace)
graph export platform_indexz_ml.png, replace
putpdf paragraph, halign(center) 
putpdf image platform_indexz_ml.png
putpdf pagebreak

putpdf save "midline_index_statistics", replace


***********************************************************************
* 	PART 3:  Additional explorations based on regressions
***********************************************************************
set scheme burd
cd "${master_gdrive}/output/key_graphs"

* Correlation between knowledge index & age
corr rg_age knowledge_index if surveyround==2  
local corr : di %4.3f r(rho)
twoway scatter rg_age knowledge_index if surveyround==2  || lfit rg_age knowledge_index if surveyround==2 , ytitle("Firm age in years") xtitle("Knowledge index (z-score)") subtitle(correlation `corr')

corr ihs_w95_dig_rev20 knowledge_index if surveyround==2  
local corr : di %4.3f r(rho)
twoway scatter ihs_w95_dig_rev20 knowledge_index if surveyround==2  || lfit ihs_w95_dig_rev20 knowledge_index if surveyround==2 , ytitle("IHS of E-commerce revenues 2022") xtitle("Knowledge index (z-score)") subtitle(correlation `corr')


* Distribution of knowledge index
collapse (mean) knowledge_index, by(surveyround treatment)
twoway (connected knowledge_index surveyround if treatment==1) (connected knowledge_index surveyround if treatment==0), xline(1.5) xlabel (1(1)2) legend(label(1 Treated) label(2 Control) )
graph export did_plot1.png, replace
 

* Distribution of digital revenues
collapse (mean) dig_revenues_ecom, by(surveyround treatment)
twoway (connected dig_revenues_ecom surveyround if treatment==1) (connected dig_revenues_ecom surveyround if treatment==0), xline(1.5) xlabel (1(1)2) legend(label(1 Treated) label(2 Control))
graph export did_plot2.png, replace
 

graph bar (mean) knowledge_index if surveyround==2, over(treatment, label(labs(vsmall))) over(sector, label(labs(vsmall))) ///
	title("Knowledge Index by sector") ///
	blabel(total, format(%9.2fc) size(vsmall)) ///
	ytitle("Average z-score") 
graph export k_index_sector.png, replace

* Knowledge questions distributions: distributuion, correlation
graph bar (mean) dig_con1_ml if surveyround==2, over(take_up, label(labs(small))) over(treatment, label(labs(vsmall))) ///
	title("Knowledge of means of online payment") ///
	blabel(total, format(%9.2fc)) ///
	ytitle("Sum of points") 
graph export dig_con1.png, replace

graph bar (mean) dig_con2_ml if surveyround==2, over(take_up, label(labs(small))) over(treatment, label(labs(vsmall))) ///
	title("What chararizes good digital content") ///
	blabel(total, format(%9.2fc)) ///
	ytitle("Sum of points") 
graph export dig_con2.png, replace

graph bar (mean) dig_con3_ml if surveyround==2, over(take_up, label(labs(small))) over(treatment, label(labs(vsmall))) ///
	title("What information can be found on google analytics") ///
	blabel(total, format(%9.2fc)) ///
	ytitle("Sum of points") 
graph export dig_con3.png, replace

graph bar (mean) dig_con4_ml if surveyround==2, over(take_up, label(labs(small))) over(treatment, label(labs(vsmall))) ///
	title("What are the components of the engagement rate indicator?") ///
	blabel(total, format(%9.2fc)) ///
	ytitle(Sum of points") 
graph export dig_con4.png, replace
	
graph bar (mean) dig_con5_ml if surveyround==2, over(take_up, label(labs(small))) over(treatment, label(labs(vsmall))) ///
	title("Which of the following are techniques used in SEO?") ///
	blabel(total, format(%9.2fc)) ///
	ytitle("Sum of points") 
graph export dig_con5.png, replace

graph bar (mean) dig_con1_ml dig_con2_ml dig_con3_ml dig_con4_ml dig_con5_ml if surveyround==2, over(status, label(labs(vsmall))) ///
	blabel(total, format(%9.2fc) size(vsmall)) ///
	ytitle("Sum of points") ///
	legend(pos (6) label(1 "Q1") label(2 "Q2") label(3 "Q3") label(4 "Q4") label(5 "Q5"))
graph export knowledge_decomp.png, replace

corr present knowledge_index if surveyround==2  & treatment==1
local corr : di %4.3f r(rho)
twoway scatter present knowledge_index if treatment==1 &  surveyround==2  || lfit present knowledge_index if treatment==1 & surveyround==2 , ytitle("No. of times visited workshop") xtitle("Knowledge index (z-score)") title("Correlation between presence and knowledge absorption") subtitle(correlation `corr')
graph export corr_presence1.png, replace

corr present knowledge_index if surveyround==2  & present>2
local corr : di %4.3f r(rho)
twoway scatter present knowledge_index if present>2 &  surveyround==2  || lfit present knowledge_index if present>2 & surveyround==2 , ytitle("No. of times visited workshop") xtitle("Knowledge index (z-score)") title("Correlation between presence and knowledge absorption") subtitle(correlation `corr')
graph export corr_presence2.png, replace

corr present knowledge_index if surveyround==2 
local corr : di %4.3f r(rho)
twoway scatter present knowledge_index if present>2 &  surveyround==2  || lfit present knowledge_index if present>2 & surveyround==2 , ytitle("No. of times visited workshop") xtitle("Knowledge index (z-score)") title("Correlation between presence and knowledge absorption") subtitle(correlation `corr')
graph export corr_presence2.png, replace

bysort id_plateforme (surveyround): replace ihs_revenue95 = ihs_revenue95[_n-1] /// 
	if ihs_revenue95 == .
corr present ihs_revenue95 knowledge_index if surveyround==2 
local corr : di %4.3f r(rho)
twoway scatter ihs_revenue95 knowledge_index if surveyround==2  || lfit ihs_revenue95 knowledge_index if surveyround==2 , ytitle("IHS Total Revenue") xtitle("Knowledge index (z-score)") title("Correlation between sales and knowledge absorption") subtitle(correlation `corr')
graph export corr_sales_knowledge.png, replace
replace ihs_revenue95=. if surveyround==2


***********************************************************************
* 	PART 4:  Graphs for the GIZ presentations
***********************************************************************
set scheme burd

cd "${master_gdrive}/output/GIZ_presentation_graphs"

	*Reponse Rate
catplot ml_attrit surveyround treatment if surveyround==2, percent(treatment) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(base) size(4) format(%3.1f)) ylabel(, angle(h)) recast(bar) /// 
	title("Response Rate Midline", size(small)) ///
	ytitle("%") ///
	legend(pos (6) label(1 "Responded") label(2 "Did not respond") ) 
graph export repondu_ml.png, replace

catplot bl_attrit surveyround treatment if surveyround==1, percent(treatment) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(base) size(4) format(%3.1f)) ylabel(, angle(h)) recast(bar) ///
	title("Response Rate Baseline", size(small)) ///
	ytitle("%") ///
	legend(pos (6) label(1 "Responded") label(2 "Did not respond") ) 
graph export repondu_bl.png, replace

*****ONLINE PRESENCE*****************
	* Digital Presence
catplot dig_presence1 surveyround treatment, percent(treatment surveyround) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(base) size(4) format(%3.1f)) ylabel(, angle(h)) recast(bar) /// 
	title("% of firms with a website") ///
	legend(pos (6) label(1 "No website") label(2 "Has Website") ) ///
	blabel(bar, format(%9.0fc)) 
gr export dig_presence1.png, replace
	 
catplot dig_presence2 surveyround treatment, percent(treatment surveyround) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(base) size(4) format(%3.0f)) ylabel(, angle(h)) recast(bar) /// 
	title("% of firms with a social media account") ///
	legend(pos (6) label(1 "No social media") label(2 "Has social media") ) ///
	blabel(bar, format(%9.0fc)) 
gr export dig_presence2.png, replace

*please change in ml_correct later
replace dig_presence3=0.33 if id_plateforme==324 & surveyround==2
catplot dig_presence3 surveyround treatment, percent(treatment surveyround) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(base) size(4) format(%3.1f)) ylabel(, angle(h)) recast(bar) /// 
	title("% of firms with a marketplace") ///
	legend(pos (6) label(1 "No marketplace") label(2 "Has marketplace account") ) ///
	blabel(bar, format(%9.0fc)) 
gr export dig_presence3.png, replace

*website updating
catplot dig_miseajour1 surveyround treatment, percent(treatment surveyround) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(center) size(3) format(%3.1f)) ylabel(, angle(h)) recast(bar) /// 
	title("Website updating") ///
	legend(pos (6) label(1 "Never") label(2 "Annually")  label(3 "Monthly")  label(4 "Weekly")  label(5 "More than weekly")) ///
	blabel(bar, format(%9.0fc)) 
gr export dig_miseajour1.png, replace
	
catplot dig_miseajour2 surveyround treatment, percent(treatment surveyround) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(center) size(3) format(%3.1f)) ylabel(, angle(h)) recast(bar) /// 
	title("Social media updating") ///
	legend(pos (6) label(1 "Never") label(2 "Annually")  label(3 "Monthly")  label(4 "Weekly")  label(5 "More than weekly")) ///
	blabel(bar, format(%9.0fc)) 
gr export dig_miseajour2.png, replace

*Sold Product online or not
catplot dig_vente  surveyround treatment, percent(treatment surveyround) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(base) size(4) format(%3.1f)) ylabel(, angle(h)) recast(bar) ///
	legend(pos (6) label(1 "Neither ordering nor paying")  label(2 "Only ordering")  label(3 "Paying and ordering")) ///
	title("% of companies that have sold their product/ service online",size(medium)) ///
	legend(pos (6) label(1 "Sold nothing online") label(2 "Sold product/ service online")) 
	
graph export dig_vente_ml.png, replace

*Paying & Ordering online
catplot dig_payment1 surveyround treatment, percent(treatment surveyround) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(base) size(4) format(%3.1f)) ylabel(, angle(h)) recast(bar) ///
	legend(pos (6) label(1 "Neither ordering nor paying")  label(2 "Only ordering")  label(3 "Paying and ordering")) /// 
	title("Ordering and paying on website")
graph export dig_payment1.png, replace

catplot dig_payment2  surveyround treatment, percent(treatment surveyround) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(base) size(4) format(%3.1f)) ylabel(, angle(h)) recast(bar) ///
	legend(pos (6) label(1 "Neither ordering nor paying")  label(2 "Only ordering")  label(3 "Paying and ordering")) /// 
	title("Ordering and paying on social media")
graph export dig_payment2.png, replace


*****DIGITAL MARKETING PRACTICES**************************
catplot dig_marketing_ind1  surveyround treatment, percent(treatment surveyround) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(base) size(4) format(%3.0f)) ylabel(, angle(h)) recast(bar) ///
	legend(pos (6) label(1 "No")  label(2 "Yes") ) ///
	title("Presence of digital marketing indicators")
graph export dig_marketing_ind1.png, replace 

catplot dig_service_satisfaction  surveyround treatment, percent(treatment surveyround) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(base) size(4) format(%3.0f)) ylabel(, angle(h)) recast(bar) ///
	legend(pos (6) label(1 "No")  label(2 "Yes") ) ///
	title("Do you measure the satisfaction of your online clients?")
graph export dig_service_satisfaction.png, replace

catplot dig_marketing_respons_bin surveyround treatment, percent(treatment surveyround) asyvars stack ///
	bar(1, bcolor(black)) bar(2, bcolor(green)) bar(3,bcolor(blue)) ytitle(%) ///
	 blabel(bar, pos(base) size(4) format(%3.0f)) ylabel(, angle(h)) recast(bar) ///
	legend(pos (6) label(1 "No")  label(2 "Yes") ) ///
	title("Do you have an employee responsible?")
graph export dig_marketing_respons_bin.png, replace

* Generate graphs for perception
graph bar (mean) dig_perception1 dig_perception2 dig_perception3 dig_perception4 dig_perception5 if surveyround==2, over(status, label(labs(vsmall))) ///
	blabel(total, format(%9.2fc) size(vsmall)) ///
	ytitle("1-very easy		 	5-very difficult") ///
	legend(pos (6) label(1 "Analyse SEO data") label(2 "Analyse social media data") label(3 "Use paid ads") label(4 "Sell on marketplace") label(5 "Export more thanks to online")) ///
	title("Perceived Difficulty of e-commerce tasks")
graph export dig_perception.png, replace


* Generate graphs for the knowledge questions
graph bar (mean) dig_con1_ml dig_con2_ml dig_con3_ml dig_con4_ml dig_con5_ml if surveyround==2, over(status, label(labs(vsmall))) ///
	blabel(total, format(%9.2fc) size(vsmall)) ///
	ytitle("Sum of points") ///
	legend(pos (6) label(1 "Means of payment") label(2 "Digital Content") label(3 "Google Analytics") label(4 "Commitment Rate ") label(5 "SEO"))
graph export knowledge_decomp.png, replace


* Generate graphs to see difference of digital revenues between baseline & midline

collapse (mean) dig_revenues_ecom, by(surveyround status)
twoway (connected dig_revenues_ecom surveyround if status==0) (connected dig_revenues_ecom surveyround if status==1) (connected dig_revenues_ecom surveyround if status ==2 ), xline(1.5) xlabel (1(1)2) ytitle("Mean of digital revenues") xtitle("1- Baseline 2- Midline ") legend(label(1 Control) label(2 Absent) label(3 Present)) 
graph export did_plot2_details.png, replace

 
 * Generate graphs to see difference of employment between baseline & midline

*Sum
collapse (sum) fte if fte >= 0, by(surveyround status)
twoway (connected fte surveyround if status==0) (connected fte surveyround if status==1) (connected fte surveyround if status ==2 ), xline(1.5) xlabel (1(1)2) ytitle("Sum of employees") xtitle("1- Baseline 2- Midline ") legend(label(1 Control) label(2 Absent) label(3 Present)) 
graph export fte_details.png, replace

collapse (sum) car_carempl_div1 if car_carempl_div1 >= 0, by(surveyround status)
twoway (connected car_carempl_div1 surveyround if status==0) (connected car_carempl_div1 surveyround if status==1) (connected car_carempl_div1 surveyround if status ==2 ), xline(1.5) xlabel (1(1)2) ytitle("Sum of female employees") xtitle("1- Baseline 2- Midline ") legend(label(1 Control) label(2 Absent) label(3 Present)) 
graph export fte_femmes_details.png, replace
 
collapse (sum) car_carempl_div3 if car_carempl_div3 >= 0, by(surveyround status)
twoway (connected car_carempl_div3 surveyround if status==0) (connected car_carempl_div3 surveyround if status==1) (connected car_carempl_div3 surveyround if status ==2 ), xline(1.5) xlabel (1(1)2) ytitle("Sum of part-time employees") xtitle("1- Baseline 2- Midline ") legend(label(1 Control) label(2 Absent) label(3 Present)) 
graph export pte_details.png, replace

collapse (sum) car_carempl_div2 if car_carempl_div2 >= 0, by(surveyround status)
twoway (connected car_carempl_div2 surveyround if status==0) (connected car_carempl_div2 surveyround if status==1) (connected car_carempl_div2 surveyround if status ==2 ), xline(1.5) xlabel (1(1)2) ytitle("Sum of young employees") xtitle("1- Baseline 2- Midline ") legend(label(1 Control) label(2 Absent) label(3 Present)) 
graph export young_employees_details.png, replace


*Mean
collapse (mean) fte if fte >= 0, by(surveyround status)
twoway (connected fte surveyround if status==0) (connected fte surveyround if status==1) (connected fte surveyround if status ==2 ), xline(1.5) xlabel (1(1)2) ytitle("Mean of employees") xtitle("1- Baseline 2- Midline ") legend(label(1 Control) label(2 Absent) label(3 Present)) 
graph export fte_details.png_mean, replace

collapse (mean) car_carempl_div1 if car_carempl_div1 >= 0, by(surveyround status)
twoway (connected car_carempl_div1 surveyround if status==0) (connected car_carempl_div1 surveyround if status==1) (connected car_carempl_div1 surveyround if status ==2 ), xline(1.5) xlabel (1(1)2) ytitle("Mean of female employees") xtitle("1- Baseline 2- Midline ") legend(label(1 Control) label(2 Absent) label(3 Present)) 
graph export fte_femmes_details_mean.png, replace
 
collapse (mean) car_carempl_div3 if car_carempl_div3 >= 0, by(surveyround status)
twoway (connected car_carempl_div3 surveyround if status==0) (connected car_carempl_div3 surveyround if status==1) (connected car_carempl_div3 surveyround if status ==2 ), xline(1.5) xlabel (1(1)2) ytitle("Mean of part-time employees") xtitle("1- Baseline 2- Midline ") legend(label(1 Control) label(2 Absent) label(3 Present)) 
graph export pte_details_mean.png, replace

collapse (mean) car_carempl_div2 if car_carempl_div2 >= 0, by(surveyround status)
twoway (connected car_carempl_div2 surveyround if status==0) (connected car_carempl_div2 surveyround if status==1) (connected car_carempl_div2 surveyround if status ==2 ), xline(1.5) xlabel (1(1)2) ytitle("Mean of young employees") xtitle("1- Baseline 2- Midline ") legend(label(1 Control) label(2 Absent) label(3 Present)) 
graph export young_employees_details_mean.png, replace

 
	* Midline Digital Revenue distribution
sum dig_revenues_ecom, d
stripplot dig_revenues_ecom if dig_revenues_ecom <5000 , by(treatment surveyround) jitter(4) vertical ///
	ytitle("Midline: Digital revenues") ///
	yline(`r(p50)', lpattern(dash)) ///
	text(`r(p50)'  0.1 "Median", size(vsmall) place(n))
name(dig_revenues_ecom_ml, replace)
gr export dig_revenues_ecom_ml.png, replace

restore




