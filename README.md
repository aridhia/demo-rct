# Randomised Controlled Trials Demo
A demonstration of the reproduccion of the statistical analysis plan of the TOPPIC study: "Mercaptopurine Vs Placebo to prevent recurrence of Crohn's Disease after surgical resection: A multicentre, double-blind, randomised controlled trial" in the Aridhia Workspace.

## Randomized Controlled Trials
A clinical trial is a planned experiment involving humans, their aim is to assess the safety and efficacy of new approaches before applying them in healthcare. 
A **Randomized Controlled Trial (RCT)** is the gold-standard of clinical research. 
* When **randomizing**, each subject is randomly allocated to a group of the trial, this reduces the selection and allocation bias. Randomization ensures comparability of the control and treatment groups in all characteristics, so differences in outcome can be attributed to differences in treatment and not to different characteristics of the two groups.  
* In **controlled trials**, there is one control group that is the group to whom those receiving the treatment are compared to. The control group will be given either the usual care (best current treatment) or a placebo (treatment with no active ingredient). 
* Most of the times, RCT are **double-blind** studies; meaning that both, the patients and the investigator, are unaware of the group allocations. This method removes detection and performance bias. Contrarily, in an **open-label trial** group allocations are known by the patients and investigator.

## TOPPIC Study
TOPPIC study is a randomised, placebo-controlled, double-blind trial in which 29 UK hopitals participated. 
* Participants in the trial were randomly assigned in a 1:1 ratio to recieve mercaptopurine or placebo. Smoking status and recruiting site were use stratify the patients before randomisation.
* Patients, their carers, and physicians were masked to the treatment allocation. 
* The trial followed the patient for up to 3 years.

<p align="center">
  <img width="460" height="300" src="https://ars.els-cdn.com/content/image/1-s2.0-S2468125316300784-gr1.gif">
</p>

### Statistical Analysis Plan (SAP)
The SAP contains all the statistical methods in such detail that should allow the reproducibility of the analyisis. The SAP must be developed before the RCT trial, thus ensuring that the analysis plan was decided without prior knowledge the final results and avoiding cherry-picking.
A clinical trial is designed to test a particular hypothesis.
* The **Null Hypothesis (H<sub>0</sub>)** states that there is NO relationships between groups
* The **Alternative Hypothesis (H<sub>1</sub>)** is the statement of what the used statistical test is set up to establish.
The data from the trial has to provide evidence against H1 to suggest that H1 is true. 

The **Endpoints** are the measure that will be analysed and used to decide whether the H<sub>0</sub> should be rejected or not. The nature of the primary endpoint will determinate the adequate statistical analysis test.

The **primary endpoint** of the TOPPIC trial was the clinical recurrence of Crohn's disease. As the enpoint is binary (occurence of the outcome or not), the statistical analysis test used was **Cox Proportional Hazards Model**, adjusted to treatment allocation and previous treatments with mercaptopurine and azathioprine, and stratified by smoking status and recruitment site. 
Analyses were by intention to treat, meaning all the subjects that were randomised where included in the analysis. No matter the number of doses they recieved.

### Survival Analysis
In Survival Analysis, two or more groups are compared with respect to the time to a specific event (clinical recurrence). In some cases, the event may not occur, then, this observation would be “censored” and survival time would be the time to this censored event. 

Survival analysis use the following methods:
<details><summary> <b> 1. Keplan-Meier plots </b> </summary>

The Kaplan-Meier plot and it is used to visualize the probability of survival in each of the time intervals.
<p align="center">
  <img width="460" height="300" src="https://s3.amazonaws.com/cdn.graphpad.com/faq/1747/images/1747d.gif">
</p>

</details>

<details><summary> <b>2. Log-Rank Test</b> </summary>

The log-rank test compares the Kaplan-Meier survival curves of both groups. Its H<sub>0</sub> is that survival curves of two populations do not differ.

It is not suitable for continuous predictors. 

</details>

<details><summary> <b>3. Cox Proportional Hazards Regression</b> </summary>

Describes the effect of continuous or categorical predictors on survival. Whereas the log-rank test compares two Kaplan-Meier survival curves (i.e. splitting the population into treatment groups), the Cox proportional hazards models considers other covariates when comparing survival of patients groups. 

The Hazard Ratio (HR):

<p align="center">
  <img src="https://github.com/aridhia/demo-rct/blob/master/Capture.PNG">
</p>

</details>

## Reproduction of the analysis plan

This reproduction of the TOPPIC study statistical analysis plan is intended to run it in an Aridhia Workspace. 

To perform the analysis from the Git, clone the repo in the desired directory
 ```sh
 git clone https://github.com/aridhia/demo-rct
 cd ./demo-rct
 ```
### Data

All the data from the study is publicaly available in https://datashare.is.ed.ac.uk/handle/10283/2196.
The documents available are:
* Clinical Trial Protocol
* Anonymised Data Dictionary
* Clinical Trial Data in 31 CSV files
* Annotated Case Report forms

To start with, download the csv files and extract all of them in the folder called trial_data.

Working with git:

```sh
#Change the directory to trial_files
cd trial_files/

#Download the zip file containing all the csv
curl " "https://datashare.is.ed.ac.uk/bitstream/handle/10283/2196/Data.zip?sequence=36&isAllowed=y" > trial_data.zip

#Un zip the file
unzip trial_data.zip

#Return to the demo_rct directory
cd ../..
```

### Cleaning the data
In the Anonymised data dictionary there is all the information about the what information is contained in the variables and the codification of each one. 

When running the script **baseline_char.R** in the folder "scripts", it generates a CSV file containing all the baseline characteristics of the subjects in the trial. In this file there is no information about the outcome.
The resulting file will be allocated in the results folder under the name **baseline_characteristics.csv**.

The scripts can be run in Rstudio or Rconsole:
```r
#From the directory demo-rct
setwd("./demo-rct")
#Run the baseline_char.R script
source("./demo_rct/scripts/baseline_char.R")
```

### App
A Shiny App was developed to easily compare baseline characteristics between two groups of subjects. It uses the baseline_characteristics.csv file.
The app can be found in the folder baseline_app.
To run the Shiny App from the console:
```r
runApp("./demo_rct/baseline_app/app.r")
```

### Adding Outcomes
Running the script **outcome.R** allocated in the folder "scripts" generates a CSV called **outcome.csv** that will be allocated in the "Results" folder.
This file contains the most important baseline characteristics from the previous file, as well as information about whether the outcome happened in the subject and the time object for the survival analysis. The time object is:
* The time of the outcome for those with clinical recurrence
* The time of the last visit for those without clinical recurrence
* The time of status change for those that dropped out of the trial

To run the script:
```r
source("./demo_rct/scripts/outcome.R")
```

### Statistical Analysis
First, the **Keplan Meier plot**:
```r
source("./demo_rct/scripts/keplan_meier.r")
```
This script will print the plot and save a copy as an image in the results folder. 

Then, the **Log-Rank Test** can be performed running the script log_rank_test.r in the scripts folder.
```r
source("./demo_rct/scripts/log_rank_test.r")
```
This script will print the Log-Rank test results. 


Finally, the **Cox Analysis** can be run:
```r
source("./demo_rct/scripts/cox_analysis.r")
```
The cox_analysis.R script will print in the console the results for the adjusted and unadjusted analysis.
