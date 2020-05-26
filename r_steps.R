#Install packages
install.packages("gmodels")

#Import libraries
library(sqldf)
library(readr)
library(plyr)
library(gmodels)
library(ggplot2)

#Import data
ist <- read_csv("~/files/ist_corrected.csv", trim_ws = FALSE,
  col_types = cols(DRSUNKD = col_integer())) #DRSUNKD variable gives a parse error if not parsed manually

#Edit colunm names, to work with SQL (avoid capital and dots)
dbSafeNames = function(names){
  names=gsub('[^a-z0-9]+','_',tolower(names))
  names=make.names(names, unique = TRUE, allow_=TRUE)
  names=gsub('.','_',names,fixed=TRUE)
  names
  }
colnames(ist) = dbSafeNames(colnames(ist))

#In the pilot trial the medium heparin dose (M) is coded as H
ist$rxhep <- revalue(ist$rxhep, c("H"="M"))
#Frequency table to assess factorial design: Randomised in Aspirine Vs Randomised in Heparine
fact_design <- table(ist$rxasp,ist$rxhep, dnn = c("Aspirin", "Heparin")) 

##ANOTHER WAY to do the same thing
fact_design <- CrossTable(ist$rxasp, ist$rxhep, expected = FALSE, prop.r = TRUE, prop.c =TRUE, prop.chisq = FALSE, 
    dnn = c("Aspirin", "Heparine"))

#Subset dataset for characteristics before randomisation
  #Variables used in the paper for baseline characteristics
vars_char <- c("rdelay", "rconsc", "sex", "age", "rsleep", "ratrial", "rct", "rvisinf", "rhep_", "rasp_", "rsbp", "rdef__3", "stype")
ist_base_char  <- ist[vars_char]
  #Easier but larger dataset (SAME THING)
vars_char <- ist[1:27]

#Export to .csv to analyse with Workspace tools from .csv file
write.csv(ist_base_char, "~/files/baseline_characteristics.csv", row.names = FALSE)
#From Workspace Analyse:
  #Age box plot
base_plot <- ggplot(dataset, aes(y = age))
base_plot + geom_boxplot() + theme_classic()
  #rdelay (delay between stroke and randomisation) box plot
base_plot <- ggplot(dataset, aes(y = rdelay))
base_plot + geom_boxplot() + theme_classic()
  #rsbp (systolic blood preassure at randomisation) density plot
base_plot <- ggplot(dataset, aes(x = rsbp))
base_plot + geom_density(alpha = 0.5) + theme_classic()
