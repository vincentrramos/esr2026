// ==============================================================================
// Paper:     Labour market insecurity and parental co-residence in the United Kingdom: heterogeneities by parental class and age
// Author:    Vincent Jerald Ramos and Ann Berrington
// Date:      January 2026
// Purpose:   Replication Codes for Figures and Tables in Text
// File:	  2_descriptives
// Describe:  generate data found in descriptive tables
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



use "$WRITE\individual_longer.dta", clear
svyset HSERIALP [pw=pwt], vce(linearized)		// set weights
keep if clc==1									// remove 2016-19

*-------------------------------------------------------------------------------
**## * Table 1. Distribution of employment arrangements
*-------------------------------------------------------------------------------

svy: logit parentres i.ecactivity_und ib3.pclass i.SEX i.AGES2 i.ethnicity_cat i.cbirth_dum i.qual i.child i.health ib8.GOVTOF2 i.REFWKY, or baselevels 	
svy: tab ecactivity_und AGES2 if e(sample), col

svy: logit parentres i.ecactivity_tempag ib3.pclass i.SEX i.AGES2 i.ethnicity_cat i.cbirth_dum i.qual i.child i.health ib8.GOVTOF2 i.REFWKY, or baselevels 	
svy: tab ecactivity_tempag AGES2 if e(sample), col



*-------------------------------------------------------------------------------
**## Table 2. Descriptive statistics
*-------------------------------------------------------------------------------

// Columns 1 and 2: Weighted cores proportions + SE
	svy: logit parentres i.ecactivity_und ib3.pclass i.SEX i.AGES2 i.ethnicity_cat i.cbirth_dum i.qual i.child i.health ib8.GOVTOF2 i.REFWKY, or baselevels 		

	foreach g in ecactivity_und ecactivity_tempag pclass SEX AGES2 ethnicity_cat cbirth_dum qual child health REFWKY GOVTOF2 {
		di "=== Results for `g' ==="
		svy: mean parentres if e(sample), over(`g')
		eststo `g'
	}

	esttab ecactivity_und ecactivity_tempag pclass SEX AGES2 ethnicity_cat cbirth_dum qual child health REFWKY GOVTOF2 using "$WRITE\frequencies.csv", ///
		cells("b(fmt(3)) se(fmt(3))") ///
		label ///
		collabels("Mean" "SE") ///
		replace

// Columns 3 and 4: unweighted counts and sample frequencies
	preserve 

	* Unweighted ns
	svy: logit parentres i.ecactivity_und ib3.pclass i.SEX i.AGES2 i.ethnicity_cat i.cbirth_dum i.qual i.child i.health ib8.GOVTOF2 i.REFWKY, or baselevels 	// M6: M5 + parenthood

	gen _sample=1 if e(sample)
	keep if _sample==1
			 
	table (var) (parentres) [pw=pwt],  ///
			statistic(fvrawfrequency ecactivity_und ecactivity_tempag pclass SEX AGES2 ethnicity_cat cbirth_dum qual child health REFWKY GOVTOF2) ///
			statistic(fvfrequency ecactivity_und ecactivity_tempag pclass SEX AGES2 ethnicity_cat cbirth_dum qual child health REFWKY GOVTOF2) ///
			statistic(fvpercent ecactivity_und ecactivity_tempag pclass SEX AGES2 ethnicity_cat cbirth_dum qual child health REFWKY GOVTOF2) ///
			nformat(%5.2f fvpercent) sformat("%s%%" fvpercent)
			
	collect recode result fvrawfrequency = column1 fvpercent = column2 fvfrequency = column3
	collect layout (var) (parentres#result[column1 column2 column3])
	collect style header result, level(hide)
	collect style row stack, nobinder spacer
	collect style cell var[ecactivity_und ecactivity_tempag pclass SEX AGES2 ethnicity_cat cbirth_dum qual child health REFWKY GOVTOF2]#result[column2], nformat(%6.1f) sformat("%s%%")
	collect preview
	collect export "$WRITE\crosstabs.xlsx", replace

	restore

***
