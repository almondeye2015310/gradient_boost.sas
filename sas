#タイタニックのデータで試す

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
proc treeboost data=trains
     iterations=1000
     maxdepth=5
     seed=123
     ;
     
     target Survived/level=binary;
     input age fare /level=interval;
     input nsex Em_S Em_C Em_Q /level=nominal;
     input Pclass Parch Sibsp /level=ordinal;
     
     subseries best;
     score data=trains outfit=fitsta;
     code file='gradboost_tree.sas';
     save fit=gbt_fit importance=importance;
     
title 'feature_importance';
proc sgplot data=importance;
     hbar name/response=importance groupdisplay=stack categoryorder=respdesc;
     
%macro _Pred(cd=);
    data _Pred_&cd.;
        set tests;
        %inc gradboost_&cd.;
        Survived=I_Survived;keep PassengerId Survived;
    
%mend _Pred;
%_Pred(cd=tree);

proc export data=_Pred_Tree
     dbms=csv
     outfile='sas.Gradboost_Tree'
     replace
    ;

     
