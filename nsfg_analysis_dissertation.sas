*******************************************
************** DISSERTATION ***************
************* NSFG 2011-2015 **************
******************************************;

*##############################################################;
*** NOTE: This program was originally created to begin work
on aims 1 and 2. In order to stay organized, I eventually
created separate programs for each model. This file is
now used specifically for doing general descriptives for aim 1.
As of 4/7/19, I am doing as much cleaning as possible as I 
re-run descriptives for writing aim 1 methods;
*##############################################################;

*CREATING TEMPORARY DATASET FROM PERMANENT;
libname library "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles";
/*proc format library=library; run;
data work.a; set library.nsfg_females_2011_2015; run;

%include "U:\Dissertation\nsfg_analysis_vartx.sas";
	*runs variable treatment program;*/
	
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\nsfg_CMcWFormats.sas";
	*McWilliams-created formats and labels;
	*ignore error, formats will still work;

*creating temporary dataset from permanent to work;
data a; set library.nsfg; run;

*turning on ods trace and graphics for easy table and 
graphics creation;
ods trace on;
ods graphics on / reset=index imagename="descriptives";
ods listing gpath = "C:\Users\Christine McWilliams\Box Sync\
Education\Dissertation\AnalyticFiles\sas_graphs_descrip";

proc sgplot data=a;
	histogram edud;
	run;


*######### WORKING ON SAMPLE #########;

/*Commenting out removal of case where
	age was not ascertained, already part of the permanent 
	dataset;

* Removing case where age was not ascertained;

data a; set a;
	if rscrage = 97 then delete;
	run;*/

*** Numbers for chapter 2 flow chart;

*Full analytic sample;
	libname full "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\Archive";
	proc contents data=full.nsfg_females_2011_2015; run;

*Women under 23;
	proc means data=full.nsfg_females_2011_2015; var rscrage; where rscrage < 23; run;

*One individual whose age was not ascertained;
	proc print data=full.nsfg_females_2011_2015; var rscrage constat1 caseid; where rscrage > 44; run;

*Not at risk of UIP;
	proc means data=a; var rscrage; where elig=0; run;

*Double-checking how I recoded individuals with "other" as contraceptive method;
	proc means data=a; var rscrage; run;
	proc means data=a; var bcc; where constat1=22; run;
	*Yep, those are kept in and I'm happy with my choices;

*Non-users;
	proc freq data=a; tables bcc*constat1; run;

*Final sample size;
	proc freq data=a; tables bcc; where bcc=1 or bcc=2 or bcc=3; run;
	*Hmm, this should be 5406 according to the flow chart but is 5327;

	proc freq data=a; tables bcc; run;
	proc freq data=a; tables bcc*constat1; where rscrage > 22; run;
		*age is fine but the number of missings is too high (2160);
	proc freq data=a; tables constat1; where elig=0 and rscrage > 22; run;
		*that is also fine, showing 2081 not at risk of uip;
	proc freq data=a; tables constat1; where bcc=.; run;
		*OK, THE PROBLEM IS 79 POSTPARTUM INDIVIDUALS;
		proc freq data=a; tables constat2; where constat1=32; run;

*** Briefly exploring the sampling corrections;
proc means; var stratvar panelvar weightvar; run;

proc freq; tables rscrage; run;
proc surveyfreq; tables rscrage; strata stratvar; cluster panelvar; weight weightvar; run;

proc freq; tables elig; run;


*######################*
*#### DESCRIPTIVES ####*
*######################*;

*########### TABLE 1 ###########;

*using bcc for table 1, it's general enough to properly describe
the sample and specific enough to provide context for all four
models;

proc freq data=a; tables bcc; run;
proc sort data=a; by bcc; run;

*I wanted to write code to create a nice table 1 but I'm at the critical 
point where hard coding would have taken significantly less time, so commenting
out the code to automate and going with several proc freqs;
/*%let confounders = edud hisprace2 pov agebabycat parityd rwant mard curr_ins;

%macro tableone;
	%let i=1;
	%do %until(not %length(%scan(&confounders,&i)));
proc freq data=a; 
	tables (%scan(&confounders,&i))*bcc / missing; 
	ods output crosstabfreqs=ct_bcc_%scan(&confounders,&i); 
	run;
	%let i=%eval(&i+1);
	%end;
	%mend tableone;

	%tableone;

proc print data=ct_bcc_agebabycat; run;
data test; set ct_bcc_agebabycat;
	drop _type_ _table_ table;
	run;
proc print data=test; where bcc=1; run;

proc sort data=ct_bcc_agebabycat; by bcc; run;

proc freq data=a; tables bcc*edud; ods output crosstabfreqs=c; run;
proc print data=c; run;*/

proc freq data=a; tables edud*bcc; run;


*########### SAMPLING WEIGHTS ###########;

	proc means data=a median;
		var weightvar;
		run;

	proc means data=a;
		var weightvar;
		run;

	title "Sampling Weights NSFG 2011-2015";
	proc sgplot data=a;
		histogram weightvar / binwidth=1000 binstart=0 showbins;
		density weightvar;
		run;
	title;


*########### IMPUTED POVERTY ###########;

	proc means; var poverty; run;

	title 'poverty histogram, all values';
	proc sgplot;
		histogram poverty;
		run;

	title 'poverty histogram';
	proc sort data=a; by poverty_i;
	proc sgplot;
		histogram poverty;
		by poverty_i;
		run;

	title 'crude contraceptive use by imputed poverty';
	proc freq data=a;
		tables poverty_i*ster / missing;
		run;
	proc freq data=a;
		tables poverty_i*ster;
		run;
	proc freq data=a;
		tables poverty_i*ster;
		weight weightvar;
		run;


	proc freq data=a;
		tables poverty_i*bcyes / missing;
		run;
	proc freq data=a;
		tables poverty_i*bcyes;
		run;
	proc freq data=a;
		tables poverty_i*bcyes;
		weight weightvar;
		run;


	title 'detailed contraceptive use by imputed poverty';
	proc freq data=a;
		tables poverty_i*bc / missing;
		run;
	proc freq data=a;
		tables poverty_i*bc;
		run;
	proc freq data=a;
		tables poverty_i*bc;
		weight weightvar;
		run;

	*as recommended by deb, regressing imputed poverty 
		on other characteristics;
	title 'imputed poverty regressed on sociodemographics';
	proc surveylogistic data=a;
		class edu (ref="hs degree or ged") hisprace2;
		model poverty_i = rscrage edu hisprace2;
		run;


*########### REPRODUCTIVE CATEGORIES BY AGE ###########;

	*WHAT DO REPRODUCTIVE HEALTH BEHAVIORS LOOK LIKE GENERALLY
	BY AGE?;

	title 'all repro options by age';
	proc freq data=a;
		tables rscrage*allrepro / nofreq nopercent nocol;
		weight weightvar;
		run;

	title 'all repro options by age categories';
	proc freq data=a;
		tables agecat*allrepro / nofreq nopercent nocol;
		weight weightvar;
		run;


	*HOW DOES A CRUDE MEASURE OF CONTRACEPTIVE CHOICE DIFFER
	BY AGE?;
	title 'crude contraceptive categories by age';
	proc freq data=a;
		tables rscrage*ster / nofreq nopercent nocol;
		weight weightvar;
		run;

		*p.s. making a stacked bar chart in sas is WAY more painful
		than it should be, i tried 2 things:
		https://blogs.sas.com/content/graphicallyspeaking
		/2013/09/20/stacked-bar-chart-with-segment-labels/
		https://blogs.sas.com/content/iml/2014/04/08/construct-a-stacked-
		bar-chart-in-sas-where-each-bar-equals-100.html.
		the second linke was helpful but if i have to make
		an output dataset, it's more work than just doing it in
		excel. so i'm just copying and pasting these in
		excel;

	*HOW DOES METHOD USE DIFFER BY AGE WHEN RESTRICTING TO WOMEN
	AT RISK OF UNINTENDED PREGNANCY?;

	title 'detailed method categories by age';
	proc freq data=a;
		tables rscrage*bc / nofreq nopercent nocol;
		weight weightvar;
		run;


*########### PROBING CONFOUNDERS ###########;

	*SIMPLE FREQS AND CROSS TABS;
	
	* just frequencies;
	proc freq data=a;
		table
			allrepro
			bc
			curr_ins
			edu
			fecund
			intend
			jintend
			parity
			povlev
			prevcohb
			rmarital
			religion
			nchildhh;
		weight weightvar;
		run;
	
	* mean for the one continuous variable;
	proc means data=a;
		var
			agebaby1;
		weight weightvar;
		run;

	* cross tabs of all variables by a crude birth control variable;
	proc freq data=a;
		table
			(
			curr_ins
			edu
			fecund
			intend
			jintend
			parity
			povlev
			prevcohb
			rmarital
			religion
			nchildhh)*bcc / nopercent norow nocol;
		weight weightvar;
		run;

	proc freq data=a;
		table religion*bcc / nopercent norow nocol;
		weight weightvar;
		run;

		proc freq data=a;
		table religion*bcc;
		weight weightvar;
		run;

	* box plots of all variables by age;
	proc sgplot data=a;
		hbox rscrage / category=curr_ins;
		run;
	%let confounders =
		curr_ins
		edu
		fecund
		intend
		jintend
		parity
		povlev
		prevcohb
		rmarital
		religion;

	%macro ditto;
		%let i=1;
		%do %until(not %length(%scan(&confounders,&i)));
		proc sgplot data=a;
			vbox rscrage / category=%scan(&confounders,&i);
		run;
		%let i=%eval(&i+1);
		%end;
	%mend ditto;

	%ditto;

	*MORE DETAIL ON EDUCATION, POVERTY;

	title 'differences in education by age';
	proc freq data=a;
		tables rscrage*edu;
		weight weightvar;
		run;
		*each age group is around 300 people;

	proc freq data=a;
		tables rscrage*edu / nofreq nopercent nocol;
		weight weightvar;
		run;
		*after 22 they even out;

	proc freq data=a;
		tables agecat*edu / nofreq nopercent nocol;
		run;

	title 'differences in HH income by age';
	proc sort; by rscrage; run;
	proc means data=a;
		var poverty; by rscrage;
		weight weightvar;
		output out=pov_age;
		run;
	proc contents data=pov_age; run;
	proc print data=pov_age; run;
	proc print data=pov_age;
		where _stat_="MEAN";
		format _all_;
		run;

	proc sort; by agecat; run;
	proc means data=a;
		var poverty; by agecat;
		run;
		*increases around 15 or 20 points each age group;

	title 'age and method choice, stratified by education';
	/* these output datasets are cute but copying and pasting the individual
	tables is actually a little easier;
	proc sort data=a; by edu; run;
	proc freq data=a;
		tables aged*ster / out=aged_ster;
		by edu;
		weight weightvar;
		run;
		*cell sizes are pretty good, some zeros that will need to be dealt with;

	proc print data=aged_ster; run;*/

	proc sort data=a; by edu;
	proc freq data=a;
		tables ster*aged / missing nofreq nopercent nocol chisq;
		weight weightvar;
		by edu;
		run;

	/*title 'age and method choice, stratified by poverty';
	proc freq data=a;
		tables poverty*aged / out=aged_ster_pov;
		by edu;
		weight weightvar;
		run;
		*cell sizes are ok, many of the 15-19 group have 0's above 200%;*/

	proc sort data=a; by poverty; run;
	title 'age and method choice, stratified by poverty';
	proc freq data=a;
		tables ster*aged / missing nofreq nopercent nocol chisq;
		by poverty;
		weight weightvar;
		run;

	/*title 'figuring out 1 missing respondent';
	proc print data=a;
		var caseid constat1; where allrepro=.; run;
		*allrepro was missing a recode for the respondent who was categorized
		as steril-unknown reasons-male. fixed this in vartx;*/

		/*Descriptives for PHS 820 pres on 10/10/18;
		proc freq; tables agebabycat*(nouse ster); run;
		proc freq; tables agebaby1; run;

		proc freq; tables agebabycat*nouse / nofreq nocol nopercent; weight weightvar; run;
		proc freq; tables agebabycat*ster / nofreq nocol nopercent; weight weightvar; run;

		proc freq; tables agebaby1*nouse / nofreq nocol nopercent; where rscrage > 21; weight weightvar; run;
		proc freq; tables agebaby1*ster / nofreq nocol nopercent; where rscrage > 21; weight weightvar; run;

		proc freq; tables edu*nouse / nofreq nocol nopercent; where rscrage > 21; weight weightvar; run;
		proc freq; tables edu*ster / nofreq nocol nopercent; where rscrage > 21; weight weightvar; run;

		*/

	*Descriptives for lab meeting;
	proc sort; by edu; run;
	proc freq; tables edu*ster / nofreq nopercent nocol; where agecat > 4; run;
	proc freq; tables edu*ster;
		where agecat > 4 and agefirstbirth < 30;
		run;
	proc freq; tables edu*ster / nofreq nopercent nocol;
		where agecat > 4 and agefirstbirth < 30;
		run;
	title "Women 35+, first birth before 25";
	proc freq; tables edu*ster / nofreq nopercent nocol;
		where agecat > 4 and agefirstbirth < 25;
		run;
	title "Women 35+, first birth after 30";
	proc freq; tables edu*ster / nofreq nopercent nocol;
		where agecat > 4 and agefirstbirth > 30;
		run;
	title;

	*How does education differ by race, specifically the "no HS";
	proc freq data=a; tables hisprace2*edu; weight weightvar; run;
	proc freq data=a; tables hisprace2*edu / nofreq nopercent nocol; 
		weight weightvar; run;
	proc freq data=a; tables edu*hisprace2; weight weightvar; run;

	*How is age at first birth associated with race?;
	proc freq data=a; tables hisprace2*agebabycat;
		weight weightvar; run;


*########### BIVARIATE ANALYSES ###########;


	*trying something first;
	proc surveylogistic data=a;
		class effmeth_1 (ref=first);
		weight weightvar;
		model bcc = rscrage / link=glogit;
		run;

	proc surveylogistic data=a;
		class effmeth_1 (ref=first) hisprace2 (ref=first);
		weight weightvar;
		model bcc = hisprace2 / link=glogit;
		run;

	proc surveylogistic data=a;
		class effmeth_1 (ref=first) povlev (ref=first);
		weight weightvar;
		model effmeth_1 = povlev;
		run;

	proc surveylogistic data=a;
		class effmeth_1 (ref=first) edu (ref="hs degree or ged");
		weight weightvar;
		model effmeth_1 = edu;
		run;

	proc surveylogistic data=a;
		class ster;
		weight weightvar;
		model ster=rscrage;
		run;	


*######################*
*##### REGRESSION #####*
*######################*;


	*LOG ODDS OF OUTCOMES BY AGE;
	proc surveylogistic data=a;
		model effmeth_1=rscrage;
		weight weightvar;
		output out=logodds_1 p=predprob_1 xbeta=logodds_1;
		run;

		title;
		proc contents data=logodds_1; run;

		data logodds_1; set logodds_1;
			keep caseid logodds_1 predprob_1 &varlist;
		run;

		proc sgplot data=logodds_1;
			scatter x=rscrage y=logodds_1;
			run;

		proc sgplot data=logodds_1;
			scatter x=rscrage y=predprob_1;
			run;

	proc surveylogistic data=a;
		model effmeth_4=rscrage;
		weight weightvar;
		output out=logodds_4 p=predprob_4 xbeta=logodds_4;
		run;

		data logodds_4; set logodds_4;
			keep &varlist logodds_4 predprob_4;
			run;

		proc sgplot data=logodds_4;
			scatter x=rscrage y=logodds_4;
			run;

		proc sgplot data=logodds_4;
			scatter x=rscrage y=predprob_4;
			run;

		proc print data=logodds_4 (obs=30); run;

		proc means data=logodds_4; var logodds_4 predprob_4; run;
		proc means data=logodds_1; var logodds_1 predprob_1; run;


	/*%macro logodds;

	%do i = 1 %to 9;
	proc surveylogistic data=a;
	effmeth_&i. = rscrage;
	weight weightvar;
	output out=logodds_&i. p=*/

* REGRESSION MODELS SELECTED AFTER INVESTIGATION OF QUASI-COMPLETE SEPARATION;
		* Code from investigation can be found here: 
		   "U:\Dissertation\nsfg_separation_investigation.sas";

	* Bivariate;
	proc surveylogistic data=a;
		class effmeth_1 / ref=first;
		weight weightvar;	
		model effmeth_1 = rscrage;
		run;

	* Only the big-3 SES;
	proc surveylogistic data=a;
		class 
			effmeth_1 (ref=first) 
			hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
			povlev (ref="<100% PL")
			edu (ref="hs degree or ged");
		weight weightvar;
		model effmeth_1 = rscrage hisprace2 povlev edu;
		run; 

	* Full model, includes new marital status variable, fecund is removed;
	proc surveylogistic data=a;
		class
			effmeth_1 (ref=first) 
			hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
			povlev (ref="<100% PL")
			edu (ref="hs degree or ged")
			rwant
			mard (ref=first)
			curr_ins
			religion;
		weight weightvar;
		model effmeth_1 = rscrage hisprace2 povlev edu rwant mard
			curr_ins religion;
		run;

	* Full model, includes new marital status variable, fecund is removed,
		parity is included;
		proc surveylogistic data=a;
			class
				effmeth_1 (ref=first) 
				hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
				povlev (ref="<100% PL")
				edu (ref="hs degree or ged")
				rwant
				mard (ref=first)
				curr_ins
				religion;
			weight weightvar;
			model effmeth_1 = rscrage hisprace2 povlev edu rwant mard
				curr_ins religion parity;
			run;

		%macro aim1ha;

		
		%do i = 1 %to 9;
		proc surveylogistic data=a;
		class
			effmeth_&i. (ref=first) 
			hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
			povlev (ref="<100% PL")
			edu (ref="hs degree or ged")
			fecund 
			rmarital (ref=first)
			curr_ins
			religion;
		weight weightvar;
		model effmeth_&i. = rscrage hisprace2 povlev edu fecund intend rmarital
			curr_ins religion;
		run;
		%end;

		%mend aim1ha;

		%aim1ha;


	*** Working on splines;

	* Using final full model from above;
	proc logistic data=a;
		class
			effmeth_1 (ref=first) 
			hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
			povlev (ref="<100% PL")
			edu (ref="hs degree or ged")
			rwant
			mard (ref=first)
			curr_ins
			religion;
		weight weightvar;
		model effmeth_1 = rscrage hisprace2 povlev edu rwant mard
			curr_ins religion parity;
		effectplot;
		run;
		* Got an error that the variable configuration is not supported
		by effectplot, i see the problem is you have to specify which
		plot because the command can't select the right plot if you have
		both categorical and continuous variables, so i'm trying slicefit
		below;


	proc logistic data=a;
		class
			effmeth_1 (ref=first) 
			hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
			povlev (ref="<100% PL")
			edu (ref="hs degree or ged")
			rwant
			mard (ref=first)
			curr_ins
			religion;
		weight weightvar;
		model effmeth_1 = rscrage hisprace2 povlev edu rwant mard
			curr_ins religion parity;
		effectplot slicefit;
		run;


	* now trying effect statement to use a cubic spline;
	proc logistic data=a;
		class
			effmeth_1 (ref=first) 
			hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
			povlev (ref="<100% PL")
			edu (ref="hs degree or ged")
			rwant
			mard (ref=first)
			curr_ins
			religion;
		weight weightvar;
		effect spl=spline(rscrage);
		model effmeth_1 = rscrage hisprace2 povlev edu rwant mard
			curr_ins religion parity;
		run;
		* it ran but i have no idea what it means;

	* going back to just trying to plot;

	*first no covariates;
	proc logistic data=a;
		class
			effmeth_1 (ref=first) ;
		weight weightvar;
		model effmeth_1 = rscrage;
		output out=logodds_1 p=predprob_1 xbeta=logodds_1;
		run;

		data logodds_1; set logodds_1;
			keep caseid logodds_1 predprob_1 &varlist;
		run;

		proc sgplot data=logodds_1;
			scatter x=rscrage y=logodds_1;
			run;

		proc sgplot data=logodds_1;
			scatter x=rscrage y=predprob_1;
			run;
		

	*now with covariates;
	proc logistic data=a;
		class
			effmeth_1 (ref=first) 
			hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
			povlev (ref="<100% PL")
			edu (ref="hs degree or ged")
			rwant
			mard (ref=first)
			curr_ins
			religion;
		weight weightvar;
		model effmeth_1 = rscrage hisprace2 povlev edu rwant mard
			curr_ins religion parity;
		output out=logodds_1 p=predprob_1 xbeta=logodds_1;
		run;

		data logodds_1; set logodds_1;
			keep caseid logodds_1 predprob_1 &varlist;
		run;

		proc sgplot data=logodds_1;
			scatter x=rscrage y=logodds_1;
			run;

		proc sgplot data=logodds_1;
			scatter x=rscrage y=predprob_1;
			run;

* trying condoms now since the increase in sterilization by age looks too
perfect;
	
	proc logistic data=a;
		class
			effmeth_4 (ref=first) ;
		weight weightvar;
		model effmeth_4 = rscrage;
		output out=logodds_4 p=predprob_4 xbeta=logodds_4;
		run;

		data logodds_4; set logodds_4;
			keep caseid logodds_4 predprob_4 &varlist;
		run;

		proc sgplot data=logodds_4;
			scatter x=rscrage y=logodds_4;
			run;

		proc sgplot data=logodds_4;
			scatter x=rscrage y=predprob_4;
			run;
		

	*now with covariates;
	proc logistic data=a;
		class
			effmeth_4 (ref=first) 
			hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
			povlev (ref="<100% PL")
			edu (ref="hs degree or ged")
			rwant
			mard (ref=first)
			curr_ins
			religion;
		weight weightvar;
		effect spl=spline(rscrage / knotmethod=percentiles(5));
		model effmeth_4 = rscrage hisprace2 povlev edu rwant mard
			curr_ins religion parity;
		output out=logodds_4 p=predprob_4 xbeta=logodds_4;
		run;

		data logodds_4; set logodds_4;
			keep caseid logodds_4 predprob_4 &varlist;
		run;

		proc sgplot data=logodds_4;
			scatter x=rscrage y=logodds_4;
			run;

		proc sgplot data=logodds_4;
			scatter x=rscrage y=predprob_4;
			run;

	*now messing around more with splines. ugh.;
	proc logistic data=a;
		class
			effmeth_4 (ref=first) 
			hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
			povlev (ref="<100% PL")
			edu (ref="hs degree or ged")
			rwant
			mard (ref=first)
			curr_ins
			religion;
		weight weightvar;
		effect spl=spline(rscrage / knotmethod=percentiles(5));
		model effmeth_4 = spl;
		output out=logodds_4 p=predprob_4 xbeta=logodds_4;
		run;

		data logodds_4; set logodds_4;
			keep caseid logodds_4 predprob_4 &varlist;
		run;

		proc sgplot data=logodds_4;
			scatter x=rscrage y=logodds_4;
			run;

		proc sgplot data=logodds_4;
			scatter x=rscrage y=predprob_4;
			run;

	****** PSEUDO DECISION TREES;


	title 'first branch: something vs nothing';
	proc surveylogistic data=a;
		class 
			bcyes (ref=first)
			hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
			povlev (ref="<100% PL")
			edu (ref="hs degree or ged")
			rwant
			mard (ref=first)
			curr_ins
			religion;
		weight weightvar;
		model bcyes = rscrage hisprace2 povlev edu rwant
			mard curr_ins religion;
		run;

	title 'second branch: get from doc vs get yourself';
	proc surveylogistic data=a;
		class 
			doc (ref=first)
			hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
			povlev (ref="<100% PL")
			edu (ref="hs degree or ged")
			rwant
			mard (ref=first)
			curr_ins
			religion;
		weight weightvar;
		model doc = rscrage hisprace2 povlev edu rwant
			mard curr_ins religion;
		run;

	* THIS VARIABLE NEEDS FIXING BUT WANT TO KEEP MOVING;
	title 'third branch: doc-required methods';
	proc surveylogistic data=a;
	class 
		docmeth
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
		povlev (ref="<100% PL")
		edu (ref="hs degree or ged")
		rwant
		mard (ref=first)
		curr_ins
		religion;
	weight weightvar;
	model docmeth = rscrage hisprace2 povlev edu rwant
		mard curr_ins religion / link=glogit;
	run;

	* THIS VARIABLE MIGHT ALSO NEED FIXING BUT WANT TO KEEP MOVING;
	title 'third branch: personal methods';
	proc surveylogistic data=a;
	class 
		selfmeth (ref=first)
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
		povlev (ref="<100% PL")
		edu (ref="hs degree or ged")
		rwant
		mard (ref=first)
		curr_ins
		religion;
	weight weightvar;
	model selfmeth = rscrage hisprace2 povlev edu rwant
		mard curr_ins religion / link=glogit;
	run;

	* BEFORE/DURING TREE;
	title 'trunk: before/during';

	proc sgplot data=a;
		vbar rscrage / response = all;
		run;
	proc logistic data=a;
		class all (ref = "during: barrier, withdrawal, nothing");
		weight weightvar;
		model all = rscrage;
		effectplot;
		run;
	proc logistic data=a;
		class all (ref = "during: barrier, withdrawal, nothing");
		weight weightvar;
		effect spl=spline(rscrage / knotmethod=percentiles(6));
		model all = spl;
		output out=all p=predprob_all xbeta=logodds_all;
		run;

		data all; set all;
			keep caseid predprob_all logodds_all &varlist all;
		run;

		proc sgplot data=all;
			scatter x=rscrage y=logodds_all;
			run;

		proc sgplot data=logodds_4;
			scatter x=rscrage y=predprob_4;
			run;


		*Stratified analysis for Deb;
			*First just sterilization by age;

		%macro ditto;
		%do i=0 %to 6;
		title 'stratified1';
		proc logistic data=a;
			class 
				effmeth_1 (ref=first)
				agebabycat;
			weight weightvar;
			model effmeth_1 = rscrage;
			where agebabycat = &i.;
			run;

		%end;
		%mend;

		%ditto;


		*Now trying with a few more variables, stratified by age
		at first birth;

		%macro ditto;

		%do i=0 %to 6;

		title "stratified2";
		proc logistic data=a;
			class 
				effmeth_1 (ref=first)
				hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
				edu (ref="hs degree or ged")
				agebabycat;
			weight weightvar;
			model effmeth_1 = rscrage hisprace2 edu;
			where agebabycat = &i.;
			run;

		%end;
		%mend;

		%ditto;

		*Now same variables by stratified by race;
		%macro ditto;

		%do i=0 %to 4;

		title "stratified";
		proc logistic data=a;
			class 
				effmeth_1 (ref=first)
				agebabycat (ref=first)
				edu (ref="hs degree or ged");
			weight weightvar;
			model effmeth_1 = rscrage edu;
			where hisprace2 = &i.;
			run;

		%end;
		%mend;

		%ditto;	

		*Now same variables by stratified by race, doing one with age at first birth;
		%macro ditto;

		%do i=0 %to 4;

		title "stratified4";
		proc logistic data=a;
			class 
				effmeth_1 (ref=first)
				agebabycat (ref=first)
				edu (ref="hs degree or ged");
			weight weightvar;
			model effmeth_1 = rscrage edu agebabycat;
			where hisprace2 = &i.;
			run;

		%end;
		%mend;

		%ditto;	

		*Now same variables by stratified by education;
		%macro ditto;

		%do i=0 %to 6;

		title "stratified5";
		proc logistic data=a;
			class 
				effmeth_1 (ref=first)
				hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE");
			weight weightvar;
			model effmeth_1 = rscrage hisprace2;
			where edu = &i.;
			run;

		%end;
		%mend;

		%ditto;	


		*Same but with agebabycat;
		%macro ditto;

		%do i=0 %to 6;

		title "stratified6";
		proc logistic data=a;
			class 
				effmeth_1 (ref=first)
				hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE")
				agebabycat (ref="no births");
			weight weightvar;
			model effmeth_1 = rscrage hisprace2 agebabycat;
			where edu = &i.;
			run;

		%end;
		%mend;

		%ditto;	

ods trace on;
proc freq data=a; tables bcc; weight weightvar; run;

proc freq data=a; tables allrepro; run;
proc freq data=a; 
	tables parity*bcc; 
	weight weightvar; 
	ods output CrossTabFreqs=bcc_parity;
	run;

