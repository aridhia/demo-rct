###########################
## QUALITY OF LIFE - IBDQ #
###########################

library(dplyr)

source("./demo_rct/scripts/function.r")

ibdq <- read.csv("./demo_rct/trial_data/tbla_Questionnaire.csv") %>%
      basic_edit() %>%
      col_class() %>%
      select(c(a_subjectno, visitno, studydayissuedate, ibdq1:ibdq32)) %>% 
      mutate_at(vars(matches('ibdq')), as.numeric)


ibdq$ibdqmean <- rowMeans(ibdq[,c(4:35)])      


baseline <- read.csv("./demo_rct/results/baseline_factors.csv") %>%
      # Select only the variables important for the statistical analysis
      select(c(a_subjectno, treatmentno))


ibdq <- merge(baseline, ibdq, by = 'a_subjectno', all = FALSE)



# Splitting for treatment
anova <- aov(ibdqmean ~ visitno*treatmentno+Error(a_subjectno/(visitno*treatmentno)), data = ibdq)
summary(anova)  # Not significant effect or interaction
