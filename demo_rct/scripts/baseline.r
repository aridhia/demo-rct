######
#It merges and cleans several csv files to create a dataset that contains pre-randomisation data (baseline characteristics)
#####


#PACKAGES

library(readr)
library(dplyr)
library(Hmisc)


source("./demo_rct/scripts/function.r")


#SUBJECT DATASET
subject_char <- read_csv("./demo_rct/trial_data/tbla_Subjects.csv") %>%
    #Applying the two functions to make general changes
    basic_edit() %>%
    col_class() %>%
    #Calculate age in years; in the original csv file it was defined as days from the day of randomisation
    mutate(
        #Create a variable for age
        age = studydaydob / -365.25,
    )

# DISEASE HISTORY DATASET
crohn_history <- read_csv("./demo_rct/trial_data/tbla_CrohnsHistory.csv") %>%
    #General changes using the functions defined previously
    basic_edit() %>%
    col_class()
    
# Variables that can be droped - incomplete or not used at all during the analysis

variables_drop <- c("studydayfromdaterandomised", "studydaydob", "studydaymonthsfromfirstsymptoms", "studydaymonthsfromoperation1", "operation1bowelresected", "studydaymonthsfromoperation2", "operation2bowelresected", "studydaymonthsfromoperation3", "operation3bowelresected", "timenomedicationmm", "timenomedicationyy", "timefiveasamm", "timefiveasayy", "timesteroidsmm", "timesteroidsyy")

# Merge the two dataset imported before
baseline <- merge(subject_char, crohn_history, all = TRUE)
# Dropping the variables defined previously as variables_drop
baseline <- baseline[, !colnames(baseline) %in% variables_drop]

#CONVERSION OF SOME VARIABLES INTO FACTORS

# Imorting Trial Master Lists with information of the coding of factors
status <- read_csv("./demo_rct/trial_data/tbla_TrialStatusMasterList.csv")

# Factor variables with options yes/no coded as 1/2
factors_yn <- function(x) (factor(x, levels = c(1,2), labels = c("Yes", "No")))
yn <- c("smoker", "sixmp", "stricturoplasty", "otherdisease", "familyhistoryibd" , "azathioprine", "previousinfliximab", "methotrexate", "othercorticosteroids", 
        "fiveasa", "topicaltreatments", "arthralgia", "iritis", "fissure", "otherfistula")

# Factor variables of symptoms categorized into 4 levels
factor_symptoms <- function(x) (factor(x, levels = c(0,1,2,3), labels = c("None", "Mild", "Moderate", "Severe")))
symptoms <- c("pain", "diarrhoea", "anorexia", "fever", "bleeding")


# Creating final dataset mutating those variables that need to be converted into factors
baseline <- baseline %>%
    # Add lebels to factorial variables and generate new variables from the existing ones
    mutate(
        # Factor using trial master lists
        treatmentno = factor(treatmentno, levels = c(1,2), labels = c("Treatment", "Placebo")),
        trialstatusid = factor(trialstatusid, levels = status$TrialStatusID, labels = status$TrialStatusText),
        # Manually generated factors - labels extracted from annonymised data dictionary
        gender = factor(gender, levels = c("F", "M"), labels = c("Female", "Male")),
        tpmt = factor(tpmt, levels = c(1,2), labels = c("Normal", "Heterozygous")),
        diagnosisage = factor(diagnosisage, levels = c("A1", "A2", "A3"), labels = c("<16", "17-40", ">40")),
        diseaselocation = factor(diseaselocation, levels = c("L1", "L2", "L3"), labels = c("Ileal", "Colonic", "Ileaocolonic")),
        diseasebehaviour = factor(diseasebehaviour, levels = c("B1", "B2", "B3"), labels = c("Non stricturing, Non penetrating", "Stricturing", "Penetrating")),
        # New variables that are easier to study
        age_diagnosis = case_when(diagnosisage == "<16" ~ "<=40", diagnosisage == "17-40" ~ "<=40", age > ">40" ~ ">40"),
        # 6-MP (Mercaptopurine) and Azathioprine are both Thiopurines
        thiopurines = ifelse(sixmp == 1 | azathioprine == 1, "Yes", "No"),
        # Surgery coded as yes/no variable. In the original dataset operationnumber = 1 coded for no previous surgery
        surgery = ifelse(operationnumber == 1, "No", "Yes"),
        # Previous treatment with infliximab or methotrexate
        infliximab_methotrexate = ifelse(previousinfliximab == 1 | methotrexate == 1, "Yes", "No"),
        #Converting months from diagnosis into years
        disease_duration = ifelse(studydaymonthsfromdiagnosis/-12 <= 1, "< 1", "> 1"),
        years_duration = studydaymonthsfromdiagnosis/-12
    ) %>%
    #Change to factors from the lists
    mutate_at(symptoms, factor_symptoms) %>%
    mutate_at(yn, factors_yn)



# Saving csv file
write.csv(baseline, "./demo_rct/results/baseline_factors.csv", row.names = FALSE)
print("baseline.csv saved in the results folder")
                  
