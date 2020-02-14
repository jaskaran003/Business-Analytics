

libname s '/folders/myfolders/sampledataset';

/* Importing the dataset */

proc import datafile='/folders/myfolders/datascience/Linear Regression Case.xls' dbms=xls 
out=s.linear_reg replace;
getnames = yes ; datarow = 2;

/* Calculating Total Spent and Total Items from primary and secondary card spent*/


data s.linear_reg;
set s.linear_reg;
total_spent = cardspent + card2spent;
total_items = carditems + card2items;
ln_spent = log(total_spent);
run;



/* Dimensionality reduction */

/* Identifying variables with high percentage of missing values (which can then be dropped) */

proc means data=s.linear_reg nmiss n min p1 p5 p95 p99 max mean std mode ;
run;


/* Running proc corr to eliminate variables with low correlation to response variable
   ie : Total Spent */
   
   
   
 proc corr data = s.linear_reg ;
 var 
 ed employ age
income lninc debtinc creddebt lncreddebt
othdebt lnothdebt spoused reside pets
pets_cats pets_dogs
pets_birds pets_reptiles
pets_small pets_saltfish pets_freshfish address
cars longmon lnlongmon longten lnlongten tollfree hourstv tenure card2tenure cardtenure
total_spent ;
run;


/* Running proc univariate to eliminate categorical variables based on density distribution */

proc univariate data = s.linear_reg;
var total_spent;
class voice;
histogram total_spent;
run;

proc univariate data=s.linear_reg;
var total_spent;
class multiline;
histogram total_spent;
run;


proc univariate data=s.linear_reg;
var total_spent;
class pager;
histogram total_spent;
run;

proc univariate data=s.linear_reg;
var total_spent;
class callid;
histogram total_spent;
run;

proc univariate data=s.linear_reg;
var total_spent;
class callwait;
histogram total_spent;
run;


proc univariate data=s.linear_reg;
var total_spent;
class forward;
histogram total_spent;
run;

proc univariate data=s.linear_reg;
var total_spent;
class confer;
histogram total_spent;
run;


proc univariate data=s.linear_reg;
var total_spent;
class ownpda;
histogram total_spent;
run;


proc univariate data=s.linear_reg;
var total_spent;
class response_01;
histogram total_spent;
run;


proc univariate data=s.linear_reg;
var total_spent;
class response_02;
histogram total_spent;
run;


proc univariate data=s.linear_reg;
var total_spent;
class commutecat;
histogram total_spent;
run;


proc univariate data=s.linear_reg;
var total_spent;
class polview;
histogram total_spent;
run;


/* Outlier treatment,missing value treatment and factor analysis for remaining variables */

data s.linear_reg;
set s.linear_reg;
if ed > 21 then ed = 21 ;
if employ > 39 then employ = 39 ;
if income > 272.5 then income = 272.5 ;
if lninc > 5.6076369 then lninc = 5.6076369 ;
if creddebt > 14.29792 then creddebt = 14.29792 ;
if lncreddebt > 2.6613666 then lncreddebt = 2.6613666 ;
if othdebt > 24.153048 then othdebt = 24.153048 ;
if lnothdebt > 3.1881546 then lnothdebt = 3.1881546 ;
if tenure > 72 then tenure = 72 ;
if total_spent > 1764.63 then total_spent = 1764.63 ;
if total_items > 25 then total_items = 25 ;
if ln_spent > 7.4756929 then ln_spent = 7.4756929 ;
run;

/* missing value treatment */

data s.linear_reg;
set s.linear_reg;
if longten = . then longten = 708.8717531 ;
if lnlongten = . then lnlongten = 2.85056659701764 ;
if lncreddebt = . then lncreddebt=  0 ;
if lnothdebt = . then lnothdebt=  0 ;
if townsize = . then townsize= 1 ;
run;

/* factor analysis */

proc factor data=s.linear_reg 
mineigen=0 method=principal rotate=varimax reorder scree nfactors=11 ;
var
region townsize agecat edcat jobcat empcat retire inccat 
jobsat marital spousedcat homeown 
hometype addresscat carown cartype
carcatvalue carbought
commute internet
card 
card2 
reason
ed employ income 
lninc creddebt
lncreddebt othdebt
lnothdebt 
tenure total_spent total_items;
run;


/* creation of dummy variables for categorical variables*/

data s.linear_reg;
set s.linear_reg;
if townsize= 1 then dummy_townsize1 = 1; else dummy_townsize1 = 0;
if townsize= 2 then dummy_townsize2 = 1; else dummy_townsize2 = 0;
if townsize= 3 then dummy_townsize3 = 1; else dummy_townsize3 = 0;
if townsize= 4 then dummy_townsize4 = 1; else dummy_townsize4 = 0;

if jobcat= 1 then dummy_jobcat1 = 1; else dummy_jobcat1 = 0;
if jobcat= 2 then dummy_jobcat2 = 1; else dummy_jobcat2 = 0;
if jobcat= 3 then dummy_jobcat3 = 1; else dummy_jobcat3 = 0;
if jobcat= 4 then dummy_jobcat4 = 1; else dummy_jobcat4 = 0;
if jobcat= 5 then dummy_jobcat5 = 1; else dummy_jobcat5 = 0;

if reason= 1 then dummy_reason1 = 1; else dummy_reason1 = 0;
if reason= 2 then dummy_reason2 = 1; else dummy_reason2 = 0;
if reason= 3 then dummy_reason3 = 1; else dummy_reason3 = 0;
if reason= 4 then dummy_reason4 = 1; else dummy_reason4 = 0;
if reason= 8 then dummy_reason5 = 1; else dummy_reason5 = 0;

if card= 1 then dummy_card1 = 1; else dummy_card1 = 0;
if card= 2 then dummy_card2 = 1; else dummy_card2 = 0;
if card= 3 then dummy_card3 = 1; else dummy_card3 = 0;
if card= 4 then dummy_card4 = 1; else dummy_card4 = 0;

if card2= 1then dummy_card2_1 = 1; else dummy_card2_1 = 0;
if card2= 2then dummy_card2_2 = 1; else dummy_card2_2 = 0;
if card2= 3then dummy_card2_3 = 1; else dummy_card2_3 = 0;
if card2= 4then dummy_card2_4 = 1; else dummy_card2_4 = 0;

if commute = 1 then dummy_commute1 =  1 ; else dummy_commute1 = 0 ;
if commute = 2 then dummy_commute2 =  1 ; else dummy_commute2 = 0 ;
if commute = 3 then dummy_commute3 =  1 ; else dummy_commute3 = 0 ;
if commute = 4 then dummy_commute4 =  1 ; else dummy_commute4 = 0 ;
if commute = 5 then dummy_commute5 =  1 ; else dummy_commute5 = 0 ;
if commute = 6 then dummy_commute6 =  1 ; else dummy_commute6 = 0 ;
if commute = 7 then dummy_commute7 =  1 ; else dummy_commute7 = 0 ;
if commute = 8 then dummy_commute8 =  1 ; else dummy_commute8 = 0 ;
if commute = 9 then dummy_commute9 =  1 ; else dummy_commute9 = 0 ;

run;


/* Creating training and validation set */

data dev val;
set s.linear_reg;
if ranuni(5000) <0.7 then output dev;
else output val;
run;


proc transreg data=s.linear_reg;
model boxcox(total_spent) = identity(income othdebt creddebt tenure ed total_items);
run;

/* Running the linear regression */

proc reg data=dev;
model ln_spent = 
income
othdebt creddebt
retire employ
tenure carown
ed marital
total_items homeown
dummy_commute1 dummy_commute2
dummy_commute3 dummy_commute4
dummy_commute5 dummy_commute6
dummy_commute7 dummy_commute8
dummy_commute9 dummy_card2_1
dummy_card2_2
dummy_card2_3 dummy_card2_4
dummy_card1 dummy_card2
dummy_card3 dummy_card4
dummy_reason1 dummy_reason2
dummy_reason3 dummy_reason4
dummy_reason5 dummy_townsize1
dummy_townsize2 dummy_townsize3
dummy_townsize4 dummy_jobcat1
dummy_jobcat2 dummy_jobcat3
dummy_jobcat4 dummy_jobcat5
/selection = stepwise slentry= 0.05 slstay=0.1 vif stb;
output out = tmp cookd=cd;
run;

data x;
set tmp;
if cd<4/3500;
run;

proc reg data=x;
model ln_spent = 
income
othdebt creddebt
retire employ
tenure carown
ed marital
total_items homeown
dummy_commute1 dummy_commute2
dummy_commute3 dummy_commute4
dummy_commute5 dummy_commute6
dummy_commute7 dummy_commute8
dummy_commute9 dummy_card2_1
dummy_card2_2
dummy_card2_3 dummy_card2_4
dummy_card1 dummy_card2
dummy_card3 dummy_card4
dummy_reason1 dummy_reason2
dummy_reason3 dummy_reason4
dummy_reason5 dummy_townsize1
dummy_townsize2 dummy_townsize3
dummy_townsize4 dummy_jobcat1
dummy_jobcat2 dummy_jobcat3
dummy_jobcat4 dummy_jobcat5
/selection = stepwise slentry= 0.05 slstay=0.1 vif stb;
run;

/* prediction for training and validation data sets */


data dev;
set dev;
y = 4.29083 + 0.00339 * income + 0.00752 * creddebt -0.16949 * retire 
+ 0.00226 * employ + 0.03002 * carown + 0.09318 * total_items 
+ 0.26448 * dummy_card2_1 -0.03176 * dummy_card2_4 
+ 0.46857 * dummy_card1 -0.07266 * dummy_card4 
-0.09576 * dummy_reason1 + 0.18616 * dummy_reason2 ;
prediction = exp(y);
run;


data val;
set val;
y = 4.29083 + 0.00339 * income + 0.00752 * creddebt -0.16949 * retire 
+ 0.00226 * employ + 0.03002 * carown + 0.09318 * total_items 
+ 0.26448 * dummy_card2_1 -0.03176 * dummy_card2_4 
+ 0.46857 * dummy_card1 -0.07266 * dummy_card4 
-0.09576 * dummy_reason1 + 0.18616 * dummy_reason2 ;
prediction = exp(y);

/* Deciling datasets based on prediction */

proc rank data= dev out=dev descending groups=10;
var prediction;
ranks decile;
run;

data dev;
set dev;
decile = decile+1;
run;

proc rank data=val out=val descending groups=10;
var prediction;
ranks decile;
run;
run;

data val;
set val;
decile = decile+1;
run;


/* decile analysis to assess rank oders for development and validation sets*/

ods html file = '/folders/myfolders/linear_validation.xls';

proc sql;
select decile, count(prediction)as observations, avg(prediction) as avg_predicted_spend,
avg(total_spent) as avg_actual_spend, sum(prediction) as total_predicted_spend,
sum(total_spent) as total_actual_spend 
from dev
group by decile
order by decile ;

select decile, count(prediction)as observations, avg(prediction) as avg_predicted_spend,
avg(total_spent) as avg_actual_spend, sum(prediction) as total_predicted_spend,
sum(total_spent) as total_actual_spend
from val
group by decile
order by decile ;

quit;

ods html close ;