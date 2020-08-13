###############################################################################
# This code creates a dataset that allows the analysis of the primary outcome #
###############################################################################


# PACKAGES
library(readr)
library(dplyr)
library(Hmisc)


#FUNCTIONS

source("./demo_rct/scripts/function.r")

    
# Dataset with information of whether each participant reached the endpoint (disease recurrence) or not and the time at whcih it happened
status_arbitration <- read.csv("./demo_rct/trial_data/tbla_IMPStatusArbitration.csv") %>%
    basic_edit() %>%
    # Endpoint date is treated as a factor when reading csv, have to change it to character before applying the col_class function
    mutate(studydayprimarydate = as.character(studydayprimarydate),
           studydaysecondarydate = as.character(studydaysecondarydate)) %>%
    col_class() %>%
    # To do the Cox analysis, the endpoint has to be coded as 1/0
    mutate(primary_endpoint = primary.endpoint, 
           secondary_endpoint = secondary.endpoint,
           primary.endpoint = ifelse(primary.endpoint == "YES", 1,0),
           secondary.endpoint = ifelse(secondary.endpoint == "YES", 1, 0)) %>%
    # Rename to make the code easier to understand
    rename(primary.time = studydayprimarydate,
           secondary.time = studydaysecondarydate)

# Importing dataset for the censored times
last_visit <- read_csv("./demo_rct/trial_data/tbla_VisitSchedule.csv") %>%
    basic_edit() %>%
    col_class() %>%
    # There are all the visits a subject has done throughout the trial (subjectno repeated for every visit)
    group_by(a_subjectno) %>%
    # Only interested in the last visit 
    slice(which.max(studydayfromactualdate)) %>%
    # Change name of the variable and drop the other columns
    transmute(last_visit = studydayfromactualdate)
    
# Merging last two datasets into one
outcomes <- merge(status_arbitration, last_visit, by = "a_subjectno", all = TRUE) %>%
    # Add last visit time to the subjects without time object
    mutate(primary.time = ifelse(!is.na(primary.time), primary.time, last_visit),
           secondary.time = ifelse(!is.na(secondary.time), secondary.time, last_visit))

# Importing dataset created with baseline.r
baseline <- read.csv("./demo_rct/results/baseline_factors.csv") %>%
    # Select only the variables important for the statistical analysis
    select(c(a_subjectno, a_centreno, treatmentno, smoker, age, azathioprine, sixmp, thiopurines, surgery, age_diagnosis, infliximab_methotrexate, disease_duration))

outcomes <- merge(baseline, outcomes, by = "a_subjectno", all = TRUE)


#Write final csv
write.csv(outcomes, "./demo_rct/results/outcomes.csv", row.names = FALSE)
write.csv(outcomes, "./demo_rct/survival_analysis/survival_analysis.csv", row.names = FALSE)

