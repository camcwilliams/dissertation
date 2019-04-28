*############################################*
*######### McWilliams Dissertation ##########*
*##### Aim 1 Logistic Regression Models #####*
*####### Needs HC Provider vs Doesn't #######*
*############################################*;


libname library "U:\Dissertation";
%include "U:\Dissertation\nsfg_CMcWFormats.sas";
data a; set library.nsfg; run;

/*Removing respondents under 23;
data a; set a;
	if rscrage < 23 then delete;
	run;*/ *permanent dataset now does not include people over 23;

*******************
* LEVEL 1: HCP REQUIRED VS NOT;
*******************;

*Turning on ODS trace and setting up so charts get saved;

ods trace on;
ods graphics on / reset=index imagename="doc_age";
ods listing gpath = "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\sas_graphs_doc";

proc freq data=a; tables bc; ods output onewayfreqs=bcfreq; run;
proc print data=bcfreq; format bc 3.1; run;

*DESCRIPTIVES FOR HCP REQUIRED VS NOT;

* Makes little dataset for simple proportion table;
proc freq data=a;
	tables doc;
	ods output OneWayFreqs=docfreq1;
	run;

	*formatting to make the frequency datasets nicer;
	data docfreq1; set docfreq1;
		drop f_doc Table CumFrequency CumPercent;
		rename doc = Doc;
		run;

	proc print data=docfreq1; run;
	proc export data=docfreq1 dbms=xlsx outfile="U:\Dissertation\xls_graphs\docfreq2.xlsx";
	run;

	/*proc export data=allrfreq
	dbms=xlsx
	outfile="U:\Dissertation\xls_graphs\allrfreq.xlsx"
	replace;
	run;*/

*Trying the freqs using strata and cluster variables, they do not
	change the estimates;

proc surveyfreq data=a;
	tables doc;
	strata stratvar;
	cluster panelvar;
	weight weightvar;
	ods output OneWay=docsf;
	run; 

	proc print data=docsf; run;

	proc freq data=a; tables doc*bcc; run;

	proc print data=a;
		where doc = 1 and bcc = 3;
		var bcc doc constat1 caseid;
		run;

*plotting the relationship between outcome and age, no adjustment;
title 'simple relationship between outcome and age';

proc freq data=a; 
	tables rscrage*doc; 
	weight weightvar; 
	ods output CrossTabFreqs=doc_age;
	run;

proc sgplot data=doc_age;
	vbar rscrage / Response=RowPercent;
	format rscrage _all_;
	where doc = 2;
	xaxis label = "Age";
	yaxis label = "Percent";
	run;
	
	*Per Jenny's recommendation, plotting condoms 
	to see if 'not requiring a hcp' is really just condoms;

	data a; set a;
		cond = 0;
		if constat1 = 12 then cond = 1;
		if allrepro >= 1 and allrepro <= 3 then cond = 0;
		if allrepro >= 6 and allrepro <= 9 then cond = 0;
		if allrepro = 4 and cond ne 1 then cond = 0;
		if allrepro >10 then cond = .;
		run;

		proc freq data=a; tables allrepro*cond; run;

		proc freq data=a;
			tables rscrage*cond;
			weight weightvar;
			ods output CrossTabFreqs=cond_age;
			run;

		proc sgplot data=cond_age;
			vbar rscrage / Response=RowPercent;
			format rscrage _all_;
			where cond = 1;
			xaxis label = "Age";
			yaxis label = "Percent";
			run;

		proc freq data=a; tables rscrage*cond; where allrepro = 4; run;

		proc freq data=a; tables doc*cond; run;
		proc freq data=a; tables doc*bc; run;

	proc freq data=a;
	tables 

/*creating dataset and plotting in SAS;
proc freq data=a;
	tables doc*rscrage / nofreq nopercent norow;
	ods output CrossTabFreqs=docage;
	run;
data docage; set docage;
	docp = doc/100;
	run;
	proc print data=docage; run;
proc sgplot data=docage;
	vbar rscrage / response = ColPercent;
	where doc = 1;
	run;*/

	*creating dataset and plotting in SAS, using weight, stratum, and panel vars;
	proc surveyfreq data=a;
	tables doc*rscrage / nofreq nopercent norow;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	ods output CrossTabFreqs=docage;
	run;
	data docage; set docage;
		docp = doc/100;
		run;
		proc print data=docage; run;
	proc sgplot data=docage;
		vbar rscrage / response = ColPercent;
		where doc = 1;
		run;

title 'just bivariate using logistic reg, no spline';
proc logistic data=a;
	class doc (ref="requires doctor or pharmacist");
	weight weightvar;
	model doc = rscrage;
	effectplot;
	run;

ods trace off;

*bivariate with splines;
title 'doc = age';
proc surveylogistic data=a;
	class
		doc (ref="does not require doctor or pharmacist");
	weight weightvar;
	effect spl=spline(rscrage / details naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5));
	model doc = spl;
	estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
	estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
	estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	output out=doc pred=pred;
	ods output Estimates=eDocAge;
	ods output FitStatistics=fsDocAge;
	run;

	proc sgplot data=doc;
		scatter y=pred x=rscrage;
		run;
		
		proc print data=edocage; run;

		/*proc export data=Estimates
			dbms=xlsx
			outfile="U:\Dissertation\xls_graphs\Estimates.xlsx"
			replace;
			run;
		proc contents data=Estimates; run;
		proc print data=Estimates; run;*/

*first doing some stepwise work;
title 'doc = age + demographics';
proc surveylogistic data=a;
	class 
		doc (ref="does not require doctor or pharmacist")
		edu (ref="hs degree or ged")
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
		povlev (ref="100-199% PL");
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl 
		edu
		hisprace2
		povlev;
	estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
	estimate '28 vs 25' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	ods output Estimates=edoc_age_dem;
	ods output FitStatistics=fs_doc_age_dem;
	ods output OddsRatios=OR_doc_age_dem;
	run;


	****** ADDING VARIABLES INDIVIDUALLY ON PAUL'S RECOMMENDATION, JUST FOR
	PROBING SO I REMOVED SOME OF THE ESTIMATE LEVELS;

	%let parity = edu hisprace2 povlev parity;
	%let mard = edu hisprace2 povlev mard;
	%let canhaver = edu hisprace2 povlev agebabycat;
	%let rwant = edu hisprace2 povlev rwant;
	%let agebabycat = edu hisprace2 povlev agebabycat;

	title 'allr = age + demographics + parity';
	proc surveylogistic data=a;
		class doc (ref=first) edu (ref="hs degree or ged") 
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
		canhaver (ref="NO") agebabycat parity (ref="0 BABIES") rwant (ref="YES")
		mard (ref="never been married");
		weight weightvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model doc = spl &parity;
		estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
		estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
		estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
		estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
		estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
		ods output Estimates=estallr_age_dem_par;
		ods output FitStatistics=fsallr_age_dem_par;
		ods output OddsRatios=ORallr_age_dem_par;
		run;

	title 'allr = age + demographics + mard';
	proc surveylogistic data=a;
		class doc (ref=first) edu (ref="hs degree or ged") 
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
		agebabycat parity (ref="0 BABIES") rwant (ref="YES")
		mard (ref="never been married");
		weight weightvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model doc = spl &mard;
		estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
		estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
		estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
		estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
		estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
		ods output Estimates=estallr_age_dem_mard;
		ods output FitStatistics=fsallr_age_dem_mard;
		ods output OddsRatios=ORallr_age_dem_mard;
		run;

	title 'allr = age + demographics + canhaver';
	proc surveylogistic data=a;
		class doc (ref=first) edu (ref="hs degree or ged") 
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
		canhaver (ref="NO") agebabycat parity (ref="0 BABIES") rwant (ref="YES")
		mard (ref="never been married");
		weight weightvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model doc = spl &canhaver;
		estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
		estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
		estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
		estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
		estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
		ods output Estimates=estallr_age_dem_canhaver;
		ods output FitStatistics=fsallr_age_dem_canhaver;
		ods output OddsRatios=ORallr_age_dem_canhaver;
		run;

	title 'allr = age + demographics + rwant';
	proc surveylogistic data=a;
		class doc (ref=first) edu (ref="hs degree or ged") 
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
		agebabycat parity (ref="0 BABIES") rwant (ref=first)
		mard (ref="never been married");
		weight weightvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model doc = spl &rwant;
		estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
		estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
		estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
		estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
		estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
		ods output Estimates=estallr_age_dem_rwant;
		ods output FitStatistics=fsallr_age_dem_rwant;
		ods output OddsRatios=ORallr_age_dem_rwant;
		run;

	title 'allr = age + demographics + agebabycat';
	proc surveylogistic data=a;
		class doc (ref=first) edu (ref="hs degree or ged") 
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
		agebabycat parity (ref="0 BABIES") rwant (ref=first)
		mard (ref="never been married");
		weight weightvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model doc = spl &agebabycat;
		estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
		estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
		estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
		estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
		estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
		ods output Estimates=estallr_age_dem_agebabycat;
		ods output FitStatistics=fsallr_age_dem_agebabycat;
		ods output OddsRatios=ORallr_age_dem_agebabycat;
		run;

		*Graphing estimates for the addition of individual variables;
		title;

		%let datasets1 = Edoc_age_dem Estallr_age_dem_agebabycat 
		Estallr_age_dem_canhaver Estallr_age_dem_mard Estallr_age_dem_par 
		Estallr_age_dem_rwant;

		*change output datasets so the data labels fit;
		%macro rounding1;
		%let i=1;
		%do %until(not %length(%scan(&datasets1,&i)));
		data %scan(&datasets1,&i); set %scan(&datasets1,&i);
			ORR=round(ExpEstimate,.001);
			LCLR=round(LowerExp,.001);
			UCLR=round(UpperExp,.001);
			title %scan(&datasets1,&i);
			run;
		%let i=%eval(&i+1);
		%end;
		%mend;

		%rounding1;

		%macro ditto;
		%let i=1;
		%do %until(not %length(%scan(&datasets1,&i)));
		proc sgplot data=%scan(&datasets1,&i);
			vbarparm category=Label response=ORR /
			datalabel=ORR datalabelpos=data
			baseline=1 groupdisplay=cluster
			limitlower=LCLR limitupper=UCLR;
			xaxis label="Age";
			yaxis label="Odds Ratio"
			type=log logbase=e;
			title1 "Coupled vs Uncoupled";
			title2 %scan(&datasets1,&i);
			run;
		%let i=%eval(&i+1);
		%end;
		%mend ditto;

		%ditto;


title 'doc = age + demographics + relationship & fertility';
proc surveylogistic data=a;
	class doc (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref=first)
	mard (ref="never been married");
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl 
		edu
		hisprace2
		povlev
		agebabycat
		parity		
		rwant
		mard;
	estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
	estimate '28 vs 25' spl [1,28] [-1,25] / exp cl;
	estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	ods output Estimates=edoc_age_dem_fert;
	ods output FitStatistics=fsdoc_age_dem_fert;
	ods output OddsRatios=ordoc_age_dem_fert;
	run;

title 'doc = all vars of interest, no interaction';
proc surveylogistic data=a;
	class doc (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref=first)
	mard (ref="never been married") curr_ins;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl 
  		edu hisprace2 povlev agebabycat parity rwant mard curr_ins;
	estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
	estimate '28 vs 25' spl [1,28] [-1,25] / exp cl;
	estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	ods output Estimates=edoc_all_noint;
	ods output FitStatistics=fsdoc_all_noint;
	ods output OddsRatios=ordoc_all_noint;
	run;

	*trying to figure out levels of variables so i can estimate the interaction
	terms;
	ods trace on;
	proc freq data=a; tables hisprace2 edu agebabycat;
	ods output onewayfreqs=dem; run;
	proc print data=dem; run;
	proc export data=dem
			dbms=xlsx
			outfile="U:\Dissertation\xls_graphs\dem.xlsx"
			replace;
			run;

title 'doc = all vars of interest, includes interaction';
proc surveylogistic data=a;
	class doc (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref=first)
	mard (ref="never been married") curr_ins;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl 
		edu hisprace2 povlev agebabycat parity rwant mard curr_ins
		hisprace2*agebabycat edu*agebabycat hisprace2*edu;
	estimate '23 vs 25' spl [1,23] [-1,25] / e exp cl;
	estimate '28 vs 25' spl [1,28] [-1,25] / exp cl;
	estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	ods output Estimates=e_int;
	ods output FitStatistics=fs_int;
	ods output OddsRatios=or_int;
	ods output ModelANOVA=joint_int;
	run;

	proc export data=joint_int outfile="U:\Dissertation\xls_graphs\joint_int.xlsx" dbms=xlsx;
	run;

proc print data=fs_int; run;

title 'doc = all vars of interest, includes interaction & interaction with age';
proc surveylogistic data=a;
	class doc (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref=first)
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl 
		edu hisprace2 povlev agebabycat parity rwant mard curr_ins 
		edu*spl hisprace2*spl hisprace2*agebabycat edu*agebabycat hisprace2*edu;
	estimate '23 vs 25' spl [1,23] [-1,25] / e exp cl;
	estimate '28 vs 25' spl [1,28] [-1,25] / exp cl;
	estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,44] [-1,25] / exp cl;
	ods output Estimates=e_int3;
	ods output FitStatistics=fs_int3;
	ods output OddsRatios=or_int3;
	ods output ModelANOVA=joint_int3;
	run;

		proc print data=coef_int3; run;
		proc print data=class_int3; run;

*Doing log likelihood ratio test for the three levels - full model without interaction,
full model with interaction of covariates, and full model with interaction of splines and 
covariates;

proc print data=coef_int; run;
proc print data=fsdoc_all_noint; run;
proc print data=fs_int; run;
proc print data=fs_int3; run;
proc print data=coef_int3; run;

*using the values from the print procedures above, i calculated the log likelihood ratio test
in excel - "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\doc_logliketest.xlsx"
and am using some guidance from sas help to calculate here 
(from http://support.sas.com/kb/24/474.html);

data lrt_pval;
	lrt1 = 6098554;
	df1 = 63;
	p_value1 = 1-probchi(LRT1,df1);
	lrt2 = 7480758;
	df2 = 32;
	p_value2 = 1-probchi(LRT2,df2);
	format p_value1 7.6 p_value2 7.6;
	run;

proc print data=lrt_pval;
	title1 "Likelihood ratio test statistic and p-value";
	run;

	proc freq data=a; tables rwant; run;

	*Checking age by fertility interactions;
		%macro stratified1;
		%do i=1 %to 9;
	proc surveylogistic data=a;
		class agecat (ref=first) edu (ref="hs degree or ged") 
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
		agebabycat parity (ref="1 BABY") rwant (ref=first)
		mard (ref="never been married") curr_ins / param=ref;
		weight weightvar;
		model doc = edu hisprace2 povlev agebabycat parity rwant mard;
		where agecat = &i.;
		ods output OddsRatios=or_1strat&i.;
		run;
		%end;
		%mend stratified1;
		%stratified1;

		%let oddsratiostwo = or_1strat2 or_1strat3 or_1strat4
		or_1strat5 or_1strat6;
		%macro orworksheetsstrat;
		%let i=1;
		%do %until(not %length(%scan(&oddsratiostwo,&i)));
		proc export data=%scan(&oddsratiostwo,&i)
			outfile="U:\Dissertation\xls_graphs\ORsStrat2.xlsx"
			dbms=xlsx
			replace;
			sheet="%scan(&oddsratiostwo,&i)";
			run;
			%let i=%eval(&i+1);
			%end;
			%mend orworksheetsstrat;

			%orworksheetsstrat;

proc print data=or_1strat2; run;

data or_1strat2; set or_1strat2;
	rename OddsRatioEst = OR2 LowerCL = LCL2 UpperCL = UCL2;
	run;

%macro strat;
%do i=3 %to 6;
data or_1strat&i.; set or_1strat&i.;
	rename OddsRatioEst = OR&i. LowerCL = LCL&i. UpperCL = UCL&i.;
	run;
	%end;
	%mend strat;

	%strat;
	
%macro sort;
%do i=2 %to 6;
proc sort data=or_1strat&i.; by Effect; run;
%end; %mend sort; %sort;

data doc_strat;
   merge &oddsratiostwo;
   by Effect;
run;

proc export data=doc_strat
	outfile = "U:\Dissertation\xls_graphs\doc_strat"
	dbms = xlsx
	replace;
	run;


	************
	* I WENT BACK AND REMOVED CANHAVER AFTER THIS INVESTIGATION:
	************;

	/*output says over 6000 observations were deleted due to missing values, which is
		way too high. exploring here;
	proc freq data=a; tables edu hisprace2 povlev canhaver agebabycat parity rwant 
	mard curr_ins; run;
	*the problem is canhaver, investigating;
	proc freq data=a; tables posiblpg*canhaver; run;
	proc freq data=a; tables posiblpg*ster; run;
	proc freq data=a; tables canhaver*ster; run;
	proc freq data=a; tables canhaver*bc / missing; run;
	*ok, both vars incorporate responses about sterilizing procedures into the 
	development of the variable. it won't work to include them;
	*/

		/*proc export data=class_int3
		outfile="U:\Dissertation\xls_graphs\class_int3.xlsx"
		dbms=xlsx
		replace;
		run;*/			

*********** ESTIMATE STATEMENTS IN EARNEST;

proc freq data=a; tables agecat*parity; run;
proc freq data=a; tables agecat*agebabycat; weight weightvar; run;

title1 'doc = all vars of interest, includes interaction & interaction with age';
title2 'estimate statements for race';
proc surveylogistic data=a;
	class doc (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref=first)
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl 
		edu hisprace2 povlev agebabycat parity rwant mard curr_ins 
		edu*spl hisprace2*spl hisprace2*agebabycat edu*agebabycat hisprace2*edu;
	estimate 'NHB vs NHW, bachelors, kid in late 20s' spl 40 hisprace2*spl [1,2 40] [-1,4 40]
		hisprace2*agebabycat [1,2 3] [-1,4 3] hisprace2*edu [1,2 2] [1,4 2]/ exp cl;
	estimate 'Hisp vs NHW, bachelors, kid in late 20s' spl 40 hisprace2*spl [1,1 40] [-1,4 40]
		hisprace2*agebabycat [1,1 3] [-1,4 3] hisprace2*edu [1,1 2] [1,4 2]/ exp cl;
	estimate 'NHO vs NHW, bachelors, kid in late 20s' spl 40 hisprace2*spl [1,3 40] [-1,4 40]
		hisprace2*agebabycat [1,3 3] [-1,4 3] hisprace2*edu [1,3 2] [1,4 2]/ exp cl;
	ods output Estimates=e_intrace;
	ods output FitStatistics=fs_intrace;
	ods output OddsRatios=or_intrace;
	ods output coef=coef_intrace;
	ods output classlevelinfo=class_intrace;
	run;
*estimates are a little wild and confidence intervals are extreme;
proc freq data=a; tables doc*agecat; where hisprace2=1 and edu=5 and agebabycat=3; run; 
*that is terrible;

	*looking at distributions here;
	title 'age at first birth for Hisp, respondents 35+';
	proc sgplot data=a;
		histogram agefirstbirth_all;
		where hisprace2=1;
		run;

	title 'age at first birth for NHB respondents 35+';
	proc sgplot data=a;
		histogram agefirstbirth_all;
		where hisprace2=3 and rscrage>34;
		run;

	title 'age at first birth for NHO respondents 35+';
	proc sgplot data=a;
		histogram agefirstbirth_all;
		where hisprace2=4 and rscrage>34;
		run;

	title 'age at first birth for NHW respondents 35+';
	proc sgplot data=a;
		histogram agefirstbirth_all;
		where hisprace2=2 and rscrage>34;
		run;

	*these differences in distribution could be a problem, it appears very few Hispanic women
	have a first birth in their late 20s and bachelors degrees;

ods trace off;

proc freq data=a; tables doc*agecat; where hisprace2=1 and edu=5 and agebabycat=3; run; 

*so let's start with less education and earlier kid-having;

title1 'doc = all vars of interest, includes interaction & interaction with age';
title2 'estimate statements for race, HS degree, kid in early 20s';
proc surveylogistic data=a;
	class doc (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref=first)
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl 
		edu hisprace2 povlev agebabycat parity rwant mard curr_ins 
		edu*spl hisprace2*spl hisprace2*agebabycat edu*agebabycat hisprace2*edu;
	estimate 'NHB vs NHW, HS degree, kid in early 20s' spl 40 hisprace2*spl [1,2 40] [-1,4 40]
		hisprace2*agebabycat [1,2 2] [-1,4 2] hisprace2*edu [1,2 4] [1,4 4]/ exp cl;
	estimate 'Hisp vs NHW, HS degree, kid in early 20s' spl 40 hisprace2*spl [1,1 40] [-1,4 40]
		hisprace2*agebabycat [1,1 2] [-1,4 2] hisprace2*edu [1,1 4] [1,4 4]/ exp cl;
	estimate 'NHO vs NHW, HS degree, kid in early 20s' spl 40 hisprace2*spl [1,3 40] [-1,4 40]
		hisprace2*agebabycat [1,3 2] [-1,4 2] hisprace2*edu [1,3 4] [1,4 4]/ exp cl;
	ods output Estimates=e_intrace_low;
	ods output FitStatistics=fs_intrace_low;
	ods output OddsRatios=or_intrace_low;
	ods output classlevelinfo=class_intrace_low;
	run;
*these are also terrible;
title 'NHB, HS, kid in early 20s';
proc freq data=a; tables doc*aged; where hisprace2=3 and edu=2 and agebabycat=2; run;
title 'NHW, HS, kid in early 20s';
proc freq data=a; tables doc*aged; where hisprace2=2 and edu=2 and agebabycat=2; run;

		data e_int2; set e_int2;
			ORR=round(ExpEstimate,.001);
			LCLR=round(LowerExp,.001);
			UCLR=round(UpperExp,.001);
			run;

		proc sgplot data=e_int2;
			vbarparm category=Label response=ORR /
			datalabel=ORR datalabelpos=data
			baseline=1 groupdisplay=cluster
			limitlower=LCLR limitupper=UCLR;
			xaxis label="Age";
			yaxis label="Odds Ratio"
			type=log logbase=e;
			title1 "With interaction";
			run;

	*creating a macro variable to work on output datasets;
	%let datasets = edocage edoc_age_dem_fert edoc_all_noint e_int e_int2 e_int3;

	title;
	*need to change the output datasets for the estimates
	so the data labels fit;
	%macro rounding;
	%let i=1;
	%do %until(not %length(%scan(&datasets,&i)));
	data %scan(&datasets,&i); set %scan(&datasets,&i);
		ORR=round(ExpEstimate,.001);
		LCLR=round(LowerExp,.001);
		UCLR=round(UpperExp,.001);
		title %scan(&datasets,&i);
		run;
	%let i=%eval(&i+1);
	%end;
	%mend;

	%rounding;

	*Running sgplot for every Regression model;

		/*used this code to create the macro;
		proc sgplot data=Estimatesallr_age;
			vbarparm category=Label response=ORR /
			datalabel=ORR datalabelpos=data
			baseline=1 groupdisplay=cluster
			limitlower=LCLR limitupper=UCLR;
			xaxis label="Age";
			yaxis label="Odds Ratio"
			type=log logbase=e;
			title1 "Coupled vs Uncoupled";
			run;*/

		%macro ditto;
		%let i=1;
		%do %until(not %length(%scan(&datasets,&i)));
		proc sgplot data=%scan(&datasets,&i);
			vbarparm category=Label response=ORR /
			datalabel=ORR datalabelpos=data
			baseline=1 groupdisplay=cluster
			limitlower=LCLR limitupper=UCLR;
			xaxis label="Age";
			yaxis label="Odds Ratio"
			type=log logbase=e;
			title1 "Requires HC Provider vs Doesn't";
			title2 %scan(&datasets,&i);
			run;
		%let i=%eval(&i+1);
		%end;
		%mend ditto;

		%ditto;

	*exporting Estimates output to excel;

	%macro remove;
	%let i=1;
	%do %until(not %length(%scan(&datasets,&i)));
	data %scan(&datasets,&i); set %scan(&datasets,&i);
		Odds_Ratio = ORR;
		Lower_CL = LCLR;
		Upper_CL = UCLR;
		keep
			Label
			Odds_Ratio
			Lower_CL
			Upper_CL;
		run;
		%let i=%eval(&i+1);
		%end;
		%mend remove;

		%remove;

		proc print data=Estimatesallr_age_dem; run;

	*now exporting to one spreadsheet with several
		worksheets;

	/*used this code to create macro;
	proc export data=Estimatesallr_age_dem
		outfile="U:\Dissertation\xls_graphs\EstimatesLevel1.xlsx"
		dbms=xlsx
		replace;
		sheet="allr_age_dem";
		run;

	*/

	%macro worksheets;
	%let i=1;
	%do %until(not %length(%scan(&datasets,&i)));
	proc export data=%scan(&datasets,&i)
		outfile="U:\Dissertation\xls_graphs\EstimatesLevel1.xlsx"
		dbms=xlsx
		replace;
		sheet="%scan(&datasets,&i)";
		run;
		%let i=%eval(&i+1);
		%end;
		%mend worksheets;

		%worksheets;

	*exporting odds ratios output to excel;

	/*used this code to write macro;
		proc export data=orallr_age_dem
		outfile="U:\Dissertation\xls_graphs\OddsRatios1.xlsx"
		dbms=xlsx
		replace;
		sheet="orallr_age_dem";
		run;*/

*************
****** INTERACTIONS BETWEEN FERTILITY VARIABLES AND AGE
*************;

title 'doc = all vars of interest, includes dem interaction and age x fert';
proc surveylogistic data=a;
	class doc (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl 
		edu hisprace2 povlev agebabycat parity rwant mard curr_ins 
		hisprace2*spl edu*spl
		parity*spl rwant*spl
		hisprace2*agebabycat edu*agebabycat;
	estimate '23 vs 25' spl [1,23] [-1,25] / exp cl;
	estimate '28 vs 25' spl [1,28] [-1,25] / exp cl;
	estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,44] [-1,25] / exp cl;
	ods output Estimates=e_fertxspl;
	ods output FitStatistics=fs_fertxspl;
	ods output OddsRatios=or_fertxspl;
	ods output ModelANOVA=jt_fertxspl;
	run;

	proc export data=jt_fertxspl 
	outfile="U:\Dissertation\xls_graphs\jt_fertxspl.xlsx"
	dbms=xlsx;
	run;

	title;

	data e_fertxspl; set e_fertxspl;
		ORR=round(ExpEstimate,.001);
		LCLR=round(LowerExp,.001);
		UCLR=round(UpperExp,.001);
		title 'fert x spl';
		run;

	proc sgplot data=e_fertxspl;
		vbarparm category=Label response=ORR /
		datalabel=ORR datalabelpos=data
		baseline=1 groupdisplay=cluster
		limitlower=LCLR limitupper=UCLR;
		xaxis label="Age";
		yaxis label="Odds Ratio"
		type=log logbase=e;
		title1 "Requires HC Provider vs Doesn't";
		title2 "fertility and age interactions";
		run;

title 'doc, final model with estimate statements';
proc surveylogistic data=a;
	class doc (ref=first) edu (ref="hs degree or ged") 
	hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") povlev (ref="100-199% PL") 
	agebabycat parity (ref="1 BABY") rwant (ref="YES")
	mard (ref="never been married") curr_ins / param=ref;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl 
		edu hisprace2 povlev agebabycat parity rwant mard curr_ins rwant*spl
		hisprace2*agebabycat edu*agebabycat;
	estimate '35 vs 30, wants kids' spl [1,35] [-1,30]
	rwant*spl [1,3 35] [-1,3 30] / exp cl;
	estimate '40 vs 30, wants kids' spl [1,40] [-1,30]
	rwant*spl [1,3 40] [-1,3 30] / exp cl;
	estimate '44 vs 30, wants kids' spl [1,44] [-1,30]
	rwant*spl [1,3 44] [-1,3 30] / exp cl;
	run;

	proc print data=coef_all; run;

	/*quickly checking for significant interactions, using macros from other programs;

	proc surveylogistic data=a;
		class &class / param=ref;
		weight weightvar;
		strata stratvar;
		cluster panelvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model doc = spl &confounders spl*edud spl*hisprace2 spl*pov spl*parityd;
		run;*/


** Running a few descriptives here to confirm which interactions I want to use;
	proc sort data=a; by edud; run;
	proc freq data=a; tables bcc*agecat; by edud; run;
	proc surveylogistic data=a;
	class tub(ref=first) / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model tub = spl;
	output out=tub pred=pred;
	run;

	proc contents data=tub; run;

	proc sgplot data=tub;
	scatter y=pred x=rscrage;
	by edud;
	run;

	*going to try another multinomial model just to see;
	proc surveylogistic data=a;
	class &class / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model bcc = &confounders spl*agebabycat spl*edud spl*pov spl*hisprace2 spl*parity;
	run;

	proc freq data=a; tables agecat*agebabycat; run;

proc surveylogistic data=a;
	class doc;
	model doc=rscrage; run;

*Final model with main effects only;

%macro main;
%do x=23 %to 43 %by 1;
	"&x" intercept 1 spl [1,&x],
	%end;
	"44, 15-19 vs >24/0" intercept 1 spl [0,44]
	%mend;


proc surveylogistic data=a;
	class doc edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins;
	estimate %main / exp cl;
	ods output Estimates=e3;
	run;

data e_main; set e3;
	drop estimate stderr df tvalue alpha lower upper;
	Label2=Label;
	run;

title1 "Use of Contraceptives That Do Not Require a Healthcare Provider";
title2 "By Age";
proc sgplot data=e_main;
	band x=Label2 lower=LowerExp upper=UpperExp /
	transparency=.5;
	series x=Label2 y=ExpEstimate / datalabel=ExpEstimate
	/*groupdisplay=overlay*/;
	refline 1 / axis=y label="OR=1.0";
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e logstyle=linear values=(0.1 0.5 1 2 3 5);
	run;


*****************************************
*** FINAL MODEL WITH INTERACTION, ORs ***
*****************************************;

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
	class doc edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	output out=doc pred=pred1;
	estimate %teen / exp cl;
	estimate %earlytwenties / exp cl;
	ods output Estimates=e2;
	run;

		/*proc sgplot data=doc;
			scatter y=pred x=rscrage;
			run;

		proc print data=doc (obs=20);
			where doc=1;
			var pred1 caseid rscrage doc;
			run;*/
			

data e_doc; set e2;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	ORR=round(ExpEstimate,.01);
	LCLR=round(LowerExp,.01);
	UCLR=round(UpperExp,.01);
	Label2=substr(Label,1,2);
	run;

title1 "Use of Contraceptives That Do Not Require a Healthcare Provider";
title2 "By Age & Age at First Birth";
proc sgplot data=e_doc;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=ORR / group=earlybirth datalabel=ORR
	/*groupdisplay=overlay*/;
	refline 1 / axis=y label="OR=1.0";
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e logstyle=linear values=(0.1 0.5 1 2 3 5);
	run;

*Fill attributes:
https://documentation.sas.com/?docsetId=grstatproc&docsetTarget=p1jzx3nmuupe74n1qy54onbwjoem.htm&docsetVersion=9.4&locale=en;

*********
** 	Running the above model with sterilization users removed to assess the impact of sterilizations in
	the comparison group on variation by age.
*********;

*Removes sterilization users - ;

data a; set a;
	if bc = 1 then doc = .;
	if bc = 2 then doc = .;
	run;

proc surveylogistic data=a;
	class doc edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl;
	estimate %earlytwenties / exp cl;
	ods output Estimates=e_docnoster;
	run;

data e_docnoster; set e_docnoster;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	ORR=round(ExpEstimate,.01);
	LCLR=round(LowerExp,.01);
	UCLR=round(UpperExp,.01);
	Label2=substr(Label,1,2);
	run;

title1 "Use of Contraceptives That Do Not Require a Healthcare Provider";
title2 "By Age & Age at First Birth";
title3 "Sterilized Individuals Removed";
proc sgplot data=e_docnoster;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=ORR / group=earlybirth datalabel=ORR
	/*groupdisplay=overlay*/;
	refline 1 / axis=y label="OR=1.0";
	xaxis label="Age";
	yaxis label="Odds Ratio"
	type=log logbase=e logstyle=linear values=(0.1 0.5 1 2 3 5);
	run;

*Wowza, that changes things considerably;


*********************
*** PROBABILITIES ***
********************;

***************************************************
*** FINAL MODEL WITH INTERACTION, PROBABILITIES ***
***************************************************;

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
	class doc edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	output out=doc pred=pred1;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e2;
	run;

		/*proc sgplot data=doc;
			scatter y=pred x=rscrage;
			run;

		proc print data=doc (obs=20);
			where doc=1;
			var pred1 caseid rscrage doc;
			run;*/
		
		proc print data=e2; run;	

data e_doc; set e2;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	if stmtno=3 then earlybirth = ">24/0";
	PROBR=round(mu,.01);
	LCLR=round(lowermu,.01);
	UCLR=round(uppermu,.01);
	Label2=substr(Label,1,2);
	run;

/*title1 "Use of Contraceptives That Do Not Require a Healthcare Provider";
title2 "By Age & Age at First Birth";*/
	title;
proc sgplot data=e_doc;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Probability"
	/*type=log logbase=e logstyle=linear*/ values=(0 0.1 0.2 0.3 0.4 0.5);
	run;

*Fill attributes:
https://documentation.sas.com/?docsetId=grstatproc&docsetTarget=p1jzx3nmuupe74n1qy54onbwjoem.htm&docsetVersion=9.4&locale=en;

*********
** 	Running the above model with sterilization users removed to assess the impact of sterilizations in
	the comparison group on variation by age.
*********;

*Removes sterilization users - ;

data a; set a;
	if bc = 1 then doc = .;
	if bc = 2 then doc = .;
	run;

proc surveylogistic data=a;
	class doc edud(ref="hs degree or ged") 
	earlybirth (ref=">24 or no live births") hisprace2(ref="NON-HISPANIC WHITE, SINGLE RACE") pov(ref="<=138%") 
	parityd(ref="0") rwant(ref="YES")
	mard(ref="never been married") curr_ins / param=ref;
	weight weightvar;
	strata stratvar;
	cluster panelvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model doc = spl edud earlybirth hisprace2 pov parityd rwant mard
	curr_ins spl*earlybirth;
	estimate %teen / exp cl ilink;
	estimate %earlytwenties / exp cl ilink;
	estimate %laterbirth / exp cl ilink;
	ods output Estimates=e_docnoster;
	run;

data e_docnoster; set e_docnoster;
	drop estimate stderr df tvalue alpha lower upper;
	if stmtno=1 then earlybirth = "15-19";
	if stmtno=2 then earlybirth = "20-24";
	if stmtno=3 then earlybirth = ">24/0";
	PROBR=round(mu,.0001);
	LCLR=round(lowermu,.0001);
	UCLR=round(uppermu,.0001);
	Label2=substr(Label,1,2);
	run;

/*title1 "Use of Contraceptives That Do Not Require a Healthcare Provider";
title2 "By Age & Age at First Birth";
title3 "Sterilized Individuals Removed";*/
	title;
proc sgplot data=e_docnoster;
	band x=Label2 lower=LCLR upper=UCLR / group=earlybirth 
	transparency=.5;
	series x=Label2 y=probr / group=earlybirth datalabel=probr
	/*groupdisplay=overlay*/;
	/*refline 1 / axis=y label="OR=1.0";*/
	xaxis label="Age";
	yaxis label="Probability"
	/*type=log logbase=e logstyle=linear*/ values=(0 0.1 0.2 0.3 0.4 0.5);
	run;

*Wowza, that changes things considerably;
