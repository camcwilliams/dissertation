*#########################*
*##### DECISION TREE #####*
*#########################*;


* LEVEL 1: COUPLED WITH INTERCOURSE VS NOT;

proc freq data=a;
	tables allr;
	run;

proc logistic;
	class allr (ref="during: barrier, withdrawal, nothing");
	weight weightvar;
	model allr = rscrage;
	effectplot;
	run;

proc sgplot data=a;
	vbar rscrage / response = allr;
	run;
	
proc logistic data=a;
	class allr (ref="during: barrier, withdrawal, nothing");
	effect spl=spline(rscrage / knotmethod=percentiles(5));
	model allr = spl;
	output out=allr p=predprob_allr xbeta=logodds_allr;
	run;
	*NOTE: The chunk of code above is for outputting linear predictors to make
	a pretty graph. It does not include the weight statement. Proceed with caution
	if using for any estimation;

	data allr; set allr;
		keep caseid predprob_allr logodds_allr &varlist allr;
		run;

	proc sgplot data=allr;
		scatter x=rscrage y=logodds_allr;
		run;

	proc sgplot data=allr;
		scatter x=rscrage y=predprob_allr;
		run;
	
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


	proc surveylogistic data=a;
		class
			allr (ref="during: barrier, withdrawal, nothing");
		weight weightvar;
		effect spl=spline(rscrage / knotmethod=percentiles(5) details);
		model allr = spl;
		estimate 'log OR for 35 vs 25' spl [1,35] [-1,25] / e exp cl;
		output out=allr pred=pred;
		run;

	*Trying guidance from here: http://support.sas.com/kb/57/975.html;
	proc sgplot data=allr;
		scatter y=pred x=rscrage;
		run;

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
	effect spl=spline(rscrage / knotmethod=percentiles(5));
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
