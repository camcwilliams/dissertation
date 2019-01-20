*#########################*
*##### DECISION TREE #####*
*#########################*;


libname library "U:\Dissertation";
%include "U:\Dissertation\nsfg_CMcWFormats.sas";
data a; set library.nsfg; run;

*******************
* LEVEL 1: COUPLED WITH INTERCOURSE VS NOT;
*******************;

ods trace on;
ods graphics on / reset=index imagename="allr_age";
ods listing gpath = "U:\Dissertation\sas_graphs";

*FREQUENCY FOR OUTCOME VARIABLE OF INTEREST,
COUPLED WITH SEX VS UNCOUPLED;
proc freq data=a;
	tables allr;
	ods output OneWayFreqs=allrfreq;
	run;
	data allrfreq; set allrfreq;
		rename 
			F_allr = formats
			allr = codes;
		run;

	proc print data=allrfreq; run;

	proc export data=allrfreq
	dbms=xlsx
	outfile="U:\Dissertation\xls_graphs\allrfreq.xlsx"
	replace;
	run;

*plotting the relationship between outcome and age, no adjustment;
title 'simple relationship between outcome and age';
ods graphics on;

proc freq data=a;
	tables allr*rscrage / nofreq nopercent norow;
	ods output CrossTabFreqs=allr_age;
	run;
data allr_age; set allr_age;
	allrp = allr/100;
	run;
	proc print data=allr_age; run;
proc sgplot data=allr_age;
	vbar rscrage / response = ColPercent;
	where allr = 1;
	run;

title 'just bivariate using logistic reg, no spline';
proc logistic data=a;
	class allr (ref="during: barrier, withdrawal, nothing");
	weight weightvar;
	model allr = rscrage;
	effectplot;
	run;

ods trace off;

	/*checking proc univariate to see if i want to use knots other than percentiles;
	proc univariate data=a;
		var rscrage;
		output out=percentiles1 pctlpts=5 27.5 50 72.5 95 pctlpre=P;
		run;

		proc print data=percentiles1; run;
		*the 5% and 95% will only include 1-2 years, I think it will be better to use percentiles;

	*in order for the bottom and top knots to be at the correct ages, 
		i think i need to use the knotmethod=list option. using proc univariate
		here to calculate those percentiles;
		proc univariate data=a;
			var rscrage;
			output out=percentiles2 pctlpts = 0 20 40 60 80 100 pctlpre=P;
			run;

		proc print data=percentiles2; run;*/

/*bivariate relationship between age splines and outcome, 
	FOR GRAPHING ONLY, NO WEIGHT STATEMENT;
title 'bivariate, age splines & outcome, NO WEIGHT STATEMENT';	
proc logistic data=a;
	class allr (ref="during: barrier, withdrawal, nothing");
	effect spl=spline(rscrage / details naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5));
	model allr = spl;
	output out=allr p=predprob_allr xbeta=logodds_allr;
	run;

	proc sgplot data=allr;
	scatter x=rscrage y=predprob_allr;
	run;*/

	/*graphing spline output to see shape;
	data allr; set allr;
		keep caseid predprob_allr logodds_allr &varlist allr;
		run;

	proc sgplot data=allr;
		scatter x=rscrage y=logodds_allr;
		run;
	*/

		/*quickly want to compare the natural cubic with listed knots to 
		percentile knots;
		*bivariate relationship between age splines and outcome, 
			FOR GRAPHING ONLY, NO WEIGHT STATEMENT;	
			proc logistic data=a;
				class allr (ref="during: barrier, withdrawal, nothing");
				effect spl=spline(rscrage / details naturalcubic basis=tpf(noint)
											knotmethod=percentiles(5));
				model allr = spl;
				output out=allr p=predprob_allr xbeta=logodds_allr;
				run;

			*graphing spline output to see shape;
			data allr; set allr;
				keep caseid predprob_allr logodds_allr &varlist allr;
				run;

			proc sgplot data=allr;
				scatter x=rscrage y=logodds_allr;
				run;

			proc sgplot data=allr;
				scatter x=rscrage y=predprob_allr;
				run;

		*quickly want to compare the natural cubic with listed knots to 
		percentile knots but not cubic;
		*bivariate relationship between age splines and outcome, 
			FOR GRAPHING ONLY, NO WEIGHT STATEMENT;	
			proc logistic data=a;
				class allr (ref="during: barrier, withdrawal, nothing");
				effect spl=spline(rscrage / knotmethod=percentiles(5));
				model allr = spl;
				output out=allr p=predprob_allr xbeta=logodds_allr;
				run;

			*graphing spline output to see shape;
			data allr; set allr;
				keep caseid predprob_allr logodds_allr &varlist allr;
				run;

			proc sgplot data=allr;
				scatter x=rscrage y=logodds_allr;
				run;

			proc sgplot data=allr;
				scatter x=rscrage y=predprob_allr;
				run;

		************ OK, I LANDED ON NATURAL CUBIC SPLINE WITH LIST KNOT METHOD;
		* DISREGARD LIST KNOT, I LANDED ON PERCENTILES;
		
		*Running this to confirm estimate statement by hand (weight statement
		not included);
		proc surveylogistic data=a;
			class
				allr (ref="during: barrier, withdrawal, nothing");
			effect spl=spline(rscrage / knotmethod=percentiles(5) details);
			model allr = spl;
			estimate 'log OR for 35 vs 25' spl [1,35] [-1,25] / e exp cl;
			output out=allr pred=pred xbeta=logodds;
			run;

	proc sgplot data=allr;
		scatter x=rscrage y=logodds;
		run;
	*/

	*bivariate with splines;
	title 'allr = age';
	proc surveylogistic data=a;
		class
			allr (ref="during: barrier, withdrawal, nothing");
		weight weightvar;
		effect spl=spline(rscrage / details naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5));
		model allr = spl;
		estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
		estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
		estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
		estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
		estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
		estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
		estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
		estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
		output out=allr pred=pred;
		ods output Estimates=EstimatesALLR_AGE;
		ods output FitStatistics=FitStatisticsALLR_AGE;
		run;

	proc sgplot data=allr;
		scatter y=pred x=rscrage;
		run;
		*actually, it works with the weight statement, going to comment out
		the above code that doesn't include weights;
		
		proc print data=EstimatesALLR_AGE; run;

		/*proc export data=Estimates
			dbms=xlsx
			outfile="U:\Dissertation\xls_graphs\Estimates.xlsx"
			replace;
			run;
		proc contents data=Estimates; run;
		proc print data=Estimates; run;*/

proc freq data=a;
	tables edu hisprace2 povlev;
	run;

*first doing some stepwise work;
title 'allr = age + demographics';
proc surveylogistic data=a;
	class 
		allr (ref="during: barrier, withdrawal, nothing")
		edu (ref="hs degree or ged")
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
		povlev (ref="100-199% PL");
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=percentiles(5) details);
	model allr = spl 
		edu
		hisprace2
		povlev;
	estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
	estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
	estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
	ods output Estimates=EstimatesALLR_AGE_DEM;
	ods output FitStatistics=FSallr_age_dem;
	ods output OddsRatios=ORallr_age_dem;
	run;

	*adding levels here on Paul's recommendation - adding parity without
	age at first birth to see if the reversal in trend is due to some people
	who cannot be exposed to it;

	title 'allr = age + demographics + parity';
	proc surveylogistic data=a;
		class 
			allr (ref="during: barrier, withdrawal, nothing")
			edu (ref="hs degree or ged")
			hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
			povlev (ref="100-199% PL")
			parity (ref="0 BABIES");
		weight weightvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model allr = spl 
			edu
			hisprace2
			povlev
			parity;
		estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
		estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
		estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
		estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
		estimate '38 vs 25' spl [1,38] [-1,25] / exp cl;
		estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
		estimate '42 vs 25' spl [1,42] [-1,25] / exp cl;
		estimate '44 vs 25' spl [1,35] [-1,25] / exp cl;
		ods output Estimates=estallr_age_dem_par;
		ods output FitStatistics=fsallr_age_dem_par;
		ods output OddsRatios=ORallr_age_dem_par;
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
