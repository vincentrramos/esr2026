// ==============================================================================
// Paper:     Labour market insecurity and parental co-residence in the United Kingdom: heterogeneities by parental class and age
// Author:    Vincent Jerald Ramos and Ann Berrington
// Date:      January 2026
// Purpose:   Replication Codes for Figures and Tables in Text
// File:	  1_lfswrangling
// Describe:  create main/master file including new variables
// ==============================================================================


clear all
clear matrix
capture drop _all
capture log close
macro drop _all
capture program drop _all
set more off
set mat 2000
eststo clear
set more off 
set emptycells drop

* Set global paths - USERS MUST UPDATE THIS
global PROJDIR "[PATH_TO_PROJECT_FOLDER]"

* Source data folders
global SOURCE01 "$PROJDIR/data/QLFS_2014_2023_Q3_all"

* Output folders
global WRITE    "$PROJDIR/output/tables"
global GRAPH      "$PROJDIR/output/figures"

* Create output directories if they don't exist
capture mkdir "$PROJDIR/output"
capture mkdir "$WRITE"
capture mkdir "$GRAPH"


// Prepare data
	use "$SOURCE01\lfsp_js24_eul_pwt24.dta", clear
	append using "$SOURCE01\lfsp_js23_eul_pwt24.dta"
	append using "$SOURCE01\lfsp_js22_eul_pwt23.dta"
	append using "$SOURCE01\lfsp_js21_eul_pwt22.dta"
	append using "$SOURCE01\lfsp_js19_eul_pwt18.dta"
	append using "$SOURCE01\lfsp_js18_eul_pwt18.dta"
	append using "$SOURCE01\lfsp_js17_eul_pwt18.dta"
	append using "$SOURCE01\lfsp_js16_eul_pwt18.dta"


// Fix person weights
	gen pwt = .
	replace pwt = PWT24 if PWT24!=.
	replace pwt = PWT23 if PWT23!=.
	replace pwt = PWT22 if PWT22!=.
	replace pwt = PWT18 if PWT18!=.
	label var pwt "Merged person weights"

// Income weights for earnings-related analysis
	gen piwt = .
	replace piwt = PIWT23 if PIWT23!=.
	replace piwt = PIWT22 if PIWT22!=.
	replace piwt = PIWT18 if PIWT18!=.
	label var piwt "Merged person income earnings weights"

// Qualification. Categories from Stone 2011
	gen qual = .
	replace qual=1 if (LEVQUL22>=1 & LEVQUL22<=3) | HIQUL15D==1		// Degree holders
	replace qual=2 if (LEVQUL22>=4 & LEVQUL22<=6) | (HIQUL15D==2 | HIQUL15D==3) 	// Higher + GCE A level + trade
	replace qual=3 if (LEVQUL22>=7 & LEVQUL22<=10) | (HIQUL15D==4 | HIQUL15D==5) 	// Some Secondary
	replace qual=4 if LEVQUL22==11 | HIQUL15D==6 | qual==. 		// include everyone else without quals
	lab var qual "Highest qualification-degree"
	lab def qual 1 "Degree/equivalent" 2 "Upper"  3 "Some Secondary" 4 "None/NA"
	lab val qual qual
	tab qual

// Country of Birth. Categories from Stone 2011
	gen cbirth_cat =.
	replace cbirth_cat=1 if CRYOX7_EUL_Main==1
	replace cbirth_cat=2 if CRYOX7_EUL_Main==2 | CRYOX7_EUL_Main==3
	replace cbirth_cat=3 if CRYOX7_EUL_Main==4
	replace cbirth_cat=4 if CRYOX7_EUL_Main==5
	lab var cbirth_cat "Country of Birth Main Categories"
	lab def cbirth_cat 1 "UK" 2 "Europe" 3 "Asia" 4 "Others"
	lab val cbirth_cat cbirth_cat


// Non-UK Born. Age at Arrival 
	gen age_arrival_UK=AGE-(REFWKY-CAMEYR) if CAMEYR>0
	tab age_arrival_UK  //cases <0 value most likely because of crude estimation, put them as 0 (moved here as a baby)
	replace age_arrival_UK= 0 if age_arrival_UK<0
	tab age_arrival_UK
	lab var age_arrival_UK "Age at arrival to UK"

// Country of Birth. Dummy
	gen cbirth_dum =.
	replace cbirth_dum=1 if CRYOX7_EUL_Main==1
	replace cbirth_dum=0 if CRYOX7_EUL_Main>1
	replace cbirth_dum=1 if cbirth_dum==0 & age_arrival_UK<=15	// Include those who arrived to the UK before age 15 as cbirth_dum==1. Reduced cbirth_dum from 23070 -> 15830
	lab var cbirth_dum "Country of Birth- UK Dummy"
	lab def cbirth_dum 0 "Outside UK" 1 "UK" 
	lab val cbirth_dum cbirth_dum
	tab cbirth_dum

// Economic Activity (ILO definition + disaggregate between PT and FT). Note. later classify STUCUR 
	gen ecactivity =.
	replace ecactivity=1 if ILODEFR==1 & FTPT==1
	replace ecactivity=2 if ILODEFR==1 & FTPT!=1
	replace ecactivity=3 if ILODEFR==2
	replace ecactivity=4 if ILODEFR==3
	replace ecactivity=5 if ILODEFR==4
	lab var ecactivity "Economic activity"
	lab def ecactivity 1 "Employed-FT" 2 "Employed-non-FT" 3 "Unemployed" 4 "Inactive" 5 "Under 16"
	lab val ecactivity ecactivity

// Economic Activity (ILO definition +  underemployment). Underemployment = employed but want more hours OR looking for new/addl job
// Underemployment expanded definition. Three indicators of time-related underemployment according to Torres et al 2023
	// Indicator 1. Involuntary part-time employment  YPTJOB==3 IF FTPTWK=2
	// Indicator 2. Want longer hours at current rate UNDEMP ==1
	// Indicator 3. Replacement job (ADDJOB==2) AND more hours (LOOKM111, 112, 113 ==5)
	gen ecactivity_und =.
	replace ecactivity_und=1 if ILODEFR==1
	replace ecactivity_und=2 if ILODEFR==1 & (FTPTWK==2 & YPTJOB==3) 		// Metric 1. Involuntary part-time employment YPTJOB==3 IF FTPTWK=2
	replace ecactivity_und=2 if ILODEFR==1 & (UNDEMP==1) 		// Metric 2. Want longer hours at current rate UNDEMP ==1
	replace ecactivity_und=2 if ILODEFR==1 & (ADDJOB==1 & (LOOKM111==5 | LOOKM112==5 | LOOKM113==5)) // Metric 3. Replacement job (ADDJOB==1) AND more hours (LOOKM111, 112, 113 ==5)
	replace ecactivity_und=3 if ILODEFR==2
	replace ecactivity_und=4 if ILODEFR==3
	replace ecactivity_und=5 if ILODEFR==4
	lab var ecactivity_und "Economic activity- with underemployment"
	lab def ecactivity_und 1 "Employed" 2 "Underemployed" 3 "Unemployed" 4 "Inactive" 5 "Under 16"
	lab val ecactivity_und ecactivity_und

// Economic Activity (ILO definition +  underemployment). Underemployment = employed but want more hours OR looking for new/addl job
// Zero hours contract or on call working
	gen ecactivity_zero =.
	replace ecactivity_zero=1 if ILODEFR==1
	replace ecactivity_zero=2 if ILODEFR==1 & (FLEXW7==1 | FLEX22W6==1) 		// Metric 1. Zero hours contract
	replace ecactivity_zero=2 if ILODEFR==1 & (FLEXW10==1 | FLEX22W7==1) 		// Metric 2. On call working
	replace ecactivity_zero=3 if ILODEFR==2
	replace ecactivity_zero=4 if ILODEFR==3
	replace ecactivity_zero=5 if ILODEFR==4
	lab var ecactivity_zero "Economic activity- with zero hours/on call working"
	lab def ecactivity_zero 1 "Employed" 2 "Emp-zero hrs/on-call" 3 "Unemployed" 4 "Inactive" 5 "Under 16"
	lab val ecactivity_zero ecactivity_zero

// Economic Activity (Temporary + Agency Contract). Use LFS measure
	gen ecactivity_tempag =.
	replace ecactivity_tempag=1 if ILODEFR==1
	replace ecactivity_tempag=2 if ILODEFR==1 & JOBTYP==2			// Metric 1. Temporary work
	replace ecactivity_tempag=2 if ILODEFR==1 & AGWRK==1 		// Metric 2. Agency work
	replace ecactivity_tempag=3 if ILODEFR==2
	replace ecactivity_tempag=4 if ILODEFR==3
	replace ecactivity_tempag=5 if ILODEFR==4
	lab var ecactivity_tempag "Economic activity- temporary or agency"
	lab def ecactivity_tempag 1 "Employed" 2 "Emp-temp/agency" 3 "Unemployed" 4 "Inactive" 5 "Under 16"
	lab val ecactivity_tempag ecactivity_tempag
	tab ecactivity_tempag
	

// Economic Activity (Unpaid overtime). Two measures of unpaid overtime: actual hours of unpaid OT/usual hours of unpaid OT.
// Classify as 1 if unpaid OT >0 and in employment (PT/FT)
	gen ecactivity_ot =.
	replace ecactivity_ot=1 if ILODEFR==1
	replace ecactivity_ot=2 if ILODEFR==1 & (ACTUOT>0 | UOTHR>0) 		// Metric 1. Unpaid OT
	replace ecactivity_ot=3 if ILODEFR==2
	replace ecactivity_ot=4 if ILODEFR==3
	replace ecactivity_ot=5 if ILODEFR==4
	lab var ecactivity_ot "Economic activity- unpaid overtime hrs"
	lab def ecactivity_ot 1 "Employed" 2 "Emp-unpaid OT" 3 "Unemployed" 4 "Inactive" 5 "Under 16"
	lab val ecactivity_ot ecactivity_ot
	tab ecactivity_ot

// Economic Activity (Agency worker). Use LFS measure
	gen ecactivity_agency =.
	replace ecactivity_agency=1 if ILODEFR==1
	replace ecactivity_agency=2 if ILODEFR==1 & AGWRK==1 		// Metric 1. Agency work
	replace ecactivity_agency=3 if ILODEFR==2
	replace ecactivity_agency=4 if ILODEFR==3
	replace ecactivity_agency=5 if ILODEFR==4
	lab var ecactivity_agency "Economic activity- agency worker"
	lab def ecactivity_agency 1 "Employed" 2 "Emp-agency work" 3 "Unemployed" 4 "Inactive" 5 "Under 16"
	lab val ecactivity_agency ecactivity_agency
	tab ecactivity_agency

// Economic Activity (Temporary Contract). Use LFS measure
	gen ecactivity_temp =.
	replace ecactivity_temp=1 if ILODEFR==1
	replace ecactivity_temp=2 if ILODEFR==1 & JOBTYP==2		// Metric 1. Agency work
	replace ecactivity_temp=3 if ILODEFR==2
	replace ecactivity_temp=4 if ILODEFR==3
	replace ecactivity_temp=5 if ILODEFR==4
	lab var ecactivity_temp "Economic activity- temporary"
	lab def ecactivity_temp 1 "Employed" 2 "Emp-temporary" 3 "Unemployed" 4 "Inactive" 5 "Under 16"
	lab val ecactivity_temp ecactivity_temp
	tab ecactivity_temp

// Parental Social Class. See guidance from ONS

	destring SM_NSEC10, replace

	gen pclass=.
	replace pclass=1 if (SM_NSEC20>=1 & SM_NSEC20<=6) | (SM_NSEC10>=1 & SM_NSEC10<7)		// managers and professional occs
	replace pclass=2 if (SM_NSEC20>=7 & SM_NSEC20<=9) | (SM_NSEC10>=7 & SM_NSEC10<10)		// intermediate + own account + employers in small orgs
	replace pclass=3 if (SM_NSEC20>=10 & SM_NSEC20<=13) | (SM_NSEC10>=10 & SM_NSEC10<14)	// inc. semi-routine and routine 
	lab var pclass "Parental class"
	lab def pclass 1 "Service" 2 "Intermediate" 3 "Routine"
	lab val pclass pclass

// Parental Social Class 5 category. See guidance from ONS

	gen pclass6=.
	replace pclass6=1 if (SM_NSEC20>=1 & SM_NSEC20<4) | (SM_NSEC10>=1 & SM_NSEC10<4)		// higher managerial, administrative and professional occupations
	replace pclass6=2 if (SM_NSEC20>=4 & SM_NSEC20<=6) | (SM_NSEC10>=4 & SM_NSEC10<7)		// Lower managerial, administrative and professional occupations
	replace pclass6=3 if (SM_NSEC20==7) | (SM_NSEC10>=7 & SM_NSEC10<8)						// intermediate 
	replace pclass6=4 if (SM_NSEC20>=8 & SM_NSEC20<=9) | (SM_NSEC10>=8 & SM_NSEC10<10)		// own account + employers in small orgs
	replace pclass6=5 if (SM_NSEC20>=10 & SM_NSEC20<=11) | (SM_NSEC10>=10 & SM_NSEC10<12)	// Lower supervisory, lower technical
	replace pclass6=6 if (SM_NSEC20>=12 & SM_NSEC20<=13) | (SM_NSEC10>=12 & SM_NSEC10<14)	// semi-routine and routine 
	lab var pclass6 "Parental class 6-cat"
	lab def pclass6 1 "Upper Service" 2 "Lower Service" 3 "Intermediate" 4 "SE+OAW" 5 "LS+TO" 6 "Routine"
	lab val pclass6 pclass6

// Ethnicity Category
	gen ethnicity_cat=.
	replace ethnicity_cat=1 if ETHUKEUL==1
	replace ethnicity_cat=2 if ETHUKEUL==8
	replace ethnicity_cat=3 if ETHUKEUL>=3 & ETHUKEUL<=5
	replace ethnicity_cat=4 if ETHUKEUL==2 | ETHUKEUL==9 | ETHUKEUL==6 | ETHUKEUL==7
	lab var ethnicity_cat "Ethnicity categories"
	lab def ethnicity_cat 1 "White" 2 "Black" 3 "South Asian" 4 "Others/Mixed"
	lab val ethnicity_cat ethnicity_cat

// Ethnicity Dummy
	gen ethnicity_dum=.
	replace ethnicity_dum=1 if ETHUKEUL==1
	replace ethnicity_dum=0 if ETHUKEUL>1
	lab var ethnicity_dum "Ethnicity- dummy for White"
	lab def ethnicity_dum 0 "Non-White" 1 "White"
	lab val ethnicity_dum ethnicity_dum


// SEX- sex variable exists as is. 1-Male; 2-Female

// AGES- Age bands (5 years) exists as is

// Parental Co-Residence (from AB's codes) // dummy identifies children of hhhead/head of funit
	gen parentres=0
	recode parentres (0=1) if (RELH06==3| RELHFU==3 | RELH06==4)
	recode parentres (1=0) if HALLRES==1 /* those who are living in halls of residence are deemed to have left home */
	lab var parentres "Residing with a parent"
	lab def parentres 0 "No" 1 "Yes"
	lab val parentres parentres

// Partnership Status // dummy identifies if respondent is in a partnership
	gen partner=0
	replace partner=1 if MARDY6==1
	replace partner=1 if MARDY6!=1 & (LIV12W==1|MARSTA==2|MARSTA==6)
	lab var partner "Partnered?"
	lab def partner 0 "No" 1 "Yes"
	lab val partner partner

// AGES1 economically active 23-34
	generate AGES1 = .		
	replace AGES1 = 1 if AGE>=23 & AGE<=26 
	replace AGES1 = 2 if AGE>=27 & AGE<=30
	replace AGES1 = 3 if AGE>=31 & AGE<=34
	lab var AGES1 "Age groups 23-34?"
	lab def AGES1 1 "23-26yrs" 2 "27-30yrs" 3 "31-34yrs"
	lab val AGES1 AGES1

// AGES2 economically active 18-34
	generate AGES2 = .		
	replace AGES2 = 1 if AGE>=18 & AGE<=22
	replace AGES2 = 2 if AGE>=23 & AGE<=26 
	replace AGES2 = 3 if AGE>=27 & AGE<=30
	replace AGES2 = 4 if AGE>=31 & AGE<=34
	lab var AGES2 "Age groups 18-34"
	lab def AGES2 1 "18-22yrs" 2 "23-26yrs" 3 "27-30yrs" 4 "31-34yrs"
	lab val AGES2 AGES2

// Create a variable for parenthood
	tab FDPCH19
	gen child19=0 if FDPCH19==0
	replace child19=1 if FDPCH19>0
	tab child19 FDPCH19

	/* coding whether it is their biological child */
	gen child=0
	replace child=1 if child19==1 & (RELHFU==1|RELHFU==2)
	tab child
	lab var child "Have own children?"
	lab def child 0 "No" 1 "Yes"
	lab val child child

// Gross Earnings Quintile (note proxy, not annualized)
	gen grsswk_clean = GRSSWK if GRSSWK > 0 	// note: median nominal is 481/wk
	pctile q = grsswk_clean [pw=piwt], nq(5)	// create 5 quintiles with earnings weights - thresholds 260, 415, 577, 827
	gen grosspay_quintile = .
	replace grosspay_quintile = 1 if grsswk_clean < 260
	replace grosspay_quintile = 2 if grsswk_clean >= 260 & grsswk_clean < 415
	replace grosspay_quintile = 3 if grsswk_clean >= 415 & grsswk_clean < 577
	replace grosspay_quintile = 4 if grsswk_clean >= 577 & grsswk_clean < 827
	replace grosspay_quintile = 5 if grsswk_clean >= 827
	replace grosspay_quintile = . if inlist(GRSSWK, -9, -8)
	lab var grosspay_quintile "Gross Nominal Pay Quintile Weekly"

// Net Earnings Quintile (note proxy, not annualized)
	gen netwk_clean = NETWK if NETWK > 0 	
	pctile qnet = netwk_clean [pw=piwt], nq(5)	// create 5 quintiles with earnings weights - thresholds 231, 335, 438, 600
	gen netpay_quintile = .
	replace netpay_quintile = 1 if netwk_clean < 231
	replace netpay_quintile = 2 if netwk_clean >= 231 & netwk_clean < 335
	replace netpay_quintile = 3 if netwk_clean >= 335& netwk_clean < 438
	replace netpay_quintile = 4 if netwk_clean >= 438 & netwk_clean < 600
	replace netpay_quintile = 5 if netwk_clean >= 600
	replace netpay_quintile = . if inlist(NETWK, -9, -8)
	lab var netpay_quintile "Net Nominal Pay Quintile Weekly"

// HOURS. Use as defined: TTACHR TTUSHR

// CLC indicator
	gen clc = 1 if REFWKY >= 2021
	replace clc = 0 if REFWKY <=2019
	lab def clc 0 "Pre-CLC" 1 "Post-CLC"
	lab val clc clc
	lab var clc "Cost-of-Living Crisis Period"

// Health Status. declared a main health problem
	gen health = 1 if HEALTH20 >=0
	replace health = 0 if HEALTH20== -9 | HEALTH20==-8
	lab var health "Declared Main Health Problem"
	lab def health 0 "No" 1 "Yes"
	lab val health health


********************************************************************************
******** SAMPLE SELECTION
********************************************************************************

// Create Analytical Sample 1: economically active 23-34
	preserve
	keep if AGE >=23 & AGE<=34	// Focus on young adults 22888 remaining
	keep if ILODEFR !=3 		// Remove economically inactive = remove 2778/22888 -> 20110 remaining
	keep if STUCUR!=1 			// Remove full-time students 523/20110 -> 19587

	// Keep Subset
	keep HOHID HRP HSERIALP REFWKY pwt piwt parentres partner SEX ethnicity_dum ethnicity_cat AGES AGES1 AGES2 ecactivity ecactivity_und ecactivity_zero ecactivity_ot ecactivity_agency ecactivity_temp ecactivity_tempag pclass qual STUCUR GOR9D cbirth_dum cbirth_cat child child19 age_arrival_UK GOVTOF2 FTPT grosspay_quintile netpay_quintile GRSSWK NETWK TTACHR TTUSHR clc health pclass6

	order HOHID HRP HSERIALP HRP REFWKY GOVTOF2 pwt piwt parentres SEX AGES AGES1 pclass pclass6 clc health

	// Export Data
	save "$WRITE\individual.dta", replace 			// Individual-level data
	restore 


// Create Analytical Sample 2: economically active 18-34
	preserve
	keep if AGE >=18 & AGE<=34	// Focus on young adults 22888 remaining
	keep if ILODEFR !=3 		// Remove economically inactive = remove 2778/22888 -> 20110 remaining
	keep if STUCUR!=1 			// Remove full-time students 523/20110 -> 19587

	// Keep Subset
	keep HOHID HRP HSERIALP REFWKY pwt piwt parentres partner SEX ethnicity_dum ethnicity_cat AGES AGES1 AGES2 ecactivity ecactivity_und ecactivity_zero ecactivity_ot ecactivity_agency ecactivity_temp ecactivity_tempag pclass qual STUCUR GOR9D cbirth_dum cbirth_cat child child19 age_arrival_UK GOVTOF2 FTPT grosspay_quintile netpay_quintile GRSSWK NETWK TTACHR TTUSHR clc health pclass6

	order HOHID HRP HSERIALP HRP REFWKY GOVTOF2 pwt piwt parentres SEX AGES AGES1 pclass pclass6 clc health


	// Export Data
	save "$WRITE\individual_longer.dta", replace 			// Individual-level data
	restore 

// Create Analytical Sample 3: economically active 18-34 including students
	preserve
	keep if AGE >=18 & AGE<=34	// Focus on young adults 22888 remaining

	// Keep Subset
	keep HOHID HRP HSERIALP REFWKY pwt piwt parentres partner SEX ethnicity_dum ethnicity_cat AGES AGES1 AGES2 ecactivity ecactivity_und ecactivity_zero ecactivity_ot ecactivity_agency ecactivity_temp ecactivity_tempag pclass qual STUCUR GOR9D cbirth_dum cbirth_cat child child19 age_arrival_UK GOVTOF2 FTPT grosspay_quintile netpay_quintile GRSSWK NETWK TTACHR TTUSHR clc health pclass6

	order HOHID HRP HSERIALP HRP REFWKY GOVTOF2 pwt piwt parentres SEX AGES AGES1 pclass pclass6 clc health


	// Export Data
	save "$WRITE\individual_longer_wstudents.dta", replace 			// Individual-level data
	restore 



