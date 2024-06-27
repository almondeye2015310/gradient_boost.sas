#タイタニックデータ

filename in "~~/データセット/train.csv" ;
proc import out=train datafile=in dbms=csv replace;
  getnames=yes;

data trains; set train;
if sex='male' then nsex=0;else nsex=1;
if Embarked = 'S' then Em_S=1;else Em_S=0;
if Embarked = 'C' then Em_C=1;else Em_C=0;
if Embarked = 'Q' then Em_Q=1;else Em_Q=0;


filename in "~~/データセット/test.csv" ;
proc import out=test file=in dbms=csv replace;
  getnames=yes;

data tests; set test;
if sex='male' then nsex=0;else nsex=1;
if Embarked = 'S' then Em_S=1;else Em_S=0;
if Embarked = 'C' then Em_C=1;else Em_C=0;
if Embarked = 'Q' then Em_Q=1;else Em_Q=0;

proc means mean noprint;var age;
output out=mm mean= mean;

data tests;set tests;
if _N_ = 1 then set mm;
if age='.' then age=mean;

proc logistic data=trains;
model Survived = Pclass nsex Age Sibsp Em_S Em_C
 /lackfit noint;
 score data=tests out=out;

data fin; set out;
Survived=i_survived;
keep passengerid Survived;

proc export 
   dbms=csv
   outfile='submission\logistic'
   replace
   ;

run;
