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
drop_col_char <- names(subject_char) %in% c("prerandom_id", "initials", "hospitalno")
subject_char <- subject_char[!drop_col_char]

drop_col_diag <- names(diagnosis) %in% c("crohnshistoryid", "operation1type", "operation2type", "operation3type",
                                        "familyhistoryibd", "infliximabreasonforstopping", "infliximabdates", "azathioprinedates",
                                        "azathioprinereasonsforstopping", "sixmpdates", "sixmpreasonforstopping")

#Due to annonimization to know age of the subjects the variable studydayob is the day of birth 
#from the day of the study
subject_char$age = subject_char$studydaydob/-365

#Export to csv
write_csv(subject_char, "~/files/TOPPIC/own_df/subject_char.csv", row.names = FALSE)


dataset %>%
  group_by(treatmentno) %>%
  summarise(mean_age = mean(age,
    na.rm = TRUE
  ))
