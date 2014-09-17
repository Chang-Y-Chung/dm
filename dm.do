// Stata Workshop 2 Data Management 2014-09-17 Chang Y. Chung

// let it run
set more off


// SLIDE #4 Setup
// cd to where you put this file (dm.do) in. Here we assume that
//   the directory is z:\dm
cd z:\dm

// check which directory I am in
pwd


// SLIDE #5 Display
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


// SLIDE #6 Stata Dataset
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

// save the master data into a file on the harddrive
save mydata.dta, replace


// SLIDE #7 Use and List a Dataset
// list shows them all
use mydata, clear
list

// individual values can be displayed using var[obs#] syntax
display x[1] // first observation value of variable x
display y[2] // second observation value of variable y

// guess what this displays?
display y[_N]


// SLIDE #8 Replace
// replace changes values of the existing variable
// -------------------------------------------------
use mydata, clear

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

save mydata2, replace


// SLIDE #9 See mydata2.dta
use mydata2, clear
list in 1/5


// SLIDE #10 Random Data
// something cool
clear all
set obs 50
set seed 12345 // set a random seed
generate x = runiform()
generate y = runiform()
twoway scatter x y
graph export random.png, width(400) height(300) replace


// try changing number of observations to 10000
// try changing runiform() to rnormal(1,1)
clear all
set obs 10000
set seed 12345
gen x = rnormal(1,1)
gen y = rnormal(2,1)
twoway scatter x y


// SLIDE #12 Missing Values
// missing values are larger than any number
// -----------------------------------------
use mydata2, clear

// check
list
describe


// SLIDE #13 Dichotomizing y Around 2.5
// create a new variable dichotomizing y around 2.5
use mydata2, clear

// this may *not* be correct. Why?
// high_y is incorrect since the missing value (.) is larger than any number
generate high_y = 0
replace high_y = 1 if 2.5 < y
list

// correct way
generate high_y2 = 0 if !missing(y)          // ! means "not"
replace high_y2 = 1 if 2.5 < y & !missing(y) // & means logical "and"
list

save mydata3, replace

// another way -- utilizing the fact that a true expression evaluates to 1
//   and false to 0 
generate high_y3 = (2.5 < y) if !missing(y)
list

// going the other way, 0 is false and any other numeric value is true
list if 0  // no observation is listed since 0 is false
list if 23.56 // any other values are true

// let's drop high_y, since it is incorrect!
drop high_y


// SLIDE #14 mydata3.dta
use mydata3, clear
list y high_y high_y2


// SLIDE #15 Save
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

// data in memory disappears when we close stata
// but we can write the data as a .dta file on disk.
// the command is: save
save birth.dta, replace  // replace option overwrite


// variable name is case sensitive. these are all different variables
generate Name = "Ah!"
generate nAme = "Oh"
generate naMe = "Ooops"
list

// now let's drop these three vars
drop Name nAme naMe


// SLIDE #16 Use
// later on, we can bring the data back using the "use" command
use birth.dta, clear
assert _N == 3 // make sure that the loaded data has a total of 3 observations

describe
list, abbreviate(15) // with no option, list will abbreviate long var names


// SLIDE #17 Labels
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

// the above recoding step is robust even when the name is missing. Why?
// since we are specifically testing for such names. Missing name (blanks)
// don't match any of the conditions, thus gender remains missing.

// we can tabulate how many boys and how many girls we have in the data
tabulate gender
save birth2, replace


// SLIDE #18 Labeling Values Takes Two Steps
// the values are not very informative. we can label the values
// doing the value label takes two steps:
// 1. create the value label itself. we use the same name("gender")
label define gender 1 "girl" 2 "boy"
// 2. attach the value label to a variable 
label values gender gender // 1st "gender" is var name and 2nd value label name
save birth3, replace


// SLIDE #19 Check
// check
use birth3, clear
// the value label is used, if associated. for instance,
tabulate gender
describe gender // notice that the value label column


// SLIDE #20 Labeling a Variable
use birth3, clear

// well, let's do the variable label as well. it is simpler.
label variable gender "Gender of the respondent"
describe gender

// dataset (.dta) itself can be labeled as well
label data "birth year data"

// notice that the dataset label appears on top-right on describe output
describe


// SLIDE #21 Some Variables from Auto.dta
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


// SLIDE #22 Tabulate With Value Label
// if we use the variable, the value label is in effect
sysuse auto, clear
tabulate foreign


// SLIDE #23 Tabulate Without Value Label
// unless we specifically ask stata not to use the value labels
sysuse auto, clear
tabulate foreign, nolabel


// SLIDE #24 Summarize
// continuous variables can be summarized nicely with summarize command
sysuse auto, clear
summarize price mpg

// detail option gives you more
summarize price, detail

// or graphically summarize
twoway hist price


// SLIDE #25 Other Useful Commands
sysuse auto, clear

describe make mpg price

// or using inspect
inspect make mpg price

// or codebook
codebook make mpg price


// SLIDE #26 Export to Excel
// import/export to excel
// ----------------------
clear all
sysuse auto
keep make price foreign // drop all other variables
keep in 1/5 // keep only the first 5 observations
// check
describe

// export this data to an excel file, auto 
//   overwriting an existing excel file if any
//   with the first row with variable names
export excel using auto.xls, replace first(var)

// check -- let's open it in excel
!start auto.xls   // windows
// !open auto.xls // mac

// now let's see if we can bring it back.
// first clear the stata's memory to make sure
clear all
assert _N == 0  // if no complaints, then no observation at all

// SLIDE #27 Import from Excel
import excel using auto.xls, clear firstrow

// are we back? -- kind of. The foreign variable is now of str8 type
//   and we lost the value label as well.
// other types and formats are changed as well. Sometimes, you
//   lose a lot of data (inadvertently) in translation
describe
list

// SLIDE #33 Append Example Creating odd.dta
// append
// ------
clear all
// use a data file over http
use http://www.stata-press.com/data/r13/odd1  // this is our "master" data set
keep in 1/3

// check
list
save odd.dta, replace

// SLIDE #34 Append Example Creating even.dta
// this is really tiny. only two obs and three vars
clear all
input number even odd
4 10 .
5 12 .
end
list
save even.dta, replace


// SLIDE #35 Append Example Put odd.dta and even.dta Together
// we are using odd.dta as the master dataset
use odd.dta, clear

// append adds observations at the bottom of the master
// generate option adds a new variable (of the given name),
//   which indicates where each observation is from:
//   0 means from master dataset
//   1 from the first using dataset
//   2 from the second using dataset 
//   3 and so on
append using even.dta, generate(obsFrom)

// check
list


// SLIDE #37 Merge Example
// one-to-one match merge
// ----------------------
// we are using age.dta and weight.dta, provided in the current directory.
// age.dta as the master dataset.
use age.dta, clear

// isid returns nothing if the given variable (or variables)
// uniquely identifies each and every observation
isid id
list

// Let's check the using data as well
use weight.dta, clear
isid id
list

// the two datasets seem to be in order with unique ids
// let's start merging. First, we load the master dataset into memory
use age.dta, clear

// drop the automatic variable _merge, if any
// capture "absorbes" the error if any and let the script keep going
// this way we are OK in both the cases whether or not age dataset
//   has the variable _merge
capture drop _merge

// merge in the weight.dta dataset one-on-one matching on id variable
merge 1:1 id using weight, report

// if everything is OK, then now we drop the merge flag variable
// this time, we know for sure that there is such variable
drop _merge

// now we save the merged dataset -- which is the new master data on memory
// as ageWeight.dta
save ageWeight, replace

// check
use ageWeight, clear
desc
list


// Many-to-one Match Merge
// -----------------------
// left as an exercise. Read Bill Gould's two-part blog entries at:
// Part 1: Merges gone bad @ http://tinyurl.com/jvtloka
// Part 2: Multiple-key merges @ http://tinyurl.com/krhs7xn


// SLIDE #43 infile Example
// reading raw data
// ----------------
clear all

// reading effort.raw as free format data using infile
infile str14 country setting effort change using "test.raw", clear
assert _N == 20 // to make sure the correct number of observations

// check
describe
list in 1/3

// do something with the data
summarize setting effort change
regress change setting effort


// reading raw data using a dictionary
// -----------------------------------
clear all

// make sure that we have both the .raw and .dct files in the pwd
ls test.*


// SLIDE #43 Fixed Column Format
// now we infile using the dictionary. The .raw data file name is specified
//   in the dictionary file, so we don't need to specify
infile using test.dct, clear
assert _N == 20

// check
describe
list

