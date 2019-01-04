*#########################*
*##### DECISION TREE #####*
*#########################*;


* LEVEL 1: COUPLED WITH INTERCOURSE VS NOT;

proc freq data=a;
	tables allr;
	run;

*just bivariate, no spline;
proc logistic;
	class allr (ref="during: barrier, withdrawal, nothing");
	weight weightvar;
	model allr = rscrage;
	effectplot;
	run;

*plotting the relationship between outcome and age, no adjustment;
proc sgplot data=a;
	vbar rscrage / response = allr;
	run;

*checking proc univariate to see if i want to use knots other than percentiles;
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

	proc print data=percentiles2; run;

*bivariate relationship between age splines and outcome, 
	FOR GRAPHING ONLY, NO WEIGHT STATEMENT;	
proc logistic data=a;
	class allr (ref="during: barrier, withdrawal, nothing");
	effect spl=spline(rscrage / details naturalcubic basis=tpf(noint)
								knotmethod=list(15 20 26 31 37 44));
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

	*bivariate with splines;
	proc surveylogistic data=a;
		class
			allr (ref="during: barrier, withdrawal, nothing");
		weight weightvar;
		effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
		model allr = spl;
		estimate '35 vs 25' spl [1,35] [-1,25] / e exp cl;
		estimate '38 vs 25' spl [1,38] [-1,25] / e exp cl;
		estimate '40 vs 25' spl [1,40] [-1,25] / e exp cl;
		estimate '42 vs 25' spl [1,42] [-1,25] / e exp cl;
		estimate '44 vs 25' spl [1,35] [-1,25] / e exp cl;
		output out=allr pred=pred;
		run;

	*Trying guidance from here: http://support.sas.com/kb/57/975.html;
	proc sgplot data=allr;
		scatter y=pred x=rscrage;
		run;

*first doing some stepwise work for Deb;
title 'allr = all + demographics';
proc surveylogistic data=a;
	class 
		allr (ref="during: barrier, withdrawal, nothing")
		edu
		hisprace2
		povlev;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=list(15 20 26 31 37 44) details);
	model allr = spl 
		edu
		hisprace2
		povlev;
	estimate '15 vs 25' spl [1,15] [-1,25] / exp cl;
	estimate '20 vs 25' spl [1,20] [-1,25] / exp cl;
	estimate '30 vs 35' spl [1,30] [-1,25] / exp cl;
	estimate '35 vs 25' spl [1,35] [-1,25] / exp cl;
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,44] [-1,25] / exp cl;
	output out=allr p=predprob_allr xbeta=logodds_allr;
	run;

title 'allr = age + demographics + relationship & fertility';
proc surveylogistic data=a;
	class 
		allr (ref="during: barrier, withdrawal, nothing")
		edu
		hisprace2
		povlev
		canhaver
		agebabycat
		parity		
		rwant
		mard;
	weight weightvar;
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=list(15 20 26 31 37 44) details);
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
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,44] [-1,25] / exp cl;
	output out=allr p=predprob_allr xbeta=logodds_allr;
	run;


title 'allr = all vars of interest, no interaction';
proc surveylogistic data=a;
	class 
		allr (ref="during: barrier, withdrawal, nothing")
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
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=list(15 20 26 31 37 44) details);
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
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,44] [-1,25] / exp cl;
	output out=allr p=predprob_allr xbeta=logodds_allr;
	run;

title 'allr = all vars of interest, includes interaction';
proc surveylogistic data=a;
	class 
		allr (ref="during: barrier, withdrawal, nothing")
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
	effect spl=spline(rscrage / naturalcubic basis=tpf(noint)
								knotmethod=list(15 20 26 31 37 44) details);
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
	estimate '40 vs 25' spl [1,40] [-1,25] / exp cl;
	estimate '44 vs 25' spl [1,44] [-1,25] / exp cl;
	output out=allr p=predprob_allr xbeta=logodds_allr;
	run;


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
