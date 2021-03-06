*############################################*
*######### McWilliams Dissertation ##########*
*##### Aim 1 Logistic Regression Model 2 ####*
*######### IUD Use vs Anything Else #########*
*############################################*;

libname library "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\nsfg_CMcWFormats.sas";
data a; set library.nsfg; run;

ods trace on;
ods graphics on / reset=index imagename="iud_age";
ods listing gpath = "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\sas_graphs_iud";

%let class = iud(ref=first) edud(ref="hs degree or ged") 
	hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	agebabycat parityd(ref="1") rwant(ref="YES")
	mard(ref="never been married") curr_ins;

%let confounders = edud hisprace2 pov agebabycat parityd rwant mard curr_ins;

*The code below creates a simple one-way frequency and histogram for the outcome of
interest. Commenting out for clarity, the final versions for use are in the 
xls_graphs and graphs_iud folders referenced in the code;

	/*DESCRIPTIVES FOR IUD VS NOT;
	proc freq data=a; tables iud; ods output onewayfreqs=iudfreq; run;
	proc print data=iudfreq; format iud 3.1; run;

		*formatting to make dataset look nicer;
		data iudfreq; set iudfreq;
			drop f_iud Table CumFrequency CumPercent;
			rename iud = IUD;
			run;

		proc print data=iudfreq; run;
		proc export data=iudfreq outfile="U:\Dissertation\xls_graphs\iudfreq.xlsx"
		dbms=xlsx replace; run;*/

	proc freq data=a; tables rscrage*iud; weight weightvar; ods output CrossTabFreqs=iud_age;
	run;
	proc print data=iud_age; run;
	title;
	proc sgplot data=iud_age;
		vbar rscrage / Response=RowPercent;
		format rscrage _all_;
		where iud = 1;
		xaxis label = "Age";
		yaxis label = "Percent";
		run;

********** TABLE 1 **********;

*IUD use by covariates;

%macro ditto;
	%let i=1;
	%do %until(not %length(%scan(&confounders,&i)));
proc surveyfreq data=a; 
	tables iud*(%scan(&confounders,&i));
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	ods output CrossTabs=iud_%scan(&confounders,&i);
	run;
	%let i=%eval(&i+1);
	%end;
	%mend ditto;

	%ditto;

	proc print data=iud_edud; run;

%let ds = 
	iud_edud
	iud_hisprace2
	iud_pov
	iud_agebabycat
	iud_parityd
	iud_rwant
	iud_mard
	iud_curr_ins;

%macro ds;
	%let i=1;
	%do %until(not %length(%scan(&ds,&i)));
	data %scan(&ds,&i); set %scan(&ds,&i);
		if iud ne 1 then delete;
		/*drop Table _TYPE_ _TABLE_ Frequency Missing;*/
		run;
	%let i=%eval(&i+1);
	%end;
	%mend ds;

	%ds;

%macro worksheets;
	%let i=1;
	%do %until(not %length(%scan(&ds,&i)));
	proc export data=%scan(&ds,&i)
		outfile="U:\Dissertation\xls_graphs\IUD_conf.xlsx"
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
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl;
	output out=iud pred=pred;
	run;

proc sgplot data=iud;
	scatter y=pred x=rscrage;
	run;

*** BIVARIATE BETWEEN IUD AND AGE, WITH ESTIMATES ***;

%macro iud_spl;
%do x=23 %to 43;
	"&x vs 28" spl [1,&x] [-1,28], %end;
	"44 vs 28" spl [1,44] [-1,28] %mend;

proc surveylogistic data=a;
	class &class;
	weight weightvar;
	strata stratvar; 
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl;
	estimate %iud_spl / exp cl;
	ods output Estimates=e_iud;
	ods output FitStatistics=fs_iud;
	ods output OddsRatios=or_iud;
	ods output ModelANOVA=jt_iud;
	run;

%let dem = edud hisprace2 pov;
%let demfert = edud hisprace2 pov agebabycat parityd rwant mard;


*** IUD USE REGRESSED ON AGE AND DEMOGRAPHIC VARS ***;

proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &dem;
	estimate %iud_spl / exp cl;
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


****************************************
*** IUD USE, FINAL MODEL, FIXING AGE ***
****************************************;

*coming back to this to look at type 3 effects for main effects and interactions
between age and demographic variables;
title 'IUD vs Anything Else';
proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &confounders spl*hisprace2 spl*pov spl*edud edud*pov;
	run;

title 'IUD vs Anything Else';
proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	/*strata stratvar;
	cluster panelvar;*/
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &confounders spl*hisprace2 spl*pov;,
	estimate "black, 40" intercept 1 
	estimate "black vs white, 40" spl*hisprace2 [1,2 40] [-1,4 40] / exp cl;
	ods output Estimates=e;
	run;

	proc surveylogistic data=a;
	class hisprace2 pov/ param=ref;
	weight weightvar;
	/*strata stratvar;
	cluster panelvar;*/
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl hisprace2 spl*hisprace2 pov spl*pov;
	estimate "black, 40" intercept 1 spl [1,40] hisprace2[1,2] spl*hisprace2 [1, 2 40] / exp cl;
	estimate "white, 40" intercept 1 spl [1,40] hisprace2[1,4] spl*hisprace2 [1, 4 40] / exp cl; 
	estimate "black vs white, 40" intercept 0 spl [0,40] hisprace2 [1,2] [-1,4] spl*hisprace2 [1,2 40] [-1,4 40] / exp cl e;
	estimate "black vs white, 30" hisprace2 0 1 0 -1 spl*hisprace2 [1,2 30] [-1,4 30] / exp cl;
	run;

	proc surveylogistic data=a;
	class hisprace2 / param=ref;
	weight weightvar;
	/*strata stratvar;
	cluster panelvar;*/
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl hisprace2;
	estimate "black vs white" hisprace2 0 1 0 -1 / exp cl;
	run;

	proc print data=e; run;

	proc freq data=a; tables hisprace2*rscrage; where iud = 1; run;

	proc surveylogistic data=a;
	class &class;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &confounders spl*hisprace2 spl*pov spl*edud spl*rwant spl*parityd
	 spl*mard hisprace2*edud hisprace2*pov edud*pov / df=infinity;
	run;

%macro iud_white_loinc;
%do x=23 %to 43 %by 1;
	"&x vs 28 w lo" spl [1,&x] [-1,28] spl*hisprace2 [1,4 &x] [-1,4 28] 
	spl*pov [1,3 &x] [-1,3 28],
	%end;
	"44 vs 28 w lo" spl [1,44] [-1,28] spl*hisprace2 [1,4 44] [-1,4 28] 
	spl*pov [1,3 44] [-1,3 28]
	%mend;

%macro iud_black_loinc;
%do x=23 %to 43 %by 1;
	"&x vs 28 b lo" spl [1,&x] [-1,28] spl*hisprace2 [1,2 &x] [-1,2 28] 
	spl*pov [1,3 &x] [-1,3 28],
	%end;
	"44 vs 28 b lo" spl [1,44] [-1,28] spl*hisprace2 [1,2 44] [-1,2 28] 
	spl*pov [1,3 44] [-1,3 28]
	%mend;	

%macro iud_hisp_loinc;
%do x=23 %to 43 %by 1;
	"&x vs 28 h lo" spl [1,&x] [-1,28] spl*hisprace2 [1,1 &x] [-1,1 28] 
	spl*pov [1,3 &x] [-1,3 28],
	%end;
	"44 vs 28 h lo" spl [1,44] [-1,28] spl*hisprace2 [1,1 44] [-1,1 28] 
	spl*pov [1,3 44] [-1,3 28]
	%mend;	

title 'IUD vs Anything Else';
proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl &confounders spl*hisprace2 spl*pov;
	estimate %iud_white_loinc / exp cl;
	estimate %iud_black_loinc / exp cl;
	estimate %iud_hisp_loinc / exp cl;
	ods output estimates=e_loinc;
	run;

	*damn that actually worked;

	data e_loinc; set e_loinc;
	 /* for char version, get last 5 characters */
  		label2 = substr(right(label),10);
		label3 = substr(label,1,8);
		run;

		proc print data=e_loinc; run;
		proc export data=e_loinc
		outfile="U:\Dissertation\xls_graphs\e_loinc.xlsx"
		dbms=xlsx;
		run;

	data e_loinc; set e_loinc;
		if label2 = "h lo" then race = "Hispanic";
		if label2 = "b lo" then race = "African American";
		if label2 = "w lo" then race = "White";
		drop Hispanic African_American White;
		run;

	data e_loinc; set e_loinc;
		ORR=round(ExpEstimate,.01);
		LCLR=round(LowerExp,.01);
		UCLR=round(UpperExp,.01);
		title loinc;
		run;

	proc sgplot data=e_loinc;
		band x=Label3 lower=LCLR upper=UCLR/ group=race;
		series x=Label3 y=ORR / group=race datalabel=ORR groupdisplay=overlay;
		refline "28 vs 28" / axis=x label="Ref";
		xaxis label="Age";
		yaxis label="Odds Ratio"
		type=log logbase=e;
		run;


proc print data=a (obs=20); var rscrage; format _all_; run;


***************************************
** REGRESSION MODELS, PART DEUX: KEEPING PARITY AND INCOME INTERACTIONS **
**************************************;
		*trying to figure out parameterization;
		/*proc surveylogistic data=a;
		class &class / param=ref;
		weight weightvar;
		strata stratvar;
		cluster panelvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model iud = spl &confounders spl*pov spl*parityd;
		estimate "40, low income" spl [1,40] pov [1,1]
		spl*pov [1,1 40] / exp cl e;
		ods output classlevelinfo=cli;
		ods output coef=coef;
		ods exclude assocation oddsratios parameterestimates ModelANOVA GlobalTests 
		FitStatistics TPFSplineDetails;
		run;

		proc freq data=a; tables pov; run;
		proc freq data=a; tables iud; run;
		proc freq data=a; tables parityd; run;
		proc print data=coef; run;
		proc print data=cli; run;

		proc export data=cli
			outfile="U:\Dissertation\xls_graphs\cli.xlsx"
			dbms=xlsx;
			run;*/

*************** MAKING MACROS FOR ESTIMATE STATEMENTS ***************;

** NO KIDS **;

%macro iud_0kid_loinc;
%do x=23 %to 43 %by 1;
	"&x, 0 kids, lo inc" spl [1,&x] pov [1,3] spl*pov [1,3 &x]
	parityd [1,1] spl*parityd [1,1 &x],
	%end;
	"44, 0 kids, lo inc" spl [1,44] pov [1,3] spl*pov [1,3 44]
	parityd [1,1] spl*parityd [1,1 44]
	%mend;

%macro iud_0kid_midinc;
%do x=23 %to 43 %by 1;
	"&x, 0 kids, mid inc" spl [1,&x] pov [1,1] spl*pov [1,1 &x]
	parityd [1,1] spl*parityd [1,1 &x],
	%end;
	"44, 0 kids, mid inc" spl [1,44] pov [1,1] spl*pov [1,1 44]
	parityd [1,1] spl*parityd [1,1 44]
	%mend;

%macro iud_0kid_hiinc;
%do x=23 %to 43 %by 1;
	"&x, 0 kids, hi inc" spl [1,&x] pov [1,2] spl*pov [1,2 &x]
	parityd [1,1] spl*parityd [1,1 &x],
	%end;
	"44, 0 kids, hi inc" spl [1,44] pov [1,2] spl*pov [1,2 44]
	parityd [1,1] spl*parityd [1,1 44]
	%mend;

** 1 KID **;

%macro iud_1kid_loinc;
%do x=23 %to 43 %by 1;
	"&x, 1 kid, lo inc" spl [1,&x] pov [1,3] spl*pov [1,3 &x]
	parityd [1,2] spl*parityd [1,2 &x],
	%end;
	"44, 1 kid, lo inc" spl [1,44] pov [1,3] spl*pov [1,3 44]
	parityd [1,2] spl*parityd [1,2 44]
	%mend;

%macro iud_1kid_midinc;
%do x=23 %to 43 %by 1;
	"&x, 1 kid, mid inc" spl [1,&x] pov [1,1] spl*pov [1,1 &x]
	parityd [1,2] spl*parityd [1,2 &x],
	%end;
	"44, 1 kid, mid inc" spl [1,44] pov [1,1] spl*pov [1,1 44]
	parityd [1,2] spl*parityd [1,2 44]
	%mend;

%macro iud_1kid_hiinc;
%do x=23 %to 43 %by 1;
	"&x, 1 kid, mid inc" spl [1,&x] pov [1,2] spl*pov [1,2 &x]
	parityd [1,2] spl*parityd [1,2 &x],
	%end;
	"44, 1 kid, mid inc" spl [1,44] pov [1,2] spl*pov [1,2 44]
	parityd [1,2] spl*parityd [1,2 44]
	%mend;

** 2 KIDS **;

%macro iud_2kid_loinc;
%do x=23 %to 43 %by 1;
	"&x, 2 kids, lo inc" spl [1,&x] pov [1,3] spl*pov [1,3 &x]
	parityd [1,3] spl*parityd [1,3 &x],
	%end;
	"44, 2 kids, lo inc" spl [1,44] pov [1,3] spl*pov [1,3 44]
	parityd [1,3] spl*parityd [1,3 44]
	%mend;

%macro iud_2kid_midinc;
%do x=23 %to 43 %by 1;
	"&x, 2 kids, mid inc" spl [1,&x] pov [1,1] spl*pov [1,1 &x]
	parityd [1,3] spl*parityd [1,3 &x],
	%end;
	"44, 2 kids, mid inc" spl [1,44] pov [1,1] spl*pov [1,1 44]
	parityd [1,3] spl*parityd [1,3 44]
	%mend;

%macro iud_2kid_hiinc;
%do x=23 %to 43 %by 1;
	"&x, 2 kids, hi inc" spl [1,&x] pov [1,2] spl*pov [1,2 &x]
	parityd [1,3] spl*parityd [1,3 &x],
	%end;
	"44, 2 kids, hi inc" spl [1,44] pov [1,2] spl*pov [1,2 44]
	parityd [1,3] spl*parityd [1,3 44]
	%mend;

** 3+ KIDS **;

%macro iud_3kid_loinc;
%do x=23 %to 43 %by 1;
	"&x, 3 kids, lo inc" spl [1,&x] pov [1,3] spl*pov [1,3 &x]
	parityd [1,4] spl*parityd [1,4 &x],
	%end;
	"44, 3 kids, lo inc" spl [1,44] pov [1,3] spl*pov [1,3 44]
	parityd [1,4] spl*parityd [1,4 44]
	%mend;

%macro iud_3kid_midinc;
%do x=23 %to 43 %by 1;
	"&x, 3 kids, mid inc" spl [1,&x] pov [1,1] spl*pov [1,1 &x]
	parityd [1,4] spl*parityd [1,4 &x],
	%end;
	"44, 3 kids, mid inc" spl [1,44] pov [1,1] spl*pov [1,1 44]
	parityd [1,4] spl*parityd [1,4 44]
	%mend;

%macro iud_3kid_hiinc;
%do x=23 %to 43 %by 1;
	"&x, 3 kids, hi inc" spl [1,&x] pov [1,2] spl*pov [1,2 &x]
	parityd [1,4] spl*parityd [1,4 &x],
	%end;
	"44, 3 kids, hi inc" spl [1,44] pov [1,2] spl*pov [1,2 44]
	parityd [1,4] spl*parityd [1,4 44]
	%mend;

%PUT _USER_;
%PUT _ALL_;
%PUT _GLOBAL_;
	

proc surveylogistic data=a;
class &class / param=ref;
weight weightvar;
strata stratvar;
cluster panelvar;
effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
							knotmethod=percentiles(5) details);
model iud = spl &confounders spl*pov spl*parityd;
estimate %iud_0kid_loinc / exp cl;
estimate %iud_0kid_midinc / exp cl;
estimate %iud_0kid_hiinc / exp cl;
estimate %iud_1kid_loinc / exp cl;
estimate %iud_1kid_midinc / exp cl;
estimate %iud_1kid_hiinc / exp cl;
estimate %iud_2kid_loinc / exp cl;
estimate %iud_2kid_midinc / exp cl;
estimate %iud_2kid_hiinc / exp cl;
estimate %iud_3kid_loinc / exp cl;
estimate %iud_3kid_midinc / exp cl;
estimate %iud_3kid_hiinc / exp cl;
ods output estimates=iud_kidsxincome;
run;

*figuring out why the 0 kid ones won't estimate;
	proc freq data=a; tables pov parityd; run;
	proc freq data=a; tables rscrage*iud; where pov=1 and parityd=0; run;
	proc freq data=a; tables rscrage*iud; where pov=2 and parityd=0; run;
	proc freq data=a; tables rscrage*iud; where pov=3 and parityd=0; run;

	proc freq data=a; tables iud; where rscrage=40 and pov=1 and parityd=0; run;
	proc print data=a; var iud; where rscrage=40 and pov=1 and parityd=0; run;
	proc freq data=a; tables parityd; where rscrage=40 and pov=1; run;

	proc freq data=a; tables rscrage; where parityd = 0; run;
	proc freq data=a; tables rscrage*iud; where parityd = 0; run;
	proc freq data=a; tables rscrage*iud; where parityd = 1; run;
	title;
	proc freq data=a; tables rscrage*iud; where parityd = 2; run;
	proc freq data=a; tables rscrage*iud; where parityd = 3; run;

	proc export data=e
		outfile="U:\Dissertation\xls_graphs\test.xlsx"
		dbms=xlsx
		replace;
		run;

proc print data=iud_kidsxincome; run;
data iud; set iud_kidsxincome;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno = 1 or stmtno = 2 or stmtno = 3 then delete;
	Label2 = substr(Label,1,2);
	run;

proc print data=iud; run;

title1 "IUD Use by Age, for Women with 1 Live Birth";
title2 "4 = Low Income, 5 = Mid Income, 6 = High Income";
proc sgplot data=iud;
	where stmtno = 4 or stmtno = 5 or stmtno = 6;
	band x=Label2 lower=LowerExp upper=UpperExp/ group=stmtno;
	series x=Label2 y=ExpEstimate / group=stmtno datalabel=Label2 groupdisplay=overlay;
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e;
	run;

	*running the plot code without the confidence intervals to look at the estimates more
	closely;
	title1 "IUD Use by Age, for Women with 1 Live Birth";
	title2 "4 = Low Income, 5 = Mid Income, 6 = High Income";
	proc sgplot data=iud;
		where stmtno = 4 or stmtno = 5 or stmtno = 6;
		series x=Label2 y=ExpEstimate / group=stmtno datalabel=ExpEstimate groupdisplay=overlay;
		xaxis label="Age";
		yaxis label="Odds Ratio"
		type=log logbase=e;
		run;

title1 "IUD Use by Age, for Women with 2 Live Births";
title2 "7 = Low Income, 8 = Mid Income, 9 = High Income";
proc sgplot data=iud;
	where stmtno = 7 or stmtno = 8 or stmtno = 9;
	band x=Label2 lower=LowerExp upper=UpperExp/ group=stmtno;
	series x=Label2 y=ExpEstimate / group=stmtno datalabel=Label2 groupdisplay=overlay;
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e;
	run;

	*again running without CL bands;
	title1 "IUD Use by Age, for Women with 2 Live Births";
	title2 "7 = Low Income, 8 = Mid Income, 9 = High Income";
	proc sgplot data=iud;
		where stmtno = 7 or stmtno = 8 or stmtno = 9;
		series x=Label2 y=ExpEstimate / group=stmtno datalabel=Label2 groupdisplay=overlay;
		xaxis label="Age";
		yaxis label="Odds Ratio"
		type=log logbase=e;
		run;

title1 "IUD Use by Age, for Women with 3 or more Live Births";
title2 "10 = Low Income, 11 = Mid Income, 12 = High Income";
proc sgplot data=iud;
	where stmtno = 10 or stmtno = 11 or stmtno = 12;
	band x=Label2 lower=LowerExp upper=UpperExp/ group=stmtno;
	series x=Label2 y=ExpEstimate / group=stmtno datalabel=Label2 groupdisplay=overlay;
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e;
	run;

	*again running without CL bands;
	title1 "IUD Use by Age, for Women with 3 or more Live Births";
	title2 "10 = Low Income, 11 = Mid Income, 12 = High Income";
	proc sgplot data=iud;
		where stmtno = 10 or stmtno = 11 or stmtno = 12;
		series x=Label2 y=ExpEstimate / group=stmtno datalabel=ExpEstimate groupdisplay=overlay;
		xaxis label="Age";
		yaxis label="Odds Ratio"
		type=log logbase=e;
		run;


** Using age at first birth as the interacting variable;

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

title1 "IUD Use by Age & Age at First Birth";
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

* Hey Teen! ^^ This is excellent coding for the chart you
	want, so you can use it as a good example;

***************************************************
*** FINAL MODEL WITH INTERACTION, PROBABILITIES ***
***************************************************;

** Macros for estimating age effects within each age at first birth group;

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
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	run;

	/*title "IUD Use by Age & Age at First Birth";*/
	title;
proc sgplot data=e_early;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr;
	format probr 3.2;
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Probability"
	/*type=log logbase=e logstyle=linear*/
	values=(0 0.1 0.2 0.25);
	run;



*****************
	Same but for only people using a reversible method
****************;

	data a; set a;
		iud_rev = iud;
		if bcc = 1 then iud_rev = .;
		run;
		proc freq data=a; tables iud_rev; run;
		proc freq data=a; tables iud; run;

	proc surveylogistic data=a;
	class iud_rev(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud_rev = spl edud earlybirth hisprace2 pov parityd rwant mard
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
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	run;

	/*title "IUD Use by Age & Age at First Birth";*/
	title;
proc sgplot data=e_early;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	format probr 3.2;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Probability"
	/*type=log logbase=e logstyle=linear*/
	values=(0 0.1 0.2 0.25);
	run;


*### SECOND DRAFT ESTIMATES, SPECIFYING COVARIATES ###;

*** Bachelor's degree, white, high income, 2 kids, wants more kids, married, private insurance;

%macro teen;
%do x=23 %to 43 %by 1;
	"&x, 1st birth teens" intercept 1 spl [1,&x] earlybirth [1,1] 
		spl*earlybirth [1,1 &x] edud [1,1] hisprace2 [1,4] pov [1,2] parityd [1,3] rwant [1,3]
		mard [1,1] curr_ins [1,4],
	%end;
	"44, 1st birth teens" intercept 1 spl [1,44] earlybirth [1,1] 
		spl*earlybirth [1,1 44] edud [1,1] hisprace2 [1,4] pov [1,2] parityd [1,3] rwant [1,3]
		mard [1,1] curr_ins [1,4]
	%mend;

%macro earlytwenties;
%do x=23 %to 43 %by 1;
	"&x, 1st birth 20-24" intercept 1 spl [1,&x] earlybirth [1,2] 
		spl*earlybirth [1,2 &x] edud [1,1] hisprace2 [1,4] pov [1,2] parityd [1,3] rwant [1,3]
		mard [1,1] curr_ins [1,4],
	%end;
	"44, 1st birth 20-24" intercept 1 spl [1,44] earlybirth [1,2] 
		spl*earlybirth [1,2 44] edud [1,1] hisprace2 [1,4] pov [1,2] parityd [1,3] rwant [1,3]
		mard [1,1] curr_ins [1,4]
	%mend;

%macro laterbirth;
%do x=23 %to 42 %by 1;
	"&x, 1st birth >24/0" intercept 1 spl [1,&x] earlybirth [1,3] 
		spl*earlybirth [1,3 &x] edud [1,1] hisprace2 [1,4] pov [1,2] parityd [1,3] rwant [1,3]
		mard [1,1] curr_ins [1,4],
	%end;
	"44, 1st birth >24/0" intercept 1 spl [1,44] earlybirth [1,3] 
		spl*earlybirth [1,3 44] edud [1,1] hisprace2 [1,4] pov [1,2] parityd [1,3] rwant [1,3]
		mard [1,1] curr_ins [1,4]
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
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	run;

	/*title "IUD Use by Age & Age at First Birth";*/
	title;
proc sgplot data=e_early;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr;
	format probr 3.2;
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Probability"
	/*type=log logbase=e logstyle=linear*/
	values=(0 0.1 0.2 0.3 0.4 0.5 0.6);
	run;




*######;

*** HS degree, NHB, low income, 2 kids, wants more kids, never been married, Medicaid;

%macro teen;
%do x=23 %to 43 %by 1;
	"&x, 1st birth teens" intercept 1 spl [1,&x] earlybirth [1,1] 
		spl*earlybirth [1,1 &x] edud [1,2] hisprace2 [1,2] pov [1,3] parityd [1,3] rwant [1,3]
		mard [1,3] curr_ins [1,2],
	%end;
	"44, 1st birth teens" intercept 1 spl [1,44] earlybirth [1,1] 
		spl*earlybirth [1,1 44] edud [1,2] hisprace2 [1,2] pov [1,3] parityd [1,3] rwant [1,3]
		mard [1,3] curr_ins [1,2]
	%mend;

%macro earlytwenties;
%do x=23 %to 43 %by 1;
	"&x, 1st birth 20-24" intercept 1 spl [1,&x] earlybirth [1,2] 
		spl*earlybirth [1,2 &x] edud [1,2] hisprace2 [1,2] pov [1,3] parityd [1,3] rwant [1,3]
		mard [1,3] curr_ins [1,2],
	%end;
	"44, 1st birth 20-24" intercept 1 spl [1,44] earlybirth [1,2] 
		spl*earlybirth [1,2 44] edud [1,2] hisprace2 [1,2] pov [1,3] parityd [1,3] rwant [1,3]
		mard [1,3] curr_ins [1,2]
	%mend;

%macro laterbirth;
%do x=23 %to 42 %by 1;
	"&x, 1st birth >24/0" intercept 1 spl [1,&x] earlybirth [1,3] 
		spl*earlybirth [1,3 &x] edud [1,2] hisprace2 [1,2] pov [1,3] parityd [1,3] rwant [1,3]
		mard [1,3] curr_ins [1,2],
	%end;
	"44, 1st birth >24/0" intercept 1 spl [1,44] earlybirth [1,3] 
		spl*earlybirth [1,3 44] edud [1,2] hisprace2 [1,2] pov [1,3] parityd [1,3] rwant [1,3]
		mard [1,3] curr_ins [1,2]
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
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	run;

	/*title "IUD Use by Age & Age at First Birth";*/
	title;
proc sgplot data=e_early;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr;
	format probr 3.2;
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Probability"
	/*type=log logbase=e logstyle=linear*/
	values=(0 0.1 0.2 0.3);
	run;


*######;

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
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	run;

	/*title "IUD Use by Age & Age at First Birth";*/
	title;
proc sgplot data=e_early;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr;
	format probr 3.2;
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Probability"
	/*type=log logbase=e logstyle=linear*/
	values=(0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8);
	run;


*### EFFECT CODING ###;

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
	class iud(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=effect;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl edud earlybirth hisprace2 pov parityd rwant mard
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
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	run;


	/*title "IUD Use by Age & Age at First Birth";*/
	title;
proc sgplot data=e_early;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr;
	format probr 3.2;
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Probability"
	/*type=log logbase=e logstyle=linear*/
	values=(0 0.1 0.2 0.3 0.4 0.5 0.6);
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
	class iud(ref=first)
	earlybirth (ref=">24 or no live births") / param=effect;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl earlybirth spl*earlybirth;
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
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	run;

	/*title "IUD Use by Age & Age at First Birth";*/
	title;
proc sgplot data=e_early;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr;
	format probr 3.2;
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Probability"
	/*type=log logbase=e logstyle=linear*/
	values=(0 0.1 0.2 0.3 0.4 0.5 0.6);
	run;



*### SECOND DRAFT ESTIMATES, ORs ###;

*** All compared to 25+;

%macro teen;
%do x=23 %to 43 %by 1;
	"&x, 15-19 vs 25+" intercept 0 spl [0,&x] age1b [1,2] [-1,4] 
		spl*age1b [1,2 &x] [-1,4 &x],
	%end;
	"44, 15-19 vs 25+" intercept 0 spl [0,44] age1b [1,2] [-1,4] 
		spl*age1b [1,2 44] [-1,4 44]
	%mend;

%macro earlytwenties;
%do x=23 %to 43 %by 1;
	"&x, 20-24 vs 25+" intercept 0 spl [0,&x] age1b [1,2] [-1,4] 
		spl*age1b [1,2 &x] [-1,4 &x],
	%end;
	"44, 20-24 vs 25+" intercept 0 spl [0,44] age1b [1,2] [-1,4] 
		spl*age1b [1,2 44] [-1,4 44]
	%mend;

%macro nobirths;
%do x=23 %to 43 %by 1;
	"&x, 0 births vs 25+" intercept 0 spl [0,&x] age1b [1,1] [-1,4] 
		spl*age1b [1,1 &x] [-1,4 &x],
	%end;
	"44, 0 births vs 25+" intercept 0 spl [0,44] age1b [1,1] [-1,4] 
		spl*age1b [1,1 44] [-1,4 44]
	%mend;

proc surveylogistic data=a;
	where rscrage > 29;
	class iud(ref=first) edud(ref="hs degree or ged") 
	age1b (ref="1") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=effect;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl edud age1b hisprace2 pov parityd rwant mard
	curr_ins spl*age1b;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %nobirths / exp cl ilink;
	ods output Estimates=e;
	run;

	/*proc print data=e; run;*/


data e_early; set e;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then age1b = "15-19 vs 25+";
	if stmtno=2 then age1b = "20-24 vs 25+";
	if stmtno=3 then age1b = "0 births vs 25+";
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	run;

	/*title "IUD Use by Age & Age at First Birth";*/
	title;
proc sgplot data=e_early;
	/*band x=Label2 lower=LCLR upper=UCLR / group=age1b
	transparency = .5;*/
	scatter x=Label2 y=probr / group=age1b datalabel=probr yerrorupper=UCLR yerrorlower=LCLR;
	format probr 3.2;
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="OR"
	type=log logbase=e logstyle=linear
	/*values=(0 0.1 0.2 0.3 0.4 0.5 0.6)*/;
	run;


*### SECOND DRAFT ESTIMATES, ORs ###;

*** All compared to 15-19;

%macro earlytwenties;
%do x=23 %to 43 %by 1;
	"&x, 20-24 vs 15-19" intercept 0 spl [0,&x] age1b [1,3] [-1,2] 
		spl*age1b [1,3 &x] [-1,2 &x],
	%end;
	"44, 20-24 vs 15-19" intercept 0 spl [0,44] age1b [1,3] [-1,2] 
		spl*age1b [1,3 44] [-1,2 44]
	%mend;

%macro older;
%do x=23 %to 43 %by 1;
	"&x, 25+ vs 15-19" intercept 0 spl [0,&x] age1b [1,4] [-1,2] 
		spl*age1b [1,4 &x] [-1,2 &x],
	%end;
	"44, 25+ vs 15-19" intercept 0 spl [0,44] age1b [1,4] [-1,2] 
		spl*age1b [1,4 44] [-1,2 44]
	%mend;

%macro nobirths;
%do x=23 %to 43 %by 1;
	"&x, 0 births vs 15-19" intercept 0 spl [0,&x] age1b [1,1] [-1,2] 
		spl*age1b [1,1 &x] [-1,2 &x],
	%end;
	"44, 0 births vs 15-19" intercept 0 spl [0,44] age1b [1,1] [-1,2] 
		spl*age1b [1,1 44] [-1,2 44]
	%mend;

proc surveylogistic data=a;
	where rscrage > 29;
	class iud(ref=first) edud(ref="hs degree or ged") 
	age1b (ref="1") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=effect;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud = spl edud age1b hisprace2 pov parityd rwant mard
	curr_ins spl*age1b;
	estimate %earlytwenties / exp cl ilink;
	estimate %older / exp cl ilink;
	estimate %nobirths / exp cl ilink;
	ods output Estimates=e;
	run;

	/*proc print data=e; run;*/


data e_early; set e;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then age1b = "20-24 vs teen";
	if stmtno=2 then age1b = "25+ vs teen";
	if stmtno=3 then age1b = "0 births vs teen";
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	label earlybirth = "Age at First Birth Group";
	run;

	/*title "IUD Use by Age & Age at First Birth";*/
	title;
proc sgplot data=e_early;
	/*band x=Label2 lower=LCLR upper=UCLR / group=age1b
	transparency = .5;*/
	scatter x=Label2 y=probr / group=age1b datalabel=probr yerrorupper=UCLR yerrorlower=LCLR;
	format probr 3.2;
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="OR"
	type=log logbase=e logstyle=linear
	values=(0.1 0.5 1 2 3 5);
	run;



*** EFFECT PARAMETERIZATION AMONG PEOPLE USING A REVERSIBLE METHOD ***;

	data a; set a;
		iud_rev = iud;
		if bcc = 1 then iud_rev = .;
		run;
		proc freq data=a; tables iud_rev; run;
		proc freq data=a; tables iud; run;

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
	class iud_rev(ref=first) edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model iud_rev = spl edud earlybirth hisprace2 pov parityd rwant mard
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
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	label earlybirth = "Age at First Birth Group";
	run;

	/*title "IUD Use by Age & Age at First Birth";*/
	title;
proc sgplot data=e_early;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth
	transparency = .5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	format probr 3.2;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Predicted Probability"
	/*type=log logbase=e logstyle=linear*/
	values=(0 0.1 0.2 0.25);
	run;

