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
		run;

*----------------------*
*---- DESCRIPTIVES ----*
*----------------------*;

	******************* FOR SAMPLE SIZE CALCULATIONS ********************;

	*race by age for sample size;
	proc freq data = a; tables agecat*race; run;

	title;

	*age at first live birth;
	proc means; var agefirstbirth; run;
	proc sgplot;
		histogram agefirstbirth;
		run;

	*age at first live birth for 35+;
	proc means; var agefirstbirth; where agecat > 4; run;
	proc sgplot;
		histogram agefirstbirth;
		where agecat > 4;
		title "age at first birth for women currently 35+";
		run;

	*income;
	proc means; var poverty; run;
	proc sgplot;
		histogram poverty;
		run;

	proc means; var poverty; where agecat > 4; run;
	proc sgplot;
		histogram poverty;
		where agecat > 4;
		run;
	/*proc print;
		var poverty agecat;
		where poverty > 450;
		run;

	proc freq;
		tables poverty;
		where poverty > 450;
		run;*/

	title "poverty for non-white respondents";
	proc means; var poverty; where race ne 2; run;
	proc sgplot;
		histogram poverty;
		where race ne 2;
		run;

	title "poverty for non-white respondents 35+";
	proc means; var poverty; where race ne 2 and agecat > 4; run;
	proc sgplot;
		histogram poverty;
		where race ne 2 and agecat > 4;
		run;

	*detouring a bit to look at whether how the relationship between age
	and some key variables is nonlinear;
	title "age at first birth by age";
	proc means; var agefirstbirth; by agecat; run;
	*yep, age at first birth differs by age group;

	title "completed education by age";
	proc freq; tables edu; by agecat; run;
	proc freq; tables agecat*edu; run;

	***************************************************************;

	*now looking at bc by age;
	proc freq data = a; tables agecat*bc / out=agecatxbc; run;

	*looking at method type by education;
	proc freq data = a; tables educat*bc; run;
	*need to change to degrees, not years of education;

	*does education affect whether a woman is sterilized, contracepting or not
	contracepting?;
	proc freq;
		tables ster*edu;
		run;
	*it appears to, so going to check whether it does after restricting to 
	women in the older age groups;
	proc freq;
		tables ster*edu;
		where agecat = 5 or agecat = 6;
		run;
	*proportions sterilized and using reversible contraception diverge widely
	as education increases, with far greater numbers using reversible contraception
	with higher levels of education;

	*so now i want to check the same distributions but look at them by age at 
	first birth;
	proc sort; by agebabycat; run;
	proc freq;
		tables ster*edu;
		where agecat = 5 or agecat = 6;
		by agebabycat;
		run;


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

