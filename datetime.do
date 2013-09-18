// Stata Date & Time. In-depth Topic of Stata Workshop 2 (Data Management)
// by Chang Y. Chung 2013-09-18

// two storage types
   clear all
   sysuse auto
   
   // see the list of variables and their storage types
   des
   
   // list first 4 values of variable, make
   list make in f/4

   // list last 3 values of variable, price
   list price in -3/L

// String to Numeric and Back
   
// an example of string variable with only digits
// also shows how to write out a numeric value to a string
   gen strID = string(2340285 + _n, "%09.0f")
   list strID in 1/4
   
// strID --> numeric ID
   gen double nID = real(strID)
   list *ID in 1/4   
   
   // clean up
   drop strID nID
   
   
// display format
   
   // see the display formats associated with each var
   des
   
   // list last three values of price
   list price in -3/L
   
   // change the price format
   format price %8.2f
   list price in -3/L
   
   // change it again
   format price %06.0f
   list price in -3/L
   
   // clean up
   format price %8.0gc
   
   
// value label

   // see the associated label for var, foreign
   des foreign

   // list value labels stored in the dataset
   label list

   // frequency table of foreign -- value label is in effect
   tab foreign 

   // same table again with no value labels
   tab foreign, nolabel

   // let's detach the label origin from the variable foreign
   label values foreign 

   // we can even delete the already detached label like this
   label drop origin

   // ok table foreign again. it does not have any value label attached
   tab foreign

   // let's create and attach a value label called, foreign.
   // it is OK to name the value label the same as the variable
   //   since the two name spaces are separate.
   label define foreign 1 "foreign" 0 "domestic"
   label values foreign foreign

   // check
   tab foreign

   // advanced. numlabel can alter value labels so that it add/remove actual values
   numlabel foreign, add

   // see the effect?
   tab foreign

   // clean up
   numlabel foreign, remove
	
	
// encoding
   clear
   
   // create five observations. still no vars yet
   set obs 5
   list
   
   // create a string variable gender
   generate str4 gender = "Male" in 1/3
   replace gender = "Female" if _n >= 4
   // check
   list
   
   // manually encode gender to a numeric var, female
   gen female = 1 if gender == "Female"   // notice the two equal signs!
   replace female = 0 if gender == "Male"
   
   // we then create a value label
   label define femaleLabel 1 "female" 0 "male"
   // and associate with the female variable
   label values female femaleLabel
   
   // check -- the two var looks the same
   list gender female
   // but they are not -- if you see actual values with no labels
   list gender female, nolabel
   
   
   // create a string income variable
   set seed 123456 // always set seed before using a random number generator
   gen str4 income = cond(runiform() < 0.5, "high", "low")
   // check
   list income
   
   // create a numeric variable, inc, encoding income into 1, 2
   encode(income), gen(inc)
   // check -- again, they look the same
   list income inc
   // but this was because the encode command was working hard for us 
   label list inc
   des inc
   list income inc, nolabel
   

// Date Variable as an encoding 
   clear
   // create a var, birthday
   set obs 9
   gen birthday = .
   local n = 1
   foreach val in -2 -1 0 1 2 3 19023 19030 19031 {
      replace birthday = `val' in `n++'
   }
   // check
   list, clean 

// just a numeric variable
   
   // format with the canonical date format %td
   format birthday %td
   // now it is a date variable
   list birthday, clean
   
   // apply different formats and see how it looks different
   format birthday %tdNN-DD-CCYY
   list birthday, clean
   
   // you can see the last date, feb. 8, 2012 in different formats using display
   display %7.0g birthday[_N] " " %tdnn/dd/yy birthday[_N] "   " %tdDD-mon-CCYY birthday[_N]
   
   
// Since Date Values are Numbers
   // sort by birthday -- already done smaller number first
   sort birthday
   
   // reverse sort -- larger number first
   gsort -birthday
   list, clean
   
   // based on the numeric values, that is
   gen numericValue = birthday
   list birthday numericValue, clean
   
   // two days later
   di %td td(08feb2012) + 2
   
   // extracting parts
   gen month = month(birthday)
   gen day = day(birthday)
   gen year = year(birthday)
   gen dow = dow(birthday)
   // let's label the dayOfWeek
   lab def dow 0 "Sun" 1 "Mon" 2 "Tue" 3 "Wed" 4 "Thu" 5 "Fri" 6 "Sat"
   lab values dow dow // it is ok to make the label name the same as the variable
   list birthday dow month day year, clean
   
   // put parts into a date
   di %tdnn/dd/ccyy mdy(2, 8, 2012)

// Date Calculation Examples
   
   // Yuna Kim's aproximate age as of today. her birthday is Sep. 5, 1990
   // when reading the string date, use date() function, like so:
   di "today is " date("02/08/2012", "MDY")
   // td() is a pseudo-function that returns the numeric value of the date
   di "Yuna's birthday is " td(5sep1990)
   // date variable calculation is nothing but arithmetics
   di "Yuna's age today (in days) is " 19031 - 11205
   di "  Which is approx. (in years) " 7826 / 365.25
   
   // Tomorrow is my day 1 for the 30-day South beach diet
   // Day 1 on diet will be;
   di "day 1: " string(19031 + 1, "%td")
   // Day 2 on diet will be:
   di "day 2: " string(19031 + 2, "%td")
   // Day 3 on diet will be:
   di "day 3: " string(19031 + 3, "%td")
   // My last day on diet will be:
   di "day 30: " string(19031 + 30, "%td")

   // when you have a date variable, how do you write the date as a string?
   // using string function, of course. Here is another example
   gen strBirthday = string(birthday, "%tdnn/dd/ccyy")
   // check
   des strBirthday // check to make sure that this is a string var
   format strBirthday %-10s // left align
   list strBirthday  
   
// Exercise 1. Jae-sang Park, aka Psy, was born on Dec. 31, 1977. How old was 
// Psy when he released the music video, Gangnam Style, on YouTube?
   clear
   set obs 1
   gen birth = td(31dec1977)
   gen upload = mdy(7, 15, 2012)
   gen ageAtUpload = (upload - birth) / 365.25
      
   format birth %td
   format upload %td
   list   
// this is an approximate age in years. calculating age at last birthday (in years)
//   especially for children is tricky.

// another exercise -- calculate an approximate age(in years) as of today
   clear
   input str6 name str10 birthday 
   "Amy"    "01/01/1990"
   "Betty"  "02/01/1991"
   "Cathy"  "03/01/1992"
   "Dasy"   "04/27/2003" 
   end
   list
   
   
   
   
      
