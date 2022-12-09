#タイタニックデータ
filename in "~~/データセット/train.csv" ;
proc import out=train datafile=in dbms=csv replace;
  getnames=yes;
  
data trains; set train;
if sex='male' then nsex=0;else nsex=1;
if Embarked = 'S' then Em_S=1;else Em_S=0;
if Embarked = 'C' then Em_C=1;else Em_C=0;
if Embarked = 'Q' then Em_Q=1;else Em_Q=0;

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
if Embarked = 'S' then Em_S=1;else Em_S=0;
if Embarked = 'C' then Em_C=1;else Em_C=0;
if Embarked = 'Q' then Em_Q=1;else Em_Q=0;


proc means mean noprint;var age;
output out=mm2 mean= mean2;

data tests;set tests;
if _N_ = 1 then set mm2;
if age='.' then age=mean2;

###ここから###
proc hpneural data=trains;
     target Survived/level=nom;
     input Pclass Parch Sibsp Age Fare/level=int;
     input nsex Em_S Em_C Em_Q/level=nom;
     
     architecture mlp;
     hidden 50;
     hidden 100;
     hidden 50;
     
     train outmodel=neuralmodel;
     
proc hpneural data=tests;
     score model=neuralmodel out=neuralfin;

data fin;set neuralfin;
   No=_N_;PassengerId=No+891;
   Survived=I_Survived;
   keep PassengerId Survived;

proc export data=fin
     dbms=csv
     outfile='sas.neural_net'
     replace;

run;
