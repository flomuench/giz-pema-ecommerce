

***********************************************************************
* 	PART 4: 	Run do-files for sample population (registered) firms
***********************************************************************
/* --------------------------------------------------------------------
	PART 4.1: Import & raw data
	Requires: 
	Creates: 
----------------------------------------------------------------------*/		
if (1) do "${samp_github}/reg_import.do"

/* --------------------------------------------------------------------
	PART 4.2: Clean raw data & save as intermediate data
	NOTE: no observation values are changed
	Requires: 
	Creates: 
----------------------------------------------------------------------*/	
if (1) do "${samp_github}/samp_clean.do"


/* --------------------------------------------------------------------
	PART 4.4: Correct & save intermediate data
	NOTE: observational values are changed, observations are dropped
	Requires: 
	Creates: 
----------------------------------------------------------------------*/	
if (1) do "${samp_github}/samp_correct.do"





/* --------------------------------------------------------------------
	PART 4.4: Generate variables for analysis or implementation
	NOTE: id_email
	Requires: 
	Creates: 
----------------------------------------------------------------------*/	
if (1) do "${samp_github}/samp_generate.do"


/* --------------------------------------------------------------------
	PART 4.5: Stratification
	Requires: 
	Creates: 
----------------------------------------------------------------------*/	
if (1) do "${samp_github}/samp_merge.do"
