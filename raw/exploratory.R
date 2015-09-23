library(lubridate)

rawActivities <- read.csv("../data/AllActivities.csv")
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

fit <- lm(AvgPace ~ Distance, data = runningActivities)

png("trainingData.png")
plot(runningActivities$Distance, runningActivities$AvgPace,
     main = "Data used to predict the finish time",
     xlab = "Distance run (miles)",
     ylab = "Average pace (minutes / mile)",
     col = "red")
abline(fit)
dev.off()

# Things to change
# - training pace
# - distance
# - elevation
