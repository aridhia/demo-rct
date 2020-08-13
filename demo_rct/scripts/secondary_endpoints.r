########################################
# Generates dataset for 2ari endpoints #
########################################


library(dplyr)
library(tidyverse)
library(gmodels)
library(pROC)

source("./demo_rct/scripts/function.r")

endoscopy <- read.csv("./demo_rct/trial_data/tbla_EndoscopyFindings.csv") %>%
      basic_edit() %>%
      col_class() %>%
      subset(visitno == 6 | visitno == 12)

endoscopy[endoscopy$rutgeerts == 'i2', "rutgeerts"] <- 2
endoscopy[endoscopy$rutgeerts == 'I4', "rutgeerts"] <- 4

endoscopy <- endoscopy %>%
      mutate(rutgeerts = as.numeric(as.character(rutgeerts)),
             cdeis = as.numeric(cdeis)) %>%
      drop_na(rutgeerts)

baseline <- read.csv("./demo_rct/results/baseline_factors.csv") %>%
      # Select only the variables important for the statistical analysis
      select(c(a_subjectno, treatmentno))


endoscopy <- merge(baseline, endoscopy, by = 'a_subjectno', all = FALSE) %>%
      # Endoscopic recurrence --> rutgeerts >= 2
      mutate(endoscopic_recurrence = as.factor(ifelse(rutgeerts >= 2, "Yes", "No")),
             treatmentno = as.factor(treatmentno))


calprotectin <- read_csv("./demo_rct/trial_data/tbla_BloodsTaken.csv") %>%
      basic_edit() %>%
      col_class() %>%
      select(c(a_subjectno, visitno, faecalcalprotectin, calprotectinresult, calprotectinsymbol)) %>%
      mutate(faecalcalprotectin = as.numeric(faecalcalprotectin),
             calprotectinresult = as.numeric(calprotectinresult)) %>%
      subset((faecalcalprotectin == 1 & visitno == 6) | (faecalcalprotectin == 1 & visitno == 12)) 

endoscopy <- merge(endoscopy, calprotectin, by = c('a_subjectno', 'visitno'), all = FALSE) %>%
      drop_na(calprotectinresult) %>%
      mutate(endoscopic_remission = as.factor(ifelse(rutgeerts == 0, "Yes", "No")))
