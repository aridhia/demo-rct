
# Packages
library(readr)

source("./demo_rct/scripts/baseline.r")


# tbla_DosageDesicions --> Dose reduction

dosereduction <- read_csv("./demo_rct/trial_data/tbla_DosageDecisions.csv") %>%
      basic_edit() %>%
      col_class()

# tbla_DrugAccountability --> Treatment period

drugaccount <- read_csv("./demo_rct/trial_data/tbla_DrugAccountability.csv") %>%
      basic_edit() %>%
      col_class()

# tbla_VisitSchedule