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
	proc freq data=a; tables agebaby1; run;
	proc means; var datbaby1 cmbirth; run;
		
