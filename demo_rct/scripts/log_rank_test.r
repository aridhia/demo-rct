#####################
####LOG-RANK TEST####
#####################

#Packages
library(survival)
library(readr)

#Import data that will be used to do the analysis
#Outcomes dataset, elaborated witht outcome.R 
outcomes <- read_csv("./demo_rct/results/outcomes.csv")

#First, create a survival object that consist of the time and whether the endpoint was reached
surv_object <- Surv(outcomes$time, outcomes$primary.endpoint)

#survdiff() can be used to compute the log-rank test comparing two survival curves

log_rank <- survdiff(surv_object ~ treatmentno, data = outcomes)
log_rank
