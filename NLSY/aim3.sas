**********************************

AIM 3 ANALYSIS: TUBAL LIGATION BY AGE, LONGITUDINAL
USING NLSY

**********************************;

*Running separate programs for each dataset, haven't been able to solve the formats problem with creating a permanent
dataset, I think the name literals are the culprit;

%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\nlsy.sas";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\nlsy_addster.sas";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\nlsy_addagebirth.sas";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\nlsy_famsize.sas";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\nlsy_educ.sas";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\nlsy_edu2.sas";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\nlsy_ins.sas";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\new_eduthree.sas";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\nlsy_samp.sas";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\new_menopause.sas";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\nlsy_custom_weights.sas";


*** Merge datasets created using NLSY programs;
data work.nlsy;
	merge new_data new_ster add_ageb add_famsize new_educ new_edutwo new_ins new_eduthree 
	nlsy_samp new_menopause; 
	by 'CASEID_1979'n; 
	run;
data a; set nlsy; run;

*** Removing males;
data a; set a;
	if 'sample_sex_1979'n = 1 then delete;
	run;

*** Renaming caseid;
data a; set a;
	rename
	'CASEID_1979'n = caseid;
	run;

*** Renaming sampling weight and dividing by 100 to get actual # representing (there are two
	implied decimal points in sampling weight;
data a; set a;
	weight = 'sampweight_1982'n/100;
	run;

*** Listwise deletion of individuals with missing interviews;

	*first need to recode age, using that as flag;
	data a; set a;
		rename
		'ageatint_1982'n=age82
		'ageatint_1984'n=age84
		'ageatint_1985'n=age85
		'ageatint_1986'n=age86
		'ageatint_1988'n=age88
		'ageatint_1990'n=age90
		'ageatint_1992'n=age92
		'ageatint_1994'n=age94
		'ageatint_1996'n=age96
		'ageatint_1998'n=age98
		'ageatint_2000'n=age00
		'ageatint_2002'n=age02
		'ageatint_2004'n=age04
		'ageatint_2006'n=age06
		'ageatint_2008'n=age08
		'ageatint_2010'n=age10
		'ageatint_2012'n=age12
		'ageatint_2014'n=age14
		'ageatint_2016'n=age16;
		run;

*making a missing dataset to describe in paper;

data missing; set a;
	if age82 = .N then miss=1;
	if age84 = .N then miss=1;
	if age85 = .N then miss=1;
	if age86 = .N then miss=1;
	if age88 = .N then miss=1;
	if age90 = .N then miss=1;
	if age92 = .N then miss=1;
	if age94 = .N then miss=1;
	if age96 = .N then miss=1;
	if age98 = .N then miss=1;
	if age00 = .N then miss=1;
	if age02 = .N then miss=1;
	if age04 = .N then miss=1;
	if age06 = .N then miss=1;
	if age08 = .N then miss=1;
	if age10 = .N then miss=1;
	if age12 = .N then miss=1;
	if age14 = .N then miss=1;
	if age16 = .N then miss=1;
	run;

data a; set a;
	if age82 = .N then delete;
	if age84 = .N then delete;
	if age85 = .N then delete;
	if age86 = .N then delete;
	if age88 = .N then delete;
	if age90 = .N then delete;
	if age92 = .N then delete;
	if age94 = .N then delete;
	if age96 = .N then delete;
	if age98 = .N then delete;
	if age00 = .N then delete;
	if age02 = .N then delete;
	if age04 = .N then delete;
	if age06 = .N then delete;
	if age08 = .N then delete;
	if age10 = .N then delete;
	if age12 = .N then delete;
	if age14 = .N then delete;
	if age16 = .N then delete;
	run;

	*checked and deleted code for check;

	*the listwise deletion removes so many people, but I think it's the only way in this case;

* TUBAL;

* Identified tubal vars and checked them, code is in previous program - basically
	if a person has not used a new method in the previous year they have a valid
	skip, so needed to do some recodes. Also, question changed in 2002, so did some
	checking to see if there was a spike. Also, some people reported not using a 
	method after reporting using tubal in a previous year, so need to account for that;

*** Changing vars so I can check if there is a spike in reported tubals in 2002;

*Creating easier to use tubal vars;	

*Making 1982-2002 first since question structure changed thereafter;
data a; set a;
	tub82 = 0; if 'Q9-65~000009_1982'n = 11 then tub82 = 1;
	tub84 = 0;	if age84 = .N then tub84 = .;	if 'Q9-65F~000009_1984'n = 9 then tub84 = 1;
	tub85 = 0;	if age85 = .N then tub85 = .;	if 'Q9-65F~000009_1985'n = 9 then tub85 = 1;
	tub86 = 0;	if age86 = .N then tub86 = .;	if 'Q9-65F~000009_1986'n = 9 then tub86 = 1;
	tub88 = 0;	if age88 = .N then tub88 = .;	if 'Q9-65F~000009_1988'n = 9 then tub88 = 1;
	tub90 = 0;	if age90 = .N then tub90 = .;	if 'Q9-65F~000009_1990'n = 9 then tub90 = 1;
	tub92 = 0;	if age92 = .N then tub92 = .;	if 'Q9-65~000009_1992'n = 9 then tub92 = 1;
	tub94 = 0;	if age94 = .N then tub94 = .;	if 'Q9-65~000009_1994'n = 9 then tub94 = 1;
	tub96 = 0;	if age96 = .N then tub96 = .;	if 'Q9-65~000009_1996'n = 9 then tub96 = 1;
	tub98 = 0;	if age98 = .N then tub98 = .;	if 'Q9-65~000009_1998'n = 1 then tub98 = 1;
	tub00 = 0;	if age00 = .N then tub00 = .;	if 'Q9-65~000009_2000'n = 1 then tub00 = 1;
	/* question structure changed in 2002 */
	run;

	*Checked and deleted check code;


*Tackling 2002-2016;

*Setting 'tub' variable equal to the *new* tubals for now;
data a; set a;
	tub02 = 0;
	if 'Q9-64GC_2002'n = 1 or 'Q9-64GC_2002'n = 3 then tub02 = 1;
	if age02 = .N then tub02 = .;
	tub04 = 0;	if age04 = .N then tub04 = .;	if 'Q9-64GC_2004'n = 1 or 'Q9-64GC_2004'n = 3 then tub04 = 1;
	tub06 = 0;	if age06 = .N then tub06 = .;	if 'Q9-64GC_2006'n = 1 or 'Q9-64GC_2006'n = 3 then tub06 = 1;
	tub08 = 0;	if age08 = .N then tub08 = .;	if 'Q9-64GC_2008'n = 1 or 'Q9-64GC_2008'n = 3 then tub08 = 1;
	tub10 = 0;	if age10 = .N then tub10 = .;	if 'Q9-64GC_2010'n = 1 or 'Q9-64GC_2010'n = 3 then tub10 = 1;
	tub12 = 0;	if age12 = .N then tub12 = .;	if 'Q9-64GC_2012'n = 1 or 'Q9-64GC_2012'n = 3 then tub12 = 1;
	tub14 = 0;	if age14 = .N then tub14 = .;	if 'Q9-64GC_2014'n = 1 or 'Q9-64GC_2014'n = 3 then tub14 = 1;
	tub16 = 0;	if age16 = .N then tub16 = .;	if 'Q9-64GC_2016'n = 1 or 'Q9-64GC_2016'n = 3 then tub16 = 1;
	run;


*Changing tub vars to include ever previously reporting tubal;

data a; set a;
	if tub82 = 1 then tub84 = 1;
	if tub84 = 1 then tub85 = 1;
	if tub85 = 1 then tub86 = 1;
	if tub86 = 1 then tub88 = 1;
	if tub88 = 1 then tub90 = 1;
	if tub90 = 1 then tub92 = 1;
	if tub92 = 1 then tub94 = 1;
	if tub94 = 1 then tub96 = 1;
	if tub96 = 1 then tub98 = 1;
	if tub98 = 1 then tub00 = 1;
	if tub00 = 1 then tub02 = 1;
	if tub02 = 1 then tub04 = 1;
	if tub04 = 1 then tub06 = 1;
	if tub06 = 1 then tub08 = 1;
	if tub08 = 1 then tub10 = 1;
	if tub10 = 1 then tub12 = 1;
	if tub12 = 1 then tub14 = 1;
	if tub14 = 1 then tub16 = 1;
	run;

	*checked and deleted check code;

* GRAPHING SIMPLE TUBAL PERCENTS;

*turning on trace to save ods graphs;
ods trace on;
ods graphics on / reset=index imagename="ster";
ods listing gpath = "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\graphs_ster";

*creating, processing new dataset of tubal frequencies;
proc freq data=a; tables tub:; 
	ods output OneWayFreqs = t; run;

	proc print data=t; run;

	data t; set t;
		if Percent > 50 then delete;
		run;

	title 'ever tubal by survey year';
	proc sgplot data=t;
		scatter x=Table y=Percent;
		run;

	*does not appear to have a sharp change at 2002;

	title;

*menopause age;

data a; set a;
	meno = 'Q11-GENHLTH_M2A_2016'n+1;
	run;

* NUMBER KIDS (NO PARITY VAR THAT I KNOW OF);

data a; set a;
	rename
	'numkid82_1982'n = numkid82
	'numkid84_1984'n = numkid84
	'numkid85_1985'n = numkid85
	'numkid86_1986'n = numkid86
	'numkid88_1988'n = numkid88
	'numkid90_1990'n = numkid90
	'numkid92_1992'n = numkid92
	'numkid94_1994'n = numkid94
	'numkid96_1996'n = numkid96
	'numkid98_1998'n = numkid98
	'numkid00_2000'n = numkid00
	'numkid02_2002'n = numkid02
	'numkid04_2004'n = numkid04
	'numkid06_2006'n = numkid06
	'numkid08_2008'n = numkid08
	'numkid10_2010'n = numkid10
	'numkid12_2012'n = numkid12
	'numkid14_2014'n = numkid14
	'numkid16_2016'n = numkid16;
	run;

	*checked and deleted check code;

	/*transforming to make sure mean increases each year;
	proc means data=a; var numkid:; 
	ods output summary = n; run;

	proc print data=n; run;

	proc transpose data=n out =n_tran;
		id vname:;
		run;
		proc print data=n_tran; run;

	data n_tran; set n_tran;
	if _label_ ne "Mean" then delete;
	if _name_ = numkid_xrnd_mean then delete;
	rename numkid82NUMKID83_1983numkid84num = numkid_mean;
	run;

	title 'mean # children born by survey year';
	proc sgplot data=n_tran;
		scatter x=_name_ y=numkid_mean;
		run;
	*/


* AGE AT FIRST BIRTH;

	*### Commenting out for now - between the discordant age at first birth between
	survey years, and the difficulty in using this in a clog-log model, I'm not currently
	planning to use age at first birth. I think using # kids at current age would
	be both more impactful and easier mathematically;

	/*no first births in 420 respondents, which is same # as had 0 births
		in numkids;

	*checking to make sure no individuals have different responses in different survey years;
	proc compare data=a;
		var 'age1b16_2016'n;
		with 'age1b00_2000'n;
		id caseid;
		run;

		*all differences are valid;

	*appears there was a numbering change at some point, need to check values;

	proc freq data=a;
		tables age1b:;
		format _all_;
		run;

		*values are whole numbers, formats are categories;

	*if values are categories then a couple of differences don't make sense;

	proc print data=a;
		var caseid age1b:;
		where caseid = 4176 or caseid = 6383;
		format _all_;
		run;

		*there are respondents who have discordant age at first birth variables for different years;
		*will need to come back to this, for now using age at first birth assigned to most recent
		survey year;

	data a; set a;
		rename
		AGE1B16_2016 = age1b;
		run;*/


* RACE;

data a; set a;
	rename
	SAMPLE_RACE_78SCRN = race;
	run;


* INCOME;

data a; set a;
	rename
	tnfi_trunc_1979 = income79
	tnfi_trunc_1982 = income82
	tnfi_trunc_1984 = income84
	tnfi_trunc_1985 = income85
	tnfi_trunc_1986 = income86
	tnfi_trunc_1988 = income88
	tnfi_trunc_1990 = income90
	tnfi_trunc_1992 = income92
	tnfi_trunc_1994 = income94
	tnfi_trunc_1996 = income96
	tnfi_trunc_1998 = income98
	tnfi_trunc_2000 = income00
	tnfi_trunc_2002 = income02
	tnfi_trunc_2004 = income04
	tnfi_trunc_2006 = income06
	tnfi_trunc_2008 = income08
	tnfi_trunc_2010 = income10
	tnfi_trunc_2012 = income12
	tnfi_trunc_2014 = income14
	tnfi_trunc_2016 = income16;
	run;

	*Commenting out code for determining highest income groups;

	/*
	proc means data=a; var income:; 
	ods output summary = i; run;

	proc print data=i; run;

	proc transpose data=i out =i_tran;
		id vname:;
		run;
		proc print data=i_tran; run;

	data i_tran; set i_tran;
	if _label_ ne "Mean" then delete;
	if _name_ = 'INCOME-24_1980_Mean'n then delete;
	if _name_ = 'INCOME-24_1981_Mean'n then delete;
	if _name_ = 'INCOME-24_1982_Mean'n then delete;
	rename 'INCOME-24_1980INCOME-24_1981INCO'n = income_mean;
	run;

	title 'mean family income by survey year';
	proc sgplot data=i_tran;
		scatter x=_name_ y=income_mean;
		run;

	* there are jumps at 92 and 96, there may be outliers;

	* checking plots;

	proc sgplot data=a;
		vbox income82;
		format _all_;
		run;

		proc sgplot data=a;
		vbox income90;
		format _all_;
		run;

		proc sgplot data=a;
		vbox income92;
		format _all_;
		run;

		proc sgplot data=a;
		vbox income96;
		format _all_;
		run;

		proc sgplot data=a;
		vbox income00;
		format _all_;
		run;

	proc sgplot data=a;
		histogram income82;
		format _all_;
		run;

	*there is a top-coded group that the average of the highest income variables, I'm guessing
	for privacy reasons, the documentation isn't super clear. There are notes on a couple of 
	years that there are suspiciously high values for a few respondents and those are included
	in the average (see codebook note for TNFI_TRUNC_1992 for example). I think to be safe I 
	should do some winsorizing;

	*I'm going to winsorize all years to the top continuous value, i.e. the last value that's
		not the averaged top-coded group;

	proc freq data=a;
		tables income82;
		where income82 > 20000;
		format _all_;
		run;	

	*I see some are already coded that way? This confirms winsorizing all years is better than
		just doing the years with weird outliers;


	*Identifying highest and second-highest income values for each survey year;
	proc freq data=a;
		tables income84;
		where income84 > 60000;
		format _all_;
		run;

	%let income = income82	income84	income85	income86	income88	income90	
	income92	income94	income96	income98	income00	income02	income04	
	income06	income08	income10	income12	income14	income16;
	
	%macro income;
	%let i=1;
	%do %until(not %length(%scan(&income,&i)));
	proc freq data=a;
		tables %scan(&income,&i);
		where %scan(&income,&i) > 75000;
		format _all_;
		title %scan(&income,&i);
		ods output OneWayFreqs = %scan(&income,&i);
		run;
	%let i=%eval(&i+1);
	%end;
	%mend;

	%income;

	*/

	/*proc sql;
		create table hi_inc as
		select caseid, max(income82) from a
		group by caseid;
		quit;*/

	*Winsorizing(ish) and adding indicator variable to include the regression discontinuity
	to the model;

	data a; set a;
		incwin79 = income79;
		incwin88 = income88;
		incwin90 = income90;
		incwin92 = income92;
		incwin94 = income94;
		incwin96 = income96;
		incwin98 = income98;
		incwin00 = income00;
		incwin02 = income02;
		incwin04 = income04;
		incwin06 = income06;
		incwin08 = income08;
		incwin10 = income10;
		incwin12 = income12;
		incwin14 = income14;
		incwin16 = income16;
		incind16 = 0;
		incind14 = 0;
		incind12 = 0;
		incind10 = 0;
		incind08 = 0;
		incind06 = 0;
		incind04 = 0;
		incind02 = 0;
		incind00 = 0;
		incind98 = 0;
		incind96 = 0;
		incind94 = 0;
		incind92 = 0;
		incind90 = 0;
		incind88 = 0;
		incind86 = 0;
		incind84 = 0;
		incind82 = 0;	
		if income16 = 922631 then do; incwin16 = 350001; incind16 = 1; end;
		if income14 = 595986 then do; incwin14 = 308001; incind14 = 1; end;
		if income12 = 497763 then do; incwin12 = 290000; incind12 = 1; end;
		if income10 = 440692 then do; incwin10 = 268001; incind10 = 1; end;
		if income08 = 454737 then do; incwin08 = 278001; incind08 = 1; end;
		if income06 = 479983 then do; incwin06 = 273001; incind06 = 1; end;
		if income04 = 408473 then do; incwin04 = 250001; incind04 = 1; end;
		if income02 = 390662 then do; incwin02 = 224001; incind02 = 1; end;
		if income00 = 332808 then do; incwin00 = 182001; incind00 = 1; end;
		if income98 = 244343 then do; incwin98 = 161001; incind98 = 1; end;
		if income96 = 974100 then do; incwin96 = 160085; incind96 = 1; end;
		if income94 = 189918 then do; incwin94 = 155741; incind94 = 1; end;
		if income92 = 839078 then do; incwin92 = 100001; incind92 = 1; end;
		if income90 = 146942 then do; incwin90 = 99501; incind90 = 1; end;
		if income88 = 100001 then do; incwin88 = 99301; incind88 = 1; end;
		incwin86 = income86;
		incwin85 = income85;
		incwin84 = income84;
		incwin82 = income82;
		run;

		*checked and deleted check code;



	*Proc reg keeps running for some reason, so commenting out for now;
	/*
	proc reg data=inc;
		model inc79_nonmiss82 = inc79_miss82;
		run;
	*/

	/* Imputation phase;
	proc mi data=a nimpute=20 out=mi_mvn seed=54321;
	var;*/

	*Comfortable with MAR approach;

	

	* FAMILY SIZE;

	/*
	data a; set a;
		pov = .;
		pov = ((famsize_1982 - 1)*1380)+4310;
		label pov = "FPL for R's family size";
		run;

		proc freq data=a; tables pov; run;

	data a; set a;
		povlev = income82/pov;
		label povlev = "proportion of FPL for survey year";
		run;

		proc freq data=a; tables povlev; run;

		proc means data=a; var povlev; where povlev <= 1.38; run;
		proc means data=a; var povlev; where povlev > 1.38; run;
	*/

data a; set a;
	pov82 = ((famsize_1982 - 1)*1380)+4310; label pov82 = 'FPL for Rs family size 1982';
	pov84 = ((famsize_1984 - 1)*1540)+4680; label pov84 = 'FPL for Rs family size 1984';
	pov85 = ((famsize_1985 - 1)*1680)+4860; label pov85 = 'FPL for Rs family size 1985';
	pov86 = ((famsize_1986 - 1)*1800)+5250; label pov86 = 'FPL for Rs family size 1986';
	pov88 = ((famsize_1988 - 1)*1900)+5500; label pov88 = 'FPL for Rs family size 1988';
	pov90 = ((famsize_1990 - 1)*2040)+5980; label pov90 = 'FPL for Rs family size 1990';
	pov92 = ((famsize_1992 - 1)*2260)+6620; label pov92 = 'FPL for Rs family size 1992';
	pov94 = ((famsize_1994 - 1)*2460)+6970; label pov94 = 'FPL for Rs family size 1994';
	pov96 = ((famsize_1996 - 1)*2560)+7470; label pov96 = 'FPL for Rs family size 1996';
	pov98 = ((famsize_1998 - 1)*2720)+7890; label pov98 = 'FPL for Rs family size 1998';
	pov00 = ((famsize_2000 - 1)*2820)+8240; label pov00 = 'FPL for Rs family size 2000';
	pov02 = ((famsize_2002 - 1)*3020)+8590; label pov02 = 'FPL for Rs family size 2002';
	pov04 = ((famsize_2004 - 1)*3140)+8980; label pov04 = 'FPL for Rs family size 2004';
	pov06 = ((famsize_2006 - 1)*3260)+9570; label pov06 = 'FPL for Rs family size 2006';
	pov08 = ((famsize_2008 - 1)*3480)+10210; label pov08 = 'FPL for Rs family size 2008';
	pov10 = ((famsize_2010 - 1)*3740)+10830; label pov10 = 'FPL for Rs family size 2010';
	pov12 = ((famsize_2012 - 1)*3820)+10890; label pov12 = 'FPL for Rs family size 2012';
	pov14 = ((famsize_2014 - 1)*4060)+11670; label pov14 = 'FPL for Rs family size 2014';
	pov16 = ((famsize_2016 - 1)*4160)+11770; label pov16 = 'FPL for Rs family size 2016';
	run;

	data a; set a;
		fpl82 = incwin82/pov82; label fpl82 = 'Rs HH % fpl 1982';
		fpl84 = incwin84/pov84; label fpl84 = 'Rs HH % fpl 1984';
		fpl85 = incwin85/pov85; label fpl85 = 'Rs HH % fpl 1985';
		fpl86 = incwin86/pov86; label fpl86 = 'Rs HH % fpl 1986';
		fpl88 = incwin88/pov88; label fpl88 = 'Rs HH % fpl 1988';
		fpl90 = incwin90/pov90; label fpl90 = 'Rs HH % fpl 1990';
		fpl92 = incwin92/pov92; label fpl92 = 'Rs HH % fpl 1992';
		fpl94 = incwin94/pov94; label fpl94 = 'Rs HH % fpl 1994';
		fpl96 = incwin96/pov96; label fpl96 = 'Rs HH % fpl 1996';
		fpl98 = incwin98/pov98; label fpl98 = 'Rs HH % fpl 1998';
		fpl00 = incwin00/pov00; label fpl00 = 'Rs HH % fpl 2000';
		fpl02 = incwin02/pov02; label fpl02 = 'Rs HH % fpl 2002';
		fpl04 = incwin04/pov04; label fpl04 = 'Rs HH % fpl 2004';
		fpl06 = incwin06/pov06; label fpl06 = 'Rs HH % fpl 2006';
		fpl08 = incwin08/pov08; label fpl08 = 'Rs HH % fpl 2008';
		fpl10 = incwin10/pov10; label fpl10 = 'Rs HH % fpl 2010';
		fpl12 = incwin12/pov12; label fpl12 = 'Rs HH % fpl 2012';
		fpl14 = incwin14/pov14; label fpl14 = 'Rs HH % fpl 2014';
		fpl16 = incwin16/pov16; label fpl16 = 'Rs HH % fpl 2016';
		run;

	*checked and deleted check code;

/*
	*** Working on missingness;

	ods html close; ods html;
	proc contents data=a; run;

	proc means data=a missing; var income:; run;

	proc print data=a (obs=50); var income:; run;

	proc print data=a (obs=50); var income:; where income88 = .I; run;

	proc freq data=a; 
		tables income: / missing; 
		ods output onewayfreqs=incmissing; run;
		run;

	proc print data=incmissing; run;

	data incmissing; set incmissing;
		if table = "Table INCOME-24_1980" or table = "Table INCOME-24_1981"
		or table = "Table INCOME-24_1982"
		then delete;
		run;

	data incmissing; set incmissing;
		val = income82;
		if val = . then val = income84;
		if val = . then val = income85;
		if val = . then val = income86;
		if val = . then val = income88;
		if val = . Then val = income90;
		if val = . Then val = income92;
		if val = . Then val = income94;
		if val = . Then val = income96;
		if val = . Then val = income98;
		if val = . Then val = income00;
		if val = . Then val = income02;
		if val = . Then val = income04;
		if val = . Then val = income06;
		if val = . Then val = income08;
		if val = . Then val = income10;
		if val = . Then val = income12;
		if val = . Then val = income14;
		if val = . Then val = income16;
		run;

	data incmissing; set incmissing;
		if val = .D then miss = 1;
		if val = .I then miss = 2;
		if val = .N then miss = 3;
		if val = .R then miss = 4;
		if val = 0 then miss = val;
		run;

	data incmissing; set incmissing;
		keep val miss frequency percent cumfrequency cumpercent table;
		run;

	proc format;
		value miss
			1 = "Don't Know"
			2 = "Invalid Missing"
			3 = "Non-Interview"
			4 = "Refused"
			0 = "No Income";
		run;

		data incmissing; set incmissing;
			format miss miss.;
			run;

	data incmissing; set incmissing;
		year = substr(table,7,8);
		run;
		
	
	proc sgplot data=incmissing;
		series x=year y=percent / group=miss datalabel;
		where miss ne . ;
		run;

	proc print data=a (obs=50);
		var income:;
		format income: _all_;
		where income82 = .D;
		run;

	*nice table to assess missingness patterns;
	proc mi data=a nimpute=0;
		var incwin82 incwin90 incwin16 educ82 educ90 educ16 numkid82 numkid90 numkid16;
		ods select misspattern;
		run;

	* In order to appropriately impute, you need to know the form of the final model,
	including interactions and transformations (%fpl comes to mind), so I am going
	to move forward with model-building and come back to imputation, see this for 
	good guidance:
	https://stats.idre.ucla.edu/sas/seminars/multiple-imputation-in-sas/mi_new_1/;
*/

* EDUCATION;

	*need to investigate Q3-10D_2008;

* After discussing with Ron on 6/7/19, because of the differences in 
question structure AND the difficulty of understanding how a bachelors
degree affects 25 year olds and 40 year olds differently, it's best
just to use years of completed education as a linear variable;

	/*
	proc freq data=a; tables 'Q3-10B_1998'n; run;
	proc freq data=a; tables 'DEGREE-1A_1_1980'n; run;
	proc freq data=a; tables degree:; run;
	*/

	/* Working with hgcrev var;
		proc means data=a; var hgc:; run;
		proc means data=a; var hgcrev:; run;
		proc freq data=a; tables hgcrev:; run;
		proc freq data=a; tables 'hgcrev82_1982'n / missing; run;
		proc freq data=a; tables 'hgcrev82_1982'n; format _all_; run;*/

* Renaming for ease of use;
	data a; set a;
	rename
	'HGCREV79_1979'n = educ79
	'HGCREV80_1980'n = educ80
	'HGCREV81_1981'n = educ81
	'HGCREV82_1982'n = educ82
	'HGCREV83_1983'n = educ83
	'HGCREV84_1984'n = educ84
	'HGCREV85_1985'n = educ85
	'HGCREV86_1986'n = educ86
	'HGCREV87_1987'n = educ87
	'HGCREV88_1988'n = educ88
	'HGCREV89_1989'n = educ89
	'HGCREV90_1990'n = educ90
	'HGCREV91_1991'n = educ91
	'HGCREV92_1992'n = educ92
	'HGCREV93_1993'n = educ93
	'HGCREV94_1994'n = educ94
	'HGCREV96_1996'n = educ96
	'HGCREV98_1998'n = educ98
	'HGCREV00_2000'n = educ00
	'HGCREV02_2002'n = educ02
	'HGCREV04_2004'n = educ04
	'HGCREV06_2006'n = educ06
	'HGCREV08_2008'n = educ08
	'HGCREV10_2010'n = educ10
	'HGCREV12_2012'n = educ12
	'HGCREV14_2014'n = educ14
	'HGCREV16_2016'n = educ16;
	run;
	
	/*
	*checking on invalid missings;
	proc print data=a;
		var caseid educ:;
		where
			educ06 = .I or
			educ79 = .I or
			educ80 = .I or
			educ81 = .I or
			educ82 = .I or
			educ83 = .I or
			educ84 = .I or
			educ85 = .I or
			educ86 = .I or
			educ87 = .I or
			educ88 = .I or
			educ89 = .I or
			educ90 = .I or
			educ91 = .I or
			educ92 = .I or
			educ93 = .I or
			educ94 = .I or
			educ96 = .I or
			educ98 = .I or
			educ00 = .I or
			educ02 = .I or
			educ04 = .I or
			educ08 = .I or
			educ10 = .I or
			educ12 = .I or
			educ14 = .I or
			educ16 = .I;
		run;

	*creating a flag for any missing education variable;
	data a; set a;
		if educ06 = .I or
			educ79 = .I or
			educ80 = .I or
			educ81 = .I or
			educ82 = .I or
			educ83 = .I or
			educ84 = .I or
			educ85 = .I or
			educ86 = .I or
			educ87 = .I or
			educ88 = .I or
			educ89 = .I or
			educ90 = .I or
			educ91 = .I or
			educ92 = .I or
			educ93 = .I or
			educ94 = .I or
			educ96 = .I or
			educ98 = .I or
			educ00 = .I or
			educ02 = .I or
			educ04 = .I or
			educ08 = .I or
			educ10 = .I or
			educ12 = .I or
			educ14 = .I or
			educ16 = .I
		then educ_miss = 1;
		run;

	*/

	*can use an array to create a flag for having any missing education data, but subsetting
		with where command hardcoded was faster;

	*many can be easily recoded because they didn't change completed education in the years
	before and after, doing that here;

	data a; set a;
		array educ (26)
		educ80	educ81	educ82	educ83	educ84	educ85	educ86	educ87	educ88	
		educ89	educ90	educ91	educ92	educ93	educ94	educ96	educ98	educ00	educ02	educ04	
		educ06 educ08	educ10	educ12	educ14	educ16;
		do i = 1 to 26;
		if educ(i) = .I and educ(i-1) = educ(i+1) then educ(i) = educ(i-1);
		end;
		run;

		/*proc print data=a;
			var caseid educ81 educ82 educ83;
			where caseid = 1766 or caseid = 1778 or caseid = 4683 or caseid = 6282;
			run;

		proc print data=a;
			var caseid educ:;
			where educ_miss = 1;
			run;*/

	*then there are some who can be confidently recoded despite having 2 or more years of
		invalid missings (i realize these can probably all be done in one program);

	data a; set a;
		array educ (26)
		educ80	educ81	educ82	educ83	educ84	educ85	educ86	educ87	educ88	
		educ89	educ90	educ91	educ92	educ93	educ94	educ96	educ98	educ00	educ02	educ04	
		educ06 educ08	educ10	educ12	educ14	educ16;
		do i = 1 to 26;
		if educ(i) = .I and educ(i-1) = educ(i+2) then educ(i) = educ(i-1);
		if educ(i) = .I and educ(i-1) = educ(i+3) then educ(i) = educ(i-1);
		if educ(i) = .I and educ(i-1) = educ(i+4) then educ(i) = educ(i-1);
		if educ(i) = .I and educ(i-1) = educ(i+6) then educ(i) = educ(i-1);
		if educ(i) = .I and educ(i-1) = educ(i+1) then educ(i) = educ(i-1);
		end;
		run;

	*there are two individuals who have an invalid missing but there is a logical response
	e.g. 8th grade in 1980 and 10th grade in 1982, I feel comfortable changing those;

	data a; set a;
		if caseid = 6718 then educ81 = 9;
		if caseid = 7394 then educ82 = 12;
		run;

	/*
	*the remaining 16 have invalid missings where completed grades increased in the subsequent
		interview;

	proc print data=z;
		var caseid xedu80 educ80 xedu82 educ82 xedu84 educ84 xedu85 educ85 xedu86 educ86 xedu88 
		educ88 xedu90 educ90 xedu92 educ92;
		where
			educ80 = .I or
			educ81 = .I or
			educ82 = .I or
			educ83 = .I or
			educ84 = .I or
			educ85 = .I or
			educ86 = .I or
			educ87 = .I or
			educ88 = .I or
			educ89 = .I or
			educ90 = .I or
			educ91 = .I or
			educ92 = .I;
		run;

	proc print data=z;
		var caseid educ80	educ81	educ82	educ83	educ84	educ85	educ86	educ87	educ88	
		educ89	educ90	educ91	educ92;
		where 
		educ80 = .I or
			educ81 = .I or
			educ82 = .I or
			educ83 = .I or
			educ84 = .I or
			educ85 = .I or
			educ86 = .I or
			educ87 = .I or
			educ88 = .I or
			educ89 = .I or
			educ90 = .I or
			educ91 = .I or
			educ92 = .I;
		run;

	*After reviewing the raw vars as well as the hcg_rev vars, I don't feel comfortable assigning
		education levels to the remaining respondents, going to leave them as missing for now;
	*Could assume they're increasing in 1 year increments and leveling off, but not ready to do
		that just yet;

	*/

* MARITAL STATUS;

*marstat variables groups are good as-is so just renaming;
data a; set a;
	rename
	'MARSTAT-KEY_1979'n = mar79
	'MARSTAT-KEY_1980'n = mar80
	'MARSTAT-KEY_1981'n = mar81
	'MARSTAT-KEY_1982'n = mar82
	'MARSTAT-KEY_1983'n = mar83
	'MARSTAT-KEY_1984'n = mar84
	'MARSTAT-KEY_1985'n = mar85
	'MARSTAT-KEY_1986'n = mar86
	'MARSTAT-KEY_1987'n = mar87
	'MARSTAT-KEY_1988'n = mar88
	'MARSTAT-KEY_1989'n = mar89
	'MARSTAT-KEY_1990'n = mar90
	'MARSTAT-KEY_1991'n = mar91
	'MARSTAT-KEY_1992'n = mar92
	'MARSTAT-KEY_1993'n = mar93
	'MARSTAT-KEY_1994'n = mar94
	'MARSTAT-KEY_1996'n = mar96
	'MARSTAT-KEY_1998'n = mar98
	'MARSTAT-KEY_2000'n = mar00
	'MARSTAT-KEY_2002'n = mar02
	'MARSTAT-KEY_2004'n = mar04
	'MARSTAT-KEY_2006'n = mar06
	'MARSTAT-KEY_2008'n = mar08
	'MARSTAT-KEY_2010'n = mar10
	'MARSTAT-KEY_2012'n = mar12
	'MARSTAT-KEY_2014'n = mar14
	'MARSTAT-KEY_2016'n = mar16;
	run;

	/*proc means data=a; var mar:; run;

	*probing some missing;

	proc print data=a;
		var caseid mar:;
		where mar82 = .I or mar88 = .I or mar02 = .I or mar12 = .I;
		run;
	*/

	*downloaded additional variables to mar.sas and performed checks there;

	*From marstat-col, numsppt, and relspptr, can identify the marital status of
	the individual, not sure why these three cases are classified as invalid missings;

	data a; set a;
		if caseid = 992 then mar02 = 1;
		if caseid = 4663 then mar02 = 3;
		if caseid = 10375 then mar82 = 1;
		if caseid = 2412 then mar88 = 1;
		if caseid = 9986 then mar12 = 1;
		run;

	*checked and deleted check code;

* HEALTH INSURANCE;
	*Not using health insurance, so commenting out;

/*
*identifying the variables i want;

proc contents data=a; run;

proc means data=a; var q11:; run;

proc freq data=a; tables 'Q11-80B_000003_1990'n; run;

proc freq data=a; tables 'Q11-79_1990'n; run;

*checking whether the source questions are sufficient to identify all sources
as well as individuals who don't have coverage;
proc freq data=a; tables 'Q11-80B_000007_1990'n*'Q11-79_1990'n; run;
*no, will need to get yes/no information from lead-in questions;

*checking frequencies for lead-in and source questions for 2000 as example;
proc freq data=a;
	tables
	'Q11-79_2000'n
	'Q11-80B~000001_2000'n
	'Q11-80B~000002_2000'n
	'Q11-80B~000003_2000'n
	'Q11-80B~000004_2000'n
	'Q11-80B~000005_2000'n
	'Q11-80B~000006_2000'n
	'Q11-80B~000007_2000'n;
	run;

proc freq data=a;
	tables 'Q11-79_2000'n 'Q11-80B~000001_2000'n;
	format _all_;
	run;

*presumably Rs can select more than one type of coverage?;
proc freq data=a;
	tables 'Q11-80B~000001_2000'n*'Q11-80B~000003_2000'n;
	run;
	*Yeah.;

proc freq data=a;
	tables 'Q11-80B~000001_2000'n*'Q11-80B~000006_2000'n;
	run;

*going to need to have just 3 categories - private, public, other;

*setting up a test recode;
data a; set a;
	ins00 = 'Q11-79_2000'n;
	if 'Q11-80B~000001_2000'n = 1 then ins00 = 1;
	if 'Q11-80B~000002_2000'n = 1 then ins00 = 1;
	if 'Q11-80B~000003_2000'n = 1 then ins00 = 1;
	if 'Q11-80B~000004_2000'n = 1 then ins00 = 1;
	if 'Q11-80B~000005_2000'n = 1 then ins00 = 1;
	if 'Q11-80B~000006_2000'n = 1 then ins00 = 2;
	if 'Q11-80B~000007_2000'n = 1 then ins00 = 3;
	label ins00 = "current H ins status 00";
	run;

	proc format;
		value insf
		0 = 'no insurance'
		1 = 'private insurance'
		2 = 'public insurance'
		3 = 'other insurance';
		run;

		data a; set a;
			format ins00 insf.;
			run;

	proc freq data=a; tables ins00 / missing; run;

	*some years are separate variables for each response, and some appear to be
one variable for all responses, so going to have to do these year by year;

*checking to see if a few of the years have identical vars;
proc freq data=a;
	tables 
	'Q11-80B_000004_1989'n
	'Q11-80B_000004_1990'n
	'Q11-80B_000004_1992'n;
	format _all_;
	run;

	proc means data=a;
		var 
		'Q11-80B~000001_2012'n
		'Q11-80B~000002_2012'n
		'Q11-80B~000003_2012'n
		'Q11-80B~000004_2012'n
		'Q11-80B~000006_2012'n
		'Q11-80B~000007_2012'n
		'Q11-80B~000008_2012'n
		'Q11-80B~000009_2012'n
		'Q11-80B~000010_2012'n
		'Q11-80B~000012_2012'n
		'Q11-80B~000001_2014'n
		'Q11-80B~000002_2014'n
		'Q11-80B~000003_2014'n
		'Q11-80B~000004_2014'n
		'Q11-80B~000005_2014'n
		'Q11-80B~000006_2014'n
		'Q11-80B~000007_2014'n
		;
		run;

*ok, from the above and the codebooks, it looks like 1989-2000 are identical, 
	2002-2008 are identical and might only have yes/no
	to having any plan, 2008-2012 are identical, 2014 is the same
	as 89-00, and 2016 is it's own bag of tricks;

	*checking whether type of insurance is associated with tubal;
	data a; set a;
		incperthous00 = income00/1000; run;
	proc surveylogistic data=a;
		class ins00 tub00 race mar00;
		model tub00 = ins00 incperthous00 educ00 race numkid00 mar00 famsize_2000 
		incperthous00*famsize_2000;
		run;

	proc freq data=a;
		tables age00;
		run;

	*** ^^ This is the model that convinces me I don't need health insurance, it is not
		significant in a model with other important predictors, and it's type 3 p-value is almost
		1, all at an important age for tubal uptake;

*/

* Adding custom weights;

	/*
	*creating final list of cases to submit to custom weight program
	(https://www.nlsinfo.org/weights/nlsy79);

	data print; set a;
		keep caseid;
		run;

	proc export data=print 
		outfile="C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\caseids.xlsx"
		dbms=xlsx;
		run;

	*/

*custom weights calculated and dataset created, combining with other datasets here;
data a;
	merge a custom_weights;
	by caseid;
	run;

*Imputing missing income and education;

*Probing correlations and determining best model for imputation was done in aim3_imputation.sas
program, final model is here:;

proc mi data=a nimpute=20 out=mi_mvn seed=54321 round=1;
var race 'age1b16_2016'n
incwin79 incwin82	incwin84	incwin86	incwin88	
incwin90	incwin92	incwin94	incwin96	incwin98	incwin00	
incwin02	incwin04	incwin06	incwin08	incwin10	incwin12	
incwin14	incwin16
educ82	educ84	
educ86	educ88	educ90	educ92
educ94	educ96
tub82 tub84 tub85 tub86 tub88 tub90 tub92 tub94 tub96 tub98 tub00 tub02 
tub04 tub06 /*tub08 tub10 tub12 tub14 tub16*/
famsize_1982	famsize_1984	famsize_1986	famsize_1988	
famsize_1990	famsize_1992	famsize_1994	famsize_1996	famsize_1998	
famsize_2000	famsize_2002	famsize_2004	famsize_2006	famsize_2008	
famsize_2010	famsize_2012	famsize_2014	famsize_2016;
ods output misspattern=imputation_misspattern;
run;
*(Had to remove the years where there was almost no variation);

*** TABLE 1;

*First describing missing;

	*need to make tub var;
	data missing; set missing;
		tub82 = 0; if 'Q9-65~000009_1982'n = 11 then tub82 = 1;
		run;

title 'removed from final sample';
proc means data=missing;
	var age82 tub82 'HGCREV82_1982'n /*<education*/ 
	tnfi_trunc_1982 /*<income*/;
	where miss=1;
	weight weight;
	ods output Summary=means_miss;
	run;

title 'remained in final sample';
proc means data=missing;
	var age82 tub82 'HGCREV82_1982'n /*<education*/ 
	tnfi_trunc_1982 /*<income*/;
	where miss=.;
	weight weight;
	ods output Summary=means_remain;
	run;

title 'removed from final sample';
proc freq data=missing;
	tables age82 tub82 'HGCREV82_1982'n /*<education*/ 
	tnfi_trunc_1982 /*<income*/;
	where miss=1;
	weight weight;
	ods output OneWayFreqs=freqs_miss;
	run;

title 'remained in final sample';
proc freq data=missing;
	tables age82 tub82 'HGCREV82_1982'n /*<education*/ 
	tnfi_trunc_1982 /*<income*/;
	where miss=.;
	weight weight;
	ods output OneWayFreqs=freqs_remain;
	run;

title;
data freqs_remain; set freqs_remain;
	if table = "Table age82" then variable = "Age";
	if table = "Table tub82" then variable = "Tubal";
	if table = "Table HGCREV82_1982" then variable = "Education";
	if table = "Table TNFI_TRUNC_1982" then variable = "Income";
	if age82 ne . then value = age82;
	if tub82 ne . then value = tub82;
	if HGCREV82_1982 ne . then value = HGCREV82_1982;
	if TNFI_TRUNC_1982 ne . then value = TNFI_TRUNC_1982;
	if variable = 'Inc' and value = 1000 then inc_value = '1000-1999';
	if variable = 'Inc' and value = 2000 then inc_value = '2000-2999';
	if variable = 'Inc' and value = 3000 then inc_value = '3000-3999';
	if variable = 'Inc' and value = 4000 then inc_value = '4000-4999';
	if variable = 'Inc' and value = 5000 then inc_value = '5000-5999';
	if variable = 'Inc' and value = 6000 then inc_value = '6000-6999';
	if variable = 'Inc' and value = 7000 then inc_value = '7000-7999';
	if variable = 'Inc' and value = 8000 then inc_value = '8000-8999';
	if variable = 'Inc' and value = 9000 then inc_value = '9000-9999';
	if variable = 'Inc' and value = 10000 then inc_value = '10000-14999';
	if variable = 'Inc' and value = 15000 then inc_value = '15000-19999';
	if variable = 'Inc' and value = 20000 then inc_value = '20000-24999';
	if variable = 'Inc' and value = 25000 then inc_value = '25000-29999';
	if variable = 'Inc' and value = 50000 then inc_value = '50000+';
	Sample = percent;
	keep variable value Sample inc_value frequency;
	run;

	proc print data=freqs_remain; run;

title;

data freqs_miss; set freqs_miss;
	if table = "Table age82" then variable = "Age";
	if table = "Table tub82" then variable = "Tubal";
	if table = "Table HGCREV82_1982" then variable = "Education";
	if table = "Table TNFI_TRUNC_1982" then variable = "Income";
	if age82 ne . then value = age82;
	if tub82 ne . then value = tub82;
	if HGCREV82_1982 ne . then value = HGCREV82_1982;
	if TNFI_TRUNC_1982 ne . then value = TNFI_TRUNC_1982;
	if variable = 'Inc' and value = 1000 then inc_value = '1000-1999';
	if variable = 'Inc' and value = 2000 then inc_value = '2000-2999';
	if variable = 'Inc' and value = 3000 then inc_value = '3000-3999';
	if variable = 'Inc' and value = 4000 then inc_value = '4000-4999';
	if variable = 'Inc' and value = 5000 then inc_value = '5000-5999';
	if variable = 'Inc' and value = 6000 then inc_value = '6000-6999';
	if variable = 'Inc' and value = 7000 then inc_value = '7000-7999';
	if variable = 'Inc' and value = 8000 then inc_value = '8000-8999';
	if variable = 'Inc' and value = 9000 then inc_value = '9000-9999';
	if variable = 'Inc' and value = 10000 then inc_value = '10000-14999';
	if variable = 'Inc' and value = 15000 then inc_value = '15000-19999';
	if variable = 'Inc' and value = 20000 then inc_value = '20000-24999';
	if variable = 'Inc' and value = 25000 then inc_value = '25000-29999';
	if variable = 'Inc' and value = 50000 then inc_value = '50000+';
	Missing = percent;
	keep variable value Missing inc_value frequency;
	run;

	proc print data=freqs_miss; run;






* In the interest of time, I abandoned graphing and made a table in excel;
	/*proc sort data = freqs_miss; by variable; run;
	proc sort data=freqs_remain; by variable; run;

	data missing;
		merge freqs_miss freqs_remain;
		by variable value;
		run;

	title "Age Distribution of Final Sample vs. Removed Respondents";
	proc sgplot data=missing;
		xaxis type=discrete;
		series x=value y=Sample / datalabel = Sample;
		series x=value y=Missing / datalabel = Missing;
		where variable = "Age";
		xaxis label = "Age";
		yaxis label = "Weighted Percent";
		run;

	title "Education Distribution of Final Sample vs. Removed Respondents";
	proc sgplot data=missing;
		xaxis type=discrete;
		series x=value y=Sample / datalabel = Sample;
		series x=value y=Missing / datalabel = Missing;
		where variable = "Edu";
		xaxis label = "Age";
		yaxis label = "Weighted Percent";
		run;

	title "Income Distribution of Final Sample vs. Removed Respondents";
	proc sgplot data=missing;
		xaxis type=discrete;
		series x=value y=Sample / datalabel = Sample;
		series x=value y=Missing / datalabel = Missing;
		where variable = "Inc";
		xaxis label = "Age";
		yaxis label = "Weighted Percent";
		run;

	*/



*** LONG FORMAT DATASET;

* Can probably do this with a macro, but trying individually first to make sure I
	have the procedure down;

* Need to adjust the normal procedures because of the imputation, see p 10 here for example:
	https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2018/1738-2018.pdf;

/*proc print data=mi_mvn; var caseid _imputation_ tub:; where caseid=4663; run;*/

* Tubal;

*first need to change tub variables to be missing after a person has a tubal;
	/*
	data mi_mvn; set mi_mvn;
		array tub (18)
		tub82 tub84 tub85 tub86 tub88 tub90 tub92 
		tub94 tub96 tub98 tub00 tub02 tub04 tub06 
		tub08 tub10 tub12 tub14;
		do i = 1 to 18;
		if tub(i) = 1 or tub(i) = . then tub(i+1) = .;
		end;
		run;
	*/
	*this array is throwing an error i can't decipher, so moving forward with hard code;

data mi_mvn; set mi_mvn;
	if tub82 = 1 then tub84 = .;
	if tub84 = 1 or tub84 = . then tub86 = .;
	if tub86 = 1 or tub86 = . then tub88 = .;
	if tub88 = 1 or tub88 = . then tub90 = .;
	if tub90 = 1 or tub90 = . then tub92 = .;
	if tub92 = 1 or tub92 = . then tub94 = .;
	if tub94 = 1 or tub94 = . then tub96 = .;
	if tub96 = 1 or tub96 = . then tub98 = .;
	if tub98 = 1 or tub98 = . then tub00 = .;
	if tub00 = 1 or tub00 = . then tub02 = .;
	if tub02 = 1 or tub02 = . then tub04 = .;
	if tub04 = 1 or tub04 = . then tub06 = .;
	if tub06 = 1 or tub06 = . then tub08 = .;
	if tub08 = 1 or tub08 = . then tub10 = .;
	if tub10 = 1 or tub10 = . then tub12 = .;
	if tub12 = 1 or tub12 = . then tub14 = .;
	if tub14 = 1 or tub14 = . then tub16 = .;
	run;

	/*proc print data=mi_mvn (obs=50); var caseid _imputation_ tub:; where _imputation_ =15; run;*/

data mi_mvn; set mi_mvn;
	array age (19)
	age82 age84 age85 age86 age88 age90 age92 age94 age96 	
	age98 age00 age02 age04 age06 age08 age10 age12 age14 age16;
	array tub (19)
	tub82 tub84 tub85 tub86 tub88 tub90 tub92 
	tub94 tub96 tub98 tub00 tub02 tub04 tub06 
	tub08 tub10 tub12 tub14 tub16;
	do i = 1 to 19;
	if age(i) >= meno then tub(i) = .;
	end;
	run;

	/*proc print data=test (obs=100); 
		var caseid _imputation_ tub10 tub12 tub14 meno age10 age12 age14; 
		where _imputation_ = 12 and (meno > tub10 or meno > tub12 or meno > tub14);
		run;

		*Hot damn, it worked!;
	*/

*making a permanent var for each year so I can transpose them. I'm sure there's a
more efficient way but haven't been able to identify one yet;

data mi_mvn; set mi_mvn;
	array age_array (19)
	age82 age84 age85 age86 age88 age90 age92 age94 age96 	
	age98 age00 age02 age04 age06 age08 age10 age12 age14 age16;
	array race_array (19)
	race82 race84 race85 race86 race88 race90 race92 race94 race96 
	race98 race00 race02 race04 race06 race08 race10 race12 race14 race16;
	array age1b_array (19)
	age1b82 age1b84 age1b85 age1b86 age1b88 age1b90 age1b92 age1b94 age1b96 
	age1b98 age1b00 age1b02 age1b04 age1b06 age1b08 age1b10 age1b12 age1b14 
	age1b16;
	array customwt_array (19)
	custom_wt82 custom_wt84 custom_wt85 custom_wt86 custom_wt88 custom_wt90 
	custom_wt92 custom_wt94 custom_wt96 custom_wt98 custom_wt00 custom_wt02 
	custom_wt04 custom_wt06 custom_wt08 custom_wt10 custom_wt12 custom_wt14 
	custom_wt16;
	do i = 1 to 19;
	if age_array(i) ne . then race_array(i) = race;
	if age_array(i) ne . then age1b_array(i) = 'age1b16_2016'n;
	if age_array(i) ne . then customwt_array(i) = custom_wt;
	end;
	run;

	*checked and deleted check code;

%let race_new = race82 race84 race85 race86 race88 race90 race92 race94 race96 
	race98 race00 race02 race04 race06 race08 race10 race12 race14 race16;
%let age1b_new = age1b82 age1b84 age1b85 age1b86 age1b88 age1b90 age1b92 age1b94 age1b96 
	age1b98 age1b00 age1b02 age1b04 age1b06 age1b08 age1b10 age1b12 age1b14 
	age1b16;
%let customwt_new = custom_wt82 custom_wt84 custom_wt85 custom_wt86 custom_wt88 custom_wt90 
	custom_wt92 custom_wt94 custom_wt96 custom_wt98 custom_wt00 custom_wt02 
	custom_wt04 custom_wt06 custom_wt08 custom_wt10 custom_wt12 custom_wt14 
	custom_wt16;

proc sort data=mi_mvn; by caseid _imputation_; run;

*transposing permanent variables first;
proc transpose data=mi_mvn out=tranrace;
	var caseid _imputation_ &race_new;
	by caseid _imputation_;
	run;	

data tranrace; set tranrace (rename=(col1=race));
	if _label_ ne . then delete;
	year=input(substr(_name_,5),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;

proc transpose data=mi_mvn out=tranage1b;
	var caseid _imputation_ &age1b_new;
	by caseid _imputation_;
	run;	

data tranage1b; set tranage1b (rename=(col1=age1b));
	if _label_ ne . then delete;
	year=input(substr(_name_,6),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;

proc transpose data=mi_mvn out=trancustomwt;
	var caseid _imputation_ &customwt_new;
	by caseid _imputation_;
	run;	

data trancustomwt; set trancustomwt (rename=(col1=customwt));
	if _label_ ne . then delete;
	year=input(substr(_name_,10),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;

*now transposing yearly vars;
proc transpose data=mi_mvn out=trantub;
	var caseid _imputation_ tub82--tub16;
	by caseid _imputation_;
	run;

	/*proc print data=trantub_mi; where caseid=4663 and _imputation_ = 1; run;*/

data trantub; set trantub (rename=(col1=tub));
	if _label_ ne . then delete;
	year=input(substr(_name_,4),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;
	*Ignore the error, the year output is still usable;

* Age at menopause;

proc transpose data=mi_mvn out=tranmeno;
	var caseid _imputation_ meno;
	var caseid _imputation_;
	run;

data tranmeno; set tranmeno (rename=(col1=meno_age));
	if _name_ = "caseid" or _name_ = "_Imputation_" then delete;
	drop _label_;
	run;

* Age;

	%let age = age82 age84 	age85 	age86 	age88 	age90 	age92 	age94 	age96 	
	age98 	age00 	age02 	age04 age06 age08 age10 age12 age14 age16; 

proc transpose data=mi_mvn out=tranage;
	var caseid _imputation_ &age;
	by caseid _imputation_;
	run;

data tranage; set tranage (rename=(col1=age));
	/*if _label_ ne . then delete;*/
	year=input(substr(_name_,4),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;

* Marital status;
%let mar = mar80	mar82	mar84	mar85	mar86	
mar88	mar90	mar92	mar94	mar96	mar98	mar00	mar02	
mar04	mar06	mar08	mar10	mar12	mar14	mar16;

proc transpose data=mi_mvn out=tranmar;
	var caseid _imputation_ &mar;
	by caseid _imputation_;
	run;

data tranmar; set tranmar (rename=(col1=mar));
	year=input(substr(_name_,4),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;
	

* Education;
%let educ = educ06	educ80	educ82	educ84	educ86	
educ88	educ90	educ92	educ94	educ96	educ98	educ00	educ02	
educ04	educ08	educ10	educ12	educ14	educ16;

proc transpose data=mi_mvn out=traneduc;
	var caseid _imputation_ &educ;
	by caseid _imputation_;
	run;

data traneduc; set traneduc (rename=(col1=educ));
	year=input(substr(_name_,5),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;

* Number kids;
%let numkid = numkid82	numkid84	numkid85	numkid86	numkid88	numkid90	numkid92	
numkid94	numkid96	numkid98	numkid00	numkid02	numkid04	numkid06	numkid08	
numkid10	numkid12	numkid14	numkid16;

proc transpose data=mi_mvn out=trannumkid;
	var caseid _imputation_ &numkid;
	by caseid _imputation_;
	run;

data trannumkid; set trannumkid (rename=(col1=numkid));
	year=input(substr(_name_,7),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;

* Income;
%let incwin = incwin82	incwin84	incwin85	incwin86	incwin88	incwin90	incwin92	incwin94	incwin96	incwin98	
incwin00	incwin02	incwin04	incwin06	incwin08	incwin10	incwin12	incwin14	incwin16;

proc transpose data=mi_mvn out=traninc;
	var caseid _imputation_ &incwin;
	by caseid _imputation_;
	run;

data traninc; set traninc (rename=(col1=incwin));
	year=input(substr(_name_,7),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;

/*
*checking that there are values for all imputations for variables I didn't include in the
	imputation model;
proc print data=mi_mvn; var caseid famsize_2000 _imputation_; where caseid=4663; run;
	*confirmed;
*/

%let famsize = famsize_1982	famsize_1984 famsize_1986	famsize_1988	famsize_1990	
famsize_1992	famsize_1994	famsize_1996	famsize_1998	famsize_2000	famsize_2002	
famsize_2004	famsize_2006	famsize_2008	famsize_2010	famsize_2012	famsize_2014	
famsize_2016;

proc transpose data=mi_mvn out=tranfamsize;
	var caseid _imputation_ &famsize;
	by caseid _imputation_;
	run;

data tranfamsize; set tranfamsize (rename=(col1=famsize));
	year=input(substr(_name_,11),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;
	

* Creating dataset;
proc sort data=trantub; by caseid _imputation_ year; run;
proc sort data=tranage; by caseid _imputation_ year; run;
proc sort data=traneduc; by caseid _imputation_ year; run;
proc sort data=traninc; by caseid _imputation_ year; run;
proc sort data=tranmar; by caseid _imputation_ year; run;
proc sort data=trannumkid; by caseid _imputation_ year; run;
proc sort data=tranfamsize; by caseid _imputation_ year; run;
proc sort data=tranrace; by caseid _imputation_ year; run;
proc sort data=tranage1b; by caseid _imputation_ year; run;
proc sort data=trancustomwt; by caseid _imputation_ year; run;
/*proc sort data=tranmeno; by caseid _imputation_ year; run;*/


data all_transposed;
	merge trantub tranage traneduc traninc tranmar trannumkid tranfamsize
	tranrace tranage1b trancustomwt;
	by caseid _imputation_ year;
	run;

* Need to order the observations by survey year;
data all_transposed; set all_transposed;
	if year = 82 then time = 0;
	if year = 84 then time = 1;
	if year = 86 then time = 2;
	if year = 88 then time = 3;
	if year = 90 then time = 4;
	if year = 92 then time = 5;
	if year = 94 then time = 6;
	if year = 96 then time = 7;
	if year = 98 then time = 8;
	if year = 0 then time = 9;
	if year = 2 then time = 10;
	if year = 4 then time = 11;
	if year = 6 then time = 12;
	if year = 8 then time = 13;
	if year = 10 then time = 14;
	if year = 12 then time = 15;
	if year = 14 then time = 16;
	if year = 16 then time = 17;
	run;

*deleting observations from 1980 and 1985;

data all_transposed; set all_transposed;
	if year = 80 or year = 85 then delete;
	run;
	

*** Analysis;

proc sort data=all_transposed; by _imputation_; run;

* First doing just time, unadjusted;

proc surveylogistic data=all_transposed;
	class time / param=glm;
	weight customwt;
	model tub(event='1') = time / noint link=cloglog technique=newton;
	by _imputation_;
	/*estimate time 1 / exp cl ilink;*/
	ods output ParameterEstimates=unadj_pe_mvn;
	run;

proc mianalyze parms(classvar=classval0)=unadj_pe_mvn;
	class time;
	modeleffects time;
	ods output ParameterEstimates=unadj_pe_final;
	run;
	*not outputting confidence limits because values are exactly the same for
	all imputations;

*What proportion of respondents are having a tubal each year?;
proc freq data=all_transposed;
	where _imputation_ = 12;
	tables tub*time;
	run;

data unadj_estimates; set unadj_pe_final;
	unadj_e = exp(-exp(Estimate));
	run;

proc print data=unadj_estimates; run;


* Adjusted;

proc surveylogistic data=all_transposed;
	class time mar (ref="0") / param=glm;
	weight customwt;
	effect spl_age = spline(age / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
	model tub(event='1') = time spl_age age1b educ famsize incwin mar numkid
	race incwin*famsize / noint link=cloglog technique=newton;
	by _imputation_;
	/*estimate time 1 / exp cl ilink;*/
	ods output ParameterEstimates=pe_mvn;
	run;

	proc contents data=pe_mvn; run;
	proc print data=pe_mvn (obs=100); run;

proc mianalyze parms(classvar=classval0)=pe_mvn;
	class time mar;
	modeleffects time spl_age age1b educ famsize incwin mar numkid race
	incwin*famsize;
	ods output ParameterEstimates=pe_final;
	run;

proc contents data=pe_final; run;
proc print data=pe_final; run;

data estimates; set pe_final;
	yr1982 = exp(-exp(Estimate));
	lcl1982 = exp(-exp(LCLMean));
	ucl1982 = exp(-exp(UCLMean));
	run;

data age_estimates; set pe_final;
	age23 = exp(-exp(23*Estimate)); 
	age30 = exp(-exp(30*Estimate));
	age35 = exp(-exp(35*Estimate));
	age40 = exp(-exp(40*Estimate));
	where parm="spl_age"; run;

proc sort data=estimates; by time; run;
proc print data=age_estimates; run;

*the probabilities are way too high, checking to see if it's the missings i added
to the tub var;

proc print data=all_transposed (obs=100);
	where tub = 1 or tub = .;
	run;

data test_missingtub; set all_transposed;
	if tub = . then delete;
	run;

	proc freq data=test_missingtub; tables tub; run;


	proc surveylogistic data=test_missingtub;
		class time mar (ref="0") / param=glm;
		weight customwt;
		effect spl_age = spline(age / naturalcubic basis=tpf(noint)
										knotmethod=percentiles(5) details);
		model tub(event='1') = time spl_age age1b educ famsize incwin mar numkid
		race incwin*famsize / noint link=cloglog technique=newton;
		by _imputation_;
		/*estimate time 1 / exp cl ilink;*/
		ods output ParameterEstimates=pe_test_missingtub;
		run;

		proc contents data=pe_mvn; run;
		proc print data=pe_mvn (obs=100); run;

	proc mianalyze parms(classvar=classval0)=pe_test_missingtub;
		class time mar;
		modeleffects time spl_age age1b educ famsize incwin mar numkid race
		incwin*famsize;
		ods output ParameterEstimates=pe_final_test_missingtub;
		run;

	proc contents data=pe_final; run;
	proc print data=pe_final; run;

	data estimates_test_missingtub; set pe_final_test_missingtub;
		yr1982 = exp(-exp(Estimate));
		lcl1982 = exp(-exp(LCLMean));
		ucl1982 = exp(-exp(UCLMean));
		run;

		proc print data=estimates_test_missingtub; run;


*After talking to Ron, need to include intercept,
	tried both ways and after adding intercept, must use ref parameterization
	to avoid separation;

proc surveylogistic data=all_transposed;
	class time (ref="0") mar (ref="0") / param=ref;
	weight customwt;
	effect spl_age = spline(age / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
	model tub(event='1') = time spl_age age1b educ famsize incwin mar numkid
	race incwin*famsize / noint link=cloglog technique=newton;
	by _imputation_;
	/*estimate time 1 / exp cl ilink;*/
	ods output ParameterEstimates=ref_mvn;
	run;

	proc contents data=ref_mvn; run;
	proc print data=ref_mvn (obs=100); run;

proc mianalyze parms(classvar=classval0)=ref_mvn;
	class time mar;
	modeleffects time spl_age age1b educ famsize incwin mar numkid race
	incwin*famsize;
	ods output ParameterEstimates=ref_final;
	run;

proc contents data=pe_final; run;
proc print data=pe_final; run;

data ref_estimates; set ref_final;
	P = exp(-exp(Estimate));
	lcl = exp(-exp(LCLMean));
	ucl = exp(-exp(UCLMean));
	run;

	proc print data=ref_estimates; run;

data age_estimates; set pe_final;
	age23 = exp(-exp(23*Estimate)); 
	age30 = exp(-exp(30*Estimate));
	age35 = exp(-exp(35*Estimate));
	age40 = exp(-exp(40*Estimate));
	where parm="spl_age"; run;

proc sort data=estimates; by time; run;
proc print data=age_estimates; run;

*trying with intercept;

proc surveylogistic data=all_transposed;
	class time (ref="0") mar (ref="0") / param=ref;
	weight customwt;
	effect spl_age = spline(age / naturalcubic basis=tpf(noint)
									knotmethod=percentiles(5) details);
	model tub(event='1') = time spl_age age1b educ famsize incwin mar numkid
	race incwin*famsize / link=cloglog technique=newton;
	by _imputation_;
	/*estimate time 1 / exp cl ilink;*/
	ods output ParameterEstimates=int_mvn;
	run;

	proc contents data=int_mvn; run;
	proc print data=int_mvn (obs=100); run;

proc mianalyze parms(classvar=classval0)=int_mvn;
	class time mar;
	modeleffects time spl_age age1b educ famsize incwin mar numkid race
	incwin*famsize;
	ods output ParameterEstimates=int_final;
	run;

proc contents data=pe_final; run;
proc print data=pe_final; run;

data estimates; set int_final;
	P = exp(-exp(Estimate));
	lcl = exp(-exp(LCLMean));
	ucl = exp(-exp(UCLMean));
	run;

	proc print data=estimates; run;

data age_estimates; set pe_final;
	age23 = exp(-exp(23*Estimate)); 
	age30 = exp(-exp(30*Estimate));
	age35 = exp(-exp(35*Estimate));
	age40 = exp(-exp(40*Estimate));
	where parm="spl_age"; run;

proc sort data=estimates; by time; run;
proc print data=age_estimates; run;
