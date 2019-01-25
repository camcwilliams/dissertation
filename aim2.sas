*############################################*
*######### McWilliams Dissertation ##########*
*##### Aim 2 Logistic Regression Model #####*
*############################################*;

libname library "U:\Dissertation";
%include "U:\Dissertation\nsfg_CMcWFormats.sas";
data a; set library.nsfg; run;

*Removing respondents under 23;
data a; set a;
	if rscrage < 23 then delete;
	run;


*******************
* MODEL 2: NO USE VS ANY USE;
*******************;

ods trace on;
ods graphics on / reset=index imagename="nouse";
ods listing gpath = "U:\Dissertation\sas_graphs_nouse";

* FREQUENCIES;

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

* BIVARIATE;

proc surveylogistic data=a;
	class nouse (ref = "using contraception");
	weight weightvar;
	effect spl=spline(rscrage / details naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5));
	model nouse = spl;
	estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
	estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	output out=nouse pred=pred;
	ods output Estimates=enuAge;
	ods output FitStatistics=fsnuAge;
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
