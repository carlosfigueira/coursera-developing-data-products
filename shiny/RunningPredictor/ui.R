library(shiny)

currentYear <- as.POSIXlt(Sys.time())$year + 1900

shinyUI(pageWithSidebar(
    headerPanel("Running Time Predictor"),
    sidebarPanel(
        div(
            style = "font-size: 11px;",
            p(paste("This app allows you to predict the time you will finish in your next (running) race.",
                    "To do that, you can tweak the following parameters:")),
            tags$ul(
                tags$li(tags$b("Race distance:"), "The distance for the race you want to predict the finishing time, in miles."),
                tags$li(tags$b("Years for training:"), "The training data set used to build the model has data for the past 4 years, but you can restrict it to the most recent results, as it will give a better indication of the estimated time."),
                tags$li(tags$b("Expected effort:"), "Some races are harder than others, due to factors like elevation or climate. You can use this option to better predict how you will finish in your race."),
                tags$li(tags$b("Training pace:"), "There are some training runs where you run in a higher or lower pace than the expected effort; you can use this option to limit the runs used in the training to only those within a certain page range.")
            )
        ),
        sliderInput("raceDistance", "Select the distance for next race (miles)",
                    min = 1, max = 26.2, step = 0.1, value = 6.2),
        
        sliderInput("yearsForTraining", "Use training data since:",
                    min = currentYear - 3, max = currentYear, value = currentYear - 1),
        
        selectInput("expectedEffort", "Select course difficulty",
                    choices = list(Easy = 1, Medium = 2, Hard = 3),
                    selected = 1),
        
        sliderInput("trainingCutoffPace", "Only include training data where the pace (minutes / mile) is between:",
                    min = 7, max = 12.5, step = 0.5, value = c(7, 12.5)),
        div(
            style = "font-size: 11px;",
            p("Notice - the data used to train this model comes from a few runners (exported from their ",
              tags$a(href = "http://connect.garmin.com/", "Garmin Connect"),
              "accounts). This sample was used to build the model for the course project, ",
              "but for a more generic prediction, we would need data for a larger number of runners. ",
              "This predictor also uses a very simple linear model, whose accuracy may not be ideal for professionals. ",
              "Use it as a rough estimate only instead of making decisions with potential serious outcomes based on it.")
        )
    ),
    mainPanel(
        h3("Results for prediction"),
        h4("For a race with this number of miles:"),
        verbatimTextOutput("raceDistance"),
        h4("You should expect to finish with a time of:"),
        verbatimTextOutput("racePredictedFinishTime"),
        h3("Details on training"),
        plotOutput("trainingPlot")
    )
))