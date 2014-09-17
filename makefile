
show: dm.html
	rscript -e "library(rmarkdown);browseURL(paste('file://',file.path(getwd(), 'dm.html'), sep=''))"

dm.html: dm.Rmd
	rscript -e "library(rmarkdown); render('dm.Rmd', 'all')"

clean:
	rm -f ageWeight.dta auto.xls birth.dta birth?.dta
	rm -f even.dta odd.dta mydata.dta mydata?.dta random.png

