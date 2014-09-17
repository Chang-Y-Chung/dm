
show: dm.html
	open dm.html

dm.html: dm.Rmd
	rscript -e "library(rmarkdown); render('dm.Rmd', 'all')"

clean:
	rm -f ageWeight.dta auto.xls birth.dta birth?.dta
	rm -f even.dta odd.dta mydata.dta mydata?.dta random.png

