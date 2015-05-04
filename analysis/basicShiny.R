#################
### Commandes ###
### générales ###
#################

library(shiny)
library(readr)

### On charge les données ###
rawFP <- read_csv("../models/FP_data.csv")

##################
### Machinerie ###
##################

server <- function(input, output) {
  # Une fonction réactive qui renvoie un graphique
  output$plothist <- renderPlot({
    mySubset <- subset(rawFP, Year == input$timer & Ag == "null")
    plot(mySubset$X, mySubset$Y)
  })

}

#################
### Interface ###
## Utilisateur ##
#################

ui <- fluidPage(
  fluidRow(
    sliderInput(inputId = "timer", label = "Année",
                step = 20,min = 820, max = 1160,
                value = 800, animate = TRUE)
    ),
      plotOutput("plothist")
  )
)

#################
### Execution ###
#################
shinyApp(ui = ui, server = server)
