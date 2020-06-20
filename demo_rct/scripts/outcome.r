#########
#This code creates a dataset that allows the analysis of the primary outcome
#########


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


#Import baseline_factors generated with the file "baseline.r"
baseline <- read_csv("./demo_rct/results/baseline_factors.csv") %>%
    col_class()
    
#STATUS OF ARBITRATION
#Dataset with information of whether each participant reached the endpoint (disease recurrence) or not and the time at whcih it happened
status_arbitration <- read.csv("./demo_rct/trial_files/tbla_IMPStatusArbitration.csv") %>%
    basic_edit() %>%
    ##Primary endpoint date is treated as a factor when reading csv, have to change it to character before applying the col_class function
    mutate(studydayprimarydate = as.character(studydayprimarydate)) %>%
    col_class() %>%
    #Not interested in the secondary enpoint
    subset(select = -c(secondary.endpoint, studydaysecondarydate)) %>%
    #To do the Cox analysis, the endpoint has to be coded as 1/0
    mutate(primary.endpoint = ifelse(primary.endpoint == "YES", 1,0))

#Merging baseline and status of arbitration datasets to start building the outcomes dataset
outcomes <- merge(baseline, status_arbitration, by = "a_subjectno", all = TRUE) %>%
    #New variable called "time" where the time object for the Cox analysis will be stored for every subject
    #In the status_arbitration dataset there is the studydayprimarydate, which is the date when the primary outcome, if it did not occur is NA
    mutate(time = ifelse(!is.na(studydayprimarydate), studydayprimarydate, NA))

#CHANGE OF STATUS
#Dataset with information about status changes, such as early withdrawls, dead, lost to follow up...
change_status <- read_csv("./demo_rct/trial_files/tbla_StatusChangeHistory.csv") %>%
    basic_edit() %>%
    col_class() %>%
    #statuschangerowid is not found in any other table
    subset(select=-c(statuschangehistoryrowid)) %>%
    #Status_change variables show the time in which subjects were lost to follow up or abandoned the trial
    #3 subjects have 2 changes of status, only interested in the last status change
    group_by(a_subjectno) %>%
    arrange(studydaystatuschangedate) %>%
    slice(n())

#Addition of change_status to outcome

outcomes <- 
    merge(outcomes, change_status, by = "a_subjectno", all = TRUE)%>%
    #In the baseline dataset there was also a "status change date" variable
    #Both columns relating to status don't show the same values for the subjects and have NA
    #6 subjects without primary endpoint have different status change dates between those two columns 
    mutate(
    #New variable to join both status change date preferently keeping the date from the change_status dataset (after reviewing differences, it was assessed that it was more logical)
        status_change = ifelse(!is.na(studydaystatuschangedate), studydaystatuschangedate, trialstatuschangedate),
    #Updating time variable to add time for those subjects with status change
        time = ifelse(!is.na(time), time, status_change)
    )
#In the time variable there is NA values for those that did not withdrawn or had the primary outcome
#For these subjects, the time object will be defined as the day of the last visit

#LAST VISIT
##Importing the data
last_visit <- read_csv("./files/trial_files/tbla_VisitSchedule.csv") %>%
    basic_edit() %>%
    col_class() %>%
    #There are all the visits a subject has done throughout the trial (subjectno repeated for every visit)
    group_by(a_subjectno) %>%
    #Only interested in the last visit 
    slice(which.max(studydayfromactualdate)) %>%
    #change name of the variable and drop the other columns
    transmute(last_visit = studydayfromactualdate)
    
#Addition to the outcomes dataset
outcomes <- merge(outcomes, last_visit, by = "a_subjectno", all = TRUE) %>%
    #Add last visit to the subjects without time object
    mutate(time = ifelse(!is.na(time), time, last_visit))


#Write final csv
write.csv(outcomes, "./demo_rct/results/outcomes.csv", row.names = FALSE)
print("Outcome.csv created")
