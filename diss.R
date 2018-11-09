########################################
###### NSFG DISSERTATION ANALYSIS ######
########################################

#read in cleaned SAS dataset, using haven as recommended here: https://garthtarr.github.io/meatR/rio.html

setwd("U:/Dissertation")

install.packages("haven")
library(haven)

dat = read_sas("U:/Dissertation/nsfg_xport.sas7bdat","U:/Dissertation/formats.sas7bcat")

#do some checks to see if things were read in
head(dat)
summary(dat$RSCRAGE)
summary(dat$fmarstat)
summary(dat$bc)
table(dat$bc)

  #hot damn it worked! now i just need to figure out how to apply the formats

#i see the variable names were pulled-in uppercase, want to change to lower
names(dat) <- tolower(names(dat))
head(dat)

