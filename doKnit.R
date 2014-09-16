# convert dm.Rmd into dm.html for presentation
# and open dm.html in the default browser
# requires rmarkdown package (see http://rmarkdown.rstudio.com)
#
# cd into the folder where dm.Rmd is located and run at bash prompt:
# $ rscript doKnit.R

library(knitr)
library(rmarkdown)
render('dm.Rmd')
browseURL(paste('file://', file.path(getwd(), 'dm.html'), sep=''))
