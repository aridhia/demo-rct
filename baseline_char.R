#PACKAGES

library(readr)
library(dplyr)
library(Hmisc)


#FUNCTIONS
basic_edit <- function(dataset) {
  #Column names to lowercase
  colnames(dataset) <- tolower(colnames(dataset))
  #Drop columns with removed information due to annonimisation
  rem <- sapply(colnames(dataset), function(i) any(dataset[[i]] == "Removed"))  #Drop columns with removed information due to annonimisation
  dataset <- dataset[!rem]
  return(dataset)
}

col_class <- function(dataset) {
  dataset <- dataset %>% 
  #Change all columns that contain date/day in the column name to numeric
  mutate_if(grepl('date|day', colnames(dataset)), as.numeric) %>% 
  #Subject number as a character
  mutate(a_subjectno = as.character(a_subjectno))
  return(dataset)
}

#SUBJECT_CHAR

subject_char <- read_csv("./Data/tbla_Subjects.csv") %>%
  basic_edit() %>%
  col_class()

#DISEASE HISTORY
crohn_history <- read_csv("./Data/tbla_CrohnsHistory.csv") %>%
  basic_edit() %>%
  col_class()
  
#FACTOR CONVERTIONS
#Lists prepared to change variables into factors
                
#Master Lists from the clinical trial database
status <- read_csv("./Data/tbla_TrialStatusMasterList.csv")
treatment <- read_csv("./Data/tbla_TreatmentNames.csv")

#Factors with options yes/no as 1/2

factor_yn <- function(x) (factor(x, levels = c(1,2), labels = c("Yes", "No")))
yn <- c("smoker", "sixmp", "stricturoplasty", "otherdisease", "familyhistoryibd" , "azathioprine", "previousinfliximab", "methotrexate", "othercorticosteroids", 
        "fiveasa", "topicaltreatments", "arthralgia", "iritis", "fissure", "otherfistula")

#Symptoms categrized into 4 levels
factor_symptoms <- function(x) (factor(x, levels = c(0,1,2,3), labels = c("None", "Mild", "Moderate", "Severe")))
symptoms <- c("pain", "diarrhoea", "anorexia", "fever", "bleeding")

#Variables to drop
variables_drop <- c("studydayfromdaterandomised", "height", "studydaydob", "studydaymonthsfromdiagnosis", "studydaymonthsfromfirstsymptoms", 
                    "studydaymonthsfromoperation1", "operation1bowelresected",
                    "studydaymonthsfromoperation2", "operation2bowelresected", "studydaymonthsfromoperation3", "operation3bowelresected", 
                    "timenomedicationmm", "timenomedicationyy", "timefiveasamm", "timefiveasayy", "timesteroidsmm", "timesteroidsyy")

#Creating final dataset
                
baseline <- merge(subject_char, crohn_history, all = TRUE)  %>%
                
  #Add labels to factorial variables and generate variables from existing ones
  mutate(
         age = studydaydob / -365.25, #Age as years
         a_centreno = as.character(a_centreno),  #Centre number as a character
         #Factors using clinical trial's Master Lists 
         treatmentno = factor(treatmentno, levels = treatment$TreatmentNo, labels = treatment$TreatmentName),
         trialstatusid = factor(trialstatusid, levels = status$TrialStatusID, labels = status$TrialStatusText),
         #Manually generated factors
         gender = factor(gender, levels = c("F", "M"), labels = c("Female", "Male")),
         tpmt = factor(tpmt, levels = c(1,2), labels = c("Normal", "Heterozygous")),
         diagnosisage = factor(diagnosisage, levels = c("A1", "A2", "A3"), labels = c("<16", "17-40", ">40")),
         diseaselocation = factor(diseaselocation, levels = c("L1", "L2", "L3"), labels = c("Ileal", "Colonic", "Ileaocolonic")),
         diseasebehaviour = factor(diseasebehaviour, levels = c("B1", "B2", "B3"), labels = c("Non stricturing, Non penetrating", "Stricturing", "Penetrating")),
         #New variables easier to assess
         age_diagnosis = case_when(diagnosisage == "<16" ~ "<=40", diagnosisage == "17-40" ~ "<=40", age > ">40" ~ ">40"),
         thiopurines = ifelse(sixmp == "Yes" | azathioprine == "Yes", "Yes", "No"),
         surgery = ifelse(operationnumber == 1, "No", "Yes"),
         years_from_diagnosis = studydaymonthsfromdiagnosis / -12
         )%>%
  #Change to factors from the lists
  mutate_at(symptoms, factor_symptoms)%>%
  mutate_at(yn, factor_yn) %>%
  #Drop variables
  select(-c(variables_drop))


#Write csv
write.csv(baseline, "./baseline.csv", row.names = FALSE)

       

         
