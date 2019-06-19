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

*** Merge datasets created using NLSY programs;
data work.nlsy;
	merge new_data new_ster add_ageb add_famsize new_educ new_edutwo new_ins new_eduthree; 
	by 'CASEID_1979'n; 
	run;
data a; set nlsy; run;

*** Removing males;
data a; set a;
	if 'sample_sex_1979'n = 1 then delete;
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

	*checking;
	proc print data=test (obs=25);
		var 'CASEID_1979'n age82 age00;
		run;

	*the listwise deletion removes so many people, but I think it's the only way in this case;

*Identifying all tubal questions;

	*Checking out first few;

	proc freq data=a; tables 'Q9-65~000009_1992'n; run;

	proc freq data=a; tables 'Q9-65~000009_1982'n; run;

	proc freq data=a; tables 'Q9-65F~000009_1984'n; run;

	proc freq data=a; tables 'Q9-65F~000009_1985'n; run;

	*These all have a number but with all others missing, need
	to recode to only have nonrespondents missing?;

	*Now looking to see if individuals who reported sterilization in 82
	carry through the first few years;

	proc print data=a;
		var
		'CASEID_1979'n 
		'Q9-65~000009_1982'n
		'Q9-65F~000009_1984'n
		'Q9-65F~000009_1985'n
		'Q9-65~000009_1992'n;
		where 'Q9-65~000009_1982'n = 11 and 'sample_sex_1979'n = 2;
		run;

	*Many who reported female sterilization in 1982 have valid skips
	or does not apply in subsequent years;

	proc freq data=a; 
		tables 'Q9-65~000009_1982'n;
		where 'sample_sex_1979'n = 2;
		run;
	proc freq data=a;
		tables 'Q9-65~000009_1982'n;
		where 'Q9-65F~000009_1984'n = 9 and 'sample_sex_1979'n = 2;
		run;

*Of the 168 women who reported using female sterilization in 1982,
		only 106 reported using it in 1984;

	*quickly testing rename since i'm not familiar with literals;
	data test; set a;
		rename
		'Q9-65~000009_1982'n = tub82;
		run;

	proc freq data=test;
		tables tub82;
		run;

		*note, SAS will let you use : with name literals, you just leave off the single
		quotes and n;


proc freq data=a;
	tables 'Q9-64H_2002'n;
	run;

proc freq data=a;
	tables tub00; run;

proc freq data=a;
	where tub82 = 11;
	tables tub00; run;

	*maybe there's hope, it does appear that new tubals are being reported -
	check qxq and questionnaires;

* Added some variables to the dataset at top of program;

* Checking out additional sterilization variables;
proc freq data=a;
	tables 'Q9-64GB_4_2002'n;
	run;

proc freq data=a;
	tables 'Q9-64GC_2002'n;
	run;

proc freq data=a;
	tables 'Q9-64GB_4_2002'n*'Q9-65F~000009_1988'n;
	run;

proc freq data=a;
	tables 'AGEATINT_2000'n;
	run;

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

	proc freq data=a; tables tub84; run;
	proc freq data=a; tables 'Q9-65F~000009_1984'; format _all_; run;
	proc freq data=a; tables age84; format _all_; run;

	proc freq data=a; tables age90 tub90; run;


*Tackling 2002-2016;
	*If R has reported prior sterilization procedure ('Q9-64GB_4_2002'n), then they skip
	the sterilizing operation question ('Q9-64GC_2002'n). So in theory, 'Q9-64GC_2002'n
	should be new procedures or those that were not previously reported;
proc freq data=a;
	tables 'Q9-64GB_4_2002'n 'Q9-64GC_2002'n;
	run;

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

	proc freq data=a; tables age02 tub02 age12 tub12; run;
	proc freq data=a; tables 'Q9-64GC_2014'n; format _all_; run;

*Now looking at tub vars for each year to see how it looks;
proc freq data=a; tables tub:; run;
	*All vars are up to snuff, 2014 has no new tubals because all new tubals were among
	males;

	*There *were* 6 new tubals in 2016, ages are spread out;
	proc print data=a; var tub16 age16; where tub16 = 1; run;

	ODS HTML CLOSE; ODS HTML;

proc freq data=a; tables tub:; run;

proc sql outobs=10;
	title 'test';
	select age02
		from a;

%let age =
	age82
	age84
	age85
	age86
	age88
	age90
	age92
	age94
	age96
	age98
	age00
	age02
	age04
	age06
	age08
	age10
	age12
	age14
	age16;

*Just to check tubal numbers, deleting people with missing interviews;
data a; set a;
	if tub82 = . then delete;
	if tub84 = . then delete;
	if tub85 = . then delete;
	if tub86 = . then delete;
	if tub88 = . then delete;
	if tub90 = . then delete;
	if tub92 = . then delete;
	if tub94 = . then delete;
	if tub96 = . then delete;
	if tub98 = . then delete;
	if tub00 = . then delete;
	if tub02 = . then delete;
	if tub04 = . then delete;
	if tub06 = . then delete;
	if tub08 = . then delete;
	if tub10 = . then delete;
	if tub12 = . then delete;
	if tub14 = . then delete;
	if tub16 = . then delete;
	run;

proc print data=b (obs=30);
	var 'CASEID_1979'n tub:;
	where tub86 = 1;
	run;

proc print data=b;
	where 'CASEID_1979'n = 979;
	var tub88 'FFER-139_1988'n tub90 'FFER-139_1990'n tub92 'Q9-64G_1992'n tub94 'Q9-64G_1994'n;
	run;

	*^^ Demonstrates that some people with previously-reported tubals report not doing
	anything to prevent pregnancy;

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

	*checking;
	proc print data=a (obs=30);
		var 'CASEID_1979'n tub:;
		where tub04 = 1;
		run;

*graphing simple tubal percents;

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
	
proc means data=b; var age:; run;


* NUMBER KIDS (NO PARITY VAR THAT I KNOW OF);
proc contents data=a; run;

proc freq data=a;
	tables 'numkid00_2000'n; run;

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

	*checking;
	proc freq data=a; tables numkid00; run;

	*transforming to make sure mean increases each year;
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

* AGE AT FIRST BIRTH;

data a; set a;
	rename
	'CASEID_1979'n = caseid;
	run;

proc print data=a (obs=30);
	var age:;
	run;
proc freq data=a;
	tables age1b16_2016;
	run;

	*no first births in 420 respondents, which is same # as had 0 births
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
	run;


* RACE;
proc contents data=a; run;
proc freq data=a; tables SAMPLE_RACE_78SCRN; run;
proc freq data=a; tables 'SAMPLE_ID_1979'n; run;

	*goodness, needed to fix a lot of formatting problems with merging the datasets,
	should be working now;

	data a; set a;
		rename
		SAMPLE_RACE_78SCRN = race;
		run;

		proc freq data=a;
			tables race;
			run;

* INCOME;

proc contents data=a; run;
proc freq data=a; tables tnfi_trunc_1982; run;
proc means data=a; var tnfi_trunc_1982; format _all_; run;

proc print data=a (obs=50);
	var caseid tnfi:;
	format _all_;
	run;

data a; set a;
	rename
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

	*yeah, it appears there is an outlier with close to $1m family income that is likely
		contributing disproportionately to the mean;

	proc print data=a;
		var caseid income:;
		where income92 > 800000;
		/*format _all_;*/
		run;

	*apparently it's several cases. there is a note in the codebook that there are some
		questionable responses, but the cases identified in that note don't align with
		the cases identified here;
	*i thought the problem wasn't a questionable value so much
		as the folks with very high incomes are coded the same d/t assigning the midpoint
		to the question asked categorically, but qx enters actual values 
		(https://www.nlsinfo.org/sites/nlsinfo.org/files/attachments/121211/NLSY79_1992_Quex.pdf);

	*checking frequencies to identify cases that are identical;
	proc freq data=a;
		tables income82 income92 income00;
		format _all_;
		run;

	*ok, figured it out (kinda) - respondents are being top-coded, i can't figure out
		how the top value is being selected (although detailed code is here
		https://www.nlsinfo.org/content/cohorts/nlsy79/other-documentation/codebook-supplement/nlsy79-appendix-2-total-net-family-0#1983
		but each highest group has many more respondents
		than any other group. regardless, need to categorize income, i think;

	proc freq data=a;
		tables income16;
		run;

	*definitely need to create my own categories since the formatted categories provided
		have the top-coded group anyone greater than 50k;

title;

	* FAMILY SIZE;

	proc freq data=a;
		tables famsize:;
		run;

	proc contents data=a; run;

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

	proc import datafile="C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\famsize_ds.csv"
		out=fs
		dbms=csv
		replace;
		getnames=yes;
		run;

		proc print data=fs; run;

		data fs; set fs;
			if mod(year,2) ne 0 then flag=1;
			if flag=1 and year ne 1983 then delete;
			run;

		proc print data=fs noobs;
			var year;
			run;
		proc print data=fs noobs; var first_person; run;
		proc print data=fs noobs; var each_additional; run;

data test; set a; run;

	%let year = 1982 1983 1984 1986 1988 1990 1992 1994 1996 1998 2000 2002 2004 
	2006 2008 2010 2012 2014;
	%let first_person = 4310 4680 4860 5250 5500 5980 6620 6970 7470 7890 8240 
	8590 8980 9570 10210 10830 10890 11670;
	%let each_additional = 1380 1540 1680 1800 1900 2040 2260 2460 2560 2720 
	2820 3020 3140 3260 3480 3740 3820 4060;


%macro overthink;
	%let i = 1;
	%do %until(not %length(%scan(year,&i)));
	data test; set test;
		pov_%scan(&year,&i) = ((famsize_%scan(&year,&i)-1)*(%scan(&each_additional,&i)))+(%scan(&first_person,&i));
		label pov = "FPL for R family size, %scan(&year,&i)";
		run;
	%let i=%eval(&i+1);
	%end;
	%mend overthink;

%overthink;

	proc freq data=test;
		tables pov_:;
		run;

	proc freq data=a;
		tables pov;
		run;

	proc contents data=test; run;

* abandoning the macro for now;

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
		fpl82 = income82/pov82; label fpl82 = 'Rs HH % fpl 1982';
		fpl84 = income84/pov84; label fpl84 = 'Rs HH % fpl 1984';
		fpl85 = income85/pov85; label fpl85 = 'Rs HH % fpl 1985';
		fpl86 = income86/pov86; label fpl86 = 'Rs HH % fpl 1986';
		fpl88 = income88/pov88; label fpl88 = 'Rs HH % fpl 1988';
		fpl90 = income90/pov90; label fpl90 = 'Rs HH % fpl 1990';
		fpl92 = income92/pov92; label fpl92 = 'Rs HH % fpl 1992';
		fpl94 = income94/pov94; label fpl94 = 'Rs HH % fpl 1994';
		fpl96 = income96/pov96; label fpl96 = 'Rs HH % fpl 1996';
		fpl98 = income98/pov98; label fpl98 = 'Rs HH % fpl 1998';
		fpl00 = income00/pov00; label fpl00 = 'Rs HH % fpl 2000';
		fpl02 = income02/pov02; label fpl02 = 'Rs HH % fpl 2002';
		fpl04 = income04/pov04; label fpl04 = 'Rs HH % fpl 2004';
		fpl06 = income06/pov06; label fpl06 = 'Rs HH % fpl 2006';
		fpl08 = income08/pov08; label fpl08 = 'Rs HH % fpl 2008';
		fpl10 = income10/pov10; label fpl10 = 'Rs HH % fpl 2010';
		fpl12 = income12/pov12; label fpl12 = 'Rs HH % fpl 2012';
		fpl14 = income14/pov14; label fpl14 = 'Rs HH % fpl 2014';
		fpl16 = income16/pov16; label fpl16 = 'Rs HH % fpl 2016';
		run;

	proc freq data=a; tables famsize:; run;
	proc freq data=a; tables income:; run;
	proc freq data=a; tables fpl:; run;

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

ods html close; ods html;

proc contents data=a; run;

proc freq data=a; tables 'Q3-10B_1998'n; run;
proc freq data=a; tables 'DEGREE-1A_1_1980'n; run;
proc freq data=a; tables degree:; run;


* EDUCATION;

*making an intermediate education variable, highest grade completed
	for ease of use later;

data a; set a;
	rename
	'Q3-4_1979'n = xedu79
	'Q3-4_1980'n = xedu80
	'Q3-4_1981'n = xedu81
	'Q3-4_1982'n = xedu82
	'Q3-4_1983'n = xedu83
	'Q3-4_1984'n = xedu84
	'Q3-4_1985'n = xedu85
	'Q3-4_1986'n = xedu86
	'Q3-4_1987'n = xedu87
	'Q3-4_1988'n = xedu88
	'Q3-4_1989'n = xedu89
	'Q3-4_1990'n = xedu90
	'Q3-4_1991'n = xedu91
	'Q3-4_1992'n = xedu92
	'Q3-4_1993'n = xedu93
	'Q3-4_1994'n = xedu94
	'Q3-4_1996'n = xedu96
	'Q3-4_1998'n = xedu98
	'Q3-4_2000'n = xedu00
	'Q3-4_2002'n = xedu02
	'Q3-4_2004'n = xedu04
	'Q3-4_2006'n = xedu06
	'Q3-4_2008'n = xedu08
	'Q3-4_2010'n = xedu10
	'Q3-4_2012'n = xedu12
	'Q3-4_2014'n = xedu14
	'Q3-4_2016'n = xedu16;
	run;

	proc freq data=a; tables xedu:; run;

*checking that valid skips are because the person did not complete more
	school;
	proc print data=a (obs=50);
		var caseid xedu82 xedu84 xedu90 xedu10 xedu16;
		run;
		*it appears that is the case but for a few exceptions (see 
		OneNote Education);

*trying to work out the inconsistent naming and asking of questions
about actual degrees;
	proc print data=a (obs=50);
		var caseid xedu79 'TRN-8E_1_M_1979'n 'TRN-8A_1_1979'n 
		xedu82 xedu84 xedu90 'Q3-10B_1998'n xedu10 xedu16;
		where 'Q3-10B_1998'n ne .V;
		run;

	proc freq data=a; tables 'Q3-10B_1998'n; run;

	proc means data=a; var degree: trn:; run;

	proc print data=a (obs=50);
		var caseid  trn: degree: xedu:;
		where caseid=174;
		run;

	proc freq data=a;
		tables 
			'Q3-4_1979'n 'TRN-8E_1_M_1979'n 'TRN-8A_1_1979'n 
			xedu82 xedu84 xedu90 xedu10 xedu16;
		run;

*i'm going to start with the easy part and recode everyone to their
highest education starting in 1988, when the consistent question about
degrees is implemented;
*creating 'degXX' for highest degree received;

data a; set a;
	rename
	'Q3-10B_1988'n = deg88
	'Q3-10B_1989'n = deg89
	'Q3-10B_1990'n = deg90
	'Q3-10B_1991'n = deg91
	'Q3-10B_1992'n = deg92
	'Q3-10B_1993'n = deg93
	'Q3-10B_1994'n = deg94
	'Q3-10B_1996'n = deg96
	'Q3-10B_1998'n = deg98
	'Q3-10B_2000'n = deg00
	'Q3-10B_2002'n = deg02
	'Q3-10B_2004'n = deg04
	'Q3-10B_2006'n = deg06
	'Q3-10B_2008'n = deg08
	'Q3-10B_2010'n = deg10
	'Q3-10B_2012'n = deg12
	'Q3-10B_2014'n = deg14
	'Q3-10B_2016'n = deg16;
	run;

	proc freq data=a;
		tables deg88 deg94 deg02 deg12 / missing;
		run;
	*it appears everyone was asked in 1988, I believe the valid
	missings are those who hav enot had formal schooling;
	*checking here;
	proc print data=a (obs=50);
		var deg88 xedu79;
		where deg88 = .V;
		run;
	*nope, the valid missings definitely have values for highest
	grade achieved in 1979;

	***from questionnaire (https://www.nlsinfo.org/sites/nlsinfo.org/
		files/attachments/121211/NLSY79_1988_Quex.pdf), deg88 = .V
		means person achieved less than HS degree;

	*figuring out what 'other' degree is;
	proc freq data=a;
		tables xedu88;
		where deg88 = 8;
		run;

	proc means data=a;
		var 
			xedu79
			xedu80
			xedu81
			xedu82
			xedu83
			xedu84
			xedu85
			xedu86
			xedu87
			xedu88;
		where deg88 = 8;
		run;
 
	proc print data=a;
		var
			caseid
			xedu79
			xedu80
			xedu81
			xedu82
			xedu83
			xedu84
			xedu85
			xedu86
			xedu87
			xedu88;
		where deg88 = 8;
		run;

	*I can't, for the life of me, figure out what 'other' is,
		so I will leave that as it's own group for now and 
		come back to it after I determine education in the years
		before 88;

	*making new degXX vars to create education groups;
	data a; set a;
		if deg88 = .V then deg88 = 0;
		if deg88 = 1 then deg88 = 1;
		if deg88 = 2 then deg88 = 2;
		if deg88 >=3 and deg88 <8 then deg88 = 3;
		label deg88 = "highest education by degree 88";
		run;

		proc format;
			value degf
				0 = "no degree"
				1 = "HS degree or GED"
				2 = "associate"
				3 = "bachelors or greater"
				8 = "other";
				run;

		data a; set a;
			format deg88 degf.;
			run;

			proc freq data=a;
				tables deg88;
				run;

	*ok, deg88 is set so now assign new values to the subsequent
	deg variables;

	data a; set a;
		array deg (16)
			deg90
			deg91
			deg92
			deg93
			deg94
			deg96
			deg98
			deg00
			deg02
			deg04
			deg06
			deg08
			deg10
			deg12
			deg14
			deg16
			;
		do i = 1 to 16;
		if deg(i) =.V then deg(i) = deg88;
		end;
		run;

		proc freq data=a; tables deg94;
		run;
		proc freq data=a; tables deg94; format _all_; run;
	
	data a; set a;
		array deg (17)
			deg89
			deg90
			deg91
			deg92
			deg93
			deg94
			deg96
			deg98
			deg00
			deg02
			deg04
			deg06
			deg08
			deg10
			deg12
			deg14
			deg16
			;
		do i = 1 to 17;
		if deg(i) = .V then deg(i) = deg88;
		if deg(i) >=3 and deg(i) <8 then deg(i) = 3;
		end;
		run;

		proc freq data=a; tables deg94; format _all_; run;

*assigning formats and labels;
		
	data a; set a;
		format deg88 degf.;
		format deg89 degf.;
		format deg90 degf.;
		format deg91 degf.;
		format deg92 degf.;
		format deg93 degf.;
		format deg94 degf.;
		format deg96 degf.;
		format deg98 degf.;
		format deg00 degf.;
		format deg02 degf.;
		format deg04 degf.;
		format deg06 degf.;
		format deg08 degf.;
		format deg10 degf.;
		format deg12 degf.;
		format deg14 degf.;
		format deg16 degf.;
		label deg88 = 'highest education by degree 88';
		label deg89 = 'highest education by degree 89';
		label deg90 = 'highest education by degree 90';
		label deg91 = 'highest education by degree 91';
		label deg92 = 'highest education by degree 92';
		label deg93 = 'highest education by degree 93';
		label deg94 = 'highest education by degree 94';
		label deg96 = 'highest education by degree 96';
		label deg98 = 'highest education by degree 98';
		label deg00 = 'highest education by degree 00';
		label deg02 = 'highest education by degree 02';
		label deg04 = 'highest education by degree 04';
		label deg06 = 'highest education by degree 06';
		label deg08 = 'highest education by degree 08';
		label deg10 = 'highest education by degree 10';
		label deg12 = 'highest education by degree 12';
		label deg14 = 'highest education by degree 14';
		label deg16 = 'highest education by degree 16';
		run;

	proc means data=a; var deg88--deg16; run;

	*need to investigate Q3-10D_2008;

* After discussing with Ron on 6/7/19, because of the differences in 
question structure AND the difficulty of understanding how a bachelors
degree affects 25 year olds and 40 year olds differently, it's best
just to use years of completed education as a linear variable;

* Working with hgcrev var;
	proc means data=a; var hgc:; run;
	proc means data=a; var hgcrev:; run;
	proc freq data=a; tables hgcrev:; run;
	proc freq data=a; tables 'hgcrev82_1982'n / missing; run;
	proc freq data=a; tables 'hgcrev82_1982'n; format _all_; run;

* Renaming for ease of use;
	data a; set a;
	rename
	'HGCREV06_2006'n = educ06
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
	'HGCREV08_2008'n = educ08
	'HGCREV10_2010'n = educ10
	'HGCREV12_2012'n = educ12
	'HGCREV14_2014'n = educ14
	'HGCREV16_2016'n = educ16;
	run;

	*checking for recode and label/format;
	proc freq data=a;
		tables educ88; run;

	*some invalid missings, checking to see if they have values for the survey years
	before and after;
	proc print data=a;
		var caseid educ:;
		where educ82 = .I;
		run;

	*many can be easily recoded because they didn't change completed education in the years
	before and after, checking if this code works;
	data a; set a;
		if educ82 = .I and educ81 = educ83 then educ82 = educ81;
		run;

		proc print data=a;
			var caseid educ81 educ82 educ83;
			where caseid = 1766 or caseid = 1778 or caseid = 4683 or caseid = 6282;
			run;

		*welp, that worked;
	
	*ok, can do recodes this week for ones I'm confident about;
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

	*can use an array to create a flag for having any missing education data, but subsetting
		with where command hardcoded was faster;

* MARITAL STATUS;

proc freq data=a; tables 'MARSTAT-KEY_1982'n / missing; run;
proc freq data=a; tables marstat:; run;

*these look pretty good as-is, except there are a few non-interview
missing that should be in there;

proc print data=a;
	var caseid age82 'MARSTAT-KEY_1982'n tub82;
	where 'MARSTAT-KEY_1982'n = .N;
	run;

	*all of these individuals are missing age as well, so some
	non-interviews were retained in the dataset. will need to come
	back and check after final sample is determined;

*marstat variables are perfect as-is so just renaming;
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

	proc means data=a; var mar:; run;

ods html close; ods html;


* HEALTH INSURANCE;

*identifying the variables i want;
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
one variable for all responses;

proc freq data=a; tables 'Q11-79_2002'n; run;

proc print data=a;
	var caseid tub82--tub16;
	run;

* LONG FORMAT DATASET;

* Can probably do this with a macro, but trying individually first to make sure I
	have the procedure down;

* Tubal;
proc transpose data=a out=trantub;
	var caseid tub82--tub16;
	by caseid;
	run;

data trantub; set trantub (rename=(col1=tub));
	year=input(substr(_name_,4),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;

* Age;
proc transpose data=a out=tranage;
	var caseid &age;
	by caseid;
	run;

data tranage; set tranage (rename=(col1=age));
	year=input(substr(_name_,4),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;

* Marital status;
%let mar = mar79	mar80	mar81	mar82	mar83	mar84	mar85	mar86	mar87	
mar88	mar89	mar90	mar91	mar92	mar93	mar94	mar96	mar98	mar00	mar02	
mar04	mar06	mar08	mar10	mar12	mar14	mar16;

proc transpose data=a out=tranmar;
	var caseid &mar;
	by caseid;
	run;

data tranmar; set tranmar (rename=(col1=mar));
	year=input(substr(_name_,4),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;

* Education;
%let educ = educ06	educ79	educ80	educ81	educ82	educ83	educ84	educ85	educ86	educ87	
educ88	educ89	educ90	educ91	educ92	educ93	educ94	educ96	educ98	educ00	educ02	
educ04	educ08	educ10	educ12	educ14	educ16;

proc transpose data=a out=traneduc;
	var caseid &educ;
	by caseid;
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

proc transpose data=a out=trannumkid;
	var caseid &numkid;
	by caseid;
	run;

data trannumkid; set trannumkid (rename=(col1=numkid));
	year=input(substr(_name_,7),5.);
	drop _name_ _label_;
	if year = . then delete;
	run;

	proc print data=trannumkid (obs=80); run;
