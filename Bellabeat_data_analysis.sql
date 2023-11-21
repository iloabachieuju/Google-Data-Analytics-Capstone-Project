-- GOOGLE DATA ANALYTICS CAPSTONE PROJECT
-- Bellabeat Fitness Data Analysis

/* 
1. INTRODUCTION
-- 1.1 About the Company.
Bellabeat, is a high-tech company that  manufactures health-focused smart products for women such as Bellabeat app, leaf, Time and Spring.
These products connect to app to track activity, sleep, stress and hydration levels. Bellabeat also offers subscription-based membership program 
for users for personalized guidance on nutrition, activity, sleep, health, beauty and mindfulness based on their lifestyle goals.

Bellabeat is a successful small company and founded by Urska Srsen and Sando Mur. Srsen believes that analysis of Bellabeat's available consumer 
data would reveal more opportunities for growth and become a larger player in the global smart device market.


2. ASK

2.1 Business task
The business task is to gain insight on how consumers use non-Bellabeat smart devices and to provide recommendation for how trends in the smart device 
usage data can inform Bellabeat marketing strategy for opportunity for growth.

2.2 Key Stakeholders
The key stakeholders include:
* Urska Srsen (Co-founder and Chief Creative Officer)
* Sando Mur (Co-founder and Mathematician)
* Marketing analytics team


3. PREPARE

3.1 . Data Source and Organization
The data used for this analysis is the FitBit Fitness Tracker data set obtained from [Kaggle.](https://www.kaggle.com/datasets/arashnic/fitbit?resource=download). 
The data was made available through [Mobius](https://www.kaggle.com/arashnic). The data is downloaded and stored locally in a csv format. We will upload the data in MySQL
for cleaning and analysis.
The FitBit Fitness tracker data zip has 18 csv files. 15 of which are presented in long format and 3 in wide format.It contains personal information of 
of eligible fitbit users. The information include physical activity, amount of sleep, weight, steps, heart rate, calories intake etc.

3.2 Data Credibility.
The data contains information of women who were eligible and consented to give their health information as oppose to every women having
a chance to give their information. The sample size is small as compared to the entire population of fitness tracker user. It is bias and the result may not be accurate. 

3.3 Limitation of the Data
* A small sample size of 33 Fitbit user.
* Not enough information about the women


4. PROCESS
We'll create a schema called project to store the data sets as tables in the schema. We'll use the following data set for analysis:
* dailyActivity_merged
* sleepDay_merged

4.1 Data Cleaning and Manipulation
We'll explore, clean and manipulate the data
*/

-- 4.1.1 Take a glimpse of the data sets
-- Retrieve all columns for daily_activity and daily_sleep 
SELECT *
FROM projects.daily_activity;

SELECT *
FROM projects.daily_sleep;

-- 4.1.2 Verify the number of fitbit users and change column names.

-- number of users for Id of daily_activity and daily_sleep
SELECT COUNT(DISTINCT(Id))
FROM projects.daily_activity;

SELECT COUNT(DISTINCT(Id))
 FROM projects.daily_sleep;
 
-- 4.1.3 Check for duplicate values

-- Check for rows with duplicate values for daily_activity using the fields needed.
SELECT Id, Date, TotalSteps, VeryActiveMinutes, FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories, COUNT(*) AS num_of_duplicates
FROM projects.daily_activity
GROUP BY Id, Date, TotalSteps, VeryActiveMinutes, FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories
HAVING COUNT(*) > 1;
-- For the daily_activity table, there are no duplicate values for the fields we need.

-- Check for rows with duplicates values for daily_sleep.
SELECT Id, Date, TotalSleepRecords, TotalMinutesAsleep, TotalMinutesInBed, COUNT(*) AS num_of_duplicates
FROM projects.daily_sleep
GROUP BY Id, Date, TotalSleepRecords, TotalMinutesAsleep, TotalMinutesInBed
HAVING COUNT(*) > 1;

-- Create a new table for daily_sleep that has no duplicate values.
CREATE TABLE projects.new_daily_sleep AS
	SELECT DISTINCT *
    FROM projects.daily_sleep;

-- Check the new_daily_sleep for duplicates again
SELECT Id, Date, TotalSleepRecords, TotalMinutesAsleep, TotalMinutesInBed, COUNT(*) AS num_of_duplicates
FROM projects.new_daily_sleep
GROUP BY Id, Date, TotalSleepRecords, TotalMinutesAsleep, TotalMinutesInBed
HAVING COUNT(*) > 1;
-- There are no duplicates in new_daily_sleep

-- 4.1.4 Check for missing values for daily_activity and new_daily_sleep
SELECT Id, Date, TotalSteps, VeryActiveMinutes, FairlyActiveMinutes, LightlyActiveMinutes, SedentaryMinutes, Calories
FROM projects.daily_activity
WHERE Id IS NULL OR 
	  Date IS NULL OR 
      TotalSteps IS NULL OR 
      VeryActiveMinutes IS NULL OR
      FairlyActiveMinutes IS NULL OR 
      LightlyActiveMinutes IS NULL OR 
      SedentaryMinutes IS NULL OR
      Calories IS NULL;
-- There are no missing values for the fields will be working with.

SELECT *
FROM projects.new_daily_sleep
WHERE Id IS NULL OR
	  Date IS NULL OR
	  TotalSleepRecords IS NULL OR
      TotalMInutesAsleep IS NULL OR
      TotalMinutesInBed IS NULL;
-- There are no missing values for new_daily_sleep

-- 5 ANALYZE
-- 5.1 Compute the average 
-- Average for fields we need for daily_activity
SELECT 
	AVG(TotalSteps) AS 'Avg_TotalSteps',
    AVG(VeryActiveMinutes) AS 'Avg_VeryActiveMinutes',
    AVG(FairlyActiveMinutes) AS 'Avg_FairlyActiveMinutes',
    AVG(LightlyActiveMInutes) AS 'Avg_LightlyActiveMinutes',
    AVG(SedentaryMinutes) AS 'Avg_SedentaryMinutes',
    AVG(Calories) AS 'avg_Calorie'
FROM projects.daily_activity;
 
 /*The average steps in a day is 7638 which is lower than 10,000 steps, the recommended steps most adult aimed to do.
 The average time for activity level varies across the levels.
 The average sedentary time is 991.2 which is approximately 16hrs in a day. Those who are sedentary spend more time being inactive.
 The average calories burned in a day is 2304.
 */
 
 -- Average for new_daily_sleep
 -- We'll explore the average for new_daily_sleep. But first we'll calculate the difference in time it takes the fitbit user to fall asleep
SELECT *, (TotalMinutesInBed - TotalMinutesAsleep) AS Difference_in_time
FROM projects.new_daily_sleep;

SELECT 
	AVG(TotalSleepRecords) AS Avg_TotalSleepRecords,
    AVG(TotalMinutesAsleep) AS Avg_TotalMinutesAsleep,
    AVG(TotalMinutesInBed) AS Avg_TotalMinutesInBed,
    AVG(TotalMinutesInBed - TotalMinutesAsleep) AS Avg_Difference_in_time
FROM projects.new_daily_sleep;

/* The average number of sleep records a user get is approximately 1. This could mean that most user do not 
get enough sleep or a good quality sleep.
Also on average, the total minutes asleep is 419.2 which is approximately 7 hours of sleep
It takes 39.31 minutes on average for users of the fitbit fitness tracker to fall asleep
*/
-- Count Total Sleep Record
SELECT
	TotalSleepRecords,
	COUNT(TotalSleepRecords) AS Sleep_Record_count
FROM projects.new_daily_sleep
GROUP BY TotalSleepRecords;

/* Majority of the users had 1 record of sleep which is 364 in number. 2 records of sleep are 43 in number
and 3 record of sleep are 3 in number. It is likely that majority of the users don't get enough sleep that their bodies need.

6. SHARE
We' ll export the data into tableau  and make visualizations to discover trends and relationships in the data set. 
We'll perform inner join in tableau too. Here is the links to the plots : https://public.tableau.com/app/profile/uju.iloabachie/vizzes

*/
-- 6.1 Data for plots using daily_activity. 
SELECT Id, 
	STR_TO_DATE(Date,"%m/%d/%Y" ) AS Date, 
	TotalSteps, 
	VeryActiveMinutes, 
	FairlyActiveMinutes, 
	LightlyActiveMinutes,
	SedentaryMinutes, 
	Calories
FROM projects.daily_activity;

-- Data for plots using new_sleep_activity
SELECT Id,
	STR_TO_DATE(Date, "%m/%d/%Y") AS Date,
    TotalMinutesAsleep
FROM projects.new_daily_sleep;

/* 7. ACT
Based on the analysis, I recommend the following:

* Bellabeat should focus on creating a reminder feature in the app for sleep routines for users. Also the company should design and build routines
  practices like yoga, meditation and workouts that will enable users to fall asleep quickly since the average time users fall asleep is 39 minutes.
  It can help to improve their sleep quality and to get more sleep cycle.

* Create app in such a way it monitors users sleep activities when they sleep so that users can have a data of their sleep quality and cycle.

* Create notification to encourage sedentary and less active users to take more steps and be very active throughout the day so they can
  get good sleep and burn calories for those who want to lose weight.
  
* Create incentive contents for very active users to encourage them to keep an active lifestyle.
*/











	  



