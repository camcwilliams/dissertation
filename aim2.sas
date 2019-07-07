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

*******************
* MODEL 2: NO USE VS ANY USE;
*******************;

ods trace on;
ods graphics on / reset=index imagename="nouse";
ods listing gpath = "U:\Dissertation\sas_graphs_nouse";

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
