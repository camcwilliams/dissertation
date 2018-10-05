*******************************************
************** DISSERTATION ***************
************* NSFG 2011-2015 **************
******************************************;

*This program is being created separately to do variable exploration and treatment work,
in order to separate the code and make the main file cleaner. The goal here is to eventually 
have a command from the main program to run this at the beginning. Therefore, this file does
not include code to pull in the datasets and formats, those can happen from 
"U:\Dissertation\nsfg_analysis_dissertation.sas";

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

	* creating a new constraceptive variable to remove people not at risk of unintended pregnancy;
	data a; set a;
		bc = constat1;
		if constat1>28 and constat1<=41 then bc=.;
		run;

	* making a dichotomous variable for using bc or not;
	data a; set a;
		nouse = bc;
		if bc = 42 then nouse = 1;
		if bc < 42 and bc > 0 then nouse = 0;
		if nouse = 1 then bcyes = 0;
		if nouse = 0 then bcyes = 1;
		run;
	/*proc freq; tables nouse; run;
	proc sort; by agecat; run;
	proc freq; tables nouse; by agecat; run;*/
	
	* sterilized, contracepting, not contracepting;
	data a; set a;
		if bc = 1 or bc = 2 or bc = 35 or bc = 36 or bc = 33 or bc = 34 or bc = 38
		then ster = 1;
		if bc ne 1 and bc ne 2 and bc ne 35 and bc ne 36 and bc ne 33 and bc ne 34 
		and bc ne 38 then ster =2;
		if bc = 42 then ster = 3;
		run;

	/* among not sterilized, using an effective method;
	data a; set a;
		effmeth = bc;
		if bc=1 or bc=2 or bc then effmeth = 1;
		if bc=42 then effmeth = .;
		run;
	*/

*** Subfecundity;

	proc freq data=a; tables fecund; run;
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
			


		
		
