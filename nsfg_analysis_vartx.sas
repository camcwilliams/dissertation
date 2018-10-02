*******************************************
************** DISSERTATION ***************
************* NSFG 2011-2015 **************
******************************************;

*This program is being created separately to do variable exploration and treatment work,
in order to separate the code and make the main file cleaner. The goal here is to eventually 
have a command from the main program to run this at the beginning. Therefore, this file does
not include code to pull in the datasets and formats, those can happen from 
"U:\Dissertation\nsfg_analysis_dissertation.sas";

* Subfecundity;
	proc freq data=a; tables fecund; run;
		*Recode specs and description of groups: 
		https://www.icpsr.umich.edu/icpsradmin/nsfg/variable/recode_spec/cycle8.1/fem/FECUND.pdf;
		*May be difficult to use because fecund = 1 will be fully collinear with sterilization
		as contraceptive use;

* Age at first birth;
	/*proc freq data=a; tables agebaby1; run;
		*agebaby1 is categorical - trying to recreate the continuous below;
		proc means; var datbaby1 cmbirth; run;
		
		data a; set a; 
			agefirst = ((datbaby1-cmbirth)/12)*100; 
			run;
		
		proc means; var agefirst; run;
		proc print data = a (obs=15); var caseid agefirst agebaby1; run;
		*that worked, agefirst is the continuous var;
		*commenting this out and making a nice data set for posterity;*/
	data a; set a;
		agefirst = (datbaby1-cmbirth)/12;
		run; 



		
		
