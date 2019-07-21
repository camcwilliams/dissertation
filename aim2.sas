*############################################*
*######### McWilliams Dissertation ##########*
*##### Aim 2 Logistic Regression Model #####*
*############################################*;

libname library "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\nsfg_CMcWFormats.sas";
data a; set library.nsfg; run;

/*
*Removing respondents under 23;
data a; set a;
	if rscrage < 23 then delete;
	run;
*/
*commenting out, permanent dataset now does not include people under 23;

*Additional restriction for full analytic sample;

*Not at risk of UIP;
	proc means data=a; var rscrage; where elig=0; run;

	data a; set a;
		if elig=0 then delete;
		run;

*******************
* MODEL 2: NO USE VS ANY USE;
*******************;

ods trace on;
ods graphics on / reset=index imagename="nouse";
ods listing gpath = "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\sas_graphs_nouse";

*########### TABLE 1 ###########;

proc freq data=a; tables bcc; run;

proc freq data=a; tables agecat*nouse / nofreq nopercent nocol; run;

proc freq data=a; tables (&confounders)*nouse / nofreq nopercent nocol; run;
proc freq data=a; tables (&confounders)*nouse; run;
proc freq data=a; tables (&confounders)*nouse / nopercent norow nocol; run;

%let confounders = agecat edud hisprace2 pov agebabycat parityd rwant mard curr_ins;

*creating frequency for each variable with 4-cat outcome;
%macro tableone;
	%let i=1;
	%do %until(not %length(%scan(&confounders,&i)));
proc freq data=a; 
	tables (%scan(&confounders,&i))*nouse; 
	ods output crosstabfreqs=ct_cont_%scan(&confounders,&i); 
	run;
	%let i=%eval(&i+1);
	%end;
	%mend tableone;

	%tableone;

	proc print data=ct_cont_edud; run;
	proc print data=ct_cont_edud; where _type_ = "00"; run;

proc sort data=ct_cont_edud; by edud; run;
proc transpose data=ct_cont_edud out=test;
	by edud;
	id nouse;
	run;
	proc print data=test; run;

%macro tableonetwo;
	%let i=1;
	%do %until(not %length(%scan(&confounders,&i)));
*removing unnecessary rows and columns, creating new outcome variable to make
transposing easier;
data %scan(&confounders,&i); set aim2_bcc_%scan(&confounders,&i);
	if _type_ = 10 then delete;
	drop _table_ table;
	bc_group = bcc;
	format bc_group bcc.;
	if bcc = . then bc_group = 5;
	if %scan(&confounders,&i) = . then %scan(&confounders,&i) = 10;
	if frequency = 8148 then delete;
	run;

*transposing;
proc transpose data=%scan(&confounders,&i) out=%scan(&confounders,&i);
	by %scan(&confounders,&i);
	id bc_group;
	run;

*renaming rows to make a 'total' row;
data %scan(&confounders,&i); set %scan(&confounders,&i);
	if %scan(&confounders,&i) = 10 and _name_ = "RowPercent" then delete;
	if %scan(&confounders,&i) = 10 and _name_ = "ColPercent" then delete;
	if %scan(&confounders,&i) = 10 and _name_ = "Percent" then _name_ = "RowPercent";
	run;

*deleting unnecessary rows;
data %scan(&confounders,&i); set %scan(&confounders,&i);
	if _name_ ne "RowPercent" and _name_ ne "Frequency" then delete;
	if _name_ = "Frequency" then Count_naruip=_5;
	if _name_ = "Frequency" then Count_sterilized=sterilized;
	if _name_ = "Frequency" then Count_reversdoc=reversible__needs_doc;
	if _name_ = "Frequency" then Count_reversnodoc=reversible__doesn_t_need_doc;
	if _name_ = "Frequency" then Count_nouse=not_using_contraception;
	drop bcc _type_ frequency percent rowpercent colpercent missing bc_group;
	run;

*making a new variable column so datasets can be concatenated;
data %scan(&confounders,&i); set %scan(&confounders,&i);
	if %scan(&confounders,&i) = 0 then covariate = "0%scan(&confounders,&i)";
	if %scan(&confounders,&i) = 1 then covariate = "1%scan(&confounders,&i)";
	if %scan(&confounders,&i) = 2 then covariate = "2%scan(&confounders,&i)";
	if %scan(&confounders,&i) = 3 then covariate = "3%scan(&confounders,&i)";
	if %scan(&confounders,&i) = 4 then covariate = "4%scan(&confounders,&i)";
	if %scan(&confounders,&i) = 5 then covariate = "5%scan(&confounders,&i)";
	if %scan(&confounders,&i) = 6 then covariate = "6%scan(&confounders,&i)";
	if %scan(&confounders,&i) = 7 then covariate = "7%scan(&confounders,&i)";
	if %scan(&confounders,&i) = 8 then covariate = "8%scan(&confounders,&i)";
	if %scan(&confounders,&i) = 9 then covariate = "9%scan(&confounders,&i)";
	if %scan(&confounders,&i) = 10 then covariate = "10%scan(&confounders,&i)";
	run;

data %scan(&confounders,&i); set %scan(&confounders,&i);
	retain CountNARUIP CountSTERILIZED CountREVERSDOC 
	CountREVERSNODOC CountNOUSE;
	output;
	CountNARUIP = Count_naruip;
	CountSTERILIZED = Count_sterilized;
	CountREVERSDOC = Count_reversdoc;
	CountREVERSNODOC = Count_reversnodoc;
	CountNOUSE = Count_nouse;
	run;

data %scan(&confounders,&i); set %scan(&confounders,&i);
	drop Count_naruip Count_sterilized Count_reversdoc Count_reversnodoc Count_nouse;
	if _name_ = "Frequency" then delete;
	run;

data %scan(&confounders,&i); 
	format covariate count5 naruip count4 sterilization 
	count3 reversdoc count2 reversnodoc count1 nouse;
	set %scan(&confounders,&i);
	drop _name_;
	run;

	%let i=%eval(&i+1);
	%end;
	%mend tableonetwo;

	%tableonetwo;


*concatenating datasets;
data tableone;
	set edud hisprace2 pov agebabycat parityd rwant mard curr_ins;
	run;

data tableone; set tableone;
	drop edud hisprace2 pov agebabycat parityd rwant mard curr_ins;
	run;

	proc print data=tableone; run;

proc export data=tableone
	dbms = xlsx
	outfile="C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\xls_graphs\aim1table1final.xlsx";
	run;

*For the most part, the output table looks good. For some reason pov did
	not get created appropriately so I will be doing that by hand in excel;

proc freq data=a; tables pov*bcc / missing; run;

* FREQUENCIES;

proc freq data=a; tables nouse nouse*rscrage; weight weightvar; run;

proc freq data=a; tables nouse nouse*rscrage / nofreq nopercent norow; 
weight weightvar; 
ods output OneWayFreqs=nousefreq;
ods output CrossTabFreqs=nousecross; run;

proc print data=nousecross; format nouse 3.1; run;

data nousecross; set nousecross;
	ColPercentp = ColPercent/100;
	keep nouse rscrage ColPercent;
	if nouse = 0 then delete;
	if nouse = . then delete;
	if rscrage = . then delete;
	run;

	proc print data=nousecross; run;

proc sgplot data=nousecross;
	vbar rscrage / response = ColPercent;
	xaxis label="Age";
	yaxis label="Percent";
	format rscrage _all_;
	run;

	proc freq data=a; tables nouse; run;

* BIVARIATE;

%macro bivariate;
%do x=23 %to 43 %by 1;
	"&x" intercept 0 spl [0,&x],
	%end;
	"44" intercept 0 spl [0,44]
	%mend;

proc surveylogistic data=a;
	class nouse (ref = "using contraception");
	weight weightvar;
	effect spl=spline(rscrage / details naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5));
	model nouse = spl;
	output out=nouse pred=pred;
	/*ods output Estimates=enuAge;
	ods output FitStatistics=fsnuAge;*/
	run;

proc sgplot data=nouse;
	scatter y=pred x=rscrage;
	run;

* REGRESSION;

title 'nouse = age + demographics';
proc surveylogistic data=a;
	class nouse (ref = "using contraception") edu (ref="hs degree or ged")
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
		povlev (ref="100-199% PL") ;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edu hisprace2 povlev;
	estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
	estimate '28 vs 25' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	ods output Estimates=enu_age_dem;
	ods output FitStatistics=fsnu_age_dem;
	ods output OddsRatios=ORnu_age_dem;
	run;

title 'nouse = age + demographics + fert';
proc surveylogistic data=a;
	class nouse (ref = "using contraception") edu (ref="hs degree or ged")
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
		povlev (ref="100-199% PL") agebabycat parity (ref="1 BABY") 
		rwant (ref=first) mard (ref="never been married");
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edu hisprace2 povlev agebabycat parity rwant mard;
	estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
	estimate '28 vs 25' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	ods output Estimates=enu_age_dem_fert;
	ods output FitStatistics=fsnu_age_dem_fert;
	ods output OddsRatios=ORnu_age_dem_fert;
	run;	

title 'nouse = age + demographics + fert + insurance';
proc surveylogistic data=a;
	class nouse (ref = "using contraception") edu (ref="hs degree or ged")
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
		povlev (ref="100-199% PL") agebabycat parity (ref="1 BABY") 
		rwant (ref=first) mard (ref="never been married") curr_ins;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edu hisprace2 povlev agebabycat parity rwant mard curr_ins;
	estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
	estimate '28 vs 25' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	ods output Estimates=enu_age_dem_fert_ins;
	ods output FitStatistics=fsnu_age_dem_fert_ins;
	ods output OddsRatios=ORnu_age_dem_fert_ins;
	run;	

title 'nouse = age + demographics + fert + insurance + interactions';
proc surveylogistic data=a;
	class nouse (ref = "using contraception") edu (ref="hs degree or ged")
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
		povlev (ref="100-199% PL") agebabycat parity (ref="1 BABY") 
		rwant (ref=first) mard (ref="never been married") curr_ins;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edu hisprace2 povlev agebabycat parity rwant mard curr_ins
	hisprace2*agebabycat edu*agebabycat hisprace2*edu;
	estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
	estimate '28 vs 25' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	ods output Estimates=enu_age_dem_fert_ins_int;
	ods output FitStatistics=fsnu_age_dem_fert_ins_int;
	ods output OddsRatios=ORnu_age_dem_fert_ins_int;
	run;	

title 'nouse = everything + all suspected interactions';
proc surveylogistic data=a;
	class nouse (ref = "using contraception") edu (ref="hs degree or ged")
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
		povlev (ref="100-199% PL") agebabycat parity (ref="2 BABIES") 
		rwant (ref=first) mard (ref="never been married") curr_ins;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edu hisprace2 povlev agebabycat parity rwant mard curr_ins
	edu*hisprace2 edu*agebabycat hisprace2*agebabycat
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
	ods output Estimates=enu_all2;
	ods output FitStatistics=fsnu_all2;
	ods output OddsRatios=ORnu_all2;
	ods output ModelANOVA=jtnu_all2;
	run;	

	proc export data=jtnu_all2
		outfile="U:\Dissertation\xls_graphs\jtnu_all2.xlsx"
		dbms=xlsx;
		run;

proc freq data=a; tables mard; weight weightvar; run;

%macro nouse_age;
%do x=23 %to 43;
"&x vs 28, married" spl [1,&x] [-1,28] spl*mard [1,1 &x] [-1,1 28],
%end;
"44 vs 28, married" spl [1,44] [-1,28] spl*mard [1,1 44] [-1,1 28]
%mend;


title 'nouse, final model, currently married';
proc surveylogistic data=a;
	class nouse (ref = "using contraception") edu (ref="hs degree or ged")
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
		povlev (ref="100-199% PL") agebabycat parityd (ref="2 BABIES") 
		rwant (ref=first) mard (ref="never been married") curr_ins;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edu hisprace2 povlev agebabycat parity rwant mard curr_ins
	edu*agebabycat hisprace2*agebabycat spl*mard;
	estimate %nouse_age / exp cl;
	run;	

proc freq data=a; tables edu; weight weightvar; run;
title;
proc freq data=a; tables hisprace2; run;
proc freq data=a; tables edu; weight weightvar; where hisprace2 = 3; run;


**************************
FINAL MODEL AS USED IN AIM 1
**************************;

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

title 'nouse = all vars of interest, includes interaction';
proc surveylogistic data=a;
	class nouse (ref="using contraception") edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e_nouse;
	run;


data e_nouse; set e_nouse;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	if stmtno=3 then earlybirth = ">24/0";
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	run;
/*
title1 "Probability of Not Using Any Contraception";
title2 "Among Women at Risk of Unintended Pregnancy";
title3 "By Age & Age at First Birth";
*/
	title;
proc sgplot data=e_nouse;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	format probr 3.2;
	xaxis label="Age";
	yaxis label="Probability"
	/*type=log logbase=e logstyle=linear*/ values=(0 0.1 0.2 0.3 0.4 0.5);
	run;


*with key legend;
	title;
proc sgplot data=e_nouse;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	format probr 3.2;
	xaxis label="Age";
	yaxis label="Probability"
	/*type=log logbase=e logstyle=linear*/ values=(0 0.1 0.2 0.3 0.4 0.5);
	keylegend / title="Age at First Birth";
	run;

*** Adding ever needed help getting pregnant;

proc freq data=a; tables ANYPRGHP; run;

title 'nouse = all vars of interest, includes interaction';
proc surveylogistic data=a;
	class nouse (ref="using contraception") edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth ANYPRGHP;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e_nouse_help;
	run;


data e_nouse_help; set e_nouse_help;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	if stmtno=3 then earlybirth = ">24/0";
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	run;
/*
title1 "Probability of Not Using Any Contraception";
title2 "Among Women at Risk of Unintended Pregnancy";
title3 "By Age & Age at First Birth";
*/
	title;
proc sgplot data=e_nouse_help;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	format probr 3.2;
	xaxis label="Age";
	yaxis label="Probability"
	/*type=log logbase=e logstyle=linear values=(0 0.1 0.2 0.3 0.4 0.5)*/;
	run;


*** Sexual frequency;
proc freq data=a;
	tables nosex12;
	format nosex12 _all_;
	run;

data a; set a;
	if nosex12 = 95 then nosex12 = .;
	run;

proc sort data=a; by agecat; run;
proc means data=a;
	var NOSEX12;
	by agecat;
	run;

proc sgplot data=a;
	vbox nosex12 / category=agecat;
	run;

proc freq data=a;
	tables agecat*nosex12;
	run;


ods html close; ods html;


* ### EFFECT PARAMETERIZATION FOR MAIN MODEL (IN CHAPTER TEXT) ###;

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

title 'nouse = all vars of interest, includes interaction';
proc surveylogistic data=a;
	class nouse (ref="using contraception") edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=effect;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e_nouse;
	run;


data e_nouse; set e_nouse;
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
/*
title1 "Probability of Not Using Any Contraception";
title2 "Among Women at Risk of Unintended Pregnancy";
title3 "By Age & Age at First Birth";
*/
	title;
proc sgplot data=e_nouse;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	format probr 3.2;
	xaxis label="Age";
	yaxis label="Predicted Probability"
	/*type=log logbase=e logstyle=linear*/ values=(0 0.1 0.2 0.3 0.4 0.5);
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
	class nouse (ref="using contraception") edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e_nouse;
	run;


data e_nouse; set e_nouse;
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


proc sgplot data=e_nouse;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	format probr 3.2;
	xaxis label="Age";
	yaxis label="Predicted Probability"
	/*type=log logbase=e logstyle=linear*/ values=(0 0.1 0.2 0.3 0.4 0.5);
	run;


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
	class nouse (ref="using contraception") edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e_nouse;
	run;


data e_nouse; set e_nouse;
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


proc sgplot data=e_nouse;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	format probr 3.2;
	xaxis label="Age";
	yaxis label="Predicted Probability"
	/*type=log logbase=e logstyle=linear*/ values=(0 0.1 0.2 0.3 0.4 0.5);
	run;


*** Bachelor's degree, NHB, high income, 0 kids, wants more kids, never been married, private insurance;

%macro teen;
%do x=23 %to 43 %by 1;
	"&x, 1st birth teens" intercept 1 spl [1,&x] earlybirth [1,1] 
		spl*earlybirth [1,1 &x] edud [1,1] hisprace2 [1,2] pov [1,2] parityd [1,1] rwant [1,3]
		mard [1,3] curr_ins [1,4],
	%end;
	"44, 1st birth teens" intercept 1 spl [1,44] earlybirth [1,1] 
		spl*earlybirth [1,1 44] edud [1,1] hisprace2 [1,2] pov [1,2] parityd [1,1] rwant [1,3]
		mard [1,3] curr_ins [1,4]
	%mend;

%macro earlytwenties;
%do x=23 %to 43 %by 1;
	"&x, 1st birth 20-24" intercept 1 spl [1,&x] earlybirth [1,2] 
		spl*earlybirth [1,2 &x] edud [1,1] hisprace2 [1,2] pov [1,2] parityd [1,1] rwant [1,3]
		mard [1,3] curr_ins [1,4],
	%end;
	"44, 1st birth 20-24" intercept 1 spl [1,44] earlybirth [1,2] 
		spl*earlybirth [1,2 44] edud [1,1] hisprace2 [1,2] pov [1,2] parityd [1,1] rwant [1,3]
		mard [1,3] curr_ins [1,4]
	%mend;

%macro laterbirth;
%do x=23 %to 42 %by 1;
	"&x, 1st birth >24/0" intercept 1 spl [1,&x] earlybirth [1,3] 
		spl*earlybirth [1,3 &x] edud [1,1] hisprace2 [1,2] pov [1,2] parityd [1,1] rwant [1,3]
		mard [1,3] curr_ins [1,4],
	%end;
	"44, 1st birth >24/0" intercept 1 spl [1,44] earlybirth [1,3] 
		spl*earlybirth [1,3 44] edud [1,1] hisprace2 [1,2] pov [1,2] parityd [1,1] rwant [1,3]
		mard [1,3] curr_ins [1,4]
	%mend;


proc surveylogistic data=a;
	class nouse (ref="using contraception") edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e_nouse;
	run;


data e_nouse; set e_nouse;
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


proc sgplot data=e_nouse;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	format probr 3.2;
	xaxis label="Age";
	yaxis label="Predicted Probability"
	/*type=log logbase=e logstyle=linear*/ values=(0 0.1 0.2 0.3 0.4 0.5);
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
	class nouse (ref="using contraception") edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e_nouse;
	run;


data e_nouse; set e_nouse;
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


proc sgplot data=e_nouse;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	format probr 3.2;
	xaxis label="Age";
	yaxis label="Predicted Probability"
	/*type=log logbase=e logstyle=linear*/ values=(0 0.1 0.2 0.3 0.4 0.5);
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
	class nouse (ref="using contraception")
	earlybirth (ref=">24 or no live births") / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl earlybirth spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e_nouse;
	run;


data e_nouse; set e_nouse;
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


proc sgplot data=e_nouse;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	format probr 3.2;
	xaxis label="Age";
	yaxis label="Predicted Probability"
	/*type=log logbase=e logstyle=linear*/ values=(0 0.1 0.2 0.3 0.4 0.5);
	run;



* ### FINAL MODEL, ORs ###;

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
	class nouse (ref="using contraception") edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model nouse = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl;
	estimate %earlytwenties / exp cl;
	ods output Estimates=e_or;
	run;


data e_or; set e_or;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19 vs 25+/0";
	if stmtno=2 then earlybirth = "20-24 vs 25+/0";
	ORR=round(ExpEstimate,.01);
	LCLR=round(LowerExp,.01);
	UCLR=round(UpperExp,.01);
	Label2=substr(Label,1,2);
	label earlybirth = "Age at First Birth Group";
	run;

		data test; set e_or;
		rename label2 = age;
		CI = cats('(',lclr,', ',uclr,')');
		drop label probt expestimate lowerexp upperexp lclr uclr;
		run;

		proc print data=test; run;


proc sgplot data=e_OR;
	scatter x=Label2 y=ORR / group=earlybirth datalabel=ORR 
	yerrorupper=UCLR yerrorlower=LCLR;
	format orr 3.2;
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e logstyle=linear;
	run;
