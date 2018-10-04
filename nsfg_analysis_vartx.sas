*******************************************
************** DISSERTATION ***************
************* NSFG 2011-2015 **************
******************************************;

*This program is being created separately to do variable exploration and treatment work,
in order to separate the code and make the main file cleaner. The goal here is to eventually 
have a command from the main program to run this at the beginning. Therefore, this file does
not include code to pull in the datasets and formats, those can happen from 
"U:\Dissertation\nsfg_analysis_dissertation.sas";

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

*** 
			


		
		
