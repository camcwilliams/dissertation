*******************************************
************** DISSERTATION ***************
*********** VARIABLE TREATMENT ************
************* NSFG 2011-2015 **************
******************************************;

*This program is being created separately to do variable exploration and treatment work,
in order to separate the code and make the main file cleaner. The goal here is to eventually 
have a command from the main program to run this at the beginning. Therefore, this file does
not include code to pull in the datasets and formats, those can happen from 
"U:\Dissertation\nsfg_analysis_dissertation.sas";

*Lower-case labels are mine, upper-case labels are from NCHS;

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

	* creating a new age variable for dealing with education;
	data a; set a;
		if rscrage>14 and rscrage<20 then aged = 1 ;
		if rscrage>19 and rscrage<23 then aged = 2 ;
		if rscrage>22 and rscrage<25 then aged = 3 ;
		if rscrage>24 and rscrage<30 then aged = 4 ;
		if rscrage>29 and rscrage<35 then aged = 5 ;
		if rscrage>34 and rscrage<40 then aged = 6 ;
		if rscrage>39 and rscrage<45 then aged = 7 ;
		label aged="age categories for dealing with education";
		run;
	

		/****************************************
		*** Age as continuous vs categorical ***
		****************************************;

		* Age and non-use;
			proc freq; tables nouse*rscrage / nofreq norow nopercent; run;

		* Age and sterilization;
			proc freq; tables rscrage*ster / nofreq nocol nopercent; run;

		* Age and conceptually appropriate contraceptive groups;

			proc freq; tables rscrage*effmeth / nofreq nocol nopercent; run;

		* Age and all contraceptive/reproductive status groups;
			* Could be used for stacked bar charts;
			proc freq; tables rscrage*allrepro / nofreq nocol nopercent; run;

			proc freq; tables agecat*allrepro / nofreq nocol nopercent; run;
		*/

*** Contraceptive Use;

	/*proc freq data=a; tables constat1; run;*/

	* creating a new constraceptive variable (bc) that is the same as constat1
	but sets people not at risk of unintended pregnancy to missing;
	data a; set a;
		bc = constat1;
		if constat1>29 and constat1<=41 then bc=.;
		label bc="bc method with not at risk of UIP set to missing";
		run;
		*note that postpartum is in this group, but is restricted to women less than
		2 months postpartum;

		/*proc freq; tables bc; run;
		proc sort; by elig; run;
		proc freq; tables bc; by elig; run;
		proc freq; tables elig; run;
		proc freq; tables bc*constat1; run;*/

	* making a dichotomous variable for using bc or not, making two versions (nouse, bcyes) so 1/0 is logical;
	data a; set a;
		nouse = bc;
		if bc = 42 then nouse = 1;
		if bc < 42 and bc > 0 then nouse = 0;
		if nouse = 1 then bcyes = 0;
		if nouse = 0 then bcyes = 1;
		label nouse="at risk of UIP but not using contr = 1 (opposite of bcyes)";
		label bcyes="at risk of UIP and using any method = 1 (opposite of nouse)";
		run;
	
	* ster: sterilized, using non-sterilization contraception, not contracepting;
	data a; set a;
		ster = bc;
		if bc = 1 or bc = 2 then ster = 1;
		if bc ne 1 and bc ne 2 and bc ne 35 and bc ne 36 and bc ne 33 and bc ne 34 
		and bc ne 38 and bc ne . then ster =2;
		if bc = 42 then ster = 3;
		label ster="sterilized, using non-sterilization contraception, not contracepting";
		run;

	* creating conceptually appropriate method groups;
	data a; set a;
		effmeth = bc;
		if ster=1 then effmeth = 1;
		if bc=3 or bc=10 then effmeth = 2;
		if bc=5 or bc=6 or bc=7 or bc=8 then effmeth = 3;
		if bc=11 or bc=12 or bc=14 or bc=16 or bc=17 or bc=18 then effmeth = 4;
		if bc=9 then effmeth = 5;
		if bc=19 or bc=20 then effmeth = 6;
		if bc=21 then effmeth = 7;
		if bc=22 then effmeth = 8;
		if ster=3 then effmeth = 9;
		label effmeth="conceptually appropriate method groups";
		run;

	* creating a var with method groups and non-uip groups;
	data a; set a;
		allrepro = bc;
		if ster=1 then allrepro = 1;
		if bc=3 or bc=10 then allrepro = 2;
		if bc=5 or bc=6 or bc=7 or bc=8 then allrepro = 3;
		if bc=11 or bc=12 or bc=14 or bc=16 or bc=17 or bc=18 then allrepro = 4;
		if bc=19 or bc=20 then allrepro = 6;
		if bc=21 then allrepro = 7;
		if bc=9 then allrepro = 8; 
		if bc=22 then allrepro = 9;
		if ster=3 then allrepro = 10;
		if constat1=30 then allrepro = 11;
		if constat1=31 then allrepro = 12;
		if constat1=32 then allrepro = 13;
		if constat1=33 or constat1=34 or constat1=35 or constat1=36 or constat1=38 or constat1=39 
		then allrepro = 14;
		if constat1=40 then allrepro = 15;
		if constat1=41 then allrepro = 16;
		label allrepro="all possible contracept or repro groups";
		run;

		/*proc sort; by allrepro; run;
		proc freq; tables bc; by allrepro; run;
		proc freq; tables constat1; where allrepro = .; run;*/

		
	data a; set a;
		bcc = .;
		if effmeth = 1 then bcc = 1;
		if effmeth = 2 or effmeth = 3 then bcc = 2;
		if effmeth = 4 or effmeth = 5 or effmeth = 6 or effmeth = 7 or effmeth = 8 then bcc = 3;
		if effmeth = 9 then bcc = 4;
		label bcc="4-cat crude contraception";
		run;

		/*proc freq data=a; tables effmeth*bc4; run;*/

		proc freq data=a; tables bc; run;

		*below are a series of variables for doctor vs self-controlled. i don't think they'll
		be used in the regression tree but I am keeping them in here just in case;
			data a; set a;
				doc = bc;
				if bc>=1 and bc<=11 then doc = 1;
				if bc>10 then doc = 2;
				run;

				proc freq data=a; tables bc*doc; run;

			data a; set a;
				docmeth = .;
				if bc = 1 or bc = 2 then docmeth = 1;
				if bc = 3 or bc = 9 then docmeth = 2;
				if bc = 5 or bc = 6 or bc = 7 then docmeth = 3;
				if bc = 4 then docmeth = 4;
				run;

				proc freq data=a; tables docmeth * bc; run;

			data a; set a;
				selfmeth = .;
				if bc = 12 then selfmeth = 1;
				if bc = 14 or bc = 17 or bc = 18 then selfmeth = 2;
				if bc = 21 then selfmeth = 3;
				if bc = 19 or bc = 20 then selfmeth = 4;
				run;

		* regression tree variables;
		*LEAVES;
		data a; set a;
			meth = bc;
			if bc = 1 then meth = 1;
			if bc = 2 then meth = 2;
			if bc = 3 or bc = 10 then meth = 3;
			if bc = 5 then meth = 4;
			if bc = 6 then meth = 5;
			if bc = 7 or bc = 8 then meth = 6;
			if bc = 9 then meth = .;
			if bc = 19 or bc = 20 then meth = 7;
			if bc = 12 then meth = 8;
			if bc = 11 or bc = 16 then meth = 9;
			if bc = 14 or bc = 17 or bc = 18 then meth = 10;
			if bc = 21 then meth = 11;
			if bc = 22 then meth = .;
			if bc = 42 then meth = 12;
			label meth = "all methods, other and EC removed";
			run;

		*TWIGS;
		data a; set a;
			perm = .;
			if meth = 1 then perm = 1;
			if meth = 2 then perm = 2;
			label perm = "permanent methods";
			run;
		data a; set a;
			rev = .;
			if meth = 3 then rev = 1;
			if meth = 4 then rev = 2;
			label rev = "reversible long-term methods";
			horm = .;
			if meth = 5 then horm = 1;
			if meth = 6 then horm = 2;
			label horm = "hormonal short-term methods";
			barr = .;
			if meth = 8 then barr = 1;
			if meth = 9 then barr = 2;
			label barr = "barrier methods";
			nobarr = .;
			if meth = 10 then nobarr = 1;
			label nobarr = "spermicide";
			run;

		*BRANCHES;
		data a; set a;
			long = .;
			if perm ne . then long = 1;
			if rev ne . then long = 2;
			label long = "long-term methods";
			short = .;
			if horm ne . then short = 1;
			if meth = 7 then short = 2;
			label short = "short-term methods";
			prep = .;
			if barr ne . then prep = 1;
			if nobarr ne . then prep = 2;
			label prep = "requires preparation";
			noprep = .;
			if meth = 11 then noprep = 1;
			if meth = 12 then noprep = 2;
			label noprep = "requires no preparation";
			run;

		/*proc freq data=a;
			tables rev horm barr nobarr long short prep noprep;
			run;

		proc freq data=a;
			tables noprep;
			run;*/

		*TRUNK (Yes I will stretch this metaphor);
		data a; set a;
			before = .;
			if long ne . then before = 1;
			if short ne . then before = 2;
			label before = "arranged before sex";
			during = .;
			if prep ne . then during = 1;
			if noprep ne . then during = 2;
			label before = "arranged during sex";
			run;

			/*proc freq data=a; tables before during; run;*/

		data a; set a;
			allr = .;
			if before ne . then allr = 1;
			if during ne . then allr = 2;
			run;


*** Subfecundity;

	/*proc freq data=a; tables fecund; run;
		*Recode specs and description of groups: 
		https://www.icpsr.umich.edu/icpsradmin/nsfg/variable/recode_spec/cycle8.1/fem/FECUND.pdf;
		*May be difficult to use because fecund = 1 will be fully collinear with sterilization
		as contraceptive use;*/

		/*Looking at diagnosed infertility;

		proc freq; tables infert; run;
		proc freq; tables infert*fecund; run;
		proc freq; tables fecund; run;
		proc print data=a;
		var caseid fecund infert POSIBLPG REASIMPR REASIMPP 
		constat1 strloper;
		where fecund=3 and infert=3;
		run;

		*I can't figure out what's going on with fecund=3 and
		infert=3, there are people who are considered "fecund" in
		the infertility variable that are considered "nonsurgically
		sterile" in the fecundity variable. Probably should just
		use the fecund variable when considering 
		infertility/fecundity. I think maybe the issue is that the
		infert variable erred on the side of caution with nonsurgical
		sterilization;*/

		*I don't think there is a variable about perceived subfecundity
		except in the motivation questions after reporting non-use,
		need to investigate further;

		
		*Upon further investigation, canhaver or posiblpg
			and some associated vars might work;
		/*proc freq data=a;
			tables posiblpg posiblpg*bcc posiblpg*hisprace2;
			run;

		proc freq data=a;
			tables canhaver;
			run;

		proc freq data=a;
			tables canhaver*bcc;
			run;

		proc freq data=a;
			tables canhaver*posiblpg;
			run;

		proc freq data=a;
			tables canhaver*pregnono;
			run;

		proc freq data=a;
			tables reasdiff:;
			run;

		proc freq data=a;
			tables reasdiff1*reasdiff2;
			run;

		*Reasdiff1--5 are also worth exploring;
		proc freq*/


*** Age at first birth;

	/*
		proc means; var agefirst; run;
		proc print data = a (obs=15); var caseid agefirst agebaby1; run;
		*that worked, agefirst is the continuous var;
		*Recode specs:
		https://www.icpsr.umich.edu/icpsradmin/nsfg/variable/recode_spec/cycle8.1/fem/AGEBABY1.pdf;
		*commenting this out and making a nice data set for posterity;*/

			*agebaby1 to real years;
			data a; set a;
				agefirstbirth = agebaby1/100;
				label agefirstbirth="real years at first birth (agebaby1/100)";
				run;

			data a; set a;
				agefirstbirth_all = agefirstbirth;
				if agefirstbirth = . then agefirstbirth_all = 0;
				label agefirstbirth_all="real years at first birth, no birth = 0";
				run;

			data a; set a;
				if agebaby1 < 2500 then agebabydichot = 1;
				if agebaby1 >= 2500 then agebabydichot = 2;
				label agebabydichot = "categorical age at first birth, 25+ = 2";
				run;

			proc freq; tables agebaby1; run;

			data a; set a;
				agebabycat = agefirstbirth;
				if agefirstbirth = . then agebabycat = 0;
				if agefirstbirth < 20 and agefirstbirth >= 8 then agebabycat = 1;
				if agefirstbirth < 25 and agefirstbirth >= 20 then agebabycat = 2;
				if agefirstbirth < 30 and agefirstbirth >= 25 then agebabycat = 3;
				if agefirstbirth < 35 and agefirstbirth >= 30 then agebabycat = 4;
				if agefirstbirth < 40 and agefirstbirth >= 35 then agebabycat = 5;
				if agefirstbirth < 45 and agefirstbirth >= 40 then agebabycat = 6;
				label agebabycat = "age at first birth, .=0, 1=<20, 6=40-44";
				run;
			
			/* trying to figure out why agebabycat wasn't working, of course it was
			because i made a stupid coding mistake. glad the troubleshooting worked!;
			proc print data = a (obs=20); var agefirstbirth; run;
			proc freq; tables agebabycat; run;
			proc means; var agefirstbirth; run;

			proc means; var agebaby1; run;
			proc freq; tables agebaby1; run;
			proc freq; tables agefirstbirth; run;*/

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
				label edu = "education categories";
				run;

*** Race;

	/*proc freq; tables race; run;
		*it appears the raw variables used to create this are not available, which 
		won't work because i would like to have more granularity...;
		*Recode specs here: https://www.icpsr.umich.edu/icpsradmin/nsfg/variable/recode_spec/cycle8.1/fem/RACE.pdf;
		*they do have a separate hispanic origin variable;
		*Recode specs here: https://www.icpsr.umich.edu/icpsradmin/nsfg/variable/recode_spec/cycle8.1/fem/HISPANIC.pdf;

	proc freq; tables race*hispanic; run;
		*hispanic folks fall into all three of the race categories, the greatest percent
		being 'other';

	*I see that there are additional race variables I didn't see originally,
	working on them here:;

	proc freq; tables race hispanic rscrrace hisprace; run;
		*error from SAS saying nraced and hisprace2f not found, after more
		investigation I see they are formats, which subsequently helped me 
		find more race vars;
		*race is just black, white, other;
		*hispanic is just hispanic origin, doesn't include race;
		*rscrrace is R's race as reported in screener;
		*hisprace is race and hispanic origin - hispanic, 
		NH white, NH black, NH other;

	*some additional variables I found;
	proc freq; 
		tables hisprace2 hsbnrace1 curcohnrace coh1nrace fsexnrace p1ynrace1; 
		run;
		*hisprace2 is same as hisprace but using 1997 OMB standards;
		*the rest are hisprace-like vars for various partners;

	proc freq; tables numrace; run;

	proc freq; tables hisprace2; run;	
	*/

*** Birth Desires, Intention, Ambivalence - INCLUDES INDIVIDUAL AND JOINT WITH PARTNER;

	/*proc freq;
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
		*/

	* Quick fix on a recode I think nchs missed;
	data a; set a;
		if jintendn = 98 then jintendn = .;
		run;

	/*Checking intention/want one more time;
	proc freq data=a;
		tables rwant;
		run;

	proc freq data=a;
		tables rwant*bcc;
		run;

	proc freq data=a;
		tables intend;
		run;
	*/

	* Quick fix on rwant;
	data a; set a;
		if rwant = 8 then rwant = 9;
		run;

*** Income;

	/*proc freq; tables poverty; run;
	proc means; var poverty; run;
	proc sgplot; histogram poverty; run;
	proc print data=a (obs=20); var caseid poverty poverty_i totinc; format _all_ ; run;
	proc freq; tables poverty*agecat; run;
	proc freq; tables poverty; format _all_; run;*/
	*For now, poverty will need to be the variable. Need to talk to Ron about 
	whether to include it as a continuous or categorical. If considering it categorical
	with it's original groups, many of the groups get pretty small, 3 or 4 respondents;

	* poverty level categories;
	data a; set a;
		povlev = .;
		if poverty < 100 and poverty > 0 then povlev = 1;
		if poverty < 200 and poverty > 99 then povlev = 2;
		if poverty < 300 and poverty > 199 then povlev = 3;
		if poverty < 400 and poverty > 299 then povlev = 4;
		if poverty < 500 and poverty > 399 then povlev = 5;
		if poverty >= 500 then povlev = 6;
		label povlev = "poverty level categories";
		run;


*** Health Insurance;

	* going to use the existing variable, although it's not quite as precise as
	I would like;
	/*proc freq; tables curr_ins; run;*/

	/*SAS Macros: https://support.sas.com/resources/papers/proceedings10/028-2010.pdf,
	https://stats.idre.ucla.edu/sas/seminars/sas-macros-introduction/;
	%let categorical = povlev edu;

	proc freq; tables &categorical; run;*/

*** Relationship History;

	/*
	proc freq; tables marstat; run;
	proc freq; tables prevcohb; run;*/

	*widowed is a very small group, creating a new variable here to see if that's what's
	causing the model separation;
	data a; set a;
		mard = rmarital;
		if rmarital = 3 then mard = 4;
		run;


*** Live Birth and Parenting History;

	/*
	proc freq; tables nchildhh; run;
	proc freq; tables nbabes_s; run;
	proc freq; tables numbabes*parity nbabes_s*parity; run;

	proc freq; tables reactslf numkdhh numfmhh; run;
	

	*Was planning to use parity, but I think I should check on pregnancy hx;
	proc freq data=a;
		tables everpreg pregnum;
		run;

	proc freq data=a;
		tables pregnum*parity;
		run;
	*In the end I think parity is sufficient;
	*/

*****************************************
Creating dummy outcome variables for regression outcomes
******************************************;

*macro based on this;
	/*data a; set a;
	if effmeth=1 then effmeth_1=1;
	if effmeth = . then effmeth_1=.;
	if effmeth ne . and effmeth ne 1 then effmeth_1=0;
	run;*/

	%macro do_loop;

	data a;
	set a;

	%do i = 1 %to 9;
		if effmeth = &i. then effmeth_&i. = 1;
		if effmeth = . then effmeth_&i. = .;
		if effmeth ne . and effmeth ne &i. then effmeth_&i. = 0;
	%end;

	run;

	%mend do_loop;

	%do_loop;

	data a;
	set a;
	label effmeth_1 = "sterilized";
	label effmeth_2 = "IUD, implant";
	label effmeth_3 = "injection, pill, patch, ring";
	label effmeth_4 = "condom, diaphragm, sponge, foam, insert, jelly";
	label effmeth_5 = "emergency contraception";
	label effmeth_6 = "periodic abstinence";
	label effmeth_7 = "withdrawal";
	label effmeth_8 = "other";
	label effmeth_9 = "not using contraception";
	run;


	/*proc freq data=a; tables effmeth*effmeth_:; run;*/

*****************************************
Creating macros
******************************************;

* Full list of variables of interest;
%let varlist =
caseid
rscrage
agecat
aged
constat1
constat2
constat3
constat4
mainnouse
currmeth1
currmeth2
currmeth3
currmeth4
bc
nouse
bcyes
ster
effmeth
bcc
allrepro
fecund
educat
poverty
nbabes_s
nchildhh
whynousing1
race
dipged
degrees
hieduc
agebaby1
agefirstbirth
rmarital
prevcohb
timescoh
parity
everpreg
pregnum
hisprace2
religion
curr_ins
numkdhh
numfmhh
rwant
probwant
pwant
jintend 
jsureint
jintendn
jintnext
intend
sureint 
intnext 
reactslf
edu
agefirstbirth_all
mard
;

data b; set a;
	keep &varlist;
	run;

proc contents data = b; title "VARIABLES OF INTEREST (varlist)"; run;

title;

* Full list of variables of interest with imputed values;
%let implist =
constat1_i
constat2_i
constat3_i
constat4_i
fecund_i
educat_i
poverty_i
nchildhh_i
race_i
hieduc_i
agebaby1_i
rmarital_i
timescoh_i
parity_i
pregnum_i
hisprace2_i
religion_i
curr_ins_i
numkdhh_i
numfmhh_i;

data b; set a;
	keep &implist;
	run;

proc contents data = b; title "IMPUTED VARIABLES OF INTEREST (implist)"; run;

title;


* Full list of variables that are or can be used as categorical;
%let catlist =
agecat
aged
constat1
constat2
constat3
constat4
mainnouse
currmeth1
currmeth2
currmeth3
currmeth4
bc
nouse
bcyes
ster
effmeth
bcc
allrepro
fecund
educat
poverty
nbabes_s
nchildhh
whynousing1
race
dipged
degrees
hieduc
agebaby1
rmarital
prevcohb
timescoh
parity
everpreg
pregnum
hisprace2
religion
curr_ins
numkdhh
numfmhh
rwant
probwant
pwant
jintend 
jsureint
jintendn
jintnext
intend
sureint 
intnext 
reactslf
edu
mard
;

data b; set a;
	keep &catlist;
	run;

proc contents data = b; title "CATEGORICAL VARIABLES OF INTEREST (catlist)"; run;

title;

* Full list of variables that are or can be used as continuous;
%let contlist =
caseid
rscrage
fecund
poverty		
nbabes_s
nchildhh
agebaby1
agefirstbirth
prevcohb
timescoh
parity
pregnum
numkdhh
numfmhh
jintendn
agefirstbirth_all;
;

data b; set a;
	keep &contlist;
	run;

proc contents data = b; title "CONTINUOUS VARIABLES OF INTEREST (contlist)"; run;

title;

data a; set a; run;
