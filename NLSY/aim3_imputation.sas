*** Working on multiple imputation for income;

	*Need to check on distribution first;

	*First checking on baseline;
	proc freq data=a;
		tables incwin79 / missing;
		run;
		*there's a lot of missing at baseline, so it may not be the best comparison;

	*Are 1982 missings the same as 1979 missings;
	proc freq data=a;
		tables incwin79*incwin82 / missing;
		where incwin79 = .D or incwin79 = .I or incwin79 = .R;
		run;
		*Around 25% of 1979 missings are also missing in 1982;

	*going to do the same thing with formats for ease of interpretation;
	proc freq data=a;
		tables income79*income82 / missing norow nocol;
		run;

	*creating new vars so I can view both histograms in the same frame;
	data inc; set a;
		inc79_miss82 = .;
		if incwin82 = .D or incwin82 = .I or incwin82 = .R then inc79_miss82 = income79;
		inc79_nonmiss82 = .;
		if incwin82 ne .D or incwin82 ne .I or incwin82 ne .R then inc79_nonmiss82 = income79;
		inc79_miss16 = .;
		if incwin16 = .D or incwin16 = .I or incwin16 = .R then inc79_miss16 = income79;
		inc79_nonmiss16 = .;
		if incwin16 ne .D or incwin16 ne .I or incwin16 ne .R then inc79_nonmiss16 = income79;
		run;

	*1982 missing income data vs complete income data;
	proc sgplot data=inc;
		histogram inc79_miss82 / binwidth = 2000 transparency = 0.5;
		histogram inc79_nonmiss82 / binwidth = 2000 transparency = 0.5;
		run;

	*2016 missing income data vs complete income data;
	proc sgplot data=inc;
		histogram inc79_miss16 / binwidth = 2000 transparency = 0.5;
		histogram inc79_nonmiss16 / binwidth = 2000 transparency = 0.5;
		run;

	*Probing correlation and linear reg coefficient;
	proc corr data=inc pearson spearman kendall hoeffding;
		var inc79_miss82 inc79_nonmiss82;
		run;

*making some macros for ease of use with imputation program;

%let incwin_impute = incwin79 incwin82	incwin84	incwin86	incwin88	
incwin90	incwin92	incwin94	incwin96	incwin98	incwin00	
incwin02	incwin04	incwin06	incwin08	incwin10	incwin12	
incwin14	incwin16;

%let education_impute = educ06	educ82	educ84	
educ86	educ88	educ90	educ92
educ94	educ96	educ98	educ00	educ02	educ04	educ06	educ08	educ10	
educ12	educ14	educ16;

%let numkid_impute = numkid82	numkid84	numkid86	numkid88	numkid90	
numkid92	numkid94	numkid96	numkid98	numkid00	numkid02	numkid04	
numkid06	numkid08	numkid10	numkid12	numkid14	numkid16;

%let marstat_impute = mar82	mar84	mar86	mar88	mar90	mar92	mar94	mar96	
mar98	mar00	mar02	mar04	mar06	mar08	mar10	mar12	mar14	mar16;

%let famsize_impute = famsize_1982	famsize_1984	famsize_1986	famsize_1988	
famsize_1990	famsize_1992	famsize_1994	famsize_1996	famsize_1998	
famsize_2000	famsize_2002	famsize_2004	famsize_2006	famsize_2008	
famsize_2010	famsize_2012	famsize_2014	famsize_2016;


*Running the imputation code;

proc mi data=a nimpute=20 out=mi_mvn seed=54321;
var race 'age1b16_2016'n
incwin79 incwin82	incwin84	incwin86	incwin88	
incwin90	incwin92	incwin94	incwin96	incwin98	incwin00	
incwin02	incwin04	incwin06	incwin08	incwin10	incwin12	
incwin14	incwin16
educ82	educ84	
educ86	educ88	educ90	educ92
educ94	educ96	educ98	educ00	educ02	educ04	educ06	educ08	educ10	
educ12	educ14	educ16
numkid82	numkid84	numkid86	numkid88	numkid90	
numkid92	numkid94	numkid96	numkid98	numkid00	numkid02	numkid04	
numkid06	numkid08	numkid10	numkid12	numkid14	numkid16
mar82	mar84	mar86	mar88	mar90	mar92	mar94	mar96	
mar98	mar00	mar02	mar04	mar06	mar08	mar10	mar12	mar14	mar16
famsize_1982	famsize_1984	famsize_1986	famsize_1988	
famsize_1990	famsize_1992	famsize_1994	famsize_1996	famsize_1998	
famsize_2000	famsize_2002	famsize_2004	famsize_2006	famsize_2008	
famsize_2010	famsize_2012	famsize_2014	famsize_2016;
run;


proc mi data=a nimpute=20 out=mi_mvn seed=54321;
fcs plots=trace(mean std); 
var race 'age1b16_2016'n
incwin79 incwin82	incwin84	incwin86	incwin88	
incwin90	incwin92	incwin94	incwin96	incwin98	incwin00	
incwin02	incwin04	incwin06	incwin08	incwin10	incwin12	
incwin14	incwin16
educ82	educ84	
educ86	educ88	educ90	educ92
educ94	educ96	educ98	educ00	educ02	educ04	educ06	educ08	educ10	
educ12	educ14	educ16
numkid82	numkid84	numkid86	numkid88	numkid90	
numkid92	numkid94	numkid96	numkid98	numkid00	numkid02	numkid04	
numkid06	numkid08	numkid10	numkid12	numkid14	numkid16
mar82	mar84	mar86	mar88	mar90	mar92	mar94	mar96	
mar98	mar00	mar02	mar04	mar06	mar08	mar10	mar12	mar14	mar16
famsize_1982	famsize_1984	famsize_1986	famsize_1988	
famsize_1990	famsize_1992	famsize_1994	famsize_1996	famsize_1998	
famsize_2000	famsize_2002	famsize_2004	famsize_2006	famsize_2008	
famsize_2010	famsize_2012	famsize_2014	famsize_2016;
fcs reg(&incwin_impute) nbiter =100; 
run;


proc mi data=a nimpute=20 out=mi_mvn seed=54321;
var race 'age1b16_2016'n
incwin79 incwin82
educ82
numkid82
mar82
famsize_1982;
run;

proc mi data=a nimpute=20 out=mi_mvn seed=54321;
class mar82	mar84	mar86	mar88	mar90	mar92	mar94	mar96	
mar98	mar00	mar02	mar04	mar06	mar08	mar10	mar12	mar14	mar16;
fcs plots=trace(mean std); 
var race 'age1b16_2016'n
incwin79 incwin82	incwin84	incwin86	incwin88	
incwin90	incwin92	incwin94	incwin96	incwin98	incwin00	
incwin02	incwin04	incwin06	incwin08	incwin10	incwin12	
incwin14	incwin16
educ82	educ84	
educ86	educ88	educ90	educ92
educ94	educ96	educ98	educ00	educ02	educ04	educ06	educ08	educ10	
educ12	educ14	educ16
mar82	mar84	mar86	mar88	mar90	mar92	mar94	mar96	
mar98	mar00	mar02	mar04	mar06	mar08	mar10	mar12	mar14	mar16
/*numkid82	numkid84	numkid86	numkid88	numkid90	
numkid92	numkid94	numkid96	numkid98	numkid00	numkid02	numkid04	
numkid06	numkid08	numkid10	numkid12	numkid14	numkid16

famsize_1982	famsize_1984	famsize_1986	famsize_1988	
famsize_1990	famsize_1992	famsize_1994	famsize_1996	famsize_1998	
famsize_2000	famsize_2002	famsize_2004	famsize_2006	famsize_2008	
famsize_2010	famsize_2012	famsize_2014	famsize_2016*/;
fcs reg(&incwin_impute) nbiter =100; 
run;

*This model isn't working, getting error messages that income and education are linear
combinations of other effects;

*The models with all of the variables won't work because of separation problems, so I am
going to work on removing some variables;

*Checking to see when average age is 35;

proc means data=a;
	var age90 age92 age94 age96 age98 age00;
	run;
	*1996;

*Ok, want to see where number of kids levels off;

proc means data=a;
	var numkid:;
	run;
	*Right around 2000;

*Now what about family size;
proc means data=a;
	var famsize:;
	run;
	*levels out for a bit starting at 1990 then resumes decreasing around 2004;

proc corr data=a;
	var incwin82 famsize_1982;
	run;
	*r2 = .25;

proc corr data=a;
	var incwin00 famsize_2000;
	run;
	*r2 = .13;

proc corr data=a;
	var incwin82 educ82;
	run;
	*r2 = .19;

proc corr data=a;
	var incwin00 educ00;
	run;
	*r2 = .43;

proc corr data=a;
	var incwin82 numkid82;
	run;
	*r2 = -.24;

proc corr data=a;
	var incwin00 numkid00;
	run;
	*r2 = -.11;

proc corr data=a;
	var incwin82 incwin79 incwin00;
	run;
	*r2(incwin82,incwin78) = .46, r2(incwin82,incwin00) = .26;

proc freq data=a;
	tables mar00 / missing;
	run;

proc freq data=a;
	tables mar00 / missing;
	format _all_;
	run;

data a; set a;
	if mar00 ne . then do;
	if mar00 = 0 then mar00_single = 1;
	else mar00_single = 0;
	if mar00 = 1 then mar00_married = 1;
	else mar00_married = 0;
	if mar00 = 2 then mar00_separated = 1;
	else mar00_separated = 0;
	if mar00 = 3 then mar00_divorced = 1;
	else mar00_divorced = 0;
	if mar00 = 6 then mar00_widowed = 1;
	else mar00_widowed = 0;
	end;
	run;

proc reg data=a;
	model income00 = mar00_single mar00_married mar00_separated mar00_divorced mar00_widowed;
	run;
	quit;
	*p-value is only significant for married, but all groups change the income by more than
	$1500, so I think they should be kept in;

*Using that info, going to try a few things;

proc mi data=a nimpute=20 out=mi_mvn seed=54321;
class mar82	mar84	mar86	mar88	mar90	mar92	mar94	mar96	
mar98	mar00	mar02	mar04	mar06	mar08	mar10	mar12	mar14	mar16;
var race 'age1b16_2016'n
incwin79 incwin82	incwin84	incwin86	incwin88	
incwin90	incwin92	incwin94	incwin96	incwin98	incwin00	
incwin02	incwin04	incwin06	incwin08	incwin10	incwin12	
incwin14	incwin16
educ82	educ84	
educ86	educ88	educ90	educ92
educ94	educ96
numkid82	numkid84	numkid86	numkid88	numkid90	
numkid92	numkid94	numkid96	numkid98	numkid00
mar82	mar84	mar86	mar88	mar90	mar92	mar94	mar96	
mar98	mar00	mar02	mar04	mar06	mar08	mar10	mar12	mar14	mar16
famsize_1982	famsize_1984	famsize_1986	famsize_1988	
famsize_1990	famsize_1992	famsize_1994	famsize_1996	famsize_1998	
famsize_2000	famsize_2002	famsize_2004	famsize_2006	famsize_2008	
famsize_2010	famsize_2012	famsize_2014	famsize_2016;
run;
*Can't use class statement unless you are specifying fcs or monotone;

*Need to create my own dummies, going to select never married as the baseline;
%macro marstat_dummies;
%let i=1;
%do %until(not %length(%scan(&marstat_impute,&i)));
data a; set a;
	if %scan(&marstat_impute,&i) ne . then do;
	if %scan(&marstat_impute,&i) = 1 then %scan(&marstat_impute,&i)_married = 1;
	else %scan(&marstat_impute,&i)_married = 0;
	if %scan(&marstat_impute,&i) = 2 then %scan(&marstat_impute,&i)_separated = 1;
	else %scan(&marstat_impute,&i)_separated = 0;
	if %scan(&marstat_impute,&i) = 3 then %scan(&marstat_impute,&i)_divorced = 1;
	else %scan(&marstat_impute,&i)_divorced = 0;
	if %scan(&marstat_impute,&i) = 6 then %scan(&marstat_impute,&i)_widowed = 1;
	else %scan(&marstat_impute,&i)_widowed = 0;
	end;
	run;
%let i=%eval(&i+1);
%end;
%mend marstat_dummies;

%marstat_dummies;

	*checking;
	proc means data=a;
		var mar:;
		run;

	proc freq data=a;
		tables mar82;
		run;	

proc mi data=a nimpute=20 out=mi_mvn seed=54321;
var race 'age1b16_2016'n
incwin79 incwin82	incwin84	incwin86	incwin88	
incwin90	incwin92	incwin94	incwin96	incwin98	incwin00	
incwin02	incwin04	incwin06	incwin08	incwin10	incwin12	
incwin14	incwin16
educ82	educ84	
educ86	educ88	educ90	educ92
educ94	educ96
/*numkid82	numkid84	numkid86	numkid88	numkid90	
numkid92	numkid94	numkid96	numkid98	numkid00
mar82	mar84	mar86	mar88	mar90	mar92	mar94	mar96	
mar98	mar00	mar02	mar04	mar06	mar08	mar10	mar12	mar14	mar16
famsize_1982	famsize_1984	famsize_1986	famsize_1988	
famsize_1990	famsize_1992	famsize_1994	famsize_1996	famsize_1998	
famsize_2000	famsize_2002	famsize_2004	famsize_2006	famsize_2008	
famsize_2010	famsize_2012	famsize_2014	famsize_2016*/;
run;
*OK, it runs after removing everything but income and education;

proc mi data=a nimpute=20 out=mi_mvn seed=54321;
var race 'age1b16_2016'n
incwin79 incwin82	incwin84	incwin86	incwin88	
incwin90	incwin92	incwin94	incwin96	incwin98	incwin00	
incwin02	incwin04	incwin06	incwin08	incwin10	incwin12	
incwin14	incwin16
educ82	educ84	
educ86	educ88	educ90	educ92
educ94	educ96
mar82_married mar82_separated mar82_divorced mar82_widowed mar84_married 
mar84_separated mar84_divorced mar84_widowed mar86_married mar86_separated 
mar86_divorced mar86_widowed mar88_married mar88_separated mar88_divorced 
mar88_widowed mar90_married mar90_separated mar90_divorced mar90_widowed 
mar92_married mar92_separated mar92_divorced mar92_widowed mar94_married 
mar94_separated mar94_divorced mar94_widowed mar96_married mar96_separated 
mar96_divorced mar96_widowed mar98_married mar98_separated mar98_divorced 
mar98_widowed mar02_married mar02_separated mar02_divorced mar02_widowed 
mar04_married mar04_separated mar04_divorced mar04_widowed mar06_married 
mar06_separated mar06_divorced mar06_widowed mar08_married mar08_separated 
mar08_divorced mar08_widowed mar10_married mar10_separated mar10_divorced 
mar10_widowed mar12_married mar12_separated mar12_divorced mar12_widowed 
mar14_married mar14_separated mar14_divorced mar14_widowed mar16_married 
mar16_separated mar16_divorced mar16_widowed 
/*numkid82	numkid84	numkid86	numkid88	numkid90	
numkid92	numkid94	numkid96	numkid98	numkid00
mar82	mar84	mar86	mar88	mar90	mar92	mar94	mar96	
mar98	mar00	mar02	mar04	mar06	mar08	mar10	mar12	mar14	mar16
famsize_1982	famsize_1984	famsize_1986	famsize_1988	
famsize_1990	famsize_1992	famsize_1994	famsize_1996	famsize_1998	
famsize_2000	famsize_2002	famsize_2004	famsize_2006	famsize_2008	
famsize_2010	famsize_2012	famsize_2014	famsize_2016*/;
run;
*Another linear dependency problem;


*OK, going to try income, education, and family size and see if I can get there;
proc mi data=a nimpute=20 out=mi_mvn seed=54321;
var race 'age1b16_2016'n
incwin79 incwin82	incwin84	incwin86	incwin88	
incwin90	incwin92	incwin94	incwin96	incwin98	incwin00	
incwin02	incwin04	incwin06	incwin08	incwin10	incwin12	
incwin14	incwin16
educ82	educ84	
educ86	educ88	educ90	educ92
educ94	educ96
/*numkid82	numkid84	numkid86	numkid88	numkid90	
numkid92	numkid94	numkid96	numkid98	numkid00
mar82	mar84	mar86	mar88	mar90	mar92	mar94	mar96	
mar98	mar00	mar02	mar04	mar06	mar08	mar10	mar12	mar14	mar16*/
famsize_1982	famsize_1984	famsize_1986	famsize_1988	
famsize_1990	famsize_1992	famsize_1994	famsize_1996	famsize_1998	
famsize_2000	famsize_2002	famsize_2004	famsize_2006	famsize_2008	
famsize_2010	famsize_2012	famsize_2014	famsize_2016;
run;

*It worked! Checking;
proc contents data=mi_mvn;
run;
