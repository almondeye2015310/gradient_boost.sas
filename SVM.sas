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

###線形カーネル###
proc hpsvm data=trains;
     target Survived/level=binary;
     input Pclass Parch Sibsp /level=ordinal order=ascending;
     input nsex Em_S Em_C Em_Q /level=nominal;
     input Fare Age /level=interval;
     
     kernel linear;
     penalty C=0.1 to 1;
     select cv=random fold=10 seed=10;
     
     code file='hpsvm_linear.sas';

###多項カーネル###
proc hpsvm data=trains;
     target Survived/level=binary;
     input Pclass Parch Sibsp /level=ordinal order=ascending;
     input nsex Em_S Em_C Em_Q /level=nominal;
     input Fare Age /level=interval;
     
     kernel polynom;
     penalty C=0.1 to 1;
     select cv=random fold=10 seed=20;
     
     code file='hpsvm_poly.sas';

###RBFカーネル###     
proc hpsvm data=trains;
     target Survived/level=binary;
     input Pclass Parch Sibsp /level=ordinal order=ascending;
     input nsex Em_S Em_C Em_Q /level=nominal;
     input Fare Age /level=interval;
     
     kernel rbf;
     penalty C=0.1 to 1;
     select cv=random fold=10 seed=20;
     
     code file='hpsvm_gauss.sas';
 
###sigmoidカーネル###
proc hpsvm data=trains;
     target Survived/level=binary;
     input Pclass Parch Sibsp /level=ordinal order=ascending;
     input nsex Em_S Em_C Em_Q /level=nominal;
     input Fare Age /level=interval;
     
     kernel sigmoid;
     penalty C=0.1 to 1;
     select cv=random fold=10 seed=20;
     
     code file='hpsvm_sigmoid.sas';     
     
%macro _Pred(cd=);
    data _Pred_&cd.;
        set tests;
        %inc hpsvm_&cd.;
        Survived=I_Survived;keep PassengerId Survived;
    
%mend _Pred;
%_Pred(cd=linear);
%_Pred(cd=poly);
%_Pred(cd=gauss);
%_Pred(cd=sigmoid);

proc export data=_Pred_linear
     dbms=csv
     outfile='sas.linear_SVM'
     replace
    ;

proc export data=_Pred_poly
     dbms=csv
     outfile='sas.poly_SVM'
     replace
    ;
    
proc export data=_Pred_gauss
     dbms=csv
     outfile='sas.rbf_SVM'
     replace
    ;
    
proc export data=_Pred_sigmoid
     dbms=csv
     outfile='sas.sig_SVM'
     replace
    ;

run;
