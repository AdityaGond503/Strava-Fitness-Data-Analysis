SELECT * FROM strava.daily_activity_merged;

use strava;

create table daily_activity(
	Id BIGINT,
    ActivityDate DATE,
    TotalSteps INT,
    TotalDistance FLOAT,
    TrackerDistance FLOAT,
    LoggedActivitesDistance FLOAT,
    VeryActiveDistance FLOAT,
    ModeratelyActiveDistance FLOAT,
    LightActiveDistance FLOAT,
    SedentaryActiveDistance FLOAT,
    VeryActiveMinutes INT,
    FairlyActiveMinutes INT,
    LightlyActiveMinutes INT,
    SedentaryMinutes INT,
	Calories INT,
    Date date
    );
    
create table hourlySteps(
	Id BIGINT,
    ActivityHour DATETIME,
    StepTotal INT,
    Date DATE,
    hour DATETIME
);
    
create table sleepDay(
	Id BIGINT,
    Sleepday DATE,
    TotalSleepRecords INT,
    TotalMinutesAsleep INT,
    TotalTimeInBed INT,
    Date DATE
);

create table weightLogInfo(
	Id BIGINT,
    Date DATE,
    WeightKg FLOAT,
    WeightPounds FLOAT,
    BMI FLOAT,
    IsManualReport BOOLEAN,
    LogId INT,
    WeightChange FLOAT
);

-- REFRENTIAL INTEGRITY
use strava;

alter table daily_activity add primary key (Id,ActivityDate); 
describe daily_activity;
describe sleepday;
alter table sleepday modify Id double;

alter table sleepday 
add constraint fk_sleep
foreign key (Id,SleepDay)
references daily_activity(Id,ActivityDate);

alter table weightloginfo
add constraint fk_weight
foreign key (Id,Date)
references daily_activity(Id,ActivityDate);

alter table hourlysteps
add constraint fk_hourly
foreign key (Id)
references daily_activity(Id);

-- SQL Queries for Strava Fitness Analysis
use strava;
-- 1.Average Steps per User
select Id,avg(TotalSteps) as avg_daily_steps
from daily_activity
group by Id
order by avg_daily_steps desc; 
-- Insight: Helps identify most active users.

-- 2.Top 10 Most Active Users
select Id,sum(TotalSteps) as Total_steps
from daily_activity
group by Id
order by Total_steps desc
limit 10;
-- Insight: Shows top performers in physical activity.

-- 3.Average Calories Burned per Day
select avg(Calories) as avg_calories_burned from daily_activity;
-- Insight: Measures average daily calorie burn.

-- 4.Activity Level Classification
select case
when TotalSteps < 5000 then 'Low Activity'
when TotalSteps between 5000 and 10000 then 'Moderate Activity'
else 'High Activity'
end as Activity_level,
count(*) as total_records
from daily_activity
group by Activity_level;
-- Insight: Understand activity distribution of users.

-- 5.Average Sleep Duration per User
select Id,avg(TotalMinutesAsleep) as avg_sleep_minutes
from sleepday
group by Id
order by avg_sleep_minutes desc;
-- Insight: Helps study sleep patterns.

-- 6.Relationship Between Steps and Sleep
select d.Id,avg(d.TotalSteps) as avg_steps,
avg(s.TotalMinutesAsleep) as avg_sleep
from daily_activity d
join sleepday s
on d.Id=s.Id
group by d.Id;
-- Insight: Understand whether active users sleep more or less.

-- 7.Peak Activity Hour
select hour(ActivityHour) as hourofday,
avg(StepTotal) as avgSteps
from hourlysteps
group by hourofday
order by avgSteps desc;
-- Insight: Identifies peak activity hours.

-- 8.Average BMI of Users
select avg(BMI) as avg_bmi from weightloginfo;
-- Insight: Understand overall BMI trend.

-- 9.Calories Burned by Activity Minutes
select avg(VeryActiveMinutes) as avg_veryActive,
avg(FairlyActiveMinutes) as avg_FairlyActive,
avg(LightlyActiveMinutes) as avg_LightlyActive,	
avg(Calories) as avg_calories
from daily_activity;
-- Insight: Shows how activity intensity impacts calorie burn.

-- 10.Steps vs Sedentary Minutes
select avg(TotalSteps) as Avg_steps,
avg(SedentaryMinutes) as Avg_sedentaryTime
from daily_activity;
-- Insight: Shows the relationship between inactivity and movement.

-- 11.Activity vs Weight
select d.Id,
avg(d.TotalSteps) as avgSteps,
avg(w.WeightKg) as avgWeight
from daily_activity d
join weightloginfo w
on d.Id=w.Id
group by d.Id;
-- Insight: Understand whether more active users tend to have lower weight.

-- 12.Identify Highly Active Users
with avg_userSteps as (
	select Id,avg(TotalSteps) as avg_steps from daily_activity 
    group by Id
    )
select * from avg_userSteps where avg_steps >(select avg(TotalSteps) from daily_activity);
-- Insight: Identify users who are more active than the overall population average.

-- 13. Users Burning Above Average Calories
select Id,avg(Calories) as avgCalories from daily_activity
group by Id
having avg(Calories)>(select avg(Calories) from daily_activity);
-- Insight: Identify high energy expenditure users.

    