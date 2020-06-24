#PACKAGES
library(shiny)
library(arsenal)
library(readr)
library(survminer)
library(survival)
library(dplyr)

#Importing data
#This data has been generated with the script outcome.R
data <- read_csv("./outcomes.csv")


ui <- fluidPage(
   title = "Survival Analysis",
   sidebarLayout(
      sidebarPanel(
         selectInput(
            inputId = "stratification",
            label = "Choose a stratification variable",
            choices = names(data),
            selected = "treatmentno",
         ),
         conditionalPanel(condition = "input.tabs == 1",
                          radioButtons(
                             inputId = "grouping",
                             label = "Do you want filter the dataset?",
                             choices = list("Yes" = 1, "No" = 0),
                             selected = 0
                          )),
         
         
         conditionalPanel(condition = "input.tabs == 2",
                          selectInput(
                             inputId = "variables",
                             label = "Choose variables: ",
                             choices = names(data),
                             multiple = TRUE
                          ),
                          radioButtons(
                             inputId = "p",
                             label = "Show p-value?",
                             choices = c("Yes", "No"),
                             selected = "No"
                          )
                          
                          
         ),
         conditionalPanel(condition = "input.tabs == 3",
                          sliderInput('xvalue', 'Survival Years =', value = 0, min = 0, max = 4, step = 0.25, round = TRUE)
                          
         )
      ),
      mainPanel(
         tabsetPanel(id = "tabs",
                     tabPanel("Subgroups", value = 1,
                              conditionalPanel(condition = "input.grouping == 1",
                                               column(4, selectInput("column", "Filter By:", choices = names(outcome))),
                                               column(4, selectInput("condition", "Boolean", choices = c("==", "!=", ">", "<"))),
                                               column(4, uiOutput("col_value")),
                                               verbatimTextOutput("condition_text")
                              )
                              
                     ),
                     tabPanel("Table", value = 2,
                              tableOutput(
                                 outputId = "tab"
                              )
                     ),
                     tabPanel("Keplan-Meier", value = 3,
                              plotOutput(
                                 outputId = "kep", height = "600px"
                              ),
                              tableOutput(
                                 outputId = "survprob"
                              )
                              
                     )
         )
      )
   )
)


server <- function(input, output) {
   output$col_value <- renderUI({
      x <- outcome %>% select(!!sym(input$column))
      selectInput("value", "Value", choices = x, selected = x[1])
   })
   
   
   filtering_string <- reactive({
      paste0(input$column, " ", input$condition, "\'", input$value, "\'")
   })
   
   
   output$condition_text <- renderText({
      filtering_string()
   })
   
   subset_data <- reactive({
      if (input$grouping == 0){
         return(data)
      } else {
         data <- filter_(data, filtering_string())
         return(data)
      }
      
   })
   
   
   mylabels = list(age="Age (Years)", a_subjectno="Subject Number", a_centreno = "Centre Number", treatmentno = "Treatment", gender = "Gender", trialstatusid = "Trial Status", trialstatuschangedate = "Last trial status change (days)", diagnosisage = "Age at diagnosis", diseaselocation = "Disease location", diseasebehaviour = "Disease Behaviour", operationnumber = "Number of operations", otherdisease = "Other diseases", familyhistoryibd = "Family history of IBD", previousinfliximab = "Infliximab", sixmp = "Mercatopurine", fiveasa = "Mesalazine", othercoritcosteroids = "Other corticosteroids", topicaltreatments = "Topical treatments", age_diagnostics = "Age at diagnostic", surgery = "Previous Surgery", years_from_diagnosis = "Years from diagnosis at the start of the trial")
   tb <- reactive(
      {
         validate(need(input$variables, "Please select characteristics to compare"))
         if (input$p == "Yes"){
            tableby(formulize(input$stratification, x = input$variables), data = subset_data())
         } else {
            my_controls <- tableby.control(test = FALSE)
            tableby(formulize(input$stratification, x=input$variables), data = subset_data(), control = my_controls)
         }
         
      }
   )
   
   output$tab <- renderTable({
      as.data.frame(summary(tb(), text = "html", labelTranslations = mylabels))
      
   }, sanitize.text.function = identity
   )
   
   
   
   output$kep <- renderPlot({
      
      kmdata <- surv_fit(as.formula(paste('Surv(time,primary.endpoint) ~',input$stratification)),data=subset_data())
      ggsurvplot(kmdata, pval = TRUE,
                 risk.table = TRUE,
                 xscale = "d_y",
                 break.time.by = 365.25,
                 xlab = "Time since randomisation (years)",
                 ylab = "Without clinical recurrence(%)",
                 legend = "bottom",
                 legend.labs = c("Mercaptopurine", "Placebo"),
                 censor = FALSE,
                 tables.y.text = FALSE,
                 risk.table.height = 0.2)
      
      
   })
   
   runSur <- reactive({
      survfit(as.formula(paste('Surv(time,primary.endpoint) ~', input$stratification)), data=subset_data())
   })
   output$survprob <- renderTable({
      table <- as.data.frame(summary(runSur(), times = input$xvalue*365.25)[c("surv", "time", "strata")]) %>%
         mutate(time = time/365.25)
      table
   })
   
}

shinyApp(ui, server)
