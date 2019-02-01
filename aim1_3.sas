*############################################*
*######### McWilliams Dissertation ##########*
*##### Aim 1 Logistic Regression Model 2 ####*
*########## Tubal vs Anything Else ##########*
*############################################*;

libname library "U:\Dissertation";
%include "U:\Dissertation\nsfg_CMcWFormats.sas";
data a; set library.nsfg; run;

*Removing respondents under 23;
data a; set a;
	if rscrage < 23 then delete;
	run;

ods trace on;
ods graphics on / reset=index imagename="tub_age";
ods listing gpath = "U:\Dissertation\sas_graphs_tub";

*DESCRIPTIVES FOR tub VS NOT;
proc freq data=a; tables tub; ods output onewayfreqs=tubfreq; run;
proc print data=tubfreq; format tub 3.1; run;

	*formatting to make dataset look nicer;
	data tubfreq; set tubfreq;
		drop f_tub Table CumFrequency CumPercent;
		rename tub = tub;
		run;

	proc print data=tubfreq; run;
	proc export data=tubfreq outfile="U:\Dissertation\xls_graphs\tubfreq.xlsx"
	dbms=xlsx replace; run;

proc freq data=a; tables rscrage*tub; weight weightvar; ods output CrossTabFreqs=tub_age;
run;
proc print data=tub_age; run;
proc sgplot data=tub_age;
	vbar rscrage / Response=RowPercent;
	where tub = 1;
	run;

* Adding a graph that includes vasectomy for good measure;
proc freq data=a; tables rscrage*vas; weight weightvar; ods output CrossTabFreqs=vas_age;
run;
proc print data=vas_age; run;
proc sgplot data=vas_age;
	vbar rscrage / Response=RowPercent;
	where vas=1;
	run;

*Tubal use by covariates;

%let var = tub;

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
	ods output CrossTabFreqs=tub_%scan(&confounders,&i);
	run;
	%let i=%eval(&i+1);
	%end;
	%mend ditto;

	%ditto;

	proc print data=tub_edu; run;
	proc sgplot data=tub_edu; 
		vbar edu / response=ColPercent;
		where tub = 1;
		run;

	data tub_edu; set tub_edu;
		if tub ne 1 then delete;
		if edu = . then delete;
		drop Table _TYPE_ _TABLE_ Frequency Missing;
		run;
		proc print data=tub_edu; run;

%let ds = 
	tub_edu
	tub_hisprace2
	tub_povlev
	tub_agebabycat
	tub_parity
	tub_rwant
	tub_mard
	tub_curr_ins;

%macro ds;
	%let i=1;
	%do %until(not %length(%scan(&ds,&i)));
	data %scan(&ds,&i); set %scan(&ds,&i);
		if tub ne 1 then delete;
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
		outfile="U:\Dissertation\xls_graphs\tub.xlsx"
		dbms=xlsx
		replace;
		sheet="%scan(&ds,&i)";
		run;
		%let i=%eval(&i+1);
		%end;
		%mend worksheets;

		%worksheets;

title 'tub = age';
proc surveylogistic data=a;
	class
		tub (ref=first);
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl;
	output out=tub pred=pred;
	run;

proc sgplot data=tub;
	scatter y=pred x=rscrage;
	run;

*** BIVARIATE BETWEEN tub AND AGE, WITH ESTIMATES ***;

proc surveylogistic data=a;
	class tub (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl;
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
	ods output Estimates=e_tub;
	ods output FitStatistics=fs_tub;
	ods output OddsRatios=or_tub;
	ods output ModelANOVA=jt_tub;
	run;

data e_tub; set e_tub;
	ORR=round(ExpEstimate,.01);
	LCLR=round(LowerExp,.01);
	UCLR=round(UpperExp,.01);
	title 'Bivariate tub use by age, fitted with spline';
	run;

proc sgplot data=e_tub;
	vbarparm category=Label response=ORR /
	datalabel=ORR
	baseline=1 groupdisplay=cluster
	limitlower=LCLR limitupper=UCLR;
	refline "28vs 28" / axis=x label="Ref";
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e;
	title1 'Bivariate tub use by age, fitted with spline';
	run;

%let dem = edu hisprace2 povlev;
%let demfert = edu hisprace2 povlev agebabycat parity rwant mard;
%let full = edu hisprace2 povlev agebabycat parity rwant mard curr_ins;


*** tub USE REGRESSED ON AGE AND DEMOGRAPHIC VARS ***;

proc surveylogistic data=a;
	class tub (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl &dem;
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
	ods output Estimates=e_tub_dem;
	ods output FitStatistics=fs_tub_dem;
	ods output OddsRatios=or_tub_dem;
	ods output ModelANOVA=jt_tub_dem;
	run;


*** tub USE REGRESSED ON AGE, DEMOGRAPHIC, AND FERTILITY VARS ***;
title;
proc surveylogistic data=a;
	class tub (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl &demfert;
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
	ods output Estimates=e_tub_demfert;
	ods output FitStatistics=fs_tub_demfert;
	ods output OddsRatios=or_tub_demfert;
	ods output ModelANOVA=jt_tub_demfert;
	run;


*** tub USE REGRESSED ON AGE AND ALL COVARIATES ***;

proc surveylogistic data=a;
	class tub (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl &full;
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
	ods output Estimates=e_tub_main;
	ods output FitStatistics=fs_tub_main;
	ods output OddsRatios=or_tub_main;
	ods output ModelANOVA=jt_tub_main;
	run;


* CREATING ODDS RATIO TABLES AND ESTIMATE PLOTS FOR MAIN EFFECTS;

* Estimates first;
%let estimates = e_tub_dem e_tub_demfert e_tub_main;

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
	title1 "tub Use vs Other Contraceptive Use";
	title2 %scan(&estimates,&i);
	run;
%let i=%eval(&i+1);
%end;
%mend ditto;

%ditto;


*** STRATIFIED tub USE ***;

%macro stratified1;
%do i=3 %to 7;
proc surveylogistic data=a;
	class agecat (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref=first)
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	model tub = edu hisprace2 povlev agebabycat parity rwant mard;
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

data tub_strat;
   merge &orr;
   by Effect;
run;

proc export data=tub_strat
	outfile = "U:\Dissertation\xls_graphs\tub_strat2"
	dbms = xlsx
	replace;
	run;


*** tub USE REGRESSED ON ALL MAIN EFFECTS AND ALL SUSPECTED INTERACTIONS ***;

proc surveylogistic data=a;
	class tub (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl &full edu*hisprace2 edu*agebabycat hisprace2*agebabycat
	spl*edu spl*hisprace2 spl*povlev spl*parity spl*mard;
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
	ods output Estimates=e_tub_int;
	ods output FitStatistics=fs_tub_int;
	ods output OddsRatios=or_tub_int;
	ods output ModelANOVA=jt_tub_int;
	run;

proc export data=jt_tub_int
	outfile="U:\Dissertation\xls_graphs\jt_tub_int.xlsx"
	dbms=xlsx;
	run;

*** TUBAL USE, FINAL MODEL (I THINK) ***;

*first, where to set poverty level;
proc freq data=a; tables povlev; weight weightvar; run;
*the largest group is <100%, so I will start there;
*https://www.needymeds.org/poverty-guidelines-percents;

proc freq data=a; tables parity; where povlev = 1 and hisprace2 = 2; run;
*starting with largest groups for estimate statements - lowest povlev, NHW, 2 babies;

title 'tub Use, Final Model, Running for class levels';
proc surveylogistic data=a;
	class tub (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl &full edu*agebabycat hisprace2*agebabycat spl*povlev spl*hisprace2
	spl*parity;
	estimate '23 vs 28' spl [1,23] [-1,28] / e exp cl;
	/*estimate '24 vs 28' spl [1,24] [-1,28] spl*povlev [1, 1 24 ] [-1,1 28] / exp cl;
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
	ods output Estimates=e_tub_final;
	ods output FitStatistics=fs_tub_int_final;
	ods output OddsRatios=or_tub_int_final;
	ods output ModelANOVA=jt_tub_int_final;*/
	ods output ClassLevelInfo=class_tub;
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
