*************************************************************************
* Introduction to Stata Data Management - Chang Y. Chung - September 2013
*************************************************************************

* slide 3 - Display 
*******************
clear all
display 1 + 2

display ln( 0.3 / (1-0.3) )
display logit(0.3)

* displaying a string
display "hello, world?"

* displaying a system value
display c(current_date)

* slide 4 - Stata Dataset
*************************
clear all
* describe the current Stata dataset in memory ("master" dataset)
describe

* create some observations -- still no variables
set obs 5
describe

* create a variable, x, which has the
* value 1 for all observations 
generate x = 1
describe

* create another variable y, which has the
* observation number as its value 
generate y = _n
describe
list

* slide 5 - Replace
*******************
clear all
set obs 5
generate x = 1
generate y = _n

replace x = 2  
list

* replace is often used with either "in" or "if"
replace x = 3 in 1/3 
replace y = 9 if y == 5
list

* other variables can be specified in an if condition
replace x = -99 if y < 3
list                          

* change the x values of -99 to "missing"
* and change y values of 9 to "missing"
replace y = . if y == 9
list

* slide 6 - Random Data
***********************
clear all
set obs 50
set seed 12345 
generate x = runiform()
generate y = runiform()
twoway scatter x y

* slide 7 - Missing Values
**************************
clear all
input x y
. 1
. 2
3 3
2 4
2 .
end

* create new variable high_y
* that dichotomizes y around 2.5
* This is incorrect !!! 
generate high_y = 0
replace high_y = 1 if 2.5 < y
list

* create high_y2 correctly ...
generate high_y2 = 0 if !missing(y) 
replace high_y2 = 1 if 2.5 < y & !missing(y) 
list

* slide 8 - Save and Use 
************************
* create and save Stata dataset
clear all
input id str10 name yob
1 "Amy" 1990
2 "Bill" 1991
3 "Cathy" 1989
end

list
describe

rename yob year_of_birth
describe

save birth.dta, replace  

* later, we can bring the data back into memory
* via the "use" command

clear all
use birth.dta
assert _N == 3
list

* slide 9 - Labels
******************
clear all
use birth.dta

generate gender = 1 if name == "Amy" | name == "Cathy" 
replace  gender = 2 if name == "Bill"
tabulate gender

* associating a variable with a value label requires two steps:
* first, create the value label
label define gender 1 "girl" 2 "boy"
* second, attach the value label to the variable 
label values gender gender 
tabulate gender 

* we can also create a variable label
label variable gender "Gender of the respondent"
describe gender

* slide 10 - Summarize
**********************
clear all
sysuse auto

list make price mpg foreign in 1/5
list make price mpg foreign in -5/L

* variable foreign has a value label
tabulate foreign
tabulate foreign, nolabel

* continuous variables can be 
* summarized nicely via the "summarize" command 
summarize price
summarize price, detail

* other commands
inspect price
codebook make price

* slide 11 - Excel 
******************
clear all
sysuse auto
keep make price mpg foreign
keep in 1/5

export excel using auto.xls, replace first(var)

!start auto.xls
* !open auto.xls * on mac
* bring the excel file back into memory as a Stata dataset

clear all
import excel using auto.xls, clear firstrow

describe
list

* slide 14 - Append Example 
***************************
clear all
use http://www.stata-press.com/data/r13/odd1  
append using http://www.stata-press.com/data/r13/even
list

* slide 16 - One-to-One Match Merge Example
*******************************************
* create a master dataset
clear all
input id age
1 22
2 56
5 27
end
save master.dta, replace

* create a using dataset
clear all
input id wgt
1 130
2 180
4 110
end
save using.dta, replace

* now we are ready to merge
clear all
use master.dta, clear
capture drop _merge
merge 1:1 id using "using.dta", report
drop _merge

* slide 21 - Free Format
************************
clear all
infile str14 country setting effort change using "test.raw", clear

* slide 22 - Fixed Column Format
********************************
clear all
infile using test.dct, clear
