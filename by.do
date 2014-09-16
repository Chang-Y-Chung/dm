// Stata By-group Processing. In-depth Topic of Stata Workshop 2 (Data Management)
// by Chang Y. Chung on 2014-09-16

// Dataset as a Matrix
   // create a simple dataset
   clear
   input x y
   1 2 
   1 3
   1 4
   end
   
   // replace x values
   replace x = 2 * y
   list
   
   // we can do the same thing with manually looping over each observation
   // now the loop
   gen x2 = .
   local N = _N
   forval obs = 1/`N' {
      replace x2 = 2 * y[`obs'] if `obs' == _n   
   }
   list x x2
    
   // _N represents the total number of observations
   // _n the current observation number
   gen bigN = _N
   gen smallN = _n
   list *N
   
// Since All the Data Are in Memory
   // load auto data
   sysuse auto, clear
   // the value of make variable in the second observation
   di make[2]
   // the last observation's value
   di make[_N]
   
   // price[_n] is equal to price in most places
   gen priceSq1 = price * price
   gen priceSq2 = price[_n] * price[_n]
   assert priceSq1 == priceSq2  // nothing means that the condition is true
   
   // lag and lead
   // let's keep only the first five observations ordered by make
   keep if _n <= 5
   sort make
   list make price
   
   // let's create a variable lagPrice, which has the previous observation's price
   gen lagPrice = price[_n-1]
   list make price lagPrice
   // ok. price has a display format, %8.0gc, associated
   format lagPrice %8.0gc
   list make price lagPrice
   // lag once more
   gen lag2Price = price[_n-2]
   format lag2Price %8.0gc
   list make price lag2Price
   // or we can do "lead"
   gen leadPrice = price[_n+1]
   format leadPrice %8.0gc
   list make price leadPrice
   
   // if you have a time-series data, then you will be better off
   // using the tsset and then using time-series operators (L., L2., ...)
   // instead of explicit subscripting. try help tsset
   
// change the order of variables
   sysuse auto, clear
   // the given variable order is
   des
   // make mpg headroom weight ... price
   // let's change it so that the first three vars are: mpg make and price
   order mpg make price, first // first can be omitted since it is the default
   des
   // there are other options as well
   order mpg make price, last // last moves these variable to the end
   des
   
   // before
   order mpg make price, before(trunk)
   des
   
   // after
   order mpg make price, after(trunk)
   des
   
// change the order of observations   
   // in order to show how stata handles a null string in sort
   replace make = trim("") in 3/5 // a null string is different from blanks ("  ")
   list make price in 1/10
   // now sort, make a habit of specifying the stable option
   sort make, stable
   // see the null make's come up at top. 
   list make price in 1/10
  
   // reverse
   gsort -make
   list make price in 1/10
 
   // for numeric variables, the missing values appears last -- considered as largest
   //    non misisng values < . < .a < .b < ... < .z
   replace price = . in 5
   replace price = .d in 6
   sort price, stable
   list make price in -6/L
   
   // sort by multiple vars -- within the same value of foreign, sort by make
   sort foreign make, stable
   by foreign: list foreign make if _n <=5
   
   
// By Group   
   // how many distinct values the foreign variable has? two.
   tab foreign, nolabel missing
   // by-group processing
   sort foreign, stable
   by foreign: summarize price // this runs summarize twice
   
   // here is how to write above two commands in one
   bysort foreign: summarize price
   // or
   by foreign, sort: summarize price
   
   // if in parens then it is sorted but does not form by-groups
   bysort foreign (make): summarize price // it runs only twice
   
   // The system vars, _n and _N are reset at the by-group boundary
   sort foreign make, stable
   by foreign (make): gen bigN = _N
   by foreign (make): gen smallN = _n
   list make foreign *N
   
// Checking Household Member Roaster
   // a hypothetical data
   clear
   input hhid pid rel age str8 name
   1 1 1 46  "tom" 
   1 2 2 45  "mary"
   1 3 3 20  "scott"
   1 4 3 .   "jane" 
   2 1 1 57  "joe"
   2 2 2 50  "ann"
   end
   
   // attach the hhsize variable
   sort hhid, stable
   by hhid: gen hhsize = _N
   list, sepby(hhid)
   
   // is the pid always the same as the observation number within hh?
   sort hhid pid, stable
   by hhid (pid): gen pidOK = (pid==_n)
   list, sepby(hhid)
   
   // check if the first member is the head (rel==1)
   sort hhid pid, stable
   by hhid (pid): gen headFirst = (rel[1] == 1)
   list, sepby(hhid)
   
// exercise 2. find out for each household if they have any children
//   of the household head listed among the members.
// here is one way.
   generate isChild = 0
   replace isChild = 1 if rel == 3
   sort hhid pid, stable
   by hhid (pid): summ isChild
// by reading the output we know that hh 1 has a child or more
//   and hh 2 has no children.

// clean up
   drop isChild

// here is another way using egen
   generate isChild = (rel == 3) // true is 1, false is 0
   sort hhid pid, stable
   by hhid (pid): egen nChild = sum(isChild) 
   generate hasChild = (nChild > 0)
   list

// clean up again
   drop isChild nChild hasChild


// agerage age of the household members
   // a short way using the stata function that calculates running sum, sum()
   sort hhid, stable
   by hhid: gen avgAge = sum(age) / sum(!missing(age))
   by hhid: replace avgAge = avgAge[_N]
   list, sepby(hhid)
   
   // here is a long way
   sort hhid, stable
   by hhid: gen sumAge = sum(age)
   by hhid: gen avgAge2 = sum(age)/_n
   list hhid pid age sumAge avgAge2, sepby(hhid) // oops this is not correct because of missing age
   // we have to count non-missing age within hh
   gen ageNotMissing = !missing(age)
   by hhid: gen nAge = sum(ageNotMissing)
   // now we calculate the average age again
   drop avgAge2
   by hhid: gen avgAge2 = sumAge / nAge
   list hhid pid age nAge avgAge2, sepby(hhid) // looks good so far
   // now we take the last average age and attach it to all the members in the hh
   by hhid: replace avgAge2 = avgAge2[_N]
   list hhid pid age nAge avgAge2, sepby(hhid) // looks good
   
   // and here is the egen way
   by hhid: egen avgAge3 = mean(age)
   list hhid pid age avgAge avgAge2 avgAge3, sepby(hhid)
   
// Egen Example 1
   // counting missing values among a set of variables in each row
   clear
   use http://www.stata-press.com/data/r12/auto3
   corr price weight mpg 
   // only 70 obs are used. Why?
   egen excluded = rowmiss(price weight mpg)
   list make price weight mpg if excluded
   // ah, ha. the four observations with a missing on any of the three are dropped
   
   // you could have done this way as well
   clear
   use make price weigh mpg using http://www.stata-press.com/data/r12/auto3
   drop if missing(price, weight, mpg)
   count // this is the size of our analysis sample
   // then do the actual analysis
   corr price weight mpg
   
   // deviation from the median
   clear
   use http://www.stata-press.com/data/r12/egenxmpl2
   by dcode, sort:egen medstay = median(los)
   generate deltalos = los - medstay
   // check
   list in 100/150, sepby(dcode)
 
 
