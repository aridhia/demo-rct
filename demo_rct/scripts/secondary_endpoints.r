#############################################
# Generates dataset for secondary endpoints #
#############################################

# Packages

library(dplyr)
library(tidyverse)
library(gmodels)
library(pROC)

# Run script with pre-defined functions
source("./demo_rct/scripts/function.r")

# Import dataset with endoscopy information for each patient
endoscopy <- read.csv("./demo_rct/trial_data/tbla_EndoscopyFindings.csv") %>%
      basic_edit() %>%
      col_class() %>%
      subset(visitno == 6 | visitno == 12)

# Two of the endoscopic scores are written differently
endoscopy[endoscopy$rutgeerts == 'i2', "rutgeerts"] <- 2
endoscopy[endoscopy$rutgeerts == 'I4', "rutgeerts"] <- 4

endoscopy <- endoscopy %>%
      # Mutate scores to numeric
      mutate(rutgeerts = as.numeric(as.character(rutgeerts)),
             cdeis = as.numeric(cdeis)) %>%
      drop_na(rutgeerts)

# Import baseline dataset to allocate each patient to a treatment group
baseline <- read.csv("./demo_rct/results/baseline_factors.csv") %>%
      # Select only the variables important for the statistical analysis
      select(c(a_subjectno, treatmentno))

# Merging both datasets to create the final one
endoscopy <- merge(baseline, endoscopy, by = 'a_subjectno', all = FALSE) %>%
      # Endoscopic recurrence --> rutgeerts >= 2
      mutate(endoscopic_recurrence = as.factor(ifelse(rutgeerts >= 2, "Yes", "No")),
             treatmentno = as.factor(treatmentno))


