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

