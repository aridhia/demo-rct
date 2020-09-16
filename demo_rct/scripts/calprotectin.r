######################################################
## Analysis of Calprotectin as a non-invasive marker #
######################################################

# Scripts with predefined functions
source("./demo_rct/scripts/function.r")

# Run script creates the dataset used
source("./demo_rct/scripts/secondary_endpoints.r")

# Import dataset with calprotectin information
calprotectin <- read_csv("./demo_rct/trial_data/tbla_BloodsTaken.csv") %>%
      basic_edit() %>%
      col_class() %>%
      # Select interest columns
      select(c(a_subjectno, visitno, faecalcalprotectin, calprotectinresult, calprotectinsymbol)) %>%
      # Converting to numeric
      mutate(faecalcalprotectin = as.numeric(faecalcalprotectin),
             calprotectinresult = as.numeric(calprotectinresult)) %>%
      # Subset values of calprotectin per patient, the ones from visits 6 and 12
      subset((faecalcalprotectin == 1 & visitno == 6) | (faecalcalprotectin == 1 & visitno == 12)) 

# Create dataset with endoscopy and calprotectin information
predictor <- merge(endoscopy, calprotectin, by = c('a_subjectno', 'visitno'), all = FALSE) %>%
      drop_na(calprotectinresult) %>%
      # Change remission variable as a Yes/No factor
      mutate(endoscopic_remission = as.factor(ifelse(rutgeerts == 0, "Yes", "No")))


# Recurrence: Rutgeerts score >= 2
# ROC curve
roc_recurrence <- roc(endoscopic_recurrence ~ calprotectinresult, data = predictor, ci = TRUE)
# Table showing sensitivity, specificity, PPV and NPV for 2 thresholds
threshold_recurrence <- as.data.frame(ci.coords(roc_recurrence, x = c(50,100), transpose = FALSE, ret = c("threshold","sensitivity", "specificity", "ppv", "npv")))


# Remission: Rutgeerts score = 0
# ROC curve
roc_remission <- roc(endoscopic_remission ~ calprotectinresult, data = predictor, ci = TRUE, plot = TRUE)
# Table showing sensitivity, specificity, PPV and NPV for 2 thresholds
threshold_remission <- as.data.frame(ci.coords(roc_remission, x = c(50,100), transpose = FALSE, ret = c("threshold","sensitivity", "specificity", "ppv", "npv")))



