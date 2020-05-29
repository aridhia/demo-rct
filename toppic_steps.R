#Packages
library(readr)
library(dplyr)
library(gmodels)
library(ggplot2)

#Import data set for subjects characteristics
subject_char <- read_csv("~/files/TOPPIC/tbla_Subjects.csv")
diagnosis <- read_csv("~/files/TOPPIC/tbla_CrohnsHistory.csv")

#Colnames to lowercase
colnames(subject_char) = tolower(colnames(subject_char))
colnames(diagnosis) = tolower(colnames(diagnosis))

#Remove columns empty due to annonimization
#Drop columsn with removed information due to annonimisation
remove_annonn <- function(dataset) {
   dataset[dataset == 'Removed'] <- NA
   dataset <- dataset %>% select_if(~ !any(is.na(.)))
   return(dataset)
}

subject_char <- remove_annonn(subject_char)
diagnosis <- remove_annonn(diagnosis)


#Due to annonimization to know age of the subjects the variable studydayob is the day of birth 
#from the day of the study
subject_char$age = subject_char$studydaydob/-365

#Join tables
baseline_char <- merge (x = subject_char, y = diagnosis, by="a_subjectno", all=TRUE)



