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
	'numkid12_2012'n
	'ageatint_2012'n
	'ageatint_2014'n
	'ageatint_2016'n;
	where 'numkid12_2012'n ne .N;
	run;

*Dataset already in wide format, yippee!;

