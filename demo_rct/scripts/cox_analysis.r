#################
##COX ANALYSIS###
#################

#Packages
library(survival)
library(survminer)
library(readr)
library(forcats)
library(tidyr)
library(knitr)


cox_analysis <- function(surv_object){
      # Adjusted Cox Regression Model
      # This model is stratified by smoker status and centre number and adjusted for treatment number and previous treatments with Mercaptopurine(6-MP) or Azathioprine
      cox_results_adjusted <- coxph(surv_object ~ treatmentno + smoker + strata(a_centreno) + sixmp + azathioprine, data = outcomes)
      
      # Unadjusted Cox Regression Model - Analysis without the adjustment of previous treatments with Thiopurines, but still stratified for randomisation strata
      cox_results_unadjusted <- coxph(surv_object ~ treatmentno, data = outcomes)
      

      table_modifications <- function(cox_object){
            # Extract HR, CI and p values from the Cox model
            HR <- round(exp(coef(cox_object)), 2)
            CI <- round(exp(confint(cox_object)), 2)
            p <- round(coef(summary(cox_object))[,5], 3)

            # Name the columns of CI
            colnames(CI) <- c("Lower_CI", "Higher_CI")

            # Bind columns together as a dataset
            cox <- as.data.frame(cbind(HR, CI, p))

            # Changes to join CI in a single column between brackets and separated by a hyphen 
            cox$a <- "("; cox$b <- "-"; cox$c <- ")"
            cox <- cox[,c("HR", "a", "Lower_CI", "b", "Higher_CI", "c", "p")]
            cox = unite(cox, "Adjusted_95%_CI", "a":"c", sep = "")

            # Print the table with the results of the adjusted cox analysis
            return(kable(cox, col.names = c("HR", "95% CI", "p value")))
      }
      
      print(table_modifications(cox_results_adjusted))
      print(table_modifications(cox_results_unadjusted))

}


#Import data that will be used to do the analysis
#Outcomes dataset, elaborated witht outcome.R 
outcomes <- read_csv("./demor_rct/results/outcomes.csv")

#First, create a survival object that consist of the time and whether the endpoint was reached
primary_surv_object <- Surv(outcomes$primary.time, outcomes$primary.endpoint)
secondary_surv_object <- Surv(outcomes$secondary.time, outcomes$secondary.endpoint)


# Call cox_analysis function on primary and secondary surv_objects
cox_analysis(primary_surv_object)
cox_analysis(secondary_surv_object)
