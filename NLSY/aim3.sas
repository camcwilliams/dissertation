**********************************

AIM 3 ANALYSIS: TUBAL LIGATION BY AGE, LONGITUDINAL
USING NLSY

**********************************;

/*
The name literals are making my usual approach difficult, so just going to run nlsy.sas
by hand for now;

libname library "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY";
%include "C:\Users\Christine McWilliams\Box Sync\Education\Dissertation\AnalyticFiles\NLSY\nlsy.sas";
*/

*First exploring dataset;
proc contents data=library.nlsy; run;

data work.nlsy;
	merge new_data new_ster; 
	by 'CASEID_1979'n; 
	run;

data a; set nlsy; run;

proc freq data=a; tables 'ageatint_2016'n; run;

proc freq data=a; tables 'ageatint_2014'n; run;

proc print data=a (obs=20);
	var
	'CASEID_1979'n 
	'sample_id_1979'n
	'numkid12_2012'n
	'ageatint_2012'n
	'ageatint_2014'n
	'ageatint_2016'n;
	run;

proc print data=a (obs=20);
	var
	'CASEID_1979'n 
	'sample_id_1979'n
	'SAMPLE_SEX_1979'n 
	'ageatint_2000'n
	'Q9-64H_2000'n
	'Q9-65~000009_2000'n
	'numkid12_2012'n
	'ageatint_2012'n
	'ageatint_2014'n
	'ageatint_2016'n;
	where 'sample_sex_1979'n = 2;
	run;

*Dataset already in wide format, yippee!;

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

	*checking to see if SAS will let me select multiple vars using
		the name literals and :;
	proc freq data=test;
		tables 'q9:'n;
		run;
	*sadly no;


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

*Restricting sample to women only for ease of use as I explore;
data a; set a;
	if 'sample_sex_1979'n = 1 then delete;
	run;


*Creating easier to use age vars;
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

	proc freq data=a; tables tub84; run;

*Creating easier to use tubal vars;	
data a; set a;
	tub84 = 0;
	if age84 = .N then tub84 = .;
	if 'Q9-65F~000009_1984'n = 9 then tub84 = 1;
	run;

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
data b; set a;
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

data b; set b;



