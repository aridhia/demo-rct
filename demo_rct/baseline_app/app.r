
#PACKAGES
library(shiny)
library(arsenal)
library(readr)

#Importing data
#This data has been generated with the script baseline.R
baseline <- read_csv("./baseline_factors.csv", 
    #Change column types of subject numbers and centre number to characters
    col_types = cols(a_subjectno = col_character(), a_centreno = col_character()))

#List of labels for the different variables on the dataset. This way it is easier for the user to know identify a variable
labels = list("Age (Years)" = "age", "Subject Number" = "a_subjectno", "Centre Number" = "a_centreno", "Treatment" = "treatmentno", "Gender"= "gender", "TPMT" = "tpmt", "Smoker" = "smoker", "Trial Status" = "trialstatusid", "Last trial status change (days)" = "trialstatuschangedate", "Age at diagnosis"= "diagnosisage", "Disease location" = "diseaselocation", "Disease Behaviour" = "diseasebehaviour", "Number of operations" = "operationnumber", "Stricturoplasty" = "stricturoplasty", "Other diseases" = "otherdisease", "Pain" = "pain", "Diarrhoea" = "diarrhoea", "Anorexia" = "anorexia", "Fever" =  "fever", "Bleeding" =  "bleeding", "Azathioprine" ="azathioprine", "Family history of IBD" = "familyhistoryibd", "Infliximab" = "previousinfliximab", "Mercatopurine" = "sixmp", "Mesalazine" = "fiveasa", "Other corticosteroids" = "othercoritcosteroids", "Topical treatments" = "topicaltreatments", "Thiopurines" = "thiopurines", "Methotrexate" = "methotrexate", "Arthralgia" = "arthralgia", "Iritis" = "iritis", "Fissure" = "fissure", "Other fistula" = "otherfistula", "Age at diagnostic" = "age_diagnostics", "Previous Surgery" = "surgery", "Years from diagnosis at the start of the trial" = "years_from_diagnosis")



#ui

ui <- fluidPage(
    title = "Baseline characteristics",
    sidebarLayout(
        sidebarPanel(
            selectInput(
                inputId = "stratification",
                label = "Choose a stratification variable",
                choices = labels,
                selected = "treatmentno",
            ),
            selectInput(
                inputId = "variables",
                label = "Choose variables: ",
                choices = labels,
                multiple = TRUE
            ),
            radioButtons(
                inputId = "p",
                label = "Show p-value?",
                choices = c("Yes", "No"),
                selected = "No"
            ),
            downloadButton(
                outputId = "save",
                label = "Save"
            )
        ),
        mainPanel(
            tableOutput(
                outputId = "tab"
            )
        )
    )
)

server <- function(input, output) {
    mylabels = list(age="Age (Years)", a_subjectno="Subject Number", a_centreno = "Centre Number", treatmentno = "Treatment", gender = "Gender", trialstatusid = "Trial Status", trialstatuschangedate = "Last trial status change (days)", diagnosisage = "Age at diagnosis", diseaselocation = "Disease location", diseasebehaviour = "Disease Behaviour", operationnumber = "Number of operations", otherdisease = "Other diseases", familyhistoryibd = "Family history of IBD", previousinfliximab = "Infliximab", sixmp = "Mercatopurine", fiveasa = "Mesalazine", othercoritcosteroids = "Other corticosteroids", topicaltreatments = "Topical treatments", age_diagnostics = "Age at diagnostic", surgery = "Previous Surgery", years_from_diagnosis = "Years from diagnosis at the start of the trial")
    tb <- reactive(
    {
        validate(need(input$variables, "Please select characteristics to compare"))
        if (input$p == "Yes"){
            tableby(formulize(input$stratification, x = input$variables), data = baseline)
        } else {
            my_controls <- tableby.control(test = FALSE)
            tableby(formulize(input$stratification, x=input$variables), data = baseline, control = my_controls)
        }
        
    }
    )
    
    output$tab <- renderTable({
        as.data.frame(summary(tb(), text = "html", labelTranslations = mylabels))
        
    }, sanitize.text.function = identity
    )
    
    output$save <- downloadHandler(
        filename = function() "baseline_characteristics.pdf",
        content = function(file) write2pdf(tb(), file)
    )
}

shinyApp(ui, server)
