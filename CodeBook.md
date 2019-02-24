---
title: "Codebook For Getting and Cleaning Data Course Project"
author: "Andrew Eickemeyer"
date: "2/24/2019"
output:
  html_document:
        keep_md: yes
---

## Project Description
The goal of this project is to take the data included in the [Human Activity Recognition Using Smartphones Data Set](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and create an R script, run_analysis.R, which produces a tidy data set from the aforementioned messy data set. In particular, this script will merge the two sets of measurements into a single data frame, apply appropriate labels to the variables included in the data frame and the factor values of the Activity variable, extract only the measurements on the mean and standard deviation of each measurement, and produce an independent tidy data set with the average of each variable extracted this way for each activity/subject pair. More information on the behavior of of the script can be found in the **Data Cleaning** section of this document.

##Reading the Output Back Into R
The output of the run_analysis.R script was written into a text file, tidy_data.txt, and is included in the same [Github repository]() as this codebook. This file can be read back into R using the *read.table* function to retrieve the original data frame output. When using *read.table* for this, it is important that the argument header = TRUE is included. If this isn't done, the names of the columns will not be included and instead will only have generic names of the form 'Vn', where n is an integer.

##Data Acquisition
The data for this project comes from the UCI Machine Learning Repository. A full description of the data can be found on the site [here](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones#), and the data for the project can be downloaded as a zip file from this [link](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip). 

As mentioned on the site where the data was obtained, the data from the study was built from the recordings of 30 subject performing six different type of activities while carrying waist-mounted smartphones with embedded intertial sensors. The 30 subjects were between 19 and 48 years of age and were split into two groups: 70 percent of the subjects were randomly placed in the **training** group and the other 30 percent were placed in the **test** group. 

According to the information included on the data set, the measurements were obtained using the phones' accelerometer and gyroscope, capturing _"3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz."_  Then, _"the sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain."_

For detailed information about the variables included in the tidy data set produced from this data, see the **Variable Descriptions** section of this document.

##Tidy Dataset Creation
To run the script to produce the tidy data set, the user must first download and unzip the file containing all of the data from the study ([link](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)). The resulting directory containg the data from the study should be named _UCI HAR Dataset_ and must be in the user's current working directory for the script to run. Do not alter any of the contents of _UCI HAR Dataset_ or the run_analysis.R script may produce an error. The following is a brief description of the behavior of the run_analysis.R script. For a more detailed description, see the [README.md file]() for the script.


###Data Cleaning
As the run_analysis.R script makes use of functions from the **dplyr** package for the cleaning, the script first checks to see if the user has this package installed, installs the package if not, and then loads the package into R:

```
      # Install dplyr package if it is not already installed
      if(!require(dplyr)){
            install.packages("dplyr")
      }
      
      # Load dplyr package
      library(dplyr)
```

The script then loads 8 text files containing relevant data from the _UCI HAR Dataset_ directory as data frames:

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

Using these data frames, the script produces a single tidy data frame, containing all of the variables for which measurements were recorded in the study and all observations of these variables:

```
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
```

From this single tidy data frame, the script extracts a data frame containg only the variables which measure the mean and standard deviation of each measurement:

```
      # Get the indices for the rows of features corresponding to measurements on the
      # mean and standard deviation of each of the features
      indices <- grep("mean\\(\\)|std\\(\\)", features$V2)
      
      # Extract a data frame consisting of subject id's, activities, and measurements
      # on the mean and standard deviation of each of the features
      dataSubset <- data[,c(1, 2, indices + 2)]
```

After this, the script cleans the variable names from the original data set so as not to include any dashes or partentheses.The script then produces a new data frame that groups the observations by SubjectID and Activity:

```
      # Create a new data frame that groups dataSubset by SubjectID and Activity variables
      groupedData <- group_by(dataSubset, SubjectID, Activity)
```

and from this grouped data, produces a final tidy data set which contains the average of each variable for each Subject/Activity pair:

```
      # Create a new, tidy data frame that contains the mean values of the measurement 
      # variables in groupedData for each Subject/Activity pair
      sumData <- summarize_all(groupedData, mean)
```

This is the data set returned by the script.

##Variable Descriptions

###General Information
The tidy dataset, tidy_data.txt, is a 180 x 68 table containing the mean of the observations for each of the numeric variables described below taken over each Subject/Activity pair. For convenience, the descriptions provided for each of the variables is the definition of the variables prior to being summarized in this manner to produce the tidy_data.txt data set. To emphasize, notation is abused slightly, as the numeric variables in tidy_data.txt are actually the means of the numeric variables described below.For convenience, the descriptions provided for each of the variables is the definition of the variables prior to being summarized in this manner to produce the tidy_data.txt data set. To emphasize, notation is abused slightly, as the numeric variables in tidy_data.txt are actually the means of the numeric variables described below. The first two columns represent the Subject and Activity variables, and each other column represents the measurements of the mean of a numeric variable described below for a Subject/Activity pair. A row represents observations of these variables for a single Subject/Activity pair.

It is also important to note that all of the numeric variable observations in the original data set from which the tidy_data.txt set is derived were normalized to be bounded between -1 and 1. Unfortunately, the documentation for the original data set did not include the method for normalization, so we cannot provide the true units for the variables described below. Instead we provide the units for each variable prior to normalization. We also note that the unit 'g' in the table below refers to the standard gravity unit (approximately 9.80665 m/s^2).

One final note is that some of the variables below were obtain via a Fast Fourier Transform of other variables. However, the documentation for the original data set did not specify whether the transform was discrete or continuous, so for the purposes of identifying units for these variables, we have assumed that the transform was discrete.

###Variables

|Variable                 |Class   |Range/Number.of.Levels                   |Unit            |Description                                                                                                                                                                                                                                                         |
|:------------------------|:-------|:----------------------------------------|:---------------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|SubjectID                |integer |1/30                                     |None            |An identification variable indicating the subject performing the activity for a particular observation.                                                                                                                                                             |
|Activity                 |factor  |6                                        |None            |A variable indicating which activity is being performed for a particular observation. Has six levels: WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, and LAYING.                                                                                 |
|tBodyAccMeanX            |numeric |0.22159824394/0.3014610196               |g               |A variable estimating the mean of the body acceleration signal in the X-direction for a particular observation. The domain for this variable is time.                                                                                                               |
|tBodyAccMeanY            |numeric |-0.0405139534294/-0.00130828765170213    |g               |A variable estimating the mean of the body acceleration signal in the Y-direction for a particular observation. The domain for this variable is time.                                                                                                               |
|tBodyAccMeanZ            |numeric |-0.152513899520833/-0.07537846886        |g               |A variable estimating the mean of the body acceleration signal in the Z-direction for a particular observation. The domain for this variable is time.                                                                                                               |
|tBodyAccStdX             |numeric |-0.996068635384615/0.626917070512821     |g               |A variable estimating the standard deviation of the body acceleration signal in the X-direction for a particular observation. The domain for this variable is time.                                                                                                 |
|tBodyAccStdY             |numeric |-0.990240946666667/0.616937015333333     |g               |A variable estimating the standard deviation of the body acceleration signal in the Y-direction for a particular observation. The domain for this variable is time.                                                                                                 |
|tBodyAccStdZ             |numeric |-0.987658662307692/0.609017879074074     |g               |A variable estimating the standard deviation of the body acceleration signal in the Z-direction for a particular observation. The domain for this variable is time.                                                                                                 |
|tGravityAccMeanX         |numeric |-0.680043155060241/0.974508732           |g               |A variable estimating the mean of the gravity acceleration signal in the X-direction for a particular observation. The domain for this variable is time.                                                                                                            |
|tGravityAccMeanY         |numeric |-0.479894842941176/0.956593814210526     |g               |A variable estimating the mean of the gravity acceleration signal in the Y-direction for a particular observation. The domain for this variable is time.                                                                                                            |
|tGravityAccMeanZ         |numeric |-0.49508872037037/0.9578730416           |g               |A variable estimating the mean of the gravity acceleration signal in the Z-direction for a particular observation. The domain for this variable is time.                                                                                                            |
|tGravityAccStdX          |numeric |-0.996764227384615/-0.829554947808219    |g               |A variable estimating the standard deviation of the gravity acceleration signal in the X-direction for a particular observation. The domain for this variable is time.                                                                                              |
|tGravityAccStdY          |numeric |-0.99424764884058/-0.643578361424658     |g               |A variable estimating the standard deviation of the gravity acceleration signal in the Y-direction for a particular observation. The domain for this variable is time.                                                                                              |
|tGravityAccStdZ          |numeric |-0.990957249538462/-0.610161166287671    |g               |A variable estimating the standard deviation of the gravity acceleration signal in the Z-direction for a particular observation. The domain for this variable is time.                                                                                              |
|tBodyAccJerkMeanX        |numeric |0.0426880986186441/0.130193043809524     |g/second        |A variable estimating the mean of the body acceleration jerk signal in the X-direction for a particular observation. The domain for this variable is time.                                                                                                          |
|tBodyAccJerkMeanY        |numeric |-0.0386872111282051/0.056818586275       |g/second        |A variable estimating the mean of the body acceleration jerk signal in the Y-direction for a particular observation. The domain for this variable is time.                                                                                                          |
|tBodyAccJerkMeanZ        |numeric |-0.0674583919268293/0.0380533591627451   |g/second        |A variable estimating the mean of the body acceleration jerk signal in the Z-direction for a particular observation. The domain for this variable is time.                                                                                                          |
|tBodyAccJerkStdX         |numeric |-0.994604542264151/0.544273037307692     |g/second        |A variable estimating the standard deviation of the body acceleration jerk signal in the X-direction for a particular observation. The domain for this variable is time.                                                                                            |
|tBodyAccJerkStdY         |numeric |-0.989513565652174/0.355306716915385     |g/second        |A variable estimating the standard deviation of the body acceleration jerk signal in the Y-direction for a particular observation. The domain for this variable is time.                                                                                            |
|tBodyAccJerkStdZ         |numeric |-0.993288313333333/0.0310157077775926    |g/second        |A variable estimating the standard deviation of the body acceleration jerk signal in the Z-direction for a particular observation. The domain for this variable is time.                                                                                            |
|tBodyGyroMeanX           |numeric |-0.205775427307692/0.19270447595122      |radian/second   |A variable estimating the mean of the body gyroscopic signal in the X-direction measuring angular velocity for a particular observation. The domain for this variable is time.                                                                                      |
|tBodyGyroMeanY           |numeric |-0.204205356087805/0.0274707556666667    |radian/second   |A variable estimating the mean of the body gyroscopic signal in the Y-direction measuring angular velocity for a particular observation. The domain for this variable is time.                                                                                      |
|tBodyGyroMeanZ           |numeric |-0.0724546025804878/0.179102058245614    |radian/second   |A variable estimating the mean of the body gyroscopic signal in the Z-direction measuring angular velocity for a particular observation. The domain for this variable is time.                                                                                      |
|tBodyGyroStdX            |numeric |-0.994276591304348/0.267657219333333     |radian/second   |A variable estimating the standard deviation of the body gyroscopic signal in the X-direction measuring angular velocity for a particular observation. The domain for this variable is time.                                                                        |
|tBodyGyroStdY            |numeric |-0.994210471914894/0.476518714444444     |radian/second   |A variable estimating the standard deviation of the body gyroscopic signal in the Y-direction measuring angular velocity for a particular observation. The domain for this variable is time.                                                                        |
|tBodyGyroStdZ            |numeric |-0.985538363333333/0.564875818162963     |radian/second   |A variable estimating the standard deviation of the body gyroscopic signal in the Z-direction measuring angular velocity for a particular observation. The domain for this variable is time.                                                                        |
|tBodyGyroJerkMeanX       |numeric |-0.157212539189362/-0.0220916265065217   |radian/second^2 |A variable estimating the mean of the body gyroscopic jerk signal in the X-direction for a particular observation. The domain for this variable is time.                                                                                                            |
|tBodyGyroJerkMeanY       |numeric |-0.0768089915604167/-0.0132022768074468  |radian/second^2 |A variable estimating the mean of the body gyroscopic jerk signal in the Y-direction for a particular observation. The domain for this variable is time.                                                                                                            |
|tBodyGyroJerkMeanZ       |numeric |-0.0924998531372549/-0.00694066389361702 |radian/second^2 |A variable estimating the mean of the body gyroscopic jerk signal in the Z-direction for a particular observation. The domain for this variable is time.                                                                                                            |
|tBodyGyroJerkStdX        |numeric |-0.99654254057971/0.179148649684615      |radian/second^2 |A variable estimating the standard deviation of the body gyroscopic jerk signal in the X-direction for a particular observation. The domain for this variable is time.                                                                                              |
|tBodyGyroJerkStdY        |numeric |-0.997081575652174/0.295945926186441     |radian/second^2 |A variable estimating the standard deviation of the body gyroscopic jerk signal in the Y-direction for a particular observation. The domain for this variable is time.                                                                                              |
|tBodyGyroJerkStdZ        |numeric |-0.995380794637681/0.193206498960417     |radian/second^2 |A variable estimating the standard deviation of the body gyroscopic jerk signal in the Z-direction for a particular observation. The domain for this variable is time.                                                                                              |
|tBodyAccMagMean          |numeric |-0.986493196666667/0.644604325128205     |g               |A variable estimating the mean of the magnitude of the body acceleration signal for a particular observation. The domain for this variable is time.                                                                                                                 |
|tBodyAccMagStd           |numeric |-0.986464542615385/0.428405922622222     |g               |A variable estimating the standard deviation of the magnitude of the body acceleration signal for a particular observation. The domain for this variable is time.                                                                                                   |
|tGravityAccMagMean       |numeric |-0.986493196666667/0.644604325128205     |g               |A variable estimating the mean of the magnitude of the gravity acceleration signal for a particular observation. The domain for this variable is time.                                                                                                              |
|tGravityAccMagStd        |numeric |-0.986464542615385/0.428405922622222     |g               |A variable estimating the standard deviation of the magnitude of the gravity acceleration signal for a particular observation. The domain for this variable is time.                                                                                                |
|tBodyAccJerkMagMean      |numeric |-0.99281471515625/0.434490400974359      |g/second        |A variable estimating the mean of the magnitude of the body acceleration jerk signal for a particular observation. The domain for this variable is time.                                                                                                            |
|tBodyAccJerkMagStd       |numeric |-0.994646916811594/0.450612065720513     |g/second        |A variable estimating the standard deviation of the magnitude of the body acceleration jerk signal for a particular observation. The domain for this variable is time.                                                                                              |
|tBodyGyroMagMean         |numeric |-0.980740846769231/0.418004608615385     |radian/second   |A variable estimating the mean of the magnitude of the body gyroscopic signal measuring angular velocity for a particular observation. The domain for this variable is time.                                                                                        |
|tBodyGyroMagStd          |numeric |-0.981372675614035/0.299975979851852     |radian/second   |A variable estimating the standard deviation of the magnitude of the body gyroscopic signal measuring angular velocity for a particular observation. The domain for this variable is time.                                                                          |
|tBodyGyroJerkMagMean     |numeric |-0.997322526811594/0.0875816618205128    |radian/second^2 |A variable estimating the mean of the magnitude of the body gyroscopic jerk signal for a particular observation. The domain for this variable is time.                                                                                                              |
|tBodyGyroJerkMagStd      |numeric |-0.997666071594203/0.250173204117966     |radian/second^2 |A variable estimating the standard deviation of the magnitude of the body gyroscopic jerk signal for a particular observation. The domain for this variable is time.                                                                                                |
|fBodyAccMeanX            |numeric |-0.995249932641509/0.537012022051282     |g               |A variable estimating the mean of the body acceleration signal in the X-direction for a particular observation. Obtained via a Fast Fourier Transform of body acceleration signals. The domain for this variable is frequency.                                      |
|fBodyAccMeanY            |numeric |-0.989034304057971/0.524187686888889     |g               |A variable estimating the mean of the body acceleration signal in the Y-direction for a particular observation. Obtained via a Fast Fourier Transform of body acceleration signals. The domain for this variable is frequency.                                      |
|fBodyAccMeanZ            |numeric |-0.989473926666667/0.280735952206667     |g               |A variable estimating the mean of the body acceleration signal in the Z-direction for a particular observation. Obtained via a Fast Fourier Transform of body acceleration signals. The domain for this variable is frequency.                                      |
|fBodyAccStdX             |numeric |-0.996604570307692/0.658506543333333     |g               |A variable estimating the standard deviation of the body acceleration signal in the X-direction for a particular observation. Obtained via a Fast Fourier Transform of body acceleration signals. The domain for this variable is frequency.                        |
|fBodyAccStdY             |numeric |-0.990680395362319/0.560191344           |g               |A variable estimating the standard deviation of the body acceleration signal in the Y-direction for a particular observation. Obtained via a Fast Fourier Transform of body acceleration signals. The domain for this variable is frequency.                        |
|fBodyAccStdZ             |numeric |-0.987224804307692/0.687124163703704     |g               |A variable estimating the standard deviation of the body acceleration signal in the Z-direction for a particular observation. Obtained via a Fast Fourier Transform of body acceleration signals. The domain for this variable is frequency.                        |
|fBodyAccJerkMeanX        |numeric |-0.994630797358491/0.474317256051282     |g/second        |A variable estimating the mean of the body acceleration jerk signal in the X-direction for a particular observation. Obtained via a Fast Fourier Transform of body acceleration jerk signals. The domain for this variable is frequency.                            |
|fBodyAccJerkMeanY        |numeric |-0.989398823913043/0.276716853307692     |g/second        |A variable estimating the mean of the body acceleration jerk signal in the Y-direction for a particular observation. Obtained via a Fast Fourier Transform of body acceleration jerk signals. The domain for this variable is frequency.                            |
|fBodyAccJerkMeanZ        |numeric |-0.992018447826087/0.157775692377778     |g/second        |A variable estimating the mean of the body acceleration jerk signal in the Z-direction for a particular observation. Obtained via a Fast Fourier Transform of body acceleration jerk signals. The domain for this variable is frequency.                            |
|fBodyAccJerkStdX         |numeric |-0.995073759245283/0.476803887476923     |g/second        |A variable estimating the standard deviation of the body acceleration jerk signal in the X-direction for a particular observation. Obtained via a Fast Fourier Transform of body acceleration jerk signals. The domain for this variable is frequency.              |
|fBodyAccJerkStdY         |numeric |-0.990468082753623/0.349771285415897     |g/second        |A variable estimating the standard deviation of the body acceleration jerk signal in the Y-direction for a particular observation. Obtained via a Fast Fourier Transform of body acceleration jerk signals. The domain for this variable is frequency.              |
|fBodyAccJerkStdZ         |numeric |-0.993107759855072/-0.00623647528983051  |g/second        |A variable estimating the standard deviation of the body acceleration jerk signal in the Z-direction for a particular observation. Obtained via a Fast Fourier Transform of body acceleration jerk signals. The domain for this variable is frequency.              |
|fBodyGyroMeanX           |numeric |-0.99312260884058/0.474962448333333      |radian/second   |A variable estimating the mean of the body gyroscopic signal measuring angular velocity in the X-direction for a particular observation. Obtained via a Fast Fourier Transform of body gyroscopic signals. The domain for this variable is frequency.               |
|fBodyGyroMeanY           |numeric |-0.994025488297872/0.328817010088889     |radian/second   |A variable estimating the mean of the body gyroscopic signal measuring angular velocity in the Y-direction for a particular observation. Obtained via a Fast Fourier Transform of body gyroscopic signals. The domain for this variable is frequency.               |
|fBodyGyroMeanZ           |numeric |-0.985957788/0.492414379822222           |radian/second   |A variable estimating the mean of the body gyroscopic signal measuring angular velocity in the Z-direction for a particular observation. Obtained via a Fast Fourier Transform of body gyroscopic signals. The domain for this variable is frequency.               |
|fBodyGyroStdX            |numeric |-0.994652185217391/0.196613286661538     |radian/second   |A variable estimating the standard deviation of the body gyroscopic signal measuring angular velocity in the X-direction for a particular observation. Obtained via a Fast Fourier Transform of body gyroscopic signals. The domain for this variable is frequency. |
|fBodyGyroStdY            |numeric |-0.994353086595745/0.646233637037037     |radian/second   |A variable estimating the standard deviation of the body gyroscopic signal measuring angular velocity in the Y-direction for a particular observation. Obtained via a Fast Fourier Transform of body gyroscopic signals.                                            |
|fBodyGyroStdZ            |numeric |-0.986725274871795/0.522454216314815     |radian/second   |A variable estimating the standard deviation of the body gyroscopic signal measuring angular velocity in the Z-direction for a particular observation. Obtained via a Fast Fourier Transform of body gyroscopic signals.                                            |
|fBodyAccMagMean          |numeric |-0.986800645362319/0.586637550769231     |g               |A variable estimating the mean of the magnitude body acceleration signal for a particular observation. Obtained via a Fast Fourier Transform of body acceleration signals. The domain for this variable is frequency.                                               |
|fBodyAccMagStd           |numeric |-0.987648484461539/0.178684580868889     |g               |A variable estimating the standard deviatoin of the magnitude body acceleration signal for a particular observation. Obtained via a Fast Fourier Transform of body acceleration signals. The domain for this variable is frequency.                                 |
|fBodyBodyAccJerkMagMean  |numeric |-0.993998275797101/0.538404846128205     |g/second        |A variable estimating the mean of the magnitude of the body acceleration jerk signal for a particular observation. Obtained via a Fast Fourier Transform of body acceleration signals. The domain for this variable is frequency.                                   |
|fBodyBodyAccJerkMagStd   |numeric |-0.994366667681159/0.316346415348718     |g/second        |A variable estimating the standard deviation of the magnitude of the body acceleration jerk signal for a particular observation. Obtained via a Fast Fourier Transform of body acceleration signals. The domain for this variable is frequency.                     |
|fBodyBodyGyroMagMean     |numeric |-0.986535242105263/0.203979764835897     |radian/second   |A variable estimating the mean of the magnitude of the gyroscopic signal measuring angular velocity for a particular observation. Obtained via a Fast Fourier Transform of gyroscopic signals. The domain for this variable is frequency.                           |
|fBodyBodyGyroMagStd      |numeric |-0.981468841692308/0.236659662496296     |radian/second   |A variable estimating the standard deviation of the magnitude of the gyroscopic signal measuring angular velocity for a particular observation. Obtained via a Fast Fourier Transform of gyroscopic signals. The domain for this variable is frequency.             |
|fBodyBodyGyroJerkMagMean |numeric |-0.997617389275362/0.146618569064407     |radian/second^2 |A variable estimating the mean of the magnitude of the gyroscopic jerk signal for a particular observation. Obtained via a Fast Fourier Transform of gyroscopic jerk signals. The domain for this variable is frequency.                                            |
|fBodyBodyGyroJerkMagStd  |numeric |-0.99758523057971/0.287834616098305      |radian/second^2 |A variable estimating the standard deviation of the magnitude of the gyroscopic jerk signal for a particular observation. Obtained via a Fast Fourier Transform of gyroscopic jerk signals. The domain for this variable is frequency.                              |

##Reference Material Used
- **Original Data Source**: _UCI Machine Learning Repository_; http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
- **Information on Fast Fourier Transform and Units**: https://physics.stackexchange.com/questions/15073/how-does-the-fourier-transform-invert-units
- **Model Template for Codebook**: https://gist.github.com/JorisSchut/dbc1fc0402f28cad9b41
- **Guide to Assignment 1**: David Hood; _Getting and Cleaning the Assignment_; https://thoughtfulbloke.wordpress.com/2015/09/09/getting-and-cleaning-the-assignment/
- **Guide to Assignment 2**: Coursera Username: Luis A. Sandino; https://drive.google.com/file/d/0B1r70tGT37UxYzhNQWdXS19CN1U/view

##Annex
**Code to Generate Variable Descriptions Table:**

```r
suppressWarnings(library(openxlsx))
suppressWarnings(library(xtable))
data <- read.xlsx("Var_Info.xlsx")
knitr::kable(data, format = "markdown")
```
