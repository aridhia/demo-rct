##################################################################################
# Generates an html table comparing baseline characteristics of treatment groups #
##################################################################################

# Packages
library(arsenal)

# Run the script that generates the dataset with information of interest
source("./demo_rct/scripts/baseline.r")

# Defining labels for the table
label <- c(gender = 'Sex', 
          smoker = 'Present smoker', 
          age = 'Age (Years)',
          disease_duration = 'Duration of Crohn\'s disease from diagnosis (Years)',
          age_diagnosis = 'Age at diagnosis (Years)',
          diseaselocation = 'Disease location',
          years_duration = ' Duration of Crohn\'s disease from diagnosis (Years)',
          sixmp = 'Mercaptopurine',
          azathioprine = 'Azathioprine',
          thiopurines = 'Either thiopurines',
          previousinfliximab = 'Infliximab',
          methotrexate = 'Methotrexate',
          otercorticosteroids = 'Other corticosteroids',
          surgery = 'Previous surgery')

# Print a characteristics table comparing treatment groups

tab <- summary( 
      tableby(
      formula = treatmentno ~ gender + smoker + age + disease_duration + years_duration + age_diagnosis + diseaselocation
                  + sixmp + azathioprine + thiopurines + previousinfliximab + methotrexate + othercorticosteroids + surgery, 
      data = baseline,
      control = tableby.control(test = FALSE)),
      labelTranslations = label
)

# Saving table into results folder as an html file
write2html(tab, "./demo_rct/results/table")
