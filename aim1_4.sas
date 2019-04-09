*############################################*
*######### McWilliams Dissertation ##########*
*##### Aim 1 Logistic Regression Model 2 ####*
*# IUD vs Anything Else, No Sterilized Individuals in Sample #*
*############################################*;

libname library "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\nsfg_CMcWFormats.sas";
data a; set library.nsfg; run;

*** The following code sets people using sterilization to missing, 
which is a critical componentof this model;

data a; set a;
	if bc = 1 then iud = .;
	if bc = 2 then iud = .;
	if bc = 42 then iud = .;
	run;

ods trace on;
ods graphics on / reset=index imagename="iud2_age";
ods listing gpath = "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\sas_graphs_iud2";

*DESCRIPTIVES FOR iud VS NOT;
proc freq data=a; tables iud; ods output onewayfreqs=iudfreq; run;
proc print data=iudfreq; format iud 3.1; run;

	*formatting to make dataset look nicer;
	data iudfreq; set iudfreq;
		drop f_iud Table CumFrequency CumPercent;
		rename iud = iud;
		run;

	proc print data=iudfreq; run;
	proc export data=iudfreq outfile="U:\Dissertation\xls_graphs\iudfreq.xlsx"
	dbms=xlsx replace; run;

proc freq data=a; tables rscrage*iud; weight weightvar; ods output CrossTabFreqs=iud_age;
run;
proc print data=iud_age; run;
proc sgplot data=iud_age;
	vbar rscrage / Response=RowPercent;
	where iud = 1;
	run;


*IUD use by covariates;

%let var = iud;

%let confounders = 
	edu
	hisprace2
	povlev
	agebabycat
	parity
	rwant
	mard
	curr_ins;

%macro ditto;
	%let i=1;
	%do %until(not %length(%scan(&confounders,&i)));
proc freq data=a; 
	tables &var*(%scan(&confounders,&i)) / nopercent norow nofreq;
	weight weightvar;
	ods output CrossTabFreqs=iud_%scan(&confounders,&i);
	run;
	%let i=%eval(&i+1);
	%end;
	%mend ditto;

	%ditto;

	proc print data=iud_edu; run;
	proc sgplot data=iud_edu; 
		vbar edu / response=ColPercent;
		where iud = 1;
		run;

	data iud_edu; set iud_edu;
		if iud ne 1 then delete;
		if edu = . then delete;
		drop Table _TYPE_ _TABLE_ Frequency Missing;
		run;
		proc print data=iud_edu; run;

%let ds = 
	iud_edu
	iud_hisprace2
	iud_povlev
	iud_agebabycat
	iud_parity
	iud_rwant
	iud_mard
	iud_curr_ins;

%macro ds;
	%let i=1;
	%do %until(not %length(%scan(&ds,&i)));
	data %scan(&ds,&i); set %scan(&ds,&i);
		if iud ne 1 then delete;
		drop Table _TYPE_ _TABLE_ Frequency Missing;
		run;
	%let i=%eval(&i+1);
	%end;
	%mend ds;

	%ds;

%macro worksheets;
	%let i=1;
	%do %until(not %length(%scan(&ds,&i)));
	proc export data=%scan(&ds,&i)
		outfile="U:\Dissertation\xls_graphs\iud2.xlsx"
		dbms=xlsx
		replace;
		sheet="%scan(&ds,&i)";
		run;
		%let i=%eval(&i+1);
		%end;
		%mend worksheets;

		%worksheets;

title 'iud = age';
proc surveylogistic data=a;
	class
		iud (ref=first);
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl;
	output out=iud pred=pred;
	run;

proc sgplot data=iud;
	scatter y=pred x=rscrage;
	run;

*** BIVARIATE BETWEEN iud AND AGE, WITH ESTIMATES ***;

proc surveylogistic data=a;
	class iud (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl;
	estimate '23 vs 28' spl [1,23] [-1,28] / exp cl;
	estimate '24 vs 28' spl [1,24] [-1,28] / exp cl;
	estimate '25 vs 28' spl [1,25] [-1,28] / exp cl;
	estimate '26 vs 28' spl [1,26] [-1,28] / exp cl;
	estimate '27 vs 28' spl [1,27] [-1,28] / exp cl;
	estimate '28 vs 28' spl [1,28] [-1,28] / exp cl;
	estimate '29 vs 28' spl [1,29] [-1,28] / exp cl;
	estimate '30 vs 28' spl [1,30] [-1,28] / exp cl;
	estimate '31 vs 28' spl [1,31] [-1,28] / exp cl;
	estimate '32 vs 28' spl [1,32] [-1,28] / exp cl;
	estimate '33 vs 28' spl [1,33] [-1,28] / exp cl;
	estimate '34 vs 28' spl [1,34] [-1,28] / exp cl;
	estimate '35 vs 28' spl [1,35] [-1,28] / exp cl;
	estimate '36 vs 28' spl [1,36] [-1,28] / exp cl;
	estimate '37 vs 28' spl [1,37] [-1,28] / exp cl;
	estimate '38 vs 28' spl [1,38] [-1,28] / exp cl;
	estimate '39 vs 28' spl [1,39] [-1,28] / exp cl;
	estimate '40 vs 28' spl [1,40] [-1,28] / exp cl;
	estimate '41 vs 28' spl [1,41] [-1,28] / exp cl;
	estimate '42 vs 28' spl [1,42] [-1,28] / exp cl;
	estimate '43 vs 28' spl [1,43] [-1,28] / exp cl;
	estimate '44 vs 28' spl [1,44] [-1,28] / exp cl;
	ods output Estimates=e_iud;
	ods output FitStatistics=fs_iud;
	ods output OddsRatios=or_iud;
	ods output ModelANOVA=jt_iud;
	run;

data e_iud; set e_iud;
	ORR=round(ExpEstimate,.01);
	LCLR=round(LowerExp,.01);
	UCLR=round(UpperExp,.01);
	title 'Bivariate iud use by age, fitted with spline';
	run;

proc sgplot data=e_iud;
	vbarparm category=Label response=ORR /
	datalabel=ORR
	baseline=1 groupdisplay=cluster
	limitlower=LCLR limitupper=UCLR;
	refline "28vs 28" / axis=x label="Ref";
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e;
	title1 'Bivariate iud use by age, fitted with spline';
	run;

%let dem = edu hisprace2 povlev;
%let demfert = edu hisprace2 povlev agebabycat parity rwant mard;
%let full = edu hisprace2 povlev agebabycat parity rwant mard curr_ins;


*** iud USE REGRESSED ON AGE AND DEMOGRAPHIC VARS ***;

proc surveylogistic data=a;
	class iud (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &dem;
	estimate '23 vs 28' spl [1,23] [-1,28] / exp cl;
	estimate '24 vs 28' spl [1,24] [-1,28] / exp cl;
	estimate '25 vs 28' spl [1,25] [-1,28] / exp cl;
	estimate '26 vs 28' spl [1,26] [-1,28] / exp cl;
	estimate '27 vs 28' spl [1,27] [-1,28] / exp cl;
	estimate '28 vs 28' spl [1,28] [-1,28] / exp cl;
	estimate '29 vs 28' spl [1,29] [-1,28] / exp cl;
	estimate '30 vs 28' spl [1,30] [-1,28] / exp cl;
	estimate '31 vs 28' spl [1,31] [-1,28] / exp cl;
	estimate '32 vs 28' spl [1,32] [-1,28] / exp cl;
	estimate '33 vs 28' spl [1,33] [-1,28] / exp cl;
	estimate '34 vs 28' spl [1,34] [-1,28] / exp cl;
	estimate '35 vs 28' spl [1,35] [-1,28] / exp cl;
	estimate '36 vs 28' spl [1,36] [-1,28] / exp cl;
	estimate '37 vs 28' spl [1,37] [-1,28] / exp cl;
	estimate '38 vs 28' spl [1,38] [-1,28] / exp cl;
	estimate '39 vs 28' spl [1,39] [-1,28] / exp cl;
	estimate '40 vs 28' spl [1,40] [-1,28] / exp cl;
	estimate '41 vs 28' spl [1,41] [-1,28] / exp cl;
	estimate '42 vs 28' spl [1,42] [-1,28] / exp cl;
	estimate '43 vs 28' spl [1,43] [-1,28] / exp cl;
	estimate '44 vs 28' spl [1,44] [-1,28] / exp cl;
	ods output Estimates=e_iud_dem;
	ods output FitStatistics=fs_iud_dem;
	ods output OddsRatios=or_iud_dem;
	ods output ModelANOVA=jt_iud_dem;
	run;


*** iud USE REGRESSED ON AGE, DEMOGRAPHIC, AND FERTILITY VARS ***;
title;
proc surveylogistic data=a;
	class iud (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &demfert;
	estimate '23 vs 28' spl [1,23] [-1,28] / exp cl;
	estimate '24 vs 28' spl [1,24] [-1,28] / exp cl;
	estimate '25 vs 28' spl [1,25] [-1,28] / exp cl;
	estimate '26 vs 28' spl [1,26] [-1,28] / exp cl;
	estimate '27 vs 28' spl [1,27] [-1,28] / exp cl;
	estimate '28 vs 28' spl [1,28] [-1,28] / exp cl;
	estimate '29 vs 28' spl [1,29] [-1,28] / exp cl;
	estimate '30 vs 28' spl [1,30] [-1,28] / exp cl;
	estimate '31 vs 28' spl [1,31] [-1,28] / exp cl;
	estimate '32 vs 28' spl [1,32] [-1,28] / exp cl;
	estimate '33 vs 28' spl [1,33] [-1,28] / exp cl;
	estimate '34 vs 28' spl [1,34] [-1,28] / exp cl;
	estimate '35 vs 28' spl [1,35] [-1,28] / exp cl;
	estimate '36 vs 28' spl [1,36] [-1,28] / exp cl;
	estimate '37 vs 28' spl [1,37] [-1,28] / exp cl;
	estimate '38 vs 28' spl [1,38] [-1,28] / exp cl;
	estimate '39 vs 28' spl [1,39] [-1,28] / exp cl;
	estimate '40 vs 28' spl [1,40] [-1,28] / exp cl;
	estimate '41 vs 28' spl [1,41] [-1,28] / exp cl;
	estimate '42 vs 28' spl [1,42] [-1,28] / exp cl;
	estimate '43 vs 28' spl [1,43] [-1,28] / exp cl;
	estimate '44 vs 28' spl [1,44] [-1,28] / exp cl;
	ods output Estimates=e_iud_demfert;
	ods output FitStatistics=fs_iud_demfert;
	ods output OddsRatios=or_iud_demfert;
	ods output ModelANOVA=jt_iud_demfert;
	run;


*** iud USE REGRESSED ON AGE AND ALL COVARIATES ***;

proc surveylogistic data=a;
	class iud (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &full;
	estimate '23 vs 28' spl [1,23] [-1,28] / exp cl;
	estimate '24 vs 28' spl [1,24] [-1,28] / exp cl;
	estimate '25 vs 28' spl [1,25] [-1,28] / exp cl;
	estimate '26 vs 28' spl [1,26] [-1,28] / exp cl;
	estimate '27 vs 28' spl [1,27] [-1,28] / exp cl;
	estimate '28 vs 28' spl [1,28] [-1,28] / exp cl;
	estimate '29 vs 28' spl [1,29] [-1,28] / exp cl;
	estimate '30 vs 28' spl [1,30] [-1,28] / exp cl;
	estimate '31 vs 28' spl [1,31] [-1,28] / exp cl;
	estimate '32 vs 28' spl [1,32] [-1,28] / exp cl;
	estimate '33 vs 28' spl [1,33] [-1,28] / exp cl;
	estimate '34 vs 28' spl [1,34] [-1,28] / exp cl;
	estimate '35 vs 28' spl [1,35] [-1,28] / exp cl;
	estimate '36 vs 28' spl [1,36] [-1,28] / exp cl;
	estimate '37 vs 28' spl [1,37] [-1,28] / exp cl;
	estimate '38 vs 28' spl [1,38] [-1,28] / exp cl;
	estimate '39 vs 28' spl [1,39] [-1,28] / exp cl;
	estimate '40 vs 28' spl [1,40] [-1,28] / exp cl;
	estimate '41 vs 28' spl [1,41] [-1,28] / exp cl;
	estimate '42 vs 28' spl [1,42] [-1,28] / exp cl;
	estimate '43 vs 28' spl [1,43] [-1,28] / exp cl;
	estimate '44 vs 28' spl [1,44] [-1,28] / exp cl;
	ods output Estimates=e_iud_main;
	ods output FitStatistics=fs_iud_main;
	ods output OddsRatios=or_iud_main;
	ods output ModelANOVA=jt_iud_main;
	run;


* CREATING ODDS RATIO TABLES AND ESTIMATE PLOTS FOR MAIN EFFECTS;

* Estimates first;
%let estimates = e_iud_dem e_iud_demfert e_iud_main;

*change output estimates so the data labels fit;
%macro rounding1;
%let i=1;
%do %until(not %length(%scan(&estimates,&i)));
data %scan(&estimates,&i); set %scan(&estimates,&i);
	ORR=round(ExpEstimate,.01);
	LCLR=round(LowerExp,.01);
	UCLR=round(UpperExp,.01);
	title %scan(&estimates,&i);
	run;
%let i=%eval(&i+1);
%end;
%mend;

%rounding1;

%macro ditto;
%let i=1;
%do %until(not %length(%scan(&estimates,&i)));
proc sgplot data=%scan(&estimates,&i);
	vbarparm category=Label response=ORR /
	datalabel=ORR
	baseline=1 groupdisplay=cluster
	limitlower=LCLR limitupper=UCLR;
	refline "28 vs 28" / axis=x label="Ref";
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e;
	title1 "iud Use vs Other Contraceptive Use";
	title2 %scan(&estimates,&i);
	run;
%let i=%eval(&i+1);
%end;
%mend ditto;

%ditto;


*** STRATIFIED iud USE ***;

%macro stratified1;
%do i=3 %to 7;
proc surveylogistic data=a;
	class agecat (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref=first)
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	model iud = edu hisprace2 povlev agebabycat parity rwant mard;
	where aged = &i.;
	ods output OddsRatios=or_strat&i.;
	run;
	%end;
	%mend stratified1;
	%stratified1;
	
%let orr = or_strat3 or_strat4 or_strat5 or_strat6 or_strat7;

/*%macro orworksheetsstrat;
%let i=1;
%do %until(not %length(%scan(&orr,&i)));
proc export data=%scan(&orr,&i)
	outfile="U:\Dissertation\xls_graphs\IUDStrat2.xlsx"
	dbms=xlsx
	replace;
	sheet="%scan(&orr,&i)";
	run;
	%let i=%eval(&i+1);
	%end;
	%mend orworksheetsstrat;

	%orworksheetsstrat;*/

%macro strat;
%do i=3 %to 7;
data or_strat&i.; set or_strat&i.;
	rename OddsRatioEst = OR&i. LowerCL = LCL&i. UpperCL = UCL&i.;
	run;
	%end;
	%mend strat;

	%strat;

%macro sort;
%do i=3 %to 7;
proc sort data=or_strat&i.; by Effect; run;
%end; %mend sort; %sort;

data iud_strat;
   merge &orr;
   by Effect;
run;

proc export data=iud_strat
	outfile = "U:\Dissertation\xls_graphs\iud_strat2"
	dbms = xlsx
	replace;
	run;


*** iud USE REGRESSED ON ALL MAIN EFFECTS AND ALL SUSPECTED INTERACTIONS ***;

proc surveylogistic data=a;
	class iud (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &full edu*hisprace2 edu*agebabycat hisprace2*agebabycat
	spl*edu spl*hisprace2 spl*povlev spl*rwant spl*parity spl*mard;
	estimate '23 vs 28' spl [1,23] [-1,28] / exp cl;
	estimate '24 vs 28' spl [1,24] [-1,28] / exp cl;
	estimate '25 vs 28' spl [1,25] [-1,28] / exp cl;
	estimate '26 vs 28' spl [1,26] [-1,28] / exp cl;
	estimate '27 vs 28' spl [1,27] [-1,28] / exp cl;
	estimate '28 vs 28' spl [1,28] [-1,28] / exp cl;
	estimate '29 vs 28' spl [1,29] [-1,28] / exp cl;
	estimate '30 vs 28' spl [1,30] [-1,28] / exp cl;
	estimate '31 vs 28' spl [1,31] [-1,28] / exp cl;
	estimate '32 vs 28' spl [1,32] [-1,28] / exp cl;
	estimate '33 vs 28' spl [1,33] [-1,28] / exp cl;
	estimate '34 vs 28' spl [1,34] [-1,28] / exp cl;
	estimate '35 vs 28' spl [1,35] [-1,28] / exp cl;
	estimate '36 vs 28' spl [1,36] [-1,28] / exp cl;
	estimate '37 vs 28' spl [1,37] [-1,28] / exp cl;
	estimate '38 vs 28' spl [1,38] [-1,28] / exp cl;
	estimate '39 vs 28' spl [1,39] [-1,28] / exp cl;
	estimate '40 vs 28' spl [1,40] [-1,28] / exp cl;
	estimate '41 vs 28' spl [1,41] [-1,28] / exp cl;
	estimate '42 vs 28' spl [1,42] [-1,28] / exp cl;
	estimate '43 vs 28' spl [1,43] [-1,28] / exp cl;
	estimate '44 vs 28' spl [1,44] [-1,28] / exp cl;
	ods output Estimates=e_iud_int;
	ods output FitStatistics=fs_iud_int;
	ods output OddsRatios=or_iud_int;
	ods output ModelANOVA=jt_iud_int;
	run;

proc export data=jt_iud_int
	outfile="U:\Dissertation\xls_graphs\jt_iud_int2.xlsx"
	dbms=xlsx;
	run;

*** IUD USE, FINAL MODEL, ESTIMATES FOR PARITY LEVELS ***;

title 'iud Use, Final Model, parity set to 0';
proc surveylogistic data=a;
	class iud (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &full edu*hisprace2 edu*agebabycat hisprace2*agebabycat
	spl*parity;
estimate '23 vs 28' spl [1,23] [-1,28] spl*parity [1, 1 23] [-1,1 28] / exp cl;
estimate '24 vs 28' spl [1,24] [-1,28] spl*parity [1, 1 24] [-1,1 28] / exp cl;
estimate '25 vs 28' spl [1,25] [-1,28] spl*parity [1, 1 25] [-1,1 28] / exp cl;
estimate '26 vs 28' spl [1,26] [-1,28] spl*parity [1, 1 26] [-1,1 28] / exp cl;
estimate '27 vs 28' spl [1,27] [-1,28] spl*parity [1, 1 27] [-1,1 28] / exp cl;
estimate '28 vs 28' spl [1,28] [-1,28] spl*parity [1, 1 28] [-1,1 28] / exp cl;
estimate '29 vs 28' spl [1,29] [-1,28] spl*parity [1, 1 29] [-1,1 28] / exp cl;
estimate '30 vs 28' spl [1,30] [-1,28] spl*parity [1, 1 30] [-1,1 28] / exp cl;
estimate '31 vs 28' spl [1,31] [-1,28] spl*parity [1, 1 31] [-1,1 28] / exp cl;
estimate '32 vs 28' spl [1,32] [-1,28] spl*parity [1, 1 32] [-1,1 28] / exp cl;
estimate '33 vs 28' spl [1,33] [-1,28] spl*parity [1, 1 33] [-1,1 28] / exp cl;
estimate '34 vs 28' spl [1,34] [-1,28] spl*parity [1, 1 34] [-1,1 28] / exp cl;
estimate '35 vs 28' spl [1,35] [-1,28] spl*parity [1, 1 35] [-1,1 28] / exp cl;
estimate '36 vs 28' spl [1,36] [-1,28] spl*parity [1, 1 36] [-1,1 28] / exp cl;
estimate '37 vs 28' spl [1,37] [-1,28] spl*parity [1, 1 37] [-1,1 28] / exp cl;
estimate '38 vs 28' spl [1,38] [-1,28] spl*parity [1, 1 38] [-1,1 28] / exp cl;
estimate '39 vs 28' spl [1,39] [-1,28] spl*parity [1, 1 39] [-1,1 28] / exp cl;
estimate '40 vs 28' spl [1,40] [-1,28] spl*parity [1, 1 40] [-1,1 28] / exp cl;
estimate '41 vs 28' spl [1,41] [-1,28] spl*parity [1, 1 41] [-1,1 28] / exp cl;
estimate '42 vs 28' spl [1,42] [-1,28] spl*parity [1, 1 42] [-1,1 28] / exp cl;
estimate '43 vs 28' spl [1,43] [-1,28] spl*parity [1, 1 43] [-1,1 28] / exp cl;
estimate '44 vs 28' spl [1,44] [-1,28] spl*parity [1, 1 44] [-1,1 28] / exp cl;
	ods output Estimates=e_iud_final0kid;
	ods output FitStatistics=fs_iud_int_final0kid;
	ods output OddsRatios=or_iud_int_final0kid;
	ods output ModelANOVA=jt_iud_int_final0kid;
	run;


title 'iud Use, Final Model, parity set to 2 kids';
proc surveylogistic data=a;
	class iud (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &full edu*agebabycat hisprace2*agebabycat spl*povlev spl*hisprace2
	spl*parity;
	estimate '23 vs 28' spl [1,23] [-1,28] spl*parity [1, 3 23] [-1,3 28] / exp cl;
	estimate '24 vs 28' spl [1,24] [-1,28] spl*parity [1, 3 24] [-1,3 28] / exp cl;
	estimate '25 vs 28' spl [1,25] [-1,28] spl*parity [1, 3 25] [-1,3 28] / exp cl;
	estimate '26 vs 28' spl [1,26] [-1,28] spl*parity [1, 3 26] [-1,3 28] / exp cl;
	estimate '27 vs 28' spl [1,27] [-1,28] spl*parity [1, 3 27] [-1,3 28] / exp cl;
	estimate '28 vs 28' spl [1,28] [-1,28] spl*parity [1, 3 28] [-1,3 28] / exp cl;
	estimate '29 vs 28' spl [1,29] [-1,28] spl*parity [1, 3 29] [-1,3 28] / exp cl;
	estimate '30 vs 28' spl [1,30] [-1,28] spl*parity [1, 3 30] [-1,3 28] / exp cl;
	estimate '31 vs 28' spl [1,31] [-1,28] spl*parity [1, 3 31] [-1,3 28] / exp cl;
	estimate '32 vs 28' spl [1,32] [-1,28] spl*parity [1, 3 32] [-1,3 28] / exp cl;
	estimate '33 vs 28' spl [1,33] [-1,28] spl*parity [1, 3 33] [-1,3 28] / exp cl;
	estimate '34 vs 28' spl [1,34] [-1,28] spl*parity [1, 3 34] [-1,3 28] / exp cl;
	estimate '35 vs 28' spl [1,35] [-1,28] spl*parity [1, 3 35] [-1,3 28] / exp cl;
	estimate '36 vs 28' spl [1,36] [-1,28] spl*parity [1, 3 36] [-1,3 28] / exp cl;
	estimate '37 vs 28' spl [1,37] [-1,28] spl*parity [1, 3 37] [-1,3 28] / exp cl;
	estimate '38 vs 28' spl [1,38] [-1,28] spl*parity [1, 3 38] [-1,3 28] / exp cl;
	estimate '39 vs 28' spl [1,39] [-1,28] spl*parity [1, 3 39] [-1,3 28] / exp cl;
	estimate '40 vs 28' spl [1,40] [-1,28] spl*parity [1, 3 40] [-1,3 28] / exp cl;
	estimate '41 vs 28' spl [1,41] [-1,28] spl*parity [1, 3 41] [-1,3 28] / exp cl;
	estimate '42 vs 28' spl [1,42] [-1,28] spl*parity [1, 3 42] [-1,3 28] / exp cl;
	estimate '43 vs 28' spl [1,43] [-1,28] spl*parity [1, 3 43] [-1,3 28] / exp cl;
	estimate '44 vs 28' spl [1,44] [-1,28] spl*parity [1, 3 44] [-1,3 28] / exp cl;
	ods output Estimates=e_iud_final2kid;
	ods output FitStatistics=fs_iud_int_final2kid;
	ods output OddsRatios=or_iud_int_final2kid;
	run;


* Making graphs with estimates;
%let estimates = e_iud_final0kid e_iud_final2kid;
%let estimates = e_iud2_1 e_iud2_2;

*change output estimates so the data labels fit;
%macro rounding1;
%let i=1;
%do %until(not %length(%scan(&estimates,&i)));
data %scan(&estimates,&i); set %scan(&estimates,&i);
	ORR=round(ExpEstimate,.01);
	LCLR=round(LowerExp,.01);
	UCLR=round(UpperExp,.01);
	title %scan(&estimates,&i);
	run;
%let i=%eval(&i+1);
%end;
%mend;

%rounding1;

*getting an error about 0 in the hipl group, my rounding may be a problem;
proc print data=e_tub_finalhipl; run;

*yep, the rounding is causing LCLR at the lowest ages to be 0.00;

*have the fix the two lowest ages LCL by hand;
title;
proc print data=e_tub_finalhipl; run;
data e_tub_finalhipl; set e_tub_finalhipl;
	if Label="23 vs 28" then LCLR = 0.0004;
	if Label="24 vs 28" then LCLR = 0.0022;
	run;

*looks like i need to fix midpl as well;
data e_tub_finalmidpl; set e_tub_finalmidpl;
	if Label="23 vs 28" then LCLR = 0.0001;
	if Label="24 vs 28" then LCLR = 0.0008;
	run;	

%macro ditto;
%let i=1;
%do %until(not %length(%scan(&estimates,&i)));
proc sgplot data=%scan(&estimates,&i);
	vbarparm category=Label response=ORR /
	datalabel=ORR
	baseline=1 groupdisplay=cluster
	limitlower=LCLR limitupper=UCLR;
	refline "28 vs 28" / axis=x label="Ref";
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e max=20;
	title1 "IUD Use vs Other Contraceptive Use";
	title2 %scan(&estimates,&i);
	run;
%let i=%eval(&i+1);
%end;
%mend ditto;

%ditto;

*Testing merging datasets so I can make overlapping graphs;

proc print data=e_iud_final0kid; run;
proc print data=e_iud_final2kid; run;

data iud_0kid; set e_iud_final0kid;
	rename ORR = ORR_0kid;
	rename LCLR = LCLR_0kid;
	rename UCLR = UCLR_0kid;
	drop Estimate StdErr DF tValue Probt Alpha Lower Upper ExpEstimate LowerExp UpperExp;
	run;

	proc print data=iud_0kid; run;

data iud_2kid; set e_iud_final2kid;
	rename ORR = ORR_2kid;
	rename LCLR = LCLR_2kid;
	rename UCLR = UCLR_2kid;
	drop Estimate StdErr DF tValue Probt Alpha Lower Upper ExpEstimate LowerExp UpperExp;
	run;

	proc print data=iud_2kid; run;

data iud; 
	merge iud_0kid iud_2kid; by Label; run;
	proc print data=iud; run;

	proc sgplot data=iud;
	vbarparm category=Label response=ORR_0kid /
	datalabel=ORR_0kid
	baseline=1 groupdisplay=cluster
	limitlower=LCLR_0kid limitupper=UCLR_0kid;
	vbarparm category=Label response=ORR_2kid /
	datalabel=ORR_2kid
	baseline=1 groupdisplay=cluster
	limitlower=LCLR_2kid limitupper=LCLR_2kid;
	refline "28 vs 28" / axis=x label="Ref";
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e max=20;
	title1 "IUD Use vs Other Contraceptive Use";
	run;


title 'iud Use, Final Model, parity set to 2 kids, looking @ povlev 1';
proc surveylogistic data=a;
	class iud (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &full edu*hisprace2 edu*agebabycat hisprace2*agebabycat
	spl*parity;
	estimate '23 vs 28' spl [1,23] [-1,28] povlev 6 spl*parity [1, 3 23] [-1,3 28] / exp cl;
	estimate '24 vs 28' spl [1,24] [-1,28] povlev 6 spl*parity [1, 3 24] [-1,3 28] / exp cl;
	estimate '25 vs 28' spl [1,25] [-1,28] povlev 6 spl*parity [1, 3 25] [-1,3 28] / exp cl;
	estimate '26 vs 28' spl [1,26] [-1,28] povlev 6 spl*parity [1, 3 26] [-1,3 28] / exp cl;
	estimate '27 vs 28' spl [1,27] [-1,28] povlev 6 spl*parity [1, 3 27] [-1,3 28] / exp cl;
	estimate '28 vs 28' spl [1,28] [-1,28] povlev 6 spl*parity [1, 3 28] [-1,3 28] / exp cl;
	estimate '29 vs 28' spl [1,29] [-1,28] povlev 6 spl*parity [1, 3 29] [-1,3 28] / exp cl;
	estimate '30 vs 28' spl [1,30] [-1,28] povlev 6 spl*parity [1, 3 30] [-1,3 28] / exp cl;
	estimate '31 vs 28' spl [1,31] [-1,28] povlev 6 spl*parity [1, 3 31] [-1,3 28] / exp cl;
	estimate '32 vs 28' spl [1,32] [-1,28] povlev 6 spl*parity [1, 3 32] [-1,3 28] / exp cl;
	estimate '33 vs 28' spl [1,33] [-1,28] povlev 6 spl*parity [1, 3 33] [-1,3 28] / exp cl;
	estimate '34 vs 28' spl [1,34] [-1,28] povlev 6 spl*parity [1, 3 34] [-1,3 28] / exp cl;
	estimate '35 vs 28' spl [1,35] [-1,28] povlev 6 spl*parity [1, 3 35] [-1,3 28] / exp cl;
	estimate '36 vs 28' spl [1,36] [-1,28] povlev 6 spl*parity [1, 3 36] [-1,3 28] / exp cl;
	estimate '37 vs 28' spl [1,37] [-1,28] povlev 6 spl*parity [1, 3 37] [-1,3 28] / exp cl;
	estimate '38 vs 28' spl [1,38] [-1,28] povlev 6 spl*parity [1, 3 38] [-1,3 28] / exp cl;
	estimate '39 vs 28' spl [1,39] [-1,28] povlev 6 spl*parity [1, 3 39] [-1,3 28] / exp cl;
	estimate '40 vs 28' spl [1,40] [-1,28] povlev 6 spl*parity [1, 3 40] [-1,3 28] / exp cl;
	estimate '41 vs 28' spl [1,41] [-1,28] povlev 6 spl*parity [1, 3 41] [-1,3 28] / exp cl;
	estimate '42 vs 28' spl [1,42] [-1,28] povlev 6 spl*parity [1, 3 42] [-1,3 28] / exp cl;
	estimate '43 vs 28' spl [1,43] [-1,28] povlev 6 spl*parity [1, 3 43] [-1,3 28] / exp cl;
	estimate '44 vs 28' spl [1,44] [-1,28] povlev 6 spl*parity [1, 3 44] [-1,3 28] / exp cl;
	ods output Estimates=e_iud2_1;
	run;

	title 'iud Use, Final Model, parity set to 2 kids, looking @ povlev 1';
proc surveylogistic data=a;
	class iud (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &full edu*hisprace2 edu*agebabycat hisprace2*agebabycat
	spl*parity;
	estimate '23 vs 28' spl [1,23] [-1,28] povlev 5 spl*parity [1, 3 23] [-1,3 28] / exp cl;
	estimate '24 vs 28' spl [1,24] [-1,28] povlev 5 spl*parity [1, 3 24] [-1,3 28] / exp cl;
	estimate '25 vs 28' spl [1,25] [-1,28] povlev 5 spl*parity [1, 3 25] [-1,3 28] / exp cl;
	estimate '26 vs 28' spl [1,26] [-1,28] povlev 5 spl*parity [1, 3 26] [-1,3 28] / exp cl;
	estimate '27 vs 28' spl [1,27] [-1,28] povlev 5 spl*parity [1, 3 27] [-1,3 28] / exp cl;
	estimate '28 vs 28' spl [1,28] [-1,28] povlev 5 spl*parity [1, 3 28] [-1,3 28] / exp cl;
	estimate '29 vs 28' spl [1,29] [-1,28] povlev 5 spl*parity [1, 3 29] [-1,3 28] / exp cl;
	estimate '30 vs 28' spl [1,30] [-1,28] povlev 5 spl*parity [1, 3 30] [-1,3 28] / exp cl;
	estimate '31 vs 28' spl [1,31] [-1,28] povlev 5 spl*parity [1, 3 31] [-1,3 28] / exp cl;
	estimate '32 vs 28' spl [1,32] [-1,28] povlev 5 spl*parity [1, 3 32] [-1,3 28] / exp cl;
	estimate '33 vs 28' spl [1,33] [-1,28] povlev 5 spl*parity [1, 3 33] [-1,3 28] / exp cl;
	estimate '34 vs 28' spl [1,34] [-1,28] povlev 5 spl*parity [1, 3 34] [-1,3 28] / exp cl;
	estimate '35 vs 28' spl [1,35] [-1,28] povlev 5 spl*parity [1, 3 35] [-1,3 28] / exp cl;
	estimate '36 vs 28' spl [1,36] [-1,28] povlev 5 spl*parity [1, 3 36] [-1,3 28] / exp cl;
	estimate '37 vs 28' spl [1,37] [-1,28] povlev 5 spl*parity [1, 3 37] [-1,3 28] / exp cl;
	estimate '38 vs 28' spl [1,38] [-1,28] povlev 5 spl*parity [1, 3 38] [-1,3 28] / exp cl;
	estimate '39 vs 28' spl [1,39] [-1,28] povlev 5 spl*parity [1, 3 39] [-1,3 28] / exp cl;
	estimate '40 vs 28' spl [1,40] [-1,28] povlev 5 spl*parity [1, 3 40] [-1,3 28] / exp cl;
	estimate '41 vs 28' spl [1,41] [-1,28] povlev 5 spl*parity [1, 3 41] [-1,3 28] / exp cl;
	estimate '42 vs 28' spl [1,42] [-1,28] povlev 5 spl*parity [1, 3 42] [-1,3 28] / exp cl;
	estimate '43 vs 28' spl [1,43] [-1,28] povlev 5 spl*parity [1, 3 43] [-1,3 28] / exp cl;
	estimate '44 vs 28' spl [1,44] [-1,28] povlev 5 spl*parity [1, 3 44] [-1,3 28] / exp cl;
	ods output Estimates=e_iud2_2;
	run;


************************************
*** FINAL MODEL WITH INTERACTION ***
************************************;

%macro teen;
%do x=23 %to 43 %by 1;
	"&x, 15-19 vs >24/0" intercept 0 spl [0,&x] earlybirth [1,1] [-1,3] 
		spl*earlybirth [1,1 &x] [-1,3 &x],
	%end;
	"44, 15-19 vs >24/0" intercept 0 spl [0,44] earlybirth [1,1] [-1,3] 
		spl*earlybirth [1,1 44] [-1,3 44]
	%mend;

%macro earlytwenties;
%do x=23 %to 43 %by 1;
	"&x, 20-24 vs >24/0" intercept 0 spl [0,&x] earlybirth [1,2] [-1,3] 
		spl*earlybirth [1,2 &x] [-1,3 &x],
	%end;
	"44, 20-24 vs >24/0" intercept 0 spl [0,44] earlybirth [1,2] [-1,3] 
		spl*earlybirth [1,2 44] [-1,3 44]
	%mend;

proc surveylogistic data=a;
	class iud(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl;
	estimate %earlytwenties / exp cl;
	ods output Estimates=e;
	run;

data e_iud2; set e;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	ORR=round(ExpEstimate,.1);
	LCLR=round(LowerExp,.1);
	UCLR=round(UpperExp,.1);
	Label2=substr(Label,1,2);
	run;

title1 "IUD Use by Age & Age at First Birth";
title2 "Among Women Not Using Tubal or Vasectomy";
proc sgplot data=e_iud2;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=ORR / group=earlybirth datalabel=ORR
	/*groupdisplay=overlay*/;
	refline 1 / axis=y label="OR=1.0";
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e logstyle=linear 
	values=(0.1 0.5 1 2 3 5 7.5 10 15 20);
	run;



