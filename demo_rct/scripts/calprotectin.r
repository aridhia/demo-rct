##########################
## Calprotectin #
##########################

source("./demo_rct/scripts/secondary_endpoints.r")


calprotectin <- read_csv("./demo_rct/trial_data/tbla_BloodsTaken.csv") %>%
      basic_edit() %>%
      col_class() %>%
      select(c(a_subjectno, visitno, faecalcalprotectin, calprotectinresult, calprotectinsymbol)) %>%
      mutate(faecalcalprotectin = as.numeric(faecalcalprotectin),
             calprotectinresult = as.numeric(calprotectinresult)) %>%
      subset((faecalcalprotectin == 1 & visitno == 6) | (faecalcalprotectin == 1 & visitno == 12)) 

predictor <- merge(endoscopy, calprotectin, by = c('a_subjectno', 'visitno'), all = FALSE) %>%
      drop_na(calprotectinresult) %>%
      mutate(endoscopic_remission = as.factor(ifelse(rutgeerts == 0, "Yes", "No")))


# Recurrence: Rutgeerts score >= 2
roc_recurrence <- roc(endoscopic_recurrence ~ calprotectinresult, data = predictor, ci = TRUE)
threshold_recurrence <- as.data.frame(ci.coords(roc_recurrence, x = c(50,100), transpose = FALSE, ret = c("threshold","sensitivity", "specificity", "ppv", "npv")))


# Remission: Rutgeerts score = 0
roc_remission <- roc(endoscopic_remission ~ calprotectinresult, data = predictor, ci = TRUE, plot = TRUE)

threshold_remission <- as.data.frame(ci.coords(roc_remission, x = c(50,100), transpose = FALSE, ret = c("threshold","sensitivity", "specificity", "ppv", "npv")))



