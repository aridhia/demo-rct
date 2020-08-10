##########################################
## BASIC FUNCTIONS TO EDIT THE DATASETS ##
##########################################

basic_edit <- function(dataset) {
      #Column names to lowercase
      colnames(dataset) <- tolower(colnames(dataset))
      #Drop columns with removed information
      rem <- sapply(colnames(dataset), function(i) any(dataset[[i]] == "Removed"))
      dataset <- dataset[!rem]
      return(dataset)
}

col_class <- function(dataset) {
      dataset <- dataset %>%
            #Change all columns that contain date/day in the column name to numeric
            mutate_if(grepl('date|day', colnames(dataset)), as.numeric) %>%
            #Change subject number to a character variable
            mutate(a_subjectno = as.character(a_subjectno))
      return(dataset)
}
