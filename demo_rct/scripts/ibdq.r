############################
## QUALITY OF LIFE - IBDQ ##
############################

# Packages
library(dplyr)

# Run script containing pre-defined functions
source("./demo_rct/scripts/function.r")

# Import dataset with IBDQ information
ibdq <- read.csv("./demo_rct/trial_data/tbla_Questionnaire.csv") %>%
      basic_edit() %>%
      col_class() %>%
      # Selecting columns of interest
      select(c(a_subjectno, visitno, studydayissuedate, ibdq1:ibdq32)) %>% 
      # Column as numeric
      mutate_at(vars(matches('ibdq')), as.numeric)

# Calculating the mean of IBDQ per patient
ibdq$ibdqmean <- rowMeans(ibdq[,c(4:35)])      

# Import baseline dataset created with baseline.r
baseline <- read.csv("./demo_rct/results/baseline_factors.csv") %>%
      # Select only the variables important for the statistical analysis
      select(c(a_subjectno, treatmentno))

# Merge both datasets
ibdq <- merge(baseline, ibdq, by = 'a_subjectno', all = FALSE)



# Splitting for treatment
anova <- aov(ibdqmean ~ visitno*treatmentno+Error(a_subjectno/(visitno*treatmentno)), data = ibdq)
summary(anova)  # Not significant effect or interaction
