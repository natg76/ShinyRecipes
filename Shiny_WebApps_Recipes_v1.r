## Nat G:  Intented for building interactive data apps in Web framework using shinly & plotly.
## Recipes are part of the training exercises.



### Recipe 1 - First Interactive Dashboaord on Shiny 

library(shiny)
library(ggplot2)
load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))

# Define UI for application that plots features of movies
ui <- fluidPage(
  
  # Sidebar layout with a input and output definitions
  sidebarLayout(
    
    # Inputs
    sidebarPanel(
      
      # Select variable for y-axis
      selectInput(inputId = "y", 
                  label = "Y-axis:",
                  choices = c("IMDB Rating" = "imdb_rating", 
                              "IMDB Number of votes" = "imdb_num_votes", 
                              "Critics score" = "critics_score", 
                              "Audience score" = "audience_score", 
                              "Runtime" = "runtime"), 
                  selected = "audience_score"),
      
      # Select variable for x-axis
      selectInput(inputId = "x", 
                  label = "X-axis:",
                  choices = c("IMDB Rating" = "imdb_rating", 
                              "IMDB Number of votes" = "imdb_num_votes", 
                              "Critics score" = "critics_score", 
                              "Audience score" = "audience_score", 
                              "Runtime" = "runtime"), 
                  selected = "critics_score"),
      
      # Select variable for color
      selectInput(inputId = "z",
                  label = "Color by",
                  choices = c("Title type" = "title_type",
                              "Genre" = "genre",
                              "MPAA rating" = "mpaa_rating",
                              "Critics rating" = "critics_rating",
                              "Audience rating" = "audience_rating"
                              ),
                  selected = "mpaa_rating"
      )
    ),
    
    # Output
    mainPanel(
      plotOutput(outputId = "scatterplot")
    )
  )
)

# Define server function required to create the scatterplot
server <- function(input, output) {
  
  # Create the scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    ggplot(data = movies, aes_string(x = input$x, y = input$y,
                                     color = input$z)) +
      geom_point()
  })
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)




### Recipe 2 - Slider Input Example


library(shiny)
library(ggplot2)
load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))

# Define UI for application that plots features of movies
ui <- fluidPage(
  
  # Sidebar layout with a input and output definitions
  sidebarLayout(
    
    # Inputs
    sidebarPanel(
      
      # Select variable for y-axis
      selectInput(inputId = "y", 
                  label = "Y-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"), 
                  selected = "audience_score"),
      
      # Select variable for x-axis
      selectInput(inputId = "x", 
                  label = "X-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"), 
                  selected = "critics_score"),
      
      # Set alpha level
      sliderInput(inputId = "alpha", 
                  label = "Alpha:", 
                  min = 0, max = 1, 
                  value = 0.5)
    ),
    
    # Outputs
    mainPanel(
      plotOutput(outputId = "scatterplot")
    )
  )
)

# Define server function required to create the scatterplot
server <- function(input, output) {
  
  # Create scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    ggplot(data = movies, aes_string(x = input$x, y = input$y)) +
      geom_point(alpha = input$alpha)
  })
}

# Create the Shiny app object
shinyApp(ui = ui, server = server)



### Recipe 3 - Plotting multiple output objects in main panel 

library(shiny)
library(ggplot2)
load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))

# Define UI for application that plots features of movies
ui <- fluidPage(

  # Sidebar layout with a input and output definitions
  sidebarLayout(

    # Inputs
    sidebarPanel(

      # Select variable for y-axis
      selectInput(inputId = "y",
                  label = "Y-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                  selected = "audience_score"),

      # Select variable for x-axis
      selectInput(inputId = "x",
                  label = "X-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                  selected = "critics_score")
    ),

    # Outputs
    mainPanel(
      plotOutput(outputId = "scatterplot", height=250),
      plotOutput(outputId = "densityplot", height=200)
    )
  )
)

# Define server function required to create the scatterplot
server <- function(input, output) {

  # Create scatterplot
  output$scatterplot <- renderPlot({
    ggplot(data = movies, aes_string(x = input$x, y = input$y)) +
      geom_point()
  })

  # Create densityplot
  output$densityplot <- renderPlot({
    ggplot(data = movies, aes_string(x = input$x)) +
      geom_density()
  })

}

# Create the Shiny app object
shinyApp(ui = ui, server = server)


### Recipe 4 Numeric Input and Data Table output Example

library(shiny)
library(dplyr)
library(DT)

load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))
n_total <- nrow(movies)

# Define UI for application that plots features of movies
ui <- fluidPage(
  
  # Sidebar layout with a input and output definitions
  sidebarLayout(
    
    # Inputs
    sidebarPanel(
      
      # Text instructions
      HTML(paste("Enter a value between 1 and", n_total)),
      
      # Numeric input for sample size
      numericInput(inputId = "n",
                   label = "Sample size:",
                   value = 30,
                   step = 1,
                   min = 1,
                   max = n_total)
      
    ),
    
    # Output: Show data table
    mainPanel(
      DT::dataTableOutput(outputId = "moviestable")
    )
  )
)

# Define server function required to create the scatterplot
server <- function(input, output) {
  
  # Create data table
  output$moviestable <- DT::renderDataTable({
    # use req funtion to make sure that sample is calculated only when the input field has a value. To avoid numeric error message happening.
	req(input$n)
    movies_sample <- movies %>%
      sample_n(input$n) %>%
      select(title:studio)
    DT::datatable(data = movies_sample, 
                  options = list(pageLength = 10), 
                  rownames = FALSE)
  })
  
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)



###  Recipe 5 SelectInput for Multiple Selections from the DD list.

library(shiny)
library(ggplot2)
library(dplyr)
library(DT)
load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))
all_studios <- sort(unique(movies$studio))

# UI
ui <- fluidPage(
    sidebarLayout(
    
    # Input(s)
    sidebarPanel(
      selectInput(inputId = "studio",
                  label = "Select studio:",
                  choices = all_studios,
                  selected = "20th Century Fox",
                  multiple = TRUE)
      
    ),
    
    # Output(s)
    mainPanel(
      DT::dataTableOutput(outputId = "moviestable")
    )
  )
)

# Server
server <- function(input, output) {
  
  # Create data table
  
  output$moviestable <- DT::renderDataTable({
  
    req(input$studio)
    movies_from_selected_studios <- movies %>%
      filter(studio %in% input$studio) %>%
      select(title:studio)
    DT::datatable(data = movies_from_selected_studios, 
                  options = list(pageLength = 10), 
                  rownames = FALSE)
  })
  
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)


##  Recipe 6 Date & Date Range inputs

library(shiny)
library(dplyr)
library(ggplot2)
load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))

min_date <- min(movies$thtr_rel_date)
max_date <- max(movies$thtr_rel_date)

# UI
ui <- fluidPage(
    sidebarLayout(
    
    # Input(s)
    sidebarPanel(
      
      # Explanatory text
      HTML(paste0("Movies released between the following dates will be plotted. 
                  Pick dates between ", min_date, " and ", max_date, ".")),
      
      # Break for visual separation
      br(), br(),
      
	  # Date input
##      dateInput(inputId = "date",
##                label = "Select date:",
##                value = "2013-01-01"
##                min = min_date, 
##                max = max_date,
##                startview = "year")
	  
      # Date input
      dateRangeInput(inputId = "date",
                label = "Select dates:",
                start = "2013-01-01",
                end = "2014-01-01",
                min = min_date, 
                max = max_date,
                startview = "year",
				separation = "To")
    ),
    
    # Output(s)
    mainPanel(
      plotOutput(outputId = "scatterplot")
    )
  )
)

# Server
server <- function(input, output) {
  
  # Create the plot
  output$scatterplot <- renderPlot({
    req(input$date)
    movies_selected_date <- movies %>%
      mutate(thtr_rel_date = as.Date(thtr_rel_date)) %>% # convert thtr_rel_date to Date format
      filter(thtr_rel_date >= input$date[1] & thtr_rel_date <= input$date[2])
    ggplot(data = movies_selected_date, aes(x = critics_score, y = audience_score, color = mpaa_rating)) +
      geom_point()
  })
  
}
# Create a Shiny app object
shinyApp(ui = ui, server = server)


## Recipe 7: renderText for printing text on the result panel (main panel)


library(shiny)
library(ggplot2)
load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))

# UI
ui <- fluidPage(
  sidebarLayout(
    
    # Input(s)
    sidebarPanel(
      
      # Select variable for y-axis
      selectInput(inputId = "y", 
                  label = "Y-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"), 
                  selected = "audience_score"),
      
      # Select variable for x-axis
      selectInput(inputId = "x", 
                  label = "X-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"), 
                  selected = "critics_score")
    ),
    
    # Outputs
    mainPanel(
      plotOutput(outputId = "scatterplot"),
      textOutput(outputId = "correlation")
    )
  )
)

# Server
server <- function(input, output) {
  
  # Create scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    ggplot(data = movies, aes_string(x = input$x, y = input$y)) +
      geom_point()
  })
  
  # Create text output stating the correlation between the two ploted 
  output$correlation <- renderText({
    r <- round(cor(movies[,input$x], movies[,input$y], use = "pairwise"), 3)
    paste0("Correlation = ", r, ". Note: If the relationship between the two variables is not linear, the correlation coefficient will not be meaningful.")
  })
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)


## Recipe 8:  Brushing on Plots

# Load packages
library(shiny)
library(ggplot2)
library(tidyverse)
library(DT)

# Load data
load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))

# Define UI for application that plots features of movies
ui <- fluidPage(


  br(),
    
  # Sidebar layout with a input and output definitions
  sidebarLayout(
    # Inputs
    sidebarPanel(
      # Select variable for y-axis
      selectInput(inputId = "y", label = "Y-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                  selected = "audience_score"),
      # Select variable for x-axis
      selectInput(inputId = "x", label = "X-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                  selected = "critics_score")
    ),

    # Output:
    mainPanel(
      # Show scatterplot with brushing capability
      plotOutput(outputId = "scatterplot", brush = "plot_brush"),
      # Show data table
      dataTableOutput(outputId = "moviestable"),
      br()
    )
  )
)

# Define server function required to create the scatterplot
server <- function(input, output) {

  # Create scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    ggplot(data = movies, aes_string(x = input$x, y = input$y)) +
      geom_point()
  })
  
  # Create data table
  output$moviestable <- DT::renderDataTable({
    brushedPoints(movies, brush = input$plot_brush) %>% 
      select(title, audience_score, critics_score)
  })
  
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)


## Recipe 9:  Hovering on Plots

# Load packages
library(shiny)
library(ggplot2)
library(tidyverse)
library(DT)

# Load data
load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))

# Define UI for application that plots features of movies
ui <- fluidPage(

  br(),
    
  # Sidebar layout with a input and output definitions
  sidebarLayout(
    # Inputs
    sidebarPanel(
      # Select variable for y-axis
      selectInput(inputId = "y", label = "Y-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                  selected = "audience_score"),
      # Select variable for x-axis
      selectInput(inputId = "x", label = "X-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                  selected = "critics_score")
    ),

    # Output:
    mainPanel(
      # Show scatterplot with brushing capability
      plotOutput(outputId = "scatterplot", hover = "plot_hover"),
      # Show data table
      dataTableOutput(outputId = "moviestable"),
      br()
    )
  )
)

# Define server function required to create the scatterplot
server <- function(input, output) {

  # Create scatterplot object the plotOutput function is expecting
  output$scatterplot <- renderPlot({
    ggplot(data = movies, aes_string(x = input$x, y = input$y)) +
      geom_point()
  })
  
  # Create data table
  # output$moviestable <- DT::renderDataTable({
  #  brushedPoints(movies, brush = input$plot_brush) %>% 
  #    select(title, audience_score, critics_score)
  # })
  
  # Create data table #coordinfo does the trick
  output$moviestable <- DT::renderDataTable({
    nearPoints(movies, coordinfo = input$plot_hover) %>% 
      select(title, audience_score, critics_score)
  })
  
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)




## Recipe 10:  Displaying Text Outputs : Formatted and Plain


library(shiny)
library(dplyr)
library(ggplot2)
load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))

# UI
ui <- fluidPage(
  sidebarLayout(
    
    # Input(s)
    sidebarPanel(
      
      # Select variable for y-axis
      selectInput(inputId = "y",
                  label = "Y-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                  selected = "audience_score"),
      
      # Select variable for x-axis
      selectInput(inputId = "x",
                  label = "X-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                  selected = "critics_score")
      
    ),
    
    # Output(s)
    mainPanel(
      plotOutput(outputId = "scatterplot"),
      textOutput(outputId = "avg_x"), # avg of x
      h3(textOutput(outputId = "avg_y")), # avg of y
      verbatimTextOutput(outputId = "lmoutput") # regression output
    )
  )
)

# Server
server <- function(input, output) {
  
  # Create scatterplot
  output$scatterplot <- renderPlot({
    ggplot(data = movies, aes_string(x = input$x, y = input$y)) +
      geom_point()
  })
  
  # Calculate average of x
  output$avg_x <- renderText({
    avg_x <- movies %>% pull(input$x) %>% mean() %>% round(2)
    paste("Average", input$x, "=", avg_x)
  })
  
  # Calculate average of y
  output$avg_y <- renderText({
    avg_y <- movies %>% pull(input$y) %>% mean() %>% round(2)
    paste("Average", input$y, "=", avg_y)
  })
  
  # Create regression output
  output$lmoutput <- renderPrint({
    x <- movies %>% pull(input$x)
    y <- movies %>% pull(input$y)
    summ <- summary(lm(y ~ x, data = movies)) 
    print(summ, digits = 3, signif.stars = FALSE)
  })
  
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)


## Recipe 11:  Creating and formatting HTML output

library(shiny)
library(dplyr)
library(ggplot2)
load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))

# UI
ui <- fluidPage(
  sidebarLayout(
    
    # Input(s)
    sidebarPanel(
      
      # Select variable for y-axis
      selectInput(inputId = "y",
                  label = "Y-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                  selected = "audience_score"),
      
      # Select variable for x-axis
      selectInput(inputId = "x",
                  label = "X-axis:",
                  choices = c("imdb_rating", "imdb_num_votes", "critics_score", "audience_score", "runtime"),
                  selected = "critics_score")
      
    ),
    
    # Output(s)
    mainPanel(
      plotOutput(outputId = "scatterplot"),
      htmlOutput(outputId = "avgs"), # avg of x
      verbatimTextOutput(outputId = "lmoutput") # regression output
    )
  )
)

# Server
server <- function(input, output) {
  
  # Create scatterplot
  output$scatterplot <- renderPlot({
    ggplot(data = movies, aes_string(x = input$x, y = input$y)) +
      geom_point()
  })

  # Calculate averages
  output$avgs <- renderUI({
    avg_x <- movies %>% pull(input$x) %>% mean() %>% round(2)
    avg_y <- movies %>% pull(input$y) %>% mean() %>% round(2)
    HTML(
      paste("Average", input$x, "=", avg_x),
      "<br/>",
      paste("Average", input$y, "=", avg_y)
    )
  })
  
  # Create regression output
  output$lmoutput <- renderPrint({
    x <- movies %>% pull(input$x)
    y <- movies %>% pull(input$y)
    print(summary(lm(y ~ x, data = movies)), digits = 3, signif.stars = FALSE)
  })
  
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)


## Recipe 12:  Downloading data with download button

library(shiny)
library(dplyr)
library(readr)
load(url("http://s3.amazonaws.com/assets.datacamp.com/production/course_4850/datasets/movies.Rdata"))

# UI
ui <- fluidPage(
  sidebarLayout(
    
    # Input(s)
    sidebarPanel(
      
      # Select filetype
      radioButtons(inputId = "filetype",
                   label = "Select filetype:",
                   choices = c("csv", "tsv"),
                   selected = "csv"),
      
      # Select variables to download
      checkboxGroupInput(inputId = "selected_var",
                  label = "Select variables:",
                  choices = names(movies),
                  selected = c("title"))
      
    ),
    
    # Output(s)
    mainPanel(
      HTML("Select filetype and variables, then hit 'Download data'."),
      br(), br(), # line break and some visual separation
      downloadButton(outputId = "download_data", label = "Download data")
    )
  )
)

# Server
server <- function(input, output) {
  
  # Download file
  output$download_data <- downloadHandler(
    filename = function() {
      paste0("movies.", input$filetype)
      },
    content = function(file) { 
      if(input$filetype == "csv"){ 
        write_csv(movies %>% select(input$selected_var), path = file) 
        }
      if(input$filetype == "tsv"){ 
        write_tsv(movies %>% select(input$selected_var), path = file) 
        }
    }
  )
  
}

# Create a Shiny app object
shinyApp(ui = ui, server = server)