library(dplyr)

# Step0: Get the working directory
pwd <- getwd()

# Step1: Download the required dataset
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, file.path(pwd, "RAW_Data.zip"))

# Step2: Unzip the data
unzip(file.path(pwd, "RAW_Data.zip"), overwrite = TRUE, exdir = ".")

# Step3: Update the working dir reference without changing it
pwd <- file.path(pwd, "UCI HAR Dataset")

# Step4: Read the three train files
Subject_Train <- read.table(file.path(pwd, "train", "subject_train.txt"))
X_Train <- read.table(file.path(pwd, "train", "X_train.txt"))
Y_Train <- read.table(file.path(pwd, "train", "y_train.txt"))

# Step5: Read the three test files
Subject_Test <- read.table(file.path(pwd, "test", "subject_test.txt"))
X_Test <- read.table(file.path(pwd, "test", "X_test.txt"))
Y_Test <- read.table(file.path(pwd, "test", "y_test.txt"))

# Step6: Read the column names from features.txt and set the names to the columns in X
ColLabels <- read.table(file.path(pwd, "features.txt"), colClasses = c("integer", "character"))
ColLabels <- ColLabels[, 2]
colnames(X_Train) <- ColLabels
colnames(X_Test) <- ColLabels

# Step7: Read the activiy labels and replace the numbers for the descriptive text in Y
ActivityLabels <- read.table(file.path(pwd, "activity_labels.txt"), colClasses = c("integer", "character"))
Y_Train <- data.frame(sapply(Y_Train, function(x){ActivityLabels[x,2]}))
Y_Test <- data.frame(sapply(Y_Test, function(x){ActivityLabels[x,2]}))

# Step8: Select only the columns with the mean and std.
# Note: In grep function is necesary indicate "\\(" to avoid the meanFreq parameters 
X_Train <- X_Train[, grepl("mean\\(|std\\(", ColLabels)]
X_Test <- X_Test[, grepl("mean\\(|std\\(", ColLabels)]

# Step9: Merge the three dataset (X, Y, Subject)
Subject <- rbind(Subject_Train, Subject_Test)
colnames(Subject) <- c("Subject")

X <- rbind(X_Train, X_Test)

Y <- rbind(Y_Train, Y_Test)
colnames(Y) <- c("Activity")

# Step10: Create a unique data set with descriptive activity names
FinalDf <- cbind(Subject, Y, X)
str(FinalDf)
write.table(FinalDf, file.path(getwd(), "MergeDF.txt"), row.names = FALSE)

# Step11: Create a second dataset with the average of each variable for each activity and subject using aggregate
dtidy <- aggregate(FinalDf, by = list(subject = FinalDf$Subject, activity = FinalDf$Activity), FUN = mean)

# Step12: Select only the columns of interest
dtidy <- dtidy[, !(colnames(dtidy) %in% c("Subject", "Activity"))]

# Step13: Save the tidy dataset
str(dtidy)
write.table(dtidy, file.path(getwd(), "TidyDF.txt"), row.names = FALSE)

