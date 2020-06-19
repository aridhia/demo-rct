######It merges and cleans two datasets to create a dataset that contains only pre-randomisation data (baseline characteristics)

#PACKAGES

library(readr)
library(dplyr)
library(Hmisc)

#FUNCTIONS

basic_edit <- function(dataset) {
    #Column names to lowercase
    colnames(dataset) <- tolower(colnames(dataset))
    #Drop columns with removed information
    rem <- sapply(colnames(dataset), function(i) any(dataset[[i]] == "Removed"))
    dataset <- dataset[!rem]
    return(dataset)
}

col_class <- function(dataset) {
    
    dataset <- dataset %>%
        #Change all columns that contain date/day in the column name to numeric
        mutate_if(grepl('date|day', colnames(dataset)), as.numeric) %>%
        #Change subject number to character
        mutate(a_subjectno = as.character(a_subjectno))
    return(dataset)
}


#SUBJECT DATASET

subject_char <- read_csv("~/files/trial_data/tbla_Subjects.csv") %>%
    basic_edit() %>%
    col_class() %>%
    #Calculate age
    mutate(
        #Create a variable for age
        age = studydaydob / -365.25,
    )

#DISEASE HISTORY DATASET

crohn_history <- read_csv("~/files/trial_data/tbla_CrohnsHistory.csv") %>%
    basic_edit() %>%
    col_class()
    
#Variables that can be droped

variables_drop <- c("studydayfromdaterandomised", "height", "studydaydob", "studydaymonthsfromfirstsymptoms", "studydaymonthsfromoperation1", "operation1bowelresected", "studydaymonthsfromoperation2", "operation2bowelresected", "studydaymonthsfromoperation3", "operation3bowelresected", "timenomedicationmm", "timenomedicationyy", "timefiveasamm", "timefiveasayy", "timesteroidsmm", "timesteroidsyy")

#Dataset with the baseline characterstics

baseline <- merge(subject_char, crohn_history, all = TRUE)
baseline <- baseline[, !colnames(baseline) %in% variables_drop]


#write csv file
write.csv(baseline, "~/files/results/baseline_characteristics.csv", row.names = FALSE)
