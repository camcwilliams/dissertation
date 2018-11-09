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


*########### TABLE 1 ###########;

proc sort; by ster; run;

proc freq data=a;
	tables (agecat poverty edu)*ster / missing nofreq nopercent nocol; 
	run;

	/*tried to output the table for easier manipulation but abandoned it;
	proc freq data=a; 
		tables agecat poverty edu / missing out=table1; by ster;
		run;

	proc print data=table1; run;*/

*########### OTHER DESCRIPTIVES ###########;

	*WILL IMPUTED POVERTY BIAS RESULTS?;

	title 'crude contraceptive use by imputed poverty';
	proc freq data=a;
		tables poverty_i*ster / missing;
		run;
	proc freq data=a;
		tables poverty_i*bcyes / missing;
		run;
	proc freq data=a;
		tables poverty_i*ster;
		run;
	proc freq data=a;
		tables poverty_i*bcyes;
		run;


	title 'detailed contraceptive use by imputed poverty';
	proc freq data=a;
		tables poverty_i*bc / missing;
		run;
	proc freq data=a;
		tables poverty_i*bc;
		run;


	*WHAT DO REPRODUCTIVE HEALTH BEHAVIORS LOOK LIKE GENERALLY
	BY AGE?;

	title 'all repro options by age';
	proc freq data=a;
		tables rscrage*allrepro / nofreq nopercent nocol;
		run;

	title 'all repro options by age categories';
	proc freq data=a;
		tables agecat*allrepro / nofreq nopercent nocol;
		run;


	*HOW DOES A CRUDE MEASURE OF CONTRACEPTIVE CHOICE DIFFER
	BY AGE?;
	title 'crude contraceptive categories by age';
	proc freq data=a;
		tables rscrage*ster / nofreq nopercent nocol;
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


*---- REGRESSION ----*;

	*i'm putting this together just to explore, there appear to be some problems
	with the model converging, so it definitely needs a lot more work;
	proc logistic;
		class ster (ref="sterilized") edu (ref="bachelor's") agecat (ref="35-39");
		model ster = edu agecat agebaby1;
		where agecat = 5 or agecat = 6 or ster = 1 or ster = 2;
		run;
	*but, interestingly, even after putting age at first baby in the model,
	there's definitely still something going on with education;
/*
	*screw it, i'm going to do a regression;
	proc surveyreg data=a;
		class bc whynousing1 educat poverty;
		model rscrage = bc whynousing1 nbabes_s educat poverty / solution;
		run;
		*i forgot surveyreg doesn't output anything;

	proc freq data = a;
		tables race*nouse povlev*nouse nbabes_s*nouse;
		where agecat>4;
		run;

	proc logistic data=a;
		class educat povlev agecat nbabes_s;
		model nouse = agecat educat povlev nbabes_s;
		where agecat > 4;
		run;


	proc logistic data=a;
		class educat povlev agecat nbabes_s;
		model nouse = agecat educat povlev nbabes_s;
		run;

	proc logistic data=a;
		class educat povlev agecat nbabes_s race;
		model ster = agecat educat povlev nbabes_s race;
		run;

*/

