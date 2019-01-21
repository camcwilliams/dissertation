*############################################*
*######### McWilliams Dissertation ##########*
*##### Aim 1 Logistic Regression Models #####*
*############################################*;


libname library "U:\Dissertation";
%include "U:\Dissertation\nsfg_CMcWFormats.sas";
data a; set library.nsfg; run;

*******************
* LEVEL 1: HCP REQUIRED VS NOT;
*******************;

*Turning on ODS trace and setting up so charts get saved;

ods trace on;
ods graphics on / reset=index imagename="allr_age";
ods listing gpath = "U:\Dissertation\sas_graphs";

proc freq data=a; tables bc; ods output onewayfreqs=bcfreq; run;
proc print data=bcfreq; format bc 3.1; run;

*DESCRIPTIVES FOR HCP REQUIRED VS NOT;
proc freq data=a;
	tables doc;
	ods output OneWayFreqs=docfreq1;
	run;

	*formatting to make the frequency datasets nicer;
	data docfreq1; set docfreq1;
		drop f_doc;
		rename doc = Doc;
		run;

	proc print data=docfreq1; run;

	/*proc export data=allrfreq
	dbms=xlsx
	outfile="U:\Dissertation\xls_graphs\allrfreq.xlsx"
	replace;
	run;*/

*plotting the relationship between outcome and age, no adjustment;
title 'simple relationship between outcome and age';

*creating dataset and plotting in SAS;
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
	run;

* Removing respondents younger than 23;
data a; set a;
	if rscrage < 23 then delete;
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

	*adding levels here on Paul's recommendation - just for probing so reducing
	number of estimate levels;

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
		canhaver (ref="NO") agebabycat parity (ref="0 BABIES") rwant (ref="YES")
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
		canhaver (ref="NO") agebabycat parity (ref="0 BABIES") rwant (ref=first)
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
		canhaver (ref="NO") agebabycat parity (ref="0 BABIES") rwant (ref=first)
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

title 'allr = age + demographics + relationship & fertility';
proc surveylogistic data=a;
	class 
		allr (ref="during: barrier, withdrawal, nothing")
		edu (ref="hs degree or ged")
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
		povlev (ref="100-199% PL")
		canhaver (ref="NO")
		agebabycat
		parity (ref="0 BABIES")		
		rwant (ref="NO")
		mard (ref="never been married");
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model allr = spl 
		edu
		hisprace2
		povlev
		canhaver
		agebabycat
		parity		
		rwant
		mard;
	estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
	estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
	estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	ods output Estimates=estallr_age_dem_fert;
	ods output FitStatistics=fsallr_age_dem_fert;
	ods output OddsRatios=ORallr_age_dem_fert;
	run;

title 'allr = all vars of interest, no interaction';
proc surveylogistic data=a;
	class 
		allr (ref="during: barrier, withdrawal, nothing")
		edu (ref="hs degree or ged")
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
		povlev (ref="100-199% PL")
		canhaver (ref="NO")
		agebabycat
		parity (ref="0 BABIES")		
		rwant (ref="NO")
		mard (ref="never been married")
		curr_ins
		religion (ref="NO RELIGION");
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model allr = spl 
		edu
		hisprace2
		povlev
		canhaver
		agebabycat
		parity		
		rwant
		curr_ins
		mard
		religion;
	estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
	estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
	estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	ods output Estimates=estallr_all_nointeraction;
	ods output FitStatistics=fsallr_all_nointeraction;
	ods output OddsRatios=ORallr_all_nointeraction;
	run;

title 'allr = all vars of interest, includes interaction';
proc surveylogistic data=a;
	class 
		allr (ref="during: barrier, withdrawal, nothing")
		edu (ref="hs degree or ged")
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
		povlev (ref="100-199% PL")
		canhaver (ref="NO")
		agebabycat
		parity (ref="0 BABIES")		
		rwant (ref="NO")
		mard (ref="never been married")
		curr_ins
		religion (ref="NO RELIGION");
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model allr = spl 
		edu
		hisprace2
		povlev
		canhaver
		agebabycat
		parity		
		rwant
		curr_ins
		mard
		religion
		hisprace2*agebabycat
		edu*agebabycat
		hisprace2*edu;
	estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
	estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
	estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	ods output Estimates=estallr_all_plusinteraction;
	ods output FitStatistics=fsallr_all_plusinteraction;
	ods output OddsRatios=ORallr_all_plusinteraction;
	run;

		* Comparing a couple of other models to the above full model;

		title 'allr = all vars of interest, includes interaction, 
		remove religion';
		proc surveylogistic data=a;
			class 
				allr (ref="during: barrier, withdrawal, nothing")
				edu (ref="hs degree or ged")
				hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
				povlev (ref="100-199% PL")
				canhaver (ref="NO")
				agebabycat
				parity (ref="0 BABIES")		
				rwant (ref="NO")
				mard (ref="never been married")
				curr_ins;
			weight weightvar;
			effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
										knotmethod=percentiles(5) details);
			model allr = spl 
				edu
				hisprace2
				povlev
				canhaver
				agebabycat
				parity		
				rwant
				curr_ins
				mard
				hisprace2*agebabycat
				edu*agebabycat
				hisprace2*edu;
			estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
			estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
			estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
			estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
			estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
			estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
			estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
			estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
			ods output Estimates=estallr_all_plusinteraction;
			ods output FitStatistics=fsallr_all_plusinteraction;
			ods output OddsRatios=ORallr_all_norel;
			run;

		proc freq data=a; tables parity; run;
		title 'allr = all vars of interest, includes interaction, 
		remove religion, change parity ref';
		proc surveylogistic data=a;
			class 
				allr (ref="during: barrier, withdrawal, nothing")
				edu (ref="hs degree or ged")
				hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
				povlev (ref="100-199% PL")
				canhaver (ref="NO")
				agebabycat
				parity (ref="1 BABY")		
				rwant (ref="NO")
				mard (ref="never been married")
				curr_ins;
			weight weightvar;
			effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
										knotmethod=percentiles(5) details);
			model allr = spl 
				edu
				hisprace2
				povlev
				canhaver
				agebabycat
				parity		
				rwant
				curr_ins
				mard
				hisprace2*agebabycat
				edu*agebabycat
				hisprace2*edu;
			estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
			estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
			estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
			estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
			estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
			estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
			estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
			estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
			ods output Estimates=estallr_all_plusinteraction;
			ods output FitStatistics=fsallr_all_plusinteraction;
			ods output OddsRatios=ORallr_all_norel_1baby;
			run;

		title 'allr = all vars of interest, includes interaction, 
		remove religion, change age at first birth ref';
		proc surveylogistic data=a;
			class 
				allr (ref="during: barrier, withdrawal, nothing")
				edu (ref="hs degree or ged")
				hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
				povlev (ref="100-199% PL")
				canhaver (ref="NO")
				agebabycat (ref="25-29")
				parity (ref="0 BABIES")		
				rwant (ref="NO")
				mard (ref="never been married")
				curr_ins;
			weight weightvar;
			effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
										knotmethod=percentiles(5) details);
			model allr = spl 
				edu
				hisprace2
				povlev
				canhaver
				agebabycat
				parity		
				rwant
				curr_ins
				mard
				hisprace2*agebabycat
				edu*agebabycat
				hisprace2*edu;
			estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
			estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
			estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
			estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
			estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
			estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
			estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
			estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
			ods output Estimates=estallr_all_plusinteraction;
			ods output FitStatistics=fsallr_all_plusinteraction;
			ods output OddsRatios=ORallr_all_norel_2529agebaby;
			run;

		title 'allr = all vars of interest, includes interaction, 
		remove religion, change parity and age at first birth refs';
		proc surveylogistic data=a;
			class 
				allr (ref="during: barrier, withdrawal, nothing")
				edu (ref="hs degree or ged")
				hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
				povlev (ref="100-199% PL")
				canhaver (ref="NO")
				agebabycat (ref="25-29")
				parity (ref="1 BABY")		
				rwant (ref="NO")
				mard (ref="never been married")
				curr_ins;
			weight weightvar;
			effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
										knotmethod=percentiles(5) details);
			model allr = spl 
				edu
				hisprace2
				povlev
				canhaver
				agebabycat
				parity		
				rwant
				curr_ins
				mard
				hisprace2*agebabycat
				edu*agebabycat
				hisprace2*edu;
			estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
			estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
			estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
			estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
			estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
			estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
			estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
			estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
			ods output Estimates=estallr_all_plusinteraction;
			ods output FitStatistics=fsallr_all_plusinteraction;
			ods output OddsRatios=ORallr_all_norel_changes;
			run;


		title 'allr = all vars of interest, includes interaction, 
		remove religion, change parity, age at first birth, rwant refs';
		proc surveylogistic data=a;
			class 
				allr (ref="during: barrier, withdrawal, nothing")
				edu (ref="hs degree or ged")
				hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
				povlev (ref="100-199% PL")
				canhaver (ref="NO")
				agebabycat (ref="25-29")
				parity (ref="1 BABY")		
				rwant (ref="YES")
				mard (ref="never been married")
				curr_ins;
			weight weightvar;
			effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
										knotmethod=percentiles(5) details);
			model allr = spl 
				edu
				hisprace2
				povlev
				canhaver
				agebabycat
				parity		
				rwant
				curr_ins
				mard
				hisprace2*agebabycat
				edu*agebabycat
				hisprace2*edu;
			estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
			estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
			estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
			estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
			estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
			estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
			estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
			estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
			ods output Estimates=estallr_all_plusinteraction;
			ods output FitStatistics=fsallr_all_plusinteraction;
			ods output OddsRatios=ORallr_all_norel_changesTWO;
			run;




	*creating a macro variable to work on output datasets;
	%let datasets =
	Estimatesallr_age
	Estimatesallr_age_dem
	Estallr_age_dem_fert
	Estallr_all_nointeraction
	Estallr_all_plusinteraction;

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

	proc contents data=Estallr_all_plusinteraction; run;

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
			title1 "Coupled vs Uncoupled";
			title2 %scan(&datasets,&i);
			run;
		%let i=%eval(&i+1);
		%end;
		%mend ditto;

		%ditto;

	*exporting Estimates output to excel;

	*checking;
	proc print data=Estimatesallr_age_dem; run;

	*first removing unnecessary variables;

	/*used this code to create macro;
	data Estimatesallr_age_dem; set Estimatesallr_age_dem;
		Odds_Ratio = ORR;
		Lower_CL = LCLR;
		Upper_CL = UCLR;
		keep
			Label
			Odds_Ratio
			Lower_CL
			Upper_CL;
		run;
	*/

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

%let oddsratios = 
	orallr_age_dem
	orallr_age_dem_fert
	orallr_all_nointeraction
	orallr_all_plusinteraction;

	%macro orworksheets;
	%let i=1;
	%do %until(not %length(%scan(&oddsratios,&i)));
	proc export data=%scan(&oddsratios,&i)
		outfile="U:\Dissertation\xls_graphs\ORsLevel1.xlsx"
		dbms=xlsx
		replace;
		sheet="%scan(&oddsratios,&i)";
		run;
		%let i=%eval(&i+1);
		%end;
		%mend orworksheets;

		%orworksheets;

		*Making another spreadsheet to look at how things changed;
		%let oddsratiostwo = 
		orallr_all_plusinteraction
		orallr_all_norel
		orallr_all_norel_1baby
		orallr_all_norel_2529agebaby;

		%macro orworksheetstwo;
		%let i=1;
		%do %until(not %length(%scan(&oddsratiostwo,&i)));
		proc export data=%scan(&oddsratiostwo,&i)
			outfile="U:\Dissertation\xls_graphs\ORsLevel1_2.xlsx"
			dbms=xlsx
			replace;
			sheet="%scan(&oddsratiostwo,&i)";
			run;
			%let i=%eval(&i+1);
			%end;
			%mend orworksheetstwo;

			%orworksheetstwo;

proc freq data=a; tables parity; run;
	*exporting fit statistics output to excel;

	proc print data=fitstatisticsallr_age; run;

	%let fits = 
		fitstatisticsallr_age
		fsallr_age_dem
		fsallr_age_dem_fert
		fsallr_all_nointeraction
		fsallr_all_plusinteraction;

	%macro fitworksheets;
	%let i=1;
	%do %until(not %length(%scan(&fits,&i)));
	proc export data=%scan(&fits,&i)
		outfile="U:\Dissertation\xls_graphs\FitLevel1.xlsx"
		dbms=xlsx
		replace;
		sheet="%scan(&fits,&i)";
		run;
		%let i=%eval(&i+1);
		%end;
		%mend fitworksheets;

		%fitworksheets;


	*#### LEVEL 2 ####; 

	*LONG-TERM VS SHORT-TERM (variable=BEFORE);

	proc freq data=a;
		tables before;
		run;

	proc logistic;
		class before (ref="short term methods: pill, patch/ring, NFP");
		weight weightvar;
		model before = rscrage;
		effectplot;
		run;

	proc sgplot data=a;
		vbar rscrage / response = before;
		run;

		*THIS IS FOR GRAPHING ONLY, NOTE NO WEIGHT STATEMENT;
		proc logistic data=a;
			class before (ref="short term methods: pill, patch/ring, NFP");
			effect spl=spline(rscrage / knotmethod=percentiles(5));
			model before = spl;
			output out=before p=pred xbeta=logodds;
			run;

		proc sgplot data=before;
			scatter y=pred x=rscrage;
			run;

		proc sgplot data=before;
			scatter y=logodds x=rscrage;
			run;

	proc surveylogistic data=a;
		class 
			before (ref="short term methods: pill, patch/ring, NFP")
			edu
			hisprace2
			povlev
			canhaver
			agebabycat
			parity		
			rwant
			curr_ins
			mard
			religion;
		weight weightvar;
		effect spl=spline(rscrage / knotmethod=percentiles(5));
		model before = spl 
			edu
			hisprace2
			povlev
			canhaver
			agebabycat
			parity		
			rwant
			curr_ins
			mard
			religion
			hisprace2*agebabycat
			edu*agebabycat
			hisprace2*edu;
		estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
		estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
		estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
		estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
		estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
		estimate '44 vs 25' spl [1,44] [-1,25] / exp cl;
		output out=before p=pred xbeta=logodds;
		run;


	* LEVEL 2: LONG-TERM VS SHORT-TERM (variable=BEFORE);

	proc freq data=a;
		tables before;
		run;

	proc logistic;
		class before (ref="short term methods: pill, patch/ring, NFP");
		weight weightvar;
		model before = rscrage;
		effectplot;
		run;

	proc sgplot data=a;
		vbar rscrage / response = before;
		run;

		*THIS IS FOR GRAPHING ONLY, NOTE NO WEIGHT STATEMENT;
		proc logistic data=a;
			class before (ref="short term methods: pill, patch/ring, NFP");
			effect spl=spline(rscrage / knotmethod=percentiles(5));
			model before = spl;
			output out=before p=pred xbeta=logodds;
			run;

		proc sgplot data=before;
			scatter y=pred x=rscrage;
			run;

		proc sgplot data=before;
			scatter y=logodds x=rscrage;
			run;

	proc surveylogistic data=a;
		class 
			before (ref="short term methods: pill, patch/ring, NFP")
			edu
			hisprace2
			povlev
			canhaver
			agebabycat
			parity		
			rwant
			curr_ins
			mard
			religion;
		weight weightvar;
		effect spl=spline(rscrage / knotmethod=percentiles(5));
		model before = spl 
			edu
			hisprace2
			povlev
			canhaver
			agebabycat
			parity		
			rwant
			curr_ins
			mard
			religion
			hisprace2*agebabycat
			edu*agebabycat
			hisprace2*edu;
		estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
		estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
		estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
		estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
		estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
		estimate '44 vs 25' spl [1,44] [-1,25] / exp cl;
		output out=before p=pred xbeta=logodds;
		run;


	* LEVEL 2: NEED TO BE PREPARED VS DON'T NEED TO BE PREPARED
	(variable=DURING);

	proc freq data=a;
		tables during;
		run;

	proc logistic;
		class during (ref="no prep needed: withdrawal, nothing");
		weight weightvar;
		model during = rscrage;
		effectplot;
		run;

	proc sgplot data=a;
		vbar rscrage / response = during;
		run;

		*THIS IS FOR GRAPHING ONLY, NOTE NO WEIGHT STATEMENT;
		proc logistic data=a;
			class during (ref=first);
			effect spl=spline(rscrage / knotmethod=percentiles(5));
			model during = spl;
			output out=during p=pred xbeta=logodds;
			run;

		proc sgplot data=during;
			scatter y=pred x=rscrage;
			run;

		proc sgplot data=during;
			scatter y=logodds x=rscrage;
			run;

	proc surveylogistic data=a;
		class 
			during (ref=first)
			edu
			hisprace2
			povlev
			canhaver
			agebabycat
			parity		
			rwant
			curr_ins
			mard
			religion;
		weight weightvar;
		effect spl=spline(rscrage / knotmethod=percentiles(5));
		model during = spl 
			edu
			hisprace2
			povlev
			canhaver
			agebabycat
			parity		
			rwant
			curr_ins
			mard
			religion
			hisprace2*agebabycat
			edu*agebabycat
			hisprace2*edu;
		estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
		estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
		estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
		estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
		estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
		estimate '44 vs 25' spl [1,44] [-1,25] / exp cl;
		output out=during p=pred xbeta=logodds;
		run;


		*#### LEVEL 3 ####; 

		* LEVEL 3: PERMANENT VS REVERSIBLE
		(variable=LONG);

		proc freq data=a;
			tables during;
			run;

		proc logistic;
			class during (ref="no prep needed: withdrawal, nothing");
			weight weightvar;
			model during = rscrage;
			effectplot;
			run;

		proc sgplot data=a;
			vbar rscrage / response = during;
			run;

			*THIS IS FOR GRAPHING ONLY, NOTE NO WEIGHT STATEMENT;
			proc logistic data=a;
				class during (ref=first);
				effect spl=spline(rscrage / knotmethod=percentiles(5));
				model during = spl;
				output out=during p=pred xbeta=logodds;
				run;

			proc sgplot data=during;
				scatter y=pred x=rscrage;
				run;

			proc sgplot data=during;
				scatter y=logodds x=rscrage;
				run;

		proc surveylogistic data=a;
			class 
				during (ref=first)
				edu
				hisprace2
				povlev
				canhaver
				agebabycat
				parity		
				rwant
				curr_ins
				mard
				religion;
			weight weightvar;
			effect spl=spline(rscrage / knotmethod=percentiles(5));
			model during = spl 
				edu
				hisprace2
				povlev
				canhaver
				agebabycat
				parity		
				rwant
				curr_ins
				mard
				religion
				hisprace2*agebabycat
				edu*agebabycat
				hisprace2*edu;
			estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
			estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
			estimate '30 vs 25' spl [1,30] [-1,25] / exp cl;
			estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
			estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
			estimate '44 vs 25' spl [1,44] [-1,25] / exp cl;
			output out=during p=pred xbeta=logodds;
			run;
