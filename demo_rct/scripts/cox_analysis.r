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



#Import data that will be used to do the analysis
#Outcomes dataset, elaborated witht outcome.R 
outcomes <- read_csv("./demo_rct/results/outcomes.csv")

outcomes$treatmentno <- outcomes$treatmentno %>% 
    #Treatmentno has to be converted into a factor variable
    as.factor() %>% 
    #By default the reference vale of treatmentno is Active (alphabetically determined). This has to be reversed
    forcats::fct_rev()


#First, create a survival object that consist of the time and whether the endpoint was reached
surv_object <- Surv(outcomes$time, outcomes$primary.endpoint)

#Adjusted Cox Regression Model
##This model is stratified by smoker status and centre number and adjusted for treatment number and previous treatments with Mercaptopurine(6-MP) or Azathioprine
cox_results_adjusted <- coxph(surv_object ~ treatmentno + strata(factor(smoker)) + strata(a_centreno) + factor(sixmp) + factor(azathioprine), data = outcomes)

#Extract HR, CI and p values from the Cox model
HR_adjusted <- round(exp(coef(cox_results_adjusted)), 2)
CI_adjusted <- round(exp(confint(cox_results_adjusted)), 2)
p_adjusted <- round(coef(summary(cox_results_adjusted))[,5], 3)

#Name the columns of CI
colnames(CI_adjusted) <- c("Lower_Adjusted_CI", "Higher_Adjusted_CI")

#Bind columns together as a dataset
cox_adjusted <- as.data.frame(cbind(HR_adjusted, CI_adjusted, p_adjusted))

#Changes to join CI in a single column between brackets and separated by a hyphen 
cox_adjusted$a <- "("; cox_adjusted$b <- "-"; cox_adjusted$c <- ")"
cox_adjusted <- cox_adjusted[,c("HR_adjusted", "a", "Lower_Adjusted_CI", "b", "Higher_Adjusted_CI", "c", "p_adjusted")]
cox_adjusted = unite(cox_adjusted, "Adjusted_95%_CI", "a":"c", sep = "")

#Changes in the row names to make them more understandable 
row.names(cox_adjusted) <- c("Mercaptopurine", "Previous treatments with Mercaptopurine", "Pervious treatments with Azathioprine")

#Print the table with the results of the adjusted cox analysis
kable(cox_adjusted, col.names = c("Adjusted HR", "95% CI", "p value"))



#Unadjusted Cox Regression Model - Analysis without the adjustment of previous treatments with Thiopurines, but still stratified for randomisation strata
cox_results_unadjusted <- coxph(surv_object ~ treatmentno + strata(factor(smoker)) + strata(a_centreno), data = outcomes)

#Extract HR, CI and p values from the Cox model
HR_unadjusted <- round(exp(coef(cox_results_unadjusted)), 2)
CI_unadjusted <- round(exp(confint(cox_results_unadjusted)), 2)
p_unadjusted <- round(coef(summary(cox_results_unadjusted))[,5], 3)

#Name the columns of CI
colnames(CI_unadjusted) <- c("Lower_Unadjusted_CI", "Higher_Unadjusted_CI")

#Bind columns together as a dataset
cox_unadjusted <- as.data.frame(cbind(HR_unadjusted, CI_unadjusted, p_unadjusted))

#Changes to join CI in a single column between brackets and separated by a hyphen 
cox_unadjusted$a <- "("; cox_unadjusted$b <- "-"; cox_unadjusted$c <- ")"
cox_unadjusted <- cox_unadjusted[,c("HR_unadjusted", "a", "Lower_Unadjusted_CI", "b", "Higher_Unadjusted_CI", "c", "p_unadjusted")]
cox_unadjusted = unite(cox_unadjusted, "Unadjusted_95%_CI", "a":"c", sep = "")

#Changes in the row names to make them more understandable 
row.names(cox_unadjusted) <- c("Mercaptopurine")

#Print the table with the results of the adjusted cox analysis
print(kable(cox_unadjusted, col.names = c("Unadjusted HR", "95% CI", "p value")))
