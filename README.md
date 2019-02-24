---
title: "README for Getting and Cleaning Data Course Project"
author: "Andrew Eickemeyer"
date: "2/24/2019"
output:
  html_document:
        keep_md: yes
---

## About this Document
The goal of this project is to take the data included in the [Human Activity Recognition Using Smartphones Data Set](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and create an R script, run_analysis.R, which produces a tidy data set from the aforementioned messy data set. In particular, this script will merge the two sets of measurements into a single data frame, apply appropriate labels to the variables included in the data frame and the factor values of the Activity variable, extract only the measurements on the mean and standard deviation of each measurement, and produce an independent tidy data set with the average of each variable extracted this way for each activity/subject pair. The purpose of this document is to provide a detailed description of the behavior of the run_analysis.R script.

##Data Acquisition
The data for this project comes from the UCI Machine Learning Repository. A full description of the data can be found on the site [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones#), and the data for the project can be downloaded as a zip file from this [link](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). 

As mentioned on the site where the data was obtained, the data from the study was built from the recordings of 30 subject performing six different type of activities while carrying waist-mounted smartphones with embedded intertial sensors. The 30 subjects were between 19 and 48 years of age and were split into two groups: 70 percent of the subjects were randomly placed in the **training** group and the other 30 percent were placed in the **test** group. 

According to the information included on the data set, the measurements were obtained using the phones' accelerometer and gyroscope, capturing _"3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz."_  Then, _"the sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain."_

##Walkthrough of run_analysis.R
For reference, we provide the entire script below:
```
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
```
The analysis performed by run_analysis.R utilizes functions from the **dplyr** package. The first lines of the script install this package into R if necessary and then load the package.

```
      if(!require(dplyr)){
            install.packages("dplyr")
      }
      
      # Load dplyr package
      library(dplyr)
```
The function *require* takes the name of an R package as an argument and returns the logical value TRUE if the package has been installed and FALSE if not. In this case, the conditional runs if the **dplyr** package has not been installed, and the code inside the conditional installs the package. After the conditional, the **dplyr** package is loaded into R via the *library* function.

Next, the script loads the eight relevant text files from the data set files as data frames and assigns them to individual variables.

```
      # Read the eight relevant text files from the dataset into R
      activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
      features <- read.table("UCI HAR Dataset/features.txt")
      subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
      x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
      y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
      subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
      x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
      y_train <- read.table("UCI HAR Dataset/train/y_train.txt")
```
The observations of the Activity variable are contained in the y_test and y_train data frames. However, in these data frames the values of the Activity variable are represented by integer values. The activity_labels data frame provides a correspondence between these integer values and descriptive labels for the values of the Activity variable. The subject_test and subject_train data frames contain the observations of the SubjectID variable, the x_test and x_train dataframes contain all observations for the remaining variables, and the features data frame contains the labels for each of these remaining variables.

Next, a new data frame, activity_test, is created that replaces the integer values of the Activity variable in the y_test data frame with descriptive labels. Then, for the purposes of preventing any repeating variables when the script merges data frames, the variable in the subject_test data frame is temporarily labeled 'Subject'. Note that since the data we loaded into R did not include their own column labels, the columns were labeled Vn, where n is an integer value, when they were read in as data frames. Column V2 of activity_labels contains the descriptive factor values for the Activity variable, and column V1 of y_test consists of observations of the Activity variable with integer values.

```
      # Create a data frame that replaces the activity id's in y_test with the 
      # corresponding proper labels
      activities_test <- data.frame(Activity = activity_labels$V2[y_test$V1])
      
      #Rename the variable in subject_test to be descriptive
      names(subject_test) <- "Subject"
```
Similarly, the data frame, activity_train, is created to replace the integer values of the Activity variable in the y_train data frame with descriptive labels, and the variable in the subject_train data frame is temporarily labeled 'Subject' as well.

```
      # Create a data frame that replaces the activity id's in y_test with the 
      # corresponding proper labels
      activities_train <- data.frame(Activity = activity_labels$V2[y_train$V1])
      
      # Rename the variable in subject_train to be descriptive
      names(subject_train) <- "Subject"
```

Next, two data frames are created by binding the the subject_test, activities_test, and x_test data frames together columnwise (in that order), and likewise for the subject_train, activities_train, and x_train dataframes. The *cbind* function is used to achieve this. The resulting data frames are test and train, respectively.

```
      # Create data frames containing the recorded data for the subjects in the 
      # test and train groups
      test <- cbind(subject_test, activities_test, x_test)
      train <- cbind(subject_train, activities_train, x_train)
```
The test data frame contains the variable observations for subjects who had been designated to the test group in the study that produced the original data set. Likewise, the train data frame does the same for subjects in the train group of the study.

Next, a single data frame is created by binding the test and train data frames together rowwise using the *rbind* function. The resulting data frame is named data which contains all observations of all variables recorded in the data set. Then, the rows of the data frame are rearranged according to the value of the Subject variable in ascending order useing the *arrange* function from the **dplyr** package.

```
      # Combine test and train data frames to create a data frame with the recorded 
      # data for all subjects. Then arrange the data frames based on the subject being
      # observed in ascending order
      data <- rbind(test, train)
      data <- data %>% arrange(Subject)
```
Next, a vector of integers, indices, is created to serve as indices corresponding to the columns representing the variables for the means and standard deviations of other variables. All of these variables have either the "mean()" or "std()" substrings in their name.

```
      # Get the indices for the rows of features corresponding to measurements on the
      # mean and standard deviation of each of the features
      indices <- grep("mean\\(\\)|std\\(\\)", features$V2)
```
The vector, indices, is produced by applying the *grep* function to the column of the features data frame containing the labels for the measurement variables of the data set. We use a regular expression to search for either a match of the strings "mean()" or "std()" within each row of this column. The *grep* function returns a vector containing the indices for the rows in which matches were found.

Next, a new data frame, dataSubset, is created containing all the observations for the Activity and Subject variables, as well as for all the variables for the means and standard deviations of other variables.

```
      # Extract a data frame consisting of subject id's, activities, and measurements
      # on the mean and standard deviation of each of the features
      dataSubset <- data[,c(1, 2, indices + 2)]
```
The creation of the dataSubset data frame is achieved by subsetting data according to a vector of indices to retrieve the columns representing the desired variables. The variables Activity and Subject are the first two columns in data. To obtain the indices for the other desired variables we use the vector, indices, that we created, but add 2 to each entry in this vector to account for the first two columns in the data frame we are subsetting being for the Activity and Subject variables.

Next, the final descriptive variable names are applied to the columns of dataSubset.

```
      # Label the data set with clean, descriptive variable names
      names(dataSubset) <- c("SubjectID", "Activity", as.character(features$V2[indices]))
      names(dataSubset) <- gsub("-|\\(|\\)", "", names(dataSubset))
      names(dataSubset) <- gsub("mean", "Mean", names(dataSubset))
      names(dataSubset) <- gsub("std", "Std", names(dataSubset))
```
The first line in the code above gives the first and second columns of dataSubset the names 'SubjectID' and 'Activity', respectively, and each of the other columns are labeled with the appropriate variable name as character vectors by subsetting the column of the features data frame containing variable names according the the indices vector we had created. The other three lines of the code above use the *gsub* function to remove any undesired characters from the names that have been assigned to the variables, as well as to capitalize some other characters to improve the readability of the variable names for the user.

Next, a new, grouped data frame, groupedData, is created from dataSubset so that observations are grouped by both the SubjectID and Activity variables. This is achieved using the *group_by* function.

```
      # Create a new data frame that groups dataSubset by SubjectID and Activity variables
      groupedData <- group_by(dataSubset, SubjectID, Activity)
```

Finally, using the groupedData data frame, the *mean* function, and the *summarize_all* function from the **dplyr** package, a new data frame, sumData, is created that contains the mean values of the measurement variables in the dataSubset data frame for each Subject/Activity pair.

```
      # Create a new, tidy data frame that contains the mean values of the measurement 
      # variables in groupedData for each Subject/Activity pair
      sumData <- summarize_all(groupedData, mean)
```
Each row of the sumData data frame represents observations of the mean values of each of the measurement variables for a Subject/Activity pair. All of the column labels remain the same as those of the dataSubset data frame, but unlike the dataSubset data frame, sumData is a 180 x 68 data frame (a result of there being 30 subjects and 6 activities, for a total of 180 Activity/Subject pairs, as well as 68 variables). The last line of code is a call of sumData to ensure that the script returns this tidy data frame.
