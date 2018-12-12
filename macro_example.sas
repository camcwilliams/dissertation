%macro do_loop;

data DEFBIS.Taux_fec_2006_2010;
set DEFBIS.Taux_fec_2006_2010;

%do i = 15 %to 49;
  Taux_&i. = 1000 * N_&i. / (5 * P_&i.);
%end;

run;

%mend do_loop;

%do_loop;


*procedure on individual variables from a list;
%let confounders=
			allrepro
			bc
			curr_ins
			edu
			fecund
			intend
			jintend
			parity
			poverty
			prevcohb
			rmarital
			religion
			nchildhh;

%macro loop(vlist);

%do i=1 %to 13;

proc freq data=a;
	tables &i. / out=out_&i.;
	weight weightvar;
	run;

%end;

%mend;

%loop(&confounders);


	** ARRAY **;
	*this didn't work but i think i'm on the right track:;
		data a; set a;
		array ditto {7}
		hisprace2
		povlev
		edu
		fecund 
		rmarital
		curr_ins
		religion;
		do i = 1 to 7;
			proc surveylogistic;
			weight weightvar;
			model effmeth_1 = i;
			end;
			run;

*an example is here: https://blogs.sas.com/content/iml/2017/02/13/run-1000-regressions.html;

%let confounders =
		hisprace2
		povlev
		edu
		fecund 
		rmarital
		curr_ins
		religion;

%macro ditto (&confounders,7);
%do i = 1 %to 7;
			proc surveylogistic;
			weight weightvar;
			model effmeth_1 = &confounders;
			run;

		%end;
		%mend;

		%ditto;

%let confounders =
		curr_ins
		edu
		fecund
		intend
		jintend
		parity
		povlev
		prevcohb
		rmarital
		religion
		nchildhh;


*the macro below is to run multiple crosstabs so I can output
them to xls for easier formatting;
%macro ditto;
	%let i=1;
	%do %until(not %length(%scan(&confounders,&i)));
	proc freq data=a;
		weight weightvar;
		tables bcc*%scan(&confounders,&i) / out=ditto_&i nopercent norow nocol;
	run;
	%let i=%eval(&i+1);
	%end;
%mend ditto;

%ditto;

proc print data=ditto_3; run;

data alldittos; set ditto_1 ditto_2; run;

proc print data=alldittos; run;

	/*proc transpose data=ditto_3 out=ditto3trans; run;
	proc print data=ditto3trans; run;
	proc freq data=a;
		tables curr_ins*ster / out=ditto3test;
		weight weightvar;
		run;
		proc print data=ditto3test; run;*/
