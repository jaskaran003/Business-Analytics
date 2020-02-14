
libname s'/folders/myfolders/sampledataset';

/* Importing the credit card segmentation data set */

proc import datafile='/folders/myfolders/datascience/CC General.csv' out= s.segmentation dbms=csv replace;
getnames=yes; datarow=2;


/* Outlier identification and missing value treatment */

proc means data=s.segmentation min p1 p5 p95 p99 max mean std nmiss n;
run;

/* outlier treatment */

data s.segmentation1;
set s.segmentation;
if BALANCE > 5911.51 then BALANCE = 5911.51 ; 
if PURCHASES > 3999.92 then PURCHASES = 3999.92 ; 
if ONEOFF_PURCHASES > 2675 then ONEOFF_PURCHASES = 2675 ; 
if INSTALLMENTS_PURCHASES > 1753.08 then INSTALLMENTS_PURCHASES = 1753.08 ; 
if CASH_ADVANCE > 4653.69 then CASH_ADVANCE = 4653.69 ; 
if CASH_ADVANCE_TRX > 15 then CASH_ADVANCE_TRX = 15 ; 
if PURCHASES_TRX > 57 then PURCHASES_TRX = 57 ; 
if CREDIT_LIMIT > 12000 then CREDIT_LIMIT = 12000 ; 
if PAYMENTS > 6083.43 then PAYMENTS = 6083.43 ; 
if PRC_FULL_PAYMENT > 1 then PRC_FULL_PAYMENT = 1 ; 
if CASH_ADVANCE_FREQUENCY > 0.7355084 then CASH_ADVANCE_FREQUENCY = 0.7355084 ; 
run;




/* missing values treatment*/

data s.segmentation1;
set s.segmentation1;
if CREDIT_LIMIT = .  then delete ;
if Ratio_balance_to_limit = .  then delete ;
if MINIMUM_PAYMENTS = .  then delete ;
if payment_by_min = .  then delete ;
run;


data s.segmentation1;
set s.segmentation1;
if cat_cust = 1 then card_install = 1 ; else card_install = 0;
if cat_cust = 2 then card_one_off = 1; else card_one_off = 0;
if cat_cust = 3 then card_cash = 1 ; else card_cash = 0;
run;


/* Factor analysis */

proc factor data= s.segmentation1
mineigen=0 method=principal rotate=varimax scree reorder nfactors=6;
var
BALANCE
BALANCE_FREQUENCY
PURCHASES
ONEOFF_PURCHASES
INSTALLMENTS_PURCHASES
CASH_ADVANCE
PURCHASES_FREQUENCY
ONEOFF_PURCHASES_FREQUENCY
PURCHASES_INSTALLMENTS_FREQUENCY
CASH_ADVANCE_FREQUENCY
CASH_ADVANCE_TRX
PURCHASES_TRX
CREDIT_LIMIT
PAYMENTS
MINIMUM_PAYMENTS
PRC_FULL_PAYMENT
TENURE;
run;

/* Creation of variable copies for standardization */

data s.segmentation1;
set s.segmentation1;
z_ONEOFF_PURCHASES = ONEOFF_PURCHASES ;
z_PAYMENTS = PAYMENTS ;
z_ONEOFF_PURCHASES_FREQUENCY = ONEOFF_PURCHASES_FREQUENCY ;
z_CASH_ADVANCE = CASH_ADVANCE ;
z_CASH_ADVANCE_FREQUENCY = CASH_ADVANCE_FREQUENCY ;
z_PURCHASES_INSTALLMENTS_FREQ = PURCHASES_INSTALLMENTS_FREQUENCY ;
z_INSTALLMENTS_PURCHASES = INSTALLMENTS_PURCHASES ;
z_BALANCE = BALANCE ;
z_PRC_FULL_PAYMENT = PRC_FULL_PAYMENT ;
z_CREDIT_LIMIT = CREDIT_LIMIT ;
run;


/* Standardization of variables */

proc standard data = s.segmentation1 out=s.segmentation1 mean=0 std=1;
var
z_ONEOFF_PURCHASES
z_PAYMENTS
z_ONEOFF_PURCHASES_FREQUENCY
z_CASH_ADVANCE
z_CASH_ADVANCE_FREQUENCY
z_PURCHASES_INSTALLMENTS_FREQ
z_INSTALLMENTS_PURCHASES
z_BALANCE
z_PRC_FULL_PAYMENT
z_CREDIT_LIMIT;
run;

/* Clustering based on standardized variables */

proc fastclus data=s.segmentation1 out=clusters cluster=cluster3 maxclusters=3 maxiter=100;
var
z_ONEOFF_PURCHASES
z_PAYMENTS
z_ONEOFF_PURCHASES_FREQUENCY
z_CASH_ADVANCE
z_CASH_ADVANCE_FREQUENCY
z_PURCHASES_INSTALLMENTS_FREQ
z_INSTALLMENTS_PURCHASES
z_BALANCE
z_PRC_FULL_PAYMENT
z_CREDIT_LIMIT;
run;


proc fastclus data=clusters out=clusters cluster=cluster4 maxclusters=4 maxiter=100;
var
z_ONEOFF_PURCHASES
z_PAYMENTS
z_ONEOFF_PURCHASES_FREQUENCY
z_CASH_ADVANCE
z_CASH_ADVANCE_FREQUENCY
z_PURCHASES_INSTALLMENTS_FREQ
z_INSTALLMENTS_PURCHASES
z_BALANCE
z_PRC_FULL_PAYMENT
z_CREDIT_LIMIT;
run;


proc fastclus data=clusters out=clusters cluster=cluster5 maxclusters=5 maxiter=100;
var
z_ONEOFF_PURCHASES
z_PAYMENTS
z_ONEOFF_PURCHASES_FREQUENCY
z_CASH_ADVANCE
z_CASH_ADVANCE_FREQUENCY
z_PURCHASES_INSTALLMENTS_FREQ
z_INSTALLMENTS_PURCHASES
z_BALANCE
z_PRC_FULL_PAYMENT
z_CREDIT_LIMIT;
run;


proc fastclus data=clusters out=clusters cluster=cluster6 maxclusters=6 maxiter=100;
var
z_ONEOFF_PURCHASES
z_PAYMENTS
z_ONEOFF_PURCHASES_FREQUENCY
z_CASH_ADVANCE
z_CASH_ADVANCE_FREQUENCY
z_PURCHASES_INSTALLMENTS_FREQ
z_INSTALLMENTS_PURCHASES
z_BALANCE
z_PRC_FULL_PAYMENT
z_CREDIT_LIMIT;
run;


/* Creating profile sheet */

ods html file = '/folders/myfolders/cluster.xls';

proc tabulate data=clusters;
var
ONEOFF_PURCHASES
PAYMENTS
ONEOFF_PURCHASES_FREQUENCY
CASH_ADVANCE
CASH_ADVANCE_FREQUENCY
PURCHASES_INSTALLMENTS_FREQUENCY
INSTALLMENTS_PURCHASES
BALANCE
PRC_FULL_PAYMENT
CREDIT_LIMIT
card_install
card_one_off
card_cash
average_purchases
average_cash_advance
tenure
ratio_balance_to_limit
payment_by_min
purchases_frequency
;
class  cluster3 cluster4 cluster5 cluster6 ;
table
(ONEOFF_PURCHASES
PAYMENTS
ONEOFF_PURCHASES_FREQUENCY
CASH_ADVANCE
CASH_ADVANCE_FREQUENCY
PURCHASES_INSTALLMENTS_FREQUENCY
INSTALLMENTS_PURCHASES
BALANCE
PRC_FULL_PAYMENT
CREDIT_LIMIT
card_install
card_one_off
card_cash
average_purchases
average_cash_advance
tenure
ratio_balance_to_limit
payment_by_min
purchases_frequency
)* mean N , all  cluster3 cluster4 cluster5 cluster6 ;
run;

ods html close; 