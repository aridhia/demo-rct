#####################################
# Subgroup analyses and forest plot #
#####################################


# Packages
library(survival)
library(survminer)
library(readr)
library(Publish)
library(forestplot)


subgroup_analysis <- function(fit_cox){
   subgroup <- Publish::subgroupAnalysis(fit_cox, outcomes, treatment = 'treatmentno', subgroups = c("smoker", "thiopurines", "age_diagnosis", "surgery", "infliximab_methotrexate", "disease_duration"))
   overall <- Publish::subgroupAnalysis(fit_cox, outcomes, treatment = 'treatmentno', subgroups = c('treatmentno'))

   # Add empty line between subgroups
   subgroup <- do.call(rbind, by(subgroup, subgroup$subgroups, rbind, NA, fill = TRUE))
   # Add empty first line 
   subgroup <- rbind(subgroup[3], subgroup)

   # To make the table for the forest graph it is necessary to move elements around
   for (i in 1:nrow(subgroup)){
      if(is.na(subgroup$level[i])){
            subgroup$level[i] <- subgroup$subgroups[i+1]
      }
      if(is.na(subgroup$pinteraction[i])){
            subgroup$pinteraction[i] <- subgroup$pinteraction[i+1]
      } else{
            subgroup$pinteraction[i] <- NA
      }
   }

   # Delete subgroup column and last empty row
   subgroup <- subgroup[-nrow(subgroup), -1]

   # Change names of subgroups

   for (i in 1:nrow(subgroup)){
      if(subgroup$level[i] == "age_diagnosis"){
         subgroup$level[i] <- "Age at diagnosis"
      } else if (subgroup$level[i] == "infliximab_methotrexate"){
         subgroup$level[i] <- "Previous treatment with infliximab or methotrexate"
      } else if (subgroup$level[i] == "smoker") {
         subgroup$level[i] <- "Current smoker"
      } else if (subgroup$level[i] == "surgery") {
         subgroup$level[i] <- 'Previous surgery'
      } else if (subgroup$level[i] == "thiopurines") {
         subgroup$level[i] <- "Previous treatment with thiopurines"
      } else if (subgroup$level[i] == "disease_duration") {
         subgroup$level[i] <- "Duration of disease"
      }
   }


   tabletext <- cbind(c("\n","\n","\n", subgroup$level, "Overall"),
                      c("Mercaptopurine","Number (%)", "outcomes",
                        ifelse(!is.na(subgroup$event_Treatment), 
                               paste(subgroup$event_Treatment, " (", round(subgroup$event_Treatment*100/subgroup$sample_Treatment, 2), "%)"),
                               NA),
                        paste(overall$event_Treatment[2], " (", round(overall$event_Treatment[2]*100/overall$sample_Treatment[2], 2), "%)")),
                      c("Placebo","Number (%)", "outcomes",
                        ifelse(!is.na(subgroup$event_Placebo),
                               paste(subgroup$event_Placebo, " (", round(subgroup$event_Placebo*100/subgroup$sample_Placebo, 2), "%)"),
                               NA),
                        paste(overall$event_Placebo[1], " (", round(overall$event_Placebo[1]*100/overall$sample_Placebo[1], 2), "%)")),
                     c("\n", "\n","Hazard Ratio (95% CI)",  
                        ifelse(!is.na(subgroup$HazardRatio),
                              paste(round(subgroup$HazardRatio,2),"(",round(subgroup$Lower,2),"-",round(subgroup$Upper,2),")"),
                              NA),
                       paste(round(overall$HazardRatio[2],2),"(",round(overall$Lower[2],2),"-",round(overall$Upper[2],2),")")),
                     c("\n", "\n","P interaction", round(subgroup$pinteraction, 2), "\n"))


   forest <- forestplot(
      labeltext=tabletext, 
      graph.pos=4, 
      mean=c(NA,NA, NA, subgroup$HazardRatio, overall$HazardRatio[2]), 
      lower=c(NA,NA, NA, subgroup$Lower, overall$Lower[2]), 
      upper=c(NA, NA, NA,subgroup$Upper, overall$Upper[2]),
      align = 'l',
      zero=1, cex=0.9, lineheight = unit(8,'mm'), boxsize=0.2, colgap=unit(3,"mm"), 
      lwd.ci=1,
      graphwidth = unit(10, 'cm'),
      txt_gp = fpTxtGp(label = gpar(cex=0.9),
                       ticks = gpar(cex = 0.9),
                       summary = gpar(cex = 0.9)),
      col = fpColors(box = 'black', lines = 'black', zero = 'gray50'),
      xlog = TRUE,
      xticks = c(0.01,0.1,1,10),
      hrzl_lines = list("4" = gpar(col = 'black')),
      is.summary = c(rep(TRUE, 3), rep(FALSE, 18))
      )
   
   return(forest)
}

#Import data that will be used to do the analysis
#Outcomes dataset, elaborated witht outcome.R 
outcomes <- read_csv("./demo_rct/results/outcomes.csv") 
outcomes <- as.data.frame(outcomes)

primary_fit_cox <- coxph(Surv(primary.time, primary.endpoint) ~ treatmentno, data = outcomes)
secondary_fit_cox <- coxph(Surv(secondary.time, secondary.endpoint) ~ treatmentno, data = outcomes)

subgroup_analysis(primary_fit_cox)
subgroup_analysis(secondary_fit_cox)

