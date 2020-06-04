#Install packages
library(readr)
library(dplyr)
library(gmodels)
library(ggplot2)
library(survival)
library(survminer)

#Function to drop columsn with removed information due to annonimisation
basic_edit <- function(dataset) {
   colnames(dataset) <- tolower(colnames(dataset))
   #Drop columsn with removed information due to annonimisation
   rem <- sapply(colnames(dataset), function(i) any(dataset[[i]] == "Removed"))  
   dataset <- dataset[!rem]
   return(dataset)
}

#Function to convert days to years
to_years <- function(column){
   return(column/365.25)
}

#SUBJECT_CHAR

subject_char <- read_csv("~/files/trial_data/tbla_Subjects.csv") %>% #General info about the subjects
    basic_edit() %>%
    #Studydayfromdaterandomised all = 0. Height is not mentioned in any of the results
    subset(select = -c(studydayfromdaterandomised, height)) %>%
    #Date of birth is days from the trial. It's negative values
    mutate(age = to_years(studydaydob) * -1) %>% 
    #Change to numeric trialstatuschangedate column and then change to years
    mutate(trialstatuschangedate = to_years(as.numeric(trialstatuschangedate))) %>%
    #Subject_no and centre_no as characters
    mutate(a_subjectno = as.character(a_subjectno)) %>%
    mutate(a_centreno = as.character(a_centreno))


#CHANGES OF STATUS

change_status <- read_csv("~/files/trial_data/tbla_StatusChangeHistory.csv") %>%
   basic_edit() %>%
   mutate(a_subjectno = as.character(a_subjectno)) %>%
   mutate(studydaystatuschangedate = to_years(studydaystatuschangedate)) 

#3 subjects had multiple status changes
duplicated <- change_status[duplicated(change_status$a_subjectno), "a_subjectno"]
status_duplicated <- change_status[change_status$a_subjectno %in% c(duplicated$a_subjectno), ] %>% 
    #It makes sense to only grab the first status change
    group_by(a_subjectno) %>%
    arrange(studydaystatuschangedate) %>% 
    slice(n())

#Remove the 3 duplicated status change that do not make sense  
change_status <- change_status[!(change_status$statuschangehistoryrowid %in% c(status_duplicated$statuschangehistoryrowid)), ] %>%
   #Status change history row id, no use
   select(select = - c(statuschangehistoryrowid))


#STATUS_ARBITRATION DATA SET (YES/NO) dataset

status_arbitration <- read.csv("~/files/trial_data/tbla_IMPStatusArbitration.csv") %>%
   basic_edit() %>%
   #Not interested in secondary endpoint
   select(select = - c(secondary.endpoint, studydaysecondarydate)) %>%
   #Column StudyDayPrimaryDate is a factor have to convert it to numeric 
   #Convert days to years
   mutate(studydayprimarydate = to_years(as.numeric(as.character(studydayprimarydate)))) %>%
   #Cannot do COX analysis if outcome is YES/NO --> 1/0
   mutate(primary.endpoint = ifelse(primary.endpoint == "YES", 1, 0))

#OUTCOME DATASET

status <- read_csv("~/files/trial_data/tbla_TrialStatusMasterList.csv")
treatment <- read_csv("~/files/trial_data/tbla_TreatmentNames.csv")

#Status change dates of this df make more sense than the ones in the sujbect df (<4 years)
#Keep column of change_status rather than subject_char

outcomes <- merge(x = subject_char, y=change_status, by="a_subjectno", all = TRUE) %>% 
   #Merge status_arbitration and outcomes
   merge(y = status_arbitration, by = "a_subjectno", all = TRUE) %>%
   #Drop trialstatuschangedate and trailstatusid and keep studydaystatuschangedate and statuschangedto
   select(select = -c(trialstatuschangedate, trialstatusid, studydaydob)) %>%
   #Change NA of statuschangedto to 1 (if status has not changed, the participant is active until the end)
   mutate(statuschangedto = ifelse(is.na(statuschangedto), 1, statuschangedto)) %>%
   mutate(statuschangedto = factor(statuschangedto, levels = status$TrialStatusID, labels = status$TrialStatusText)) %>%
   mutate(treatmentno = factor(treatmentno, levels = treatment$TreatmentNo, labels = treatment$TreatmentName)) %>%
   #If we do not have primary_outcome_date we still need a censoring time for those withount an outcome or that were discontinued
   mutate(time = ifelse(is.na(studydayprimarydate), studydaystatuschangedate, studydayprimarydate)) #There is still NA for subjects that lasted until the end
#When outcome is NO the time is NA, as the study lasted for 3 years change NA for 1092 days (3 years - 156 weeks)


#Cox proportional Hazards Model
surv_object <- Surv(time = outcomes$time, event = outcomes$primary.endpoint)
fit1 <- survfit(surv_object ~ treatmentno, data = outcomes)
surv_plot <- ggsurvplot(fit1, data = outcomes, pval = TRUE, risk.table = TRUE)
print(surv_plot)



