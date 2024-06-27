#タイタニックのデータ

filename in "~~/データセット/train.csv" ;
proc import out=train datafile=in dbms=csv replace;
  getnames=yes;
  
data trains; set train;
if sex='male' then nsex=0;else nsex=1;
if Embarked='S' then Em=0;
   else if Embarked='C' then Em=1;
   else if Embarked='Q' then Em=2;
   else Em=0;
middle=scan(name,1,'.');
middle=scan(middle,2,',');
if passengerid in (746,31,823,557,600,760,450,537) then delete;

proc means mean noprint;var age;
output out=mm mean= mean;

data trains;set trains;
if _N_ = 1 then set mm;
if age='.' then age=mean;
    
filename in "~~/データセット/test.csv" ;
proc import out=test file=in dbms=csv replace;
  getnames=yes;

data tests; set test;
if sex='male' then nsex=0;else nsex=1;
if Embarked='S' then Em=0;
   else if Embarked='C' then Em=1;
   else if Embarked='Q' then Em=2;
   else Em=0;
middle=scan(name,1,'.');
middle=scan(middle,2,',');
proc means mean noprint;var age;
output out=mm2 mean= mean2;

data tests;set tests;
if _N_ = 1 then set mm2;

if age='.' then age=mean2;
data null;set tests; where fare is missing;
data class; set tests ;where pclass=3;
proc means mean noprint;var fare;
output out=mmm mean=mean;

data null; merge null mmm;
fare=mean;
drop _TYPE_ _FREQ_ mean;

data tests; set tests null;
proc sort nodupkey ;by passengerid; 


###ここから###
proc hpforest data=trains 
     seed=10 maxtrees=100 maxdepth=6;
  
     target Survived/level=binary;
     input Pclass Parch Sibsp /level=ordinal order=ascending;
     input nsex Em middle /level=nominal;
     input Fare Age /level=interval;
     
     ods output Fitstatistics=fitstats;
     ods output VariableImportance=varimp;
     save file='hpforest_fit.bin';
     
title "Feature Importance";
proc sgplot data=varimp;
    hbar Variable /response=Gini  groupdisplay=cluster categoryorder=respdesc;   
  
proc hp4score data=tests;
     score file='hpforest_fit.bin' out=submission;
     id Passengerid ;
     
data fin; set submission;
     Survived=i_survived;
     keep Passengerid Survived;
     
proc export
     dbms=csv
     outfile='sas.hpforest'
     replace
    ;
run;
     
