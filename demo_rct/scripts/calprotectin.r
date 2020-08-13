##########################
## Calprotectin #
##########################

library(dplyr)
library(tidyverse)
library(gmodels)
library(readr)
library(pROC)

source("./demo_rct/scripts/function.r")

calprot <- read.csv("./demo_rct/trial_data/tbla_endoscopyFindings.csv") %>%
      basic_edit() %>%
      col_class() %>%
      subset(visitno == 6 | visitno == 12)

calprot[calprot$rutgeerts == 'i2', "rutgeerts"] <- 2
calprot[calprot$rutgeerts == 'I4', "rutgeerts"] <- 4

calprot <- calprot %>%
      mutate(rutgeerts = as.numeric(as.character(rutgeerts)),
             cdeis = as.numeric(cdeis)) %>%
      drop_na(rutgeerts)

baseline <- read.csv("./demo_rct/results/baseline_factors.csv") %>%
      # Select only the variables important for the statistical analysis
      select(c(a_subjectno, treatmentno))


calprot <- merge(baseline, calprot, by = 'a_subjectno', all = FALSE) %>%
      # Endoscopic recurrence --> rutgeerts >= 2
      mutate(endoscopic_recurrence = as.factor(ifelse(rutgeerts >= 2, "Yes", "No")),
             treatmentno = as.factor(treatmentno))

res_calprot <- read_csv("./demo_rct/trial_data/tbla_BloodsTaken.csv") %>%
   basic_edit() %>%
   col_class() %>%
   select(c(a_subjectno, visitno, faecalcalprotectin, calprotectinresult, calprotectinsymbol)) %>%
   mutate(faecalcalprotectin = as.numeric(faecalcalprotectin),
          calprotectinresult = as.numeric(calprotectinresult)) %>%
   subset((faecalcalprotectin == 1 & visitno == 6) | (faecalcalprotectin == 1 & visitno == 12)) 

a <- merge(calprot, res_calprot, by = c('a_subjectno', 'visitno'), all = FALSE) %>%
   drop_na(calprotectinresult) %>%
   mutate(endoscopic_remission = as.factor(ifelse(rutgeerts == 0, "Yes", "No")))



# Endoscopic remission - Rug = 0
roc_recurrence <- roc(endoscopic_recurrence ~ calprotectinresult, data = a, ci = TRUE, plot = TRUE)
roc_remission <- roc(endoscopic_remission ~ calprotectinresult, data = a, ci = TRUE, plot = TRUE)


threshold_recurrence <- as.data.frame(ci.coords(roc_recurrence, x = c(50,100), transpose = FALSE, ret = c("threshold","sensitivity", "specificity", "ppv", "npv")))
threshold_remission <- as.data.frame(ci.coords(roc_remission, x = c(50,100), transpose = FALSE, ret = c("threshold","sensitivity", "specificity", "ppv", "npv")))



