*******************************************
******** NSFG DATA FOR WOMEN 35+ **********
************ NEW FORMATS ******************
******************************************;

*http://documentation.sas.com/?docsetId=lestmtsref&docsetTarget=n0d5oq7e0oia0wn13nsins0x8nmh.htm&docsetVersion=9.4&locale=en;

proc format;
	value agecat
		1="15-19"
		2="20-24"
		3="25-29"
		4="30-34"
		5="35-39"
		6="40-44";
	value povlev
		1="<100% PL"
		2="100-199% PL"
		3="200-299% PL"
		4="300-399% PL"
		5="400-499% PL"
		6="500%+ PL";
	value nouse
		1="not using anything"
		0="using contraception";
	value bcyes
		0="not using anything"
		1="using contraception";
	value edu
		1="no hs degree"
		2="hs degree or ged"
		3="some college no degree"
		4="associate's"
		5="bachelor's"
		6="graduate or professional degree";
	value ster
		1="sterilized"
		2="using reversible contraception"
		3="not contracepting";
	value effmeth
		1="sterilized"
		2="IUD, implant"
		3="injection, pill, patch, ring"
		4="condom, diaphragm, sponge, foam, insert, jelly"
		5="emergency contraception"
		6="periodic abstinence"
		7="withdrawal"
		8="other"
		9="not using contraception";
	value allrepro
		1="sterilized"
		2="IUD, implant"
		3="injection, pill, patch, ring"
		4="condom, diaphragm, sponge, foam, insert, jelly"
		6="periodic abstinence"
		7="withdrawal"
		8="emergency contraception"
		9="other"
		10="not using contraception"
		11="pregnant"
		12="seeking pregnancy"
		13="<2 months postpartum"
		14="noncontraceptive sterile"
		15="never had intercourse since first period"
		16="no intercourse in 3 months b4 interview";
	value elig
		1="at risk of UIP"
		0="not at risk of UIP";

	

run;

data a; set a;
	format 	agecat agecat.
			bc constatf.
			povlev povlev.
			nouse nouse.
			effmeth effmeth.
			bcyes bcyes.
			edu edu.
			ster ster.
			allrepro allrepro.
			elig elig.;
;run;
