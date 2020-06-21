###############
##KEPLAN MEIER#
###############

#Packages
library(survival)
library(survminer)
library(readr)


#Import data that will be used to do the analysis
#Outcomes dataset, elaborated witht outcome.R 
outcomes <- read_csv("./demo_rct/results/outcomes.csv")

#First, create a survival object that consist of the time and whether the endpoint was reached
surv_object <- Surv(outcomes$time, outcomes$primary.endpoint)

#fit the Kaplan-Meier Curve. In this case only use treatmentno
fit <- survfit(surv_object ~ treatmentno, data = outcomes)

png(filename="./demo_rct/results/keplan_meier_plot.png")

#Graph the fit
plot <- ggsurvplot(fit, data=outcomes, pval = TRUE,
    risk.table = TRUE,
    xscale = "d_y",
    break.time.by = 365.25,
    xlab = "Time since randomisation (years)",
    ylab = "Without clinical recurrence(%)",
    legend = "bottom",
    legend.labs = c("Mercaptopurine", "Placebo"),
    censor = FALSE,
    tables.y.text = FALSE)
dev.off()
show(plot)
