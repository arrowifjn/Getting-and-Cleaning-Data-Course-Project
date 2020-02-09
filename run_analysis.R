# Getting and Cleaning Data Project John Hopkins Coursera
# Author: ARROWIF

#You should create one R script called run_analysis.R that does the following.

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.


# Load activity labels + features
library(data.table)
activityLabels <- fread("UCI HAR Dataset/activity_labels.txt", col.names = c("classLabels", "activityName"))
features <- fread("UCI HAR Dataset/features.txt", col.names = c("index", "featureNames")) #get all features and index table
View(features)
featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames]) #get mean and standard deviation col name index vector
View(featuresWanted)
measurements <- features[featuresWanted, featureNames] #get col name
measurements <- gsub('[()]', '', measurements) 
View(measurements)

# Load 3 taining datasets
train <- fread("UCI HAR Dataset/train/X_train.txt")[, featuresWanted, with = FALSE]
head(train)
data.table::setnames(train, colnames(train), measurements)
trainActivities <- fread("UCI HAR Dataset/train/Y_train.txt", col.names = c("Activity"))
head(trainActivities)
trainSubjects <- fread("UCI HAR Dataset/train/subject_train.txt", col.names = c("SubjectNum"))
head(trainActivities)
trainC <- cbind(trainSubjects, trainActivities, train)  # merge 3 table to one df

# Load 3 test datasets
test <- fread("UCI HAR Dataset/test/X_test.txt")[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
testActivities <- fread( "UCI HAR Dataset/test/Y_test.txt", col.names = c("Activity"))
testSubjects <- fread( "UCI HAR Dataset/test/subject_test.txt", col.names = c("SubjectNum"))
testC <- cbind(testSubjects, testActivities, test) # merge 3 table to one df

# merge datasets
combined <- rbind(trainC, testC)

# Convert classLabels to activityName basically. More explicit. 
#combined[["Activity"]]
combined[["Activity"]] <- factor(combined[, Activity], levels = activityLabels[["classLabels"]] , labels = activityLabels[["activityName"]])
#combined[["Activity"]]
combined[["SubjectNum"]] <- as.factor(combined[, SubjectNum])
combined <- reshape2::melt(data = combined, id = c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data = combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined, file = "tidyData.csv", quote = FALSE)
