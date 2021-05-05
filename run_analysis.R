# Coursera's "Getting and Cleaning Data" Course Project 
# Author: Mojdeh Zamyadi

# This R script performs the following:
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# First, load required packages and get the data
library(data.table)

url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
destfile<-file.path(getwd(),"ProjectData.zip")
download.file(url, destfile)
unzip(zipfile = "ProjectData.zip")

# Load activity labels and features files
activityLabels <- fread(file.path(getwd(), "UCI HAR Dataset/activity_labels.txt"))
colnames(activityLabels) = c("index", "activityLabels")

features <- fread(file.path(getwd(), "UCI HAR Dataset/features.txt"))
colnames(features) = c("index", "features")

# Extracts only the measurements on the mean and standard deviation for each measurement. 
featuresExtracted <- grep("(mean|std)\\(\\)", features[, features])
measurements_wanted <- features[featuresExtracted, features]
measurements_wanted <- gsub('[()]', '', measurements_wanted)

# Load train datasets
train <- fread(file.path(getwd(), "UCI HAR Dataset/train/X_train.txt"))[, ..featuresExtracted]
colnames(train) = measurements_wanted

trainLabels <- fread(file.path(path, "UCI HAR Dataset/train/Y_train.txt")
                         , col.names = c("activityLabel"))

trainSubjects <- fread(file.path(path, "UCI HAR Dataset/train/subject_train.txt")
                       , col.names = c("SubjectNum"))

train <- cbind(trainSubjects, trainLabels, train)

# Load test datasets
test <- fread(file.path(getwd(), "UCI HAR Dataset/test/X_test.txt"))[, ..featuresExtracted]
colnames(test) = measurements_wanted

testLabels <- fread(file.path(path, "UCI HAR Dataset/test/Y_test.txt")
                     , col.names = c("activityLabel"))

testSubjects <- fread(file.path(path, "UCI HAR Dataset/test/subject_test.txt")
                       , col.names = c("SubjectNum"))

test <- cbind(testSubjects, testLabels, test)

# merge datasets
combined <- rbind(train, test)

# Convert class lables (1-6) to activity names based on info in "activity_labels" file
combined[["activityLabel"]] <- factor(combined[, activityLabel]
                                 , levels = activityLabels[["classLabels"]]
                                 , labels = activityLabels[["activityName"]])

# conver subject names into factors 
combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])

combined_new <- melt(data = combined, id = c("SubjectNum", "activityLabel"))
combined_final <- dcast(data = combined_new, SubjectNum + activityLabel ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined_final, file = "tidyData.txt", quote = FALSE)