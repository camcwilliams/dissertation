*############################################*
*######### McWilliams Dissertation ##########*
*##### Aim 1 Logistic Regression Model 2 ####*
*######### IUD Use vs Anything Else #########*
*############################################*;

libname library "U:\Dissertation";
%include "U:\Dissertation\nsfg_CMcWFormats.sas";
data a; set library.nsfg; run;

*Removing respondents under 23;
data a; set a;
	if rscrage < 23 then delete;
	run;

proc freq data=a; tables iud; run;
proc freq data=a; tables bc*iud; run;

ods trace on;
ods graphics on / reset=index imagename="iud_age";
ods listing gpath = "U:\Dissertation\sas_graphs_iud";

*DESCRIPTIVES FOR IUD VS NOT;
proc freq data=a; tables iud; ods output onewayfreqs=iudfreq; run;
proc print data=iudfreq; format iud 3.1; run;

	*formatting to make dataset look nicer;
	data iudfreq; set iudfreq;
		drop f_iud Table CumFrequency CumPercent;
		rename iud = IUD;
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
	tables iud*(%scan(&confounders,&i)) / nopercent norow nofreq;
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
		outfile="U:\Dissertation\xls_graphs\IUD.xlsx"
		dbms=xlsx
		replace;
		sheet="%scan(&ds,&i)";
		run;
		%let i=%eval(&i+1);
		%end;
		%mend worksheets;

		%worksheets;

proc freq data=a; 
	tables iud*agebabycat / nopercent norow nofreq;
	weight weightvar;
	ods output CrossTabFreqs=iud_agebabycat;
	run;
	proc print data=iud_agebabycat; run;
	data iud_agebabycat; set iud_agebabycat;
		if iud ne 1 then delete;
		drop Table _TYPE_ _TABLE_ Frequency Missing;
		run;	

	proc print data=iud_curr_ins; run;

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

*** BIVARIATE BETWEEN IUD AND AGE, WITH ESTIMATES ***;

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

proc print data=e_iud; run;

data e_iud; set e_iud;
	ORR=round(ExpEstimate,.01);
	LCLR=round(LowerExp,.01);
	UCLR=round(UpperExp,.01);
	title 'Bivariate IUD use by age, fitted with spline';
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
	title1 'Bivariate IUD use by age, fitted with spline';
	run;

%let dem = edu hisprace2 povlev;
%let demfert = edu hisprace2 povlev agebabycat parity rwant mard;
%let full = edu hisprace2 povlev agebabycat parity rwant mard curr_ins;


*** IUD USE REGRESSED ON AGE AND DEMOGRAPHIC VARS ***;

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


*** IUD USE REGRESSED ON AGE, DEMOGRAPHIC, AND FERTILITY VARS ***;
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


*** IUD USE REGRESSED ON AGE AND ALL COVARIATES ***;

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
	title1 "IUD Use vs Other Contraceptive Use";
	title2 %scan(&estimates,&i);
	run;
%let i=%eval(&i+1);
%end;
%mend ditto;

%ditto;


*** STRATIFIED IUD USE ***;

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

proc print data=or_1strat5; run;

data iud_strat;
   merge &orr;
   by Effect;
run;

proc export data=iud_strat
	outfile = "U:\Dissertation\xls_graphs\iud_strat2"
	dbms = xlsx
	replace;
	run;


*** IUD USE REGRESSED ON ALL MAIN EFFECTS AND ALL SUSPECTED INTERACTIONS ***;

proc surveylogistic data=a;
	class iud (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &full edu*hisprace2 edu*agebabycat hisprace2*agebabycat
	spl*edu spl*hisprace2 spl*povlev spl*parity spl*rwant spl*mard;
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
	outfile="U:\Dissertation\xls_graphs\jt_iud_int.xlsx"
	dbms=xlsx;
	run;

*** IUD USE, FINAL MODEL ***;

*first, where to set poverty level;
proc freq data=a; tables povlev; weight weightvar; run;
*the largest group is <100%, so I will start there;
*https://www.needymeds.org/poverty-guidelines-percents;

title 'IUD Use, Final Model, % FPL set to <100%';
proc surveylogistic data=a;
	class iud (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &full edu*agebabycat hisprace2*agebabycat
	spl*povlev;
	estimate '23 vs 28' spl [1,23] [-1,28] spl*povlev [1, 1 23 ] [-1,1 28] / exp cl;
	estimate '24 vs 28' spl [1,24] [-1,28] spl*povlev [1, 1 24 ] [-1,1 28] / exp cl;
	estimate '25 vs 28' spl [1,25] [-1,28] spl*povlev [1, 1 25 ] [-1,1 28] / exp cl;
	estimate '26 vs 28' spl [1,26] [-1,28] spl*povlev [1, 1 26 ] [-1,1 28] / exp cl;
	estimate '27 vs 28' spl [1,27] [-1,28] spl*povlev [1, 1 27 ] [-1,1 28] / exp cl;
	estimate '28 vs 28' spl [1,28] [-1,28] spl*povlev [1, 1 28 ] [-1,1 28] / exp cl;
	estimate '29 vs 28' spl [1,29] [-1,28] spl*povlev [1, 1 29 ] [-1,1 28] / exp cl;
	estimate '30 vs 28' spl [1,30] [-1,28] spl*povlev [1, 1 30 ] [-1,1 28] / exp cl;
	estimate '31 vs 28' spl [1,31] [-1,28] spl*povlev [1, 1 31 ] [-1,1 28] / exp cl;
	estimate '32 vs 28' spl [1,32] [-1,28] spl*povlev [1, 1 32 ] [-1,1 28] / exp cl;
	estimate '33 vs 28' spl [1,33] [-1,28] spl*povlev [1, 1 33 ] [-1,1 28] / exp cl;
	estimate '34 vs 28' spl [1,34] [-1,28] spl*povlev [1, 1 34 ] [-1,1 28] / exp cl;
	estimate '35 vs 28' spl [1,35] [-1,28] spl*povlev [1, 1 35 ] [-1,1 28] / exp cl;
	estimate '36 vs 28' spl [1,36] [-1,28] spl*povlev [1, 1 36 ] [-1,1 28] / exp cl;
	estimate '37 vs 28' spl [1,37] [-1,28] spl*povlev [1, 1 37 ] [-1,1 28] / exp cl;
	estimate '38 vs 28' spl [1,38] [-1,28] spl*povlev [1, 1 38 ] [-1,1 28] / exp cl;
	estimate '39 vs 28' spl [1,39] [-1,28] spl*povlev [1, 1 39 ] [-1,1 28] / exp cl;
	estimate '40 vs 28' spl [1,40] [-1,28] spl*povlev [1, 1 40 ] [-1,1 28] / exp cl;
	estimate '41 vs 28' spl [1,41] [-1,28] spl*povlev [1, 1 41 ] [-1,1 28] / exp cl;
	estimate '42 vs 28' spl [1,42] [-1,28] spl*povlev [1, 1 42 ] [-1,1 28] / exp cl;
	estimate '43 vs 28' spl [1,43] [-1,28] spl*povlev [1, 1 43 ] [-1,1 28] / exp cl;
	estimate '44 vs 28' spl [1,44] [-1,28] spl*povlev [1, 1 44 ] [-1,1 28] / exp cl;
	ods output Estimates=e_iud_finallowpl;
	ods output FitStatistics=fs_iud_int_finallowpl;
	ods output OddsRatios=or_iud_int_finallowpl;
	ods output ModelANOVA=jt_iud_int_finallowpl;
	run;


title 'IUD Use, Final Model, % FPL set to 500%+';
proc surveylogistic data=a;
	class iud (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &full edu*agebabycat hisprace2*agebabycat
	spl*povlev;
	estimate '23 vs 28' spl [1,23] [-1,28] spl*povlev [1, 5 23] [-1,5 28] / exp cl;
	estimate '24 vs 28' spl [1,24] [-1,28] spl*povlev [1, 5 24] [-1,5 28] / exp cl;
	estimate '25 vs 28' spl [1,25] [-1,28] spl*povlev [1, 5 25] [-1,5 28] / exp cl;
	estimate '26 vs 28' spl [1,26] [-1,28] spl*povlev [1, 5 26] [-1,5 28] / exp cl;
	estimate '27 vs 28' spl [1,27] [-1,28] spl*povlev [1, 5 27] [-1,5 28] / exp cl;
	estimate '28 vs 28' spl [1,28] [-1,28] spl*povlev [1, 5 28] [-1,5 28] / exp cl;
	estimate '29 vs 28' spl [1,29] [-1,28] spl*povlev [1, 5 29] [-1,5 28] / exp cl;
	estimate '30 vs 28' spl [1,30] [-1,28] spl*povlev [1, 5 30] [-1,5 28] / exp cl;
	estimate '31 vs 28' spl [1,31] [-1,28] spl*povlev [1, 5 31] [-1,5 28] / exp cl;
	estimate '32 vs 28' spl [1,32] [-1,28] spl*povlev [1, 5 32] [-1,5 28] / exp cl;
	estimate '33 vs 28' spl [1,33] [-1,28] spl*povlev [1, 5 33] [-1,5 28] / exp cl;
	estimate '34 vs 28' spl [1,34] [-1,28] spl*povlev [1, 5 34] [-1,5 28] / exp cl;
	estimate '35 vs 28' spl [1,35] [-1,28] spl*povlev [1, 5 35] [-1,5 28] / exp cl;
	estimate '36 vs 28' spl [1,36] [-1,28] spl*povlev [1, 5 36] [-1,5 28] / exp cl;
	estimate '37 vs 28' spl [1,37] [-1,28] spl*povlev [1, 5 37] [-1,5 28] / exp cl;
	estimate '38 vs 28' spl [1,38] [-1,28] spl*povlev [1, 5 38] [-1,5 28] / exp cl;
	estimate '39 vs 28' spl [1,39] [-1,28] spl*povlev [1, 5 39] [-1,5 28] / exp cl;
	estimate '40 vs 28' spl [1,40] [-1,28] spl*povlev [1, 5 40] [-1,5 28] / exp cl;
	estimate '41 vs 28' spl [1,41] [-1,28] spl*povlev [1, 5 41] [-1,5 28] / exp cl;
	estimate '42 vs 28' spl [1,42] [-1,28] spl*povlev [1, 5 42] [-1,5 28] / exp cl;
	estimate '43 vs 28' spl [1,43] [-1,28] spl*povlev [1, 5 43] [-1,5 28] / exp cl;
	estimate '44 vs 28' spl [1,44] [-1,28] spl*povlev [1, 5 44] [-1,5 28] / exp cl;
	ods output Estimates=e_iud_finalhipl;
	ods output FitStatistics=fs_iud_int_finalhipl;
	ods output OddsRatios=or_iud_int_finalhipl;
	ods output ModelANOVA=jt_iud_int_finalhipl;
	run;

* Making graphs with estimates;
%let estimates = e_iud_finallowpl e_iud_finalhipl;

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
	title1 "IUD Use vs Other Contraceptive Use";
	title2 %scan(&estimates,&i);
	run;
%let i=%eval(&i+1);
%end;
%mend ditto;

%ditto;
