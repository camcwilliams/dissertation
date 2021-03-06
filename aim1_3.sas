*############################################*
*######### McWilliams Dissertation ##########*
*##### Aim 1 Logistic Regression Model 2 ####*
*########## Tubal vs Anything Else ##########*
*############################################*;

libname library "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\nsfg_CMcWFormats.sas";
data a; set library.nsfg; run;

ods trace on;
ods graphics on / reset=index imagename="tub_age";
ods listing gpath = "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\sas_graphs_tub";

*DESCRIPTIVES FOR tub VS NOT;
proc freq data=a; tables tub; ods output onewayfreqs=tubfreq; run;
proc print data=tubfreq; format tub 3.1; run;
proc freq data=a; tables tub; weight weightvar; run;

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
	format rscrage _all_;
	where tub = 1;
	xaxis label = "Age";
	yaxis label = "Percent";
	run;

proc freq data=a; tables pov*tub; weight weightvar; ods output CrossTabFreqs=tub_pov; run;
proc print data=tub_pov; run;

proc sgplot data=tub_pov;
	vbar pov / Response=RowPercent;
	where tub=1;
	xaxis label = "Household Income, % FPL";
	yaxis label = "Percent";
	run;

*doing cross tab to move to excel and plot age and poverty;
proc freq data=a; tables agecat*pov; weight weightvar; ods output CrossTabFreqs=age_pov; run;
proc print data=age_pov; run;


* Adding a graph that includes vasectomy for good measure;
proc freq data=a; tables vas; weight weightvar; run;
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

	proc means data=tub; var pred; where rscrage=40; run;

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
%let full = edud hisprace2 povlev agebabycat parityd rwant mard curr_ins;


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

*ran for class levels and am printing here, won't save the code but it's on github;
proc print data=class_tub; run;

title 'tub Use, Final Model, % FPL set to <100%';
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
estimate '23 vs 28' spl [1,23] [-1,28] spl*povlev [1, 6 23] [-1,6 28] spl*hisprace2 [1, 4 23] [-1,4 28] spl*parity [1,3 23] [-1,3 28] / exp cl;
estimate '24 vs 28' spl [1,24] [-1,28] spl*povlev [1, 6 24] [-1,6 28] spl*hisprace2 [1, 4 24] [-1,4 28] spl*parity [1,3 24] [-1,3 28] / exp cl;
estimate '25 vs 28' spl [1,25] [-1,28] spl*povlev [1, 6 25] [-1,6 28] spl*hisprace2 [1, 4 25] [-1,4 28] spl*parity [1,3 25] [-1,3 28] / exp cl;
estimate '26 vs 28' spl [1,26] [-1,28] spl*povlev [1, 6 26] [-1,6 28] spl*hisprace2 [1, 4 26] [-1,4 28] spl*parity [1,3 26] [-1,3 28] / exp cl;
estimate '27 vs 28' spl [1,27] [-1,28] spl*povlev [1, 6 27] [-1,6 28] spl*hisprace2 [1, 4 27] [-1,4 28] spl*parity [1,3 27] [-1,3 28] / exp cl;
estimate '28 vs 28' spl [1,28] [-1,28] spl*povlev [1, 6 28] [-1,6 28] spl*hisprace2 [1, 4 28] [-1,4 28] spl*parity [1,3 28] [-1,3 28] / exp cl;
estimate '29 vs 28' spl [1,29] [-1,28] spl*povlev [1, 6 29] [-1,6 28] spl*hisprace2 [1, 4 29] [-1,4 28] spl*parity [1,3 29] [-1,3 28] / exp cl;
estimate '30 vs 28' spl [1,30] [-1,28] spl*povlev [1, 6 30] [-1,6 28] spl*hisprace2 [1, 4 30] [-1,4 28] spl*parity [1,3 30] [-1,3 28] / exp cl;
estimate '31 vs 28' spl [1,31] [-1,28] spl*povlev [1, 6 31] [-1,6 28] spl*hisprace2 [1, 4 31] [-1,4 28] spl*parity [1,3 31] [-1,3 28] / exp cl;
estimate '32 vs 28' spl [1,32] [-1,28] spl*povlev [1, 6 32] [-1,6 28] spl*hisprace2 [1, 4 32] [-1,4 28] spl*parity [1,3 32] [-1,3 28] / exp cl;
estimate '33 vs 28' spl [1,33] [-1,28] spl*povlev [1, 6 33] [-1,6 28] spl*hisprace2 [1, 4 33] [-1,4 28] spl*parity [1,3 33] [-1,3 28] / exp cl;
estimate '34 vs 28' spl [1,34] [-1,28] spl*povlev [1, 6 34] [-1,6 28] spl*hisprace2 [1, 4 34] [-1,4 28] spl*parity [1,3 34] [-1,3 28] / exp cl;
estimate '35 vs 28' spl [1,35] [-1,28] spl*povlev [1, 6 35] [-1,6 28] spl*hisprace2 [1, 4 35] [-1,4 28] spl*parity [1,3 35] [-1,3 28] / exp cl;
estimate '36 vs 28' spl [1,36] [-1,28] spl*povlev [1, 6 36] [-1,6 28] spl*hisprace2 [1, 4 36] [-1,4 28] spl*parity [1,3 36] [-1,3 28] / exp cl;
estimate '37 vs 28' spl [1,37] [-1,28] spl*povlev [1, 6 37] [-1,6 28] spl*hisprace2 [1, 4 37] [-1,4 28] spl*parity [1,3 37] [-1,3 28] / exp cl;
estimate '38 vs 28' spl [1,38] [-1,28] spl*povlev [1, 6 38] [-1,6 28] spl*hisprace2 [1, 4 38] [-1,4 28] spl*parity [1,3 38] [-1,3 28] / exp cl;
estimate '39 vs 28' spl [1,39] [-1,28] spl*povlev [1, 6 39] [-1,6 28] spl*hisprace2 [1, 4 39] [-1,4 28] spl*parity [1,3 39] [-1,3 28] / exp cl;
estimate '40 vs 28' spl [1,40] [-1,28] spl*povlev [1, 6 40] [-1,6 28] spl*hisprace2 [1, 4 40] [-1,4 28] spl*parity [1,3 40] [-1,3 28] / exp cl;
estimate '41 vs 28' spl [1,41] [-1,28] spl*povlev [1, 6 41] [-1,6 28] spl*hisprace2 [1, 4 41] [-1,4 28] spl*parity [1,3 41] [-1,3 28] / exp cl;
estimate '42 vs 28' spl [1,42] [-1,28] spl*povlev [1, 6 42] [-1,6 28] spl*hisprace2 [1, 4 42] [-1,4 28] spl*parity [1,3 42] [-1,3 28] / exp cl;
estimate '43 vs 28' spl [1,43] [-1,28] spl*povlev [1, 6 43] [-1,6 28] spl*hisprace2 [1, 4 43] [-1,4 28] spl*parity [1,3 43] [-1,3 28] / exp cl;
estimate '44 vs 28' spl [1,44] [-1,28] spl*povlev [1, 6 44] [-1,6 28] spl*hisprace2 [1, 4 44] [-1,4 28] spl*parity [1,3 44] [-1,3 28] / exp cl;
	ods output Estimates=e_tub_finallopl;
	ods output FitStatistics=fs_tub_int_finallopl;
	ods output OddsRatios=or_tub_int_finallopl;
	ods output ModelANOVA=jt_tub_int_finallopl;
	run;


title 'tub Use, Final Model, % FPL set to 500%+';
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
estimate '23 vs 28' spl [1,23] [-1,28] spl*povlev [1, 5 23] [-1,5 28] spl*hisprace2 [1, 4 23] [-1,4 28] spl*parity [1,3 23] [-1,3 28] / exp cl;
estimate '24 vs 28' spl [1,24] [-1,28] spl*povlev [1, 5 24] [-1,5 28] spl*hisprace2 [1, 4 24] [-1,4 28] spl*parity [1,3 24] [-1,3 28] / exp cl;
estimate '25 vs 28' spl [1,25] [-1,28] spl*povlev [1, 5 25] [-1,5 28] spl*hisprace2 [1, 4 25] [-1,4 28] spl*parity [1,3 25] [-1,3 28] / exp cl;
estimate '26 vs 28' spl [1,26] [-1,28] spl*povlev [1, 5 26] [-1,5 28] spl*hisprace2 [1, 4 26] [-1,4 28] spl*parity [1,3 26] [-1,3 28] / exp cl;
estimate '27 vs 28' spl [1,27] [-1,28] spl*povlev [1, 5 27] [-1,5 28] spl*hisprace2 [1, 4 27] [-1,4 28] spl*parity [1,3 27] [-1,3 28] / exp cl;
estimate '28 vs 28' spl [1,28] [-1,28] spl*povlev [1, 5 28] [-1,5 28] spl*hisprace2 [1, 4 28] [-1,4 28] spl*parity [1,3 28] [-1,3 28] / exp cl;
estimate '29 vs 28' spl [1,29] [-1,28] spl*povlev [1, 5 29] [-1,5 28] spl*hisprace2 [1, 4 29] [-1,4 28] spl*parity [1,3 29] [-1,3 28] / exp cl;
estimate '30 vs 28' spl [1,30] [-1,28] spl*povlev [1, 5 30] [-1,5 28] spl*hisprace2 [1, 4 30] [-1,4 28] spl*parity [1,3 30] [-1,3 28] / exp cl;
estimate '31 vs 28' spl [1,31] [-1,28] spl*povlev [1, 5 31] [-1,5 28] spl*hisprace2 [1, 4 31] [-1,4 28] spl*parity [1,3 31] [-1,3 28] / exp cl;
estimate '32 vs 28' spl [1,32] [-1,28] spl*povlev [1, 5 32] [-1,5 28] spl*hisprace2 [1, 4 32] [-1,4 28] spl*parity [1,3 32] [-1,3 28] / exp cl;
estimate '33 vs 28' spl [1,33] [-1,28] spl*povlev [1, 5 33] [-1,5 28] spl*hisprace2 [1, 4 33] [-1,4 28] spl*parity [1,3 33] [-1,3 28] / exp cl;
estimate '34 vs 28' spl [1,34] [-1,28] spl*povlev [1, 5 34] [-1,5 28] spl*hisprace2 [1, 4 34] [-1,4 28] spl*parity [1,3 34] [-1,3 28] / exp cl;
estimate '35 vs 28' spl [1,35] [-1,28] spl*povlev [1, 5 35] [-1,5 28] spl*hisprace2 [1, 4 35] [-1,4 28] spl*parity [1,3 35] [-1,3 28] / exp cl;
estimate '36 vs 28' spl [1,36] [-1,28] spl*povlev [1, 5 36] [-1,5 28] spl*hisprace2 [1, 4 36] [-1,4 28] spl*parity [1,3 36] [-1,3 28] / exp cl;
estimate '37 vs 28' spl [1,37] [-1,28] spl*povlev [1, 5 37] [-1,5 28] spl*hisprace2 [1, 4 37] [-1,4 28] spl*parity [1,3 37] [-1,3 28] / exp cl;
estimate '38 vs 28' spl [1,38] [-1,28] spl*povlev [1, 5 38] [-1,5 28] spl*hisprace2 [1, 4 38] [-1,4 28] spl*parity [1,3 38] [-1,3 28] / exp cl;
estimate '39 vs 28' spl [1,39] [-1,28] spl*povlev [1, 5 39] [-1,5 28] spl*hisprace2 [1, 4 39] [-1,4 28] spl*parity [1,3 39] [-1,3 28] / exp cl;
estimate '40 vs 28' spl [1,40] [-1,28] spl*povlev [1, 5 40] [-1,5 28] spl*hisprace2 [1, 4 40] [-1,4 28] spl*parity [1,3 40] [-1,3 28] / exp cl;
estimate '41 vs 28' spl [1,41] [-1,28] spl*povlev [1, 5 41] [-1,5 28] spl*hisprace2 [1, 4 41] [-1,4 28] spl*parity [1,3 41] [-1,3 28] / exp cl;
estimate '42 vs 28' spl [1,42] [-1,28] spl*povlev [1, 5 42] [-1,5 28] spl*hisprace2 [1, 4 42] [-1,4 28] spl*parity [1,3 42] [-1,3 28] / exp cl;
estimate '43 vs 28' spl [1,43] [-1,28] spl*povlev [1, 5 43] [-1,5 28] spl*hisprace2 [1, 4 43] [-1,4 28] spl*parity [1,3 43] [-1,3 28] / exp cl;
estimate '44 vs 28' spl [1,44] [-1,28] spl*povlev [1, 5 44] [-1,5 28] spl*hisprace2 [1, 4 44] [-1,4 28] spl*parity [1,3 44] [-1,3 28] / exp cl;
	ods output Estimates=e_tub_finalhipl;
	ods output FitStatistics=fs_tub_int_finalhipl;
	ods output OddsRatios=or_tub_int_finalhipl;
	run;

* Trying one more PL level for safe measure, will likely need to make other comparisons
for final chapters;

proc freq data=a; tables povlev; weight weightvar; run;

title 'tub Use, Final Model, % FPL set to 200-299%';
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
estimate '23 vs 28' spl [1,23] [-1,28] spl*povlev [1, 2 23] [-1,2 28] spl*hisprace2 [1, 4 23] [-1,4 28] spl*parity [1,3 23] [-1,3 28] / exp cl;
estimate '24 vs 28' spl [1,24] [-1,28] spl*povlev [1, 2 24] [-1,2 28] spl*hisprace2 [1, 4 24] [-1,4 28] spl*parity [1,3 24] [-1,3 28] / exp cl;
estimate '25 vs 28' spl [1,25] [-1,28] spl*povlev [1, 2 25] [-1,2 28] spl*hisprace2 [1, 4 25] [-1,4 28] spl*parity [1,3 25] [-1,3 28] / exp cl;
estimate '26 vs 28' spl [1,26] [-1,28] spl*povlev [1, 2 26] [-1,2 28] spl*hisprace2 [1, 4 26] [-1,4 28] spl*parity [1,3 26] [-1,3 28] / exp cl;
estimate '27 vs 28' spl [1,27] [-1,28] spl*povlev [1, 2 27] [-1,2 28] spl*hisprace2 [1, 4 27] [-1,4 28] spl*parity [1,3 27] [-1,3 28] / exp cl;
estimate '28 vs 28' spl [1,28] [-1,28] spl*povlev [1, 2 28] [-1,2 28] spl*hisprace2 [1, 4 28] [-1,4 28] spl*parity [1,3 28] [-1,3 28] / exp cl;
estimate '29 vs 28' spl [1,29] [-1,28] spl*povlev [1, 2 29] [-1,2 28] spl*hisprace2 [1, 4 29] [-1,4 28] spl*parity [1,3 29] [-1,3 28] / exp cl;
estimate '30 vs 28' spl [1,30] [-1,28] spl*povlev [1, 2 30] [-1,2 28] spl*hisprace2 [1, 4 30] [-1,4 28] spl*parity [1,3 30] [-1,3 28] / exp cl;
estimate '31 vs 28' spl [1,31] [-1,28] spl*povlev [1, 2 31] [-1,2 28] spl*hisprace2 [1, 4 31] [-1,4 28] spl*parity [1,3 31] [-1,3 28] / exp cl;
estimate '32 vs 28' spl [1,32] [-1,28] spl*povlev [1, 2 32] [-1,2 28] spl*hisprace2 [1, 4 32] [-1,4 28] spl*parity [1,3 32] [-1,3 28] / exp cl;
estimate '33 vs 28' spl [1,33] [-1,28] spl*povlev [1, 2 33] [-1,2 28] spl*hisprace2 [1, 4 33] [-1,4 28] spl*parity [1,3 33] [-1,3 28] / exp cl;
estimate '34 vs 28' spl [1,34] [-1,28] spl*povlev [1, 2 34] [-1,2 28] spl*hisprace2 [1, 4 34] [-1,4 28] spl*parity [1,3 34] [-1,3 28] / exp cl;
estimate '35 vs 28' spl [1,35] [-1,28] spl*povlev [1, 2 35] [-1,2 28] spl*hisprace2 [1, 4 35] [-1,4 28] spl*parity [1,3 35] [-1,3 28] / exp cl;
estimate '36 vs 28' spl [1,36] [-1,28] spl*povlev [1, 2 36] [-1,2 28] spl*hisprace2 [1, 4 36] [-1,4 28] spl*parity [1,3 36] [-1,3 28] / exp cl;
estimate '37 vs 28' spl [1,37] [-1,28] spl*povlev [1, 2 37] [-1,2 28] spl*hisprace2 [1, 4 37] [-1,4 28] spl*parity [1,3 37] [-1,3 28] / exp cl;
estimate '38 vs 28' spl [1,38] [-1,28] spl*povlev [1, 2 38] [-1,2 28] spl*hisprace2 [1, 4 38] [-1,4 28] spl*parity [1,3 38] [-1,3 28] / exp cl;
estimate '39 vs 28' spl [1,39] [-1,28] spl*povlev [1, 2 39] [-1,2 28] spl*hisprace2 [1, 4 39] [-1,4 28] spl*parity [1,3 39] [-1,3 28] / exp cl;
estimate '40 vs 28' spl [1,40] [-1,28] spl*povlev [1, 2 40] [-1,2 28] spl*hisprace2 [1, 4 40] [-1,4 28] spl*parity [1,3 40] [-1,3 28] / exp cl;
estimate '41 vs 28' spl [1,41] [-1,28] spl*povlev [1, 2 41] [-1,2 28] spl*hisprace2 [1, 4 41] [-1,4 28] spl*parity [1,3 41] [-1,3 28] / exp cl;
estimate '42 vs 28' spl [1,42] [-1,28] spl*povlev [1, 2 42] [-1,2 28] spl*hisprace2 [1, 4 42] [-1,4 28] spl*parity [1,3 42] [-1,3 28] / exp cl;
estimate '43 vs 28' spl [1,43] [-1,28] spl*povlev [1, 2 43] [-1,2 28] spl*hisprace2 [1, 4 43] [-1,4 28] spl*parity [1,3 43] [-1,3 28] / exp cl;
estimate '44 vs 28' spl [1,44] [-1,28] spl*povlev [1, 2 44] [-1,2 28] spl*hisprace2 [1, 4 44] [-1,4 28] spl*parity [1,3 44] [-1,3 28] / exp cl;
	ods output Estimates=e_tub_finalmidpl;
	ods output FitStatistics=fs_tub_int_finalmidpl;
	ods output OddsRatios=or_tub_int_finalmidpl;
	run;

/*proc export data=class_tub outfile="U:\Dissertation\xls_graphs\class_tub.xlsx"
dbms=xlsx; run;*/

* Making graphs with estimates;
%let estimates = e_tub_finallopl e_tub_finalmidpl e_tub_finalhipl;

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

proc sort data=a; by hisprace2; run;

proc freq data=a; 
	tables edu agebabycat povlev parity; 
	by hisprace2; 
	where rscrage = 40;
	weight weightvar; 
	run;

*For NHW: largest proportion are HS degree or GED, first birth at 15-19, 2 babies,
100-199% FPL;
*For Hisp: HS degree or GED, 25-29, 2 babies, <100% FPL;
*For NHB: HS degree or GED, 15-19, 2 babies, 100-199% FPL;


**** FOR HYPOTHESIS B, COMPARING SOCIODEMOGRAPHIC AND FERTILITY VARIABLES ***;
	*** I CHANGED EDU AND PARITY TO COLLAPSE SOME GROUPS ***;

title 'Tubal Use';
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
	estimate "NHB vs NHW" spl 40 hisprace2*agebabycat [1,2 1] [-1,4 1] spl*hisprace2 [1,2 40] [-1,4 40]/ exp cl;
	estimate "Hisp vs NHW" spl 40 hisprace2*agebabycat [1,1 1] [-1,4 1] spl*hisprace2 [1,1 40] [-1,4 40] / exp cl;
	run;

		
***************************************
**** REGRESSION MODELS, PART DEUX ****
**************************************;

%let class = tub(ref=first) edud(ref="hs degree or ged") 
	hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	agebabycat parityd(ref="1") rwant(ref="YES")
	mard(ref="never been married") curr_ins;

%let confounders = edud hisprace2 pov agebabycat parityd rwant mard curr_ins;

*first running just main effects;

proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl &confounders;
	run;

*now testing interactions;

proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl &confounders spl*edud spl*hisprace2 spl*pov spl*parityd;
	run;

*a lot of significant interactions, so i did a global test between the two models
	above;

data lrt_pval;
	LRT = 821954;
	df = 44;
	p_value = 1-probchi(LRT,df);
	format p_value 8.7;
	run;

proc print data=lrt_pval;
	title1 "Likelihood ratio test statistic and p-value";
	run;

*ok, yep, non-linear effect jointly;

*after talking to Paul, I am going to move forward with using parity and 
	income interactions for all models;


**** FINAL MODEL ****;

proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl &confounders spl*pov spl*parityd;
	run;

*************** MAKING MACROS FOR ESTIMATE STATEMENTS ***************;

** NO KIDS **;

%macro kids0_loinc;
%do x=23 %to 43 %by 1;
	"&x, 0 kids, lo inc" spl [1,&x] pov [1,3] spl*pov [1,3 &x]
	parityd [1,1] spl*parityd [1,1 &x],
	%end;
	"44, 0 kids, lo inc" spl [1,44] pov [1,3] spl*pov [1,3 44]
	parityd [1,1] spl*parityd [1,1 44]
	%mend;

%macro kids0_midinc;
%do x=23 %to 43 %by 1;
	"&x, 0 kids, mid inc" spl [1,&x] pov [1,1] spl*pov [1,1 &x]
	parityd [1,1] spl*parityd [1,1 &x],
	%end;
	"44, 0 kids, mid inc" spl [1,44] pov [1,1] spl*pov [1,1 44]
	parityd [1,1] spl*parityd [1,1 44]
	%mend;

%macro kids0_hiinc;
%do x=23 %to 43 %by 1;
	"&x, 0 kids, hi inc" spl [1,&x] pov [1,2] spl*pov [1,2 &x]
	parityd [1,1] spl*parityd [1,1 &x],
	%end;
	"44, 0 kids, hi inc" spl [1,44] pov [1,2] spl*pov [1,2 44]
	parityd [1,1] spl*parityd [1,1 44]
	%mend;

** 1 KID **;

%macro kids1_loinc;
%do x=23 %to 43 %by 1;
	"&x, 1 kid, lo inc" spl [1,&x] pov [1,3] spl*pov [1,3 &x]
	parityd [1,2] spl*parityd [1,2 &x],
	%end;
	"44, 1 kid, lo inc" spl [1,44] pov [1,3] spl*pov [1,3 44]
	parityd [1,2] spl*parityd [1,2 44]
	%mend;

%macro kids1_midinc;
%do x=23 %to 43 %by 1;
	"&x, 1 kid, mid inc" spl [1,&x] pov [1,1] spl*pov [1,1 &x]
	parityd [1,2] spl*parityd [1,2 &x],
	%end;
	"44, 1 kid, mid inc" spl [1,44] pov [1,1] spl*pov [1,1 44]
	parityd [1,2] spl*parityd [1,2 44]
	%mend;

%macro kids1_hiinc;
%do x=23 %to 43 %by 1;
	"&x, 1 kid, mid inc" spl [1,&x] pov [1,2] spl*pov [1,2 &x]
	parityd [1,2] spl*parityd [1,2 &x],
	%end;
	"44, 1 kid, mid inc" spl [1,44] pov [1,2] spl*pov [1,2 44]
	parityd [1,2] spl*parityd [1,2 44]
	%mend;

** 2 KIDS **;

%macro kids2_loinc;
%do x=23 %to 43 %by 1;
	"&x, 2 kids, lo inc" spl [1,&x] pov [1,3] spl*pov [1,3 &x]
	parityd [1,3] spl*parityd [1,3 &x],
	%end;
	"44, 2 kids, lo inc" spl [1,44] pov [1,3] spl*pov [1,3 44]
	parityd [1,3] spl*parityd [1,3 44]
	%mend;

%macro kids2_midinc;
%do x=23 %to 43 %by 1;
	"&x, 2 kids, mid inc" spl [1,&x] pov [1,1] spl*pov [1,1 &x]
	parityd [1,3] spl*parityd [1,3 &x],
	%end;
	"44, 2 kids, mid inc" spl [1,44] pov [1,1] spl*pov [1,1 44]
	parityd [1,3] spl*parityd [1,3 44]
	%mend;

%macro kids2_hiinc;
%do x=23 %to 43 %by 1;
	"&x, 2 kids, hi inc" spl [1,&x] pov [1,2] spl*pov [1,2 &x]
	parityd [1,3] spl*parityd [1,3 &x],
	%end;
	"44, 2 kids, hi inc" spl [1,44] pov [1,2] spl*pov [1,2 44]
	parityd [1,3] spl*parityd [1,3 44]
	%mend;

** 3+ KIDS **;

%macro kids3_loinc;
%do x=23 %to 43 %by 1;
	"&x, 3 kids, lo inc" spl [1,&x] pov [1,3] spl*pov [1,3 &x]
	parityd [1,4] spl*parityd [1,4 &x],
	%end;
	"44, 3 kids, lo inc" spl [1,44] pov [1,3] spl*pov [1,3 44]
	parityd [1,4] spl*parityd [1,4 44]
	%mend;

%macro kids3_midinc;
%do x=23 %to 43 %by 1;
	"&x, 3 kids, mid inc" spl [1,&x] pov [1,1] spl*pov [1,1 &x]
	parityd [1,4] spl*parityd [1,4 &x],
	%end;
	"44, 3 kids, mid inc" spl [1,44] pov [1,1] spl*pov [1,1 44]
	parityd [1,4] spl*parityd [1,4 44]
	%mend;

%macro kids3_hiinc;
%do x=23 %to 43 %by 1;
	"&x, 3 kids, hi inc" spl [1,&x] pov [1,2] spl*pov [1,2 &x]
	parityd [1,4] spl*parityd [1,4 &x],
	%end;
	"44, 3 kids, hi inc" spl [1,44] pov [1,2] spl*pov [1,2 44]
	parityd [1,4] spl*parityd [1,4 44]
	%mend;

proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl &confounders spl*pov spl*parityd;
	estimate %kids0_loinc / exp cl;
	estimate %kids0_midinc / exp cl;
	estimate %kids0_hiinc / exp cl;
	estimate %kids1_loinc / exp cl;
	estimate %kids1_midinc / exp cl;
	estimate %kids1_hiinc / exp cl;
	estimate %kids2_loinc / exp cl;
	estimate %kids2_midinc / exp cl;
	estimate %kids2_hiinc / exp cl;
	estimate %kids3_loinc / exp cl;
	estimate %kids3_midinc / exp cl;
	estimate %kids3_hiinc / exp cl;
	ods output estimates=tub_kidsxincome;
	run;

proc print data=tub_kidsxincome; run;

data tub; set tub_kidsxincome;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno = 1 or stmtno = 2 or stmtno = 3 then delete;
	Label2 = substr(Label,1,2);
	run;

title1 "Tubal Ligation Use by Age, for Women with 1 Live Birth";
title2 "4 = Low Income, 5 = Mid Income, 6 = High Income";
proc sgplot data=tub;
	where stmtno = 4 or stmtno = 5 or stmtno = 6;
	band x=Label2 lower=LowerExp upper=UpperExp/ group=stmtno;
	series x=Label2 y=ExpEstimate / group=stmtno datalabel=Label2 groupdisplay=overlay;
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e;
	run;

	*running the plot code without the confidence intervals to look at the estimates more
	closely;
	title1 "Tubal Ligation Use by Age, for Women with 1 Live Birth";
	title2 "4 = Low Income, 5 = Mid Income, 6 = High Income";
	proc sgplot data=tub;
		where stmtno = 4 or stmtno = 5 or stmtno = 6;
		series x=Label2 y=ExpEstimate / group=stmtno datalabel=ExpEstimate groupdisplay=overlay;
		xaxis label="Age";
		yaxis label="Odds Ratio"
		type=log logbase=e;
		run;
		
title1 "Tubal Ligation Use by Age, for Women with 2 Live Birth";
title2 "7 = Low Income, 8 = Mid Income, 9 = High Income";
proc sgplot data=tub;
	where stmtno = 7 or stmtno = 8 or stmtno = 9;
	/*band x=Label2 lower=LowerExp upper=UpperExp/ group=stmtno;*/
	series x=Label2 y=ExpEstimate / group=stmtno datalabel=ExpEstimate groupdisplay=overlay;
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e;
	run;

title1 "Tubal Ligation Use by Age, for Women with 3 or more Live Births";
title2 "10 = Low Income, 11 = Mid Income, 12 = High Income";
proc sgplot data=tub;
	where stmtno = 10 or stmtno = 11 or stmtno = 12;
	/*band x=Label2 lower=LowerExp upper=UpperExp/ group=stmtno;*/
	series x=Label2 y=ExpEstimate / group=stmtno datalabel=ExpEstimate groupdisplay=overlay;
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e;
	run;

proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = rscrage;
	run;


** I'm still getting really wild estimates and confidence intervals, so going to 
	start over here and see if I can identify where the problem is occurring;


**First doing bivariate between tubal use and the splines;
	*Running with weights/strata/cluster and without;
proc surveylogistic data=a;
	class tub(ref=first) / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl;
	estimate spl [1,25] / exp cl;
	estimate spl [1,30] / exp cl;
	estimate spl [1,35] / exp cl;
	estimate spl [1,40] / exp cl;
	run;

	*ok, they are still wild with and without weights etc, slightly less without;

	*maybe the problem is not including intercept?;
	proc surveylogistic data=a;
	class tub(ref=first) / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl;
	estimate intercept 1 spl [1,25] / exp cl;
	estimate intercept 1 spl [1,30] / exp cl;
	estimate intercept 1 spl [1,35] / exp cl;
	estimate intercept 1 spl [1,40] / exp cl;
	estimate intercept 1 spl [1,44] / exp cl;
	run;

	*yeah, that was it. how annoying;

** OK, trying the age at first birth thing;

proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl &confounders;
	estimate intercept 1 spl [1,25] / exp cl;
	estimate intercept 1 spl [1,30] / exp cl;
	estimate intercept 1 spl [1,35] / exp cl;
	estimate intercept 1 spl [1,40] / exp cl;
	run;
	
	*the estimate statements won't run;
	*i didn't save the code, but i tried to run the model 2 more ways, one without
	agebabycat and one without parity, the separation is definitely the problem
	here, because both of those models were estimable;

** Now I'm testing whether SAS will correctly estimate things if I include 
	age at first birth as an interaction with age;

proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl &confounders spl*agebabycat;
	estimate "25, afb=15-19" intercept 1 spl [1,25] spl*agebabycat [1,1 25] / exp cl;
	estimate "30, afb=15-19" intercept 1 spl [1,30] spl*agebabycat [1,1 30] / exp cl;
	estimate "35, afb=15-19" intercept 1 spl [1,35] spl*agebabycat [1,1 35] / exp cl;
	estimate "40, afb=15-19" intercept 1 spl [1,40] spl*agebabycat [1,1 40] / exp cl;
	run;

	*that still won't estimate so I am going to try running the model without
	parity... I'm not sure it will work because the linear combination problem
	is not just parity;

	proc surveylogistic data=a;
		class &class / param=ref;
		weight weightvar;
		strata stratvar;
		cluster panelvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model tub = spl edud hisprace2 pov agebabycat rwant mard curr_ins spl*agebabycat;
		estimate "25, afb=15-19" intercept 1 spl [1,25] spl*agebabycat [1,1 25] / exp cl;
		estimate "30, afb=15-19" intercept 1 spl [1,30] spl*agebabycat [1,1 30] / exp cl;
		estimate "35, afb=15-19" intercept 1 spl [1,35] spl*agebabycat [1,1 35] / exp cl;
		estimate "40, afb=15-19" intercept 1 spl [1,40] spl*agebabycat [1,1 40] / exp cl;
		run;

		*that runs but estimates are ginormous, trying removing intercept;

			proc surveylogistic data=a;
				class &class / param=ref;
				weight weightvar;
				strata stratvar;
				cluster panelvar;
				effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
											knotmethod=percentiles(5) details);
				model tub = spl edud hisprace2 pov agebabycat rwant mard curr_ins spl*agebabycat;
				estimate "25, afb=15-19" spl [1,25] spl*agebabycat [1,1 25] [-1,2 25] / exp cl;
				estimate "30, afb=15-19" spl [1,30] spl*agebabycat [1,1 30] / exp cl;
				estimate "35, afb=15-19" spl [1,35] spl*agebabycat [1,1 35] / exp cl;
				estimate "40, afb=15-19" spl [1,40] spl*agebabycat [1,1 40] / exp cl;
				run;

				*estimates still ginormous;

proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud hisprace2 pov earlybirth parityd rwant mard 
	curr_ins spl*earlybirth;
	estimate "25, afb=15-19" spl [1,25] spl*earlybirth [1,1 25] [-1,2 25] / exp cl e;
	estimate "40, afb=15-19" spl [1,40] spl*earlybirth [1,1 40] / exp cl;
	run;

	*still enormous but as far as I can tell variables are not being set to 0;
	*retrying this with earlybirth in the class statement;

	proc surveylogistic data=a;
		class tub(ref=first) edud(ref="hs degree or ged") 
		hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
		earlybirth (ref=first) parityd(ref="1") rwant(ref="YES")
		mard(ref="never been married") curr_ins / param=ref;
			weight weightvar;
		strata stratvar;
		cluster panelvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model tub = spl edud hisprace2 pov earlybirth parityd rwant mard 
		curr_ins spl*earlybirth;
		estimate "25, afb=15-19" spl [1,25] spl*earlybirth [1,1 25] [-1,2 25] / exp cl e;
		estimate "40, afb=15-19" spl [1,40] spl*earlybirth [1,1 40] / exp cl;
		run;

	*estimates are still enormous but only parityd0 = earlybirth0, gonna try
		including the intercept now;

	proc surveylogistic data=a;
		class tub(ref=first) edud(ref="hs degree or ged") 
		hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
		earlybirth (ref=first) parityd(ref="1") rwant(ref="YES")
		mard(ref="never been married") curr_ins / param=ref;
		weight weightvar;
		strata stratvar;
		cluster panelvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model tub = spl edud hisprace2 pov earlybirth parityd rwant mard 
		curr_ins spl*earlybirth;
		estimate "25, afb=15-19" intercept 1 spl [1,25] spl*earlybirth [1,1 25] [-1,2 25] / exp cl e;
		estimate "40, afb=15-19" intercept 1 spl [1,40] spl*earlybirth [1,1 40] / exp cl;
		ods output ClassLevelInfo=cli;
		run;

		proc print data=cli; run;

		*this is still a mess;

*In a last ditch effort, I'm going to try creating the class variables using 
	effect parameterization instead of full-rank, perhaps if the perfectly
	correlated groups are both references, this won't be a problem? see
	https://support.sas.com/documentation/cdl/en/statug/63033/HTML/default/viewer.htm#statug_logistic_sect023.htm;

proc surveylogistic data=a;
	class tub(ref=first) edud(ref="hs degree or ged") 
	hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	earlybirth (ref="no births") parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=effect;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud hisprace2 pov earlybirth parityd rwant mard 
	curr_ins spl*earlybirth;
	estimate "25, afb=15-19" intercept 1 spl [1,25] spl*earlybirth [1,1 25] [-1,2 25] / exp cl e;
	estimate "40, afb=15-19" intercept 1 spl [1,40] spl*earlybirth [1,1 40] / exp cl;
	ods output ClassLevelInfo=cli;
	run;

*it's still a problem, now parityd3 is set to 0 because it's a linear combination
	of some of the earlybirth and parityd variables. going to need to adjust and 
	either create my own dummies or not use age at first birth as an interaction;

	*taking out earlybirth completely to see if that's causing the wild estimates;
	proc surveylogistic data=a;
		class tub(ref=first) edud(ref="hs degree or ged") 
		hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
		parityd(ref="0") rwant(ref="YES")
		mard(ref="never been married") curr_ins / param=effect;
		weight weightvar;
		strata stratvar;
		cluster panelvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model tub = spl edud hisprace2 pov parityd rwant mard 
		curr_ins spl*parityd;
		estimate "25, afb=15-19" intercept 1 spl [1,25] spl*parityd [1,1 25] [-1,2 25] / exp cl e;
		estimate "40, afb=15-19" intercept 1 spl [1,40] spl*parityd [1,1 40] / exp cl;
		ods output ClassLevelInfo=cli;
		run;

	*it's not early birth, so i'm going to try again removing the intercept;
	proc surveylogistic data=a;
		class tub(ref=first) edud(ref="hs degree or ged") 
		hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
		parityd(ref="0") rwant(ref="YES")
		mard(ref="never been married") curr_ins / param=effect;
		weight weightvar;
		strata stratvar;
		cluster panelvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model tub = spl edud hisprace2 pov parityd rwant mard 
		curr_ins spl*parityd;
		estimate "25, afb=15-19" spl [1,25] spl*parityd [1,1 25] [-1,2 25] / exp cl e;
		estimate "40, afb=15-19" spl [1,40] spl*parityd [1,1 40] / exp cl;
		run;

		proc print data=cli; run;

		*those are wild too, what the hell is going on. no linear combination
		problems but the estimates are outrageous;

** Now trying just main effects, no earlybirth;
	proc surveylogistic data=a;
		class tub(ref="using tubal ligation") edud(ref="hs degree or ged") 
		hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
		parityd(ref="0") rwant(ref="YES")
		mard(ref="never been married") curr_ins / param=effect;
		weight weightvar;
		strata stratvar;
		cluster panelvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model tub = spl edud hisprace2 pov parityd rwant mard 
		curr_ins;
		estimate "25" intercept 1 spl [1,25] / exp cl;
		estimate "40" intercept 1 spl [1,40] / exp cl;
		run;

		*ok, that looks good, now try an interaction, no OR;

		proc surveylogistic data=a;
			class tub(ref=first) edud(ref="hs degree or ged") 
			hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
			parityd(ref="0") rwant(ref="YES")
			mard(ref="never been married") curr_ins / param=effect;
			weight weightvar;
			strata stratvar;
			cluster panelvar;
			effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
										knotmethod=percentiles(5) details);
			model tub = spl edud hisprace2 pov parityd rwant mard 
			curr_ins spl*edud;
			estimate "25, afb=15-19" /*intercept 1*/ spl [1,25] spl*edud [1,1 25] / exp cl;
			estimate "40, afb=15-19" /*intercept 1*/ spl [1,40] spl*edud [1,1 40] / exp cl;
			run;

			*both with and without the intercept have huge estimates;

		*now trying odds ratios;
		proc surveylogistic data=a;
			class tub(ref=first) edud(ref="hs degree or ged") 
			hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
			parityd(ref="0") rwant(ref="YES")
			mard(ref="never been married") curr_ins / param=effect;
			weight weightvar;
			strata stratvar;
			cluster panelvar;
			effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
										knotmethod=percentiles(5) details);
			model tub = spl edud hisprace2 pov parityd rwant mard 
			curr_ins spl*edud;
			estimate "25" /*intercept 1*/ spl [1,25] spl*edud [1,1 25] [1,2 25] / exp cl;
			estimate "40" /*intercept 1*/ spl [1,40] spl*edud [1,1 40] [1,2 25]/ exp cl;
			run;

			*still crazy, the problem must be with the code for spl, i think when you
			include higher-order effects you have to use odds ratios for spl?;

		proc surveylogistic data=a;
			class tub(ref=first) edud(ref="hs degree or ged") 
			hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
			parityd(ref="0") rwant(ref="YES")
			mard(ref="never been married") curr_ins / param=effect;
			weight weightvar;
			strata stratvar;
			cluster panelvar;
			effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
										knotmethod=percentiles(5) details);
			model tub = spl edud hisprace2 pov parityd rwant mard 
			curr_ins spl*edud;
			estimate "25, bachelors" intercept 1 spl [1,25] edud [1,1] spl*edud [1,1 25] / exp cl;
			estimate "40, bachelors" intercept 1 spl [1,40] edud [1,1] spl*edud [1,1 40] / exp cl;
			run;

			*ok, that did work;

** Now checking to make sure it's the same as comparing to hs degree;
proc surveylogistic data=a;
	class tub(ref=first) edud(ref="hs degree or ged") 
	hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=effect;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud hisprace2 pov parityd rwant mard 
	curr_ins spl*edud;
	estimate "25, bachelors vs HS" intercept 1 spl [1,25] edud [1,1] [-1,2] spl*edud [1,1 25] [-1,2 25] / exp cl;
	estimate "40, bachelors vs HS" intercept 1 spl [1,40] edud [1,1] [-1,2] spl*edud [1,1 40] [-1,2 40]/ exp cl;
	run;

	*ok, it looks like that worked;

** Now trying it after flipping the reference group for tubal, since values over
	1 are more intuitive to me;

* First trying just spline estimates;
proc surveylogistic data=a;
	class tub(ref="using tubal ligation") edud(ref="hs degree or ged") 
	hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=effect;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud hisprace2 pov parityd rwant mard 
	curr_ins spl*edud;
	estimate "30, bachelors vs HS" intercept 1 spl [1,30] / exp cl e;
	estimate "40, bachelors vs HS" intercept 1 spl [1,40] / exp cl;
	ods output ClassLevelInfo = cli;
	run;

	proc print data=cli; run;
	*Reference group for education is HS degree or GED;

proc surveylogistic data=a;
	class tub(ref=first) edud(ref="hs degree or ged") 
	hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud hisprace2 pov parityd rwant mard 
	curr_ins spl*edud;
	estimate "30, bachelors vs HS" intercept 0 spl [0,30] edud [1,1] [-1,2] spl*edud [1,1 30] [-1,2 30] / e exp cl;
	estimate "40, bachelors vs HS" intercept 0 spl [0,40] edud [1,1] [-1,2] spl*edud [1,1 40] [-1,2 40]  / exp cl;
	ods output classlevelinfo=cli3;
	run;

*############ ^^^ THIS IS THE CORRECT SYNTAX FOR INTERACTIONS ##############;

	proc print data=cli3; run;

** Hoping I have this figured out now;

** Now trying with age at first birth interaction;
proc surveylogistic data=a;
	class tub(ref=first) edud(ref="hs degree or ged") 
	agebabycat hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud agebabycat hisprace2 pov parityd rwant mard
	curr_ins spl*agebabycat;
	estimate "30, 15-19 vs 20-24" intercept 0 spl [0,30] agebabycat [1,1] [-1,2] 
	spl*agebabycat [1,1 30] [-1,2 30] / e exp cl;
	estimate "40, 15-19 vs 20-24" intercept 0 spl [0,40] agebabycat [1,1] [-1,2] 
	spl*agebabycat [1,1 40] [-1,2 40]  / exp cl;
	ods output ClassLevelInfo=cli_agebabycat;
	run;

	proc print data=cli_agebabycat; run;

	proc export data=cli_agebabycat
		outfile="U:\Dissertation\xls_graphs\cli_agebabycat.xlsx"
		dbms=xlsx
		replace;
		run;

**The age at first birth interaction worked well above, but now I'm going to 
	test it with the categories SAS has set to 0;

proc surveylogistic data=a;
	class tub(ref=first) edud(ref="hs degree or ged") 
	agebabycat hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud agebabycat hisprace2 pov parityd rwant mard
	curr_ins spl*agebabycat;
	estimate "40, 35-39 vs 0" intercept 0 spl [0,40] agebabycat [1,4] [-1,1] 
	spl*agebabycat [1,4 40] [-1,1 40] / exp cl;
	estimate "44, 35-39 vs 0" intercept 0 spl [0,44] agebabycat [1,4] [-1,1] 
	spl*agebabycat [1,4 44] [-1,1 44] / exp cl;
	run;

	*I'm getting a lot of non-estimable results or huge estimates and confidence
	intervals;

	*Since what I'm really interested in is whether a person had an early first
	birth, I created an 'earlybirth' group, trying here;

proc surveylogistic data=a;
	class tub(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate "40, 15-19 vs older" intercept 0 spl [0,40] earlybirth [1,1] [-1,3] 
	spl*earlybirth [1,1 40] [-1,3 40] / e exp cl;
	estimate "44, 15-19 vs older" intercept 0 spl [0,44] earlybirth [1,1] [-1,3] 
	spl*earlybirth [1,1 44] [-1,3 44] / exp cl;
	ods output ClassLevelInfo=cli_earlybirth;
	run;

	*Hot damn, it worked!;

proc export data=cli_earlybirth
		outfile="U:\Dissertation\xls_graphs\cli_earlybirth.xlsx"
		dbms=xlsx
		replace;
		run;

	proc freq data=a; tables earlybirth; run;

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
	class tub(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl;
	estimate %earlytwenties / exp cl;
	ods output Estimates=e;
	run;

	/*proc print data=e; run;*/


data e_early; set e;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	ORR=round(ExpEstimate,.1);
	LCLR=round(LowerExp,.1);
	UCLR=round(UpperExp,.1);
	Label2=substr(Label,1,2);
	run;

	proc print data=e_early; run;

	data test; set e_early;
		rename label2 = age;
		CI = cats('(',lclr,', ',uclr,')');
		drop label probt expestimate lowerexp upperexp lclr uclr;
		run;

title1 "Tubal Ligation Use by Age & Age at First Birth";
proc sgplot data=e_early;
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

*********
** 	Running the above model with vasectomy users removed to assess whether variation in tubal use by age
	is due to vasectomy increasing among affluent women.
*********;

data a; set a;
	if bc=2 then tub=.;
	run;

proc surveylogistic data=a;
	class tub(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl;
	estimate %earlytwenties / exp cl;
	ods output Estimates=e_tubnovas;
	run;


data e_tubnovas; set e_tubnovas;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	ORR=round(ExpEstimate,.1);
	LCLR=round(LowerExp,.1);
	UCLR=round(UpperExp,.1);
	Label2=substr(Label,1,2);
	run;

title1 "Tubal Ligation Use by Age & Age at First Birth";
title2 "Vasectomies Removed";
proc sgplot data=e_tubnovas;
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

*** VERY interesting, does not appear to change the shape;



***************************************************
*** FINAL MODEL WITH INTERACTION, PROBABILITIES ***
***************************************************;

* ### EFFECT PARAMETERIZATION ###;

%macro teen;
%do x=23 %to 43 %by 1;
	"&x, 1st birth teens" intercept 1 spl [1,&x] earlybirth [1,1] 
		spl*earlybirth [1,1 &x],
	%end;
	"44, 1st birth teens" intercept 1 spl [1,44] earlybirth [1,1] 
		spl*earlybirth [1,1 44]
	%mend;

%macro earlytwenties;
%do x=23 %to 43 %by 1;
	"&x, 1st birth 20-24" intercept 1 spl [1,&x] earlybirth [1,2] 
		spl*earlybirth [1,2 &x],
	%end;
	"44, 1st birth 20-24" intercept 1 spl [1,44] earlybirth [1,2] 
		spl*earlybirth [1,2 44]
	%mend;

%macro laterbirth;
%do x=23 %to 42 %by 1;
	"&x, 1st birth >24/0" intercept 1 spl [1,&x] earlybirth [1,3] 
		spl*earlybirth [1,3 &x],
	%end;
	"44, 1st birth >24/0" intercept 1 spl [1,44] earlybirth [1,3] 
		spl*earlybirth [1,3 44]
	%mend;

proc surveylogistic data=a;
	class tub(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=effect;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e;
	run;

	** checked that keeping the reference values in there doesn't override the effect
	parameterization statement;

	data e_early; set e;
		drop estimate stderr df tvalue alpha lower upper;
		if stmtno=1 then earlybirth = "15-19";
		if stmtno=2 then earlybirth = "20-24";
		if stmtno=3 then earlybirth = ">24/0";
		PROBR=round(mu,.01);
		LCLR=round(lowermu,.01);
		UCLR=round(uppermu,.01);
		Label2=substr(Label,1,2);
		label earlybirth = "Age at First Birth Group";
		run;

		/*title1 "Tubal Ligation Use by Age & Age at First Birth";*/
			*removing title so I can create an appropriate caption in Word;
			title;
		proc sgplot data=e_early;
			band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
			transparency = .5;
			series x=Label2 y=probr / group=earlybirth datalabel=probr
			/*groupdisplay=overlay*/;
			/*refline 1 / axis=y label="OR=1.0";*/
			xaxis label="Age";
			yaxis label="Predicted Probability"
			/*type=log logbase=e logstyle=linear*/
			values=(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8);
			run;

*Repeating this analysis after removing vasectomies
	to see if increasing vasectomies among the most
	affluent women is changing the results;

data a; set a;
	tubnovas = tub;
	if bc=2 then tub=.;
	run;

proc surveylogistic data=a;
	class tubnovas(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=effect;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tubnovas = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e_tubnovas;
	run;


data e_tubnovas; set e_tubnovas;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	if stmtno=3 then earlybirth = ">24/0";
	PROBR=round(mu,.01);
	LCLR=round(lowermu,.01);
	UCLR=round(uppermu,.01);
	Label2=substr(Label,1,2);
	label earlybirth = "Age at First Birth Group";
	run;

/*title1 "Tubal Ligation Use by Age & Age at First Birth";
title2 "Vasectomies Removed";*/
proc sgplot data=e_tubnovas;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Predicted Probability"
	/*type=log logbase=e logstyle=linear*/
	values=(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7);
	run;





** Doing one model with tubal & vasectomy (all permanent methods) included;

data a; set a;
	tubvas = tub;
	if ster = 1 then tubvas = 1;
	run;

	proc freq data=a; tables tubvas; run;
	proc freq data=a; tables tub; run;

	proc surveylogistic data=a;
	class tubvas(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=effect;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tubvas = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e;
	run;

	/*proc print data=e; run;*/


data e_early; set e;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	if stmtno=3 then earlybirth = ">24/0";
	PROBR=round(mu,.01);
	LCLR=round(lowermu,.01);
	UCLR=round(uppermu,.01);
	Label2=substr(Label,1,2);
	label earlybirth = "Age at First Birth Group";
	run;

title;
proc sgplot data=e_early;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Predicted Probability"
	/*type=log logbase=e logstyle=linear*/
	values=(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8);
	run;




*### SECOND DRAFT ESTIMATES, SPECIFYING COVARIATES ###;


*** Bachelor's degree, white, high income, 0 kids, doesn't want more kids, never been married, private insurance;

%macro teen;
%do x=23 %to 43 %by 1;
	"&x, 1st birth teens" intercept 1 spl [1,&x] earlybirth [1,1] 
		spl*earlybirth [1,1 &x] edud [1,1] hisprace2 [1,4] pov [1,2] parityd [1,1] rwant [1,2]
		mard [1,3] curr_ins [1,4],
	%end;
	"44, 1st birth teens" intercept 1 spl [1,44] earlybirth [1,1] 
		spl*earlybirth [1,1 44] edud [1,1] hisprace2 [1,4] pov [1,2] parityd [1,1] rwant [1,2]
		mard [1,3] curr_ins [1,4]
	%mend;

%macro earlytwenties;
%do x=23 %to 43 %by 1;
	"&x, 1st birth 20-24" intercept 1 spl [1,&x] earlybirth [1,2] 
		spl*earlybirth [1,2 &x] edud [1,1] hisprace2 [1,4] pov [1,2] parityd [1,1] rwant [1,2]
		mard [1,3] curr_ins [1,4],
	%end;
	"44, 1st birth 20-24" intercept 1 spl [1,44] earlybirth [1,2] 
		spl*earlybirth [1,2 44] edud [1,1] hisprace2 [1,4] pov [1,2] parityd [1,1] rwant [1,2]
		mard [1,3] curr_ins [1,4]
	%mend;

%macro laterbirth;
%do x=26 %to 42 %by 1;
	"&x, 1st birth >24/0" intercept 1 spl [1,&x] earlybirth [1,3] 
		spl*earlybirth [1,3 &x] edud [1,1] hisprace2 [1,4] pov [1,2] parityd [1,1] rwant [1,2]
		mard [1,3] curr_ins [1,4],
	%end;
	"44, 1st birth >24/0" intercept 1 spl [1,44] earlybirth [1,3] 
		spl*earlybirth [1,3 44] edud [1,1] hisprace2 [1,4] pov [1,2] parityd [1,1] rwant [1,2]
		mard [1,3] curr_ins [1,4]
	%mend;


proc surveylogistic data=a;
	class tub(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e;
	run;

	/*proc print data=e; run;*/


data e_early; set e;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	if stmtno=3 then earlybirth = ">24/0";
	PROBR=round(mu,.01);
	LCLR=round(lowermu,.01);
	UCLR=round(uppermu,.01);
	Label2=substr(Label,1,2);
	label earlybirth = "Age at First Birth Group";
	run;

/*title1 "Tubal Ligation Use by Age & Age at First Birth";*/
	*removing title so I can create an appropriate caption in Word;
	title;
proc sgplot data=e_early;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Predicted Probability"
	/*type=log logbase=e logstyle=linear*/
	values=(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8);
	run;


*** HS degree, NHB, low income, 2 kids, does not more kids, never been married, Medicaid
	(did the same one but with wanting more kids in the other aims, don't think that's
	appropriate here);

%macro teen;
%do x=23 %to 43 %by 1;
	"&x, 1st birth teens" intercept 1 spl [1,&x] earlybirth [1,1] 
		spl*earlybirth [1,1 &x] edud [1,2] hisprace2 [1,2] pov [1,3] parityd [1,3] rwant [1,2]
		mard [1,3] curr_ins [1,2],
	%end;
	"44, 1st birth teens" intercept 1 spl [1,44] earlybirth [1,1] 
		spl*earlybirth [1,1 44] edud [1,2] hisprace2 [1,2] pov [1,3] parityd [1,3] rwant [1,2]
		mard [1,3] curr_ins [1,2]
	%mend;

%macro earlytwenties;
%do x=23 %to 43 %by 1;
	"&x, 1st birth 20-24" intercept 1 spl [1,&x] earlybirth [1,2] 
		spl*earlybirth [1,2 &x] edud [1,2] hisprace2 [1,2] pov [1,3] parityd [1,3] rwant [1,2]
		mard [1,3] curr_ins [1,2],
	%end;
	"44, 1st birth 20-24" intercept 1 spl [1,44] earlybirth [1,2] 
		spl*earlybirth [1,2 44] edud [1,2] hisprace2 [1,2] pov [1,3] parityd [1,3] rwant [1,2]
		mard [1,3] curr_ins [1,2]
	%mend;

%macro laterbirth;
%do x=23 %to 42 %by 1;
	"&x, 1st birth >24/0" intercept 1 spl [1,&x] earlybirth [1,3] 
		spl*earlybirth [1,3 &x] edud [1,2] hisprace2 [1,2] pov [1,3] parityd [1,3] rwant [1,2]
		mard [1,3] curr_ins [1,2],
	%end;
	"44, 1st birth >24/0" intercept 1 spl [1,44] earlybirth [1,3] 
		spl*earlybirth [1,3 44] edud [1,2] hisprace2 [1,2] pov [1,3] parityd [1,3] rwant [1,2]
		mard [1,3] curr_ins [1,2]
	%mend;


proc surveylogistic data=a;
	class tub(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e;
	run;

	/*proc print data=e; run;*/


data e_early; set e;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	if stmtno=3 then earlybirth = ">24/0";
	PROBR=round(mu,.01);
	LCLR=round(lowermu,.01);
	UCLR=round(uppermu,.01);
	Label2=substr(Label,1,2);
	label earlybirth = "Age at First Birth Group";
	run;

/*title1 "Tubal Ligation Use by Age & Age at First Birth";*/
	*removing title so I can create an appropriate caption in Word;
	title;
proc sgplot data=e_early;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Predicted Probability"
	/*type=log logbase=e logstyle=linear*/
	/*values=(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8)*/;
	run;



*** associate, Hisp, mid income, 2 kids, does not more kids, married, uninsured;

%macro teen;
%do x=23 %to 43 %by 1;
	"&x, 1st birth teens" intercept 1 spl [1,&x] earlybirth [1,1] 
		spl*earlybirth [1,1 &x] edud [1,4] hisprace2 [1,1] pov [1,2] parityd [1,3] rwant [1,2]
		mard [1,1] curr_ins [1,1],
	%end;
	"44, 1st birth teens" intercept 1 spl [1,44] earlybirth [1,1] 
		spl*earlybirth [1,1 44] edud [1,4] hisprace2 [1,1] pov [1,2] parityd [1,3] rwant [1,2]
		mard [1,1] curr_ins [1,1]
	%mend;

%macro earlytwenties;
%do x=23 %to 43 %by 1;
	"&x, 1st birth 20-24" intercept 1 spl [1,&x] earlybirth [1,2] 
		spl*earlybirth [1,2 &x] edud [1,4] hisprace2 [1,1] pov [1,2] parityd [1,3] rwant [1,2]
		mard [1,1] curr_ins [1,1],
	%end;
	"44, 1st birth 20-24" intercept 1 spl [1,44] earlybirth [1,2] 
		spl*earlybirth [1,2 44] edud [1,4] hisprace2 [1,1] pov [1,2] parityd [1,3] rwant [1,2]
		mard [1,1] curr_ins [1,1]
	%mend;

%macro laterbirth;
%do x=23 %to 42 %by 1;
	"&x, 1st birth >24/0" intercept 1 spl [1,&x] earlybirth [1,3] 
		spl*earlybirth [1,3 &x] edud [1,4] hisprace2 [1,1] pov [1,2] parityd [1,3] rwant [1,2]
		mard [1,1] curr_ins [1,1],
	%end;
	"44, 1st birth >24/0" intercept 1 spl [1,44] earlybirth [1,3] 
		spl*earlybirth [1,3 44] edud [1,4] hisprace2 [1,1] pov [1,2] parityd [1,3] rwant [1,2]
		mard [1,1] curr_ins [1,1]
	%mend;


proc surveylogistic data=a;
	class tub(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e;
	run;


	data e_early; set e;
		drop estimate stderr df tvalue alpha lower upper;
		if stmtno=1 then earlybirth = "15-19";
		if stmtno=2 then earlybirth = "20-24";
		if stmtno=3 then earlybirth = ">24/0";
		PROBR=round(mu,.01);
		LCLR=round(lowermu,.01);
		UCLR=round(uppermu,.01);
		Label2=substr(Label,1,2);
		label earlybirth = "Age at First Birth Group";
		run;


		proc sgplot data=e_early;
			band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
			transparency = .5;
			series x=Label2 y=probr / group=earlybirth datalabel=probr
			/*groupdisplay=overlay*/;
			/*refline 1 / axis=y label="OR=1.0";*/
			xaxis label="Age";
			yaxis label="Predicted Probability"
			/*type=log logbase=e logstyle=linear*/
			/*values=(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8)*/;
			run;


*### UNADJUSTED ###;

%macro teen;
%do x=23 %to 43 %by 1;
	"&x, 1st birth teens" intercept 1 spl [1,&x] earlybirth [1,1] 
		spl*earlybirth [1,1 &x],
	%end;
	"44, 1st birth teens" intercept 1 spl [1,44] earlybirth [1,1] 
		spl*earlybirth [1,1 44]
	%mend;

%macro earlytwenties;
%do x=23 %to 43 %by 1;
	"&x, 1st birth 20-24" intercept 1 spl [1,&x] earlybirth [1,2] 
		spl*earlybirth [1,2 &x],
	%end;
	"44, 1st birth 20-24" intercept 1 spl [1,44] earlybirth [1,2] 
		spl*earlybirth [1,2 44]
	%mend;

%macro laterbirth;
%do x=23 %to 42 %by 1;
	"&x, 1st birth >24/0" intercept 1 spl [1,&x] earlybirth [1,3] 
		spl*earlybirth [1,3 &x],
	%end;
	"44, 1st birth >24/0" intercept 1 spl [1,44] earlybirth [1,3] 
		spl*earlybirth [1,3 44]
	%mend;



proc surveylogistic data=a;
	class tub(ref=first)
	earlybirth (ref=">24 or no live births") / param=effect;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl earlybirth spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e;
	run;


	data e_early; set e;
		drop estimate stderr df tvalue alpha lower upper;
		if stmtno=1 then earlybirth = "15-19";
		if stmtno=2 then earlybirth = "20-24";
		if stmtno=3 then earlybirth = ">24/0";
		PROBR=round(mu,.01);
		LCLR=round(lowermu,.01);
		UCLR=round(uppermu,.01);
		Label2=substr(Label,1,2);
		label earlybirth = "Age at First Birth Group";
		run;


		proc sgplot data=e_early;
			band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
			transparency = .5;
			series x=Label2 y=probr / group=earlybirth datalabel=probr
			/*groupdisplay=overlay*/;
			/*refline 1 / axis=y label="OR=1.0";*/
			xaxis label="Age";
			yaxis label="Predicted Probability"
			/*type=log logbase=e logstyle=linear*/
			/*values=(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8)*/;
			run;
