-- database
use Foodie_Fi;


-- Data Analysis Questions
-- dataset
select * from plans;
select * from subscriptions;

-- 1. How many customers has Foodie-Fi ever had?
select count(distinct customer_id) as Total_num_of_customer
from subscriptions;

-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

select date_format(start_date, '%y-%m-01') as start_date,
	   count(*) as trial,
       p.plan_name
from subscriptions s
	   left join plans p
       on s.plan_id =p.plan_id
where p.plan_name = 'trial'
group by date_format(start_date, '%y-%m-01')
order by start_date


-- 3. What plan start_date values occur after the year 2020 for our dataset? 
--     Show the breakdown by count of events for each plan_name

select p.plan_name,
	   count(*) as count_no
from subscriptions s
	   left join plans p
       on s.plan_id =p.plan_id
where  s.start_date > '2020-12-31'
group by p.plan_name
order by count_no desc

-- 4.What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
-- find customers who have churned

select count(distinct customer_id) as count_no_churned_customers,
	   round(
       count(distinct customer_id) * 100.0 / (select count(distinct customer_id) from subscriptions) , 1) as percentage_of_churned_customers
from subscriptions s
left join plans p
	on s.plan_id = p.plan_id
where p.plan_name = 'churn'

-- 5. How many customers have churned straight after their initial free trial -
--    what percentage is this rounded to the nearest whole number?

Trial → Churn = Churned straight after free trial ====> find count
Trial → Paid Plan → Churn = Not straight after trial

select * from plans;
select * from subscriptions;

select count(*) as churned_straight_after_their_initial_free_trial
from subscriptions s1
left join subscriptions s2
	on s1.customer_id = s2.customer_id
left join plans p1
       on s1.plan_id = p1.plan_id
left join plans p2
       on s2.plan_id = p2.plan_id
where p1.plan_name = 'trial' 
	  and  p2.plan_name = 'churn'
	  and s2.start_date > s1.start_date;

-- what percentage is this rounded to the nearest whole number?
select count(*) as churned_straight_after_their_initial_free_trial,
	   round(count(*) * 100.0 / (select count(distinct customer_id) from subscriptions), 1)as '%_churned_straight_after_their_initial_free_trial'
from subscriptions s1
left join subscriptions s2
	on s1.customer_id = s2.customer_id
left join plans p1
       on s1.plan_id = p1.plan_id
left join plans p2
       on s2.plan_id = p2.plan_id
where p1.plan_name = 'trial' 
	  and  p2.plan_name = 'churn'
	  and s2.start_date > s1.start_date;	  
      
      
      
-- 6. What is the number and percentage of customer plans after their initial free trial?

-- "After customers finished their initial trial, what was their next plan?"
--           INITIAL TRIAL
                │
                ↓
--          What happened NEXT?
                │
       ┌────────┼────────┬─────────┐
       ↓        ↓        ↓         ↓
--     Basic     Pro      Pro       Churn
--   Monthly   Monthly  Annual

with customer_plans as (
    select
        s.customer_id,
        p.plan_name,
        lead(p.plan_name) over (
            partition by s.customer_id
            order by s.start_date
        ) as next_plan
    from subscriptions s
    join plans p
        on s.plan_id = p.plan_id
)

select
    next_plan as plan_name,
    count(*) as customer_count,
    round(
        count(*) * 100.0 /
        (select count(*) 
         from customer_plans
         where plan_name = 'trial'),
        1
    ) as percentage
from customer_plans
where plan_name = 'trial'and next_plan is not null
group by next_plan
order by customer_count desc;
      

-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
select * from plans;
select * from subscriptions;

with next_dates as (
select
    customer_id,
    plan_id,
  	start_date,
    lead(start_date) over(partition by customer_id order by start_date) AS next_date
from subscriptions
where start_date <= '2020-12-31'
)

SELECT
	plan_id, 
	count(distinct customer_id) as customers,
	round(
		  COUNT(distinct customer_id) *  100.0 / (select count(distinct customer_id) 
												  from subscriptions) ,1) as percentage
from next_dates
where next_date is null
group by plan_id;       


-- 8. How many customers have upgraded to an annual plan in 2020?
select * from plans;
select * from subscriptions;

select p.plan_name,count(distinct customer_id) as count_annual_plan_2020
from subscriptions s
left join plans p
	on s.plan_id = p.plan_id
where p.plan_name = 'pro annual' and start_date between '2020-01-01' and '2020-12-31';

-- 9. How many days on average does it take for a customer to an annual plan 
-- 	  from the day they join Foodie-Fi?

with cannual_plan as (
select customer_id,
	   min(start_date) as min_start_date
from subscriptions
group by customer_id
)
select datediff(s.start_date,f.min_start_date)
from subscriptions s
left join cannual_plan f
	on s.customer_id = f.customer_id
left join plans p
	on s.plan_id = p.plan_id
where p.plan_name = 'pro annual';

-- many days on average does it take for a customer to an annual plan 
with cannual_plan as (
select customer_id,
	   min(start_date) as min_start_date
from subscriptions
group by customer_id
)
select round(avg(datediff(s.start_date,f.min_start_date))) as average_days
from subscriptions s
left join cannual_plan f
	on s.customer_id = f.customer_id
left join plans p
	on s.plan_id = p.plan_id
where p.plan_name = 'pro annual';

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
with first_join as (
select
	customer_id,
	min(start_date) as first_date
from subscriptions
group by customer_id
),

annual_customers as (
select
	s.customer_id,
	datediff(s.start_date, f.first_date) as days_to_annual
from subscriptions s
join first_join f
	on s.customer_id = f.customer_id
join plans p
	on s.plan_id = p.plan_id
where p.plan_name = 'pro annual'
)

select
    case
        when days_to_annual between 0 and 30 then '0-30'
        when days_to_annual between 31 and 60 then '31-60'
        when days_to_annual between 61 and 90 then '61-90'
        when days_to_annual between 91 and 120 then '91-120'
        when days_to_annual between 121 and 150 then '121-150'
        when days_to_annual between 151 and 180 then '151-180'
        when days_to_annual between 181 and 210 then '181-210'
        when days_to_annual between 211 and 240 then '211-240'
        when days_to_annual between 241 and 270 then '241-270'
        when days_to_annual between 271 and 300 then '271-300'
        when days_to_annual between 301 and 330 then '301-330'
        when days_to_annual between 331 and 360 then '331-360'
        else '361+'
    end as period,
    count(*) as customer_count
from annual_customers
group by period
order by min(days_to_annual);

