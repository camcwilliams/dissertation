*******************************************
************** DISSERTATION ***************
************* NSFG 2011-2015 **************
******************************************;

*CREATING TEMPORARY DATASET FROM PERMANENT;
libname library "U:\Dissertation";
proc format library=library; run;
data work.a; set library.nsfg_females_2011_2015; run;
	
%include "U:\Dissertation\nsfg_CMcWFormats.sas";
	*McWilliams-created formats and labels;
	*ignore error, formats will still work;


%include "U:\Dissertation\nsfg_analysis_vartx.sas";
	*runs variable treatment program;

*######### WORKING ON SAMPLE #########;

* Flag for eligible cases (according to standard practice);

data a; set a;
	elig = 1;
	run;

	data a; set a;
		if constat1 = 30 then elig = 0; *currently pregnant;
		if constat1 = 31 then elig = 0; *seeking pregnancy;
		if constat1 = 33 or 
		constat1 = 34 or
		constat1 = 35 or
		constat1 = 36 then elig = 0; *noncontraceptive sterility;
		if constat1 = 38 then elig = 0; *sterile--unknown reasons -male;
		if constat1 = 40 then elig = 0; *no intercourse since menarche;
		if constat1 = 41 then elig = 0; *no intercourse in last 3 months;
		label elig="at risk of UIP, according to standard practice";
		run;

* Removing case where age was not ascertained;

data a; set a;
	if rscrage = 97 then delete;
	run;

*######################*
*#### DESCRIPTIVES ####*
*######################*;


/*########### CORRELATION ###########;

	proc corr data = a outp=CorrOutp; var &varlist; run;
	proc print data=CorrOutp; run;
	proc export data=CorrOutp outfile='outcorr' dbms=xlsx;
		run;*/

	proc corr data=a;
		var poverty rscrage edu hisprace2;
		run;


*########### TABLE 1 ###########;

proc sort; by ster; run;

title 'table 1, no weights';
proc freq data=a;
	tables (agecat poverty edu)*ster / missing nofreq nopercent nocol; 
	run;

	/*tried to output the table for easier manipulation but abandoned it;
	proc freq data=a; 
		tables agecat poverty edu / missing out=table1; by ster;
		run;

	proc print data=table1; run;*/

title 'table 1, weighted';
proc freq data=a;
	tables (agecat poverty edu)*ster / missing nopercent nocol;
	weight weightvar; 
	run;

*########### OTHER DESCRIPTIVES ###########;

	*WILL IMPUTED POVERTY BIAS RESULTS?;

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


	*LOOKING AT SUSPECTED CONFOUNDERS;
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
	proc sort; by agecat; run;
	proc means data=a;
		var poverty; by agecat;
		run;
		*increases around 15 or 20 points each age group;

	title 'age and method choice, stratified by education';
	proc sort; by edu; run;
	proc freq data=a;
		tables aged*ster;
		by edu;
		run;
		*cell sizes are pretty good, some zeros that will need to be dealt with;

	proc freq data=a;
		tables ster*aged / missing nofreq nopercent nocol chisq;
		by edu;
		run;

	title 'age and method choice, stratified by poverty';
	proc freq data=a;
		tables poverty*aged;
		by edu;
		run;
		*cell sizes are ok, many of the 15-19 group have 0's above 200%;

	proc sort; by poverty; run;
	proc freq data=a;
		tables ster*aged / missing nofreq nopercent nocol chisq;
		by poverty;
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


*######################*
*##### REGRESSION #####*
*######################*;

proc surveylogistic;
	model effmeth_1 = rscrage;
	weight weightvar;
	run;

proc surveylogistic;
	class effmeth_1 / ref=first;
	weight weightvar;	
	model effmeth_1 = rscrage;
	run;

proc surveylogistic;
	class 
		effmeth_1 (ref=first) 
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
		povlev (ref="<100% PL")
		edu (ref="hs degree or ged");
	weight weightvar;
	model effmeth_1 = rscrage hisprace2 povlev edu;
	run; 

proc surveylogistic;
	class
		effmeth_1 (ref=first) 
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
		povlev (ref="<100% PL")
		edu (ref="hs degree or ged")
		fecund 
		intend
		rmarital (ref="CURRENTLY MARRIED TO A PERSON OF THE OPPOSITE SEX")
		curr_ins
		religion;
	weight weightvar;
	model effmeth_1 = rscrage hisprace2 povlev edu fecund intend rmarital
		curr_ins religion;
	run;

	*this model has quasi-complete separation, investigating:;

	proc freq; tables rmarital*effmeth_1; run;
	*that doesn't seem to be the problem;
	proc freq; tables intend*effmeth_1; run;
	*it could be intend, obviously there are very small numbers of
	women who have been sterilized but intend to have another baby.
	removing it from the model;

	*it also appears povlev and edu are wonky;
	proc sort; by effmeth_1; run;
	proc freq; tables povlev*edu / out=freqcnt; by effmeth_1; run;

		/*keeping this in just in case;
		proc print data=freqcnt; run;
		proc export data=freqcnt
			dbms=xlsx
			outfile="U:\Dissertation\xls_graphs\freqcnt.xlsx"
			replace;
			run;
		*/

	proc freq data=a; tables edu*povlev; run;
	proc freq data=a; tables edu*effmeth_1; run;
	proc freq data=a; tables povlev*effmeth_1; run;

*maybe the problem is age. taking teenagers out here:;
proc surveylogistic data=a;
	class
		effmeth_1 (ref=first) 
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
		povlev (ref="<100% PL")
		edu (ref="hs degree or ged")
		fecund 
		rmarital (ref=first)
		curr_ins
		religion;
	weight weightvar;
	where rscrage >= 20;
	model effmeth_1 = rscrage hisprace2 povlev edu fecund intend rmarital
		curr_ins religion;
	run;
	*that did not help;

	*GOING TO TRY ALTERNATELY REMOVING EDUCATION AND POVERTY;
	title 'full model, no poverty';
	proc surveylogistic data=a;
	class
		effmeth_1 (ref=first) 
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
		edu (ref="hs degree or ged")
		fecund 
		rmarital (ref=first)
		curr_ins
		religion;
	weight weightvar;
	where rscrage >= 20;
	model effmeth_1 = rscrage hisprace2 edu fecund intend rmarital
		curr_ins religion;
	run;

	title 'full model, no education';
	proc surveylogistic data=a;
	class
		effmeth_1 (ref=first) 
		hisprace2 (ref="NON-HISPANIC WHITE, SINGLE RACE") 
		povlev (ref="<100% PL")
		fecund 
		rmarital (ref=first)
		curr_ins
		religion;
	weight weightvar;
	where rscrage >= 20;
	model effmeth_1 = rscrage hisprace2 povlev fecund intend rmarital
		curr_ins religion;
	run;

	*that also did not help;

	*TRYING BIVARIATE ASSOCIATIONS FOR ALL COVARIATES;
	proc surveylogistic data=a;
	class edu (ref="hs degree or ged");
	weight weightvar;
	model effmeth_1 = edu;
	run;

	proc surveylogistic data=a;
	class povlev (ref="<100% PL");
	weight weightvar;
	model effmeth_1 = povlev;
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

