# run_analysis.R
# Purpose: This is a practice on collect, work with and clean a data set.
# Data Source: University of California, Irvine - Machine Learning Repository
# Dataset Name: Human Activity Recognition Using Smartphones Data Set 
# Resource link: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
# Data Download Link: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 

# Part I. Load and Read Datasets from file/internet

library(plyr)

# Check data

  # Directory of file
  directory <- ("UCI HAR Dataset")
  # Make a list of file names
  file_name <- list.files(directory,full.names=T)
  # Check whether the local file exist, if not, download from website and unzip
  if(length(file_name) == 0){
    message("Can not find local dataset, start to download from website ...")
    fileUrl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileUrl, destfile = "Dataset.zip")
    unzip("Dataset.zip")
  }


# Read in data

  # Read files under train
  train_X <- read.table("UCI HAR Dataset/train/X_train.txt") 
  train_Y <- read.table("UCI HAR Dataset/train/y_train.txt")
  train_Subject <- read.table("UCI HAR Dataset/train/subject_train.txt")
  
  # Read files under test
  test_X <- read.table("UCI HAR Dataset/test/X_test.txt") 
  test_Y <- read.table("UCI HAR Dataset/test/y_test.txt")
  test_Subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
  
  message("data are read, strat to merging ...")
  
  # Merging Data
  mergeX <- rbind(train_X,test_X)
  mergeY <- rbind(train_Y,test_Y)
  mergeSubject <- rbind(train_Subject,test_Subject)
  mergeData <- list(x=mergeX, y=mergeY, subject=mergeSubject)
  
  message("Merging finished ... The result saves as mergeData (data frame)")


# Extracts only the measurements on the mean and standard deviation for each measurement. 
  
  # Read in feature
  features <- read.table("UCI HAR Dataset/features.txt", sep="", header=FALSE)
  # Select features we want
  ext_mean <- sapply(features[,2], function(x) grepl("mean()", x, fixed=T))
  ext_std <- sapply(features[,2], function(x) grepl("std()", x, fixed=T))
  # Create new dataset contain the new data sets
  mergeData$x <- mergeData$x[,(ext_mean | ext_std)]
  colnames(mergeData$x) <- features[(ext_mean | ext_std), 2]
  
  message("Extraction finished ... The result is mergeData$x (data frame)")
  
# Uses descriptive activity names to name the activities in the data set
  
  # Load activity labels
  label_act <- read.table("UCI HAR Dataset/activity_labels.txt")[,2]
  
  # Link label to data
  # Add one more col to mergeY to save the Activity name
  mergeData$y[,2] <- label_act[mergeData$y[,1]]
  names(mergeData$y) <- c("ActivityLabel","ActivityName")
  
  message("Activity named ...The result is updated mergeData$y (data frame in a list)")
  
# Appropriately labels the data set with descriptive variable names. 
  
  colnames(mergeData$subject) <- "subject"
  
# Make the data clean
  # Convert List back to data frame
  temp <- cbind(mergeData$x,mergeData$y,mergeData$subject)
  # Split data frame, apply function, and return results in a data frame.
  tidy <- ddply(temp, .(subject, ActivityName), function(x) colMeans(x[,1:60]))
  
# Save data
  write.table(tidy,file="tidy.txt",row.name=FALSE)
  
  
  