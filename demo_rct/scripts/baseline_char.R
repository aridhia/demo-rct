######
#It merges and cleans several csv files to create a dataset that contains pre-randomisation data (baseline characteristics)
#####


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
        #Change subject number to a character variable
        mutate(a_subjectno = as.character(a_subjectno))
    return(dataset)
}


#SUBJECT DATASET
##Importing the dataset
subject_char <- read_csv("./demo_rct/trial_files/tbla_Subjects.csv") %>%
    #Applying the two functions to make general changes
    basic_edit() %>%
    col_class() %>%
    #Calculate age in years; in the original csv file it was defined as days from the day of randomisation
    mutate(
        #Create a variable for age
        age = studydaydob / -365.25,
    )

#DISEASE HISTORY DATASET
##Importing the dataset
crohn_history <- read_csv("./demo_rct/trial_files/tbla_CrohnsHistory.csv") %>%
    #General changes using the functions defined previously
    basic_edit() %>%
    col_class()
    
#Variables that can be droped
## These variables are incomplete or not used at all during the analysis

variables_drop <- c("studydayfromdaterandomised", "studydaydob", "studydaymonthsfromfirstsymptoms", "studydaymonthsfromoperation1", "operation1bowelresected", "studydaymonthsfromoperation2", "operation2bowelresected", "studydaymonthsfromoperation3", "operation3bowelresected", "timenomedicationmm", "timenomedicationyy", "timefiveasamm", "timefiveasayy", "timesteroidsmm", "timesteroidsyy")

#CREATING THE DATASET FOR THE BASELINE CHARACTERISTICS
#Merger of the two dataset imported before
baseline <- merge(subject_char, crohn_history, all = TRUE)
#Dropping the variables defined previously as variables_drop
baseline <- baseline[, !colnames(baseline) %in% variables_drop]

#CONVERSION OF SOME VARIABLES INTO FACTORS

#Imorting Trial Master Lists with information of the coding of factors
status <- read_csv("./demo_rct/trial_files/tbla_TrialStatusMasterList.csv")
treatment <- read_csv("./demo_rct/trial_files/tbla_TreatmentNames.csv")

#Factor variables with options yes/no coded as 1/2
factors_yn <- function(x) (factor(x, levels = c(1,2), labels = c("Yes", "No")))
yn <- c("smoker", "sixmp", "stricturoplasty", "otherdisease", "familyhistoryibd" , "azathioprine", "previousinfliximab", "methotrexate", "othercorticosteroids", 
        "fiveasa", "topicaltreatments", "arthralgia", "iritis", "fissure", "otherfistula")

#Factor variables of symptoms categorized into 4 levels
factor_symptoms <- function(x) (factor(x, levels = c(0,1,2,3), labels = c("None", "Mild", "Moderate", "Severe")))
symptoms <- c("pain", "diarrhoea", "anorexia", "fever", "bleeding")


#Creating final dataset mutating those variables that need to be converted into factors
baseline <- baseline %>%
    #Add lebels to factorial variables and generate new variables from the existing ones
    mutate(
        #Factor using trial master lists
        treatmentno = factor(treatmentno, levels = treatment$TreatmentNo, labels = treatment$TreatmentName),
        trialstatusid = factor(trialstatusid, levels = status$TrialStatusID, labels = status$TrialStatusText),
        #Manually generated factors - labels extracted from annonymised data dictionary
        gender = factor(gender, levels = c("F", "M"), labels = c("Female", "Male")),
        tpmt = factor(tpmt, levels = c(1,2), labels = c("Normal", "Heterozygous")),
        diagnosisage = factor(diagnosisage, levels = c("A1", "A2", "A3"), labels = c("<16", "17-40", ">40")),
        diseaselocation = factor(diseaselocation, levels = c("L1", "L2", "L3"), labels = c("Ileal", "Colonic", "Ileaocolonic")),
        diseasebehaviour = factor(diseasebehaviour, levels = c("B1", "B2", "B3"), labels = c("Non stricturing, Non penetrating", "Stricturing", "Penetrating")),
        #New variables that are easier to study
        age_diagnosis = case_when(diagnosisage == "<16" ~ "<=40", diagnosisage == "17-40" ~ "<=40", age > ">40" ~ ">40"),
        #6-MP (Mercaptopurine) and Azathioprine are both Thiopurines
        thiopurines = ifelse(sixmp == "Yes" | azathioprine == "Yes", "Yes", "No"),
        #Surgery coded as yes/no variable. In the original dataset operationnumber = 1 coded for no previous surgery
        surgery = ifelse(operationnumber == 1, "No", "Yes"),
        #Converting months from diagnosis into years
        years_from_diagnosis = studydaymonthsfromdiagnosis / -12
    ) %>%
    #Change to factors from the lists
    mutate_at(symptoms, factor_symptoms) %>%
    mutate_at(yn, factors_yn)



#WRITE CSV FILE
###This goes to results folder
write.csv(baseline, "./demo_rct/results/baseline_factors.csv", row.names = FALSE)
###This goes to the app folder
write.csv(baseline, "./demo_rct/baseline_app/baseline_factors.csv", row.names = FALSE)
                  
