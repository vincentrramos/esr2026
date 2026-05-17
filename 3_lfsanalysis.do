// ==============================================================================
// Paper:     Labour market insecurity and parental co-residence in the United Kingdom: heterogeneities by parental class and age
// Author:    Vincent Jerald Ramos and Ann Berrington
// Date:      January 2026
// Purpose:   Replication Codes for Figures and Tables in Text
// File:	  3_lfsanalysis
// Describe:  regressions
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


********************************************************************************
** Figure 4. Labour market insecurity and parental co-residence—average marginal effects
********************************************************************************

svy: logit parentres i.ecactivity_und ib3.pclass i.SEX i.AGES2 i.ethnicity_cat i.cbirth_dum i.qual i.child i.health ib8.GOVTOF2 i.REFWKY, or baselevels 
eststo precarity1: margins, dydx(*) post 

svy: logit parentres i.ecactivity_tempag ib3.pclass i.SEX i.AGES2 i.ethnicity_cat i.cbirth_dum i.qual i.child i.health ib8.GOVTOF2 i.REFWKY, or baselevels 	
eststo precarity2: margins, dydx(*) post 

// plot
	coefplot precarity1 precarity2, drop(_cons) xline(0, lcolor(red) lwidth(medium)) ///
	xtitle("{bf: Marginal Effect on Pr(Parental Coresidence)}") /// 
	graphregion(margin(medsmall)) ///
	xsize(6.5) ysize(4.5) ///
	keep(1.ecactivity_und 2.ecactivity_und 3.ecactivity_und 1.ecactivity_tempag 2.ecactivity_tempag 3.ecactivity_tempag) /// Keep option
	xlab(, glpattern(solid) glcolor(gs14)) /// 
	grid(glpattern(solid) glcolor(gs14)) ///
	ylab(, labsize(*1.1)) ///
	baselevels ///
	headings(1.ecactivity_und="{bf: S1: Underemployment}" ///
			1.ecactivity_tempag="{bf: S2: Temporary and agency work}", gap(0)) ///
	msize(small)  mlcolor(navy) msymbol(square_hollow) ///
	levels(95 90) ciopts(lcolor(navy midblue) recast(rspike rcap)) ///
	subtitle(, color(black) fcolor(gs15) lcolor(gs12)) ///
	xscale(range(-0.1 0.2)) ///
	xlabel(-0.1(0.05)0.2, angle(horizontal)) ///
	legend(off) ///
	scale(0.9) ///
	note("Note: Models control for parental class, sex, age, ethnicity, migration background, qualifications, parenthood," "health status, and region and year dummies. Sample: economically active young adults, 18-34yrs (n=20,144)", size(small) span) /// add a note
	subtitle("LM Insecurity and Parental Coresidence")
	graph export "$GRAPH\figure4_age18_h1_precarityall_full.png", replace width(1000)
	graph export "$GRAPH\figure4_age18_h1_precarityall_full.eps", replace

********************************************************************************
** Figure 5. Labour market insecurity and parental co-residence, by age groups
********************************************************************************

	svy: logit parentres i.ecactivity_und##i.AGES2 i.SEX i.pclass i.ethnicity_cat i.cbirth_dum i.qual i.child i.health ib8.GOVTOF2 i.REFWKY, or baselevels
	margins, dydx(i.ecactivity_und) at(AGES2 = (1 2 3 4))
	mplotoffset, recast(scatter) offset(0.1) ylab(-0.1(.1)0.4) ysc(r(-0.1(.1).4)) yline(0) legend(position(6) col(3)) name(age18_int_und_age_all_ame_alt, replace)
		gr_edit .title.text = {}
		gr_edit .title.text.Arrpush "S1: Underemployment" // title edits
		gr_edit .yaxis1.title.text = {}
		gr_edit .yaxis1.title.text.Arrpush "Effect on Pr(PC) (vs. Employment)" // title edits
		gr_edit .xaxis1.title.text = {}
		gr_edit .legend.plotregion1.label[1].text = {}
		gr_edit .legend.plotregion1.label[1].text.Arrpush Underemployment
		gr_edit .legend.plotregion1.label[2].text = {}
		gr_edit .legend.plotregion1.label[2].text.Arrpush Unemployment
		//graph export "$GRAPH\age18_ecactivityund_ages1_int_ame_alt.png", replace width(1000)
		
	svy: logit parentres i.ecactivity_tempag##i.AGES2 i.SEX i.pclass i.ethnicity_cat i.cbirth_dum i.qual i.child i.health ib8.GOVTOF2 i.REFWKY, or baselevels 
	margins, dydx(i.ecactivity_tempag) at(AGES2 = (1 2 3 4))
	mplotoffset, recast(scatter) offset(0.1) ylab(-0.1(.1)0.4) ysc(r(-0.1(.1).4)) yline(0) xtitle("Age groups") legend(position(6) col(3)) name(age18_int_tempag_age_all_ame_alt, replace)
		gr_edit .title.text = {}
		gr_edit .title.text.Arrpush "S2: Temporary and Agency Work" // title edits
		gr_edit .yaxis1.title.text = {}
		gr_edit .yaxis1.title.text.Arrpush "Effect on Pr(PC) (vs. Employment)" // title edits
		gr_edit .xaxis1.title.text = {}
		gr_edit .legend.plotregion1.label[1].text = {}
		gr_edit .legend.plotregion1.label[1].text.Arrpush Emp-temp/agency
		gr_edit .legend.plotregion1.label[2].text = {}
		gr_edit .legend.plotregion1.label[2].text.Arrpush Unemployment
		//graph export "$GRAPH\age18_ecactivitytempag_ages1_int_ame_alt.png", replace width(1000)
		
	** Merge Plots
	graph combine age18_int_und_age_all_ame_alt age18_int_tempag_age_all_ame_alt, note("Note: Models control for sex, parental class, ethnicity, migration background, qualifications, parenthood, health," "region, and year. Sample: economically active working-age young adults, 18-34yrs. (n=20,144)", size(small) span)
	graph export "$GRAPH\figure5_age18_h3_precarity_age_ame_alt.png", replace 
	graph export "$GRAPH\figure5_age18_h3_precarity_age_ame_alt.eps", replace
	
	
********************************************************************************
** Figure 6. Labour market insecurity and parental co-residence, by parental class
********************************************************************************	
	
	svy: logit parentres i.ecactivity_und##i.pclass i.SEX i.AGES2 i.ethnicity_cat i.cbirth_dum i.qual i.child i.health ib8.GOVTOF2 i.REFWKY, or baselevels
	margins, dydx(i.ecactivity_und) at(pclass = (1 2 3))
	mplotoffset, recast(scatter) offset(0.1) ylab(-0.1(.1).40) ysc(r(-0.1(.1).40)) yline(0) legend(position(6) col(3)) name(age18_int_und_pc_all_ame_alt, replace)
		gr_edit .title.text = {}
		gr_edit .title.text.Arrpush "S1: Underemployment" // title edits
		gr_edit .yaxis1.title.text = {}
		gr_edit .yaxis1.title.text.Arrpush "Effect on Pr(PC) (vs. Employment)" // title edits
		gr_edit .xaxis1.title.text = {}
		gr_edit .legend.plotregion1.label[1].text = {}
		gr_edit .legend.plotregion1.label[1].text.Arrpush Underemployment
		gr_edit .legend.plotregion1.label[2].text = {}
		gr_edit .legend.plotregion1.label[2].text.Arrpush Unemployment
		//graph export "$GRAPH\age18_ecactivityund_pclass_int_ame_alt.png", replace width(1000)

	svy: logit parentres i.ecactivity_tempag##i.pclass i.SEX i.AGES2 i.ethnicity_cat i.cbirth_dum i.qual i.child i.health ib8.GOVTOF2 i.REFWKY, or baselevels 
	margins, dydx(i.ecactivity_tempag) at(pclass = (1 2 3))
	mplotoffset, recast(scatter) offset(0.1) ylab(-0.1(.1).40) ysc(r(-0.1(.1).40)) yline(0) legend(position(6) col(3)) name(age18_int_tempag_pc_all_ame_alt, replace)
		gr_edit .title.text = {}
		gr_edit .title.text.Arrpush "S2: Temporary and Agency Work" // title edits
		gr_edit .yaxis1.title.text = {}
		gr_edit .yaxis1.title.text.Arrpush "Effect on Pr(PC) (vs. Employment)" // title edits
		gr_edit .xaxis1.title.text = {}
		gr_edit .legend.plotregion1.label[1].text = {}
		gr_edit .legend.plotregion1.label[1].text.Arrpush Emp-temp/agency
		gr_edit .legend.plotregion1.label[2].text = {}
		gr_edit .legend.plotregion1.label[2].text.Arrpush Unemployment
		//graph export "$GRAPH\age18_ecactivitytempag_pclass_int_ame_alt.png", replace width(1000)
		
	** Merge Plots

	graph combine age18_int_und_pc_all_ame_alt age18_int_tempag_pc_all_ame_alt, note("Note: Models control for sex, age, ethnicity, migration background, qualifications, parenthood, health," "region, and year. Sample: economically active working-age young adults, 18-34yrs. (n=20,144)", size(small) span)
	graph export "$GRAPH\figure6_age18_h4_precarity_pclass_ame_alt.png", replace 
	graph export "$GRAPH\figure6_age18_h4_precarity_pclass_ame_alt.eps", replace

	
	
********************************************************************************
** Figure 7. Labour market insecurity and parental co-residence, by parental social class and age groups
********************************************************************************	

	svy: logit parentres i.ecactivity_und##i.pclass##i.AGES2 i.SEX i.ethnicity_cat i.cbirth_dum i.qual i.child i.health ib8.GOVTOF2 i.REFWKY, or baselevels 
	margins, dydx(i.ecactivity_und) at(pclass = (1 2 3) AGES2=(1 2 3 4))
	mplotoffset, xdimension(pclass) by(AGES2) recast(scatter) offset(0.2) yline(0) ylab(.4(.2)-.2) ysc(r(.4(.2)-.2)) byopts(legend(pos(6))) legend(col(3)) name(age18_int_und_pc_age_ame_alt2, replace)
		gr_edit .title.text = {}
		gr_edit .title.text.Arrpush "S1: Underemployment" // title edits
		gr_edit .l1title.text = {}
		gr_edit .Edit , cmd(.set_cols = 4) cmd(.set_rows = 0)  // int_und_pc_age_all edits
		gr_edit .legend.plotregion1.label[1].text = {}
		gr_edit .legend.plotregion1.label[1].text.Arrpush Underemployment
		gr_edit .legend.plotregion1.label[2].text = {}
		gr_edit .legend.plotregion1.label[2].text.Arrpush Unemployment
		//graph export "$GRAPH\age18_ecactivityund_pclass_age_int_ame_alt2.png", replace width(1000)
		
	svy: logit parentres i.ecactivity_tempag##i.pclass##i.AGES2 i.SEX i.ethnicity_cat i.cbirth_dum i.qual i.child i.health ib8.GOVTOF2 i.REFWKY, or baselevels 
	margins, dydx(i.ecactivity_tempag) at(pclass = (1 2 3) AGES2=(1 2 3 4))
	mplotoffset, xdimension(pclass) by(AGES2) recast(scatter) offset(0.2) yline(0) ylab(.4(.2)-.2) ysc(r(.4(.2)-.2)) byopts(legend(pos(6))) legend(col(3)) name(age18_int_tempag_pc_age_ame_alt2, replace)
		gr_edit .title.text = {}
		gr_edit .title.text.Arrpush "S2: Temporary and Agency Work" // title edits
		gr_edit .l1title.text = {}
		gr_edit .Edit , cmd(.set_cols = 4) cmd(.set_rows = 0)  // int_und_pc_age_all edits
		gr_edit .legend.plotregion1.label[1].text = {}
		gr_edit .legend.plotregion1.label[1].text.Arrpush Emp-temp/agency
		gr_edit .legend.plotregion1.label[2].text = {}
		gr_edit .legend.plotregion1.label[2].text.Arrpush Unemployment
		//graph export "$GRAPH\age18_ecactivitytempag_pclass_ageint_ame_alt2.png", replace width(1000)
		
	** Merge Plots
	graph combine age18_int_und_pc_age_ame_alt2 age18_int_tempag_pc_age_ame_alt2, rows(2) note("Note: Models control for sex, ethnicity, migration background, qualifications, parenthood, health, region," "and year dummies. Sample: economically active working-age young adults, 18-34yrs. (n=20,144)", size(small) span)
		gr_edit .l1title.text = {}
		gr_edit .l1title.text.Arrpush "Effect on Pr(PC) (vs. Employment)" 
	graph export "$GRAPH\figure7_age18_h5b_precarity_pclass_age_ame_alt2.png", replace 
	graph export "$GRAPH\figure7_age18_h5b_precarity_pclass_age_ame_alt2.eps", replace