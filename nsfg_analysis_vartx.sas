*******************************************
************** DISSERTATION ***************
************* NSFG 2011-2015 **************
******************************************;

*This program is being created separately to do variable exploration and treatment work,
in order to separate the code and make the main file cleaner. The goal here is to eventually 
have a command from the main program to run this at the beginning. Therefore, this file does
not include code to pull in the datasets and formats, those can happen from 
"U:\Dissertation\nsfg_analysis_dissertation.sas";

*Lower-case labels are mine, upper-case labels are from NCHS;

*** Age;

	* breaking up into age groups first;
	data a; set a;
		if rscrage>14 and rscrage<20 then agecat = 1 ;
		if rscrage>19 and rscrage<25 then agecat = 2 ;
		if rscrage>24 and rscrage<30 then agecat = 3 ;
		if rscrage>29 and rscrage<35 then agecat = 4 ;
		if rscrage>34 and rscrage<40 then agecat = 5 ;
		if rscrage>39 and rscrage<45 then agecat = 6 ;
		label agecat="5yr age categories, 1=15-19, 6=40-44";
		run;	

*** Contraceptive Use;

	/*proc freq data=a; tables constat1; run;*/

	* creating a new constraceptive variable (bc) that is the same as constat1
	but sets people not at risk of unintended pregnancy to missing;
	data a; set a;
		bc = constat1;
		if constat1>29 and constat1<=41 then bc=.;
		label bc="bc method with not at risk if UIP set to missing";
		run;
		*note that postpartum is in this group, but is restricted to women less than
		2 months postpartum;

		/*proc freq; tables bc; run;*/

	* making a dichotomous variable for using bc or not, making two versions (nouse, bcyes) so 1/0 is logical;
	data a; set a;
		nouse = bc;
		if bc = 42 then nouse = 1;
		if bc < 42 and bc > 0 then nouse = 0;
		if nouse = 1 then bcyes = 0;
		if nouse = 0 then bcyes = 1;
		label nouse="at risk of UIP but not using contr = 1 (opposite of bcyes)";
		label bcyes="at risk of UIP and using any method = 1 (opposite of nouse)";
		run;
	
	* ster: sterilized, using non-sterilization contraception, not contracepting;
	data a; set a;
		if bc = 1 or bc = 2 or bc = 35 or bc = 36 or bc = 33 or bc = 34 or bc = 38
		then ster = 1;
		if bc ne 1 and bc ne 2 and bc ne 35 and bc ne 36 and bc ne 33 and bc ne 34 
		and bc ne 38 then ster =2;
		if bc = 42 then ster = 3;
		label ster="sterilized, using non-sterilization contraception, not contracepting";
		run;


	* creating conceptually appropriate method groups;
	data a; set a;
		effmeth = bc;
		if ster=1 then effmeth = 1;
		if bc=3 or bc=10 then effmeth = 2;
		if bc=5 or bc=6 or bc=7 or bc=8 then effmeth = 3;
		if bc=11 or bc=12 or bc=14 or bc=16 or bc=17 or bc=18 then effmeth = 4;
		if bc=19 or bc=20 then effmeth = 6;
		if bc=21 then effmeth = 7;
		if bc=9 or bc=22 then effmeth = .;
		if ster=3 then effmeth = 8;
		label effmeth="conceptually appropriate method groups";
		run;

	* creating a var with method groups and non-iup groups;
	data a; set a;
		allrepro = bc;
		if ster=1 then allrepro = 1;
		if bc=3 or bc=10 then allrepro = 2;
		if bc=5 or bc=6 or bc=7 or bc=8 then allrepro = 3;
		if bc=11 or bc=12 or bc=14 or bc=16 or bc=17 or bc=18 then allrepro = 4;
		if bc=19 or bc=20 then allrepro = 6;
		if bc=21 then allrepro = 7;
		if bc=9 or bc=22 then allrepro = .;
		if ster=3 then allrepro = 8;
		if constat1=30 then allrepro = 9;
		if constat1=31 then allrepro = 10;
		if constat1=32 then allrepro = 11;
		if constat1=33 or constat1=34 or constat1=35 or constat1=36 then allrepro = 12;
		if constat1=40 then allrepro = 13;
		if constat1=41 then allrepro = 14;
		label allrepro="all possible contracept or repro groups";
		run;


*** Subfecundity;

	/*proc freq data=a; tables fecund; run;
		*Recode specs and description of groups: 
		https://www.icpsr.umich.edu/icpsradmin/nsfg/variable/recode_spec/cycle8.1/fem/FECUND.pdf;
		*May be difficult to use because fecund = 1 will be fully collinear with sterilization
		as contraceptive use;

*** Age at first birth;

	/*proc freq data=a; tables agebaby1; run;
		*agebaby1 is categorical - trying to recreate the continuous below;
		proc means; var datbaby1 cmbirth; run;
		
		data a; set a; 
			agefirst = ((datbaby1-cmbirth)/12)*100; 
			run;
		
		proc means; var agefirst; run;
		proc print data = a (obs=15); var caseid agefirst agebaby1; run;
		*that worked, agefirst is the continuous var;
		*Recode specs:
		https://www.icpsr.umich.edu/icpsradmin/nsfg/variable/recode_spec/cycle8.1/fem/AGEBABY1.pdf;
		*commenting this out and making a nice data set for posterity;*/
			data a; set a;
				agefirst = (datbaby1-cmbirth)/12;
				label "continuous age at first birth";
				run; 

*** Education;

	/*proc freq data=a; tables dipged degrees hieduc; run;*/
		*hieduc is the most appropriate for this work, counts people in their terminal degree
		as appropriate or grades if lower, and does not combine associate and some college;

		*creating my own education variable here, edu;
			data a; set a;
				edu = hieduc;
				if hieduc = 5 then edu = 1;
				if hieduc = 6 then edu = 1;
				if hieduc = 7 then edu = 1;
				if hieduc = 8 then edu = 1;
				if hieduc = 9 then edu = 2;
				if hieduc = 10 then edu = 3;
				if hieduc = 11 then edu = 4;
				if hieduc = 12 then edu = 5;
				if hieduc = 13 then edu = 6;
				if hieduc = 14 then edu = 6;
				if hieduc = 15 then edu = 6;
				label edu = "education categories";
				run;

*** Race;

	proc freq; tables race; run;
		*it appears the raw variables used to create this are not available, which 
		won't work because i would like to have more granularity...;
		*Recode specs here: https://www.icpsr.umich.edu/icpsradmin/nsfg/variable/recode_spec/cycle8.1/fem/RACE.pdf;
		*they do have a separate hispanic origin variable;
		*Recode specs here: https://www.icpsr.umich.edu/icpsradmin/nsfg/variable/recode_spec/cycle8.1/fem/HISPANIC.pdf;

	proc freq; tables race*hispanic; run;
		*hispanic folks fall into all three of the race categories, the greatest percent
		being 'other';

	proc sgplot;
		scatter x=poverty y=race;
		run;

	proc sgplot;
		hbox poverty / category=race;
		run;

	proc sgplot;
		hbox poverty / category=hispanic;
		run;

	*still not sure about this. will need to figure out if there is any way to handle race better.
	i'm worried about misclassification problems because the 'other' category will be so 
	heterogeneous;

*** Birth Desires, Intention, Ambivalence - INCLUDES INDIVIDUAL AND JOINT WITH PARTNER;

	proc freq;
		tables
			rwant
			probwant
			pwant
			jintend
			jsureint
			jintendn
			jexpectl
			jexpects
			jintnext
			intend
			sureint
			intendn
			expectl
			expects
			intnext;
		run;

*** Income;

	/*proc freq; tables poverty; run;
	proc means; var poverty; run;
	proc sgplot; histogram poverty; run;
	proc print data=a (obs=20); var caseid poverty poverty_i totinc; format _all_ ; run;
	proc freq; tables poverty*agecat; run;
	proc freq; tables poverty; format _all_; run;*/
	*For now, poverty will need to be the variable. Need to talk to Ron about 
	whether to include it as a continuous or categorical. If considering it categorical
	with it's original groups, many of the groups get pretty small, 3 or 4 respondents;

*** 


****************************************
*** Age as continuous vs categorical ***
****************************************;

* Age and non-use;
	proc freq; tables nouse*rscrage / nofreq norow nopercent; run;

* Age and sterilization;
	proc freq; tables rscrage*ster / nofreq nocol nopercent; run;

* Age and conceptually appropriate contraceptive groups;

	proc freq; tables rscrage*effmeth / nofreq nocol nopercent; run;

* Age and all contraceptive/reproductive status groups;
	* Could be used for stacked bar charts;

	proc freq; tables rscrage*allrepro / nofreq nocol nopercent; run;

	proc freq; tables agecat*allrepro / nofreq nocol nopercent; run;


		
		
