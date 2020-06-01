#Packages
library(readr)
library(dplyr)
library(gmodels)
library(ggplot2)
library(table1)
library(survival)
library(ranger)
library(ggfortify)

#Import data
subject_char <- read_csv("./Data/tbla_Subjects.csv")
diagnosis <- read_csv("./Data/tbla_CrohnsHistory.csv")
status_arbitration <- read.csv("./Data/tbla_IMPStatusArbitration.csv")

#Colnames to lowercase
colnames(subject_char) = tolower(colnames(subject_char))
colnames(diagnosis) = tolower(colnames(diagnosis))
colnames(status_arbitration) = tolower(colnames(status_arbitration))

#Drop columns with "Removed" information due to annonimisation
remove_annonn <- function(dataset) {
   dataset[dataset == 'Removed'] <- NA
   dataset <- dataset %>% select_if(~ !any(is.na(.)))
   return(dataset)
}

subject_char <- remove_annonn(subject_char)
diagnosis <- remove_annonn(diagnosis)
status_arbitration <- remove_annonn(status_arbitration)

#Calculate age from subject data
subject_char$age = subject_char$studydaydob/-365

#Change to numeric "trial status change date" column
subject_char$trialstatuschangedate <- as.numeric(subject_char$trialstatuschangedate)

#Column StudyDayPrimaryDate is a factor have to convert it to numberic 
status_arbitration$studydayprimarydate <- as.numeric(as.character(status_arbitration$studydayprimarydate))
#Cannot do COX analysis if outcome is YES/NO --> Change it to 1/0 there is one NA value
status_arbitration <- status_arbitration %>% mutate(primary.endpoint = ifelse(primary.endpoint == "YES",1, 
                                                                              ifelse(primary.endpoint == "NO", 0, NA)))

#Join tables
baseline_char <- merge (x = subject_char, y = diagnosis, by="a_subjectno", all=TRUE)
baseline_char <- merge (x = subject_char, y = status_arbitration, by="a_subjectno", all=TRUE)

#Make a variable time that is the time to primary output, lost to follow up or drop out
baseline_char$time <- ifelse(is.na(baseline_char$studydayprimarydate), baseline_char$trialstatuschangedate, 
                             baseline_char$studydayprimarydate) #Works but still NA

#When outcome is NO the time is NA, as the study lasted for 3 years change NA for 1092 days (3 years - 156 weeks)
baseline_char$time[is.na(baseline_char$time)] <- 1092


