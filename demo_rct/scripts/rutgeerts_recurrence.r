##########################
## Endoscopic recurrence #
##########################


# Rutgeerts score week 49 - visit number 6 
# Score cannot be more than 4
visit6 <- endoscopy %>% subset(visitno == 6 & rutgeerts <= 4)

# Chi-square test - Difference in rutgeerts and recurrence between treatments
CrossTable(visit6$treatmentno, visit6$rutgeerts, dnn = c("Treatment allocation", "Rutgeerts Score"), digits = 1, format = "SPSS", percent = TRUE, prop.chisq = FALSE)
CrossTable(visit6$treatmentno, visit6$endoscopic_recurrence, dnn = c("Treatment allocation", "Rutgeerts Recurrence"), chisq = TRUE)

# T-test - Difference in cdeis between treatments
t.test(visit6$cdeis ~ visit6$treatmentno)


# Rutgeerts score week 157 - visit number 12
visit12 <- endoscopy %>% subset(visitno == 12 & rutgeerts <= 4)

# Chi-square test - Difference in rutgeerts and recurrence between treatments
CrossTable(visit12$treatmentno, visit12$rutgeerts, dnn = c("Treatment allocation", "Rutgeerts Score"), digits = 1, format = "SPSS", percent = TRUE, prop.chisq = FALSE)
CrossTable(visit12$treatmentno, visit12$endoscopic_recurrence, dnn = c("Treatment allocation", "Rutgeerts Recurrence"), chisq = TRUE)

# T-test - Difference in cdeis between treatments
t.test(visit12$cdeis ~ visit12$treatmentno)
