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

###############
##KEPLAN MEIER#
###############

#Packages
library(survival)
library(survminer)
library(readr)


#Import data that will be used to do the analysis
#Outcomes dataset, elaborated witht outcome.R 
outcomes <- read_csv("./results/outcomes.csv") 

outcomes$treatmentno <- outcomes$treatmentno %>% 
    # Treatmentno has to be converted into a factor variable
    as.factor() %>% 
    # By default the reference vale of treatmentno is Active (alphabetically determined). This has to be reversed
    forcats::fct_rev()


# Fit for the Kaplan-Meier Curve
primary_fit <- survfit(Surv(outcomes$primary.time, outcomes$primary.endpoint) ~ treatmentno, data = outcomes)
secondary_fit <- survfit(Surv(outcomes$secondary.time, outcomes$secondary.endpoint) ~ treatmentno, data = outcomes)


#Graph the fit

keplan_meier <- function(fit) {
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

    #Show plot
    show(plot)
}

# Graph for primary endpoint
keplan_meier(primary_fit)

# Graph for secondary endpoint
keplan_meier(secondary_fit)

