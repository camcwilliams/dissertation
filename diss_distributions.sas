*******************************************
************** DISSERTATION ***************
* MISSINGNESS, DISTRIBUTIONS, SAMPLE SIZES *
************* NSFG 2011-2015 **************
******************************************;

/*########### ASSESS MISSINGNESS ###########;
*########### CHECK RECODES ###########;

	proc freq; tables &implist; run;

	proc freq; tables &catlist; run;
	proc means; var &contlist; run;*/

*########### DISTRIBUTION ###########;

	proc sgplot data = a;
		histogram poverty;
		run;

		title 'poverty level distribution for Rs with imputed poverty';
		proc sgplot data = a;
		histogram poverty;
		where poverty_i = 1;
		run;
		title;

		title 'are missing poverty values due to missing income values?';
		proc freq;
			tables poverty_i*totincr_i;
			run;
		title;

	proc sgplot data = a;
		histogram agebaby1;
		run;

	proc sgplot data = a;
		vbar agecat;
		run;

			******************* FOR SAMPLE SIZE CALCULATIONS ********************;

	*race by age for sample size;
	proc freq data = a; tables agecat*race; run;

	title;

	*age at first live birth;
	proc means; var agefirstbirth; run;
	proc sgplot;
		histogram agefirstbirth;
		run;

	*age at first live birth for 35+;
	proc means; var agefirstbirth; where agecat > 4; run;
	proc sgplot;
		histogram agefirstbirth;
		where agecat > 4;
		title "age at first birth for women currently 35+";
		run;

	*income;
	proc means; var poverty; run;
	proc sgplot;
		histogram poverty;
		run;

	proc means; var poverty; where agecat > 4; run;
	proc sgplot;
		histogram poverty;
		where agecat > 4;
		run;
	/*proc print;
		var poverty agecat;
		where poverty > 450;
		run;

	proc freq;
		tables poverty;
		where poverty > 450;
		run;*/

	title "poverty for non-white respondents";
	proc means; var poverty; where race ne 2; run;
	proc sgplot;
		histogram poverty;
		where race ne 2;
		run;

	title "poverty for non-white respondents 35+";
	proc means; var poverty; where race ne 2 and agecat > 4; run;
	proc sgplot;
		histogram poverty;
		where race ne 2 and agecat > 4;
		run;

	*detouring a bit to look at whether how the relationship between age
	and some key variables is nonlinear;
	title "age at first birth by age";
	proc means; var agefirstbirth; by agecat; run;
	*yep, age at first birth differs by age group;

	title "completed education by age";
	proc freq; tables edu; by agecat; run;
	proc freq; tables agecat*edu; run;

	***************************************************************;

	*now looking at bc by age;
	proc freq data = a; tables agecat*bc / out=agecatxbc; run;

	*looking at method type by education;
	proc freq data = a; tables educat*bc; run;
	*need to change to degrees, not years of education;

	*does education affect whether a woman is sterilized, contracepting or not
	contracepting?;
	proc freq;
		tables ster*edu;
		run;
	*it appears to, so going to check whether it does after restricting to 
	women in the older age groups;
	proc freq;
		tables ster*edu;
		where agecat = 5 or agecat = 6;
		run;
	*proportions sterilized and using reversible contraception diverge widely
	as education increases, with far greater numbers using reversible contraception
	with higher levels of education;

	*so now i want to check the same distributions but look at them by age at 
	first birth;
	proc sort; by agebabycat; run;
	proc freq;
		tables ster*edu;
		where agecat = 5 or agecat = 6;
		by agebabycat;
		run;
