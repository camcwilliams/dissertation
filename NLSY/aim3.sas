**********************************

AIM 3 ANALYSIS: TUBAL LIGATION BY AGE, LONGITUDINAL
USING NLSY

**********************************;

*First exploring dataset;
data a; set library.nlsy; run;

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

