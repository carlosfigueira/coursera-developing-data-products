library(shiny)
library(lubridate)

rawActivities <- read.csv("AllActivities.csv")
rawActivities$Start <- parse_date_time(substr(rawActivities$Start, 6, 100), "b d Y H M")
rawActivities$Best.SWOLF <- NULL
rawActivities$Avg.SWOLF <- NULL
rawActivities$Min.Strokes <- NULL
rawActivities$Avg.Strokes <- NULL
rawActivities$Total.Strokes <- NULL
rawActivities$X <- NULL
rawActivities$Favorite <- NULL
rawActivities$Activity.Name <- NULL
rawActivities$Activity.Type <- NULL
rawActivities$Course <- NULL
rawActivities$Calories <- as.numeric(gsub(",", "", rawActivities$Calories))
rawActivities$Max.Speed.Best.Pace. <- NULL

durations <- parse_date_time(rawActivities$Time, c("H M S", "M S"))
rawActivities$DurationMinutes <- hour(durations) * 60 + minute(durations) + second(durations) / 60

rawActivities$Elevation.Gain <- as.numeric(gsub(",", "", rawActivities$Elevation.Gain))

paces <- parse_date_time(rawActivities$Avg.Speed.Avg.Pace., "M S")
rawActivities$AvgPace <- minute(paces) + second(paces) / 60

runningActivities <- rawActivities[rawActivities$AvgPace < 12.5,]

shinyServer(function(input, output) {
    trainingActivities <- reactive({runningActivities[
        runningActivities$AvgPace <= input$trainingCutoffPace[2] &
            runningActivities$AvgPace >= input$trainingCutoffPace[1] &
            year(runningActivities$Start) >= input$yearsForTraining,]})
    fit <- reactive({lm(AvgPace ~ Distance, data = trainingActivities())})
    output$raceDistance <- renderPrint({input$raceDistance})
    output$racePredictedFinishTime <- renderPrint({
        predictedTimeStr <- ""
        if (nrow(trainingActivities()) <= 1) {
            predictedTimeStr <- "Not enough data to predict"
        } else {
            predictedPace <- predict(fit(), data.frame(Distance = c(input$raceDistance)))
            multiplier <- ifelse(input$expectedEffort == 1, 0.95, ifelse(input$expectedEffort == 2, 1, 1.05))
            predictedTime <- predictedPace * input$raceDistance * multiplier
            predictedTimeStr <- sprintf("%02d:%02d:%02d",
                    floor(predictedTime / 60),
                    floor(predictedTime %% 60),
                    floor(60 * (predictedTime - floor(predictedTime))))
        }
        
        predictedTimeStr
    })
    output$trainingPlot <- renderPlot({
        if (nrow(trainingActivities()) <= 1) {
            plot(c(3.1), c(10),
                 main = "Not enough data to predict",
                 xlab = "",
                 ylab = "")
            lines(c(0, 6.1), c(8, 12), lwd = 3, col = "red")
            lines(c(6.1, 0), c(8, 12), lwd = 3, col = "red")
        } else {
            plot(trainingActivities()$Distance, trainingActivities()$AvgPace,
                 main = "Data used to predict the finish time",
                 xlab = "Distance run (miles)",
                 ylab = "Average pace (minutes / mile)",
                 col = "red")
            abline(fit())
        }
    })
})