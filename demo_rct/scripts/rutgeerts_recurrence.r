##########################
## Endoscopic recurrence #
##########################

library(dplyr)
library(tidyverse)
library(gmodels)

source("./demo_rct/scripts/function.r")

endoscopy <- read.csv("./demo_rct/trial_data/tbla_EndoscopyFindings.csv") %>%
      basic_edit() %>%
      col_class() %>%
      subset(visitno == 6 | visitno == 12)

endoscopy[endoscopy$rutgeerts == 'i2', "rutgeerts"] <- 2
endoscopy[endoscopy$rutgeerts == 'I4', "rutgeerts"] <- 4

endoscopy <- endoscopy %>%
      mutate(rutgeerts = as.numeric(as.character(rutgeerts)),
             cdeis = as.numeric(cdeis)) %>%
      drop_na(rutgeerts)

baseline <- read.csv("./demo_rct/results/baseline_factors.csv") %>%
      # Select only the variables important for the statistical analysis
      select(c(a_subjectno, treatmentno))


endoscopy <- merge(baseline, endoscopy, by = 'a_subjectno', all = FALSE) %>%
      # Endoscopic recurrence --> rutgeerts >= 2
      mutate(endoscopic_recurrence = as.factor(ifelse(rutgeerts >= 2, "Yes", "No")),
             treatmentno = as.factor(treatmentno))

# Rutgeerts score week 49 - visit number 6 
# Score cannot be more than 4
visit6 <- endoscopy %>% subset(visitno == 6 & rutgeerts <= 4)

CrossTable(visit6$treatmentno, visit6$rutgeerts, dnn = c("Treatment allocation", "Rutgeerts Score"), digits = 1, format = "SPSS", percent = TRUE, prop.chisq = FALSE)
CrossTable(visit6$treatmentno, visit6$endoscopic_recurrence, dnn = c("Treatment allocation", "Rutgeerts Recurrence"), chisq = TRUE)


# Rutgeerts score week 157 - visit number 12
visit12 <- endoscopy %>% subset(visitno == 12 & rutgeerts <= 4)

CrossTable(visit12$treatmentno, visit12$rutgeerts, dnn = c("Treatment allocation", "Rutgeerts Score"), digits = 1, format = "SPSS", percent = TRUE, prop.chisq = FALSE)
CrossTable(visit12$treatmentno, visit12$endoscopic_recurrence, dnn = c("Treatment allocation", "Rutgeerts Recurrence"), chisq = TRUE)

t.test(visit6$cdeis ~ visit6$treatmentno)
t.test(visit12$cdeis ~ visit12$treatmentno)
