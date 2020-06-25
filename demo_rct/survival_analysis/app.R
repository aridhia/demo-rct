#To use in workspace:
#.libPaths("/home/workspace/R/3.5.0")


#PACKAGES
library(shiny)
library(arsenal)
library(readr)
library(survminer)
library(survival)
library(dplyr)

#Importing data
#This data has been generated with the script outcome.R
outcome <- read_csv("./demo_rct/survival_analysis/outcomes.csv", 
                    #Change column types of subject numbers and centre number to characters
                    col_types = cols(a_subjectno = col_character(), a_centreno = col_character()))


ui <- fluidPage(
   
      #The title panel is displayed in the top left hand corner by default 
      titlePanel("Survival Analysis"),
   
      #Start by setting up the sidebar panel   
      sidebarLayout(
            sidebarPanel(
               
                  #Used to select the stratification variable for the analysis
                  selectInput(
                        inputId = "stratification",
                        label = "Choose a stratification variable",
                        choices = names(outcome),
                        selected = "treatmentno",
                  ),
               
                  #It's a conditional panel that will only appear in tab1, that is the tab for the subgroups
                  conditionalPanel(condition = "input.tabs == 1",
                                   radioButtons(
                                         inputId = "filtering",
                                         label = "Do you want filter the dataset?",
                                         choices = list("Yes" = 1, "No" = 0),
                                         selected = 0
                                   )
                  ),
                  
                  #This will only appear in the tab2
                  conditionalPanel(condition = "input.tabs == 2",
                                   selectInput(
                                         inputId = "variables",
                                         label = "Choose variables: ",
                                         choices = names(outcome),
                                         multiple = TRUE
                                   ),
                                   radioButtons(
                                         inputId = "p",
                                         label = "Show p-value?",
                                         choices = c("Yes", "No"),
                                         selected = "No"
                                   )      
                  ),
               
                  #Will only appear in tab3
                  conditionalPanel(condition = "input.tabs == 3",
                                   sliderInput('xvalue', 'Survival Years =', value = 0, min = 0, max = 4, step = 0.25, round = TRUE)
                                   
                  ),
               
                  #Will only appear when the user has decided to subset a part of the population
                  conditionalPanel(condition = "input.filtering == 1",
                                   p(textOutput(outputId = "caption", container = span)),
                                   textOutput("condition"))
            ),
         
            #This will show in the main panel of the app
            mainPanel(
                  #The main panel will be divided in tabs
                  tabsetPanel(id = "tabs",
                              
                              #First tab is for subseting a population
                              tabPanel("Subset", 
                                       value = 1,
                                       #The Panel will only be visible if the user decides to filter the data by clicking "Yes" 
                                       conditionalPanel(condition = "input.filtering == 1",
                                                        #It will show 3 columns: Variable name, Boolean condition and filtering value
                                                        column(4, selectInput("column", "Filter By:", choices = names(outcome))),
                                                        column(4, selectInput("condition", "Boolean", choices = c("==", "!=", ">", "<"))),
                                                        #Filtering values depend on the column chosen, so it's an output
                                                        column(4, uiOutput("col_value"))
                                                        ),
                                       
                              ),
                              
                              #Second tab is for displaying characteristics of the population under study
                              tabPanel("Table", 
                                       value = 2,
                                       #The output is a table
                                       tableOutput(
                                             outputId = "tab"
                                       )
                              ),
                              
                              #Third tab displays the Keplan-Meier graph and a table with the survival probability at a chosen time
                              tabPanel("Keplan-Meier", 
                                       value = 3,
                                       #The output is a plot
                                       plotOutput(
                                             outputId = "kep", 
                                             height = "600px"
                                       ),
                                       #Table with survival probability
                                       tableOutput(
                                             outputId = "survprob"
                                       )
                                       
                              )
                  )
            )
      )
)


server <- function(input, output) {
   
   #Text shown before printed condition in the sidebar panel
   local({
      output$caption <- renderText({
         "Subgroup being used: "
      })
   })
   
   #The values shown in the third column of the subset tab, they depend on the column chosen
   output$col_value <- renderUI({
            x <- as.data.frame(outcome %>% select(input$column))
            if (!is.character(x[1,])){
               x <- na.omit(x)
               sliderInput("value", "Value", min = round(min(x)), max = round(max(x)), value = round(max(x)))
            } else{
               selectInput("value", "Value", choices = x, selected = x[1])
            }
  })
      
  #String made to subset the subjects and display in the sidebar    
  filtering_string <- reactive({
            x <- as.data.frame(outcome %>% select(input$column))
            if (is.numeric(x[1, ])){
               paste0(input$column, " ", input$condition, input$value)
            }else{
               paste0(input$column, " ", input$condition, "\ '", input$value, "\'")
            }
  })
      
   #Text in the sidebar showing population subset 
   output$condition <- renderText({
         filtering_string()
   })
   
   
   #Changing the dataset according to the condition
   subset_data <- reactive({
      #If user does not want to subset, all the dataset is used
           if (input$filtering == 0){
                 return(outcome)
           } else {
                 outcome <- filter_(outcome, filtering_string())
                 return(outcome)
           }      
    })
      
    #Starting to elaborate the table of characteristics  
    tb <- reactive({
                  #Message if the user does not chose characteristics to compare
                  validate(need(input$variables, "Please select characteristics to compare"))
                  if (input$p == "Yes"){
                        tableby(formulize(input$stratification, x = input$variables), data = subset_data())
                  } else {
                        my_controls <- tableby.control(test = FALSE)
                        tableby(formulize(input$stratification, x=input$variables), data = subset_data(), control = my_controls)
                  }        
    })
    
   #Create the final table that will be displayed at the second tab
    output$tab <- renderTable({
            as.data.frame(summary(tb(), text = "html"))
            
      }, sanitize.text.function = identity
    )
      
      
     #Construct the Keplan-Meier plot 
     output$kep <- renderPlot({
            #Survival function - for ggsurvplot has to be inside the renderPlot function
            kmdata <- surv_fit(as.formula(paste('Surv(time,primary.endpoint) ~',input$stratification)),data=subset_data())
            
            #Plotting the survival curves
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
      
   #Survival function outside renderPlot function
   runSur <- reactive({
            survfit(as.formula(paste('Surv(time,primary.endpoint) ~', input$stratification)), data=subset_data())
      })
   
   #Survival table
   output$survprob <- renderTable({
            table <- as.data.frame(summary(runSur(), times = input$xvalue*365.25)[c("surv", "time", "strata")]) %>%
                  mutate(time = time/365.25)
            table
      })
      
}

#This function runs the ShinyApp
shinyApp(ui, server)
