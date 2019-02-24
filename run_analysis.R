run_analysis <- function(){
      # Install dplyr package if it is not already installed
      if(!require(dplyr)){
            install.packages("dplyr")
      }
      
      # Load dplyr package
      library(dplyr)
      
      # Read the eight relevant text files from the dataset into R
      activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
      features <- read.table("UCI HAR Dataset/features.txt")
      subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
      x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
      y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
      subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
      x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
      y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
      
      
      # Create a data frame that replaces the activity id's in y_test with the 
      # corresponding proper labels
      activities_test <- data.frame(Activity = activity_labels$V2[y_test$V1])
      
      #Rename the variable in subject_test to be descriptive
      names(subject_test) <- "Subject"
      
      # Create a data frame that replaces the activity id's in y_test with the 
      # corresponding proper labels
      activities_train <- data.frame(Activity = activity_labels$V2[y_train$V1])
      
      # Rename the variable in subject_train to be descriptive
      names(subject_train) <- "Subject"
      
      # Create data frames containing the recorded data for the subjects in the 
      # test and train groups
      test <- cbind(subject_test, activities_test, x_test)
      train <- cbind(subject_train, activities_train, x_train)
      
      # Combine test and train data frames to create a data frame with the recorded 
      # data for all subjects. Then arrange the data frames based on the subject being
      # observed in ascending order
      data <- rbind(test, train)
      data <- data %>% arrange(Subject)
      
      
      # Get the indices for the rows of features corresponding to measurements on the
      # mean and standard deviation of each of the features
      indices <- grep("mean\\(\\)|std\\(\\)", features$V2)
      
      # Extract a data frame consisting of subject id's, activities, and measurements
      # on the mean and standard deviation of each of the features
      dataSubset <- data[,c(1, 2, indices + 2)]
      
      # Label the data set with clean, descriptive variable names
      names(dataSubset) <- c("SubjectID", "Activity", as.character(features$V2[indices]))
      names(dataSubset) <- gsub("-|\\(|\\)", "", names(dataSubset))
      names(dataSubset) <- gsub("mean", "Mean", names(dataSubset))
      names(dataSubset) <- gsub("std", "Std", names(dataSubset))
      
      # Create a new data frame that groups dataSubset by SubjectID and Activity variables
      groupedData <- group_by(dataSubset, SubjectID, Activity)
      
      # Create a new, tidy data frame that contains the mean values of the measurement 
      # variables in groupedData for each Subject/Activity pair
      sumData <- summarize_all(groupedData, mean)
      
      # Return this new data frame
      sumData
      
}