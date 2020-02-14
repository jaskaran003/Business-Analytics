

libname s '/folders/myfolders/sampledataset';

proc import datafile='/folders/myfolders/datascience/Logistic Regression.csv' out=s.logistic dbms=csv replace;
getnames=yes; datarow=2;

proc means data=s.logistic min p1 p5 p95 p99 max mean std nmiss n mode;
run;


/* outlier treatment */

data s.logistic;
set s.logistic;
if REVENUE > 135.39 then REVENUE = 135.39 ;
if MOU > 1580.25 then MOU = 1580.25 ;
if RECCHRGE > 85 then RECCHRGE = 85 ;
if DIRECTAS > 4.21 then DIRECTAS = 4.21 ;
if OVERAGE > 190.5 then OVERAGE = 190.5 ;
if ROAM > 5.09 then ROAM = 5.09 ;
if CHANGEM > 345.25 then CHANGEM = 345.25 ;
if CHANGER > 46.22 then CHANGER = 46.22 ;
if DROPVCE > 22 then DROPVCE = 22 ;
if BLCKVCE > 17.33 then BLCKVCE = 17.33 ;
if UNANSVCE > 97.67 then UNANSVCE = 97.67 ;
if CUSTCARE > 9.33 then CUSTCARE = 9.33 ;
if THREEWAY > 1.33 then THREEWAY = 1.33 ;
if MOUREC > 440.95 then MOUREC = 440.95 ;
if OUTCALLS > 90.33 then OUTCALLS = 90.33 ;
if INCALLS > 35.67 then INCALLS = 35.67 ;
if PEAKVCE > 279.67 then PEAKVCE = 279.67 ;
if OPEAKVCE > 242 then OPEAKVCE = 242 ;
if DROPBLK > 35.33 then DROPBLK = 35.33 ;
if CALLWAIT > 8.67 then CALLWAIT = 8.67 ;
if MONTHS > 37 then MONTHS = 37 ;
if UNIQSUBS > 3 then UNIQSUBS = 3 ;
if ACTVSUBS > 2 then ACTVSUBS = 2 ;
if PHONES > 4 then PHONES = 4 ;
if MODELS > 3 then MODELS = 3 ;
if EQPDAYS > 866 then EQPDAYS = 866 ;
if RETCALLS > 1 then RETCALLS = 1 ;
if RETACCPT > 1 then RETACCPT = 1 ;
if refer>1 then refer = 1;
if EQPDAYS < 7 then EQPDAYS = 7 ;
if RECCHRGE < 9.19 then RECCHRGE = 9.19 ;
run;

/* missing value treatment */

data s.logistic;
set s.logistic;
if REVENUE = . then delete ;
if MOU = . then delete ;
if RECCHRGE = . then delete ;
if DIRECTAS = . then delete ;
if OVERAGE = . then delete ;
if ROAM = . then delete ;
if CHANGEM = . then delete ;
if CHANGER = . then delete ;
if PHONES = . then delete ;
if MODELS = . then delete ;
if EQPDAYS = . then delete ;
run;

/* Chi-square tests to eliminate categorical variables */

proc freq data=s.logistic;
tables churn * (rv truck occprof occcler occcrft occstud occhmkr occret occself 
ownrent marryun marryyes marryno mailord mailres mailflag travel pcown
newcelln newcelly mcycle  children prizmub prizmrur prizmtwn) / chisq nocol nopercent norow;
run;


/* Correlation matrix to eliminate numerical variables */

ods html file = '/folders/myfolders/correlation.xls';

proc corr data = s.logistic;
var 
REVENUE MOU RECCHRGE
DIRECTAS OVERAGE
ROAM CHANGEM
CHANGER DROPVCE
BLCKVCE UNANSVCE CUSTCARE
THREEWAY MOUREC
OUTCALLS REFURB
INCALLS PEAKVCE
OPEAKVCE
DROPBLK CALLWAIT
MONTHS UNIQSUBS
ACTVSUBS PHONES
MODELS EQPDAYS;
run;

ods html close

/* Factor analysis */

proc factor data = s.logistic mineigen=0 method=principal
rotate=varimax scree reorder nfactors=14;
var
MOU RECCHRGE
DIRECTAS OVERAGE
ROAM CHANGEM
CHANGER DROPVCE
BLCKVCE CUSTCARE
THREEWAY INcalls
PEAKVCE MONTHS 
UNIQSUBS PHONES 
EQPDAYS RETCALLS 
RETACCPT REFER 
CREDITAD RETCALL 
churn CREDITCD
CREDITA CREDITAA
CREDITB CREDITC
CREDITDE CREDITGY
CREDITZ REFURB
WEBCAP MAILRES
;
run;

/* Dividing into calibration and validation set*/

data s.dev s.val;
set s.logistic;
if churndep NE . then output s.dev;
else output s.val;
run;

data s.dev;
set s.dev;
root_mou = sqrt(mou);
root_eqpdays = sqrt(eqpdays);
root_overage = sqrt(overage);
run;


data s.val;
set s.val;
root_mou = sqrt(mou);
root_eqpdays = sqrt(eqpdays);
root_overage = sqrt(overage);
run;


/* Running logistic regression */

proc logistic data=s.dev descending;
model churn =
root_MOU DROPvce
root_OVERAGE 
CUSTcare RECCHRGE 
RETCALL MONTHs
CHANGEM changer MAILRES
CREDITCD root_EQPDAYS
WEBCAP REFURB
PHONES CREDITDE
CREDITB CREDITC
CREDITZ roam
REFER CREDITGY
uniqsubs
/ selection=stepwise slentry=0.05 slstay=0.05 stb lackfit;
run;


/* running predictive model on validaton set */

data s.dev;
set s.dev;
y =-0.4843 -0.0267 * square_mou + 0.0144 * DROPVCE
 + 0.0485 * square_overage + 0.7571 * RETCALL 
 -0.0205 * MONTHS -0.00062 * CHANGEM + 0.00271 * CHANGER -0.1669 * MAILRES 
 -0.0804 * CREDITCD + 0.0553 * square_eqpdays -0.2206 * WEBCAP 
 + 0.2499 * REFURB + 0.1439 * PHONES -0.3575 * CREDITDE -0.1484 * CREDITC 
 + 0.0478 * ROAM + 0.0869 * UNIQSUBS;

predicted = exp(y)/(1+exp(y));
run;


data s.val;
set s.val;
y =-0.4843 -0.0267 * square_mou + 0.0144 * DROPVCE + 0.0485 * square_overage 
+ 0.7571 * RETCALL -0.0205 * MONTHS 
-0.00062 * CHANGEM + 0.00271 * CHANGER
 -0.1669 * MAILRES -0.0804 * CREDITCD 
+ 0.0553 * square_eqpdays -0.2206 * WEBCAP + 0.2499 * REFURB + 0.1439 * PHONES
 -0.3575 * CREDITDE -0.1484 * CREDITC + 0.0478 * ROAM + 0.0869 * UNIQSUBS;

predicted = exp(y) /(1+ exp(y));
run;

proc rank data=s.dev out= s.dev descending groups=10;
var predicted;
ranks decile;
run;

proc rank data=s.val out=s.val descending groups=10;
var predicted;
ranks decile;
run;

data s.dev;
set s.dev;
decile = decile+1;
run;

data s.val;
set s.val;
decile = decile+1;
run;

proc sql ;
select decile, count(predicted) as number_of_obs, min(predicted) as min_score,
max(predicted) as max_score,sum(churn) as churners
from s.dev
group by decile
order by decile;

select decile,count(predicted) as number_of_obs, min(predicted) as min_score,
max(predicted) as max_score, sum(churn) as churners
from s.val
group by decile
order by decile;

quit;


/* fixing probability at 0.504 based on KS statistics and lift chart */

data s.dev;
set s.dev;
if predicted < 0.504 then probability = 0;
else probability = 1;
run;

data s.val;
set s.val;
if predicted < 0.504 then probability = 0;
else probability = 1;
run;

proc freq data = s.val;
table churn*probability/norow nocol nopercent;
run;




