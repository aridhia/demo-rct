##########################
## Calprotectin #
##########################

source("./demo_rct/scripts/secondary_endpoints.r")

# Recurrence: Rutgeerts score >= 2
roc_recurrence <- roc(endoscopic_recurrence ~ calprotectinresult, data = endoscopy, ci = TRUE, plot = TRUE)
threshold_recurrence <- as.data.frame(ci.coords(roc_recurrence, x = c(50,100), transpose = FALSE, ret = c("threshold","sensitivity", "specificity", "ppv", "npv")))


# Remission: Rutgeerts score = 0
roc_remission <- roc(endoscopic_remission ~ calprotectinresult, data = endoscopy, ci = TRUE, plot = TRUE)

threshold_remission <- as.data.frame(ci.coords(roc_remission, x = c(50,100), transpose = FALSE, ret = c("threshold","sensitivity", "specificity", "ppv", "npv")))



