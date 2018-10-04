*******************************************
************** DISSERTATION ***************
************* NSFG 2011-2015 **************
******************************************;

*CREATING TEMPORARY DATASET FROM PERMANENT;
libname library "U:\Dissertation";
proc format library=library; run;
data work.a; set library.nsfg_females_2011_2015; run;

	* McWilliams-created formats and labels;
	%include "U:\Dissertation\nsfg_CMcWFormats.sas";
	*there will be errors saying the variables are uninitialized, the formats will
	still work when they are applied later;

*RESTRICTING TO JUST MY VARIABLES OF INTEREST;
data work.a; set work.a; 
	keep caseid rscrage constat1 constat2 constat3 constat4 mainnouse
	currmeth1 currmeth2 currmeth3 currmeth4 educat poverty nbabes_s
	nchildhh whynousing1 race dipged degrees hieduc agebaby1; run;

proc contents data = a; run;	
	
*---- CREATING NEW VARIABLES ----*;



	* creating a new constraceptive variable to remove people not at risk of unintended pregnancy;
	data a; set a;
		bc = constat1;
		if constat1>28 and constat1<=41 then bc=.;
		run;

	* making a dichotomous variable for using bc or not;
	data a; set a;
		nouse = bc;
		if bc = 42 then nouse = 1;
		if bc < 42 and bc > 0 then nouse = 0;
		if nouse = 1 then bcyes = 0;
		if nouse = 0 then bcyes = 1;
		run;
	/*proc freq; tables nouse; run;
	proc sort; by agecat; run;
	proc freq; tables nouse; by agecat; run;*/


	* poverty level categories;
	data a; set a;
		povlev = .;
		if poverty < 100 and poverty > 0 then povlev = 1;
		if poverty < 200 and poverty > 99 then povlev = 2;
		if poverty < 300 and poverty > 199 then povlev = 3;
		if poverty < 400 and poverty > 299 then povlev = 4;
		if poverty < 500 and poverty > 399 then povlev = 5;
		if poverty >= 500 then povlev = 6;
		run;

	* sterilized, contracepting, not contracepting;
	data a; set a;
		if bc = 1 or bc = 2 or bc = 35 or bc = 36 or bc = 33 or bc = 34 or bc = 38
		then ster = 1;
		if bc ne 1 and bc ne 2 and bc ne 35 and bc ne 36 and bc ne 33 and bc ne 34 
		and bc ne 38 then ster =2;
		if bc = 42 then ster = 3;
		run;

	/* among not sterilized, using an effective method;
	data a; set a;
		effmeth = bc;
		if bc=1 or bc=2 or bc then effmeth = 1;
		if bc=42 then effmeth = .;
		run;
	*/

	/*commenting out here since i added this to variable treatment program;
	* created my own education variable;
	proc freq; tables hieduc; run;
	*there are some extra categories here, one of which (2) includes 5434 people;
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
		run;
	*/

	data a; set a;
		if agebaby1 < 2500 then agebabycat = 1;
		if agebaby1 >= 2500 then agebabycat = 2;
		run;

	*agebaby1 to real years;
	data a; set a;
		agefirstbirth = agebaby1/100;
		label agefirstbirth="real years at first birth (agebaby1/100)";
		run;

	proc means; var agefirstbirth; run;
	*Distributions of education by yes/no to contraception really aren't very different. 
	If education is playing a role, perhaps it's by method or use and non-use need 
	to be defined more granularly;


*---- REMOVING CASES ACCORDING TO STANDARD PRACTICE 
	  (MAY WANT TO INCLUDE LATER OR RUN BOTH WAYS);

	* removing individuals who are currently pregnant;
	data a; set a;
		if constat1 = 30 then delete;
		run;
		*5450;

	* removing individuals who are seeking pregnancy;
	data a; set a;
		if constat1 = 31 then delete;
		run;
		*5205;

	* removing individuals who are sterile for noncontraceptive reasons
	(includes surgical and nonsurgical);
	data a; set a;
		if constat1 = 33 then delete;
		if constat1 = 34 then delete;
		if constat1 = 35 then delete;
		if constat1 = 36 then delete;
		run;
		*5004;

	* removing "sterile--unknown reasons -male";
	data a; set a;
		if constat1 = 38 then delete;
		run;
		*5004;

	* removing never had intercourse since 1st period;	
	data a; set a;
		if constat1 = 40 then delete;
		run;
		*4308;

	* removing hasn't had intercourse in last 3 months;
	data a; set a;
		if constat1 = 41 then delete;
		run;
		*3812;

proc freq data = work.a; tables agecat; run;
	*women over 34 = 1225;

*----------------------*
*---- DESCRIPTIVES ----*
*----------------------*;

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


	

*---- REGRESSION ----*;

	*i'm putting this together just to explore, there appear to be some problems
	with the model converging, so it definitely needs a lot more work;
	proc logistic;
		class ster (ref="sterilized") edu (ref="bachelor's") agecat (ref="35-39");
		model ster = edu agecat agebaby1;
		where agecat = 5 or agecat = 6 or ster = 1 or ster = 2;
		run;
	*but, interestingly, even after putting age at first baby in the model,
	there's definitely still something going on with education;
/*
	*screw it, i'm going to do a regression;
	proc surveyreg data=a;
		class bc whynousing1 educat poverty;
		model rscrage = bc whynousing1 nbabes_s educat poverty / solution;
		run;
		*i forgot surveyreg doesn't output anything;

	proc freq data = a;
		tables race*nouse povlev*nouse nbabes_s*nouse;
		where agecat>4;
		run;

	proc logistic data=a;
		class educat povlev agecat nbabes_s;
		model nouse = agecat educat povlev nbabes_s;
		where agecat > 4;
		run;


	proc logistic data=a;
		class educat povlev agecat nbabes_s;
		model nouse = agecat educat povlev nbabes_s;
		run;

	proc logistic data=a;
		class educat povlev agecat nbabes_s race;
		model ster = agecat educat povlev nbabes_s race;
		run;

*/

