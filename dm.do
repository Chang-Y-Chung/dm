// Stata Workshop 2 Data Management 2013-08-18 Chang Y. Chung

// let it run
set more off


// cd to where you put this file (dm.do) in. Here we assume that 
//   the directory is z:\dm
cd z:\dm

// check which directory I am in
pwd


// display command as a calculator and more
// ----------------------------------------
clear all

display 1 + 2
// 3 

// another example
display ln( 0.3 / (1-0.3) )
// which is the same as
display logit(0.3)

// it can display strings as well
display "hello, world?"

// some system values
display c(current_date)

// current version
display c(version)

// number of observations -- 0 since we haven't loaded data into memory yet
display _N


// stata dataset is a matrix with observations(rows) and variables(columns)
// ------------------------------------------------------------------------
clear all

// describe the current stata dataset in memory ("master" dataset)
describe

// create some observations -- still no variables
set obs 5
describe

// create a variable, x, with all the values equal to 1
generate x = 1
describe

// create another variable, y, with the built-in observation number, _n
// notice that _n is different from _N
generate y = _n
describe

// list shows them all
list

// individual values can be displayed using var[obs#] syntax
display x[1] // first observation value of variable x
display y[2] // second observation value of variable y

// guess what this displays?
display y[_N]


// replace changes values of the existing variable
// -------------------------------------------------
clear all
set obs 5
generate x = 1
generate y = _n

replace x = 2  
list

// replace is often used with either "in" or "if"
replace x = 3 in 1/3  // replace only the first three observations
list

replace y = 9 if y == 5 // if y value is equal to 5, then replace it with 9
list

// you can refer to other variables in the if condition as well
replace x = -99 if y < 3 // if the observation has y values less than 3
list                          

// suppose that -99 in x and 9 in y are to be missing values
replace x = . if x == -99
replace y = . if y == 9
list


// something cool
clear all
set obs 50
set seed 12345 // set a random seed
generate x = runiform()
generate y = runiform()
twoway scatter x y


// try changing number of observations to 10000
// try changing runiform() to rnormal(1,1)
clear all
set obs 10000
set seed 12345
gen x = rnormal(1,1)
gen y = rnormal(2,1)
twoway scatter x y


// missing values are larger than any number
// -----------------------------------------
clear all

// here is another way of creating a tiny dataset
input x y
. 1
. 2
3 3
2 4
2 .
end

// check
describe
list

// create a new variable dichotomizing y around 2.5
generate high_y = 0
replace high_y = 1 if 2.5 < y
list

// high_y is incorrect since the missing value (.) is larger than any number

// correct way
generate high_y2 = 0 if !missing(y) // ! means "not"
replace high_y2 = 1 if 2.5 < y & !missing(y) // & means logical "and"
list

// another way -- utilizing the fact that a true expression evaluates to 1
//   and false to 0 
generate high_y3 = (2.5 < y) if !missing(y)
list

// going the other way, 0 is false and any other numeric value is true
list if 0  // no observation is listed since 0 is false
list if 23.56 // any other values are true
 
// let's drop high_y, since it is incorrect!
drop high_y


// save and use stata dataset
// --------------------------
clear all

// let's create a dataset in memory
input id str10 name yob
1 "Amy" 1990
2 "Bill" 1991
3 "Cathy" 1989
end

// check
list
describe

// variables have 5 attributes: name, type, format, val label, and var label

// you can change the variable name with rename command.
// variable name can changed with rename command. name is case sensitive
rename yob year_of_birth
describe

// variable name is case sensitive. these are all different variables
generate Name = "Ah!"
generate nAme = "Oh"
generate naMe = "Ooops"
list

// now let's drop these three vars
drop Name nAme naMe

// data in memory disappears when we close stata
// but we can write the data as a .dta file on disk.
// the command is: save
save birth.dta, replace  // replace option overwrite

// later on, we can bring the data back using the "use" command
clear all // we first remove what we had in memory

use birth.dta
assert _N == 3 // make sure that the loaded data has a total of 3 observations

describe
list


// labels
// ------
clear all
use birth.dta
assert _N == 3
describe
list

// let's create gender variable based on name
generate int gender = 1 if name == "Amy" | name == "Cathy" // "|" means "or"
replace gender = 2 if name == "Bill" // boy
describe gender // this variable is of an int type variable

// we can tabulate how many boys and how many girls we have in the data
tabulate gender

// the values are not very informative. we can label the values
// doing the value label takes two steps:
// 1. create the value label itself. we use the same name("gender")
label define gender 1 "girl" 2 "boy"
// 2. attach the value label to a variable 
label values gender gender // 1st "gender" is var name and 2nd value label name

// check
describe gender // notice that the value label column
// the value label is used, if associated. for instance,
tabulate gender 

// well, let's do the variable label as well. it is simpler.
label variable gender "Gender of the respondent"
describe gender

// dataset (.dta) itself can be labeled as well
label data "birth year data"

// let's save this data as birth2.dta
save birth2.dta, replace
// check
describe


// summary and tabulate
// --------------------
// stata comes with some data files (.dta). Use "sysuse" instead of "use" to load
clear all
sysuse auto
describe

// how many observations there is? describe gives you the answer. 
// another way
count
// yet another way to find out how many observations there is
display _N

// how many variables? describe gives the answer, but here is another way
display c(k)

// let's see first 5 observations of the data
list in 1/5

// only a few variables
list make price mpg foreign in 1/5

// those observations at the end
list make price mpg foreign in -5/L

// you can do this, too
list m*  in 1/5 // variables whose name starts with m
list make-mpg in 1/5 // variables between make and mpg including both ends

// notice that the variable foreign has a label attached
describe foreign

// if we use the variable, the value label is in effect
tabulate foreign

// unless we specifically ask stata not to use the value labels
tabulate foreign, nolabel

// continuous variables can be summarized nicely with summarize command
summarize price

// detail option gives you more
summarize price, detail

// or graphically
twoway hist price

// or using inspect
inspect price

// or codebook
codebook make price


// import/export to excel
// ----------------------
clear all
sysuse auto
keep make price mpg foreign // drop all other variables
keep in 1/5 // keep only the first 5 observations
// check
describe

// export this data to an excel file, auto 
//   overwriting an existing excel file if any
//   with the first row with variable names
export excel using auto.xls, replace first(var)

// check -- let's open it in excel
!start auto.xls

// now let's see if we can bring it back.
// first clear the stata's memory
clear all
assert _N == 0

import excel using auto.xls, clear firstrow
// are we back? -- kind of. The foreign variable is now of str8 type
//   and we lost the value label as well.
// other types and formats are changed as well. Sometimes, you 
//   lose a lot of data (inadvertently) in translation 
describe
list


// append
// ------
clear all
// use a data file over http
use http://www.stata-press.com/data/r13/odd1  // this is our "master" data set

// check
list

// append adds observations at the bottom of the master
append using http://www.stata-press.com/data/r13/even

// check
list


// one-to-one match merge
// ----------------------
// create a master dataset
clear all
input id age
1 22
2 56
5 27
end

// checks
desc
list

// isid returns nothing if the given variable (or variables)
//   uniquely identifies each and every observation
isid id

// save as master.dta
save master.dta, replace

// create a using dadtaset
clear all
input id wgt
1 130
2 180
4 110
end

// checks
describe
list
isid id

// save as using.dta
save using.dta, replace

// now we are read to merge
clear all

// first load the master dataset
use master.dta, clear

// drop the automatic variable _merge, if any
// capture "absorbes" the error if any and let the script keep going
capture drop _merge
merge 1:1 id using "using.dta", report
drop _merge

// _merge == 1 means "from master dataset only"
// _merge == 2 means "from the using dataset only"
// _merge == 3 means "from both the master and using datasets" (matches)


// Many-to-one Match Merge
// -----------------------
// left as an exercise


// reading raw data
// ----------------
clear all

// reading effort.raw as free format data using infile
infile str14 country setting effort change using "test.raw", clear
assert _N == 20 // to make sure the correct number of observations

// check
describe
list
   
// do something with the data
summarize setting effort change
regress change setting effort

   
// reading raw data using a dictionary
// -----------------------------------
clear all

// make sure that we have both the .raw and .dct files in the pwd
ls test.*

// now we infile using the dictionary. The .raw data file name is specified
//   in the dictionary file, so we don't need to specify
infile using test.dct, clear
assert _N == 20

// check
describe
list
